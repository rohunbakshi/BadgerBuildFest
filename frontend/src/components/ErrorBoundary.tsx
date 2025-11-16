'use client';

import { Component, ReactNode } from 'react';

interface Props {
  children: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

/**
 * Error Boundary to catch and handle WalletConnect errors gracefully
 */
export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
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
      // Return null to suppress the error
      return { hasError: false, error: null };
    }

    // For other errors, show them
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // Only log non-WalletConnect errors
    const isWalletConnectError =
      error.message?.includes('Connection interrupted') ||
      error.message?.includes('WalletConnect') ||
      error.stack?.includes('@walletconnect');

    if (!isWalletConnectError) {
      console.error('Error caught by boundary:', error, errorInfo);
    }
  }

  render() {
    if (this.state.hasError && this.state.error) {
      return (
        <div className="min-h-screen bg-[#f9fafb] flex items-center justify-center p-4">
          <div className="bg-white rounded-xl shadow-sm p-8 max-w-md text-center">
            <h2 className="text-xl font-medium text-[#111827] mb-4">Something went wrong</h2>
            <p className="text-[#6b7280] mb-4">{this.state.error.message}</p>
            <button
              onClick={() => this.setState({ hasError: false, error: null })}
              className="px-4 py-2 bg-[#667eea] text-white rounded-lg hover:opacity-90"
            >
              Try again
            </button>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}

