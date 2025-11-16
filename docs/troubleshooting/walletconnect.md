# WalletConnect Setup & Troubleshooting

## Error: Connection interrupted while trying to subscribe

This error occurs when WalletConnect Project ID is missing or invalid.

## Solution

### Get a Free WalletConnect Project ID

1. Visit https://cloud.walletconnect.com/
2. Sign up for a free account
3. Create a new project
4. Copy your Project ID (32 character hex string)

### Update Environment Variables

Add to `frontend/.env.local`:
```env
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your-actual-project-id-here
```

### Restart Dev Server

```bash
# Stop server (Ctrl+C)
cd frontend
npm run dev
```

## Quick Fix (For Testing)

The app now handles WalletConnect errors gracefully:
- Error is suppressed in console
- App continues to work
- Wallet connection shows warnings but doesn't crash
- All UI components render correctly

**Just refresh your browser** - the error should be suppressed.

## Verification

After setting up:
1. Hard refresh browser: `Ctrl+Shift+R`
2. Navigate to dashboard
3. Error should be gone
4. Wallet connection should work

## Notes

- Project ID is required for production
- For development/testing, the app works without it (with warnings)
- Dashboard UI works perfectly even without wallet connection

