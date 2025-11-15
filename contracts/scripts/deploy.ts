import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await ethers.provider.getBalance(deployer.address)).toString());

  // Deploy IssuerRegistry first (needed by CredentialRegistry)
  console.log("\nDeploying IssuerRegistry...");
  const IssuerRegistry = await ethers.getContractFactory("IssuerRegistry");
  const issuerRegistry = await IssuerRegistry.deploy();
  await issuerRegistry.waitForDeployment();
  const issuerRegistryAddress = await issuerRegistry.getAddress();
  console.log("IssuerRegistry deployed to:", issuerRegistryAddress);

  // Deploy IdentityRegistry
  console.log("\nDeploying IdentityRegistry...");
  const IdentityRegistry = await ethers.getContractFactory("IdentityRegistry");
  const identityRegistry = await IdentityRegistry.deploy();
  await identityRegistry.waitForDeployment();
  const identityRegistryAddress = await identityRegistry.getAddress();
  console.log("IdentityRegistry deployed to:", identityRegistryAddress);

  // Deploy CredentialRegistry (requires IssuerRegistry)
  console.log("\nDeploying CredentialRegistry...");
  const CredentialRegistry = await ethers.getContractFactory("CredentialRegistry");
  const credentialRegistry = await CredentialRegistry.deploy(issuerRegistryAddress);
  await credentialRegistry.waitForDeployment();
  const credentialRegistryAddress = await credentialRegistry.getAddress();
  console.log("CredentialRegistry deployed to:", credentialRegistryAddress);

  // Deploy ResumeRegistry
  console.log("\nDeploying ResumeRegistry...");
  const ResumeRegistry = await ethers.getContractFactory("ResumeRegistry");
  const resumeRegistry = await ResumeRegistry.deploy();
  await resumeRegistry.waitForDeployment();
  const resumeRegistryAddress = await resumeRegistry.getAddress();
  console.log("ResumeRegistry deployed to:", resumeRegistryAddress);

  // Deploy AuditLog
  console.log("\nDeploying AuditLog...");
  const AuditLog = await ethers.getContractFactory("AuditLog");
  const auditLog = await AuditLog.deploy();
  await auditLog.waitForDeployment();
  const auditLogAddress = await auditLog.getAddress();
  console.log("AuditLog deployed to:", auditLogAddress);

  console.log("\n=== Deployment Summary ===");
  console.log("IssuerRegistry:", issuerRegistryAddress);
  console.log("IdentityRegistry:", identityRegistryAddress);
  console.log("CredentialRegistry:", credentialRegistryAddress);
  console.log("ResumeRegistry:", resumeRegistryAddress);
  console.log("AuditLog:", auditLogAddress);

  // Save deployment addresses to a file (optional)
  const deploymentInfo = {
    network: "localhost",
    timestamp: new Date().toISOString(),
    contracts: {
      IssuerRegistry: issuerRegistryAddress,
      IdentityRegistry: identityRegistryAddress,
      CredentialRegistry: credentialRegistryAddress,
      ResumeRegistry: resumeRegistryAddress,
      AuditLog: auditLogAddress,
    },
  };

  console.log("\nDeployment info:", JSON.stringify(deploymentInfo, null, 2));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

