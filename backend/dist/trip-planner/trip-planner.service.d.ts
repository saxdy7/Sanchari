import { ConfigService } from '@nestjs/config';
import { LocationService } from '../location/location.service';
import { GroqService } from '../groq/groq.service';
import { WikipediaService } from '../wikipedia/wikipedia.service';
import { PixabayService } from '../pixabay/pixabay.service';
import { SarvamService } from '../sarvam/sarvam.service';
import { RoutingService } from './routing.service';
export interface TripPlace {
    placeName: string;
    category: string;
    description: string;
    duration: string;
    latitude?: number;
    longitude?: number;
    imageUrl?: string;
    rating?: number;
    history?: string;
}
export interface TripDay {
    dayNumber: number;
    places: TripPlace[];
}
export interface TripResponse {
    destination: string;
    state?: string;
    days: number;
    cityInfo?: {
        description: string;
        imageUrl?: string;
    };
    itinerary: TripDay[];
    routeGeometry?: any;
}
export declare class TripPlannerService {
    private readonly locationService;
    private readonly groqService;
    private readonly wikipediaService;
    private readonly pixabayService;
    private readonly sarvamService;
    private readonly routingService;
    private configService;
    private cache;
    private readonly CACHE_TTL;
    private sharedTrips;
    private readonly SHARE_TTL;
    private readonly logger;
    constructor(locationService: LocationService, groqService: GroqService, wikipediaService: WikipediaService, pixabayService: PixabayService, sarvamService: SarvamService, routingService: RoutingService, configService: ConfigService);
    generateTrip(destination: string, days: number, preferences?: string[]): Promise<TripResponse>;
    private generateShareCode;
    createShareCode(trip: TripResponse): Promise<string>;
    getTripByShareCode(code: string): Promise<TripResponse | null>;
    private enrichPlacesWithImages;
    private enrichPlacesWithGroq;
    private getCityInfoWithGroq;
    private inferCategory;
    private getFallbackPlaces;
    searchDestinations(query: string): Promise<import("../location/location.service").LocationResult[]>;
    getPlaceInfo(name: string, city?: string): Promise<{
        title: string;
        description: string;
        imageUrl: string | null;
        pageUrl: string | null;
        source: string | null;
    }>;
    getPopularDestinations(): Promise<{
        imageUrl: string;
        name: string;
        state: string;
        days: number;
        spots: number;
        description: string;
    }[]>;
    private discoverPlacesWithGroq;
}
