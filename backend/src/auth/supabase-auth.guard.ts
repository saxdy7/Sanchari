import { Injectable, CanActivate, ExecutionContext, UnauthorizedException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseAuthGuard implements CanActivate {
    private supabase: SupabaseClient;
    private readonly logger = new Logger(SupabaseAuthGuard.name);

    constructor(private configService: ConfigService) {
        const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
        const supabaseKey = this.configService.get<string>('SUPABASE_ANON_KEY');

        if (!supabaseUrl || !supabaseKey) {
            throw new Error('Supabase configuration missing');
        }

        this.supabase = createClient(supabaseUrl, supabaseKey);
    }

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const request = context.switchToHttp().getRequest();
        const authHeader = request.headers.authorization;

        if (!authHeader) {
            throw new UnauthorizedException('No authorization header provided');
        }

        const token = authHeader.replace('Bearer ', '');

        if (!token) {
            throw new UnauthorizedException('No token provided');
        }

        try {
            const { data: { user }, error } = await this.supabase.auth.getUser(token);

            if (error) {
                this.logger.error('❌ Supabase auth error:', error.message);
                throw new UnauthorizedException('Invalid or expired token');
            }

            if (!user) {
                throw new UnauthorizedException('User not found');
            }

            // Attach user to request for use in controllers
            request.user = user;
            this.logger.log(`✅ Authenticated user: ${user.email}`);

            return true;
        } catch (error) {
            if (error instanceof UnauthorizedException) {
                throw error;
            }
            this.logger.error('❌ Authentication error:', error);
            throw new UnauthorizedException('Authentication failed');
        }
    }
}
