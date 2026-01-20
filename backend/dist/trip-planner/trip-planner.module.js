"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TripPlannerModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const trip_planner_controller_1 = require("./trip-planner.controller");
const trip_planner_service_1 = require("./trip-planner.service");
const location_module_1 = require("../location/location.module");
const groq_module_1 = require("../groq/groq.module");
const wikipedia_module_1 = require("../wikipedia/wikipedia.module");
const pixabay_module_1 = require("../pixabay/pixabay.module");
const sarvam_module_1 = require("../sarvam/sarvam.module");
const routing_service_1 = require("./routing.service");
let TripPlannerModule = class TripPlannerModule {
};
exports.TripPlannerModule = TripPlannerModule;
exports.TripPlannerModule = TripPlannerModule = __decorate([
    (0, common_1.Module)({
        imports: [config_1.ConfigModule, location_module_1.LocationModule, groq_module_1.GroqModule, wikipedia_module_1.WikipediaModule, pixabay_module_1.PixabayModule, sarvam_module_1.SarvamModule],
        controllers: [trip_planner_controller_1.TripPlannerController],
        providers: [trip_planner_service_1.TripPlannerService, routing_service_1.RoutingService],
    })
], TripPlannerModule);
//# sourceMappingURL=trip-planner.module.js.map