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
var TripPlannerController_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.TripPlannerController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const trip_planner_service_1 = require("./trip-planner.service");
const plan_trip_dto_1 = require("./dto/plan-trip.dto");
const supabase_auth_guard_1 = require("../auth/supabase-auth.guard");
const current_user_decorator_1 = require("../auth/current-user.decorator");
let TripPlannerController = TripPlannerController_1 = class TripPlannerController {
    tripPlannerService;
    logger = new common_1.Logger(TripPlannerController_1.name);
    constructor(tripPlannerService) {
        this.tripPlannerService = tripPlannerService;
    }
    async searchDestinations(dto) {
        return this.tripPlannerService.searchDestinations(dto.q);
    }
    async getPopularDestinations() {
        return this.tripPlannerService.getPopularDestinations();
    }
    async getPlaceInfo(name, city) {
        return this.tripPlannerService.getPlaceInfo(name, city);
    }
    async getTripByShareCode(code) {
        const trip = await this.tripPlannerService.getTripByShareCode(code);
        if (!trip) {
            return { error: 'Trip not found or expired' };
        }
        return trip;
    }
    async planTrip(user, dto) {
        this.logger.log(`🔐 Generating trip for user: ${user.email}`);
        const prefList = dto.preferences ? dto.preferences.split(',') : [];
        return this.tripPlannerService.generateTrip(dto.destination, dto.days, prefList);
    }
    async createShareCode(user, body) {
        this.logger.log(`🔐 Creating share code for user: ${user.email}`);
        const code = await this.tripPlannerService.createShareCode(body.trip);
        return { code, expiresIn: '24 hours' };
    }
};
exports.TripPlannerController = TripPlannerController;
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
    (0, common_1.Get)('place-info'),
    __param(0, (0, common_1.Query)('name')),
    __param(1, (0, common_1.Query)('city')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], TripPlannerController.prototype, "getPlaceInfo", null);
__decorate([
    (0, common_1.Get)('share/:code'),
    __param(0, (0, common_1.Param)('code')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TripPlannerController.prototype, "getTripByShareCode", null);
__decorate([
    (0, common_1.Get)('plan'),
    (0, common_1.UseGuards)(supabase_auth_guard_1.SupabaseAuthGuard),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, plan_trip_dto_1.PlanTripDto]),
    __metadata("design:returntype", Promise)
], TripPlannerController.prototype, "planTrip", null);
__decorate([
    (0, common_1.Post)('share'),
    (0, common_1.UseGuards)(supabase_auth_guard_1.SupabaseAuthGuard),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], TripPlannerController.prototype, "createShareCode", null);
exports.TripPlannerController = TripPlannerController = TripPlannerController_1 = __decorate([
    (0, swagger_1.ApiTags)('trip'),
    (0, common_1.Controller)('trip'),
    __metadata("design:paramtypes", [trip_planner_service_1.TripPlannerService])
], TripPlannerController);
//# sourceMappingURL=trip-planner.controller.js.map