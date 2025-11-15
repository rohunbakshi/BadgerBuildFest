"use client";

import { useAccount } from "wagmi";
import { ConnectButton } from "@rainbow-me/rainbowkit";

export default function MatchingPage() {
  const { isConnected } = useAccount();

  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="container mx-auto px-4">
        <h1 className="text-4xl font-bold mb-8">Job Matching</h1>

        {!isConnected ? (
          <div className="bg-white rounded-lg shadow p-8 text-center">
            <p className="text-gray-600 mb-4">Connect your wallet to continue</p>
            <ConnectButton />
          </div>
        ) : (
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold mb-4">Create Matching Vault</h2>
              <p className="text-gray-600">Create a vault for job matching based on skillsets.</p>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold mb-4">Matching Results</h2>
              <p className="text-gray-600">View matching candidates for your job postings.</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

