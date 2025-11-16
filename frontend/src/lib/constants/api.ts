/**
 * API configuration constants
 */

export const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

export const API_ENDPOINTS = {
  // Identity
  IDENTITY: '/api/identity',
  IDENTITY_REGISTER: '/api/identity/register',
  
  // Credentials
  CREDENTIALS: '/api/credentials',
  
  // Verification
  VERIFICATION_REQUEST: '/api/verification/request',
  VERIFICATION_STATUS: '/api/verification/status',
  
  // Staking
  STAKING_STATS: '/api/staking/stats',
  STAKING_STAKE: '/api/staking/stake',
  STAKING_UNSTAKE: '/api/staking/unstake',
  
  // Resumes
  RESUMES: '/api/resumes',
  RESUMES_CREATE: '/api/resumes/create',
  
  // Matching
  MATCHING_VAULT: '/api/matching/vault',
  MATCHING_RESULTS: '/api/matching/results',
} as const;

