import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TripPlannerModule } from './trip-planner/trip-planner.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TripPlannerModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
