import { TripPlannerService } from './trip-planner.service';
import { PlanTripDto, SearchDestinationDto } from './dto/plan-trip.dto';
export declare class TripPlannerController {
    private readonly tripPlannerService;
    constructor(tripPlannerService: TripPlannerService);
    planTrip(dto: PlanTripDto): Promise<import("./trip-planner.service").TripResponse>;
    searchDestinations(dto: SearchDestinationDto): Promise<import("../location/location.service").LocationResult[]>;
    getPopularDestinations(): Promise<{
        imageUrl: string;
        name: string;
        state: string;
        days: number;
        spots: number;
        description: string;
    }[]>;
    createShareCode(body: any): Promise<{
        code: string;
        expiresIn: string;
    }>;
    getTripByShareCode(code: string): Promise<import("./trip-planner.service").TripResponse | {
        error: string;
    }>;
    getPlaceInfo(name: string, city?: string): Promise<{
        title: string;
        description: string;
        imageUrl: string | null;
        pageUrl: string | null;
        source: string | null;
    }>;
}
