# Dashboard Testing Guide

## Test Checklist

### 1. Initial Load
- [ ] Navigate to `http://localhost:3000/dashboard`
- [ ] Check if page loads without errors
- [ ] Verify loading spinner appears briefly

### 2. Wallet Connection
- [ ] If wallet not connected, should see "Connect Your Wallet" message
- [ ] Click "Connect Wallet" button
- [ ] Verify wallet connection modal appears
- [ ] Connect a wallet (MetaMask, WalletConnect, etc.)

### 3. Dashboard Display (After Wallet Connection)
- [ ] Profile card displays on the left side
- [ ] Action cards display on the right side
- [ ] Top navigation with logo and search

### 4. Request Verification Flow
- [ ] Click "Request Verification" button
- [ ] Modal should open
- [ ] Verify modal displays list of experiences
- [ ] Click "Request" button on an unverified experience
- [ ] Verify toast notification appears
- [ ] Modal should close automatically

### 5. Staking Flow
- [ ] Click "Stake & Earn" button
- [ ] Verify toast notification appears
- [ ] Check staking stats display

### 6. Update Profile
- [ ] Click "Update Profile" button
- [ ] Verify toast notification appears

### 7. Responsive Design
- [ ] Resize browser window to mobile size (< 768px)
- [ ] Verify layout switches to single column
- [ ] Check that all components are readable

## Expected Behavior

- Loading state: Brief spinner on initial load
- Without wallet: Shows connect wallet prompt
- With wallet: Full dashboard with mock data
- Toasts: Success/error/info notifications appear top-right
- Modal: Opens and closes smoothly

## Success Criteria

✅ All components render correctly
✅ No console errors
✅ Toast notifications work
✅ Modal opens and closes properly
✅ Responsive design works
✅ Wallet connection flow works
✅ All interactions trigger appropriate feedback

