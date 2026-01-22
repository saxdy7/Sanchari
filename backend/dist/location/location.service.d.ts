import { ConfigService } from '@nestjs/config';
export interface LocationResult {
    name: string;
    fullName: string;
    latitude: number;
    longitude: number;
    state?: string;
    type: string;
}
export declare class LocationService {
    private configService;
    private readonly nominatimUrl;
    private readonly logger;
    constructor(configService: ConfigService);
    searchLocations(query: string): Promise<LocationResult[]>;
    getCoordinates(placeName: string): Promise<{
        lat: number;
        lon: number;
    } | null>;
    private extractCityName;
    getNearbyTouristSpots(lat: number, lon: number): Promise<Array<{
        name: string;
        category: string;
        lat: number;
        lon: number;
    }>>;
    private getCategory;
}
