import { ethers } from "ethers";
import { getContract } from "../config/blockchain";

/**
 * Create a job matching vault
 */
export async function createVault(
  vaultId: string,
  requiredSkills: string[],
  skillLevels: number[],
  stakedOnly: boolean
) {
  const jobMatchingVault = await getContract("JobMatchingVault");
  
  const tx = await jobMatchingVault.createVault(
    ethers.id(vaultId),
    requiredSkills,
    skillLevels,
    stakedOnly
  );

  await tx.wait();
  
  return { success: true, vaultId };
}

/**
 * Get matching resumes for a vault
 */
export async function getVaultMatches(vaultId: string) {
  const jobMatchingVault = await getContract("JobMatchingVault");
  const matches = await jobMatchingVault.getVaultMatches(ethers.id(vaultId));
  
  return matches.map((match: any) => ({
    resumeId: match.resumeId,
    matchScore: match.matchScore.toString(),
    isStaked: match.isStaked,
  }));
}

/**
 * Update vault matches
 */
export async function updateVaultMatches(vaultId: string) {
  const jobMatchingVault = await getContract("JobMatchingVault");
  const tx = await jobMatchingVault.updateVaultMatches(ethers.id(vaultId));
  await tx.wait();
  return { success: true };
}

