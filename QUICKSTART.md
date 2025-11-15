# Quick Start Guide

## TL;DR - Get Running in 5 Minutes

### Prerequisites Check
```powershell
# Verify Node.js is installed
node --version  # Should be v18+
npm --version   # Should be 9+

# Verify MongoDB is running (if using local)
# Or have MongoDB Atlas connection string ready
```

### Step 1: Install Dependencies
```powershell
npm install
```

### Step 2: Configure Environment

**Backend:**
```powershell
cd backend
Copy-Item .env.example .env
# Edit .env with your MongoDB URI
```

**Frontend:**
```powershell
cd frontend
# Create .env.local with:
# NEXT_PUBLIC_API_URL=http://localhost:3001
# NEXT_PUBLIC_RPC_URL=http://localhost:8545
```

### Step 3: Run Everything

You need **4 terminal windows** open:

**Terminal 1 - Blockchain:**
```powershell
cd contracts
npm run dev
```

**Terminal 2 - Deploy Contracts:**
```powershell
cd contracts
npm run deploy:local
# Copy the addresses and update backend/.env
```

**Terminal 3 - Backend:**
```powershell
cd backend
npm run dev
```

**Terminal 4 - Frontend:**
```powershell
cd frontend
npm run dev
```

### Step 4: Open Browser
Go to: `http://localhost:3000`

## Common Issues

**"Cannot find module"**
→ Run `npm install` in the directory with the error

**"Port already in use"**
→ Change port in `.env` or kill the process using the port

**"MongoDB connection failed"**
→ Make sure MongoDB is running or check connection string

**"Contract not found"**
→ Make sure contracts are deployed and addresses are in `backend/.env`

## Need More Help?

See [SETUP.md](./SETUP.md) for detailed instructions.

