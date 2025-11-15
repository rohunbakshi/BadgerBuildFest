// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title ResumeRegistry
 * @dev Manages resume creation, updates, and access control
 */
contract ResumeRegistry is Ownable, ReentrancyGuard {
    constructor() Ownable(msg.sender) {}
    struct Resume {
        bytes32 resumeId;
        address owner;
        bytes32[] credentialIds; // References to verified credentials
        bytes32 contentHash; // Hash of resume content (JSON/PDF) stored off-chain
        string offChainUri; // IPFS or cloud storage URI
        uint256 createdAt;
        uint256 updatedAt;
        bool isActive;
    }

    struct AccessGrant {
        bytes32 grantId;
        address owner;
        address employer; // Optional: specific employer address, or address(0) for token-based access
        bytes32 resumeId;
        bytes32 accessToken; // Hash of access token for link-based sharing
        uint256 createdAt;
        uint256 expiresAt; // 0 means no expiration
        bool revoked;
    }

    mapping(bytes32 => Resume) public resumes;
    mapping(address => bytes32[]) public userResumes; // User address => array of resume IDs
    mapping(bytes32 => AccessGrant) public accessGrants;
    mapping(bytes32 => bool) public validAccessTokens; // accessToken hash => valid
    
    event ResumeCreated(
        bytes32 indexed resumeId,
        address indexed owner,
        bytes32 contentHash,
        string offChainUri,
        uint256 timestamp
    );
    
    event ResumeUpdated(
        bytes32 indexed resumeId,
        address indexed owner,
        bytes32 newContentHash,
        string newOffChainUri,
        uint256 timestamp
    );
    
    event ResumeRevoked(bytes32 indexed resumeId, address indexed owner, uint256 timestamp);
    
    event AccessGranted(
        bytes32 indexed grantId,
        address indexed owner,
        bytes32 indexed resumeId,
        bytes32 accessToken,
        uint256 expiresAt
    );
    
    event AccessRevoked(bytes32 indexed grantId, address indexed owner, uint256 timestamp);

    /**
     * @dev Create a new resume
     * @param resumeId Unique identifier for the resume
     * @param credentialIds Array of credential IDs to include
     * @param contentHash Hash of resume content stored off-chain
     * @param offChainUri URI where resume content is stored (IPFS, etc.)
     */
    function createResume(
        bytes32 resumeId,
        bytes32[] calldata credentialIds,
        bytes32 contentHash,
        string calldata offChainUri
    ) external nonReentrant {
        require(resumeId != bytes32(0), "Invalid resume ID");
        require(contentHash != bytes32(0), "Invalid content hash");
        require(resumes[resumeId].resumeId == bytes32(0), "Resume ID already exists");

        resumes[resumeId] = Resume({
            resumeId: resumeId,
            owner: msg.sender,
            credentialIds: credentialIds,
            contentHash: contentHash,
            offChainUri: offChainUri,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            isActive: true
        });

        userResumes[msg.sender].push(resumeId);
        emit ResumeCreated(resumeId, msg.sender, contentHash, offChainUri, block.timestamp);
    }

    /**
     * @dev Update an existing resume
     * @param resumeId ID of the resume to update
     * @param credentialIds Updated array of credential IDs
     * @param newContentHash New hash of updated resume content
     * @param newOffChainUri New URI for updated resume content
     */
    function updateResume(
        bytes32 resumeId,
        bytes32[] calldata credentialIds,
        bytes32 newContentHash,
        string calldata newOffChainUri
    ) external {
        Resume storage resume = resumes[resumeId];
        require(resume.owner == msg.sender, "Not the resume owner");
        require(resume.isActive, "Resume is not active");
        require(newContentHash != bytes32(0), "Invalid content hash");

        resume.credentialIds = credentialIds;
        resume.contentHash = newContentHash;
        resume.offChainUri = newOffChainUri;
        resume.updatedAt = block.timestamp;

        emit ResumeUpdated(resumeId, msg.sender, newContentHash, newOffChainUri, block.timestamp);
    }

    /**
     * @dev Revoke/deactivate a resume
     * @param resumeId ID of the resume to revoke
     */
    function revokeResume(bytes32 resumeId) external {
        Resume storage resume = resumes[resumeId];
        require(resume.owner == msg.sender, "Not the resume owner");
        require(resume.isActive, "Resume already revoked");

        resume.isActive = false;
        emit ResumeRevoked(resumeId, msg.sender, block.timestamp);
    }

    /**
     * @dev Grant access to a resume via access token
     * @param grantId Unique identifier for the access grant
     * @param resumeId ID of the resume to grant access to
     * @param accessToken Hash of the access token (generated off-chain)
     * @param expiresAt Expiration timestamp (0 for no expiration)
     */
    function grantAccess(
        bytes32 grantId,
        bytes32 resumeId,
        bytes32 accessToken,
        uint256 expiresAt
    ) external nonReentrant {
        Resume memory resume = resumes[resumeId];
        require(resume.owner == msg.sender, "Not the resume owner");
        require(resume.isActive, "Resume is not active");
        require(accessGrants[grantId].grantId == bytes32(0), "Grant ID already exists");
        require(expiresAt == 0 || expiresAt > block.timestamp, "Invalid expiration date");

        accessGrants[grantId] = AccessGrant({
            grantId: grantId,
            owner: msg.sender,
            employer: address(0), // Token-based access
            resumeId: resumeId,
            accessToken: accessToken,
            createdAt: block.timestamp,
            expiresAt: expiresAt,
            revoked: false
        });

        validAccessTokens[accessToken] = true;
        emit AccessGranted(grantId, msg.sender, resumeId, accessToken, expiresAt);
    }

    /**
     * @dev Revoke an access grant
     * @param grantId ID of the access grant to revoke
     */
    function revokeAccess(bytes32 grantId) external {
        AccessGrant storage grant = accessGrants[grantId];
        require(grant.owner == msg.sender, "Not the grant owner");
        require(!grant.revoked, "Grant already revoked");

        grant.revoked = true;
        validAccessTokens[grant.accessToken] = false;
        emit AccessRevoked(grantId, msg.sender, block.timestamp);
    }

    /**
     * @dev Check if an access token is valid
     * @param accessToken Hash of the access token to check
     * @return bool True if valid and not expired/revoked
     */
    function isValidAccessToken(bytes32 accessToken) external view returns (bool) {
        // This is a simplified check - in practice, you'd need to find the grant
        // For now, we maintain a mapping of valid tokens
        return validAccessTokens[accessToken];
    }

    /**
     * @dev Get resume information
     * @param resumeId ID of the resume
     * @return Resume struct
     */
    function getResume(bytes32 resumeId) external view returns (Resume memory) {
        return resumes[resumeId];
    }

    /**
     * @dev Get all resume IDs for a user
     * @param userAddress Address of the user
     * @return Array of resume IDs
     */
    function getUserResumes(address userAddress) external view returns (bytes32[] memory) {
        return userResumes[userAddress];
    }
}

