# 🚀 Complete GitHub + Render Deployment Guide

Follow these steps to push your entire repository to GitHub and deploy the backend to Render.

---

## 📋 Part 1: Push Entire Repository to GitHub (5 minutes)

### Step 1: Run the deployment script

Double-click: **`deploy-to-cloud.bat`**

This will:
- Initialize Git repository
- Add all files
- Create initial commit

### Step 2: Create GitHub Repository

1. Go to https://github.com/new
2. **Repository name**: `sanchari`
3. **Visibility**: ✅ **PUBLIC** (required for free Render hosting)
4. ⚠️ **Do NOT** add README, .gitignore, or license (we already have them)
5. Click **"Create repository"**

### Step 3: Connect and Push

After creating the repository, GitHub will show you commands. Run these in PowerShell:

```powershell
cd d:\Sanchari

# Connect to GitHub (replace YOUR_USERNAME with your actual GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/sanchari.git

# Push code
git branch -M main
git push -u origin main
```

**Done!** Your code is now on GitHub: `https://github.com/YOUR_USERNAME/sanchari`

---

## ☁️ Part 2: Deploy Backend to Render (10 minutes)

### Step 1: Sign up on Render

1. Go to https://render.com
2. Click **"Get Started for Free"**
3. **Sign up with GitHub** (this makes connecting easier)
4. Authorize Render to access your repositories

### Step 2: Create Web Service

1. Click **"New +"** button (top right)
2. Select **"Web Service"**
3. Click **"Connect a repository"**
4. Find and select **"sanchari"** from the list
5. Click **"Connect"**

### Step 3: Configure Service Settings

Fill in these settings:

**Basic Settings:**
- **Name**: `sanchari-backend` (or any name you want)
- **Region**: `Singapore` (closest to India for best performance)
- **Branch**: `main`
- **Root Directory**: `backend` ⚠️ **IMPORTANT!**
- **Runtime**: `Node`

**Build & Deploy:**
- **Build Command**: 
  ```
  npm install && npm run build
  ```
- **Start Command**: 
  ```
  npm run start:prod
  ```

**Instance Type:**
- Select **"Free"** (scroll down if needed)

### Step 4: Add Environment Variables

Click **"Advanced"** → Scroll to **"Environment Variables"** → Click **"Add Environment Variable"**

Add each of these (copy values from `backend/.env`):

| Key | Value |
|-----|-------|
| `NODE_ENV` | `production` |
| `PORT` | `3000` |
| `SUPABASE_URL` | Copy from backend/.env |
| `SUPABASE_ANON_KEY` | Copy from backend/.env |
| `GROQ_API_KEY` | Copy from backend/.env |
| `SARVAM_API_KEY` | Copy from backend/.env |
| `PIXABAY_API_KEY` | Copy from backend/.env |

### Step 5: Deploy!

1. Click **"Create Web Service"** at the bottom
2. Wait 5-10 minutes for deployment
3. Watch the logs - you'll see:
   - Building...
   - Installing dependencies...
   - Starting server...
4. When you see "Live", your backend is deployed! 🎉

### Step 6: Copy Your Backend URL

At the top of the page, you'll see your URL:
```
https://sanchari-backend.onrender.com
```

**Copy this URL!** You'll need it in the next step.

---

## 📱 Part 3: Update Flutter App (2 minutes)

### Step 1: Update API Configuration

1. Open: `d:\Sanchari\lib\config\api_config.dart`
2. Find these lines:
   ```dart
   static const String productionUrl = 'https://your-app-name.onrender.com';
   static const bool useProduction = false;
   ```
3. Change to (use YOUR actual Render URL):
   ```dart
   static const String productionUrl = 'https://sanchari-backend.onrender.com';
   static const bool useProduction = true;
   ```
4. Save the file

### Step 2: Commit Changes

```powershell
cd d:\Sanchari
git add .
git commit -m "Update to production backend URL"
git push
```

---

## 📦 Part 4: Build & Install APK (10 minutes)

### Build APK

```powershell
cd d:\Sanchari
flutter build apk --release
```

Wait 5-10 minutes. APK will be at:
```
d:\Sanchari\build\app\outputs\flutter-apk\app-release.apk
```

### Install on Mobile (Choose one method)

**Method 1: WhatsApp/Telegram** (Easiest)
1. Send `app-release.apk` to yourself
2. Download on phone
3. Tap to install
4. Enable "Install from unknown sources" if asked

**Method 2: Google Drive**
1. Upload APK to Google Drive
2. Download from phone
3. Install

**Method 3: USB Cable**
```powershell
# Connect phone via USB with USB debugging enabled
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## ✅ Testing Your App

1. Open Sanchari on your phone
2. **Wait 30 seconds on first load** (Render free tier wakes from sleep)
3. Login with your account
4. Search "Jaipur" → Generate trip
5. Should work perfectly! 🎉

**Your app now works WITHOUT your laptop running!**

---

## 🔄 Future Updates

### Update Backend Code:

```powershell
cd d:\Sanchari\backend
# Make your changes
git add .
git commit -m "Updated backend logic"
git push
```

Render automatically redeploys! (takes 5 min)

### Update Flutter App:

```powershell
cd d:\Sanchari
# Make your changes
flutter build apk --release
# Reinstall APK on phone
```

---

## ⚠️ Important Notes

### Free Tier Limitations

**Render.com Free:**
- ✅ FREE forever
- ⚠️ Sleeps after 15 min inactivity
- ⚠️ First request takes ~30 seconds (waking up)
- ✅ Auto-deploy on git push

**Solutions:**
1. **Free Keep-Awake**: https://uptimerobot.com (pings every 10 min)
2. **Paid Always-On**: $7/month on Render

### Troubleshooting

**"Network Error" on first app load:**
- Normal! Wait 30 seconds (backend waking up)
- Subsequent requests will be fast

**Backend shows errors on Render:**
- Check Render Dashboard → Logs tab
- Verify all environment variables are set
- Make sure Root Directory = `backend`

**APK won't install:**
- Enable "Install from unknown sources"
- Settings → Security → Unknown Sources

---

## 💰 Cost Breakdown

| Service | Cost |
|---------|------|
| GitHub | FREE |
| Render.com | FREE |
| Domain (optional) | $10/year |
| **TOTAL** | **$0** 🎉 |

---

## 🎉 Congratulations!

You now have:
- ✅ Code on GitHub (version controlled)
- ✅ Backend running 24/7 in cloud
- ✅ Mobile app working independently
- ✅ Free hosting with auto-deploy

**No laptop needed anymore!** 🚀

---

## 📞 Need Help?

**Check Render Logs:**
1. Go to Render dashboard
2. Click your service
3. Click "Logs" tab

**Check if backend is running:**
- Open in browser: https://your-app-name.onrender.com
- Should see: "Sanchari Backend is running"

**Still stuck?** Check the error in Render logs for specific issues.
