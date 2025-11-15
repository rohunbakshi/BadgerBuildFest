# Detailed Setup Guide

This guide will walk you through setting up the Decentralized Identity and Resume Management platform from scratch.

## Prerequisites Installation

### 1. Node.js and npm

**Windows:**
- Download installer from [nodejs.org](https://nodejs.org/)
- Run the installer and follow the prompts
- Verify installation:
  ```powershell
  node --version  # Should show v18.x.x or higher
  npm --version   # Should show 9.x.x or higher
  ```

**macOS:**
```bash
# Using Homebrew
brew install node

# Verify
node --version
npm --version
```

**Linux:**
```bash
# Using apt (Ubuntu/Debian)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version
npm --version
```

### 2. MongoDB

**Option A: Local Installation**

**Windows:**
- Download from [mongodb.com/try/download/community](https://www.mongodb.com/try/download/community)
- Run installer and follow prompts
- MongoDB will start automatically as a service

**macOS:**
```bash
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community
```

**Linux:**
```bash
# Ubuntu/Debian
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
```

**Option B: MongoDB Atlas (Cloud - Recommended for beginners)**

1. Go to [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
2. Sign up for free account
3. Create a free cluster
4. Get your connection string
5. Use it in `backend/.env` as `MONGODB_URI`

### 3. IPFS (Optional but Recommended)

**Option A: Local IPFS Node**

**Windows:**
- Download from [dist.ipfs.io](https://dist.ipfs.io/#go-ipfs)
- Extract and add to PATH
- Initialize: `ipfs init`
- Start daemon: `ipfs daemon`

**macOS:**
```bash
brew install ipfs
ipfs init
ipfs daemon
```

**Linux:**
```bash
wget https://dist.ipfs.io/go-ipfs/v0.20.0/go-ipfs_v0.20.0_linux-amd64.tar.gz
tar -xvzf go-ipfs_v0.20.0_linux-amd64.tar.gz
cd go-ipfs
sudo ./install.sh
ipfs init
ipfs daemon
```

**Option B: Use Remote IPFS Service**

- [Pinata](https://www.pinata.cloud/) - Free tier available
- [Infura IPFS](https://infura.io/product/ipfs) - Free tier available
- Update `backend/.env` with the service API URL

### 4. MetaMask Browser Extension

1. Go to [metamask.io](https://metamask.io/)
2. Click "Download" and install for your browser
3. Create a new wallet or import existing
4. Add local network:
   - Network Name: `Localhost 8545`
   - RPC URL: `http://localhost:8545`
   - Chain ID: `1337`
   - Currency Symbol: `ETH`

## Project Setup

### Step 1: Clone and Install

```bash
# Navigate to project directory
cd BadgerBuildFest

# Install all dependencies
npm install
```

### Step 2: Configure Backend

```bash
cd backend

# Copy environment template
# On Windows PowerShell:
Copy-Item .env.example .env

# On macOS/Linux:
cp .env.example .env
```

Edit `backend/.env`:
```env
PORT=3001
NODE_ENV=development
FRONTEND_URL=http://localhost:3000

# MongoDB - use your connection string
MONGODB_URI=mongodb://localhost:27017/decentralized-identity
# Or for MongoDB Atlas:
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/decentralized-identity

# Blockchain - will be set after contract deployment
RPC_URL=http://localhost:8545
IDENTITY_REGISTRY_ADDRESS=
CREDENTIAL_REGISTRY_ADDRESS=
RESUME_REGISTRY_ADDRESS=
ISSUER_REGISTRY_ADDRESS=

# IPFS
IPFS_API_URL=http://localhost:5001
# Or for remote service:
# IPFS_API_URL=https://ipfs.infura.io:5001/api/v0
IPFS_GATEWAY_URL=https://ipfs.io/ipfs/
```

### Step 3: Configure Frontend

```bash
cd frontend

# Create .env.local file
# On Windows PowerShell:
New-Item .env.local

# On macOS/Linux:
touch .env.local
```

Edit `frontend/.env.local`:
```env
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_RPC_URL=http://localhost:8545
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your-project-id
```

For WalletConnect Project ID:
1. Go to [cloud.walletconnect.com](https://cloud.walletconnect.com/)
2. Sign up/login
3. Create a new project
4. Copy the Project ID

### Step 4: Start Local Blockchain

Open a **new terminal** and run:

```bash
cd contracts
npm run dev
```

This starts Hardhat's local blockchain. You should see:
```
Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/
```

**Keep this terminal open!** The blockchain must be running.

### Step 5: Deploy Smart Contracts

Open a **new terminal** and run:

```bash
cd contracts
npm run deploy:local
```

You'll see output like:
```
Deploying contracts with the account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
IssuerRegistry deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
IdentityRegistry deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
...
```

**Copy these addresses** and update `backend/.env`:
```env
IDENTITY_REGISTRY_ADDRESS=0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
CREDENTIAL_REGISTRY_ADDRESS=0x...
RESUME_REGISTRY_ADDRESS=0x...
ISSUER_REGISTRY_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
```

### Step 6: Start Backend

Open a **new terminal** and run:

```bash
cd backend
npm run dev
```

You should see:
```
✅ Connected to MongoDB
🚀 Server running on port 3001
```

**Keep this terminal open!**

### Step 7: Start Frontend

Open a **new terminal** and run:

```bash
cd frontend
npm run dev
```

You should see:
```
  ▲ Next.js 14.0.4
  - Local:        http://localhost:3000
```

### Step 8: Access the Application

1. Open your browser
2. Navigate to `http://localhost:3000`
3. Connect your MetaMask wallet (make sure it's connected to Localhost 8545 network)
4. Start using the platform!

## Troubleshooting

### Issue: "Cannot connect to MongoDB"

**Solution:**
- Make sure MongoDB is running: `mongod` (local) or check Atlas connection
- Verify `MONGODB_URI` in `backend/.env` is correct
- Check firewall settings

### Issue: "Cannot connect to blockchain"

**Solution:**
- Make sure Hardhat node is running (`npm run dev` in contracts/)
- Verify RPC URL in `backend/.env` and `frontend/.env.local`
- Check MetaMask is connected to Localhost 8545 network

### Issue: "IPFS connection failed"

**Solution:**
- If using local IPFS: Make sure `ipfs daemon` is running
- If using remote service: Verify API URL and credentials
- You can temporarily disable IPFS features if not needed

### Issue: "Contract not found" errors

**Solution:**
- Make sure contracts are deployed (`npm run deploy:local`)
- Verify contract addresses in `backend/.env` match deployment output
- Redeploy if needed

### Issue: Frontend build errors

**Solution:**
```bash
cd frontend
rm -rf .next node_modules
npm install
npm run dev
```

### Issue: Port already in use

**Solution:**
- Change port in `backend/.env` (PORT=3002)
- Or kill the process using the port:
  - Windows: `netstat -ano | findstr :3001` then `taskkill /PID <pid> /F`
  - macOS/Linux: `lsof -ti:3001 | xargs kill`

## Next Steps

1. **Test the contracts:**
   ```bash
   cd contracts
   npm test
   ```

2. **Create your identity:**
   - Connect wallet on frontend
   - Go to Identity page
   - Fill in your profile

3. **Issue test credentials:**
   - Deployer account is admin by default
   - Can approve issuers and issue credentials

4. **Build a resume:**
   - Go to Resumes page
   - Create a new resume
   - Add credentials and self-claimed items

## Development Tips

- Use Hardhat console for contract interaction:
  ```bash
  cd contracts
  npx hardhat console --network localhost
  ```

- Check backend logs for API debugging

- Use browser DevTools for frontend debugging

- Reset local blockchain by restarting Hardhat node (all data resets)

## Production Deployment

For production deployment, you'll need to:

1. Deploy contracts to a real network (Sepolia, Polygon, etc.)
2. Set up production MongoDB (Atlas recommended)
3. Configure production IPFS (Pinata or Infura)
4. Set up environment variables for production
5. Build and deploy frontend (Vercel, Netlify, etc.)
6. Set up backend hosting (AWS, Heroku, Railway, etc.)

See individual component READMEs for more details.

