"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var TripPlannerService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.TripPlannerService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const location_service_1 = require("../location/location.service");
const groq_service_1 = require("../groq/groq.service");
const wikipedia_service_1 = require("../wikipedia/wikipedia.service");
const pixabay_service_1 = require("../pixabay/pixabay.service");
const sarvam_service_1 = require("../sarvam/sarvam.service");
const routing_service_1 = require("./routing.service");
const axios_1 = __importDefault(require("axios"));
let TripPlannerService = TripPlannerService_1 = class TripPlannerService {
    locationService;
    groqService;
    wikipediaService;
    pixabayService;
    sarvamService;
    routingService;
    configService;
    cache = new Map();
    CACHE_TTL = 30 * 60 * 1000;
    sharedTrips = new Map();
    SHARE_TTL = 24 * 60 * 60 * 1000;
    logger = new common_1.Logger(TripPlannerService_1.name);
    constructor(locationService, groqService, wikipediaService, pixabayService, sarvamService, routingService, configService) {
        this.locationService = locationService;
        this.groqService = groqService;
        this.wikipediaService = wikipediaService;
        this.pixabayService = pixabayService;
        this.sarvamService = sarvamService;
        this.routingService = routingService;
        this.configService = configService;
        setInterval(() => {
            const now = Date.now();
            let cleanedCount = 0;
            for (const [key, value] of this.cache.entries()) {
                if (value.expires < now) {
                    this.cache.delete(key);
                    cleanedCount++;
                }
            }
            if (cleanedCount > 0) {
                this.logger.log(`Cleaned up ${cleanedCount} expired cache entries`);
            }
        }, 10 * 60 * 1000);
    }
    async generateTrip(destination, days, preferences = []) {
        const cacheKey = `${destination.toLowerCase()}-${days}-${preferences.sort().join(',')}`;
        const cached = this.cache.get(cacheKey);
        if (cached && cached.expires > Date.now()) {
            this.logger.log(`Cache HIT for ${destination}`);
            return cached.data;
        }
        this.logger.log(`Generating trip for ${destination}, ${days} days`);
        const coords = await this.locationService.getCoordinates(destination);
        if (!coords) {
            throw new Error(`Could not find coordinates for ${destination}`);
        }
        this.logger.log('⚡ Fetching spots from Sarvam AI...');
        const sarvamSpots = await this.sarvamService.discoverTouristSpots(destination, preferences);
        const uniqueSpots = [];
        const seenNames = new Set();
        for (const spot of sarvamSpots) {
            const sarvamPlace = {
                name: spot.name,
                category: spot.category,
                lat: coords.lat,
                lon: coords.lon,
            };
            const normalizedName = sarvamPlace.name.toLowerCase().trim();
            if (!seenNames.has(normalizedName)) {
                seenNames.add(normalizedName);
                uniqueSpots.push(sarvamPlace);
            }
        }
        this.logger.log(`🔍 Sarvam returned ${sarvamSpots.length} spots, ${uniqueSpots.length} unique`);
        let spots = uniqueSpots;
        this.logger.log(`✅ Using ${spots.length} Sarvam-discovered spots`);
        this.logger.log(`📍 Total spots from parallel fetch: ${spots.length}`);
        if (spots.length === 0) {
            this.logger.log('Using Fallback mechanisms...');
            const fallbackSpots = this.getFallbackPlaces(destination, coords.lat, coords.lon);
            if (fallbackSpots.length > 0) {
                this.logger.log(`Found ${fallbackSpots.length} hardcoded fallback spots`);
                spots = fallbackSpots.map(p => ({
                    name: p.placeName,
                    category: p.category,
                    lat: p.latitude || coords.lat,
                    lon: p.longitude || coords.lon
                }));
            }
            else {
                this.logger.log('Attempting Groq Discovery...');
                spots = await this.discoverPlacesWithGroq(destination);
                this.logger.log(`Groq discovered ${spots.length} places`);
            }
        }
        if (spots.length === 0) {
            this.logger.warn(`Could not find ANY spots for ${destination} even after all fallbacks.`);
        }
        this.logger.log(`Proceeding with ${spots.length} places`);
        const initialPlaces = spots.map(s => ({
            placeName: s.name,
            category: s.category,
            description: '',
            duration: '1-2 hours',
            latitude: s.lat,
            longitude: s.lon,
        }));
        const enrichedPlaces = initialPlaces;
        this.logger.log('Fetching images and city info (Wikipedia + Pixabay)...');
        const [placesWithImages, cityWiki] = await Promise.all([
            this.enrichPlacesWithImages(enrichedPlaces, destination),
            this.wikipediaService.getCityInfo(destination),
        ]);
        const cityInfo = cityWiki
            ? { description: cityWiki.extract, imageUrl: cityWiki.imageUrl }
            : { description: `Explore ${destination}, India.`, imageUrl: undefined };
        const placesPerDay = Math.max(Math.ceil(placesWithImages.length / days), 1);
        const itinerary = [];
        for (let day = 1; day <= days; day++) {
            const startIdx = (day - 1) * placesPerDay;
            const dayPlaces = placesWithImages.slice(startIdx, startIdx + placesPerDay);
            if (dayPlaces.length > 0) {
                itinerary.push({ dayNumber: day, places: dayPlaces });
            }
        }
        const routeCoords = placesWithImages
            .filter(p => p.longitude && p.latitude)
            .map(p => [p.longitude, p.latitude]);
        let routeGeometry = null;
        if (routeCoords.length >= 2) {
            this.logger.log('Fetching route geometry from OSRM...');
            const routeData = await this.routingService.getRoute(routeCoords);
            if (routeData) {
                routeGeometry = routeData.geometry;
            }
        }
        this.logger.log(`Created itinerary with ${itinerary.length} days. Route: ${routeGeometry ? 'Found' : 'None'}`);
        const result = {
            destination,
            days,
            cityInfo,
            itinerary,
            routeGeometry,
        };
        this.cache.set(cacheKey, {
            data: result,
            expires: Date.now() + this.CACHE_TTL,
        });
        this.logger.log(`✅ Cached trip for ${destination} (expires in 30 min)`);
        return result;
    }
    generateShareCode() {
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        let code = '';
        for (let i = 0; i < 6; i++) {
            code += characters.charAt(Math.floor(Math.random() * characters.length));
        }
        if (this.sharedTrips.has(code)) {
            return this.generateShareCode();
        }
        return code;
    }
    async createShareCode(trip) {
        const now = Date.now();
        for (const [code, shared] of this.sharedTrips.entries()) {
            if (now > shared.createdAt + this.SHARE_TTL) {
                this.sharedTrips.delete(code);
            }
        }
        const code = this.generateShareCode();
        this.sharedTrips.set(code, {
            code,
            trip,
            createdAt: now,
        });
        this.logger.log(`✅ Created share code: ${code} for ${trip.destination}`);
        return code;
    }
    async getTripByShareCode(code) {
        const shared = this.sharedTrips.get(code.toUpperCase());
        if (!shared) {
            return null;
        }
        const now = Date.now();
        if (now > shared.createdAt + this.SHARE_TTL) {
            this.sharedTrips.delete(code);
            return null;
        }
        this.logger.log(`📥 Retrieved shared trip: ${code} - ${shared.trip.destination}`);
        return shared.trip;
    }
    async enrichPlacesWithImages(places, city) {
        this.logger.log('⚡ Fetching images from Wikipedia...');
        const placeNames = places.map(p => p.placeName);
        const wikiMap = await this.wikipediaService.getMultiplePlaceInfo(placeNames, city);
        this.logger.log(`✅ Wikipedia found ${wikiMap.size} images`);
        const enrichedPlaces = await Promise.all(places.map(async (place) => {
            const wikiInfo = wikiMap.get(place.placeName);
            let imageUrl = wikiInfo?.imageUrl;
            if (!imageUrl) {
                this.logger.log(`🔍 Wikipedia image not found for ${place.placeName}, trying Pixabay...`);
                const pixabayUrl = await this.pixabayService.getPlaceImage(place.placeName, city);
                imageUrl = pixabayUrl || undefined;
            }
            return {
                ...place,
                imageUrl,
            };
        }));
        return enrichedPlaces;
    }
    async enrichPlacesWithGroq(places, destination, days) {
        if (places.length === 0)
            return [];
        try {
            const placeNames = places.map(p => p.placeName).join(', ');
            const prompt = `For a ${days}-day trip to ${destination}, India, provide brief, engaging 2-sentence descriptions for these places: ${placeNames}

Return ONLY valid JSON in this format:
{
  "places": [
    {
      "name": "Place Name",
      "description": "Brief engaging description (2 sentences max)",
      "history": "Short historical fact if available"
    }
  ]
}`;
            const groqResponse = await axios_1.default.post('https://api.groq.com/openai/v1/chat/completions', {
                model: 'llama-3.3-70b-versatile',
                messages: [
                    {
                        role: 'system',
                        content: 'You are a travel guide expert. Provide concise, engaging place descriptions. Always respond with valid JSON only.',
                    },
                    { role: 'user', content: prompt },
                ],
                temperature: 0.7,
                max_tokens: 2000,
            }, {
                headers: {
                    Authorization: `Bearer ${this.configService.get('GROQ_API_KEY')}`,
                    'Content-Type': 'application/json',
                },
            });
            const content = groqResponse.data.choices[0].message.content;
            let cleaned = content.trim();
            if (cleaned.startsWith('```')) {
                cleaned = cleaned.replace(/```json?\n?/g, '').replace(/```/g, '');
            }
            const parsed = JSON.parse(cleaned);
            const descriptions = new Map(parsed.places.map((p) => [p.name, { description: p.description, history: p.history }]));
            return places.map(place => ({
                ...place,
                description: descriptions.get(place.placeName)?.description || place.description,
                history: descriptions.get(place.placeName)?.history,
            }));
        }
        catch (error) {
            console.error('Groq enrichment error:', error.message);
            return places;
        }
    }
    async getCityInfoWithGroq(city) {
        try {
            const prompt = `Write a compelling 3-sentence introduction for ${city}, India for travelers. Focus on what makes it unique and worth visiting.`;
            const response = await axios_1.default.post('https://api.groq.com/openai/v1/chat/completions', {
                model: 'llama-3.3-70b-versatile',
                messages: [
                    { role: 'system', content: 'You are a travel writer. Be concise and engaging.' },
                    { role: 'user', content: prompt },
                ],
                temperature: 0.7,
                max_tokens: 300,
            }, {
                headers: {
                    Authorization: `Bearer ${this.configService.get('GROQ_API_KEY')}`,
                    'Content-Type': 'application/json',
                },
            });
            return {
                description: response.data.choices[0].message.content,
            };
        }
        catch (error) {
            console.error('Groq city info error:', error.message);
            return {
                description: `Explore the vibrant city of ${city}, one of India's most captivating destinations.`,
            };
        }
    }
    inferCategory(types) {
        if (types.includes('museum'))
            return 'Museum';
        if (types.includes('hindu_temple') || types.includes('place_of_worship'))
            return 'Temple';
        if (types.includes('park'))
            return 'Nature';
        if (types.includes('shopping_mall'))
            return 'Shopping';
        if (types.includes('restaurant'))
            return 'Food';
        return 'Attraction';
    }
    getFallbackPlaces(destination, lat, lon) {
        const fallbackData = {
            'jaipur': [
                { placeName: 'Hawa Mahal', category: 'Heritage', description: 'The Palace of Winds', duration: '1-2 hours', latitude: 26.9239, longitude: 75.8267, rating: 4.5 },
                { placeName: 'Amber Fort', category: 'Heritage', description: 'Magnificent hilltop fort', duration: '2-3 hours', latitude: 26.9855, longitude: 75.8513, rating: 4.6 },
                { placeName: 'City Palace', category: 'Heritage', description: 'Royal palace complex', duration: '2-3 hours', latitude: 26.9258, longitude: 75.8237, rating: 4.4 },
                { placeName: 'Jantar Mantar', category: 'Heritage', description: 'Astronomical observatory', duration: '1-2 hours', latitude: 26.9248, longitude: 75.8246, rating: 4.3 },
                { placeName: 'Nahargarh Fort', category: 'Heritage', description: 'Scenic fort with city views', duration: '2-3 hours', latitude: 26.9373, longitude: 75.8154, rating: 4.4 },
                { placeName: 'Jal Mahal', category: 'Attraction', description: 'Water palace in Man Sagar Lake', duration: '1 hour', latitude: 26.9533, longitude: 75.8463, rating: 4.2 },
            ],
            'manali': [
                { placeName: 'Hadimba Temple', category: 'Temple', description: 'Ancient temple in cedar forest', duration: '1 hour', latitude: 32.2432, longitude: 77.1689, rating: 4.5 },
                { placeName: 'Solang Valley', category: 'Nature', description: 'Adventure sports destination', duration: '3-4 hours', latitude: 32.3150, longitude: 77.1575, rating: 4.6 },
                { placeName: 'Rohtang Pass', category: 'Nature', description: 'High mountain pass', duration: '4-5 hours', latitude: 32.3725, longitude: 77.2475, rating: 4.7 },
                { placeName: 'Old Manali', category: 'Attraction', description: 'Charming village area', duration: '2-3 hours', latitude: 32.2558, longitude: 77.1878, rating: 4.4 },
                { placeName: 'Vashisht Hot Springs', category: 'Attraction', description: 'Natural thermal springs', duration: '1-2 hours', latitude: 32.2638, longitude: 77.1783, rating: 4.3 },
            ],
            'goa': [
                { placeName: 'Baga Beach', category: 'Nature', description: 'Popular beach destination', duration: '2-3 hours', latitude: 15.5553, longitude: 73.7514, rating: 4.3 },
                { placeName: 'Basilica of Bom Jesus', category: 'Heritage', description: 'UNESCO World Heritage church', duration: '1 hour', latitude: 15.5009, longitude: 73.9116, rating: 4.6 },
                { placeName: 'Fort Aguada', category: 'Heritage', description: '17th-century Portuguese fort', duration: '1-2 hours', latitude: 15.4922, longitude: 73.7736, rating: 4.4 },
                { placeName: 'Dudhsagar Falls', category: 'Nature', description: 'Spectacular waterfall', duration: '3-4 hours', latitude: 15.3144, longitude: 74.3143, rating: 4.7 },
                { placeName: 'Anjuna Beach', category: 'Nature', description: 'Famous for flea market', duration: '2-3 hours', latitude: 15.5735, longitude: 73.7419, rating: 4.2 },
            ],
            'udaipur': [
                { placeName: 'City Palace', category: 'Heritage', description: 'Majestic palace complex', duration: '2-3 hours', latitude: 24.5764, longitude: 73.6901, rating: 4.6 },
                { placeName: 'Lake Pichola', category: 'Nature', description: 'Beautiful artificial lake', duration: '2 hours', latitude: 24.5719, longitude: 73.6807, rating: 4.5 },
                { placeName: 'Jag Mandir', category: 'Heritage', description: 'Island palace on Lake Pichola', duration: '1-2 hours', latitude: 24.5676, longitude: 73.6830, rating: 4.4 },
                { placeName: 'Fateh Sagar Lake', category: 'Nature', description: 'Scenic lake with islands', duration: '1-2 hours', latitude: 24.6031, longitude: 73.6803, rating: 4.3 },
            ],
            'kasol': [
                { placeName: 'Kheerganga Trek', category: 'Nature', description: 'Beautiful mountain trek', duration: '6-8 hours', latitude: 32.0292, longitude: 77.4917, rating: 4.7 },
                { placeName: 'Manikaran Sahib', category: 'Temple', description: 'Sacred Sikh pilgrimage site', duration: '2 hours', latitude: 32.0275, longitude: 77.3458, rating: 4.6 },
                { placeName: 'Tosh Village', category: 'Attraction', description: 'Scenic hippie village', duration: '3-4 hours', latitude: 32.0350, longitude: 77.4450, rating: 4.5 },
                { placeName: 'Chalal Trek', category: 'Nature', description: 'Short nature trek', duration: '2-3 hours', latitude: 32.0150, longitude: 77.3250, rating: 4.4 },
            ],
            'chennai': [
                { placeName: 'Marina Beach', category: 'Nature', description: 'Second longest urban beach in the world', duration: '2-3 hours', latitude: 13.0475, longitude: 80.2824, rating: 4.5 },
                { placeName: 'Kapaleeshwarar Temple', category: 'Temple', description: 'Ancient Shiva temple built in Dravidian style', duration: '1-2 hours', latitude: 13.0334, longitude: 80.2705, rating: 4.7 },
                { placeName: 'San Thome Basilica', category: 'Heritage', description: 'Historic minor basilica built over Saint Thomas tomb', duration: '1 hour', latitude: 13.0315, longitude: 80.2785, rating: 4.6 },
                { placeName: 'Fort St. George', category: 'Heritage', description: 'First English fortress in India, now a museum', duration: '2 hours', latitude: 13.0792, longitude: 80.2868, rating: 4.3 },
                { placeName: 'Guindy National Park', category: 'Nature', description: 'Protected area with diverse flora and fauna', duration: '2-3 hours', latitude: 13.0067, longitude: 80.2206, rating: 4.4 },
                { placeName: 'Government Museum', category: 'Museum', description: 'Second oldest museum in India', duration: '2-3 hours', latitude: 13.0706, longitude: 80.2562, rating: 4.5 },
            ],
        };
        const city = destination.toLowerCase();
        return fallbackData[city] || [];
    }
    async searchDestinations(query) {
        return this.locationService.searchLocations(query);
    }
    async getPlaceInfo(name, city) {
        try {
            this.logger.log(`📍 Fetching comprehensive place info for: ${name}${city ? ` in ${city}` : ''}`);
            const wikiInfo = await this.wikipediaService.getPlaceInfo(name, city);
            let imageUrl = wikiInfo?.imageUrl || null;
            let description = wikiInfo?.extract || '';
            const pageUrl = wikiInfo?.pageUrl || null;
            if (!imageUrl) {
                this.logger.log(`🔍 Wikipedia image not found, trying Pixabay for ${name}`);
                const pixabayImage = await this.pixabayService.getPlaceImage(name, city);
                if (pixabayImage) {
                    imageUrl = pixabayImage;
                    this.logger.log(`✅ Found Pixabay image for ${name}`);
                }
            }
            let aiDescription = '';
            try {
                const locationName = city ? `${name}, ${city}` : name;
                this.logger.log(`🤖 Fetching AI historical description for ${locationName}`);
                aiDescription = await this.sarvamService.getLocationContext(locationName);
                this.logger.log(`✅ Got AI description for ${name}`);
            }
            catch (aiError) {
                this.logger.log(`⚠️ Could not fetch AI description: ${aiError.message}`);
            }
            const combinedDescription = aiDescription
                ? (description ? `${description}\n\n${aiDescription}` : aiDescription)
                : description;
            this.logger.log(`✅ Comprehensive info gathered for ${name}`);
            return {
                title: wikiInfo?.title || name,
                description: combinedDescription,
                imageUrl: imageUrl,
                pageUrl: pageUrl,
                source: imageUrl ? (wikiInfo?.imageUrl ? 'wikipedia' : 'pixabay') : null,
            };
        }
        catch (error) {
            console.error(`❌ Error fetching place info for ${name}:`, error.message);
            return {
                title: name,
                description: '',
                imageUrl: null,
                pageUrl: null,
                source: null,
            };
        }
    }
    async getPopularDestinations() {
        const destinations = [
            { name: 'Jaipur', state: 'Rajasthan', days: 3, spots: 15, description: 'The Pink City' },
            { name: 'Udaipur', state: 'Rajasthan', days: 2, spots: 12, description: 'City of Lakes' },
            { name: 'Goa', state: 'Goa', days: 4, spots: 20, description: 'Beach Paradise' },
            { name: 'Varanasi', state: 'Uttar Pradesh', days: 2, spots: 10, description: 'Spiritual Capital' },
            { name: 'Rishikesh', state: 'Uttarakhand', days: 3, spots: 12, description: 'Yoga Capital' },
            { name: 'Manali', state: 'Himachal Pradesh', days: 4, spots: 14, description: 'Hill Station' },
            { name: 'Kerala', state: 'Kerala', days: 5, spots: 18, description: 'Backwaters & Nature' },
            { name: 'Agra', state: 'Uttar Pradesh', days: 1, spots: 8, description: 'Home of Taj Mahal' },
            { name: 'Mumbai', state: 'Maharashtra', days: 3, spots: 22, description: 'City of Dreams' },
            { name: 'Hampi', state: 'Karnataka', days: 2, spots: 15, description: 'Ancient Ruins' },
            { name: 'Leh', state: 'Ladakh', days: 5, spots: 16, description: 'Mountain Paradise' },
            { name: 'Mysore', state: 'Karnataka', days: 2, spots: 10, description: 'Palace City' },
        ];
        const destinationsWithImages = await Promise.all(destinations.map(async (dest) => {
            try {
                const wikiInfo = await this.wikipediaService.getPlaceInfo(dest.name);
                const imageUrl = wikiInfo?.imageUrl || 'https://via.placeholder.com/400x300?text=' + dest.name;
                return {
                    ...dest,
                    imageUrl,
                };
            }
            catch (error) {
                console.error(`Failed to fetch image for ${dest.name}:`, error.message);
                return {
                    ...dest,
                    imageUrl: 'https://via.placeholder.com/400x300?text=' + dest.name,
                };
            }
        }));
        return destinationsWithImages;
    }
    async discoverPlacesWithGroq(destination) {
        this.logger.log(`Using Groq to discover places for ${destination}...`);
        try {
            const prompt = `List 20 MUST-VISIT famous tourist attractions in ${destination}, India.

IMPORTANT: Only include REAL, WELL-KNOWN landmarks that tourists actually visit (like Charminar, Golconda Fort, Hussain Sagar Lake for Hyderabad).

Return JSON ONLY:
{
  "places": [
    { "name": "Exact Real Place Name", "category": "Heritage/Nature/Temple/Museum/Popular" }
  ]
}`;
            const response = await axios_1.default.post('https://api.groq.com/openai/v1/chat/completions', {
                model: 'llama-3.3-70b-versatile',
                messages: [
                    { role: 'system', content: 'You are a travel expert. Output JSON only.' },
                    { role: 'user', content: prompt },
                ],
                temperature: 0.5,
            }, {
                headers: {
                    Authorization: `Bearer ${this.configService.get('GROQ_API_KEY')}`,
                    'Content-Type': 'application/json',
                },
            });
            const content = response.data.choices[0].message.content;
            let cleaned = content.trim();
            if (cleaned.startsWith('```')) {
                cleaned = cleaned.replace(/```json?\n?/g, '').replace(/```/g, '');
            }
            const parsed = JSON.parse(cleaned);
            const discoveredPlaces = parsed.places || [];
            const resolvedPlaces = [];
            for (const p of discoveredPlaces) {
                const coords = await this.locationService.getCoordinates(`${p.name}, ${destination}`);
                if (coords) {
                    resolvedPlaces.push({
                        name: p.name,
                        category: p.category,
                        lat: coords.lat,
                        lon: coords.lon,
                    });
                }
            }
            return resolvedPlaces;
        }
        catch (error) {
            console.error('Groq discovery error:', error.message);
            return [];
        }
    }
};
exports.TripPlannerService = TripPlannerService;
exports.TripPlannerService = TripPlannerService = TripPlannerService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [location_service_1.LocationService,
        groq_service_1.GroqService,
        wikipedia_service_1.WikipediaService,
        pixabay_service_1.PixabayService,
        sarvam_service_1.SarvamService,
        routing_service_1.RoutingService,
        config_1.ConfigService])
], TripPlannerService);
//# sourceMappingURL=trip-planner.service.js.map