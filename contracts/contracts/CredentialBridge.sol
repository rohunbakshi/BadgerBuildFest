// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title CredentialBridge
 * @dev Bridges Solana credentials to Ethereum for verification
 */
contract CredentialBridge is Ownable, ReentrancyGuard {
    struct BridgedCredential {
        string solanaTxHash;        // Solana transaction hash (proof)
        address ethereumIdentity;  // Ethereum wallet
        bytes32 credentialHash;    // Hash of credential data
        bytes32 credentialType;    // "course", "test", "certification", "skill"
        uint256 bridgedAt;
        bool verified;
        address bridgeOperator;    // Who bridged it
    }
    
    mapping(bytes32 => BridgedCredential) public bridgedCredentials;
    mapping(address => bytes32[]) public userBridgedCredentials;
    mapping(string => bytes32) public solanaTxToCredential; // Solana TX → Credential ID
    mapping(address => bool) public authorizedOperators; // Authorized bridge operators
    
    address public bridgeAuthority;
    
    event CredentialBridged(
        bytes32 indexed credentialId,
        string solanaTxHash,
        address indexed ethereumIdentity,
        bytes32 credentialType,
        address indexed bridgeOperator
    );
    
    event CredentialVerified(
        bytes32 indexed credentialId,
        bool verified
    );
    
    constructor() Ownable(msg.sender) {
        bridgeAuthority = msg.sender;
        authorizedOperators[msg.sender] = true;
    }
    
    /**
     * @dev Authorize a bridge operator
     */
    function authorizeOperator(address operator) external onlyOwner {
        authorizedOperators[operator] = true;
    }
    
    /**
     * @dev Revoke bridge operator authorization
     */
    function revokeOperator(address operator) external onlyOwner {
        authorizedOperators[operator] = false;
    }
    
    /**
     * @dev Bridge a Solana credential to Ethereum
     * @param credentialId Unique identifier for the credential
     * @param solanaTxHash Solana transaction hash (proof)
     * @param credentialHash Hash of credential data
     * @param credentialType Type of credential
     * @param proof Cryptographic proof from Solana (simplified - use oracle in production)
     */
    function bridgeCredential(
        bytes32 credentialId,
        string calldata solanaTxHash,
        bytes32 credentialHash,
        bytes32 credentialType,
        bytes calldata proof
    ) external nonReentrant {
        require(
            authorizedOperators[msg.sender] || msg.sender == bridgeAuthority,
            "Unauthorized bridge operator"
        );
        require(bridgedCredentials[credentialId].ethereumIdentity == address(0), "Credential already bridged");
        require(bytes(solanaTxHash).length > 0, "Invalid Solana transaction hash");
        require(credentialHash != bytes32(0), "Invalid credential hash");
        
        // Verify proof (in production, use oracle or merkle proof)
        require(verifySolanaProof(solanaTxHash, proof), "Invalid Solana proof");
        
        // Create bridged credential
        bridgedCredentials[credentialId] = BridgedCredential({
            solanaTxHash: solanaTxHash,
            ethereumIdentity: msg.sender, // In production, get from proof or parameter
            credentialHash: credentialHash,
            credentialType: credentialType,
            bridgedAt: block.timestamp,
            verified: true,
            bridgeOperator: msg.sender
        });
        
        userBridgedCredentials[msg.sender].push(credentialId);
        solanaTxToCredential[solanaTxHash] = credentialId;
        
        emit CredentialBridged(credentialId, solanaTxHash, msg.sender, credentialType, msg.sender);
    }
    
    /**
     * @dev Bridge credential with specific Ethereum identity
     */
    function bridgeCredentialFor(
        bytes32 credentialId,
        string calldata solanaTxHash,
        bytes32 credentialHash,
        bytes32 credentialType,
        address ethereumIdentity,
        bytes calldata proof
    ) external nonReentrant {
        require(
            authorizedOperators[msg.sender] || msg.sender == bridgeAuthority,
            "Unauthorized bridge operator"
        );
        require(bridgedCredentials[credentialId].ethereumIdentity == address(0), "Credential already bridged");
        require(ethereumIdentity != address(0), "Invalid Ethereum identity");
        require(bytes(solanaTxHash).length > 0, "Invalid Solana transaction hash");
        require(verifySolanaProof(solanaTxHash, proof), "Invalid Solana proof");
        
        bridgedCredentials[credentialId] = BridgedCredential({
            solanaTxHash: solanaTxHash,
            ethereumIdentity: ethereumIdentity,
            credentialHash: credentialHash,
            credentialType: credentialType,
            bridgedAt: block.timestamp,
            verified: true,
            bridgeOperator: msg.sender
        });
        
        userBridgedCredentials[ethereumIdentity].push(credentialId);
        solanaTxToCredential[solanaTxHash] = credentialId;
        
        emit CredentialBridged(credentialId, solanaTxHash, ethereumIdentity, credentialType, msg.sender);
    }
    
    /**
     * @dev Verify Solana proof (simplified - in production use oracle)
     */
    function verifySolanaProof(string memory txHash, bytes memory proof) 
        internal 
        pure 
        returns (bool) 
    {
        // In production: Verify against Solana RPC or use oracle
        // For now: Basic validation
        return bytes(txHash).length > 0 && proof.length > 0;
    }
    
    /**
     * @dev Check if bridged credential is valid
     */
    function isBridgedCredentialValid(bytes32 credentialId) 
        external 
        view 
        returns (bool) 
    {
        BridgedCredential memory cred = bridgedCredentials[credentialId];
        return cred.verified && cred.ethereumIdentity != address(0);
    }
    
    /**
     * @dev Get bridged credential information
     */
    function getBridgedCredential(bytes32 credentialId) 
        external 
        view 
        returns (BridgedCredential memory) 
    {
        return bridgedCredentials[credentialId];
    }
    
    /**
     * @dev Get all bridged credentials for a user
     */
    function getUserBridgedCredentials(address user) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        return userBridgedCredentials[user];
    }
    
    /**
     * @dev Get credential ID from Solana transaction hash
     */
    function getCredentialFromSolanaTx(string calldata solanaTxHash) 
        external 
        view 
        returns (bytes32) 
    {
        return solanaTxToCredential[solanaTxHash];
    }
    
    /**
     * @dev Revoke a bridged credential (if fraud detected)
     */
    function revokeBridgedCredential(bytes32 credentialId) 
        external 
        onlyOwner 
    {
        require(
            bridgedCredentials[credentialId].ethereumIdentity != address(0),
            "Credential not found"
        );
        bridgedCredentials[credentialId].verified = false;
        emit CredentialVerified(credentialId, false);
    }
}

