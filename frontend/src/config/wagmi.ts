import { getDefaultConfig } from '@rainbow-me/rainbowkit'
import { http } from 'wagmi'
import { localhost, sepolia } from 'wagmi/chains'

// Get WalletConnect Project ID from environment
// If not set, use a placeholder (WalletConnect will show an error but app will still work)
// Get your free Project ID from: https://cloud.walletconnect.com/
const projectId = process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID || '00000000000000000000000000000000'

if (projectId === '00000000000000000000000000000000' || projectId === 'your-project-id') {
  console.warn(
    '⚠️ WalletConnect Project ID not set. Please set NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID in .env.local\n' +
    'Get your free Project ID from: https://cloud.walletconnect.com/'
  )
}

export const config = getDefaultConfig({
  appName: 'Decentralized Identity & Resume',
  projectId: projectId,
  chains: [localhost, sepolia],
  transports: {
    [localhost.id]: http(process.env.NEXT_PUBLIC_ETHEREUM_RPC_URL || process.env.NEXT_PUBLIC_RPC_URL || 'http://localhost:8545'),
    [sepolia.id]: http(),
  },
  // Reduce connection timeout to fail faster
  ssr: false,
})

