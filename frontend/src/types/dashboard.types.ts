/**
 * Type definitions for the Student Dashboard components
 */

export interface Experience {
  id: string;
  title: string;
  organization: string;
  type: 'education' | 'work';
  verified: boolean;
}

export interface VerificationBadge {
  id: string;
  label: string;
  type: 'education' | 'work';
}

export interface ProfileCardProps {
  name: string;
  walletAddress: string;
  profileImageUrl?: string;
  badges: VerificationBadge[];
  summary: string;
  onUpdateProfile: () => void;
}

export interface ActionCardProps {
  icon: React.ComponentType<{ className?: string }>;
  title: string;
  description: string;
  buttonText: string;
  buttonVariant?: 'default' | 'outline';
  onAction: () => void;
  children?: React.ReactNode;
}

export interface VerificationCardProps extends Omit<ActionCardProps, 'children' | 'icon'> {
  unverifiedCount: number;
}

export interface StakingCardProps extends Omit<ActionCardProps, 'children' | 'icon'> {
  isStaking: boolean;
  stakingStats?: {
    students: number;
    earnings: string;
  };
}

export interface RequestVerificationModalProps {
  isOpen: boolean;
  onClose: () => void;
  experiences: Experience[];
  onRequestVerification: (experienceId: string) => void;
}

