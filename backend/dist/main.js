"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const app_module_1 = require("./app.module");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
    }));
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
            if (origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) {
                return callback(null, true);
            }
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
//# sourceMappingURL=main.js.map