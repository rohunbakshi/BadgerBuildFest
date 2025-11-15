"use client";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-16">
        {/* Header */}
        <div className="text-center mb-16">
          <h1 className="text-5xl font-bold text-gray-900 mb-4">
            Verified Resume Platform
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            Verification is Everything. Everything else is secondary.
          </p>
          <div className="flex justify-center gap-4">
            <ConnectButton />
          </div>
        </div>

        {/* Key Features */}
        <div className="grid md:grid-cols-3 gap-8 mb-16">
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h2 className="text-2xl font-bold mb-4">✅ Verified-Only Resumes</h2>
            <p className="text-gray-600">
              Build resumes from verified credentials only. 100% fraud prevention.
            </p>
          </div>
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h2 className="text-2xl font-bold mb-4">⭐ Public Verification Score</h2>
            <p className="text-gray-600">
              Earn Diamond, Platinum, Gold badges based on verified credentials.
            </p>
          </div>
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h2 className="text-2xl font-bold mb-4">💰 Get Paid for Verification</h2>
            <p className="text-gray-600">
              Employers pay to verify candidates. You earn money for verification.
            </p>
          </div>
        </div>

        {/* Navigation */}
        <div className="grid md:grid-cols-4 gap-4">
          <Link
            href="/identity"
            className="bg-indigo-600 text-white rounded-lg p-6 text-center hover:bg-indigo-700 transition"
          >
            <h3 className="font-bold mb-2">Identity</h3>
            <p className="text-sm">Manage your identity</p>
          </Link>
          <Link
            href="/resumes"
            className="bg-indigo-600 text-white rounded-lg p-6 text-center hover:bg-indigo-700 transition"
          >
            <h3 className="font-bold mb-2">Resumes</h3>
            <p className="text-sm">Build verified resumes</p>
          </Link>
          <Link
            href="/verification"
            className="bg-indigo-600 text-white rounded-lg p-6 text-center hover:bg-indigo-700 transition"
          >
            <h3 className="font-bold mb-2">Verification</h3>
            <p className="text-sm">Verify credentials</p>
          </Link>
          <Link
            href="/matching"
            className="bg-indigo-600 text-white rounded-lg p-6 text-center hover:bg-indigo-700 transition"
          >
            <h3 className="font-bold mb-2">Job Matching</h3>
            <p className="text-sm">Find matching jobs</p>
          </Link>
        </div>
      </div>
    </div>
  );
}
