# Decentralized Identity and Resume Management Platform

A blockchain-based platform that allows individuals to own and control their verified digital identity, resumes, and references. Employers and organizations can instantly validate this information without relying on centralized intermediaries.

## 🏗️ Architecture

This is a monorepo containing:

- **`contracts/`** - Smart contracts (Solidity) for identity, credentials, resumes, and access control
- **`backend/`** - Node.js/Express API server with IPFS integration and database
- **`frontend/`** - React/Next.js web application with Web3 integration
- **`shared/`** - Shared TypeScript types and utilities

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm
- Hardhat or Foundry for smart contract development
- A blockchain network (local, testnet, or mainnet)
- IPFS node (local or remote)

### Installation

```bash
# Install all dependencies
npm run install:all

# Or install individually
cd contracts && npm install
cd backend && npm install
cd frontend && npm install
```

### Development

```bash
# Start local blockchain (in contracts/)
npm run dev:contracts

# Start backend API (in backend/)
npm run dev:backend

# Start frontend app (in frontend/)
npm run dev:frontend
```

## 📁 Project Structure

```
.
├── contracts/          # Smart contracts
│   ├── contracts/      # Solidity source files
│   ├── scripts/        # Deployment scripts
│   ├── test/           # Contract tests
│   └── hardhat.config.js
├── backend/            # API server
│   ├── src/
│   │   ├── routes/     # API routes
│   │   ├── models/     # Database models
│   │   ├── services/   # Business logic
│   │   └── utils/      # Utilities
│   └── package.json
├── frontend/           # Web application
│   ├── src/
│   │   ├── components/ # React components
│   │   ├── pages/     # Page components
│   │   ├── hooks/      # Custom hooks
│   │   └── utils/      # Utilities
│   └── package.json
└── shared/             # Shared code
    └── types/          # TypeScript types
```

## 🔐 Key Features

- **Decentralized Identity**: Users own their identity via blockchain wallet/DID
- **Verified Credentials**: Issuers (universities, companies) can issue verifiable credentials
- **Resume Management**: Build resumes from verified credentials and self-claimed data
- **Reference System**: Signed references from referees
- **Selective Sharing**: Fine-grained consent and access control
- **Employer Verification**: Batch verification of credentials and references

## 🧪 Testing

```bash
# Test smart contracts
cd contracts && npm test

# Test backend
cd backend && npm test

# Test frontend
cd frontend && npm test
```

## 📝 Documentation

See the [Requirements Document](./Decentralized_Identity_Resume_Requirements.md) for detailed specifications.

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Add tests
4. Submit a pull request

## 📄 License

MIT

