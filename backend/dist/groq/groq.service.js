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
exports.GroqService = void 0;
const common_1 = require("@nestjs/common");
const axios_1 = __importDefault(require("axios"));
let GroqService = class GroqService {
    apiKey = process.env.GROQ_API_KEY;
    baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
    async generateItinerary(destination, days, preferences = []) {
        const prompt = this.buildPrompt(destination, days, preferences);
        try {
            const response = await axios_1.default.post(this.baseUrl, {
                model: 'llama-3.3-70b-versatile',
                messages: [
                    {
                        role: 'system',
                        content: `You are an expert India travel planner. Generate detailed, realistic trip itineraries.
              Always respond with valid JSON only, no markdown, no explanations.
              Focus on real, existing places in India with accurate information.`,
                    },
                    {
                        role: 'user',
                        content: prompt,
                    },
                ],
                temperature: 0.7,
                max_tokens: 4000,
            }, {
                headers: {
                    Authorization: `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json',
                },
            });
            const content = response.data.choices[0].message.content;
            return this.parseItinerary(content);
        }
        catch (error) {
            console.error('Groq API error:', error.response?.data || error.message);
            throw new Error('Failed to generate itinerary');
        }
    }
    buildPrompt(destination, days, preferences) {
        const prefText = preferences.length
            ? `Focus on: ${preferences.join(', ')}`
            : 'Include a mix of attractions, culture, food, and nature';
        return `Create a ${days}-day trip itinerary for ${destination}, India.
${prefText}

Return ONLY valid JSON in this exact format:
{
  "days": [
    {
      "dayNumber": 1,
      "places": [
        {
          "placeName": "Real Place Name",
          "category": "ATTRACTION|NATURE|HISTORY|FOOD|SHOPPING|MUSEUM",
          "description": "2-3 sentences about this place",
          "duration": "2 hours",
          "bestTime": "morning|afternoon|evening"
        }
      ]
    }
  ]
}

Rules:
- Only include REAL places that exist in ${destination}
- 4-6 places per day
- Include famous landmarks, local food spots, hidden gems
- Add practical info like best time to visit
- Be specific with place names (full official names)`;
    }
    parseItinerary(content) {
        try {
            let cleaned = content.trim();
            if (cleaned.startsWith('```')) {
                cleaned = cleaned.replace(/```json?\n?/g, '').replace(/```/g, '');
            }
            const parsed = JSON.parse(cleaned);
            return parsed.days || [];
        }
        catch (error) {
            console.error('Failed to parse itinerary:', content);
            return [];
        }
    }
};
exports.GroqService = GroqService;
exports.GroqService = GroqService = __decorate([
    (0, common_1.Injectable)()
], GroqService);
//# sourceMappingURL=groq.service.js.map