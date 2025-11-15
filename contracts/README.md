# Smart Contracts

This directory contains the Solidity smart contracts for the Decentralized Identity and Resume Management platform.

## Contracts Overview

- **IdentityRegistry.sol** - Manages user identities on-chain
- **IssuerRegistry.sol** - Manages verified issuer organizations
- **CredentialRegistry.sol** - Handles credential issuance and verification
- **ResumeRegistry.sol** - Manages resume creation and access control
- **AuditLog.sol** - Immutable log of access and verification events

## Setup

```bash
cd contracts
npm install
```

## Development

### Start Local Blockchain

```bash
npm run dev
# Starts Hardhat node on http://localhost:8545
```

### Compile Contracts

```bash
npm run compile
```

### Deploy Contracts

```bash
# Deploy to local network
npm run deploy:local

# Deploy to testnet (configure network in hardhat.config.ts first)
npm run deploy:testnet
```

### Run Tests

```bash
npm test
```

### Run Tests with Coverage

```bash
npm run coverage
```

## Contract Addresses

After deployment, contract addresses will be printed. Update these in:
- `backend/.env`
- `frontend/.env.local` (if needed)

## Network Configuration

Edit `hardhat.config.ts` to add networks:

```typescript
networks: {
  sepolia: {
    url: process.env.SEPOLIA_RPC_URL || "",
    accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
  },
}
```

## Interacting with Contracts

### Using Hardhat Console

```bash
npx hardhat console --network localhost

# In console:
const IdentityRegistry = await ethers.getContractFactory("IdentityRegistry");
const identity = await IdentityRegistry.attach("0x...");
const profileHash = ethers.keccak256(ethers.toUtf8Bytes("test"));
await identity.registerIdentity(profileHash);
```

### Using Scripts

Create scripts in `scripts/` directory:

```typescript
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  const contract = await ethers.getContractAt("IdentityRegistry", "0x...");
  // Interact with contract
}
```

## Gas Optimization

- Contracts use Solidity 0.8.20 with optimizer enabled (200 runs)
- Large data stored off-chain (IPFS), only hashes on-chain
- Batch operations available for multiple verifications

## Security

- Uses OpenZeppelin contracts for security
- ReentrancyGuard on critical functions
- Access control with Ownable pattern
- Input validation on all public functions

