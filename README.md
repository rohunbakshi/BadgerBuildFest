# Verified Resume & Job Matching Platform

> **Verification is Everything. Everything else is secondary.**

A blockchain-based platform that prevents resume fraud and improves job matching through **on-chain verification**. Unlike LinkedIn or traditional job sites, our platform makes verification **public, valuable, required, and challengeable**.

## 🎯 Core Philosophy

**Verification is Everything** - Our platform makes verification:
- ✅ **Public and visible** (on-chain, transparent)
- ✅ **Valuable** (people get paid for verification)
- ✅ **Required** (can't build resume without verified credentials)
- ✅ **Challengeable** (anyone can challenge fraud)
- ✅ **Scored** (public reputation based on verification)

## 🚀 Key Differentiators

| Feature | LinkedIn | Us |
|---------|----------|-----|
| **Verification** | Optional, hidden | Required, public, on-chain |
| **Fraud Prevention** | Self-reported, can fake | Smart contract enforced, can't fake |
| **Verification Value** | Free, not valuable | Paid, valuable |
| **Verification Challenges** | None | Public challenge system |
| **Verification Score** | None | Public on-chain score |

See [UNIQUE_DIFFERENTIATORS.md](./UNIQUE_DIFFERENTIATORS.md) for complete details.

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│     Gemini Wallet SDK (Identity)       │
│  • Holds identity & credentials        │
│  • Passkey authentication               │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│   Solana (Fast Verification)            │
│  • University credentials               │
│  • Employer verification                │
│  • Cost: ~$0.00025 per verification    │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│   Ethereum (Trusted Storage)            │
│  • Resume verification                  │
│  • Job matching vault                   │
│  • Resume staking                      │
│  • Verification marketplace             │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│   Turtle.xyz (Staking & Rewards)         │
│  • Liquidity distribution                │
│  • Staking rewards                       │
└─────────────────────────────────────────┘
```

## 📁 Project Structure

```
.
├── contracts/              # Smart contracts (Solidity)
│   ├── contracts/         # Contract source files
│   ├── scripts/           # Deployment scripts
│   └── test/              # Contract tests
├── backend/               # Node.js/Express API
│   ├── src/
│   │   ├── routes/       # API routes
│   │   ├── services/     # Business logic
│   │   ├── models/       # Database models
│   │   └── config/       # Configuration
│   └── package.json
├── frontend/              # Next.js/React app
│   ├── src/
│   │   ├── app/          # Next.js app router
│   │   ├── components/   # React components
│   │   └── config/       # Wagmi/Web3 config
│   └── package.json
├── COMPLETE_PROJECT_VISION.md  # Full project vision
└── UNIQUE_DIFFERENTIATORS.md   # What makes us different
```

## 🚀 Quick Start

### Prerequisites

- **Node.js 18+** and npm
- **MongoDB** (local or Atlas)
- **MetaMask** or Web3 wallet
- **Hardhat** (for local blockchain)

### Installation

```bash
# Install all dependencies
npm install

# Install in each workspace
cd contracts && npm install
cd ../backend && npm install
cd ../frontend && npm install
```

### Environment Setup

**Backend** (`backend/.env`):
```env
PORT=3001
MONGODB_URI=mongodb://localhost:27017/verified-resume
ETHEREUM_RPC_URL=http://localhost:8545
PRIVATE_KEY=your_private_key_here
IDENTITY_REGISTRY_ADDRESS=
CREDENTIAL_REGISTRY_ADDRESS=
RESUME_VERIFICATION_ADDRESS=
```

**Frontend** (`frontend/.env.local`):
```env
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_ETHEREUM_RPC_URL=http://localhost:8545
```

### Running the Application

1. **Start local blockchain**:
```bash
cd contracts
npm run dev
```

2. **Deploy contracts**:
```bash
cd contracts
npm run deploy:local
# Copy contract addresses to backend/.env
```

3. **Start backend**:
```bash
cd backend
npm run dev
```

4. **Start frontend**:
```bash
cd frontend
npm run dev
```

Or use the convenience script:
```bash
./start-dev.ps1  # Windows PowerShell
```

## 🔑 Core Features

### 1. Verified-Only Resume Builder
- Smart contract enforces verified credentials only
- **100% fraud prevention** - can't add unverified claims
- Instant trust for employers

### 2. Public Verification Score
- On-chain reputation (Diamond, Platinum, Gold, Silver, Bronze)
- Public and transparent
- Employers filter by verification level

### 3. Verification Challenges
- Anyone can challenge credentials (stake tokens)
- Public challenge system
- Rewards for successful challenges

### 4. Verification Marketplace
- Employers pay to verify candidates
- Candidates earn money for verification
- Verification has monetary value

### 5. Job Matching Vault
- Skillset-based matching
- Pre-filtered, verified candidates
- Reduces employer filtering time by 90%

### 6. Resume Staking
- Users stake resumes for rewards
- Platform earns fees
- Employers pay for premium access

See [COMPLETE_PROJECT_VISION.md](./COMPLETE_PROJECT_VISION.md) for all features.

## 📝 Smart Contracts

### Core Contracts
- `IdentityRegistry.sol` - User identity management
- `CredentialRegistry.sol` - Credential issuance and verification
- `ResumeVerification.sol` - Resume verification and fraud detection
- `CredentialBridge.sol` - Bridge Solana credentials to Ethereum

### Verification Contracts
- `VerificationScore.sol` - Public verification score
- `VerificationChallenge.sol` - Public challenge system
- `VerificationMarketplace.sol` - Paid verification marketplace
- `VerifiedProjectPortfolio.sol` - Verified project portfolio

### Matching & Staking
- `JobMatchingVault.sol` - Skillset-based job matching
- `ResumeStaking.sol` - Resume staking with rewards
- `GovernmentIDVerification.sol` - KYC/identity verification

## 🧪 Testing

```bash
# Test smart contracts
cd contracts && npm test

# Test backend
cd backend && npm test

# Test frontend
cd frontend && npm test
```

## 📚 Documentation

- [COMPLETE_PROJECT_VISION.md](./COMPLETE_PROJECT_VISION.md) - Full project vision and features
- [UNIQUE_DIFFERENTIATORS.md](./UNIQUE_DIFFERENTIATORS.md) - What makes us different

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Add tests
4. Submit a pull request

## 📄 License

MIT

## 🎯 Key Message

**"Verification is everything. Everything else is secondary."**

We're not just another job matching site - we're a **verification platform** that happens to do job matching.
