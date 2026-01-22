interface WikipediaResult {
    title: string;
    extract: string;
    imageUrl?: string;
    pageUrl: string;
}
export declare class WikipediaService {
    private readonly logger;
    private readonly searchUrl;
    private readonly timeout;
    private readonly maxRetries;
    getPlaceInfo(placeName: string, city?: string): Promise<WikipediaResult | null>;
    private searchAndGetInfo;
    getCityInfo(cityName: string): Promise<WikipediaResult | null>;
    getMultiplePlaceInfo(places: string[], city: string): Promise<Map<string, WikipediaResult>>;
    private chunkArray;
}
export {};
