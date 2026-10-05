require('dotenv').config();

module.exports = {
  database: {
    host: process.env.DATABASE_HOST || 'localhost',
    port: Number(process.env.DATABASE_PORT || 5432),
    database: process.env.DATABASE_NAME || 'aot_meter_db',
    user: process.env.DATABASE_USER || 'postgres',
    password: process.env.DATABASE_PASSWORD || 'password',
    connectionString: process.env.DATABASE_URL || null
  },
  server: {
    port: Number(process.env.PORT || 4000),
    env: process.env.NODE_ENV || 'development'
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'super-secret-key-change-me',
    expiry: process.env.JWT_EXPIRY || '7d'
  },
  ocr: {
    confidenceThreshold: Number(process.env.OCR_CONFIDENCE_THRESHOLD || 0.85)
  }
};
