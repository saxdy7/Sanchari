import { Controller, Get, Query, Post, Body, Param, UseGuards, Logger } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { TripPlannerService } from './trip-planner.service';
import { PlanTripDto, SearchDestinationDto } from './dto/plan-trip.dto';
import { SupabaseAuthGuard } from '../auth/supabase-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';

@ApiTags('trip')
@Controller('trip')
export class TripPlannerController {
    private readonly logger = new Logger(TripPlannerController.name);
    constructor(private readonly tripPlannerService: TripPlannerService) { }

    // ✅ PUBLIC - No authentication required
    @Get('search')
    async searchDestinations(@Query() dto: SearchDestinationDto) {
        return this.tripPlannerService.searchDestinations(dto.q);
    }

    // ✅ PUBLIC - No authentication required
    @Get('popular-destinations')
    async getPopularDestinations() {
        return this.tripPlannerService.getPopularDestinations();
    }

    // ✅ PUBLIC - No authentication required
    @Get('place-info')
    async getPlaceInfo(@Query('name') name: string, @Query('city') city?: string) {
        return this.tripPlannerService.getPlaceInfo(name, city);
    }

    // ✅ PUBLIC - Anyone can view shared trips
    @Get('share/:code')
    async getTripByShareCode(@Param('code') code: string) {
        const trip = await this.tripPlannerService.getTripByShareCode(code);
        if (!trip) {
            return { error: 'Trip not found or expired' };
        }
        return trip;
    }

    // 🔒 PROTECTED - Requires authentication
    @Get('plan')
    @UseGuards(SupabaseAuthGuard)
    async planTrip(
        @CurrentUser() user: any,
        @Query() dto: PlanTripDto,
    ) {
        this.logger.log(`🔐 Generating trip for user: ${user.email}`);
        const prefList = dto.preferences ? dto.preferences.split(',') : [];
        return this.tripPlannerService.generateTrip(dto.destination, dto.days, prefList);
    }

    // 🔒 PROTECTED - Requires authentication
    @Post('share')
    @UseGuards(SupabaseAuthGuard)
    async createShareCode(
        @CurrentUser() user: any,
        @Body() body: any,
    ) {
        this.logger.log(`🔐 Creating share code for user: ${user.email}`);
        const code = await this.tripPlannerService.createShareCode(body.trip);
        return { code, expiresIn: '24 hours' };
    }
}
