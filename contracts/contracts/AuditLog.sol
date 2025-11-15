// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AuditLog
 * @dev Immutable log of access and verification events
 */
contract AuditLog is Ownable {
    enum EventType {
        ResumeViewed,
        CredentialVerified,
        AccessGranted,
        AccessRevoked
    }

    struct AuditEvent {
        uint256 eventId;
        EventType eventType;
        address actor; // Who performed the action
        address subject; // Whose data was accessed
        bytes32 resourceId; // Resume ID, Credential ID, etc.
        bytes32 metadataHash; // Hash of additional metadata stored off-chain
        uint256 timestamp;
    }

    uint256 private eventCounter;
    AuditEvent[] public events;
    
    mapping(address => uint256[]) public userEvents; // User address => array of event IDs
    mapping(bytes32 => uint256[]) public resourceEvents; // Resource ID => array of event IDs
    
    event AuditEventLogged(
        uint256 indexed eventId,
        EventType eventType,
        address indexed actor,
        address indexed subject,
        bytes32 resourceId,
        uint256 timestamp
    );

    /**
     * @dev Log an audit event
     * @param eventType Type of event
     * @param subject Address of the user whose data was accessed
     * @param resourceId ID of the resource (resume, credential, etc.)
     * @param metadataHash Hash of additional metadata stored off-chain
     */
    function logEvent(
        EventType eventType,
        address subject,
        bytes32 resourceId,
        bytes32 metadataHash
    ) external {
        eventCounter++;
        
        AuditEvent memory auditEvent = AuditEvent({
            eventId: eventCounter,
            eventType: eventType,
            actor: msg.sender,
            subject: subject,
            resourceId: resourceId,
            metadataHash: metadataHash,
            timestamp: block.timestamp
        });

        events.push(auditEvent);
        userEvents[subject].push(eventCounter);
        resourceEvents[resourceId].push(eventCounter);

        emit AuditEventLogged(
            eventCounter,
            eventType,
            msg.sender,
            subject,
            resourceId,
            block.timestamp
        );
    }

    /**
     * @dev Get audit events for a user
     * @param userAddress Address of the user
     * @return Array of event IDs
     */
    function getUserEvents(address userAddress) external view returns (uint256[] memory) {
        return userEvents[userAddress];
    }

    /**
     * @dev Get audit events for a resource
     * @param resourceId ID of the resource
     * @return Array of event IDs
     */
    function getResourceEvents(bytes32 resourceId) external view returns (uint256[] memory) {
        return resourceEvents[resourceId];
    }

    /**
     * @dev Get an audit event by ID
     * @param eventId ID of the event
     * @return AuditEvent struct
     */
    function getEvent(uint256 eventId) external view returns (AuditEvent memory) {
        require(eventId > 0 && eventId <= eventCounter, "Invalid event ID");
        return events[eventId - 1];
    }

    /**
     * @dev Get total number of events
     * @return Total count
     */
    function getTotalEvents() external view returns (uint256) {
        return eventCounter;
    }
}

