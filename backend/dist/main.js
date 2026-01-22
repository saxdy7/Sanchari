"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const app_module_1 = require("./app.module");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
    }));
    const config = new swagger_1.DocumentBuilder()
        .setTitle('Sanchari API')
        .setDescription('Personal AI Trip Planner for India - Backend API')
        .setVersion('1.0')
        .addBearerAuth({
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Enter JWT token from Supabase authentication',
    }, 'JWT-auth')
        .addTag('trip', 'Trip planning and itinerary generation')
        .addTag('search', 'Destination search and discovery')
        .build();
    const document = swagger_1.SwaggerModule.createDocument(app, config);
    swagger_1.SwaggerModule.setup('api', app, document, {
        customSiteTitle: 'Sanchari API Docs',
        customCss: '.swagger-ui .topbar { display: none }',
    });
    const allowedOrigins = process.env.NODE_ENV === 'production'
        ? [process.env.FRONTEND_URL || 'https://yourdomain.com']
        : [
            'http://localhost:3000',
            'http://localhost:8080',
            'http://127.0.0.1:3000',
            'http://localhost:50515',
            'http://localhost:5000',
            'http://localhost:5001',
        ];
    app.enableCors({
        origin: (origin, callback) => {
            if (!origin)
                return callback(null, true);
            if (process.env.NODE_ENV !== 'production') {
                if (origin.startsWith('http://localhost:') ||
                    origin.startsWith('http://127.0.0.1:') ||
                    origin.startsWith('https://localhost:') ||
                    origin.startsWith('https://127.0.0.1:')) {
                    return callback(null, true);
                }
            }
            if (allowedOrigins.includes(origin)) {
                return callback(null, true);
            }
            console.warn(`⚠️  CORS rejected origin: ${origin}`);
            callback(null, false);
        },
        methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
        credentials: true,
    });
    const port = process.env.PORT ?? 3000;
    await app.listen(port, '0.0.0.0');
    const os = require('os');
    const networkInterfaces = os.networkInterfaces();
    let localIP = 'localhost';
    for (const interfaceName in networkInterfaces) {
        for (const iface of networkInterfaces[interfaceName]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                localIP = iface.address;
                break;
            }
        }
    }
    console.log(`✅ Backend running on:`);
    console.log(`   - Local:   http://localhost:${port}`);
    console.log(`   - Network: http://${localIP}:${port} (use this for mobile)`);
    console.log(`📚 Swagger docs available at http://localhost:${port}/api`);
    console.log(`🔒 CORS enabled for: ${allowedOrigins.join(', ')}`);
}
bootstrap();
//# sourceMappingURL=main.js.map