import { ethers } from "ethers";
import { getContract } from "../config/blockchain";

/**
 * Stake a resume
 */
export async function stakeResume(resumeId: string) {
  const resumeStaking = await getContract("ResumeStaking");
  const minStake = await resumeStaking.minStakeAmount();
  
  const tx = await resumeStaking.stakeResume(ethers.id(resumeId), {
    value: minStake,
  });

  await tx.wait();
  
  return { success: true, resumeId };
}

/**
 * Unstake a resume
 */
export async function unstakeResume(resumeId: string) {
  const resumeStaking = await getContract("ResumeStaking");
  const tx = await resumeStaking.unstakeResume(ethers.id(resumeId));
  await tx.wait();
  
  return { success: true, resumeId };
}

/**
 * Claim staking rewards
 */
export async function claimRewards(resumeId: string) {
  const resumeStaking = await getContract("ResumeStaking");
  const tx = await resumeStaking.claimRewards(ethers.id(resumeId));
  await tx.wait();
  
  return { success: true, resumeId };
}

/**
 * Get staking information
 */
export async function getStakingInfo(resumeId: string) {
  const resumeStaking = await getContract("ResumeStaking");
  const staked = await resumeStaking.stakedResumes(ethers.id(resumeId));
  const rewards = await resumeStaking.getCurrentRewards(ethers.id(resumeId));
  
  return {
    isStaked: staked.isActive,
    stakedAmount: staked.stakedAmount.toString(),
    rewardAccumulated: staked.rewardAccumulated.toString(),
    currentRewards: rewards.toString(),
    stakedAt: staked.stakedAt.toString(),
  };
}

