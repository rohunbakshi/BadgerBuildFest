// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./CredentialRegistry.sol";
import "./VerificationScore.sol";

/**
 * @title VerificationMarketplace
 * @dev Employers pay to verify candidates - incentivizes verification
 * KEY DIFFERENTIATOR: Verification is valuable, not free like LinkedIn
 */
contract VerificationMarketplace is Ownable, ReentrancyGuard {
    struct VerificationRequest {
        bytes32 requestId;
        address employer;
        address candidate;
        bytes32[] credentialIds;
        uint256 paymentAmount;
        bool completed;
        uint256 requestedAt;
        uint256 completedAt;
    }
    
    struct VerificationOffer {
        bytes32 offerId;
        address employer;
        string[] requiredSkills;
        uint256 paymentAmount;
        uint256 maxCandidates;
        uint256 currentCandidates;
        bool active;
        uint256 createdAt;
    }
    
    CredentialRegistry public credentialRegistry;
    VerificationScore public verificationScore;
    
    mapping(bytes32 => VerificationRequest) public verificationRequests;
    mapping(bytes32 => VerificationOffer) public verificationOffers;
    mapping(address => bytes32[]) public candidateOffers; // candidate => offerIds
    
    uint256 public platformFee; // Platform fee percentage (basis points)
    uint256 public minVerificationPayment; // Minimum payment for verification
    
    event VerificationRequested(
        bytes32 indexed requestId,
        address indexed employer,
        address indexed candidate,
        uint256 paymentAmount
    );
    
    event VerificationCompleted(
        bytes32 indexed requestId,
        address indexed employer,
        address indexed candidate,
        bool verified
    );
    
    event VerificationOfferCreated(
        bytes32 indexed offerId,
        address indexed employer,
        uint256 paymentAmount,
        string[] requiredSkills
    );
    
    event CandidateMatched(
        bytes32 indexed offerId,
        address indexed candidate,
        uint256 paymentAmount
    );
    
    constructor(
        address _credentialRegistry,
        address _verificationScore,
        uint256 _platformFee,
        uint256 _minVerificationPayment
    ) Ownable(msg.sender) {
        credentialRegistry = CredentialRegistry(_credentialRegistry);
        verificationScore = VerificationScore(_verificationScore);
        platformFee = _platformFee;
        minVerificationPayment = _minVerificationPayment;
    }
    
    /**
     * @dev Employer requests to verify a candidate (pays for verification)
     */
    function requestVerification(
        bytes32 requestId,
        address candidate,
        bytes32[] calldata credentialIds
    ) external payable nonReentrant {
        require(msg.value >= minVerificationPayment, "Payment too low");
        require(
            verificationRequests[requestId].requestId == bytes32(0),
            "Request already exists"
        );
        
        verificationRequests[requestId] = VerificationRequest({
            requestId: requestId,
            employer: msg.sender,
            candidate: candidate,
            credentialIds: credentialIds,
            paymentAmount: msg.value,
            completed: false,
            requestedAt: block.timestamp,
            completedAt: 0
        });
        
        emit VerificationRequested(requestId, msg.sender, candidate, msg.value);
    }
    
    /**
     * @dev Complete verification (system verifies credentials)
     */
    function completeVerification(
        bytes32 requestId,
        bool verified
    ) external {
        VerificationRequest storage request = verificationRequests[requestId];
        require(!request.completed, "Already completed");
        require(
            msg.sender == owner() || msg.sender == request.employer,
            "Not authorized"
        );
        
        request.completed = true;
        request.completedAt = block.timestamp;
        
        if (verified) {
            // Calculate platform fee
            uint256 platformFeeAmount = (request.paymentAmount * platformFee) / 10000;
            uint256 candidatePayment = request.paymentAmount - platformFeeAmount;
            
            // Pay candidate
            (bool success, ) = payable(request.candidate).call{value: candidatePayment}("");
            require(success, "Payment failed");
            
            // Pay platform
            if (platformFeeAmount > 0) {
                (bool feeSuccess, ) = payable(owner()).call{value: platformFeeAmount}("");
                require(feeSuccess, "Fee transfer failed");
            }
        } else {
            // Return payment to employer
            (bool success, ) = payable(request.employer).call{value: request.paymentAmount}("");
            require(success, "Refund failed");
        }
        
        emit VerificationCompleted(requestId, request.employer, request.candidate, verified);
    }
    
    /**
     * @dev Employer creates verification offer (pays for verified candidates)
     */
    function createVerificationOffer(
        bytes32 offerId,
        string[] calldata requiredSkills,
        uint256 paymentAmount,
        uint256 maxCandidates
    ) external payable nonReentrant {
        require(msg.value >= paymentAmount * maxCandidates, "Insufficient payment");
        require(
            verificationOffers[offerId].offerId == bytes32(0),
            "Offer already exists"
        );
        
        verificationOffers[offerId] = VerificationOffer({
            offerId: offerId,
            employer: msg.sender,
            requiredSkills: requiredSkills,
            paymentAmount: paymentAmount,
            maxCandidates: maxCandidates,
            currentCandidates: 0,
            active: true,
            createdAt: block.timestamp
        });
        
        emit VerificationOfferCreated(offerId, msg.sender, paymentAmount, requiredSkills);
    }
    
    /**
     * @dev Candidate applies to verification offer (if they match requirements)
     */
    function applyToOffer(
        bytes32 offerId,
        bytes32[] calldata credentialIds
    ) external {
        VerificationOffer storage offer = verificationOffers[offerId];
        require(offer.active, "Offer not active");
        require(
            offer.currentCandidates < offer.maxCandidates,
            "Offer full"
        );
        
        // Verify candidate has required skills (simplified - check credentials)
        // In production, check actual skills from credentials
        
        offer.currentCandidates++;
        candidateOffers[msg.sender].push(offerId);
        
        // Pay candidate
        uint256 platformFeeAmount = (offer.paymentAmount * platformFee) / 10000;
        uint256 candidatePayment = offer.paymentAmount - platformFeeAmount;
        
        (bool success, ) = payable(msg.sender).call{value: candidatePayment}("");
        require(success, "Payment failed");
        
        if (platformFeeAmount > 0) {
            (bool feeSuccess, ) = payable(owner()).call{value: platformFeeAmount}("");
            require(feeSuccess, "Fee transfer failed");
        }
        
        emit CandidateMatched(offerId, msg.sender, candidatePayment);
    }
    
    /**
     * @dev Get verification offer details
     */
    function getOffer(bytes32 offerId) 
        external 
        view 
        returns (VerificationOffer memory) 
    {
        return verificationOffers[offerId];
    }
}

