'use client'

import { WagmiProvider } from 'wagmi'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { RainbowKitProvider } from '@rainbow-me/rainbowkit'
import { Toaster } from 'sonner'
import '@rainbow-me/rainbowkit/styles.css'
import { config } from '@/config/wagmi'
import { useEffect } from 'react'

// Create QueryClient outside component to prevent recreation on every render
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
})

export function Providers({ children }: { children: React.ReactNode }) {
  // Handle WalletConnect errors gracefully
  useEffect(() => {
    const handleError = (event: ErrorEvent) => {
      // Suppress WalletConnect connection errors in development
      if (
        event.error?.message?.includes('Connection interrupted') ||
        event.error?.message?.includes('WalletConnect')
      ) {
        console.warn('WalletConnect connection issue (this is normal if Project ID is not set):', event.error.message)
        // Don't show error to user - wallet connection is optional for testing
        event.preventDefault()
      }
    }

    window.addEventListener('error', handleError)
    return () => window.removeEventListener('error', handleError)
  }, [])

  // Since we're using dynamic import with ssr: false, we don't need mounted check
  // This component will only render on client side
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          {children}
          <Toaster position="top-right" richColors />
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  )
}

