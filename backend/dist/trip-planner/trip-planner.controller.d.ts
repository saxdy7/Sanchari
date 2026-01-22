import { TripPlannerService } from './trip-planner.service';
import { PlanTripDto, SearchDestinationDto } from './dto/plan-trip.dto';
export declare class TripPlannerController {
    private readonly tripPlannerService;
    private readonly logger;
    constructor(tripPlannerService: TripPlannerService);
    searchDestinations(dto: SearchDestinationDto): Promise<import("../location/location.service").LocationResult[]>;
    getPopularDestinations(): Promise<{
        imageUrl: string;
        name: string;
        state: string;
        days: number;
        spots: number;
        description: string;
    }[]>;
    getPlaceInfo(name: string, city?: string): Promise<{
        title: string;
        description: string;
        imageUrl: string | null;
        pageUrl: string | null;
        source: string | null;
    }>;
    getTripByShareCode(code: string): Promise<import("./trip-planner.service").TripResponse | {
        error: string;
    }>;
    planTrip(user: any, dto: PlanTripDto): Promise<import("./trip-planner.service").TripResponse>;
    createShareCode(user: any, body: any): Promise<{
        code: string;
        expiresIn: string;
    }>;
}
