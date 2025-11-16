import { getDefaultConfig } from '@rainbow-me/rainbowkit'
import { http } from 'wagmi'
import { localhost, sepolia } from 'wagmi/chains'

// Use a dummy Project ID to prevent WalletConnect initialization errors
// RainbowKit will still show Coinbase Wallet and other injected wallets
// The dummy ID won't work for WalletConnect, but that's fine since we're not using it
const DUMMY_PROJECT_ID = '00000000000000000000000000000000'

// Configure wagmi using RainbowKit's default config
// This provides better multi-wallet discovery including Coinbase Wallet
// WalletConnect will fail silently but other wallets (Coinbase, MetaMask, Brave) will work
export const config = getDefaultConfig({
  appName: 'Decentralized Identity & Resume',
  projectId: DUMMY_PROJECT_ID, // Dummy ID - WalletConnect won't work but other wallets will
  chains: [localhost, sepolia],
  transports: {
    [localhost.id]: http(process.env.NEXT_PUBLIC_ETHEREUM_RPC_URL || process.env.NEXT_PUBLIC_RPC_URL || 'http://localhost:8545'),
    [sepolia.id]: http(),
  },
  ssr: false,
})

