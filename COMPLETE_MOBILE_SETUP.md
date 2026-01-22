# 📱 Complete Setup Guide - Use App Without Laptop

## ✅ What You'll Achieve:
- Install app on your mobile phone
- Backend runs in cloud (24/7 available)
- NO laptop/computer needed after setup
- Works anywhere with internet

---

## 🚀 Step-by-Step Guide

### 📋 Prerequisites:
1. GitHub account (free)
2. Render account (free - no credit card needed)

---

### Part 1: Deploy Backend to Cloud (One-Time Setup)

#### Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `sanchari-backend`
3. Make it **PUBLIC** (required for free Render hosting)
4. Click "Create repository"

#### Step 2: Push Backend Code to GitHub

Open PowerShell in VS Code and run:

```powershell
# Navigate to backend folder
cd d:\Sanchari\backend

# Initialize git (if not done)
git init

# Create .gitignore
"node_modules/
.env
dist/
*.log" | Out-File -FilePath .gitignore -Encoding utf8

# Add and commit
git add .
git commit -m "Initial backend deployment"

# Connect to GitHub (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/sanchari-backend.git
git branch -M main
git push -u origin main
```

#### Step 3: Deploy on Render

1. **Sign up on Render:**
   - Go to https://render.com
   - Click "Get Started for Free"
   - Sign up with GitHub

2. **Create Web Service:**
   - Click "New +" → "Web Service"
   - Click "Connect a repository"
   - Select `sanchari-backend` from the list
   
3. **Configure Service:**
   - **Name**: `sanchari-backend` (or any name you want)
   - **Region**: Singapore (closest to India)
   - **Branch**: `main`
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm run start:prod`

4. **Add Environment Variables:**
   
   Click "Advanced" → "Add Environment Variable" and add these:

   ```
   NODE_ENV = production
   PORT = 3000
   ```

   Copy these from your `backend/.env` file:
   ```
   SUPABASE_URL = (your supabase URL)
   SUPABASE_ANON_KEY = (your supabase anon key)
   GROQ_API_KEY = (your groq API key)
   SARVAM_API_KEY = (your sarvam API key)
   PIXABAY_API_KEY = (your pixabay API key)
   ```

5. **Deploy:**
   - Click "Create Web Service"
   - Wait 5-10 minutes for deployment
   - You'll get a URL like: `https://sanchari-backend.onrender.com`

---

### Part 2: Update Flutter App with Cloud URL

#### Step 1: Update API Configuration

Open `d:\Sanchari\lib\config\api_config.dart` and change:

```dart
// Replace with YOUR Render URL
static const String productionUrl = 'https://sanchari-backend.onrender.com';

// Set to true to use cloud backend
static const bool useProduction = true;
```

#### Step 2: Build APK

```powershell
# Navigate to project root
cd d:\Sanchari

# Build release APK
flutter build apk --release
```

Wait 5-10 minutes. APK will be created at:
```
d:\Sanchari\build\app\outputs\flutter-apk\app-release.apk
```

---

### Part 3: Install on Mobile (NO CABLE NEEDED)

#### Option A: Share via WhatsApp/Telegram

1. Find APK file: `d:\Sanchari\build\app\outputs\flutter-apk\app-release.apk`
2. Send to yourself on WhatsApp/Telegram
3. Open on phone → Download → Install
4. If blocked, go to Settings → Security → Enable "Install from unknown sources"

#### Option B: Google Drive

1. Upload `app-release.apk` to Google Drive
2. Open Drive on your phone
3. Download and install

#### Option C: Direct Link (Advanced)

1. Upload APK to file hosting (dropbox.com, wetransfer.com)
2. Get download link
3. Open link on phone
4. Install

---

## 🎉 Done! Now Your App Works Independently!

### Testing:

1. Open Sanchari app on your phone
2. Login with your account
3. Search for a destination (e.g., "Jaipur")
4. Generate trip
5. Should work WITHOUT laptop running!

---

## ⚠️ Important Notes

### Free Tier Limitations:

**Render.com Free Tier:**
- ✅ FREE forever
- ⚠️ Sleeps after 15 min of inactivity
- ⚠️ First request after sleep takes ~30 seconds
- ✅ Good for personal use and testing

**Solutions:**
1. **Keep it awake** (free): Use https://uptimerobot.com to ping your backend every 10 minutes
2. **Upgrade**: Pay $7/month on Render for always-on service
3. **Alternative**: Use Railway.app ($5/month) - no sleep

### Troubleshooting:

**App shows "Network Error":**
- Check your internet connection
- Wait 30 seconds (backend might be waking up)
- Verify production URL in `api_config.dart`

**Backend not responding:**
- Check Render dashboard for errors
- Verify environment variables are set correctly
- Check logs on Render dashboard

---

## 🔄 Future Updates

When you update backend code:

```powershell
cd d:\Sanchari\backend
git add .
git commit -m "Update description"
git push
```

Render will automatically redeploy!

---

## 💰 Cost Summary

- GitHub: FREE
- Render.com: FREE (with sleep)
- Domain name (optional): $10/year
- **Total: $0** 🎉

---

## 📞 Need Help?

Check Render logs:
1. Go to Render dashboard
2. Click your service
3. Click "Logs" tab
4. Look for errors
