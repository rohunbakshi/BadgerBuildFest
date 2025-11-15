// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./CredentialRegistry.sol";
import "./ResumeVerification.sol";

/**
 * @title VerificationScore
 * @dev Public, on-chain reputation score based on verification - KEY DIFFERENTIATOR
 * This makes verification visible and valuable, not hidden like LinkedIn
 */
contract VerificationScore is Ownable, ReentrancyGuard {
    struct UserScore {
        address user;
        uint256 totalScore;
        uint256 credentialCount;
        uint256 verifiedCredentialCount;
        uint256 employmentCredentialCount;
        uint256 educationCredentialCount;
        uint256 certificationCredentialCount;
        uint256 skillCredentialCount;
        uint256 lastUpdated;
        uint256 verificationLevel; // 0-5 (Bronze, Silver, Gold, Platinum, Diamond)
    }
    
    CredentialRegistry public credentialRegistry;
    ResumeVerification public resumeVerification;
    
    mapping(address => UserScore) public userScores;
    mapping(address => bool) public hasScore;
    
    // Verification level thresholds
    uint256 public constant BRONZE_THRESHOLD = 1;      // 1-4 credentials
    uint256 public constant SILVER_THRESHOLD = 5;      // 5-9 credentials
    uint256 public constant GOLD_THRESHOLD = 10;       // 10-19 credentials
    uint256 public constant PLATINUM_THRESHOLD = 20;   // 20-49 credentials
    uint256 public constant DIAMOND_THRESHOLD = 50;    // 50+ credentials
    
    // Score multipliers (different credential types worth different amounts)
    uint256 public constant EMPLOYMENT_MULTIPLIER = 10;
    uint256 public constant EDUCATION_MULTIPLIER = 8;
    uint256 public constant CERTIFICATION_MULTIPLIER = 6;
    uint256 public constant SKILL_MULTIPLIER = 3;
    
    event ScoreUpdated(
        address indexed user,
        uint256 newScore,
        uint256 verificationLevel,
        uint256 credentialCount
    );
    
    event VerificationLevelUp(
        address indexed user,
        uint256 oldLevel,
        uint256 newLevel
    );
    
    constructor(
        address _credentialRegistry,
        address _resumeVerification
    ) Ownable(msg.sender) {
        credentialRegistry = CredentialRegistry(_credentialRegistry);
        resumeVerification = ResumeVerification(_resumeVerification);
    }
    
    /**
     * @dev Calculate and update user's verification score
     * This is called automatically when credentials are issued/verified
     */
    function updateScore(address user) external {
        require(
            msg.sender == address(credentialRegistry) ||
            msg.sender == address(resumeVerification) ||
            msg.sender == owner(),
            "Unauthorized"
        );
        
        _calculateScore(user);
    }
    
    /**
     * @dev Calculate verification score for a user
     */
    function _calculateScore(address user) internal {
        bytes32[] memory credentials = credentialRegistry.getUserCredentials(user);
        
        uint256 totalScore = 0;
        uint256 verifiedCount = 0;
        uint256 employmentCount = 0;
        uint256 educationCount = 0;
        uint256 certificationCount = 0;
        uint256 skillCount = 0;
        
        for (uint256 i = 0; i < credentials.length; i++) {
            (bool exists, bool notRevoked, bool notExpired, bool issuerVerified) = 
                credentialRegistry.verifyCredential(credentials[i]);
            
            if (exists && notRevoked && notExpired && issuerVerified) {
                verifiedCount++;
                
                CredentialRegistry.Credential memory cred = 
                    credentialRegistry.getCredential(credentials[i]);
                
                // Calculate score based on credential type
                if (cred.credentialType == CredentialRegistry.CredentialType.Employment) {
                    totalScore += EMPLOYMENT_MULTIPLIER;
                    employmentCount++;
                } else if (cred.credentialType == CredentialRegistry.CredentialType.Degree) {
                    totalScore += EDUCATION_MULTIPLIER;
                    educationCount++;
                } else if (cred.credentialType == CredentialRegistry.CredentialType.Certification) {
                    totalScore += CERTIFICATION_MULTIPLIER;
                    certificationCount++;
                } else if (cred.credentialType == CredentialRegistry.CredentialType.Skill) {
                    totalScore += SKILL_MULTIPLIER;
                    skillCount++;
                } else {
                    totalScore += 1; // Default score
                }
            }
        }
        
        // Check if user has verified resume (bonus points)
        bytes32[] memory resumes = resumeVerification.getUserResumes(user);
        for (uint256 i = 0; i < resumes.length; i++) {
            if (resumeVerification.isResumeVerified(resumes[i])) {
                totalScore += 50; // Bonus for verified resume
            }
        }
        
        // Calculate verification level
        uint256 oldLevel = hasScore[user] ? userScores[user].verificationLevel : 0;
        uint256 newLevel = _calculateLevel(verifiedCount);
        
        // Update score
        userScores[user] = UserScore({
            user: user,
            totalScore: totalScore,
            credentialCount: credentials.length,
            verifiedCredentialCount: verifiedCount,
            employmentCredentialCount: employmentCount,
            educationCredentialCount: educationCount,
            certificationCredentialCount: certificationCount,
            skillCredentialCount: skillCount,
            lastUpdated: block.timestamp,
            verificationLevel: newLevel
        });
        
        hasScore[user] = true;
        
        if (newLevel > oldLevel) {
            emit VerificationLevelUp(user, oldLevel, newLevel);
        }
        
        emit ScoreUpdated(user, totalScore, newLevel, verifiedCount);
    }
    
    /**
     * @dev Calculate verification level based on credential count
     */
    function _calculateLevel(uint256 credentialCount) internal pure returns (uint256) {
        if (credentialCount >= DIAMOND_THRESHOLD) return 5; // Diamond
        if (credentialCount >= PLATINUM_THRESHOLD) return 4; // Platinum
        if (credentialCount >= GOLD_THRESHOLD) return 3; // Gold
        if (credentialCount >= SILVER_THRESHOLD) return 2; // Silver
        if (credentialCount >= BRONZE_THRESHOLD) return 1; // Bronze
        return 0; // Unverified
    }
    
    /**
     * @dev Get user's verification score
     */
    function getScore(address user) external view returns (UserScore memory) {
        return userScores[user];
    }
    
    /**
     * @dev Get verification level name
     */
    function getLevelName(uint256 level) external pure returns (string memory) {
        if (level == 5) return "Diamond";
        if (level == 4) return "Platinum";
        if (level == 3) return "Gold";
        if (level == 2) return "Silver";
        if (level == 1) return "Bronze";
        return "Unverified";
    }
    
    /**
     * @dev Batch update scores (for efficiency)
     */
    function batchUpdateScores(address[] calldata users) external {
        for (uint256 i = 0; i < users.length; i++) {
            _calculateScore(users[i]);
        }
    }
}

