// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./CredentialRegistry.sol";

/**
 * @title VerificationChallenge
 * @dev Allows anyone to challenge credentials - creates transparency and trust
 * KEY DIFFERENTIATOR: Public verification challenges, not hidden like LinkedIn
 */
contract VerificationChallenge is Ownable, ReentrancyGuard {
    enum ChallengeStatus {
        Pending,
        Resolved,
        Dismissed,
        Upheld
    }
    
    struct Challenge {
        bytes32 challengeId;
        bytes32 credentialId;
        address challenger;
        address credentialOwner;
        string reason;
        string evidence; // IPFS hash or URI
        ChallengeStatus status;
        uint256 createdAt;
        uint256 resolvedAt;
        address resolver; // Issuer or admin
        uint256 stakeAmount; // Challenger stakes tokens (optional)
    }
    
    CredentialRegistry public credentialRegistry;
    
    mapping(bytes32 => Challenge) public challenges;
    mapping(bytes32 => bytes32[]) public credentialChallenges; // credentialId => challengeIds
    mapping(address => bytes32[]) public userChallenges; // user => challengeIds
    
    uint256 public challengeStakeRequired; // Minimum stake to challenge
    uint256 public challengeResolutionReward; // Reward for successful challenge
    
    event ChallengeCreated(
        bytes32 indexed challengeId,
        bytes32 indexed credentialId,
        address indexed challenger,
        string reason
    );
    
    event ChallengeResolved(
        bytes32 indexed challengeId,
        ChallengeStatus status,
        address resolver
    );
    
    constructor(
        address _credentialRegistry,
        uint256 _challengeStakeRequired,
        uint256 _challengeResolutionReward
    ) Ownable(msg.sender) {
        credentialRegistry = CredentialRegistry(_credentialRegistry);
        challengeStakeRequired = _challengeStakeRequired;
        challengeResolutionReward = _challengeResolutionReward;
    }
    
    /**
     * @dev Challenge a credential (anyone can challenge)
     * @param challengeId Unique identifier for the challenge
     * @param credentialId Credential being challenged
     * @param reason Reason for challenge
     * @param evidence Evidence (IPFS hash or URI)
     */
    function createChallenge(
        bytes32 challengeId,
        bytes32 credentialId,
        string calldata reason,
        string calldata evidence
    ) external payable nonReentrant {
        require(
            challenges[challengeId].challengeId == bytes32(0),
            "Challenge already exists"
        );
        
        CredentialRegistry.Credential memory cred = 
            credentialRegistry.getCredential(credentialId);
        require(cred.credentialId != bytes32(0), "Credential does not exist");
        
        require(msg.value >= challengeStakeRequired, "Insufficient stake");
        
        challenges[challengeId] = Challenge({
            challengeId: challengeId,
            credentialId: credentialId,
            challenger: msg.sender,
            credentialOwner: cred.subject,
            reason: reason,
            evidence: evidence,
            status: ChallengeStatus.Pending,
            createdAt: block.timestamp,
            resolvedAt: 0,
            resolver: address(0),
            stakeAmount: msg.value
        });
        
        credentialChallenges[credentialId].push(challengeId);
        userChallenges[msg.sender].push(challengeId);
        
        emit ChallengeCreated(challengeId, credentialId, msg.sender, reason);
    }
    
    /**
     * @dev Resolve a challenge (issuer or admin)
     * @param challengeId Challenge to resolve
     * @param upheld True if challenge is valid (credential is fraudulent)
     */
    function resolveChallenge(
        bytes32 challengeId,
        bool upheld
    ) external {
        Challenge storage challenge = challenges[challengeId];
        require(
            challenge.status == ChallengeStatus.Pending,
            "Challenge not pending"
        );
        
        CredentialRegistry.Credential memory cred = 
            credentialRegistry.getCredential(challenge.credentialId);
        
        // Only issuer or admin can resolve
        require(
            cred.issuer == msg.sender || msg.sender == owner(),
            "Not authorized to resolve"
        );
        
        if (upheld) {
            challenge.status = ChallengeStatus.Upheld;
            // Revoke credential
            credentialRegistry.revokeCredential(challenge.credentialId);
            // Reward challenger
            if (challengeResolutionReward > 0) {
                (bool success, ) = payable(challenge.challenger).call{
                    value: challenge.stakeAmount + challengeResolutionReward
                }("");
                require(success, "Reward transfer failed");
            }
        } else {
            challenge.status = ChallengeStatus.Dismissed;
            // Return stake to challenger
            (bool success, ) = payable(challenge.challenger).call{
                value: challenge.stakeAmount
            }("");
            require(success, "Stake return failed");
        }
        
        challenge.resolvedAt = block.timestamp;
        challenge.resolver = msg.sender;
        
        emit ChallengeResolved(challengeId, challenge.status, msg.sender);
    }
    
    /**
     * @dev Get all challenges for a credential
     */
    function getCredentialChallenges(bytes32 credentialId) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        return credentialChallenges[credentialId];
    }
    
    /**
     * @dev Get challenge details
     */
    function getChallenge(bytes32 challengeId) 
        external 
        view 
        returns (Challenge memory) 
    {
        return challenges[challengeId];
    }
}

