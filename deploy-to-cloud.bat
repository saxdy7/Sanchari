@echo off
echo ================================================================
echo   SANCHARI - Push to GitHub and Deploy to Render
echo ================================================================
echo.

cd /d d:\Sanchari

echo Step 1: Checking Git status...
if not exist ".git" (
    echo Initializing Git repository...
    git init
    echo Git repository initialized!
) else (
    echo Git repository already exists.
)

echo.
echo Step 2: Adding all files to Git...
git add .

echo.
echo Step 3: Creating commit...
git commit -m "Complete Sanchari app - Backend and Flutter"

echo.
echo ================================================================
echo   MANUAL STEPS - Follow these instructions:
echo ================================================================
echo.
echo 1. CREATE GITHUB REPOSITORY
echo    - Go to: https://github.com/new
echo    - Repository name: sanchari
echo    - Visibility: PUBLIC (required for free Render hosting)
echo    - Do NOT add README, .gitignore, or license
echo    - Click "Create repository"
echo.
echo 2. PUSH TO GITHUB
echo    After creating the repo, run these commands:
echo.
echo    git remote add origin https://github.com/YOUR_USERNAME/sanchari.git
echo    git branch -M main
echo    git push -u origin main
echo.
echo 3. DEPLOY BACKEND ON RENDER
echo    - Go to: https://render.com
echo    - Sign in with GitHub
echo    - Click "New +" -^> "Web Service"
echo    - Select your "sanchari" repository
echo    - Root Directory: backend
echo    - Build Command: npm install ^&^& npm run build
echo    - Start Command: npm run start:prod
echo    - Add Environment Variables:
echo        NODE_ENV=production
echo        PORT=3000
echo        SUPABASE_URL=your_value
echo        SUPABASE_ANON_KEY=your_value
echo        GROQ_API_KEY=your_value
echo        SARVAM_API_KEY=your_value
echo        PIXABAY_API_KEY=your_value
echo    - Click "Create Web Service"
echo.
echo 4. UPDATE FLUTTER APP
echo    After deployment, copy your Render URL:
echo    https://your-app-name.onrender.com
echo.
echo    Open: lib/config/api_config.dart
echo    Update:
echo      static const String productionUrl = 'https://your-app-name.onrender.com';
echo      static const bool useProduction = true;
echo.
echo 5. BUILD APK
echo    flutter build apk --release
echo.
echo    APK location:
echo    build/app/outputs/flutter-apk/app-release.apk
echo.
echo ================================================================
pause
