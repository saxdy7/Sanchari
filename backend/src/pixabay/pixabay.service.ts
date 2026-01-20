import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

@Injectable()
export class PixabayService {
    private readonly BASE_URL = 'https://pixabay.com/api/';
    private readonly PIXABAY_API_KEY: string;

    constructor(private configService: ConfigService) {
        this.PIXABAY_API_KEY = this.configService.get('PIXABAY_API_KEY') || '';
    }

    async getPlaceImage(placeName: string, city?: string): Promise<string | null> {
        try {
            if (!this.PIXABAY_API_KEY || this.PIXABAY_API_KEY === 'YOUR_PIXABAY_API_KEY_HERE') {
                return null;
            }

            const searchQuery = city ? `${placeName} ${city} India` : `${placeName} India`;

            const response = await axios.get(this.BASE_URL, {
                params: {
                    key: this.PIXABAY_API_KEY,
                    q: searchQuery,
                    image_type: 'photo',
                    category: 'places,travel,buildings',
                    per_page: 3,
                    safesearch: true,
                },
                timeout: 5000,
            });

            if (response.data?.hits && response.data.hits.length > 0) {
                // Return the large image URL from the first result
                return response.data.hits[0].largeImageURL || response.data.hits[0].webformatURL;
            }

            return null;
        } catch (error) {
            // Silent failure - just return null
            return null;
        }
    }

    async getMultiplePlaceImages(placeNames: string[], city: string): Promise<Map<string, string>> {
        if (!this.PIXABAY_API_KEY || this.PIXABAY_API_KEY === 'YOUR_PIXABAY_API_KEY_HERE') {
            return new Map();
        }

        const imageMap = new Map<string, string>();

        // Fetch images in parallel with Promise.allSettled to handle failures gracefully
        const promises = placeNames.map(async (placeName) => {
            const imageUrl = await this.getPlaceImage(placeName, city);
            if (imageUrl) {
                imageMap.set(placeName, imageUrl);
            }
        });

        await Promise.allSettled(promises);
        return imageMap;
    }

    async getCityImage(cityName: string): Promise<string | null> {
        try {
            if (!this.PIXABAY_API_KEY || this.PIXABAY_API_KEY === 'YOUR_PIXABAY_API_KEY_HERE') {
                return null;
            }

            const response = await axios.get(this.BASE_URL, {
                params: {
                    key: this.PIXABAY_API_KEY,
                    q: `${cityName} India cityscape`,
                    image_type: 'photo',
                    category: 'places,travel,buildings',
                    per_page: 3,
                    safesearch: true,
                },
                timeout: 5000,
            });

            if (response.data?.hits && response.data.hits.length > 0) {
                return response.data.hits[0].largeImageURL || response.data.hits[0].webformatURL;
            }

            return null;
        } catch (error) {
            return null;
        }
    }
}
