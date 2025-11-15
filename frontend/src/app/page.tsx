'use client'

import { ConnectButton } from '@rainbow-me/rainbowkit'
import { useAccount } from 'wagmi'
import Link from 'next/link'

export default function Home() {
  const { isConnected, address } = useAccount()

  return (
    <main className="min-h-screen p-8">
      <div className="max-w-7xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-4xl font-bold">Decentralized Identity & Resume</h1>
          <ConnectButton />
        </div>

        {isConnected ? (
          <div className="space-y-6">
            <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
              <h2 className="text-2xl font-semibold mb-4">Welcome!</h2>
              <p className="text-gray-600 dark:text-gray-300 mb-4">
                Your wallet address: <code className="bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded">{address}</code>
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              <Link href="/identity" className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
                <h3 className="text-xl font-semibold mb-2">Identity</h3>
                <p className="text-gray-600 dark:text-gray-300">Manage your decentralized identity and profile</p>
              </Link>

              <Link href="/credentials" className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
                <h3 className="text-xl font-semibold mb-2">Credentials</h3>
                <p className="text-gray-600 dark:text-gray-300">View and manage your verified credentials</p>
              </Link>

              <Link href="/resumes" className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
                <h3 className="text-xl font-semibold mb-2">Resumes</h3>
                <p className="text-gray-600 dark:text-gray-300">Create and manage your resumes</p>
              </Link>

              <Link href="/share" className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
                <h3 className="text-xl font-semibold mb-2">Share</h3>
                <p className="text-gray-600 dark:text-gray-300">Share your resume with employers</p>
              </Link>

              <Link href="/verify" className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
                <h3 className="text-xl font-semibold mb-2">Verify</h3>
                <p className="text-gray-600 dark:text-gray-300">Verify credentials and resumes</p>
              </Link>

              <Link href="/issuer" className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
                <h3 className="text-xl font-semibold mb-2">Issuer</h3>
                <p className="text-gray-600 dark:text-gray-300">Issue credentials as an organization</p>
              </Link>
            </div>
          </div>
        ) : (
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8 text-center">
            <h2 className="text-2xl font-semibold mb-4">Connect Your Wallet</h2>
            <p className="text-gray-600 dark:text-gray-300 mb-6">
              Connect your wallet to get started with decentralized identity and resume management.
            </p>
            <ConnectButton />
          </div>
        )}
      </div>
    </main>
  )
}

