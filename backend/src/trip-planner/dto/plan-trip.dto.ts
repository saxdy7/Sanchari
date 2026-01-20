import { IsString, IsInt, Min, Max, IsOptional, Length } from 'class-validator';
import { Transform } from 'class-transformer';

export class PlanTripDto {
  @IsString()
  @Length(1, 100)
  destination: string;

  @Transform(({ value }) => parseInt(value, 10))
  @IsInt()
  @Min(1)
  @Max(30)
  days: number;

  @IsOptional()
  @IsString()
  preferences?: string;
}

export class SearchDestinationDto {
  @IsString()
  @Length(1, 100)
  q: string;
}
