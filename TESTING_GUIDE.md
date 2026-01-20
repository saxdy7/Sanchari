# Quick Testing Guide 🧪

## Testing Real-Time Updates + Comprehensive Place Info

### 1. Start Backend Server
```bash
cd backend
npm start
```

**Expected Output**:
```
✅ Backend running on http://localhost:3000
🔒 CORS enabled
[Nest] LOG [RouterExplorer] Mapped {/trip/place-info, GET} route
```

---

### 2. Test API Endpoint Manually

#### Test Wikipedia + Pixabay + AI (Chennai)
```bash
curl "http://localhost:3000/trip/place-info?name=Chennai&city=Tamil+Nadu"
```

**Expected Response**:
```json
{
  "title": "Chennai",
  "description": "Chennai is the capital...\n\nChennai has been a major cultural centre...",
  "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/3/32/Chennai_Central.jpg",
  "pageUrl": "https://en.wikipedia.org/wiki/Chennai",
  "source": "wikipedia"
}
```

#### Test Pixabay Fallback (Unknown Place)
```bash
curl "http://localhost:3000/trip/place-info?name=Kasol&city=Himachal+Pradesh"
```

**Expected**: `source: "pixabay"` if Wikipedia has no image

---

### 3. Test in Flutter App

#### Test Real-Time Updates:
1. **Launch App**: `flutter run`
2. **Navigate**: Home → My Spots
3. **Search**: Tap search icon → Type "Chennai"
4. **Save**: Click bookmark icon on Chennai
5. **Watch**: 
   - Loading: "Fetching comprehensive info..."
   - Success: "Chennai saved with wikipedia! ✅"
   - **Auto-refresh**: Spot appears in My Spots < 2 seconds ⚡

#### Test Multi-Device Sync:
1. **Device 1**: Open app, login as user A
2. **Device 2**: Open app, login as user A
3. **Device 1**: Save a spot (e.g., "Jaipur")
4. **Device 2**: Watch My Spots screen
5. **Result**: New spot appears automatically! 🎉

---

### 4. Verify Data in Supabase

#### Check Spot Details:
```sql
SELECT 
  s.name,
  s.image_url,
  s.description,
  LENGTH(s.description) as desc_length
FROM spots s
WHERE s.name = 'Chennai'
ORDER BY s.created_at DESC
LIMIT 1;
```

**Expected**:
- `image_url`: Not null (Wikipedia or Pixabay URL)
- `desc_length`: > 500 characters (Wikipedia + AI combined)

#### Check Real-Time Subscription:
```sql
-- Enable real-time for saved_spots table
ALTER PUBLICATION supabase_realtime ADD TABLE saved_spots;

-- Verify table is in publication
SELECT * FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime';
```

---

### 5. Test Error Scenarios

#### Test Network Failure:
1. Stop backend server
2. Try to save a spot
3. **Expected**: Error message shown, no crash

#### Test Missing API Keys:
1. Remove `SARVAM_API_KEY` from `.env`
2. Restart backend
3. Save a spot
4. **Expected**: Saves with Wikipedia description only (no AI)

#### Test Widget Navigation:
1. Search for "Mumbai"
2. Click save
3. **Immediately** press back button (navigate away)
4. **Expected**: No "unmounted widget" error ✅

---

### 6. Performance Testing

#### Measure Real-Time Latency:
```dart
// Add to saved_spots_screen.dart temporarily
debugPrint('⏱️ Spot saved at: ${DateTime.now()}');

// When new spot appears:
debugPrint('⏱️ Spot displayed at: ${DateTime.now()}');
```

**Target**: < 2 seconds from save to display

#### Measure API Response Time:
```bash
# Use curl with timing
curl -w "@curl-format.txt" -o /dev/null -s \
  "http://localhost:3000/trip/place-info?name=Delhi&city=India"
```

Create `curl-format.txt`:
```
time_total: %{time_total}s
```

**Target**: < 3 seconds total

---

### 7. Visual Verification

#### Check Images:
- **Wikipedia source**: Should be authentic place photos
- **Pixabay source**: High-quality travel photos
- **Fallback**: Generic placeholder (rare)

#### Check Descriptions:
Open spot details and verify:
- ✅ Short Wikipedia extract (1-2 sentences)
- ✅ Line break (`\n\n`)
- ✅ AI historical context (3-4 sentences)
- ✅ Total length: 300-800 characters

