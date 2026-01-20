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
Object.defineProperty(exports, "__esModule", { value: true });
exports.UnsplashService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const axios_1 = __importDefault(require("axios"));
let UnsplashService = class UnsplashService {
    configService;
    BASE_URL = 'https://api.unsplash.com';
    constructor(configService) {
        this.configService = configService;
    }
    async getPlaceImage(placeName, city) {
        try {
            const accessKey = this.configService.get('UNSPLASH_ACCESS_KEY');
            if (!accessKey || accessKey === 'YOUR_UNSPLASH_ACCESS_KEY_HERE') {
                console.warn('⚠️ Unsplash API key not configured. Skipping...');
                return null;
            }
            const query = `${placeName} ${city} India`;
            const response = await axios_1.default.get(`${this.BASE_URL}/search/photos`, {
                params: {
                    query,
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
        }
        catch (error) {
            console.error(`Unsplash error for ${placeName}:`, error.message);
            return null;
        }
    }
    async getMultiplePlaceImages(placeNames, city) {
        const results = new Map();
        const accessKey = this.configService.get('UNSPLASH_ACCESS_KEY');
        if (!accessKey || accessKey === 'YOUR_UNSPLASH_ACCESS_KEY_HERE') {
            console.warn('⚠️ Unsplash API key not configured. Returning empty results.');
            return results;
        }
        const promises = placeNames.map(async (placeName) => {
            const imageUrl = await this.getPlaceImage(placeName, city);
            results.set(placeName, imageUrl);
        });
        await Promise.allSettled(promises);
        return results;
    }
    async getCityImage(cityName) {
        try {
            const accessKey = this.configService.get('UNSPLASH_ACCESS_KEY');
            if (!accessKey || accessKey === 'YOUR_UNSPLASH_ACCESS_KEY_HERE') {
                return null;
            }
            const response = await axios_1.default.get(`${this.BASE_URL}/search/photos`, {
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
        }
        catch (error) {
            console.error(`Unsplash city image error for ${cityName}:`, error.message);
            return null;
        }
    }
};
exports.UnsplashService = UnsplashService;
exports.UnsplashService = UnsplashService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], UnsplashService);
//# sourceMappingURL=unsplash.service.js.map