import { Injectable } from '@nestjs/common';
import axios from 'axios';

interface ItineraryItem {
    placeName: string;
    category: string;
    description: string;
    duration: string;
    latitude?: number;
    longitude?: number;
    imageUrl?: string;
    history?: string;
}

interface DayPlan {
    dayNumber: number;
    places: ItineraryItem[];
}

@Injectable()
export class GroqService {
    private readonly apiKey = process.env.GROQ_API_KEY;
    private readonly baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

    async generateItinerary(
        destination: string,
        days: number,
        preferences: string[] = [],
    ): Promise<DayPlan[]> {
        const prompt = this.buildPrompt(destination, days, preferences);

        try {
            const response = await axios.post(
                this.baseUrl,
                {
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
                },
                {
                    headers: {
                        Authorization: `Bearer ${this.apiKey}`,
                        'Content-Type': 'application/json',
                    },
                },
            );

            const content = response.data.choices[0].message.content;
            return this.parseItinerary(content);
        } catch (error) {
            console.error('Groq API error:', error.response?.data || error.message);
            throw new Error('Failed to generate itinerary');
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

    private parseItinerary(content: string): DayPlan[] {
        try {
            // Clean up the response (remove markdown if present)
            let cleaned = content.trim();
            if (cleaned.startsWith('```')) {
                cleaned = cleaned.replace(/```json?\n?/g, '').replace(/```/g, '');
            }

            const parsed = JSON.parse(cleaned);
            return parsed.days || [];
        } catch (error) {
            console.error('Failed to parse itinerary:', content);
            return [];
        }
    }
}
