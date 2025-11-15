// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ResumeVerification.sol";

/**
 * @title ResumeStaking
 * @dev Allows users to stake their resumes for rewards (Turtle.xyz integration)
 */
contract ResumeStaking is Ownable, ReentrancyGuard {
    struct StakedResume {
        bytes32 resumeId;
        address owner;
        uint256 stakedAt;
        uint256 stakedAmount; // Amount staked (in tokens or native currency)
        uint256 rewardAccumulated;
        bool isActive;
        uint256 unstakeTime; // When they can unstake (if locked)
    }
    
    ResumeVerification public resumeVerification;
    IERC20 public stakingToken; // Token used for staking (optional, can use native ETH)
    
    mapping(bytes32 => StakedResume) public stakedResumes;
    mapping(address => bytes32[]) public userStakedResumes;
    mapping(bytes32 => bool) public isResumeStaked;
    
    // Staking parameters
    uint256 public minStakeAmount;
    uint256 public stakingLockPeriod; // Time before can unstake (in seconds)
    uint256 public rewardRate; // Rewards per second per staked amount
    uint256 public platformFee; // Platform fee percentage (basis points, e.g., 1000 = 10%)
    
    // Premium access
    mapping(address => bool) public premiumEmployers; // Employers who paid for premium access
    uint256 public premiumAccessFee; // Fee for employers to access staked resumes
    
    event ResumeStaked(
        bytes32 indexed resumeId,
        address indexed owner,
        uint256 stakedAmount,
        uint256 stakedAt
    );
    
    event ResumeUnstaked(
        bytes32 indexed resumeId,
        address indexed owner,
        uint256 rewardAmount
    );
    
    event RewardsClaimed(
        bytes32 indexed resumeId,
        address indexed owner,
        uint256 rewardAmount
    );
    
    event PremiumAccessGranted(
        address indexed employer,
        uint256 feePaid
    );
    
    constructor(
        address _resumeVerification,
        address _stakingToken, // Can be address(0) for native ETH
        uint256 _minStakeAmount,
        uint256 _stakingLockPeriod,
        uint256 _rewardRate,
        uint256 _platformFee
    ) Ownable(msg.sender) {
        resumeVerification = ResumeVerification(_resumeVerification);
        stakingToken = IERC20(_stakingToken);
        minStakeAmount = _minStakeAmount;
        stakingLockPeriod = _stakingLockPeriod;
        rewardRate = _rewardRate;
        platformFee = _platformFee;
    }
    
    /**
     * @dev Stake a resume (requires resume to be verified)
     */
    function stakeResume(bytes32 resumeId) external payable nonReentrant {
        require(
            resumeVerification.isResumeVerified(resumeId),
            "Resume must be verified before staking"
        );
        require(!isResumeStaked[resumeId], "Resume already staked");
        
        uint256 stakeAmount = msg.value;
        if (address(stakingToken) != address(0)) {
            // ERC20 token staking
            require(
                stakingToken.transferFrom(msg.sender, address(this), stakeAmount),
                "Token transfer failed"
            );
        } else {
            // Native ETH staking
            require(stakeAmount >= minStakeAmount, "Stake amount below minimum");
        }
        
        stakedResumes[resumeId] = StakedResume({
            resumeId: resumeId,
            owner: msg.sender,
            stakedAt: block.timestamp,
            stakedAmount: stakeAmount,
            rewardAccumulated: 0,
            isActive: true,
            unstakeTime: block.timestamp + stakingLockPeriod
        });
        
        userStakedResumes[msg.sender].push(resumeId);
        isResumeStaked[resumeId] = true;
        
        emit ResumeStaked(resumeId, msg.sender, stakeAmount, block.timestamp);
    }
    
    /**
     * @dev Unstake a resume and claim rewards
     */
    function unstakeResume(bytes32 resumeId) external nonReentrant {
        StakedResume storage staked = stakedResumes[resumeId];
        require(staked.owner == msg.sender, "Not resume owner");
        require(staked.isActive, "Resume not staked");
        require(
            block.timestamp >= staked.unstakeTime,
            "Staking lock period not expired"
        );
        
        // Calculate rewards
        uint256 stakingDuration = block.timestamp - staked.stakedAt;
        uint256 totalReward = (staked.stakedAmount * rewardRate * stakingDuration) / 1e18;
        
        // Calculate platform fee
        uint256 platformReward = (totalReward * platformFee) / 10000;
        uint256 userReward = totalReward - platformReward;
        
        staked.rewardAccumulated += userReward;
        staked.isActive = false;
        
        // Transfer staked amount + rewards back to user
        uint256 totalToReturn = staked.stakedAmount + userReward;
        
        if (address(stakingToken) != address(0)) {
            require(
                stakingToken.transfer(msg.sender, totalToReturn),
                "Token transfer failed"
            );
        } else {
            (bool success, ) = payable(msg.sender).call{value: totalToReturn}("");
            require(success, "ETH transfer failed");
        }
        
        // Transfer platform fee to owner
        if (platformReward > 0) {
            if (address(stakingToken) != address(0)) {
                stakingToken.transfer(owner(), platformReward);
            } else {
                (bool success, ) = payable(owner()).call{value: platformReward}("");
                require(success, "ETH transfer failed");
            }
        }
        
        emit ResumeUnstaked(resumeId, msg.sender, userReward);
    }
    
    /**
     * @dev Claim accumulated rewards without unstaking
     */
    function claimRewards(bytes32 resumeId) external nonReentrant {
        StakedResume storage staked = stakedResumes[resumeId];
        require(staked.owner == msg.sender, "Not resume owner");
        require(staked.isActive, "Resume not staked");
        
        // Calculate new rewards since last claim
        uint256 stakingDuration = block.timestamp - staked.stakedAt;
        uint256 totalReward = (staked.stakedAmount * rewardRate * stakingDuration) / 1e18;
        uint256 newReward = totalReward - staked.rewardAccumulated;
        
        require(newReward > 0, "No rewards to claim");
        
        // Calculate platform fee
        uint256 platformReward = (newReward * platformFee) / 10000;
        uint256 userReward = newReward - platformReward;
        
        staked.rewardAccumulated = totalReward;
        
        // Transfer rewards to user
        if (address(stakingToken) != address(0)) {
            require(
                stakingToken.transfer(msg.sender, userReward),
                "Token transfer failed"
            );
        } else {
            (bool success, ) = payable(msg.sender).call{value: userReward}("");
            require(success, "ETH transfer failed");
        }
        
        // Transfer platform fee
        if (platformReward > 0) {
            if (address(stakingToken) != address(0)) {
                stakingToken.transfer(owner(), platformReward);
            } else {
                (bool success, ) = payable(owner()).call{value: platformReward}("");
                require(success, "ETH transfer failed");
            }
        }
        
        emit RewardsClaimed(resumeId, msg.sender, userReward);
    }
    
    /**
     * @dev Get current rewards for a staked resume
     */
    function getCurrentRewards(bytes32 resumeId) 
        external 
        view 
        returns (uint256) 
    {
        StakedResume memory staked = stakedResumes[resumeId];
        if (!staked.isActive) {
            return 0;
        }
        
        uint256 stakingDuration = block.timestamp - staked.stakedAt;
        uint256 totalReward = (staked.stakedAmount * rewardRate * stakingDuration) / 1e18;
        return totalReward - staked.rewardAccumulated;
    }
    
    /**
     * @dev Grant premium access to employer (pay fee to access staked resumes)
     */
    function grantPremiumAccess() external payable {
        require(msg.value >= premiumAccessFee, "Insufficient fee");
        premiumEmployers[msg.sender] = true;
        
        // Transfer fee to owner
        (bool success, ) = payable(owner()).call{value: msg.value}("");
        require(success, "ETH transfer failed");
        
        emit PremiumAccessGranted(msg.sender, msg.value);
    }
    
    /**
     * @dev Check if resume is staked
     */
    function isResumeStakedCheck(bytes32 resumeId) 
        external 
        view 
        returns (bool) 
    {
        return isResumeStaked[resumeId] && stakedResumes[resumeId].isActive;
    }
    
    /**
     * @dev Get all staked resumes for a user
     */
    function getUserStakedResumes(address user) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        return userStakedResumes[user];
    }
    
    /**
     * @dev Update staking parameters (owner only)
     */
    function updateStakingParameters(
        uint256 _minStakeAmount,
        uint256 _stakingLockPeriod,
        uint256 _rewardRate,
        uint256 _platformFee
    ) external onlyOwner {
        minStakeAmount = _minStakeAmount;
        stakingLockPeriod = _stakingLockPeriod;
        rewardRate = _rewardRate;
        platformFee = _platformFee;
    }
    
    /**
     * @dev Set premium access fee
     */
    function setPremiumAccessFee(uint256 _fee) external onlyOwner {
        premiumAccessFee = _fee;
    }
    
    /**
     * @dev Withdraw contract balance (owner only, for emergency)
     */
    function withdrawBalance() external onlyOwner {
        if (address(stakingToken) != address(0)) {
            stakingToken.transfer(owner(), stakingToken.balanceOf(address(this)));
        } else {
            (bool success, ) = payable(owner()).call{value: address(this).balance}("");
            require(success, "ETH transfer failed");
        }
    }
}

