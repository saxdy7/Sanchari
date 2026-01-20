"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TripPlannerController = void 0;
const common_1 = require("@nestjs/common");
const trip_planner_service_1 = require("./trip-planner.service");
const plan_trip_dto_1 = require("./dto/plan-trip.dto");
let TripPlannerController = class TripPlannerController {
    tripPlannerService;
    constructor(tripPlannerService) {
        this.tripPlannerService = tripPlannerService;
    }
    async planTrip(dto) {
        const prefList = dto.preferences ? dto.preferences.split(',') : [];
        return this.tripPlannerService.generateTrip(dto.destination, dto.days, prefList);
    }
    async searchDestinations(dto) {
        return this.tripPlannerService.searchDestinations(dto.q);
    }
    async getPopularDestinations() {
        return this.tripPlannerService.getPopularDestinations();
    }
    async createShareCode(body) {
        const code = await this.tripPlannerService.createShareCode(body.trip);
        return { code, expiresIn: '24 hours' };
    }
    async getTripByShareCode(code) {
        const trip = await this.tripPlannerService.getTripByShareCode(code);
        if (!trip) {
            return { error: 'Trip not found or expired' };
        }
        return trip;
    }
    async getPlaceInfo(name, city) {
        return this.tripPlannerService.getPlaceInfo(name, city);
    }
};
exports.TripPlannerController = TripPlannerController;
__decorate([
    (0, common_1.Get)('plan'),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [plan_trip_dto_1.PlanTripDto]),
    __metadata("design:returntype", Promise)
], TripPlannerController.prototype, "planTrip", null);
__decorate([
    (0, common_1.Get)('search'),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [plan_trip_dto_1.SearchDestinationDto]),
    __metadata("design:returntype", Promise)
], TripPlannerController.prototype, "searchDestinations", null);
__decorate([
    (0, common_1.Get)('popular-destinations'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], TripPlannerController.prototype, "getPopularDestinations", null);
__decorate([
    (0, common_1.Post)('share'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], TripPlannerController.prototype, "createShareCode", null);
__decorate([
    (0, common_1.Get)('share/:code'),
    __param(0, (0, common_1.Param)('code')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TripPlannerController.prototype, "getTripByShareCode", null);
__decorate([
    (0, common_1.Get)('place-info'),
    __param(0, (0, common_1.Query)('name')),
    __param(1, (0, common_1.Query)('city')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], TripPlannerController.prototype, "getPlaceInfo", null);
exports.TripPlannerController = TripPlannerController = __decorate([
    (0, common_1.Controller)('trip'),
    __metadata("design:paramtypes", [trip_planner_service_1.TripPlannerService])
], TripPlannerController);
//# sourceMappingURL=trip-planner.controller.js.map