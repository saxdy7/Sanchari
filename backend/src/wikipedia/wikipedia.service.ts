import { Injectable } from '@nestjs/common';
import axios from 'axios';

interface WikipediaResult {
    title: string;
    extract: string;
    imageUrl?: string;
    pageUrl: string;
}

@Injectable()
export class WikipediaService {
    private readonly searchUrl = 'https://en.wikipedia.org/w/api.php';

    async getPlaceInfo(placeName: string, city?: string): Promise<WikipediaResult | null> {
        try {
            // Search for the place using the MediaWiki API (more reliable)
            const searchQuery = city ? `${placeName} ${city} India` : `${placeName} India`;

            const response = await axios.get(this.searchUrl, {
                params: {
                    action: 'query',
                    titles: placeName,
                    prop: 'extracts|pageimages|info',
                    exintro: true,
                    explaintext: true,
                    piprop: 'original|thumbnail',
                    pithumbsize: 500,
                    inprop: 'url',
                    format: 'json',
                    origin: '*',
                },
                headers: {
                    'User-Agent': 'Sanchari/1.0 (https://sanchari.app; contact@sanchari.app) travel-planner',
                },
            });

            const pages = response.data.query?.pages;
            if (!pages) return null;

            const pageId = Object.keys(pages)[0];
            if (pageId === '-1') {
                // Try with search if direct title fails
                return this.searchAndGetInfo(searchQuery);
            }

            const page = pages[pageId];
            return {
                title: page.title,
                extract: page.extract || '',
                imageUrl: page.original?.source || page.thumbnail?.source,
                pageUrl: page.fullurl || '',
            };
        } catch (error) {
            console.error(`Wikipedia error for "${placeName}":`, error.message);
            return null;
        }
    }

    private async searchAndGetInfo(searchQuery: string): Promise<WikipediaResult | null> {
        try {
            // First search
            const searchResponse = await axios.get(this.searchUrl, {
                params: {
                    action: 'query',
                    list: 'search',
                    srsearch: searchQuery,
                    srlimit: 1,
                    format: 'json',
                    origin: '*',
                },
                headers: {
                    'User-Agent': 'Sanchari/1.0 (https://sanchari.app; contact@sanchari.app) travel-planner',
                },
            });

            const searchResults = searchResponse.data.query?.search;
            if (!searchResults || searchResults.length === 0) {
                return null;
            }

            const pageTitle = searchResults[0].title;

            // Get page details
            const pageResponse = await axios.get(this.searchUrl, {
                params: {
                    action: 'query',
                    titles: pageTitle,
                    prop: 'extracts|pageimages|info',
                    exintro: true,
                    explaintext: true,
                    piprop: 'original|thumbnail',
                    pithumbsize: 500,
                    inprop: 'url',
                    format: 'json',
                    origin: '*',
                },
                headers: {
                    'User-Agent': 'Sanchari/1.0 (https://sanchari.app; contact@sanchari.app) travel-planner',
                },
            });

            const pages = pageResponse.data.query?.pages;
            if (!pages) return null;

            const pageId = Object.keys(pages)[0];
            if (pageId === '-1') return null;

            const page = pages[pageId];
            return {
                title: page.title,
                extract: page.extract || '',
                imageUrl: page.original?.source || page.thumbnail?.source,
                pageUrl: page.fullurl || '',
            };
        } catch (error) {
            console.error(`Wikipedia search error:`, error.message);
            return null;
        }
    }

    async getCityInfo(cityName: string): Promise<WikipediaResult | null> {
        return this.getPlaceInfo(cityName);
    }

    async getMultiplePlaceInfo(places: string[], city: string): Promise<Map<string, WikipediaResult>> {
        const results = new Map<string, WikipediaResult>();

        // Fetch sequentially with small delays to avoid rate limiting
        for (const place of places) {
            const info = await this.getPlaceInfo(place, city);
            if (info) {
                results.set(place, info);
            }
            // Small delay between requests
            await new Promise(resolve => setTimeout(resolve, 100));
        }

        return results;
    }
}
