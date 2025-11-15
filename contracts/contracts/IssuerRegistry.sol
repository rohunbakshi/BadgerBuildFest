// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title IssuerRegistry
 * @dev Manages verified issuer organizations (universities, companies, certifying bodies)
 */
contract IssuerRegistry is Ownable, ReentrancyGuard {
    enum IssuerStatus {
        Pending,
        Approved,
        Revoked
    }

    struct Issuer {
        address issuerAddress;
        bytes32 issuerHash; // Hash of issuer metadata (name, type, etc.)
        IssuerStatus status;
        uint256 registeredAt;
        uint256 approvedAt;
    }

    mapping(address => Issuer) public issuers;
    mapping(address => bool) public isIssuer;
    
    event IssuerRegistered(address indexed issuerAddress, bytes32 issuerHash, uint256 timestamp);
    event IssuerApproved(address indexed issuerAddress, uint256 timestamp);
    event IssuerRevoked(address indexed issuerAddress, uint256 timestamp);

    /**
     * @dev Register a new issuer (requires admin approval)
     * @param issuerHash Hash of issuer metadata stored off-chain
     */
    function registerIssuer(bytes32 issuerHash) external nonReentrant {
        require(!isIssuer[msg.sender], "Issuer already registered");
        require(issuerHash != bytes32(0), "Invalid issuer hash");

        issuers[msg.sender] = Issuer({
            issuerAddress: msg.sender,
            issuerHash: issuerHash,
            status: IssuerStatus.Pending,
            registeredAt: block.timestamp,
            approvedAt: 0
        });

        isIssuer[msg.sender] = true;
        emit IssuerRegistered(msg.sender, issuerHash, block.timestamp);
    }

    /**
     * @dev Approve an issuer (admin only)
     * @param issuerAddress Address of the issuer to approve
     */
    function approveIssuer(address issuerAddress) external onlyOwner {
        require(isIssuer[issuerAddress], "Issuer not registered");
        require(issuers[issuerAddress].status == IssuerStatus.Pending, "Issuer not pending");

        issuers[issuerAddress].status = IssuerStatus.Approved;
        issuers[issuerAddress].approvedAt = block.timestamp;

        emit IssuerApproved(issuerAddress, block.timestamp);
    }

    /**
     * @dev Revoke an issuer's status (admin only)
     * @param issuerAddress Address of the issuer to revoke
     */
    function revokeIssuer(address issuerAddress) external onlyOwner {
        require(isIssuer[issuerAddress], "Issuer not registered");
        require(issuers[issuerAddress].status == IssuerStatus.Approved, "Issuer not approved");

        issuers[issuerAddress].status = IssuerStatus.Revoked;
        emit IssuerRevoked(issuerAddress, block.timestamp);
    }

    /**
     * @dev Check if an issuer is verified (approved and not revoked)
     * @param issuerAddress Address to check
     * @return bool True if verified
     */
    function isVerifiedIssuer(address issuerAddress) external view returns (bool) {
        return isIssuer[issuerAddress] && issuers[issuerAddress].status == IssuerStatus.Approved;
    }

    /**
     * @dev Get issuer information
     * @param issuerAddress Address to query
     * @return Issuer struct
     */
    function getIssuer(address issuerAddress) external view returns (Issuer memory) {
        return issuers[issuerAddress];
    }
}

