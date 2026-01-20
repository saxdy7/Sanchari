"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var RoutingService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.RoutingService = void 0;
const common_1 = require("@nestjs/common");
const axios_1 = __importDefault(require("axios"));
let RoutingService = RoutingService_1 = class RoutingService {
    logger = new common_1.Logger(RoutingService_1.name);
    OSRM_API_URL = 'http://router.project-osrm.org/route/v1/driving';
    async getRoute(coordinates) {
        if (coordinates.length < 2) {
            return null;
        }
        const coordinateString = coordinates
            .map(coord => `${coord[0]},${coord[1]}`)
            .join(';');
        try {
            const url = `${this.OSRM_API_URL}/${coordinateString}?overview=full&geometries=geojson`;
            this.logger.log(`Fetching route from OSRM: ${url}`);
            const response = await axios_1.default.get(url);
            if (response.data && response.data.routes && response.data.routes.length > 0) {
                return response.data.routes[0];
            }
            return null;
        }
        catch (error) {
            this.logger.error(`Failed to fetch route from OSRM`, error);
            return null;
        }
    }
};
exports.RoutingService = RoutingService;
exports.RoutingService = RoutingService = RoutingService_1 = __decorate([
    (0, common_1.Injectable)()
], RoutingService);
//# sourceMappingURL=routing.service.js.map