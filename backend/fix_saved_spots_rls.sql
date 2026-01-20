-- FIX: RLS Policy for saved_spots table
-- Run this in Supabase SQL Editor to allow users to view their saved spots

-- Drop ALL existing policies first to avoid conflicts
DROP POLICY IF EXISTS "Users can save spots" ON saved_spots;
DROP POLICY IF EXISTS "Users can view own saved spots" ON saved_spots;
DROP POLICY IF EXISTS "Users can insert own saved spots" ON saved_spots;
DROP POLICY IF EXISTS "Users can delete own saved spots" ON saved_spots;

-- Allow users to view their own saved spots
CREATE POLICY "Users can view own saved spots" ON saved_spots
    FOR SELECT USING (auth.uid()::text = user_id::text);

-- Allow users to save spots (re-create the INSERT policy)
CREATE POLICY "Users can insert own saved spots" ON saved_spots
    FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- Allow users to delete their own saved spots
CREATE POLICY "Users can delete own saved spots" ON saved_spots
    FOR DELETE USING (auth.uid()::text = user_id::text);
