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

  // Deploy CredentialBridge (for Solana credential bridging)
  console.log("\nDeploying CredentialBridge...");
  const CredentialBridge = await ethers.getContractFactory("CredentialBridge");
  const credentialBridge = await CredentialBridge.deploy();
  await credentialBridge.waitForDeployment();
  const credentialBridgeAddress = await credentialBridge.getAddress();
  console.log("CredentialBridge deployed to:", credentialBridgeAddress);

  // Deploy ExternalCertificationRegistry
  console.log("\nDeploying ExternalCertificationRegistry...");
  const ExternalCertificationRegistry = await ethers.getContractFactory("ExternalCertificationRegistry");
  const externalCertRegistry = await ExternalCertificationRegistry.deploy();
  await externalCertRegistry.waitForDeployment();
  const externalCertRegistryAddress = await externalCertRegistry.getAddress();
  console.log("ExternalCertificationRegistry deployed to:", externalCertRegistryAddress);

  // Deploy ResumeVerification (requires CredentialRegistry, CredentialBridge, ExternalCertificationRegistry)
  console.log("\nDeploying ResumeVerification...");
  const ResumeVerification = await ethers.getContractFactory("ResumeVerification");
  const resumeVerification = await ResumeVerification.deploy(
    credentialRegistryAddress,
    credentialBridgeAddress,
    externalCertRegistryAddress
  );
  await resumeVerification.waitForDeployment();
  const resumeVerificationAddress = await resumeVerification.getAddress();
  console.log("ResumeVerification deployed to:", resumeVerificationAddress);

  // Deploy GovernmentIDVerification
  console.log("\nDeploying GovernmentIDVerification...");
  const GovernmentIDVerification = await ethers.getContractFactory("GovernmentIDVerification");
  const governmentIDVerification = await GovernmentIDVerification.deploy();
  await governmentIDVerification.waitForDeployment();
  const governmentIDVerificationAddress = await governmentIDVerification.getAddress();
  console.log("GovernmentIDVerification deployed to:", governmentIDVerificationAddress);

  // Deploy ResumeStaking (requires ResumeVerification)
  console.log("\nDeploying ResumeStaking...");
  const ResumeStaking = await ethers.getContractFactory("ResumeStaking");
  const resumeStaking = await ResumeStaking.deploy(
    resumeVerificationAddress,
    ethers.ZeroAddress, // No ERC20 token, use native ETH
    ethers.parseEther("0.01"), // Min stake: 0.01 ETH
    30 * 24 * 60 * 60, // Lock period: 30 days
    ethers.parseEther("0.0001"), // Reward rate (per second)
    1000 // Platform fee: 10% (1000 basis points)
  );
  await resumeStaking.waitForDeployment();
  const resumeStakingAddress = await resumeStaking.getAddress();
  console.log("ResumeStaking deployed to:", resumeStakingAddress);

  // Deploy JobMatchingVault (requires ResumeVerification, CredentialRegistry)
  console.log("\nDeploying JobMatchingVault...");
  const JobMatchingVault = await ethers.getContractFactory("JobMatchingVault");
  const jobMatchingVault = await JobMatchingVault.deploy(
    resumeVerificationAddress,
    credentialRegistryAddress
  );
  await jobMatchingVault.waitForDeployment();
  const jobMatchingVaultAddress = await jobMatchingVault.getAddress();
  console.log("JobMatchingVault deployed to:", jobMatchingVaultAddress);

  // Deploy VerificationScore (requires CredentialRegistry, ResumeVerification)
  console.log("\nDeploying VerificationScore...");
  const VerificationScore = await ethers.getContractFactory("VerificationScore");
  const verificationScore = await VerificationScore.deploy(
    credentialRegistryAddress,
    resumeVerificationAddress
  );
  await verificationScore.waitForDeployment();
  const verificationScoreAddress = await verificationScore.getAddress();
  console.log("VerificationScore deployed to:", verificationScoreAddress);

  // Deploy VerificationChallenge (requires CredentialRegistry)
  console.log("\nDeploying VerificationChallenge...");
  const VerificationChallenge = await ethers.getContractFactory("VerificationChallenge");
  const verificationChallenge = await VerificationChallenge.deploy(
    credentialRegistryAddress,
    ethers.parseEther("0.001"), // Challenge stake required: 0.001 ETH
    ethers.parseEther("0.01") // Challenge resolution reward: 0.01 ETH
  );
  await verificationChallenge.waitForDeployment();
  const verificationChallengeAddress = await verificationChallenge.getAddress();
  console.log("VerificationChallenge deployed to:", verificationChallengeAddress);

  // Deploy VerificationMarketplace (requires CredentialRegistry, VerificationScore)
  console.log("\nDeploying VerificationMarketplace...");
  const VerificationMarketplace = await ethers.getContractFactory("VerificationMarketplace");
  const verificationMarketplace = await VerificationMarketplace.deploy(
    credentialRegistryAddress,
    verificationScoreAddress,
    1000, // Platform fee: 10% (1000 basis points)
    ethers.parseEther("0.01") // Min verification payment: 0.01 ETH
  );
  await verificationMarketplace.waitForDeployment();
  const verificationMarketplaceAddress = await verificationMarketplace.getAddress();
  console.log("VerificationMarketplace deployed to:", verificationMarketplaceAddress);

  // Deploy VerifiedProjectPortfolio (requires CredentialRegistry)
  console.log("\nDeploying VerifiedProjectPortfolio...");
  const VerifiedProjectPortfolio = await ethers.getContractFactory("VerifiedProjectPortfolio");
  const verifiedProjectPortfolio = await VerifiedProjectPortfolio.deploy(
    credentialRegistryAddress
  );
  await verifiedProjectPortfolio.waitForDeployment();
  const verifiedProjectPortfolioAddress = await verifiedProjectPortfolio.getAddress();
  console.log("VerifiedProjectPortfolio deployed to:", verifiedProjectPortfolioAddress);

  console.log("\n=== Deployment Summary ===");
  console.log("IssuerRegistry:", issuerRegistryAddress);
  console.log("IdentityRegistry:", identityRegistryAddress);
  console.log("CredentialRegistry:", credentialRegistryAddress);
  console.log("ResumeRegistry:", resumeRegistryAddress);
  console.log("AuditLog:", auditLogAddress);
  console.log("CredentialBridge:", credentialBridgeAddress);
  console.log("ExternalCertificationRegistry:", externalCertRegistryAddress);
  console.log("ResumeVerification:", resumeVerificationAddress);
  console.log("GovernmentIDVerification:", governmentIDVerificationAddress);
  console.log("ResumeStaking:", resumeStakingAddress);
  console.log("JobMatchingVault:", jobMatchingVaultAddress);
  console.log("VerificationScore:", verificationScoreAddress);
  console.log("VerificationChallenge:", verificationChallengeAddress);
  console.log("VerificationMarketplace:", verificationMarketplaceAddress);
  console.log("VerifiedProjectPortfolio:", verifiedProjectPortfolioAddress);

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
      CredentialBridge: credentialBridgeAddress,
      ExternalCertificationRegistry: externalCertRegistryAddress,
      ResumeVerification: resumeVerificationAddress,
      GovernmentIDVerification: governmentIDVerificationAddress,
      ResumeStaking: resumeStakingAddress,
      JobMatchingVault: jobMatchingVaultAddress,
      VerificationScore: verificationScoreAddress,
      VerificationChallenge: verificationChallengeAddress,
      VerificationMarketplace: verificationMarketplaceAddress,
      VerifiedProjectPortfolio: verifiedProjectPortfolioAddress,
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

