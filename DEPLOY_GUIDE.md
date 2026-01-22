# Sanchari Backend Deployment Guide

## Deploy to Render (Free Cloud Hosting)

### 1. Push Backend to GitHub

```bash
# Navigate to backend folder
cd d:\Sanchari\backend

# Initialize git (if not already)
git init
git add .
git commit -m "Initial backend commit"

# Create repository on GitHub and push
git remote add origin https://github.com/YOUR_USERNAME/sanchari-backend.git
git branch -M main
git push -u origin main
```

### 2. Deploy on Render

1. Go to https://render.com and sign up
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository
4. Use these settings:
   - **Name**: `sanchari-backend`
   - **Region**: Singapore (closest to India)
   - **Branch**: `main`
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm run start:prod`

5. Add Environment Variables (click "Advanced" → "Add Environment Variable"):
   ```
   NODE_ENV=production
   PORT=3000
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GROQ_API_KEY=your_groq_api_key
   SARVAM_API_KEY=your_sarvam_api_key
   PIXABAY_API_KEY=your_pixabay_api_key
   ```

6. Click **"Create Web Service"**

### 3. Your Backend URL

After deployment (5-10 minutes), you'll get a URL like:
```
https://sanchari-backend.onrender.com
```

### 4. Update Flutter App

Update `lib/services/trip_api_service.dart`:
```dart
static const String baseUrl = 'https://sanchari-backend.onrender.com';
```

### 5. Build APK

```bash
cd d:\Sanchari
flutter build apk --release
```

### 6. Install on Mobile

APK location: `d:\Sanchari\build\app\outputs\flutter-apk\app-release.apk`

Share this file to your phone via:
- WhatsApp/Telegram
- Google Drive
- AirDrop

## Alternative: Deploy to Railway.app

Even easier! One-click deployment:

1. Go to https://railway.app
2. Click "Start a New Project"
3. Choose "Deploy from GitHub repo"
4. Select your backend repo
5. Add environment variables
6. Done! Get your URL

## Important Notes

- **Free Tier Limits**: Render free tier sleeps after 15 min of inactivity. First request after sleep takes ~30 seconds.
- **Always-On Alternative**: Use Railway ($5/month) or Heroku for production.
- **No Laptop Needed**: Once deployed, your mobile app works independently!
