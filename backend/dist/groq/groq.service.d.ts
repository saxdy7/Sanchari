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
export declare class GroqService {
    private readonly apiKey;
    private readonly baseUrl;
    generateItinerary(destination: string, days: number, preferences?: string[]): Promise<DayPlan[]>;
    private buildPrompt;
    private parseItinerary;
}
export {};
