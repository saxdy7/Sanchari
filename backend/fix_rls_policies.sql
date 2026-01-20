-- FIX: RLS Policy for Users table
-- Run this in Supabase SQL Editor to fix the signup issue

-- First, drop existing policies on users table
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;

-- Create new policies that work with Supabase auth
-- Allow users to insert their own profile during signup
CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (auth.uid()::text = supabase_id::text);

-- Allow users to view their own profile
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid()::text = supabase_id::text);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid()::text = supabase_id::text);

-- Alternative: For easier testing, you can temporarily allow all inserts
-- UNCOMMENT the line below if still having issues:
-- CREATE POLICY "Allow all inserts for testing" ON users FOR INSERT WITH CHECK (true);
