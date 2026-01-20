import { ConfigService } from '@nestjs/config';
export declare class UnsplashService {
    private configService;
    private readonly BASE_URL;
    constructor(configService: ConfigService);
    getPlaceImage(placeName: string, city: string): Promise<string | null>;
    getMultiplePlaceImages(placeNames: string[], city: string): Promise<Map<string, string | null>>;
    getCityImage(cityName: string): Promise<string | null>;
}
