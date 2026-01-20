import { Controller, Get, Query, Post, Body, Param } from '@nestjs/common';
import { TripPlannerService } from './trip-planner.service';
import { PlanTripDto, SearchDestinationDto } from './dto/plan-trip.dto';

@Controller('trip')
export class TripPlannerController {
    constructor(private readonly tripPlannerService: TripPlannerService) { }

    @Get('plan')
    async planTrip(@Query() dto: PlanTripDto) {
        const prefList = dto.preferences ? dto.preferences.split(',') : [];
        return this.tripPlannerService.generateTrip(dto.destination, dto.days, prefList);
    }

    @Get('search')
    async searchDestinations(@Query() dto: SearchDestinationDto) {
        return this.tripPlannerService.searchDestinations(dto.q);
    }

    @Get('popular-destinations')
    async getPopularDestinations() {
        return this.tripPlannerService.getPopularDestinations();
    }

    @Post('share')
    async createShareCode(@Body() body: any) {
        const code = await this.tripPlannerService.createShareCode(body.trip);
        return { code, expiresIn: '24 hours' };
    }

    @Get('share/:code')
    async getTripByShareCode(@Param('code') code: string) {
        const trip = await this.tripPlannerService.getTripByShareCode(code);
        if (!trip) {
            return { error: 'Trip not found or expired' };
        }
        return trip;
    }

    @Get('place-info')
    async getPlaceInfo(@Query('name') name: string, @Query('city') city?: string) {
        return this.tripPlannerService.getPlaceInfo(name, city);
    }
}
