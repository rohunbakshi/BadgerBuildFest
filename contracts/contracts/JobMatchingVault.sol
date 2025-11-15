// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./ResumeVerification.sol";
import "./CredentialRegistry.sol";

/**
 * @title JobMatchingVault
 * @dev Creates vaults of resumes matching specific skillsets for employers
 */
contract JobMatchingVault is Ownable, ReentrancyGuard {
    struct Skillset {
        string[] requiredSkills;
        uint256[] skillLevels; // 0 = any, 1 = beginner, 2 = intermediate, 3 = advanced, 4 = expert
        bool active;
        uint256 createdAt;
    }
    
    struct MatchingVault {
        bytes32 vaultId;
        address employer;
        Skillset skillset;
        bytes32[] matchingResumeIds;
        uint256 matchCount;
        bool isStakedOnly; // Only include staked resumes
        uint256 createdAt;
        uint256 updatedAt;
    }
    
    struct ResumeMatch {
        bytes32 resumeId;
        address owner;
        uint256 matchScore; // Higher = better match
        string[] matchedSkills;
        bool isStaked;
    }
    
    ResumeVerification public resumeVerification;
    CredentialRegistry public credentialRegistry;
    
    mapping(bytes32 => MatchingVault) public vaults;
    mapping(address => bytes32[]) public employerVaults;
    mapping(bytes32 => ResumeMatch[]) public vaultMatches; // vaultId => matches
    mapping(bytes32 => bool) public vaultExists;
    
    // Skillset matching
    mapping(string => bytes32[]) public skillToResumes; // skill name => resume IDs
    mapping(bytes32 => string[]) public resumeToSkills; // resume ID => skills
    
    event VaultCreated(
        bytes32 indexed vaultId,
        address indexed employer,
        string[] requiredSkills,
        bool stakedOnly
    );
    
    event ResumeMatched(
        bytes32 indexed vaultId,
        bytes32 indexed resumeId,
        uint256 matchScore
    );
    
    event VaultUpdated(
        bytes32 indexed vaultId,
        uint256 newMatchCount
    );
    
    constructor(
        address _resumeVerification,
        address _credentialRegistry
    ) Ownable(msg.sender) {
        resumeVerification = ResumeVerification(_resumeVerification);
        credentialRegistry = CredentialRegistry(_credentialRegistry);
    }
    
    /**
     * @dev Create a matching vault for a job posting
     * @param vaultId Unique identifier for the vault
     * @param requiredSkills Array of required skill names
     * @param skillLevels Array of required skill levels (0 = any level)
     * @param stakedOnly Only include staked resumes
     */
    function createVault(
        bytes32 vaultId,
        string[] memory requiredSkills,
        uint256[] memory skillLevels,
        bool stakedOnly
    ) external nonReentrant {
        require(!vaultExists[vaultId], "Vault already exists");
        require(requiredSkills.length > 0, "Must specify at least one skill");
        require(requiredSkills.length == skillLevels.length, "Skills and levels length mismatch");
        
        // Initialize vault
        vaults[vaultId].vaultId = vaultId;
        vaults[vaultId].employer = msg.sender;
        vaults[vaultId].matchingResumeIds = new bytes32[](0);
        vaults[vaultId].matchCount = 0;
        vaults[vaultId].isStakedOnly = stakedOnly;
        vaults[vaultId].createdAt = block.timestamp;
        vaults[vaultId].updatedAt = block.timestamp;
        
        // Create skillset struct (copy arrays to storage one by one)
        Skillset storage skillset = vaults[vaultId].skillset;
        // Initialize arrays
        string[] storage skillsArray = skillset.requiredSkills;
        uint256[] storage levelsArray = skillset.skillLevels;
        
        // Copy required skills
        for (uint256 i = 0; i < requiredSkills.length; i++) {
            skillsArray.push(requiredSkills[i]);
        }
        
        // Copy skill levels
        for (uint256 i = 0; i < skillLevels.length; i++) {
            levelsArray.push(skillLevels[i]);
        }
        
        skillset.active = true;
        skillset.createdAt = block.timestamp;
        
        employerVaults[msg.sender].push(vaultId);
        vaultExists[vaultId] = true;
        
        // Emit event (convert to calldata-compatible format)
        string[] memory skillsForEvent = new string[](requiredSkills.length);
        for (uint256 i = 0; i < requiredSkills.length; i++) {
            skillsForEvent[i] = requiredSkills[i];
        }
        emit VaultCreated(vaultId, msg.sender, skillsForEvent, stakedOnly);
        
        // Automatically match resumes
        _updateVaultMatches(vaultId);
    }
    
    /**
     * @dev Update vault matches (can be called periodically)
     */
    function updateVaultMatches(bytes32 vaultId) external {
        require(vaultExists[vaultId], "Vault does not exist");
        _updateVaultMatches(vaultId);
    }
    
    /**
     * @dev Internal function to match resumes to vault
     */
    function _updateVaultMatches(bytes32 vaultId) internal {
        MatchingVault storage vault = vaults[vaultId];
        Skillset memory skillset = vault.skillset;
        
        // Clear existing matches
        delete vaultMatches[vaultId];
        delete vault.matchingResumeIds;
        
        // Collect matching resumes (simplified approach)
        bytes32[] memory candidateResumes = new bytes32[](100); // Max 100 candidates
        uint256[] memory candidateScores = new uint256[](100);
        uint256 candidateCount = 0;
        
        for (uint256 i = 0; i < skillset.requiredSkills.length; i++) {
            string memory skill = skillset.requiredSkills[i];
            bytes32[] memory resumesWithSkill = skillToResumes[skill];
            
            for (uint256 j = 0; j < resumesWithSkill.length && candidateCount < 100; j++) {
                bytes32 resumeId = resumesWithSkill[j];
                
                // Check if resume is verified
                if (!resumeVerification.isResumeVerified(resumeId)) {
                    continue;
                }
                
                // Check if staked only
                if (vault.isStakedOnly) {
                    // TODO: Check if resume is staked (integrate with staking contract)
                    // For now, skip this check
                }
                
                // Check skill level (if specified)
                if (skillset.skillLevels[i] > 0) {
                    // TODO: Verify skill level from credential
                    // For now, accept any level
                }
                
                // Find or add resume to candidates
                bool found = false;
                for (uint256 k = 0; k < candidateCount; k++) {
                    if (candidateResumes[k] == resumeId) {
                        candidateScores[k]++;
                        found = true;
                        break;
                    }
                }
                
                if (!found) {
                    candidateResumes[candidateCount] = resumeId;
                    candidateScores[candidateCount] = 1;
                    candidateCount++;
                }
            }
        }
        
        // Build match list
        uint256 matchCount = 0;
        for (uint256 i = 0; i < candidateCount; i++) {
            if (candidateScores[i] > 0) {
                bytes32 resumeId = candidateResumes[i];
                
                // Check if already added
                bool alreadyAdded = false;
                for (uint256 k = 0; k < vault.matchingResumeIds.length; k++) {
                    if (vault.matchingResumeIds[k] == resumeId) {
                        alreadyAdded = true;
                        break;
                    }
                }
                
                if (!alreadyAdded) {
                    vault.matchingResumeIds.push(resumeId);
                    matchCount++;
                    
                    // Create match record
                    ResumeMatch memory matchRecord = ResumeMatch({
                        resumeId: resumeId,
                        owner: address(0), // TODO: Get from resume verification
                        matchScore: candidateScores[i],
                        matchedSkills: new string[](0), // TODO: Populate
                        isStaked: false // TODO: Check staking status
                    });
                    vaultMatches[vaultId].push(matchRecord);
                    
                    emit ResumeMatched(vaultId, resumeId, candidateScores[i]);
                }
            }
        }
        
        vault.matchCount = matchCount;
        vault.updatedAt = block.timestamp;
        
        emit VaultUpdated(vaultId, matchCount);
    }
    
    /**
     * @dev Register a resume's skills (called when resume is verified)
     */
    function registerResumeSkills(
        bytes32 resumeId,
        string[] calldata skills
    ) external {
        // Only resume verification contract can call this
        require(
            msg.sender == address(resumeVerification),
            "Only resume verification can register skills"
        );
        
        // Clear existing skills
        for (uint256 i = 0; i < resumeToSkills[resumeId].length; i++) {
            string memory oldSkill = resumeToSkills[resumeId][i];
            // Remove from skill mapping (simplified - in production use better data structure)
        }
        
        // Register new skills
        resumeToSkills[resumeId] = skills;
        for (uint256 i = 0; i < skills.length; i++) {
            skillToResumes[skills[i]].push(resumeId);
        }
    }
    
    /**
     * @dev Get matching resumes for a vault
     */
    function getVaultMatches(bytes32 vaultId) 
        external 
        view 
        returns (ResumeMatch[] memory) 
    {
        require(vaultExists[vaultId], "Vault does not exist");
        return vaultMatches[vaultId];
    }
    
    /**
     * @dev Get vault information
     */
    function getVault(bytes32 vaultId) 
        external 
        view 
        returns (MatchingVault memory) 
    {
        require(vaultExists[vaultId], "Vault does not exist");
        return vaults[vaultId];
    }
    
    /**
     * @dev Get all vaults for an employer
     */
    function getEmployerVaults(address employer) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        return employerVaults[employer];
    }
    
    /**
     * @dev Deactivate a vault
     */
    function deactivateVault(bytes32 vaultId) external {
        require(vaultExists[vaultId], "Vault does not exist");
        require(vaults[vaultId].employer == msg.sender, "Not vault owner");
        vaults[vaultId].skillset.active = false;
    }
}

