// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title IdentityRegistry
 * @dev Manages user identities on-chain, mapping wallet addresses to identity data
 */
contract IdentityRegistry is Ownable, ReentrancyGuard {
    struct Identity {
        address walletAddress;
        bytes32 profileHash; // Hash of off-chain profile metadata
        uint256 createdAt;
        uint256 updatedAt;
        bool isActive;
    }

    mapping(address => Identity) public identities;
    mapping(address => bool) public registeredAddresses;
    
    event IdentityRegistered(address indexed walletAddress, bytes32 profileHash, uint256 timestamp);
    event IdentityUpdated(address indexed walletAddress, bytes32 profileHash, uint256 timestamp);
    event IdentityDeactivated(address indexed walletAddress, uint256 timestamp);

    /**
     * @dev Register a new identity
     * @param profileHash Hash of the user's profile metadata stored off-chain
     */
    function registerIdentity(bytes32 profileHash) external nonReentrant {
        require(!registeredAddresses[msg.sender], "Identity already registered");
        require(profileHash != bytes32(0), "Invalid profile hash");

        identities[msg.sender] = Identity({
            walletAddress: msg.sender,
            profileHash: profileHash,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            isActive: true
        });

        registeredAddresses[msg.sender] = true;
        emit IdentityRegistered(msg.sender, profileHash, block.timestamp);
    }

    /**
     * @dev Update profile hash for existing identity
     * @param newProfileHash New hash of updated profile metadata
     */
    function updateProfileHash(bytes32 newProfileHash) external {
        require(registeredAddresses[msg.sender], "Identity not registered");
        require(newProfileHash != bytes32(0), "Invalid profile hash");
        require(identities[msg.sender].isActive, "Identity is deactivated");

        identities[msg.sender].profileHash = newProfileHash;
        identities[msg.sender].updatedAt = block.timestamp;

        emit IdentityUpdated(msg.sender, newProfileHash, block.timestamp);
    }

    /**
     * @dev Deactivate an identity (self-service)
     */
    function deactivateIdentity() external {
        require(registeredAddresses[msg.sender], "Identity not registered");
        require(identities[msg.sender].isActive, "Identity already deactivated");

        identities[msg.sender].isActive = false;
        emit IdentityDeactivated(msg.sender, block.timestamp);
    }

    /**
     * @dev Get identity information
     * @param walletAddress Address to query
     * @return Identity struct
     */
    function getIdentity(address walletAddress) external view returns (Identity memory) {
        return identities[walletAddress];
    }

    /**
     * @dev Check if an address has a registered identity
     * @param walletAddress Address to check
     * @return bool True if registered and active
     */
    function isRegistered(address walletAddress) external view returns (bool) {
        return registeredAddresses[walletAddress] && identities[walletAddress].isActive;
    }
}

