import { ConfigService } from '@nestjs/config';
export declare class PixabayService {
    private configService;
    private readonly BASE_URL;
    private readonly PIXABAY_API_KEY;
    constructor(configService: ConfigService);
    getPlaceImage(placeName: string, city?: string): Promise<string | null>;
    getMultiplePlaceImages(placeNames: string[], city: string): Promise<Map<string, string>>;
    getCityImage(cityName: string): Promise<string | null>;
}
