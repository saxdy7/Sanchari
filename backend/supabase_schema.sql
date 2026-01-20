-- Supabase SQL Schema for Sanchari
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===== USERS TABLE =====
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supabase_id UUID UNIQUE NOT NULL,
    email TEXT UNIQUE,
    name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== TRIPS TABLE =====
CREATE TYPE trip_status AS ENUM ('PLANNED', 'ONGOING', 'COMPLETED');

CREATE TABLE IF NOT EXISTS trips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    destination TEXT NOT NULL,
    state TEXT,
    days INTEGER NOT NULL,
    start_date DATE,
    end_date DATE,
    preferences TEXT[] DEFAULT '{}',
    status trip_status DEFAULT 'PLANNED',
    share_code TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_trips_user_id ON trips(user_id);
CREATE INDEX idx_trips_share_code ON trips(share_code);

-- ===== ITINERARY DAYS TABLE =====
CREATE TABLE IF NOT EXISTS itinerary_days (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID REFERENCES trips(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL,
    date DATE,
    UNIQUE(trip_id, day_number)
);

-- ===== SPOTS TABLE =====
CREATE TYPE spot_category AS ENUM (
    'ATTRACTION', 'CAFE', 'RESTAURANT', 'ENTERTAINMENT', 
    'SHOPPING', 'NATURE', 'HISTORY', 'MUSEUM', 'OTHER'
);

CREATE TABLE IF NOT EXISTS spots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    category spot_category DEFAULT 'OTHER',
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    image_url TEXT,
    source TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_spots_city ON spots(city);
CREATE INDEX idx_spots_category ON spots(category);

-- ===== ITINERARY ITEMS TABLE =====
CREATE TABLE IF NOT EXISTS itinerary_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    day_id UUID REFERENCES itinerary_days(id) ON DELETE CASCADE,
    spot_id UUID REFERENCES spots(id),
    place_name TEXT NOT NULL,
    category spot_category DEFAULT 'OTHER',
    description TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    order_index INTEGER NOT NULL,
    duration TEXT,
    distance TEXT,
    travel_time TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== SAVED SPOTS TABLE =====
CREATE TABLE IF NOT EXISTS saved_spots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    spot_id UUID REFERENCES spots(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, spot_id)
);

-- ===== SEARCH LOGS (Analytics) =====
CREATE TABLE IF NOT EXISTS search_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    query TEXT NOT NULL,
    destination TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_search_logs_destination ON search_logs(destination);
CREATE INDEX idx_search_logs_created_at ON search_logs(created_at);

-- ===== GUIDE VIEWS (Analytics) =====
CREATE TABLE IF NOT EXISTS guide_views (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    guide_name TEXT NOT NULL,
    destination TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_guide_views_destination ON guide_views(destination);
CREATE INDEX idx_guide_views_created_at ON guide_views(created_at);

-- ===== TRAVEL GUIDES (Pre-defined templates) =====
CREATE TABLE IF NOT EXISTS travel_guides (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    destination TEXT NOT NULL,
    state TEXT NOT NULL,
    days INTEGER NOT NULL,
    spots_count INTEGER NOT NULL,
    description TEXT,
    image_url TEXT,
    is_popular BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_travel_guides_destination ON travel_guides(destination);
CREATE INDEX idx_travel_guides_is_popular ON travel_guides(is_popular);

-- ===== RLS (Row Level Security) =====
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_spots ENABLE ROW LEVEL SECURITY;
ALTER TABLE search_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_views ENABLE ROW LEVEL SECURITY;

-- Users can only see their own data
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = supabase_id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = supabase_id);

-- Users can view and manage their own trips
CREATE POLICY "Users can view own trips" ON trips
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can create trips" ON trips
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update own trips" ON trips
    FOR UPDATE USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own trips" ON trips
    FOR DELETE USING (auth.uid()::text = user_id::text);

-- Allow viewing shared trips via share_code
CREATE POLICY "Anyone can view shared trips" ON trips
    FOR SELECT USING (share_code IS NOT NULL);

-- Spots are publicly viewable
ALTER TABLE spots ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Spots are viewable by everyone" ON spots
    FOR SELECT USING (true);

-- Allow authenticated users to create spots
CREATE POLICY "Authenticated users can create spots" ON spots
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Users can manage their own saved spots
CREATE POLICY "Users can save spots" ON saved_spots
    FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- Travel guides are publicly viewable
ALTER TABLE travel_guides ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Travel guides are viewable by everyone" ON travel_guides
    FOR SELECT USING (true);

-- ===== INSERT SAMPLE TRAVEL GUIDES =====
INSERT INTO travel_guides (destination, state, days, spots_count, description, is_popular) VALUES
    ('Jaipur', 'Rajasthan', 2, 12, 'The Pink City - forts, palaces, and vibrant culture', true),
    ('Udaipur', 'Rajasthan', 3, 15, 'City of Lakes - romantic getaway in Rajasthan', true),
    ('Goa', 'Goa', 4, 18, 'Beaches, parties, and Portuguese heritage', true),
    ('Manali', 'Himachal Pradesh', 3, 10, 'Mountain paradise for adventure seekers', true),
    ('Varanasi', 'Uttar Pradesh', 2, 8, 'Spiritual capital of India on the Ganges', true),
    ('Kerala', 'Kerala', 5, 20, 'Gods own country - backwaters and beaches', true);

-- ===== INSERT SAMPLE SPOTS =====
INSERT INTO spots (name, description, category, city, state, latitude, longitude, source) VALUES
    ('Hawa Mahal', 'Palace of Winds - iconic pink sandstone structure', 'ATTRACTION', 'Jaipur', 'Rajasthan', 26.9239, 75.8267, 'OSM'),
    ('Amber Fort', 'Magnificent hilltop fort with stunning views', 'ATTRACTION', 'Jaipur', 'Rajasthan', 26.9855, 75.8513, 'OSM'),
    ('City Palace', 'Royal palace complex with museums', 'ATTRACTION', 'Jaipur', 'Rajasthan', 26.9258, 75.8237, 'OSM'),
    ('Jogini Falls', 'Beautiful waterfall near Old Manali', 'NATURE', 'Manali', 'Himachal Pradesh', 32.2396, 77.1887, 'OSM'),
    ('Mall Road Manali', 'Main shopping and food street', 'SHOPPING', 'Manali', 'Himachal Pradesh', 32.2432, 77.1892, 'OSM'),
    ('Old Manali', 'Charming village with cafes and culture', 'ATTRACTION', 'Manali', 'Himachal Pradesh', 32.2500, 77.1800, 'OSM');
