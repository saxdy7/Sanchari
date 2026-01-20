# 🖼️ Unsplash API Setup (FREE)

## Why Dual Image Sources?
- **Wikipedia**: Historical accuracy, but limited images
- **Unsplash**: High-quality travel photos, better coverage
- **Both run in parallel** = Faster results! ⚡

## How It Works
```
Trip Generation
    │
    ├── Wikipedia (fetches images)
    │   └── 5 seconds timeout
    │
    └── Unsplash (fetches images)
        └── 5 seconds timeout
        
Both run simultaneously!
Winner gets used first, loser provides backup.
```

## Get FREE Unsplash API Key (2 minutes)

### Step 1: Create Account
1. Go to: https://unsplash.com
2. Click "Sign up" (top-right)
3. Use email or Google account

### Step 2: Create Application
1. Go to: https://unsplash.com/oauth/applications
2. Click **"New Application"**
3. Check all guidelines checkboxes
4. Fill in:
   - **Application name**: `Sanchari Travel App`
   - **Description**: `Trip planning app for Indian destinations`
   - **Website/App URL**: `http://localhost:3000` (for development)

### Step 3: Get Access Key
1. After creating app, you'll see **"Access Key"**
2. Copy the key (looks like: `abc123xyz456...`)
3. Add to backend `.env` file:
```env
UNSPLASH_ACCESS_KEY=your_access_key_here
```

### Step 4: Restart Backend
```bash
cd backend
npm start
```

## Free Tier Limits
- **50 requests/hour** (Development)
- **50,000 requests/month** (Production - request increase)
- Perfect for testing!

## Testing
Search for "Jaipur 2 days" - you'll now get:
- Wikipedia images for historical places
- Beautiful Unsplash photos as backup
- **Much faster** than Wikipedia alone! ⚡

## Without Unsplash Key?
App still works! Falls back to:
1. Wikipedia only
2. Graceful degradation (no errors)
