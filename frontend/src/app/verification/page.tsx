"use client";

import { useAccount } from "wagmi";
import { ConnectButton } from "@rainbow-me/rainbowkit";

export default function VerificationPage() {
  const { isConnected } = useAccount();

  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="container mx-auto px-4">
        <h1 className="text-4xl font-bold mb-8">Verification</h1>

        {!isConnected ? (
          <div className="bg-white rounded-lg shadow p-8 text-center">
            <p className="text-gray-600 mb-4">Connect your wallet to continue</p>
            <ConnectButton />
          </div>
        ) : (
          <div className="space-y-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold mb-4">Verification Score</h2>
              <p className="text-gray-600">Your public verification score will appear here.</p>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold mb-4">Verify Resume</h2>
              <p className="text-gray-600">Verify your resume against on-chain credentials.</p>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-2xl font-bold mb-4">Verification Marketplace</h2>
              <p className="text-gray-600">Get paid for verification by employers.</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

