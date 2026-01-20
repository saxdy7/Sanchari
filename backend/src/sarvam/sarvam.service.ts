import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

@Injectable()
export class SarvamService {
    private readonly SARVAM_API_KEY: string;
    private readonly BASE_URL = 'https://api.sarvam.ai';

    constructor(private configService: ConfigService) {
        this.SARVAM_API_KEY = this.configService.get('SARVAM_API_KEY') || '';
    }

    async discoverTouristSpots(destination: string, preferences: string[] = []): Promise<any[]> {
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

            const response = await axios.post(
                `${this.BASE_URL}/v1/chat/completions`,
                {
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
                },
                {
                    headers: {
                        'Authorization': `Bearer ${this.SARVAM_API_KEY}`,
                        'Content-Type': 'application/json',
                    },
                    timeout: 30000, // 30 second timeout
                }
            );

            const content = response.data.choices[0].message.content;
            let cleaned = content.trim();
            
            // Remove markdown code blocks if present
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

        } catch (error) {
            console.error(`❌ Sarvam discovery error: ${error.message}`);
            return [];
        }
    }

    async enrichPlaceDescription(placeName: string, destination: string): Promise<string> {
        try {
            if (!this.SARVAM_API_KEY) return '';

            const response = await axios.post(
                `${this.BASE_URL}/v1/chat/completions`,
                {
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
                },
                {
                    headers: {
                        'Authorization': `Bearer ${this.SARVAM_API_KEY}`,
                        'Content-Type': 'application/json',
                    },
                    timeout: 5000,
                }
            );

            return response.data.choices[0].message.content.trim();
        } catch (error) {
            console.error(`Sarvam enrichment error for ${placeName}: ${error.message}`);
            return '';
        }
    }

    async getLocationContext(locationName: string): Promise<string> {
        try {
            if (!this.SARVAM_API_KEY) {
                console.warn('⚠️ Sarvam API key not configured for location context');
                return '';
            }

            console.log(`🤖 Fetching AI historical context for: ${locationName}`);

            const response = await axios.post(
                `${this.BASE_URL}/v1/chat/completions`,
                {
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
                },
                {
                    headers: {
                        'Authorization': `Bearer ${this.SARVAM_API_KEY}`,
                        'Content-Type': 'application/json',
                    },
                    timeout: 8000,
                }
            );

            const context = response.data.choices[0].message.content.trim();
            console.log(`✅ Got AI context for ${locationName} (${context.length} chars)`);
            return context;

        } catch (error) {
            console.error(`❌ Sarvam location context error for ${locationName}: ${error.message}`);
            return '';
        }
    }
}
