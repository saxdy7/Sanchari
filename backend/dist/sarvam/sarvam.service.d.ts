import { ConfigService } from '@nestjs/config';
export declare class SarvamService {
    private configService;
    private readonly logger;
    private readonly SARVAM_API_KEY;
    private readonly BASE_URL;
    constructor(configService: ConfigService);
    discoverTouristSpots(destination: string, preferences?: string[]): Promise<any[]>;
    enrichPlaceDescription(placeName: string, destination: string): Promise<string>;
    getLocationContext(locationName: string): Promise<string>;
}
