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
exports.SarvamService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const axios_1 = __importDefault(require("axios"));
let SarvamService = class SarvamService {
    configService;
    SARVAM_API_KEY;
    BASE_URL = 'https://api.sarvam.ai';
    constructor(configService) {
        this.configService = configService;
        this.SARVAM_API_KEY = this.configService.get('SARVAM_API_KEY') || '';
    }
    async discoverTouristSpots(destination, preferences = []) {
        try {
            if (!this.SARVAM_API_KEY) {
                console.warn('⚠️ Sarvam API key not configured. Skipping...');
                return [];
            }
            const prompt = `List 40 MUST-VISIT tourist attractions in ${destination}, India. Focus on:
- Famous landmarks and monuments
- Historical sites
- Popular temples, museums, parks
- Well-known restaurants and cafes
- Major shopping areas
- Natural attractions

User preferences: ${preferences.join(', ')}

IMPORTANT: Only include REAL, WELL-KNOWN places that tourists actually visit. No generic places.

For each place provide:
1. Name (exact, real place name - e.g., "Charminar", "Golconda Fort")
2. Category (Museum, Nature, Foodie, History, Shopping, Adventure, Religious, Rivers, Popular)
3. Description (1 sentence about why it's famous)

Return ONLY valid JSON array:
[{"name": "Exact Place Name", "category": "Category", "description": "Why it's famous"}, ...]`;
            const response = await axios_1.default.post(`${this.BASE_URL}/v1/chat/completions`, {
                model: 'sarvam-m',
                messages: [
                    {
                        role: 'system',
                        content: 'You are a travel expert for Indian destinations. Return ONLY valid JSON arrays without any markdown formatting.',
                    },
                    { role: 'user', content: prompt },
                ],
                temperature: 0.3,
                max_tokens: 2000,
            }, {
                headers: {
                    'Authorization': `Bearer ${this.SARVAM_API_KEY}`,
                    'Content-Type': 'application/json',
                },
                timeout: 30000,
            });
            const content = response.data.choices[0].message.content;
            let cleaned = content.trim();
            if (cleaned.startsWith('```')) {
                cleaned = cleaned.replace(/```json?\n?/g, '').replace(/```/g, '');
            }
            const places = JSON.parse(cleaned);
            if (!Array.isArray(places)) {
                console.error('Sarvam response is not an array');
                return [];
            }
            console.log(`✅ Sarvam discovered ${places.length} places`);
            return places;
        }
        catch (error) {
            console.error(`❌ Sarvam discovery error: ${error.message}`);
            return [];
        }
    }
    async enrichPlaceDescription(placeName, destination) {
        try {
            if (!this.SARVAM_API_KEY)
                return '';
            const response = await axios_1.default.post(`${this.BASE_URL}/v1/chat/completions`, {
                model: 'sarvam-m',
                messages: [
                    {
                        role: 'system',
                        content: 'You are a travel guide for India. Provide concise, engaging descriptions.',
                    },
                    {
                        role: 'user',
                        content: `Write a 2-sentence description of ${placeName} in ${destination}, India.`,
                    },
                ],
                temperature: 0.7,
                max_tokens: 150,
            }, {
                headers: {
                    'Authorization': `Bearer ${this.SARVAM_API_KEY}`,
                    'Content-Type': 'application/json',
                },
                timeout: 5000,
            });
            return response.data.choices[0].message.content.trim();
        }
        catch (error) {
            console.error(`Sarvam enrichment error for ${placeName}: ${error.message}`);
            return '';
        }
    }
    async getLocationContext(locationName) {
        try {
            if (!this.SARVAM_API_KEY) {
                console.warn('⚠️ Sarvam API key not configured for location context');
                return '';
            }
            console.log(`🤖 Fetching AI historical context for: ${locationName}`);
            const response = await axios_1.default.post(`${this.BASE_URL}/v1/chat/completions`, {
                model: 'sarvam-m',
                messages: [
                    {
                        role: 'system',
                        content: 'You are a knowledgeable Indian travel historian. Provide rich, engaging historical and cultural context about Indian destinations. Keep responses concise but informative (3-4 sentences).',
                    },
                    {
                        role: 'user',
                        content: `Provide historical and cultural context about ${locationName}, India. Include:
- Historical significance and key events
- Cultural importance and traditions
- What makes it special or unique
- Best time to visit or key attractions

Keep it engaging and informative.`,
                    },
                ],
                temperature: 0.7,
                max_tokens: 250,
            }, {
                headers: {
                    'Authorization': `Bearer ${this.SARVAM_API_KEY}`,
                    'Content-Type': 'application/json',
                },
                timeout: 8000,
            });
            const context = response.data.choices[0].message.content.trim();
            console.log(`✅ Got AI context for ${locationName} (${context.length} chars)`);
            return context;
        }
        catch (error) {
            console.error(`❌ Sarvam location context error for ${locationName}: ${error.message}`);
            return '';
        }
    }
};
exports.SarvamService = SarvamService;
exports.SarvamService = SarvamService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], SarvamService);
//# sourceMappingURL=sarvam.service.js.map