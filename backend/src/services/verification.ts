import { ethers } from "ethers";
import { getContract } from "../config/blockchain";

/**
 * Verify a resume against on-chain credentials
 */
export async function verifyResume(
  resumeId: string,
  resumeHash: string,
  claims: any[]
): Promise<{ fullyVerified: boolean; issues: string[] }> {
  const resumeVerification = await getContract("ResumeVerification");
  
  // Convert claims to contract format
  const contractClaims = claims.map((claim) => ({
    claimType: claim.claimType,
    credentialId: ethers.id(claim.credentialId),
    description: claim.description,
    verified: false,
    verificationSource: "",
  }));

  const tx = await resumeVerification.verifyResume(
    ethers.id(resumeId),
    ethers.id(resumeHash),
    contractClaims
  );

  await tx.wait();
  
  const result = await resumeVerification.getResumeVerification(ethers.id(resumeId));
  
  return {
    fullyVerified: result.isFullyVerified,
    issues: result.issues,
  };
}

/**
 * Get resume verification status
 */
export async function getResumeVerification(resumeId: string) {
  const resumeVerification = await getContract("ResumeVerification");
  const verification = await resumeVerification.getResumeVerification(ethers.id(resumeId));
  
  return {
    owner: verification.owner,
    isFullyVerified: verification.isFullyVerified,
    verifiedClaimCount: verification.verifiedClaimCount.toString(),
    totalClaimCount: verification.totalClaimCount.toString(),
    verifiedAt: verification.verifiedAt.toString(),
  };
}

