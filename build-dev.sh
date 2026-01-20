#!/bin/bash
# Build script for Flutter with environment variables
# Usage: ./build-dev.sh

echo "🔧 Building Sanchari with development environment variables..."

# Development environment variables
export SUPABASE_URL="https://ajlomqwmsknzbkkuovxw.supabase.co"
export SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFqbG9tcXdtc2tuemJra3Vvdnh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg3MzAwNjIsImV4cCI6MjA4NDMwNjA2Mn0.CF8Ge8in1jgF2HxlBuija0yexVdCgvYh5qp6NtrPfE0"
export SARVAM_API_KEY="sk_d7lugoxa_ymP6eDIIsI2i8dSmPKCdii95"
export API_BASE_URL="http://localhost:3000"

# Run Flutter with dart-define
flutter run \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=SARVAM_API_KEY="$SARVAM_API_KEY" \
  --dart-define=API_BASE_URL="$API_BASE_URL"
