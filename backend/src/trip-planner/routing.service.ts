
import { Injectable, Logger } from '@nestjs/common';
import axios from 'axios';

@Injectable()
export class RoutingService {
    private readonly logger = new Logger(RoutingService.name);
    private readonly OSRM_API_URL = 'http://router.project-osrm.org/route/v1/driving';

    /**
     * Fetch a route between multiple coordinates using OSRM.
     * Coordinates should be in [lon, lat] format (GeoJSON standard).
     */
    async getRoute(coordinates: [number, number][]): Promise<any> {
        if (coordinates.length < 2) {
            return null;
        }

        // OSRM format: {lon},{lat};{lon},{lat}...
        const coordinateString = coordinates
            .map(coord => `${coord[0]},${coord[1]}`)
            .join(';');

        try {
            const url = `${this.OSRM_API_URL}/${coordinateString}?overview=full&geometries=geojson`;
            this.logger.log(`Fetching route from OSRM: ${url}`);

            const response = await axios.get(url);

            if (response.data && response.data.routes && response.data.routes.length > 0) {
                return response.data.routes[0]; // Return the best route
            }
            return null;
        } catch (error) {
            this.logger.error(`Failed to fetch route from OSRM`, error);
            // Fallback: Return null or throw, depending on needs. for now silent fail is safer for "free" APIs that might be busy.
            return null;
        }
    }
}
