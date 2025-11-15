// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./CredentialRegistry.sol";

/**
 * @title VerifiedProjectPortfolio
 * @dev Verified project portfolio - not just credentials, but verified work
 * KEY DIFFERENTIATOR: Verified projects, not just self-reported like LinkedIn
 */
contract VerifiedProjectPortfolio is Ownable, ReentrancyGuard {
    struct Project {
        bytes32 projectId;
        address owner;
        string title;
        string description;
        bytes32 projectHash; // Hash of project files/code (IPFS)
        string projectUri; // IPFS or GitHub link
        address[] verifiers; // Who verified this project
        bytes32[] relatedCredentials; // Related credentials
        uint256 createdAt;
        uint256 verifiedAt;
        bool isVerified;
        string[] technologies; // Technologies used
        string githubUrl; // Optional GitHub link
    }
    
    struct ProjectVerification {
        address verifier;
        bytes32 projectId;
        bool verified;
        string comment;
        uint256 verifiedAt;
    }
    
    CredentialRegistry public credentialRegistry;
    
    mapping(bytes32 => Project) public projects;
    mapping(address => bytes32[]) public userProjects;
    mapping(bytes32 => ProjectVerification[]) public projectVerifications;
    mapping(address => bool) public authorizedVerifiers; // Who can verify projects
    
    event ProjectCreated(
        bytes32 indexed projectId,
        address indexed owner,
        string title
    );
    
    event ProjectVerified(
        bytes32 indexed projectId,
        address indexed verifier,
        bool verified
    );
    
    constructor(address _credentialRegistry) Ownable(msg.sender) {
        credentialRegistry = CredentialRegistry(_credentialRegistry);
        authorizedVerifiers[msg.sender] = true;
    }
    
    /**
     * @dev Create a project portfolio entry
     */
    function createProject(
        bytes32 projectId,
        string calldata title,
        string calldata description,
        bytes32 projectHash,
        string calldata projectUri,
        bytes32[] calldata relatedCredentials,
        string[] calldata technologies,
        string calldata githubUrl
    ) external nonReentrant {
        require(
            projects[projectId].projectId == bytes32(0),
            "Project already exists"
        );
        require(bytes(title).length > 0, "Title required");
        
        projects[projectId] = Project({
            projectId: projectId,
            owner: msg.sender,
            title: title,
            description: description,
            projectHash: projectHash,
            projectUri: projectUri,
            verifiers: new address[](0),
            relatedCredentials: relatedCredentials,
            createdAt: block.timestamp,
            verifiedAt: 0,
            isVerified: false,
            technologies: technologies,
            githubUrl: githubUrl
        });
        
        userProjects[msg.sender].push(projectId);
        
        emit ProjectCreated(projectId, msg.sender, title);
    }
    
    /**
     * @dev Verify a project (authorized verifiers only)
     */
    function verifyProject(
        bytes32 projectId,
        bool verified,
        string calldata comment
    ) external {
        require(authorizedVerifiers[msg.sender], "Not authorized verifier");
        require(
            projects[projectId].projectId != bytes32(0),
            "Project does not exist"
        );
        
        Project storage project = projects[projectId];
        
        // Check if already verified by this verifier
        bool alreadyVerified = false;
        for (uint256 i = 0; i < project.verifiers.length; i++) {
            if (project.verifiers[i] == msg.sender) {
                alreadyVerified = true;
                break;
            }
        }
        
        if (!alreadyVerified && verified) {
            project.verifiers.push(msg.sender);
        }
        
        // Store verification
        projectVerifications[projectId].push(ProjectVerification({
            verifier: msg.sender,
            projectId: projectId,
            verified: verified,
            comment: comment,
            verifiedAt: block.timestamp
        }));
        
        // Mark as verified if at least one verifier approved
        if (verified && !project.isVerified) {
            project.isVerified = true;
            project.verifiedAt = block.timestamp;
        }
        
        emit ProjectVerified(projectId, msg.sender, verified);
    }
    
    /**
     * @dev Get project details
     */
    function getProject(bytes32 projectId) 
        external 
        view 
        returns (Project memory) 
    {
        return projects[projectId];
    }
    
    /**
     * @dev Get all projects for a user
     */
    function getUserProjects(address user) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        return userProjects[user];
    }
    
    /**
     * @dev Get project verifications
     */
    function getProjectVerifications(bytes32 projectId) 
        external 
        view 
        returns (ProjectVerification[] memory) 
    {
        return projectVerifications[projectId];
    }
    
    /**
     * @dev Authorize a verifier (owner only)
     */
    function authorizeVerifier(address verifier) external onlyOwner {
        authorizedVerifiers[verifier] = true;
    }
}

