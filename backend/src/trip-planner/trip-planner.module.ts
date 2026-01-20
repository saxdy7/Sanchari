import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TripPlannerController } from './trip-planner.controller';
import { TripPlannerService } from './trip-planner.service';
import { LocationModule } from '../location/location.module';
import { GroqModule } from '../groq/groq.module';
import { WikipediaModule } from '../wikipedia/wikipedia.module';
import { PixabayModule } from '../pixabay/pixabay.module';
import { SarvamModule } from '../sarvam/sarvam.module';
import { RoutingService } from './routing.service';

@Module({
    imports: [ConfigModule, LocationModule, GroqModule, WikipediaModule, PixabayModule, SarvamModule],
    controllers: [TripPlannerController],
    providers: [TripPlannerService, RoutingService],
})
export class TripPlannerModule { }
