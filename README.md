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

Before you begin, ensure you have the following installed:

1. **Node.js 18+** and npm

   - Download from [nodejs.org](https://nodejs.org/)
   - Verify: `node --version` and `npm --version`

2. **MongoDB** (for backend database)

   - Download from [mongodb.com](https://www.mongodb.com/try/download/community)
   - Or use MongoDB Atlas (cloud): [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)

3. **IPFS** (optional, for decentralized storage)

   - Install IPFS: [ipfs.io/install](https://docs.ipfs.io/install/)
   - Or use a remote IPFS service like Pinata or Infura

4. **MetaMask** or another Web3 wallet (for frontend)
   - Install browser extension: [metamask.io](https://metamask.io/)

### Step-by-Step Setup

#### 1. Install Dependencies

```bash
# Install root and all workspace dependencies
npm install

# Or install individually in each directory
cd contracts && npm install
cd ../backend && npm install
cd ../frontend && npm install
```

#### 2. Set Up Environment Variables

**Backend** (`backend/.env`):

```bash
cd backend
cp .env.example .env
# Edit .env with your configuration
```

**Frontend** (`frontend/.env.local`):

```bash
cd frontend
# Create .env.local file with:
# NEXT_PUBLIC_API_URL=http://localhost:3001
# NEXT_PUBLIC_RPC_URL=http://localhost:8545
```

#### 3. Start Local Blockchain

In a **new terminal window**:

```bash
cd contracts
npm run dev
# This starts Hardhat local network on http://localhost:8545
# Keep this terminal open!
```

#### 4. Deploy Smart Contracts

In a **new terminal window**:

```bash
cd contracts
npm run deploy:local
# Copy the contract addresses from the output
# Update backend/.env with these addresses
```

#### 5. Start MongoDB

Make sure MongoDB is running:

```bash
# If installed locally:
mongod

# Or if using MongoDB Atlas, ensure connection string is in backend/.env
```

#### 6. Start Backend API

In a **new terminal window**:

```bash
cd backend
npm run dev
# Server will start on http://localhost:3001
# Keep this terminal open!
```

#### 7. Start Frontend

In a **new terminal window**:

```bash
cd frontend
npm run dev
# App will start on http://localhost:3000
# Open in your browser!
```

### Running the Application

Once everything is set up, you should have:

1. **Local blockchain** running on `http://localhost:8545`
2. **Backend API** running on `http://localhost:3001`
3. **Frontend app** running on `http://localhost:3000`

Open your browser and navigate to `http://localhost:3000`

### Quick Commands Reference

```bash
# Install all dependencies
npm install

# Start local blockchain
cd contracts && npm run dev

# Deploy contracts
cd contracts && npm run deploy:local

# Start backend
cd backend && npm run dev

# Start frontend
cd frontend && npm run dev

# Run tests
cd contracts && npm test
cd backend && npm test
cd frontend && npm test
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
