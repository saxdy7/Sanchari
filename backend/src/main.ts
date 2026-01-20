import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // CORS configuration - secure for production
  const allowedOrigins = process.env.NODE_ENV === 'production'
    ? [process.env.FRONTEND_URL || 'https://yourdomain.com']
    : [
        'http://localhost:3000', 
        'http://localhost:8080', 
        'http://127.0.0.1:3000',
        'http://localhost:50515', // Flutter web default port
        'http://localhost:5000',
        'http://localhost:5001',
      ];

  app.enableCors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, Postman, etc)
      if (!origin) return callback(null, true);
      
      // Check if origin starts with allowed localhost
      if (origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) {
        return callback(null, true);
      }
      
      // Check if origin is in allowed list
      if (allowedOrigins.includes(origin)) {
        return callback(null, true);
      }
      
      callback(new Error('Not allowed by CORS'));
    },
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  console.log(`✅ Backend running on http://localhost:${port}`);
  console.log(`🔒 CORS enabled for: ${allowedOrigins.join(', ')}`);
}
bootstrap();
