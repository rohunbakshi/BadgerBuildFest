'use client';

import { useState, useCallback } from 'react';
import { useAccount } from 'wagmi';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import axios from 'axios';
import { toast } from 'sonner';
import type { Experience } from '@/types/dashboard.types';
import { API_URL, API_ENDPOINTS } from '@/lib/constants';

interface ProfileData {
  name: string;
  walletAddress: string;
  profileImageUrl?: string;
  badges: Array<{ id: string; label: string; type: 'education' | 'work' }>;
  summary: string;
}

interface StakingStats {
  students: number;
  earnings: string;
  isStaking: boolean;
}

/**
 * Custom hook for dashboard data and operations
 * Handles API calls, state management, and user interactions
 */
export function useDashboard() {
  const { address, isConnected } = useAccount();
  const queryClient = useQueryClient();
  const [isVerificationModalOpen, setIsVerificationModalOpen] = useState(false);

  // Fetch user experiences/credentials
  const {
    data: experiences = [],
    isLoading: isLoadingExperiences,
    error: experiencesError,
  } = useQuery<Experience[]>({
    queryKey: ['dashboard', 'experiences', address],
    queryFn: async () => {
      if (!address) return [];
      // TODO: Replace with actual API endpoint
      // const response = await axios.get(`${API_URL}${API_ENDPOINTS.CREDENTIALS}`, {
      //   params: { walletAddress: address },
      // });
      // return response.data;
      
      // Mock data for now
      return [
        {
          id: '1',
          title: 'Bachelor of Science in Computer Science',
          organization: 'MIT',
          type: 'education',
          verified: true,
        },
        {
          id: '2',
          title: 'Software Engineer',
          organization: 'Google',
          type: 'work',
          verified: true,
        },
        {
          id: '3',
          title: 'Frontend Developer Intern',
          organization: 'Meta',
          type: 'work',
          verified: false,
        },
        {
          id: '4',
          title: 'Teaching Assistant',
          organization: 'MIT CSAIL',
          type: 'work',
          verified: false,
        },
      ];
    },
    enabled: !!address && isConnected,
  });

  // Fetch user profile
  const {
    data: profile,
    isLoading: isLoadingProfile,
    error: profileError,
  } = useQuery<ProfileData>({
    queryKey: ['dashboard', 'profile', address],
    queryFn: async () => {
      if (!address) {
        throw new Error('Wallet not connected');
      }
      // TODO: Replace with actual API endpoint
      // const response = await axios.get(`${API_URL}${API_ENDPOINTS.IDENTITY}`, {
      //   params: { walletAddress: address },
      // });
      // return response.data;
      
      // Mock data for now
      return {
        name: 'Bob Jones',
        walletAddress: address,
        profileImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
        badges: [
          { id: '1', label: "MIT '98", type: 'education' },
          { id: '2', label: 'Google SWE', type: 'work' },
        ],
        summary: 'Computer Science @ MIT | Software Engineer @ Google | 3 verified credentials',
      };
    },
    enabled: !!address && isConnected,
  });

  // Fetch staking stats
  const {
    data: stakingStats,
    isLoading: isLoadingStaking,
  } = useQuery<StakingStats>({
    queryKey: ['dashboard', 'staking'],
    queryFn: async () => {
      // TODO: Replace with actual API endpoint
      // const response = await axios.get(`${API_URL}${API_ENDPOINTS.STAKING_STATS}`);
      // return response.data;
      
      // Mock data for now
      return {
        students: 523,
        earnings: '$247k',
        isStaking: false,
      };
    },
  });

  // Request verification mutation
  const requestVerificationMutation = useMutation({
    mutationFn: async (experienceId: string) => {
      if (!address) throw new Error('Wallet not connected');
      
      const experience = experiences.find((exp) => exp.id === experienceId);
      if (!experience) throw new Error('Experience not found');
      
      // TODO: Replace with actual API call
      // const response = await axios.post(`${API_URL}${API_ENDPOINTS.VERIFICATION_REQUEST}`, {
      //   walletAddress: address,
      //   experienceId,
      //   organization: experience.organization,
      // });
      // return response.data;
      
      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 1000));
      return { success: true, experienceId };
    },
    onSuccess: (data, experienceId) => {
      const experience = experiences.find((exp) => exp.id === experienceId);
      toast.success(`Verification request sent to ${experience?.organization}!`);
      queryClient.invalidateQueries({ queryKey: ['dashboard', 'experiences'] });
      setIsVerificationModalOpen(false);
    },
    onError: (error: Error) => {
      toast.error(`Failed to request verification: ${error.message}`);
    },
  });

  // Stake resume mutation
  const stakeResumeMutation = useMutation({
    mutationFn: async () => {
      if (!address) throw new Error('Wallet not connected');
      
      // TODO: Replace with actual API/smart contract call
      // const response = await axios.post(`${API_URL}${API_ENDPOINTS.STAKING_STAKE}`, {
      //   walletAddress: address,
      // });
      // return response.data;
      
      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 1000));
      return { success: true };
    },
    onSuccess: () => {
      toast.success('Resume staked successfully! You can now earn 15-25% APY.');
      queryClient.invalidateQueries({ queryKey: ['dashboard', 'staking'] });
    },
    onError: (error: Error) => {
      toast.error(`Failed to stake resume: ${error.message}`);
    },
  });

  // Handlers
  const handleRequestVerification = useCallback(
    (experienceId: string) => {
      requestVerificationMutation.mutate(experienceId);
    },
    [requestVerificationMutation]
  );

  const handleStakeResume = useCallback(() => {
    stakeResumeMutation.mutate();
  }, [stakeResumeMutation]);

  const handleUpdateProfile = useCallback(() => {
    // TODO: Navigate to profile editor or open modal
    toast.info('Profile editor coming soon!');
  }, []);

  const unverifiedCount = experiences.filter((exp) => !exp.verified).length;

  return {
    // Data
    experiences,
    profile,
    stakingStats,
    unverifiedCount,
    
    // Loading states
    isLoadingExperiences,
    isLoadingProfile,
    isLoadingStaking,
    isLoading: isLoadingExperiences || isLoadingProfile || isLoadingStaking,
    
    // Errors
    experiencesError,
    profileError,
    
    // Modal state
    isVerificationModalOpen,
    setIsVerificationModalOpen,
    
    // Handlers
    handleRequestVerification,
    handleStakeResume,
    handleUpdateProfile,
    
    // Wallet state
    isConnected,
    address,
  };
}

