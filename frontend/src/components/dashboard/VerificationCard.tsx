'use client';

import { ShieldCheck } from 'lucide-react';
import { ActionCard } from './ActionCard';
import type { VerificationCardProps } from '@/types/dashboard.types';

/**
 * Verification card component
 * Specialized action card for requesting verification
 */
export function VerificationCard({
  unverifiedCount,
  onAction,
  title = 'Request Verification',
  description = 'Ask employers or institutions to verify your credentials',
  buttonText = 'Request Verification',
  buttonVariant = 'default',
  ...props
}: VerificationCardProps) {
  return (
    <ActionCard
      icon={ShieldCheck}
      title={title}
      description={description}
      buttonText={buttonText}
      buttonVariant={buttonVariant}
      onAction={onAction}
      {...props}
    >
      <div className="bg-gray-50 rounded-lg p-3 border border-gray-200">
        <p className="text-xs text-[#6b7280]">
          <span className="text-[#111827] font-medium">{unverifiedCount} unverified experiences</span>{' '}
          ready for verification
        </p>
      </div>
    </ActionCard>
  );
}

