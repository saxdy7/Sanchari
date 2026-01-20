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
exports.PixabayService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const axios_1 = __importDefault(require("axios"));
let PixabayService = class PixabayService {
    configService;
    BASE_URL = 'https://pixabay.com/api/';
    PIXABAY_API_KEY;
    constructor(configService) {
        this.configService = configService;
        this.PIXABAY_API_KEY = this.configService.get('PIXABAY_API_KEY') || '';
    }
    async getPlaceImage(placeName, city) {
        try {
            if (!this.PIXABAY_API_KEY || this.PIXABAY_API_KEY === 'YOUR_PIXABAY_API_KEY_HERE') {
                return null;
            }
            const searchQuery = city ? `${placeName} ${city} India` : `${placeName} India`;
            const response = await axios_1.default.get(this.BASE_URL, {
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
                return response.data.hits[0].largeImageURL || response.data.hits[0].webformatURL;
            }
            return null;
        }
        catch (error) {
            return null;
        }
    }
    async getMultiplePlaceImages(placeNames, city) {
        if (!this.PIXABAY_API_KEY || this.PIXABAY_API_KEY === 'YOUR_PIXABAY_API_KEY_HERE') {
            return new Map();
        }
        const imageMap = new Map();
        const promises = placeNames.map(async (placeName) => {
            const imageUrl = await this.getPlaceImage(placeName, city);
            if (imageUrl) {
                imageMap.set(placeName, imageUrl);
            }
        });
        await Promise.allSettled(promises);
        return imageMap;
    }
    async getCityImage(cityName) {
        try {
            if (!this.PIXABAY_API_KEY || this.PIXABAY_API_KEY === 'YOUR_PIXABAY_API_KEY_HERE') {
                return null;
            }
            const response = await axios_1.default.get(this.BASE_URL, {
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
        }
        catch (error) {
            return null;
        }
    }
};
exports.PixabayService = PixabayService;
exports.PixabayService = PixabayService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], PixabayService);
//# sourceMappingURL=pixabay.service.js.map