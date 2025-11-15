import { ethers } from "ethers";

// Contract addresses (should be set via environment variables after deployment)
const RPC_URL = process.env.RPC_URL || "http://localhost:8545";
const IDENTITY_REGISTRY_ADDRESS = process.env.IDENTITY_REGISTRY_ADDRESS || "";
const CREDENTIAL_REGISTRY_ADDRESS = process.env.CREDENTIAL_REGISTRY_ADDRESS || "";
const RESUME_REGISTRY_ADDRESS = process.env.RESUME_REGISTRY_ADDRESS || "";
const ISSUER_REGISTRY_ADDRESS = process.env.ISSUER_REGISTRY_ADDRESS || "";

let provider: ethers.Provider | null = null;

export function getProvider(): ethers.Provider {
  if (!provider) {
    provider = new ethers.JsonRpcProvider(RPC_URL);
  }
  return provider;
}

export function getContractAddresses() {
  return {
    identityRegistry: IDENTITY_REGISTRY_ADDRESS,
    credentialRegistry: CREDENTIAL_REGISTRY_ADDRESS,
    resumeRegistry: RESUME_REGISTRY_ADDRESS,
    issuerRegistry: ISSUER_REGISTRY_ADDRESS,
  };
}

// Contract ABIs would be imported from compiled artifacts
// For now, we'll use placeholder types
export interface ContractConfig {
  address: string;
  abi: any[];
}

