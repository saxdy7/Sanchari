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
Object.defineProperty(exports, "__esModule", { value: true });
exports.WikipediaService = void 0;
const common_1 = require("@nestjs/common");
const axios_1 = __importDefault(require("axios"));
let WikipediaService = class WikipediaService {
    searchUrl = 'https://en.wikipedia.org/w/api.php';
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
            console.error(`Wikipedia error for "${placeName}":`, error.message);
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
            console.error(`Wikipedia search error:`, error.message);
            return null;
        }
    }
    async getCityInfo(cityName) {
        return this.getPlaceInfo(cityName);
    }
    async getMultiplePlaceInfo(places, city) {
        const results = new Map();
        for (const place of places) {
            const info = await this.getPlaceInfo(place, city);
            if (info) {
                results.set(place, info);
            }
            await new Promise(resolve => setTimeout(resolve, 100));
        }
        return results;
    }
};
exports.WikipediaService = WikipediaService;
exports.WikipediaService = WikipediaService = __decorate([
    (0, common_1.Injectable)()
], WikipediaService);
//# sourceMappingURL=wikipedia.service.js.map