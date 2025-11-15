# PowerShell script to start all development servers
# Run this script from the project root directory

Write-Host "🚀 Starting Decentralized Identity Platform..." -ForegroundColor Green

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js not found. Please install Node.js 18+ from nodejs.org" -ForegroundColor Red
    exit 1
}

# Check if dependencies are installed
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
    npm install
}

if (-not (Test-Path "contracts/node_modules")) {
    Write-Host "📦 Installing contract dependencies..." -ForegroundColor Yellow
    cd contracts
    npm install
    cd ..
}

if (-not (Test-Path "backend/node_modules")) {
    Write-Host "📦 Installing backend dependencies..." -ForegroundColor Yellow
    cd backend
    npm install
    cd ..
}

if (-not (Test-Path "frontend/node_modules")) {
    Write-Host "📦 Installing frontend dependencies..." -ForegroundColor Yellow
    cd frontend
    npm install
    cd ..
}

# Check environment files
if (-not (Test-Path "backend/.env")) {
    Write-Host "⚠️  backend/.env not found. Copying from .env.example..." -ForegroundColor Yellow
    Copy-Item "backend/.env.example" "backend/.env"
    Write-Host "⚠️  Please edit backend/.env with your configuration!" -ForegroundColor Yellow
}

if (-not (Test-Path "frontend/.env.local")) {
    Write-Host "⚠️  frontend/.env.local not found. Creating template..." -ForegroundColor Yellow
    @"
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_RPC_URL=http://localhost:8545
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your-project-id
"@ | Out-File -FilePath "frontend/.env.local" -Encoding utf8
    Write-Host "⚠️  Please edit frontend/.env.local with your configuration!" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Starting services in separate windows..." -ForegroundColor Cyan
Write-Host ""
Write-Host "You need to run these commands in separate terminal windows:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Terminal 1 - Blockchain:" -ForegroundColor Green
Write-Host "  cd contracts" -ForegroundColor White
Write-Host "  npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "Terminal 2 - Deploy Contracts:" -ForegroundColor Green
Write-Host "  cd contracts" -ForegroundColor White
Write-Host "  npm run deploy:local" -ForegroundColor White
Write-Host "  (Then update backend/.env with contract addresses)" -ForegroundColor Gray
Write-Host ""
Write-Host "Terminal 3 - Backend:" -ForegroundColor Green
Write-Host "  cd backend" -ForegroundColor White
Write-Host "  npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "Terminal 4 - Frontend:" -ForegroundColor Green
Write-Host "  cd frontend" -ForegroundColor White
Write-Host "  npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "Then open http://localhost:3000 in your browser!" -ForegroundColor Cyan
Write-Host ""

# Optionally, try to start services automatically
$startAuto = Read-Host "Would you like to try starting services automatically? (y/n)"
if ($startAuto -eq "y" -or $startAuto -eq "Y") {
    Write-Host "Starting services..." -ForegroundColor Green
    
    # Start blockchain in new window
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\contracts'; npm run dev"
    Start-Sleep -Seconds 3
    
    Write-Host "✅ Blockchain starting in new window" -ForegroundColor Green
    Write-Host "⏳ Wait 5 seconds, then deploy contracts manually" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "After deploying contracts, press Enter to continue..." -ForegroundColor Yellow
    Read-Host
    
    # Start backend in new window
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\backend'; npm run dev"
    Start-Sleep -Seconds 2
    
    # Start frontend in new window
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\frontend'; npm run dev"
    Start-Sleep -Seconds 2
    
    Write-Host ""
    Write-Host "✅ All services starting!" -ForegroundColor Green
    Write-Host "🌐 Frontend will be available at http://localhost:3000" -ForegroundColor Cyan
}

