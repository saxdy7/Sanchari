import { Module } from '@nestjs/common';
import { PixabayService } from './pixabay.service';

@Module({
    providers: [PixabayService],
    exports: [PixabayService],
})
export class PixabayModule { }
