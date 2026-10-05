# System Design

This document explains the operational logic behind the meter-reading system.

## 1. Mobile app with OCR for analog meters
Technical officers visit each meter physically. They open the mobile app and take a photo of the meter display. The app captures:
- meter number
- photo of the dial
- GPS location
- timestamp
- officer ID

The OCR engine reads the numeric index from the image and verifies that it looks valid. If OCR confidence is low, the app asks the officer to re-take the photo.

### Flow
1. Officer selects a route or meter
2. App opens camera
3. Photo is captured
4. OCR extracts reading digits
5. Reading is validated
6. Reading is submitted to the backend
7. Backend checks for anomalies and stores the record

## 2. Anomaly detection
The system compares the new reading with the previous reading for the same meter. Rules include:
- negative reading value
- reading decrease without a valid reason
- jump greater than expected baseline
- repeated identical reading within a short time
- missing reading for a scheduled visit

If any rule is triggered, the system sends an alert.

## 3. Missing or unreadable meter
When OCR fails or the officer cannot read a meter, the app sends a `meter_unreadable` status and creates a task in the system. The dispatcher receives a real-time alert.

## 4. Pricing model and tariff updates
Tariffs are stored in a versioned table. Example:
```json
{
  "meterType": "domestic",
  "ratePerUnit": 3.25,
  "fixedCharge": 1200,
  "effectiveFrom": "2026-10-01",
  "effectiveTo": null,
  "status": "active"
}
```

When the board changes prices:
1. A new tariff version is entered with a future `effectiveFrom` date
2. The old rate remains historical
3. The billing engine uses the newest active tariff for all new bills
4. Past bills remain unchanged because historical tariff records are preserved

This is how the system keeps billing accurate without losing accounting history.

## 5. Bill calculation logic
```
consumption = currentReading - previousReading
bill = (consumption * tariff.ratePerUnit) + tariff.fixedCharge
```
If the reading is negative or invalid, no bill is generated until the reading is corrected.

## 6. Data separation
This system keeps its own database and does not depend on the IT department's database. It is an independent source of truth for customer readings and billing operations.
