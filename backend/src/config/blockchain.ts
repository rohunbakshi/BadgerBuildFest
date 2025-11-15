import { ethers } from "ethers";
import dotenv from "dotenv";

dotenv.config();

const RPC_URL = process.env.ETHEREUM_RPC_URL || "http://localhost:8545";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";

// Contract addresses (set after deployment)
const CONTRACT_ADDRESSES: Record<string, string> = {
  IdentityRegistry: process.env.IDENTITY_REGISTRY_ADDRESS || "",
  CredentialRegistry: process.env.CREDENTIAL_REGISTRY_ADDRESS || "",
  ResumeVerification: process.env.RESUME_VERIFICATION_ADDRESS || "",
  JobMatchingVault: process.env.JOB_MATCHING_VAULT_ADDRESS || "",
  ResumeStaking: process.env.RESUME_STAKING_ADDRESS || "",
  VerificationScore: process.env.VERIFICATION_SCORE_ADDRESS || "",
  VerificationChallenge: process.env.VERIFICATION_CHALLENGE_ADDRESS || "",
  VerificationMarketplace: process.env.VERIFICATION_MARKETPLACE_ADDRESS || "",
  VerifiedProjectPortfolio: process.env.VERIFIED_PROJECT_PORTFOLIO_ADDRESS || "",
  CredentialBridge: process.env.CREDENTIAL_BRIDGE_ADDRESS || "",
  ExternalCertificationRegistry: process.env.EXTERNAL_CERTIFICATION_REGISTRY_ADDRESS || "",
  GovernmentIDVerification: process.env.GOVERNMENT_ID_VERIFICATION_ADDRESS || "",
};

// Provider and signer
let provider: ethers.Provider;
let signer: ethers.Wallet;

export function initializeBlockchain() {
  provider = new ethers.JsonRpcProvider(RPC_URL);
  
  if (PRIVATE_KEY) {
    signer = new ethers.Wallet(PRIVATE_KEY, provider);
  } else {
    console.warn("⚠️  No private key provided. Some operations may fail.");
  }
}

// Contract ABIs (simplified - in production, import from typechain)
const CONTRACT_ABIS: Record<string, any[]> = {
  IdentityRegistry: [],
  CredentialRegistry: [],
  ResumeVerification: [],
  JobMatchingVault: [],
  ResumeStaking: [],
  VerificationScore: [],
  VerificationChallenge: [],
  VerificationMarketplace: [],
  VerifiedProjectPortfolio: [],
  CredentialBridge: [],
  ExternalCertificationRegistry: [],
  GovernmentIDVerification: [],
};

/**
 * Get a contract instance
 */
export async function getContract(contractName: string): Promise<ethers.Contract> {
  if (!provider) {
    initializeBlockchain();
  }

  const address = CONTRACT_ADDRESSES[contractName];
  if (!address) {
    throw new Error(`Contract address not found for ${contractName}`);
  }

  // In production, use proper ABI from typechain
  // For now, return a basic contract instance
  return new ethers.Contract(address, CONTRACT_ABIS[contractName] || [], signer || provider);
}

/**
 * Get provider
 */
export function getProvider(): ethers.Provider {
  if (!provider) {
    initializeBlockchain();
  }
  return provider;
}

/**
 * Get signer
 */
export function getSigner(): ethers.Wallet | null {
  if (!signer) {
    initializeBlockchain();
  }
  return signer || null;
}

// Initialize on import
initializeBlockchain();