---

### 8. Console Log Verification

#### Backend Logs to Watch:
```
📍 Fetching comprehensive place info for: Chennai in Tamil Nadu
✅ Found Wikipedia info for Chennai
🤖 Fetching AI historical description for Chennai, Tamil Nadu
✅ Got AI description for Chennai (245 chars)
✅ Comprehensive info gathered for Chennai
```

#### Frontend Logs to Watch:
```
🖼️ Fetching comprehensive data for Chennai
✅ Image from wikipedia: https://upload.wikimedia.org/...
✅ Description length: 523 chars
🔍 Initial load: 0 spots
🔄 Real-time update detected: INSERT
✅ Refreshed: 1 spots
✅ Spot saved with Wikipedia data and provider invalidated
```

---

### 9. Known Good Test Cases

| Location | Expected Image Source | Expected Description |
|----------|----------------------|---------------------|
| Chennai | Wikipedia | ✅ Combined |
| Jaipur | Wikipedia | ✅ Combined |
| Kasol | Pixabay (maybe) | ✅ Combined |
| Hyderabad | Wikipedia | ✅ Combined |
| Varanasi | Wikipedia | ✅ Combined |

---

### 10. Troubleshooting

#### Real-Time Not Working?
**Check**:
1. Supabase real-time enabled in dashboard
2. RLS policies allow SELECT for user
3. Flutter app subscribed to channel (check logs)

**Fix**:
```sql
-- Run in Supabase SQL Editor
ALTER PUBLICATION supabase_realtime ADD TABLE saved_spots;
```

#### No Images?
**Check**:
1. Wikipedia API working (try manual curl)
2. Pixabay API key in `.env`
3. Network connectivity

**Debug**:
```typescript
// Add to trip-planner.service.ts temporarily
console.log('Wikipedia response:', wikiInfo);
console.log('Pixabay response:', pixabayImage);
```

#### No AI Descriptions?
**Check**:
1. `SARVAM_API_KEY` in `.env`
2. Sarvam API quota not exceeded
3. Network connectivity

**Debug**:
```typescript
// Add to sarvam.service.ts
console.log('Sarvam request:', prompt);
console.log('Sarvam response:', response.data);
```

---

## ✅ Success Criteria

- [ ] Backend starts without errors
- [ ] API returns comprehensive data (image + description)
- [ ] Spots save successfully
- [ ] Real-time updates work (< 2 sec)
- [ ] Images display correctly (Wikipedia or Pixabay)
- [ ] Descriptions are rich (Wikipedia + AI)
- [ ] No "unmounted widget" errors
- [ ] Multi-device sync works
- [ ] Error handling graceful

---

## 📸 Expected Screenshots

### 1. Loading State
<img src="..." alt="Loading: Fetching comprehensive info..." />

### 2. Success Message
<img src="..." alt="Chennai saved with wikipedia! ✅" />

### 3. Spot with Real Image
<img src="..." alt="Chennai with Wikipedia image + AI description" />

### 4. Real-Time Update
<img src="..." alt="Spot appears instantly in My Spots" />

---

## 🎯 Quick Smoke Test (2 minutes)

```bash
# Terminal 1: Start backend
cd backend && npm start

# Terminal 2: Run Flutter app
cd .. && flutter run

# In app:
1. Go to My Spots
2. Tap search icon
3. Type "Chennai"
4. Tap bookmark on Chennai
5. Wait < 2 seconds
6. ✅ See Chennai in My Spots with real image!
```

---

## 📝 Test Report Template

```
Date: _____________
Tester: _____________

[ ] Backend starts successfully
[ ] API endpoint returns data
[ ] Images load (Wikipedia or Pixabay)
[ ] Descriptions are comprehensive
[ ] Real-time updates work
[ ] Multi-device sync works
[ ] No errors in console
[ ] Performance < 2 sec

Issues Found:
1. _________________________
2. _________________________
3. _________________________

Notes:
_________________________
_________________________
```

---

## 🚀 Production Readiness

Before deploying:
- [ ] All tests pass
- [ ] API keys secured (not in git)
- [ ] Error logging configured
- [ ] Performance benchmarks met
- [ ] User acceptance testing done

---

Happy Testing! 🎉
