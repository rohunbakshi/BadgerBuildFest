# Frontend Application

Next.js React application with Web3 integration for the Decentralized Identity and Resume Management platform.

## Setup

```bash
cd frontend
npm install
```

## Configuration

Create `.env.local`:
```env
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_RPC_URL=http://localhost:8545
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your-project-id
```

## Development

```bash
npm run dev
# App runs on http://localhost:3000
```

## Features

- **Wallet Connection** - Connect via MetaMask or WalletConnect
- **Identity Management** - Create and update your profile
- **Credential Viewing** - View your verified credentials
- **Resume Builder** - Create resumes from credentials
- **Sharing** - Generate share links for employers
- **Verification** - Verify credentials and resumes

## Tech Stack

- **Next.js 14** - React framework
- **Wagmi** - React hooks for Ethereum
- **RainbowKit** - Wallet connection UI
- **Tailwind CSS** - Styling
- **TypeScript** - Type safety

## Building for Production

```bash
npm run build
npm start
```

## Deployment

### Vercel (Recommended)

1. Push code to GitHub
2. Import project in Vercel
3. Add environment variables
4. Deploy!

### Other Platforms

- Netlify
- AWS Amplify
- Railway
- Any Node.js hosting

## Wallet Setup

Users need:
1. MetaMask or compatible wallet
2. Local network configured (for development):
   - Network: Localhost 8545
   - RPC: http://localhost:8545
   - Chain ID: 1337

## Testing

```bash
npm test
```

