// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./IssuerRegistry.sol";

/**
 * @title CredentialRegistry
 * @dev Manages issuance, storage, and verification of credentials
 */
contract CredentialRegistry is Ownable, ReentrancyGuard {
    enum CredentialType {
        Degree,
        Employment,
        Certification,
        Reference
    }

    struct Credential {
        bytes32 credentialId;
        address subject; // User who owns this credential
        address issuer; // Issuer organization
        CredentialType credentialType;
        bytes32 dataHash; // Hash of credential data stored off-chain
        uint256 issuedAt;
        uint256 expiresAt; // 0 means no expiration
        bool revoked;
    }

    IssuerRegistry public issuerRegistry;
    
    mapping(bytes32 => Credential) public credentials;
    mapping(address => bytes32[]) public userCredentials; // User address => array of credential IDs
    mapping(address => bytes32[]) public issuerCredentials; // Issuer address => array of credential IDs
    
    event CredentialIssued(
        bytes32 indexed credentialId,
        address indexed subject,
        address indexed issuer,
        CredentialType credentialType,
        bytes32 dataHash,
        uint256 issuedAt,
        uint256 expiresAt
    );
    
    event CredentialRevoked(bytes32 indexed credentialId, address indexed issuer, uint256 timestamp);

    constructor(address _issuerRegistry) {
        issuerRegistry = IssuerRegistry(_issuerRegistry);
    }

    /**
     * @dev Issue a new credential
     * @param credentialId Unique identifier for the credential
     * @param subject Address of the user receiving the credential
     * @param credentialType Type of credential
     * @param dataHash Hash of credential data stored off-chain
     * @param expiresAt Expiration timestamp (0 for no expiration)
     */
    function issueCredential(
        bytes32 credentialId,
        address subject,
        CredentialType credentialType,
        bytes32 dataHash,
        uint256 expiresAt
    ) external nonReentrant {
        require(issuerRegistry.isVerifiedIssuer(msg.sender), "Not a verified issuer");
        require(credentialId != bytes32(0), "Invalid credential ID");
        require(subject != address(0), "Invalid subject address");
        require(dataHash != bytes32(0), "Invalid data hash");
        require(credentials[credentialId].credentialId == bytes32(0), "Credential ID already exists");
        require(expiresAt == 0 || expiresAt > block.timestamp, "Invalid expiration date");

        credentials[credentialId] = Credential({
            credentialId: credentialId,
            subject: subject,
            issuer: msg.sender,
            credentialType: credentialType,
            dataHash: dataHash,
            issuedAt: block.timestamp,
            expiresAt: expiresAt,
            revoked: false
        });

        userCredentials[subject].push(credentialId);
        issuerCredentials[msg.sender].push(credentialId);

        emit CredentialIssued(
            credentialId,
            subject,
            msg.sender,
            credentialType,
            dataHash,
            block.timestamp,
            expiresAt
        );
    }

    /**
     * @dev Revoke a credential (issuer only)
     * @param credentialId ID of the credential to revoke
     */
    function revokeCredential(bytes32 credentialId) external {
        Credential storage credential = credentials[credentialId];
        require(credential.credentialId != bytes32(0), "Credential does not exist");
        require(credential.issuer == msg.sender, "Only issuer can revoke");
        require(!credential.revoked, "Credential already revoked");

        credential.revoked = true;
        emit CredentialRevoked(credentialId, msg.sender, block.timestamp);
    }

    /**
     * @dev Verify a credential
     * @param credentialId ID of the credential to verify
     * @return bool True if valid and not revoked
     * @return bool True if not expired
     * @return bool True if issuer is verified
     */
    function verifyCredential(bytes32 credentialId) external view returns (bool, bool, bool, bool) {
        Credential memory credential = credentials[credentialId];
        
        if (credential.credentialId == bytes32(0)) {
            return (false, false, false, false);
        }

        bool exists = true;
        bool notRevoked = !credential.revoked;
        bool notExpired = credential.expiresAt == 0 || credential.expiresAt > block.timestamp;
        bool issuerVerified = issuerRegistry.isVerifiedIssuer(credential.issuer);

        return (exists, notRevoked, notExpired, issuerVerified);
    }

    /**
     * @dev Get credential information
     * @param credentialId ID of the credential
     * @return Credential struct
     */
    function getCredential(bytes32 credentialId) external view returns (Credential memory) {
        return credentials[credentialId];
    }

    /**
     * @dev Get all credential IDs for a user
     * @param userAddress Address of the user
     * @return Array of credential IDs
     */
    function getUserCredentials(address userAddress) external view returns (bytes32[] memory) {
        return userCredentials[userAddress];
    }

    /**
     * @dev Batch verify multiple credentials
     * @param credentialIds Array of credential IDs to verify
     * @return results Array of verification results (exists, notRevoked, notExpired, issuerVerified)
     */
    function batchVerifyCredentials(bytes32[] calldata credentialIds) 
        external 
        view 
        returns (bool[4][] memory results) 
    {
        results = new bool[4][](credentialIds.length);
        
        for (uint256 i = 0; i < credentialIds.length; i++) {
            (bool exists, bool notRevoked, bool notExpired, bool issuerVerified) = 
                this.verifyCredential(credentialIds[i]);
            results[i] = [exists, notRevoked, notExpired, issuerVerified];
        }
    }
}

