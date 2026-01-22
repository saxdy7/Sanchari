import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

interface ItineraryPlace {
    placeName: string;
    category: string;
    description: string;
    duration: string;
}

interface DayPlan {
    dayNumber: number;
    places: ItineraryPlace[];
}

@Injectable()
export class GoogleAIService {
    private readonly logger = new Logger(GoogleAIService.name);
    private readonly apiKey: string;
    private readonly geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
    private readonly customSearchUrl = 'https://www.googleapis.com/customsearch/v1';
    private readonly customSearchEngineId = '017576662512468239146:omuauf_lfve';

    constructor(private configService: ConfigService) {
        this.apiKey = this.configService.get('GOOGLE_AI_STUDIO_API_KEY') || '';
    }

    /**
     * Generate trip itinerary using Gemini (fast and free)
     */
    async generateItinerary(
        destination: string,
        days: number,
        preferences: string[] = [],
    ): Promise<DayPlan[]> {
        try {
            if (!this.apiKey) {
                this.logger.warn('Google AI Studio API key not configured');
                throw new Error('API key missing');
            }

            const prompt = this.buildPrompt(destination, days, preferences);

            const response = await axios.post(
                `${this.geminiUrl}?key=${this.apiKey}`,
                {
                    contents: [{
                        parts: [{
                            text: prompt
                        }]
                    }],
                    generationConfig: {
                        temperature: 0.7,
                        maxOutputTokens: 4000,
                    }
                },
                {
                    timeout: 15000,
                    headers: { 'Content-Type': 'application/json' }
                }
            );

            const content = response.data.candidates[0].content.parts[0].text;
            return this.parseItinerary(content);
        } catch (error) {
            this.logger.error(`Gemini API error: ${error.message}`);
            throw new Error('Failed to generate itinerary with Gemini');
        }
    }

    private buildPrompt(destination: string, days: number, preferences: string[]): string {
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
          "duration": "2 hours"
        }
      ]
    }
  ]
}

Rules:
- Only include REAL places that exist in ${destination}
- 4-6 places per day
- Include famous landmarks, local food spots, hidden gems
- Add practical info like duration
- Be specific with place names (full official names)
- No markdown, just pure JSON`;
    }

    private parseItinerary(content: string): DayPlan[] {
        try {
            let cleaned = content.trim();
            if (cleaned.startsWith('```')) {
                cleaned = cleaned.replace(/```json?\n?/g, '').replace(/```/g, '');
            }

            const parsed = JSON.parse(cleaned);
            return parsed.days || [];
        } catch (error) {
            this.logger.error('Failed to parse Gemini response');
            throw new Error('Invalid itinerary format');
        }
    }

    /**
     * Search for high-quality images using Google Custom Search
     * Fast and free with generous quota
     */
    async searchImage(query: string): Promise<string | null> {
        try {
            if (!this.apiKey) {
                this.logger.warn('Google AI Studio API key not configured');
                return null;
            }

            const searchQuery = `${query} India tourist attraction high quality`;

            const response = await axios.get(this.customSearchUrl, {
                params: {
                    key: this.apiKey,
                    cx: this.customSearchEngineId,
                    q: searchQuery,
                    searchType: 'image',
                    imgSize: 'large',
                    imgType: 'photo',
                    num: 1,
                    safe: 'active',
                },
                timeout: 5000,
            });

            if (response.data.items && response.data.items.length > 0) {
                const imageUrl = response.data.items[0].link;
                this.logger.log(`✅ Found image for: ${query}`);
                return imageUrl;
            }

            this.logger.warn(`No image found for: ${query}`);
            return null;
        } catch (error) {
            if (error.response?.status === 429) {
                this.logger.warn(`Rate limit reached for Google AI - query: ${query}`);
            } else if (error.code === 'ETIMEDOUT') {
                this.logger.warn(`Timeout searching image for: ${query}`);
            } else {
                this.logger.error(`Google AI image search error: ${error.message}`);
            }
            return null;
        }
    }

    /**
     * Batch search images for multiple places
     * Fast parallel processing with rate limiting
     */
    async searchMultipleImages(places: string[]): Promise<Map<string, string>> {
        const results = new Map<string, string>();

        // Process in chunks of 3 for speed and rate limit management
        const chunks = this.chunkArray(places, 3);

        for (const chunk of chunks) {
            const chunkResults = await Promise.all(
                chunk.map(place => this.searchImage(place).catch(() => null))
            );

            chunk.forEach((place, i) => {
                if (chunkResults[i]) {
                    results.set(place, chunkResults[i]);
                }
            });

            // Small delay between chunks to respect rate limits
            await new Promise(resolve => setTimeout(resolve, 200));
        }

        this.logger.log(`✅ Found images for ${results.size}/${places.length} places`);
        return results;
    }

    private chunkArray<T>(array: T[], size: number): T[][] {
        const chunks: T[][] = [];
        for (let i = 0; i < array.length; i += size) {
            chunks.push(array.slice(i, i + size));
        }
        return chunks;
    }
}
