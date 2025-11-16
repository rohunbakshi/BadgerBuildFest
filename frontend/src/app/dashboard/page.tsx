'use client';

import { UserCog } from 'lucide-react';
import {
  TopNavigation,
  ProfileCard,
  ActionCard,
  VerificationCard,
  StakingCard,
  RequestVerificationModal,
} from '@/components/dashboard';
import { useDashboard } from '@/hooks/useDashboard';
import { ConnectButton } from '@rainbow-me/rainbowkit';

/**
 * Student Dashboard Page
 * Main dashboard for students to manage their profile, request verifications, and stake credentials
 */
export default function DashboardPage() {
  const {
    experiences,
    profile,
    stakingStats,
    unverifiedCount,
    isLoading,
    isVerificationModalOpen,
    setIsVerificationModalOpen,
    handleRequestVerification,
    handleStakeResume,
    handleUpdateProfile,
    isConnected,
  } = useDashboard();

  // Show loading state
  if (isLoading) {
    return (
      <div className="min-h-screen bg-[#f9fafb] flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-[#667eea] mx-auto mb-4"></div>
          <p className="text-[#6b7280]">Loading dashboard...</p>
        </div>
      </div>
    );
  }

  // Show connect wallet prompt if not connected
  if (!isConnected) {
    return (
      <div className="min-h-screen bg-[#f9fafb]">
        <TopNavigation />
        <main className="max-w-7xl mx-auto px-4 md:px-8 py-16">
          <div className="bg-white rounded-xl shadow-sm p-8 text-center">
            <h1 className="text-2xl font-medium text-[#111827] mb-4">Connect Your Wallet</h1>
            <p className="text-[#6b7280] mb-6">
              Please connect your wallet to access your dashboard.
            </p>
            <ConnectButton />
          </div>
        </main>
      </div>
    );
  }

  // Show error state if profile data is missing
  if (!profile) {
    return (
      <div className="min-h-screen bg-[#f9fafb]">
        <TopNavigation />
        <main className="max-w-7xl mx-auto px-4 md:px-8 py-16">
          <div className="bg-white rounded-xl shadow-sm p-8 text-center">
            <h1 className="text-2xl font-medium text-[#111827] mb-4">Profile Not Found</h1>
            <p className="text-[#6b7280]">
              Unable to load your profile. Please try refreshing the page.
            </p>
          </div>
        </main>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#f9fafb]">
      {/* Top Navigation */}
      <TopNavigation />

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 md:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-[30%_1fr] gap-6">
          {/* Left Section - Profile Card */}
          <div className="lg:sticky lg:top-8 h-fit">
            <ProfileCard
              name={profile.name}
              walletAddress={profile.walletAddress}
              profileImageUrl={profile.profileImageUrl}
              badges={profile.badges}
              summary={profile.summary}
              onUpdateProfile={handleUpdateProfile}
            />
          </div>

          {/* Right Section - Action Cards */}
          <div className="space-y-6">
            {/* Request Verification Card */}
            <VerificationCard
              title="Request Verification"
              description="Ask employers or institutions to verify your credentials"
              buttonText="Request Verification"
              buttonVariant="default"
              unverifiedCount={unverifiedCount}
              onAction={() => setIsVerificationModalOpen(true)}
            />

            {/* Staking Card */}
            <StakingCard
              title="Stake Your Resume"
              description="Earn 15-25% APY by staking your verified credentials"
              buttonText="Stake & Earn"
              buttonVariant="default"
              isStaking={stakingStats?.isStaking ?? false}
              stakingStats={
                stakingStats
                  ? {
                      students: stakingStats.students,
                      earnings: stakingStats.earnings,
                    }
                  : undefined
              }
              onAction={handleStakeResume}
            />

            {/* Profile Management Card */}
            <ActionCard
              icon={UserCog}
              title="Update Profile"
              description="Edit your information, add credentials, manage privacy"
              buttonText="Edit Profile"
              buttonVariant="outline"
              onAction={handleUpdateProfile}
            >
              <div className="bg-gray-50 rounded-lg p-3 border border-gray-200">
                <p className="text-xs text-[#6b7280]">
                  Last updated: <span className="text-[#111827] font-medium">3 days ago</span>
                </p>
              </div>
            </ActionCard>
          </div>
        </div>
      </main>

      {/* Verification Request Modal */}
      <RequestVerificationModal
        isOpen={isVerificationModalOpen}
        onClose={() => setIsVerificationModalOpen(false)}
        experiences={experiences}
        onRequestVerification={handleRequestVerification}
      />
    </div>
  );
}

