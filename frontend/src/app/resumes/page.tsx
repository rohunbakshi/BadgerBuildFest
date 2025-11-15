'use client'

import { useAccount } from 'wagmi'
import { ConnectButton } from '@rainbow-me/rainbowkit'
import { useState, useEffect } from 'react'
import axios from 'axios'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'

export default function ResumesPage() {
  const { isConnected, address } = useAccount()
  const [resumes, setResumes] = useState<any[]>([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (isConnected && address) {
      loadResumes()
    }
  }, [isConnected, address])

  const loadResumes = async () => {
    if (!address) return
    setLoading(true)
    try {
      const response = await axios.get(`${API_URL}/api/resumes/user/${address}`)
      setResumes(response.data)
    } catch (error) {
      console.error('Error loading resumes:', error)
    } finally {
      setLoading(false)
    }
  }

  if (!isConnected) {
    return (
      <div className="min-h-screen p-8">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-3xl font-bold mb-6">Resume Management</h1>
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8 text-center">
            <p className="mb-4">Please connect your wallet to continue.</p>
            <ConnectButton />
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen p-8">
      <div className="max-w-4xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold">Resume Management</h1>
          <button className="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700">
            Create Resume
          </button>
        </div>

        {loading ? (
          <div className="text-center py-8">Loading...</div>
        ) : resumes.length === 0 ? (
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8 text-center">
            <p className="text-gray-600 dark:text-gray-300 mb-4">No resumes found.</p>
            <button className="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700">
              Create Your First Resume
            </button>
          </div>
        ) : (
          <div className="space-y-4">
            {resumes.map((resume) => (
              <div key={resume.resumeId} className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
                <h3 className="text-xl font-semibold mb-2">Resume {resume.resumeId.slice(0, 8)}...</h3>
                <p className="text-gray-600 dark:text-gray-300 mb-4">
                  {resume.credentialIds?.length || 0} credentials included
                </p>
                <div className="flex gap-2">
                  <button className="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700">
                    View
                  </button>
                  <button className="bg-gray-200 dark:bg-gray-700 px-4 py-2 rounded-md hover:bg-gray-300 dark:hover:bg-gray-600">
                    Edit
                  </button>
                  <button className="bg-gray-200 dark:bg-gray-700 px-4 py-2 rounded-md hover:bg-gray-300 dark:hover:bg-gray-600">
                    Share
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

