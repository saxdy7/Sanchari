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
var LocationService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.LocationService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const axios_1 = __importDefault(require("axios"));
let LocationService = LocationService_1 = class LocationService {
    configService;
    nominatimUrl = 'https://nominatim.openstreetmap.org';
    logger = new common_1.Logger(LocationService_1.name);
    constructor(configService) {
        this.configService = configService;
    }
    async searchLocations(query) {
        try {
            const response = await axios_1.default.get(`${this.nominatimUrl}/search`, {
                params: {
                    q: `${query}, India`,
                    format: 'json',
                    addressdetails: 1,
                    limit: 8,
                    countrycodes: 'in',
                },
                headers: {
                    'User-Agent': 'Sanchari/1.0 (travel-planner-app)',
                },
            });
            return response.data.map((result) => ({
                name: this.extractCityName(result),
                fullName: result.display_name,
                latitude: parseFloat(result.lat),
                longitude: parseFloat(result.lon),
                state: result.address?.state,
                type: result.type,
            }));
        }
        catch (error) {
            console.error('Nominatim search error:', error.message);
            return [];
        }
    }
    async getCoordinates(placeName) {
        try {
            const response = await axios_1.default.get(`${this.nominatimUrl}/search`, {
                params: {
                    q: `${placeName}, India`,
                    format: 'json',
                    limit: 1,
                },
                headers: {
                    'User-Agent': 'Sanchari/1.0 (travel-planner-app)',
                },
            });
            if (response.data.length > 0) {
                this.logger.log(`Found coordinates for ${placeName}: ${response.data[0].lat}, ${response.data[0].lon}`);
                return {
                    lat: parseFloat(response.data[0].lat),
                    lon: parseFloat(response.data[0].lon),
                };
            }
            console.error(`No coordinates found for ${placeName}`);
            return null;
        }
        catch (error) {
            console.error('Geocoding error:', error.message);
            return null;
        }
    }
    extractCityName(result) {
        if (result.address?.city)
            return result.address.city;
        if (result.address?.town)
            return result.address.town;
        if (result.address?.village)
            return result.address.village;
        return result.display_name.split(',')[0].trim();
    }
    async getNearbyTouristSpots(lat, lon) {
        try {
            const query = `
                [out:json][timeout:25];
                (
                  node["tourism"~"attraction|museum|viewpoint|zoo|theme_park"]["name"](around:50000,${lat},${lon});
                  way["tourism"~"attraction|museum|viewpoint|zoo|theme_park"]["name"](around:50000,${lat},${lon});
                  relation["tourism"~"attraction|museum|viewpoint|zoo|theme_park"]["name"](around:50000,${lat},${lon});
                  node["historic"~"monument|memorial|castle|fort|ruins"]["name"](around:50000,${lat},${lon});
                  way["historic"~"monument|memorial|castle|fort|ruins"]["name"](around:50000,${lat},${lon});
                  relation["historic"~"monument|memorial|castle|fort|ruins"]["name"](around:50000,${lat},${lon});
                  node["religion"~"place_of_worship"]["name"](around:50000,${lat},${lon});
                  way["religion"~"place_of_worship"]["name"](around:50000,${lat},${lon});
                  relation["religion"~"place_of_worship"]["name"](around:50000,${lat},${lon});
                );
                out center;
            `;
            const response = await axios_1.default.get('https://overpass-api.de/api/interpreter', {
                params: { data: query },
                timeout: 30000,
            });
            if (!response.data.elements)
                return [];
            const uniqueSpots = new Map();
            response.data.elements.forEach((element) => {
                if (element.tags && element.tags.name) {
                    const name = element.tags.name;
                    if (name.length > 3 && !uniqueSpots.has(name)) {
                        const lat = element.lat || element.center?.lat;
                        const lon = element.lon || element.center?.lon;
                        if (lat && lon) {
                            uniqueSpots.set(name, {
                                name: name,
                                category: this.getCategory(element.tags),
                                lat: lat,
                                lon: lon,
                            });
                        }
                    }
                }
            });
            return Array.from(uniqueSpots.values()).slice(0, 40);
        }
        catch (error) {
            console.error('Overpass API error:', error.message);
            return [];
        }
    }
    getCategory(tags) {
        if (tags.tourism === 'museum')
            return 'Museum';
        if (tags.tourism === 'viewpoint')
            return 'Viewpoint';
        if (tags.historic)
            return 'Heritage';
        if (tags.religion || tags.amenity === 'place_of_worship')
            return 'Temple';
        if (tags.leisure === 'park' || tags.leisure === 'garden')
            return 'Nature';
        return 'Attraction';
    }
};
exports.LocationService = LocationService;
exports.LocationService = LocationService = LocationService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], LocationService);
//# sourceMappingURL=location.service.js.map