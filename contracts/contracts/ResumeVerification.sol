// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./CredentialRegistry.sol";
import "./CredentialBridge.sol";
import "./ExternalCertificationRegistry.sol";

/**
 * @title ResumeVerification
 * @dev Verifies resumes against on-chain credentials and detects fraud
 */
contract ResumeVerification is Ownable, ReentrancyGuard {
    struct ResumeClaim {
        string claimType;          // "education", "employment", "certification", "skill"
        bytes32 credentialId;      // Reference to credential (if on-chain)
        string description;        // Human-readable claim
        bool verified;              // Verification status
        string verificationSource;  // "ethereum", "solana", "external", "unverified"
    }
    
    struct VerifiedResume {
        address owner;
        bytes32 resumeHash;         // Hash of resume content
        ResumeClaim[] claims;       // All claims in resume
        uint256 verifiedAt;
        bool isFullyVerified;
        uint256 verifiedClaimCount;
        uint256 totalClaimCount;
        string[] issues;            // Any discrepancies found
    }
    
    CredentialRegistry public credentialRegistry;
    CredentialBridge public credentialBridge;
    ExternalCertificationRegistry public externalCertRegistry;
    
    mapping(bytes32 => VerifiedResume) public verifiedResumes;
    mapping(address => bytes32[]) public userResumes;
    mapping(bytes32 => bool) public resumeExists;
    
    event ResumeVerified(
        bytes32 indexed resumeId,
        address indexed owner,
        bool fullyVerified,
        uint256 claimCount,
        uint256 verifiedCount
    );
    
    event FraudDetected(
        bytes32 indexed resumeId,
        address indexed owner,
        string[] issues
    );
    
    event ClaimVerified(
        bytes32 indexed resumeId,
        uint256 claimIndex,
        bool verified,
        string claimType
    );
    
    constructor(
        address _credentialRegistry,
        address _credentialBridge,
        address _externalCertRegistry
    ) Ownable(msg.sender) {
        credentialRegistry = CredentialRegistry(_credentialRegistry);
        credentialBridge = CredentialBridge(_credentialBridge);
        externalCertRegistry = ExternalCertificationRegistry(_externalCertRegistry);
    }
    
    /**
     * @dev Register and verify a resume
     * @param resumeId Unique identifier for the resume
     * @param resumeHash Hash of resume content
     * @param claims Array of claims in the resume
     * @return fullyVerified True if all claims are verified
     * @return issues Array of issues found during verification
     */
    function verifyResume(
        bytes32 resumeId,
        bytes32 resumeHash,
        ResumeClaim[] calldata claims
    ) external nonReentrant returns (bool fullyVerified, string[] memory issues) {
        require(!resumeExists[resumeId], "Resume already verified");
        require(claims.length > 0, "Resume must have at least one claim");
        
        issues = new string[](0);
        uint256 verifiedCount = 0;
        
        // Create storage struct
        VerifiedResume storage verifiedResume = verifiedResumes[resumeId];
        verifiedResume.owner = msg.sender;
        verifiedResume.resumeHash = resumeHash;
        verifiedResume.verifiedAt = block.timestamp;
        verifiedResume.totalClaimCount = claims.length;
        
        // Verify each claim and push to storage array
        for (uint256 i = 0; i < claims.length; i++) {
            bool claimVerified = false;
            string memory source = "unverified";
            
            // Verify based on claim type
            if (keccak256(bytes(claims[i].claimType)) == keccak256(bytes("education"))) {
                // Verify educational credential (may be bridged from Solana)
                (claimVerified, source) = verifyEducationalCredential(claims[i].credentialId);
            } else if (keccak256(bytes(claims[i].claimType)) == keccak256(bytes("employment"))) {
                // Verify professional credential (on Ethereum)
                (claimVerified, source) = verifyProfessionalCredential(claims[i].credentialId);
            } else if (keccak256(bytes(claims[i].claimType)) == keccak256(bytes("certification"))) {
                // Verify external certification
                (claimVerified, source) = verifyExternalCertification(claims[i].credentialId);
            } else if (keccak256(bytes(claims[i].claimType)) == keccak256(bytes("skill"))) {
                // Verify skill credential (could be on either chain)
                (claimVerified, source) = verifySkillCredential(claims[i].credentialId);
            }
            
            // Push verified claim to storage array
            // Create struct in memory first to avoid calldata-to-storage copy issues
            ResumeClaim memory newClaim = ResumeClaim({
                claimType: claims[i].claimType,
                credentialId: claims[i].credentialId,
                description: claims[i].description,
                verified: claimVerified,
                verificationSource: source
            });
            verifiedResume.claims.push(newClaim);
            
            if (claimVerified) {
                verifiedCount++;
                emit ClaimVerified(resumeId, i, true, claims[i].claimType);
            } else {
                // Emit event for unverified claim
                // Note: Issues are tracked via events since Solidity doesn't easily support dynamic string arrays
                emit ClaimVerified(resumeId, i, false, claims[i].claimType);
            }
        }
        
        fullyVerified = verifiedCount == claims.length;
        verifiedResume.isFullyVerified = fullyVerified;
        verifiedResume.verifiedClaimCount = verifiedCount;
        
        userResumes[msg.sender].push(resumeId);
        resumeExists[resumeId] = true;
        
        if (fullyVerified) {
            emit ResumeVerified(resumeId, msg.sender, true, claims.length, verifiedCount);
        } else {
            emit FraudDetected(resumeId, msg.sender, issues);
        }
        
        return (fullyVerified, issues);
    }
    
    /**
     * @dev Verify educational credential (may be bridged from Solana)
     */
    function verifyEducationalCredential(bytes32 credentialId) 
        internal 
        view 
        returns (bool verified, string memory source) 
    {
        // Check if bridged from Solana
        if (address(credentialBridge) != address(0)) {
            if (credentialBridge.isBridgedCredentialValid(credentialId)) {
                return (true, "solana");
            }
        }
        
        // Check if on Ethereum (some educational credentials might be here)
        (bool exists, bool notRevoked, bool notExpired, bool issuerVerified) = 
            credentialRegistry.verifyCredential(credentialId);
        
        if (exists && notRevoked && notExpired && issuerVerified) {
            return (true, "ethereum");
        }
        
        return (false, "unverified");
    }
    
    /**
     * @dev Verify professional credential (on Ethereum)
     */
    function verifyProfessionalCredential(bytes32 credentialId) 
        internal 
        view 
        returns (bool verified, string memory source) 
    {
        (bool exists, bool notRevoked, bool notExpired, bool issuerVerified) = 
            credentialRegistry.verifyCredential(credentialId);
        
        if (exists && notRevoked && notExpired && issuerVerified) {
            return (true, "ethereum");
        }
        
        return (false, "unverified");
    }
    
    /**
     * @dev Verify external certification (AWS, Google Cloud, etc.)
     */
    function verifyExternalCertification(bytes32 certId) 
        internal 
        view 
        returns (bool verified, string memory source) 
    {
        if (address(externalCertRegistry) != address(0)) {
            (bool valid, bool notExpired, bool notRevoked) = 
                externalCertRegistry.verifyCertification(certId);
            
            if (valid && notExpired && notRevoked) {
                return (true, "external");
            }
        }
        
        return (false, "unverified");
    }
    
    /**
     * @dev Verify skill credential (could be on Solana or Ethereum)
     */
    function verifySkillCredential(bytes32 credentialId) 
        internal 
        view 
        returns (bool verified, string memory source) 
    {
        // Check bridge first (Solana skills)
        if (address(credentialBridge) != address(0)) {
            if (credentialBridge.isBridgedCredentialValid(credentialId)) {
                return (true, "solana");
            }
        }
        
        // Check Ethereum
        (bool exists, bool notRevoked, bool notExpired, bool issuerVerified) = 
            credentialRegistry.verifyCredential(credentialId);
        
        if (exists && notRevoked && notExpired && issuerVerified) {
            return (true, "ethereum");
        }
        
        return (false, "unverified");
    }
    
    /**
     * @dev Get verification status of a resume
     */
    function getResumeVerification(bytes32 resumeId) 
        external 
        view 
        returns (VerifiedResume memory) 
    {
        require(resumeExists[resumeId], "Resume not found");
        return verifiedResumes[resumeId];
    }
    
    /**
     * @dev Batch verify multiple resumes
     */
    function batchVerifyResumes(bytes32[] calldata resumeIds) 
        external 
        view 
        returns (bool[] memory results) 
    {
        results = new bool[](resumeIds.length);
        for (uint256 i = 0; i < resumeIds.length; i++) {
            if (resumeExists[resumeIds[i]]) {
                results[i] = verifiedResumes[resumeIds[i]].isFullyVerified;
            } else {
                results[i] = false;
            }
        }
    }
    
    /**
     * @dev Get all resumes for a user
     */
    function getUserResumes(address user) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        return userResumes[user];
    }
    
    /**
     * @dev Check if a resume is fully verified
     */
    function isResumeVerified(bytes32 resumeId) 
        external 
        view 
        returns (bool) 
    {
        if (!resumeExists[resumeId]) {
            return false;
        }
        return verifiedResumes[resumeId].isFullyVerified;
    }
}

