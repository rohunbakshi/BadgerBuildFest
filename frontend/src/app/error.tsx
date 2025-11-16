'use client';

import { useEffect } from 'react';

/**
 * Global error handler for Next.js app router
 * Catches WalletConnect errors and suppresses them
 */
export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Check if it's a WalletConnect error
    const isWalletConnectError =
      error.message?.includes('Connection interrupted') ||
      error.message?.includes('WalletConnect') ||
      error.stack?.includes('@walletconnect');

    if (isWalletConnectError) {
      // Suppress WalletConnect errors - they're not critical
      console.warn(
        'WalletConnect connection issue (this is normal if Project ID is not set):',
        error.message
      );
      // Silently reset to continue without WalletConnect
      reset();
      return;
    }

    // Log other errors
    console.error('Application error:', error);
  }, [error, reset]);

  // Check if it's a WalletConnect error
  const isWalletConnectError =
    error.message?.includes('Connection interrupted') ||
    error.message?.includes('WalletConnect') ||
    error.stack?.includes('@walletconnect');

  // Don't show error UI for WalletConnect errors
  if (isWalletConnectError) {
    return null; // Silently handle - app will continue
  }

  // Show error UI for other errors
  return (
    <div className="min-h-screen bg-[#f9fafb] flex items-center justify-center p-4">
      <div className="bg-white rounded-xl shadow-sm p-8 max-w-md text-center">
        <h2 className="text-xl font-medium text-[#111827] mb-4">Something went wrong</h2>
        <p className="text-[#6b7280] mb-4">{error.message}</p>
        <button
          onClick={reset}
          className="px-4 py-2 bg-[#667eea] text-white rounded-lg hover:opacity-90"
        >
          Try again
        </button>
      </div>
    </div>
  );
}

