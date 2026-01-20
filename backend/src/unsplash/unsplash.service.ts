import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

@Injectable()
export class UnsplashService {
    private readonly BASE_URL = 'https://api.unsplash.com';

    constructor(private configService: ConfigService) {}

    async getPlaceImage(placeName: string, city: string): Promise<string | null> {
        try {
            const accessKey = this.configService.get('UNSPLASH_ACCESS_KEY');
            if (!accessKey || accessKey === 'YOUR_UNSPLASH_ACCESS_KEY_HERE') {
                console.warn('⚠️ Unsplash API key not configured. Skipping...');
                return null;
            }

            const query = `${placeName} ${city} India`;
            const response = await axios.get(`${this.BASE_URL}/search/photos`, {
                params: {
                    query,
                    per_page: 1,
                    orientation: 'landscape',
                },
                headers: {
                    Authorization: `Client-ID ${accessKey}`,
                },
                timeout: 5000, // 5 second timeout
            });

            if (response.data.results && response.data.results.length > 0) {
                return response.data.results[0].urls.regular;
            }
            return null;
        } catch (error) {
            console.error(`Unsplash error for ${placeName}:`, error.message);
            return null;
        }
    }

    async getMultiplePlaceImages(placeNames: string[], city: string): Promise<Map<string, string | null>> {
        const results = new Map<string, string | null>();

        const accessKey = this.configService.get('UNSPLASH_ACCESS_KEY');
        if (!accessKey || accessKey === 'YOUR_UNSPLASH_ACCESS_KEY_HERE') {
            console.warn('⚠️ Unsplash API key not configured. Returning empty results.');
            return results;
        }

        // Fetch all images in parallel
        const promises = placeNames.map(async (placeName) => {
            const imageUrl = await this.getPlaceImage(placeName, city);
            results.set(placeName, imageUrl);
        });

        await Promise.allSettled(promises); // Don't fail if one request fails
        return results;
    }

    async getCityImage(cityName: string): Promise<string | null> {
        try {
            const accessKey = this.configService.get('UNSPLASH_ACCESS_KEY');
            if (!accessKey || accessKey === 'YOUR_UNSPLASH_ACCESS_KEY_HERE') {
                return null;
            }

            const response = await axios.get(`${this.BASE_URL}/search/photos`, {
                params: {
                    query: `${cityName} India landmark`,
                    per_page: 1,
                    orientation: 'landscape',
                },
                headers: {
                    Authorization: `Client-ID ${accessKey}`,
                },
                timeout: 5000,
            });

            if (response.data.results && response.data.results.length > 0) {
                return response.data.results[0].urls.regular;
            }
            return null;
        } catch (error) {
            console.error(`Unsplash city image error for ${cityName}:`, error.message);
            return null;
        }
    }
}
