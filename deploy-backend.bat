@echo off
echo ========================================
echo   Sanchari Backend - Cloud Deployment
echo ========================================
echo.

echo Step 1: Check if git is initialized...
cd backend
if not exist ".git" (
    echo Initializing git repository...
    git init
    echo Created .gitignore for security...
    echo node_modules/ > .gitignore
    echo .env >> .gitignore
    echo dist/ >> .gitignore
)

echo.
echo Step 2: Add files to git...
git add .
git commit -m "Prepare backend for cloud deployment"

echo.
echo ========================================
echo   Next Steps (Manual):
echo ========================================
echo.
echo 1. Create GitHub repository:
echo    - Go to https://github.com/new
echo    - Name: sanchari-backend
echo    - Keep it PUBLIC (for free Render hosting)
echo.
echo 2. Push to GitHub:
echo    git remote add origin https://github.com/YOUR_USERNAME/sanchari-backend.git
echo    git branch -M main
echo    git push -u origin main
echo.
echo 3. Deploy on Render.com:
echo    - Visit: https://render.com
echo    - Click "New +" -^> "Web Service"
echo    - Connect your GitHub repo
echo    - Use these settings:
echo      * Build Command: npm install ^&^& npm run build
echo      * Start Command: npm run start:prod
echo.
echo 4. Add Environment Variables on Render:
echo    - NODE_ENV=production
echo    - PORT=3000
echo    - Copy from your .env file:
echo      * SUPABASE_URL
echo      * SUPABASE_ANON_KEY
echo      * GROQ_API_KEY
echo      * SARVAM_API_KEY
echo      * PIXABAY_API_KEY
echo.
echo 5. After deployment, you'll get a URL like:
echo    https://sanchari-backend.onrender.com
echo.
echo 6. Update Flutter app with this URL in:
echo    lib/services/trip_api_service.dart
echo.
echo ========================================
pause
