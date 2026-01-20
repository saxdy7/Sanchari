# Sanchari - Quick Start Guide

## 🚀 Start the Application

### Step 1: Start Backend Server
Open **PowerShell/Terminal 1**:
```powershell
cd d:\Sanchari\backend
npm run start:dev
```
✅ Wait for: `Backend running on http://localhost:3000`

### Step 2: Start Flutter App  
Open **PowerShell/Terminal 2**:
```powershell
cd d:\Sanchari
flutter run -d chrome
```

### Step 3: Test the App
1. **Login** with your credentials
2. Click **+ button** → **Plan a Trip**
3. **Search** for "Jaipur"
4. Select preferences and duration
5. **View your trip!** 🎉

---

## ✅ What Works

- **Backend**: Trip generation API with Wikipedia data
- **Frontend**: Complete trip planning flow  
- **Cities**: Jaipur, Manali, Goa, Udaipur, Kasol (with fallback data)
- **Auth**: Supabase authentication
- **Profile**: User settings and logout

---

## 🐛 If Issues Occur

**"Connection error"** → Backend not running
- Start backend: `cd d:\Sanchari\backend && npm run start:dev`

**"Failed to generate trip"** → API timeout
- Click **Retry** button
- Overpass API sometimes times out (fallback data will be used)

**Blank screen** → Hard refresh
- Press `Ctrl + Shift + R` in browser
- Or restart: `flutter run -d chrome`

---

## 📁 Helper Scripts

**Easy start**: Double-click these files in `d:\Sanchari\`:
- `start-backend.bat` - Starts backend server
- `start-app.bat` - Starts Flutter app

---

## 🔑 Test Credentials

Create account or use existing Supabase user:
- Email: your-email@example.com
- Password: your-password

---

**Need help?** Check `walkthrough.md` for detailed docs!
