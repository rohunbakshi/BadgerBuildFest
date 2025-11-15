// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title GovernmentIDVerification
 * @dev Manages government ID verification (KYC) for users
 */
contract GovernmentIDVerification is Ownable, ReentrancyGuard {
    enum VerificationStatus {
        Pending,
        Verified,
        Rejected,
        Expired
    }
    
    struct IDVerification {
        address user;
        bytes32 idHash; // Hash of ID document (privacy-preserving)
        bytes32 verificationHash; // Hash of verification data
        VerificationStatus status;
        address verifier; // Who verified (KYC provider)
        uint256 verifiedAt;
        uint256 expiresAt; // Optional expiration
        string idType; // "passport", "drivers_license", "national_id", etc.
        string country; // Country code
    }
    
    mapping(address => IDVerification) public verifications;
    mapping(address => bool) public isVerified;
    mapping(address => bool) public authorizedVerifiers; // KYC providers
    
    // Privacy: Only store hashes, not actual ID data
    mapping(bytes32 => address) public idHashToUser; // Prevent duplicate verifications
    
    event IDVerificationRequested(
        address indexed user,
        bytes32 idHash,
        string idType,
        string country
    );
    
    event IDVerificationCompleted(
        address indexed user,
        address indexed verifier,
        VerificationStatus status,
        uint256 verifiedAt
    );
    
    event IDVerificationExpired(
        address indexed user,
        uint256 expiredAt
    );
    
    constructor() Ownable(msg.sender) {
        // Owner is authorized verifier by default
        authorizedVerifiers[msg.sender] = true;
    }
    
    /**
     * @dev Request ID verification (user initiates)
     * @param idHash Hash of ID document (off-chain verification)
     * @param idType Type of ID (passport, drivers_license, etc.)
     * @param country Country code
     */
    function requestVerification(
        bytes32 idHash,
        string calldata idType,
        string calldata country
    ) external nonReentrant {
        require(
            verifications[msg.sender].status == VerificationStatus.Pending ||
            verifications[msg.sender].status == VerificationStatus.Rejected ||
            verifications[msg.sender].status == VerificationStatus.Expired ||
            verifications[msg.sender].user == address(0),
            "Verification already in progress or completed"
        );
        require(idHash != bytes32(0), "Invalid ID hash");
        require(bytes(idType).length > 0, "Invalid ID type");
        require(idHashToUser[idHash] == address(0) || idHashToUser[idHash] == msg.sender, "ID hash already used");
        
        verifications[msg.sender] = IDVerification({
            user: msg.sender,
            idHash: idHash,
            verificationHash: bytes32(0),
            status: VerificationStatus.Pending,
            verifier: address(0),
            verifiedAt: 0,
            expiresAt: 0,
            idType: idType,
            country: country
        });
        
        idHashToUser[idHash] = msg.sender;
        
        emit IDVerificationRequested(msg.sender, idHash, idType, country);
    }
    
    /**
     * @dev Complete ID verification (authorized verifier only)
     * @param user Address of user to verify
     * @param verificationHash Hash of verification data (from KYC provider)
     * @param expiresAt Expiration timestamp (0 = no expiration)
     */
    function completeVerification(
        address user,
        bytes32 verificationHash,
        uint256 expiresAt
    ) internal {
        require(authorizedVerifiers[msg.sender], "Not authorized verifier");
        require(
            verifications[user].status == VerificationStatus.Pending,
            "Verification not pending"
        );
        require(verificationHash != bytes32(0), "Invalid verification hash");
        require(
            expiresAt == 0 || expiresAt > block.timestamp,
            "Invalid expiration date"
        );
        
        verifications[user].verificationHash = verificationHash;
        verifications[user].status = VerificationStatus.Verified;
        verifications[user].verifier = msg.sender;
        verifications[user].verifiedAt = block.timestamp;
        verifications[user].expiresAt = expiresAt;
        
        isVerified[user] = true;
        
        emit IDVerificationCompleted(user, msg.sender, VerificationStatus.Verified, block.timestamp);
    }
    
    /**
     * @dev Complete ID verification (public wrapper for external calls)
     */
    function verifyUser(
        address user,
        bytes32 verificationHash,
        uint256 expiresAt
    ) external {
        completeVerification(user, verificationHash, expiresAt);
    }
    
    /**
     * @dev Reject ID verification (authorized verifier only)
     * @param user Address of user to reject
     */
    function rejectVerification(address user) external {
        require(authorizedVerifiers[msg.sender], "Not authorized verifier");
        require(
            verifications[user].status == VerificationStatus.Pending,
            "Verification not pending"
        );
        
        verifications[user].status = VerificationStatus.Rejected;
        verifications[user].verifier = msg.sender;
        verifications[user].verifiedAt = block.timestamp;
        
        isVerified[user] = false;
        
        emit IDVerificationCompleted(user, msg.sender, VerificationStatus.Rejected, block.timestamp);
    }
    
    /**
     * @dev Check if verification is expired
     * @param user Address of user to check
     */
    function checkExpiration(address user) external {
        IDVerification storage verification = verifications[user];
        if (
            verification.status == VerificationStatus.Verified &&
            verification.expiresAt > 0 &&
            verification.expiresAt <= block.timestamp
        ) {
            verification.status = VerificationStatus.Expired;
            isVerified[user] = false;
            
            emit IDVerificationExpired(user, block.timestamp);
        }
    }
    
    /**
     * @dev Get verification status for a user
     */
    function getVerification(address user) 
        external 
        view 
        returns (IDVerification memory) 
    {
        return verifications[user];
    }
    
    /**
     * @dev Check if user is verified (and not expired)
     */
    function isUserVerified(address user) 
        external 
        view 
        returns (bool) 
    {
        IDVerification memory verification = verifications[user];
        if (verification.status != VerificationStatus.Verified) {
            return false;
        }
        if (verification.expiresAt > 0 && verification.expiresAt <= block.timestamp) {
            return false;
        }
        return true;
    }
    
    /**
     * @dev Authorize a KYC provider (owner only)
     */
    function authorizeVerifier(address verifier) external onlyOwner {
        authorizedVerifiers[verifier] = true;
    }
    
    /**
     * @dev Revoke verifier authorization (owner only)
     */
    function revokeVerifier(address verifier) external onlyOwner {
        authorizedVerifiers[verifier] = false;
    }
    
    /**
     * @dev Batch verify multiple users (for efficiency)
     */
    function batchVerify(
        address[] calldata users,
        bytes32[] calldata verificationHashes,
        uint256[] calldata expiresAts
    ) external {
        require(authorizedVerifiers[msg.sender], "Not authorized verifier");
        require(
            users.length == verificationHashes.length &&
            users.length == expiresAts.length,
            "Array length mismatch"
        );
        
        for (uint256 i = 0; i < users.length; i++) {
            if (verifications[users[i]].status == VerificationStatus.Pending) {
                completeVerification(users[i], verificationHashes[i], expiresAts[i]);
            }
        }
    }
}

