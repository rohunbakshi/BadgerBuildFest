// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title ExternalCertificationRegistry
 * @dev Registers and verifies external certifications (AWS, Google Cloud, Microsoft, etc.)
 */
contract ExternalCertificationRegistry is Ownable, ReentrancyGuard {
    struct Certification {
        bytes32 certId;
        address holder;
        string certName;           // "AWS Certified Solutions Architect"
        string issuer;              // "Amazon Web Services"
        string certNumber;          // Certification number from issuer
        bytes32 certDataHash;       // Hash of certification details
        uint256 issuedAt;
        uint256 expiresAt;
        bool verified;              // Verified via API or issuer
        bool revoked;
        address registeredBy;       // Who registered it (issuer or API)
    }
    
    mapping(bytes32 => Certification) public certifications;
    mapping(address => bytes32[]) public userCertifications;
    mapping(string => address) public authorizedIssuers; // Issuer name → authorized address
    mapping(address => bool) public authorizedRegistrars; // Who can register certifications
    
    event CertificationRegistered(
        bytes32 indexed certId,
        address indexed holder,
        string certName,
        string issuer
    );
    
    event CertificationRevoked(
        bytes32 indexed certId,
        address indexed holder
    );
    
    constructor() Ownable(msg.sender) {
        authorizedRegistrars[msg.sender] = true;
    }
    
    /**
     * @dev Register external certification
     * @param certId Unique identifier for the certification
     * @param holder Address of the certification holder
     * @param certName Name of the certification
     * @param issuer Issuer name (AWS, Google, Microsoft, etc.)
     * @param certNumber Certification number from issuer
     * @param certDataHash Hash of certification details
     * @param expiresAt Expiration timestamp (0 = no expiration)
     */
    function registerCertification(
        bytes32 certId,
        address holder,
        string calldata certName,
        string calldata issuer,
        string calldata certNumber,
        bytes32 certDataHash,
        uint256 expiresAt
    ) external nonReentrant {
        require(authorizedRegistrars[msg.sender], "Unauthorized registrar");
        require(certifications[certId].certId == bytes32(0), "Certification already exists");
        require(holder != address(0), "Invalid holder address");
        require(bytes(certName).length > 0, "Invalid certification name");
        require(bytes(issuer).length > 0, "Invalid issuer");
        require(expiresAt == 0 || expiresAt > block.timestamp, "Invalid expiration date");
        
        // If issuer is authorized, auto-verify
        bool isVerified = authorizedIssuers[issuer] == msg.sender;
        
        certifications[certId] = Certification({
            certId: certId,
            holder: holder,
            certName: certName,
            issuer: issuer,
            certNumber: certNumber,
            certDataHash: certDataHash,
            issuedAt: block.timestamp,
            expiresAt: expiresAt,
            verified: isVerified,
            revoked: false,
            registeredBy: msg.sender
        });
        
        userCertifications[holder].push(certId);
        
        emit CertificationRegistered(certId, holder, certName, issuer);
    }
    
    /**
     * @dev Verify a certification
     * @param certId Certification ID
     * @return valid True if certification exists and is verified
     * @return notExpired True if not expired
     * @return notRevoked True if not revoked
     */
    function verifyCertification(bytes32 certId) 
        external 
        view 
        returns (bool valid, bool notExpired, bool notRevoked) 
    {
        Certification memory cert = certifications[certId];
        valid = cert.certId != bytes32(0) && cert.verified;
        notExpired = cert.expiresAt == 0 || cert.expiresAt > block.timestamp;
        notRevoked = !cert.revoked;
    }
    
    /**
     * @dev Get certification information
     */
    function getCertification(bytes32 certId) 
        external 
        view 
        returns (Certification memory) 
    {
        return certifications[certId];
    }
    
    /**
     * @dev Get all certifications for a user
     */
    function getUserCertifications(address user) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        return userCertifications[user];
    }
    
    /**
     * @dev Authorize a certification issuer (e.g., AWS, Google)
     */
    function authorizeIssuer(string calldata issuerName, address issuerAddress) 
        external 
        onlyOwner 
    {
        authorizedIssuers[issuerName] = issuerAddress;
    }
    
    /**
     * @dev Authorize a registrar (who can register certifications)
     */
    function authorizeRegistrar(address registrar) 
        external 
        onlyOwner 
    {
        authorizedRegistrars[registrar] = true;
    }
    
    /**
     * @dev Revoke registrar authorization
     */
    function revokeRegistrar(address registrar) 
        external 
        onlyOwner 
    {
        authorizedRegistrars[registrar] = false;
    }
    
    /**
     * @dev Manually verify a certification (admin only)
     */
    function verifyCertificationManually(bytes32 certId) 
        external 
        onlyOwner 
    {
        require(certifications[certId].certId != bytes32(0), "Certification not found");
        certifications[certId].verified = true;
    }
    
    /**
     * @dev Revoke a certification (issuer or admin)
     */
    function revokeCertification(bytes32 certId) 
        external 
    {
        Certification storage cert = certifications[certId];
        require(cert.certId != bytes32(0), "Certification not found");
        require(
            msg.sender == cert.registeredBy || 
            msg.sender == authorizedIssuers[cert.issuer] ||
            msg.sender == owner(),
            "Unauthorized"
        );
        require(!cert.revoked, "Certification already revoked");
        
        cert.revoked = true;
        emit CertificationRevoked(certId, cert.holder);
    }
    
    /**
     * @dev Batch verify multiple certifications
     */
    function batchVerifyCertifications(bytes32[] calldata certIds) 
        external 
        view 
        returns (bool[] memory results) 
    {
        results = new bool[](certIds.length);
        for (uint256 i = 0; i < certIds.length; i++) {
            Certification memory cert = certifications[certIds[i]];
            results[i] = cert.verified && 
                      !cert.revoked && 
                      (cert.expiresAt == 0 || cert.expiresAt > block.timestamp);
        }
    }
}

