import { IsString, IsInt, Min, Max, IsOptional } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class PlanTripDto {
  @ApiProperty({
    description: 'Destination city name in India',
    example: 'Jaipur',
    type: String,
  })
  @IsString()
  destination: string;

  @ApiProperty({
    description: 'Number of days for the trip',
    example: 3,
    minimum: 1,
    maximum: 14,
    type: Number,
  })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(14)
  days: number;

  @ApiPropertyOptional({
    description: 'Comma-separated list of preferences (Heritage, Food, Nature, Adventure, etc.)',
    example: 'Heritage,Food',
    type: String,
  })
  @IsOptional()
  @IsString()
  preferences?: string;
}

export class SearchDestinationDto {
  @ApiProperty({
    description: 'Search query for destination',
    example: 'Mumbai',
    type: String,
  })
  @IsString()
  q: string;
}
