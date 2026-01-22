import { Module } from '@nestjs/common';
import { GoogleAIService } from './google-ai.service';

@Module({
    providers: [GoogleAIService],
    exports: [GoogleAIService],
})
export class GoogleAIModule { }
