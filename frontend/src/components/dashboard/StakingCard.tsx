'use client';

import { Lock } from 'lucide-react';
import { ActionCard } from './ActionCard';
import type { StakingCardProps } from '@/types/dashboard.types';

/**
 * Staking card component
 * Specialized action card for staking interface
 */
export function StakingCard({
  isStaking,
  stakingStats,
  onAction,
  title = 'Stake Your Resume',
  description = 'Earn 15-25% APY by staking your verified credentials',
  buttonText = 'Stake & Earn',
  buttonVariant = 'default',
  ...props
}: StakingCardProps) {
  return (
    <ActionCard
      icon={Lock}
      title={title}
      description={description}
      buttonText={buttonText}
      buttonVariant={buttonVariant}
      onAction={onAction}
      {...props}
    >
      <div className="space-y-2">
        <div className="bg-gray-50 rounded-lg p-3 border border-gray-200">
          <p className="text-xs text-[#6b7280] mb-1">Current Status</p>
          <p className="text-sm text-[#111827] font-medium">
            {isStaking ? 'Currently staking' : 'Not currently staking'}
          </p>
        </div>
        {stakingStats && (
          <div className="bg-gradient-to-r from-[#667eea]/10 to-[#764ba2]/10 rounded-lg p-3 border border-[#667eea]/20">
            <p className="text-xs text-[#667eea]">
              <span className="text-[#111827] font-medium">{stakingStats.students} students</span>{' '}
              earning{' '}
              <span className="text-[#111827] font-medium">{stakingStats.earnings} combined</span>
            </p>
          </div>
        )}
      </div>
    </ActionCard>
  );
}

