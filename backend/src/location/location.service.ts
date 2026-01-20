import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

export interface LocationResult {
    name: string;
    fullName: string;
    latitude: number;
    longitude: number;
    state?: string;
    type: string;
}

interface NominatimResult {
    place_id: number;
    display_name: string;
    lat: string;
    lon: string;
    type: string;
    address?: {
        city?: string;
        town?: string;
        village?: string;
        state?: string;
    };
}

@Injectable()
export class LocationService {
    private readonly nominatimUrl = 'https://nominatim.openstreetmap.org';

    constructor(private configService: ConfigService) { }

    // Search for cities in India (FREE - Nominatim/OSM)
    async searchLocations(query: string): Promise<LocationResult[]> {
        try {
            const response = await axios.get<NominatimResult[]>(`${this.nominatimUrl}/search`, {
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
        } catch (error) {
            console.error('Nominatim search error:', error.message);
            return [];
        }
    }

    // Get coordinates for a place name
    async getCoordinates(placeName: string): Promise<{ lat: number; lon: number } | null> {
        try {
            const response = await axios.get<NominatimResult[]>(`${this.nominatimUrl}/search`, {
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
                console.log(`Found coordinates for ${placeName}: ${response.data[0].lat}, ${response.data[0].lon}`);
                return {
                    lat: parseFloat(response.data[0].lat),
                    lon: parseFloat(response.data[0].lon),
                };
            }
            console.error(`No coordinates found for ${placeName}`);
            return null;
        } catch (error) {
            console.error('Geocoding error:', error.message);
            return null;
        }
    }

    private extractCityName(result: NominatimResult): string {
        if (result.address?.city) return result.address.city;
        if (result.address?.town) return result.address.town;
        if (result.address?.village) return result.address.village;
        return result.display_name.split(',')[0].trim();
    }

    // Get tourist spots from OpenStreetMap (FREE - Overpass API)
    async getNearbyTouristSpots(lat: number, lon: number): Promise<Array<{
        name: string;
        category: string;
        lat: number;
        lon: number;
    }>> {
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

            const response = await axios.get('https://overpass-api.de/api/interpreter', {
                params: { data: query },
                timeout: 30000, // 30 seconds timeout
            });

            if (!response.data.elements) return [];

            const uniqueSpots = new Map();

            response.data.elements.forEach((element: any) => {
                if (element.tags && element.tags.name) {
                    const name = element.tags.name;
                    // Filter out generic names
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
        } catch (error) {
            console.error('Overpass API error:', error.message);
            return [];
        }
    }

    private getCategory(tags: any): string {
        if (tags.tourism === 'museum') return 'Museum';
        if (tags.tourism === 'viewpoint') return 'Viewpoint';
        if (tags.historic) return 'Heritage';
        if (tags.religion || tags.amenity === 'place_of_worship') return 'Temple';
        if (tags.leisure === 'park' || tags.leisure === 'garden') return 'Nature';
        return 'Attraction';
    }
}
