# Dashboard Refactoring Documentation

This document consolidates all information about the Student Dashboard refactoring from Figma design to production-ready React components.

## Overview

The Student Dashboard was refactored from Figma-generated code into production-ready React + TypeScript components with proper structure, TypeScript types, and integration with React Query and Wagmi.

## Component Structure

### Main Components
- **TopNavigation** - Navigation bar with logo, search, and actions
- **ProfileCard** - User profile display with image, badges, and wallet address
- **ActionCard** - Reusable action card component
- **VerificationCard** - Specialized card for verification requests
- **StakingCard** - Specialized card for staking interface
- **RequestVerificationModal** - Modal for requesting verification

### Supporting Components
- **ImageWithFallback** - Image component with error handling
- **Button** - Reusable button component
- **Badge** - Badge component for verification status

## File Locations

```
frontend/src/
├── components/
│   └── dashboard/        # Dashboard-specific components
│   └── ui/               # Reusable UI components
├── hooks/
│   └── useDashboard.ts   # Dashboard data and operations hook
├── types/
│   └── dashboard.types.ts # TypeScript type definitions
└── app/
    └── dashboard/
        └── page.tsx      # Main dashboard page
```

## Integration

### React Query
- Data fetching for experiences, profile, and staking stats
- Automatic caching and refetching
- Mutation handling for verification requests and staking

### Wagmi
- Wallet connection management
- Account state handling
- Chain configuration

### Toast Notifications
- Success, error, and info toasts
- Integrated with all user actions
- Using `sonner` library

## API Integration Points

The dashboard is ready for backend integration. Update API calls in `useDashboard.ts`:

1. **GET** `/api/credentials?walletAddress={address}` - Fetch experiences
2. **GET** `/api/identity?walletAddress={address}` - Fetch profile
3. **GET** `/api/staking/stats` - Fetch staking statistics
4. **POST** `/api/verification/request` - Request verification
5. **POST** `/api/staking/stake` - Stake resume

## Design System

### Colors
- Primary Gradient: `#667eea` → `#764ba2`
- Background: `#f9fafb`
- Text Primary: `#111827`
- Text Secondary: `#6b7280`
- Success/Verified: `#10b981`

### Responsive Breakpoints
- Mobile: < 768px
- Desktop: >= 1024px (lg: prefix)

## Testing

See `docs/testing/dashboard-testing.md` for testing checklist and results.

## Troubleshooting

### WalletConnect Errors
See `docs/troubleshooting/walletconnect.md` for WalletConnect setup and error resolution.

### Common Issues
- Missing WalletConnect Project ID: Get free ID from https://cloud.walletconnect.com/
- Type errors: Run `npm run typecheck` in frontend directory
- Build errors: Clear `.next` folder and rebuild

