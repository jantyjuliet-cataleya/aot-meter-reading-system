# AOT Water & Sanitation Board Meter Reading System

This repository contains a practical implementation skeleton for an automated meter-reading system designed for AOT Water and Sanitation Board.

## Objectives
- Replace manual paper-based readings with a mobile-first data capture workflow
- Use OCR on meter photos to reduce transcription errors
- Detect abnormal readings in real time
- Calculate bills automatically using a versioned tariff system
- Keep the system independent from the IT department's existing database

## System summary
The deployed solution uses:
- A mobile app for field officers to capture readings from analog meters
- OCR processing to read the numeric meter index from a photo
- A backend API to validate readings, store them securely, and detect anomalies
- A pricing engine with versioned tariffs so bills can be recalculated when tariffs change
- Email/SMS alerts to notify staff when a meter is unreadable, abnormal, or missing

## Recommended architecture
- Mobile app: Android/iOS (React Native / Expo)
- Backend: Node.js + Express
- OCR: Tesseract.js or Cloud OCR service
- Database: PostgreSQL or SQLite for this project (separate from the IT department system)
- Storage: local file or object storage for meter photos

## Repository structure
- `backend/` — API, pricing logic, OCR service, billing engine
- `mobile-app/` — mobile app skeleton for field officers
- `docs/` — architecture and requirements notes

## Quick start

### 1. Backend
```bash
cd backend
npm install
npm run dev
```

### 2. Mobile app
```bash
cd mobile-app
npm install
npm start
```

## Key pricing update mechanism
Price changes are managed through a versioned tariff schedule. Each tariff has:
- `effectiveFrom`
- `effectiveTo`
- `rate`
- `fixedCharge`
- `status`

When a tariff is updated, a new record is created instead of overwriting the old one. The system always selects the active tariff for the reading date. This allows historical readings to remain intact while future bills use the newest approved prices.

See `docs/pricing-model.md` for details.

## Main API routes
- `GET /api/health`
- `POST /api/readings/scan`
- `POST /api/readings`
- `GET /api/pricing/active`
- `POST /api/pricing/update`
- `GET /api/bills/:meterId`

## Notes
This repository intentionally provides a production-ready project skeleton rather than a monolithic, hard-coded implementation. It is suitable for adapting into a real operational system for AOT Water and Sanitation Board.
