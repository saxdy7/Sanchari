"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var WikipediaService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.WikipediaService = void 0;
const common_1 = require("@nestjs/common");
const axios_1 = __importDefault(require("axios"));
let WikipediaService = WikipediaService_1 = class WikipediaService {
    logger = new common_1.Logger(WikipediaService_1.name);
    searchUrl = 'https://en.wikipedia.org/w/api.php';
    timeout = 10000;
    maxRetries = 2;
    async getPlaceInfo(placeName, city) {
        try {
            const searchQuery = city ? `${placeName} ${city} India` : `${placeName} India`;
            const response = await axios_1.default.get(this.searchUrl, {
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
                timeout: this.timeout,
            });
            const pages = response.data.query?.pages;
            if (!pages)
                return null;
            const pageId = Object.keys(pages)[0];
            if (pageId === '-1') {
                return this.searchAndGetInfo(searchQuery);
            }
            const page = pages[pageId];
            return {
                title: page.title,
                extract: page.extract || '',
                imageUrl: page.original?.source || page.thumbnail?.source,
                pageUrl: page.fullurl || '',
            };
        }
        catch (error) {
            if (error.code === 'ETIMEDOUT' || error.code === 'ECONNABORTED') {
                this.logger.warn(`Wikipedia timeout for "${placeName}" - skipping`);
            }
            else {
                this.logger.error(`Wikipedia error for "${placeName}": ${error.message}`);
            }
            return null;
        }
    }
    async searchAndGetInfo(searchQuery) {
        try {
            const searchResponse = await axios_1.default.get(this.searchUrl, {
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
                timeout: this.timeout,
            });
            const searchResults = searchResponse.data.query?.search;
            if (!searchResults || searchResults.length === 0) {
                return null;
            }
            const pageTitle = searchResults[0].title;
            const pageResponse = await axios_1.default.get(this.searchUrl, {
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
                timeout: this.timeout,
            });
            const pages = pageResponse.data.query?.pages;
            if (!pages)
                return null;
            const pageId = Object.keys(pages)[0];
            if (pageId === '-1')
                return null;
            const page = pages[pageId];
            return {
                title: page.title,
                extract: page.extract || '',
                imageUrl: page.original?.source || page.thumbnail?.source,
                pageUrl: page.fullurl || '',
            };
        }
        catch (error) {
            this.logger.error(`Wikipedia search error: ${error.message}`);
            return null;
        }
    }
    async getCityInfo(cityName) {
        return this.getPlaceInfo(cityName);
    }
    async getMultiplePlaceInfo(places, city) {
        const results = new Map();
        const chunks = this.chunkArray(places, 5);
        for (const chunk of chunks) {
            const chunkResults = await Promise.all(chunk.map(place => this.getPlaceInfo(place, city).catch(() => null)));
            chunk.forEach((place, i) => {
                if (chunkResults[i]) {
                    results.set(place, chunkResults[i]);
                }
            });
            await new Promise(resolve => setTimeout(resolve, 100));
        }
        this.logger.log(`Fetched Wikipedia info for ${results.size}/${places.length} places`);
        return results;
    }
    chunkArray(array, size) {
        const chunks = [];
        for (let i = 0; i < array.length; i += size) {
            chunks.push(array.slice(i, i + size));
        }
        return chunks;
    }
};
exports.WikipediaService = WikipediaService;
exports.WikipediaService = WikipediaService = WikipediaService_1 = __decorate([
    (0, common_1.Injectable)()
], WikipediaService);
//# sourceMappingURL=wikipedia.service.js.map