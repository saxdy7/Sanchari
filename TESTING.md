# Testing Checklist for Sanchari

## ✅ Step 1: Start Backend Server

**Terminal 1** (Keep this open!):
```powershell
cd d:\Sanchari\backend
npm run start:dev
```

**Wait for this message:**
```
[Nest] LOG [NestApplication] Nest application successfully started
Backend running on http://localhost:3000
```

✅ **Test backend is working:**
Open browser: http://localhost:3000/trip/plan?destination=Jaipur&days=2&preferences=

**Expected:** JSON response with trip data

---

## ✅ Step 2: Start Flutter App

**Terminal 2** (Keep this open!):
```powershell
cd d:\Sanchari  
flutter run -d chrome
```

**Expected:** Browser opens with Sanchari app

---

## ✅ Step 3: Test Trip Generation

### Test Case 1: Jaipur (2 days)
1. Login to the app
2. Click **+ button** (bottom center)
3. Click **"Plan a Trip"**
4. Search: **"Jaipur"**
5. Select Jaipur from results
6. Click **"Let's Go"**
7. Select preferences (optional)
8. Select **2 days**
9. Click **"Create Trip"**

**Expected Result:**
- Map with 8 markers
- Day 1 (4 places): Hawa Mahal, Amber Fort, City Palace, Nahargarh Fort
- Day 2 (4 places): Jal Mahal, Albert Hall Museum, Jantar Mantar, Birla Mandir
- Wikipedia description and image of Jaipur

### Test Case 2: Manali (3 days)
Repeat flow with **"Manali"** and **3 days**

**Expected:** 8 places split across 3 days

### Test Case 3: Goa (2 days)  
Repeat flow with **"Goa"** and **2 days**

**Expected:** Beaches and forts

---

## 🐛 Troubleshooting

### "Connection error. Make sure backend is running."
- ❌ Backend not started
- ✅ Go to Terminal 1, run backend command
- ✅ Refresh Flutter app

### "Failed to generate trip"
- ⚠️ Overpass API timeout (normal)
- ✅ Click **"Retry"** button
- ✅ Fallback data should load

### Nothing shows in app
- ✅ Hard refresh: `Ctrl + Shift + R`
- ✅ Check browser console (F12) for errors
- ✅ Restart Flutter: Press `R` in Terminal 2

### Backend shows errors
- ✅ Check Terminal 1 for error messages
- ✅ Make sure you're in `d:\Sanchari\backend` folder
- ✅ Try: `npm install` then `npm run start:dev`

---

## ✅ Step 4: Test Profile Screen

1. Click **Profile tab** (person icon, bottom right)
2. Check your name and email appear
3. Click **Log Out**  
4. Should return to Login screen

---

## 📋 Test Completion Checklist

- [ ] Backend starts without errors
- [ ] Backend API returns JSON (browser test)
- [ ] Flutter app loads and shows login
- [ ] Can login successfully
- [ ] Home screen shows travel guides
- [ ] + button opens "New Trip" modal
- [ ] Destination search shows results
- [ ] Trip generation works for Jaipur
- [ ] Map displays with markers
- [ ] Day-wise itinerary shows place details
- [ ] Profile screen shows user info
- [ ] Logout works

---

## 🎯 Success Criteria

**100% Working:**
- ✅ All 12 items in checklist pass
- ✅ At least 2 cities tested successfully
- ✅ No console errors in browser

**Report any failures here:**
- Screenshot the error
- Copy console logs (F12 → Console)
- Note which step failed

---

**Last Updated:** 2026-01-18 19:26 IST
