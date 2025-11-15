import { getDefaultConfig } from '@rainbow-me/rainbowkit'
import { http } from 'wagmi'
import { localhost, sepolia } from 'wagmi/chains'

export const config = getDefaultConfig({
  appName: 'Decentralized Identity & Resume',
  projectId: process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID || 'your-project-id',
  chains: [localhost, sepolia],
  transports: {
    [localhost.id]: http(process.env.NEXT_PUBLIC_RPC_URL || 'http://localhost:8545'),
    [sepolia.id]: http(),
  },
})

