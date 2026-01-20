export declare class RoutingService {
    private readonly logger;
    private readonly OSRM_API_URL;
    getRoute(coordinates: [number, number][]): Promise<any>;
}
