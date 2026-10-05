# AOT Water & Sanitation Board Meter Reading System Blueprint

## 1. Project overview

This system is designed for AOT Water and Sanitation Board to record and manage water meter readings automatically, without relying on manual paper-based recording by technical officers.

The project addresses the following core issues:
- manual meter reading errors
- mixed-up meter numbers and index numbers
- collection of inaccurate readings
- delayed bill generation
- poor data reconciliation
- lack of automated anomaly detection
- difficulty updating price and tariff changes without damaging historical billing records

The solution uses a mobile application for field officers, OCR to read analog meter values from captured images, a separate database for customer and billing records, and a tariff-based billing engine.

---

## 2. Business goals

The system must:
- track each customer and meter accurately
- store customer name, account number, meter number, and index number in one structured system
- let field officers capture readings from analog meters physically
- use OCR to reduce manual errors
- validate readings before saving to the database
- detect abnormal readings and unreadable meters in real time
- calculate bills automatically
- support price changes without overwriting historical billing records
- keep data independent from the existing IT department database

---

## 3. Key business problem

The current manual process creates several problems:
- technical officers walk from meter to meter and record numbers by hand
- meter numbers or index numbers may be typed incorrectly
- readings can be mixed between customers
- consumption calculations become inaccurate
- billing is delayed or disputed
- historical records are hard to reconcile

This system replaces that manual process with a structured and auditable digital workflow.

---

## 4. Proposed solution

The final design uses a digital workflow built around these components:

### 4.1 Mobile app for field officers
The app captures:
- meter number
- customer name
- account number
- index number
- service area
- service type
- current reading
- previous reading
- timestamp
- GPS location
- photo of meter display

### 4.2 OCR-based reading capture
The app reads the analog meter digits from a photo using OCR. If the reading is too unclear or the confidence is low, the officer is asked to retake the image.

### 4.3 Validation and anomaly detection
Before storing a reading, the system checks:
- whether the meter exists
- whether the customer matches the meter
- whether the reading is lower than previous months
- whether the reading is unreasonably high
- whether the image is unreadable
- whether route completion is missing

### 4.4 Separate database
The system keeps its own independent database for:
- customers
- accounts
- meters
- readings
- tariffs
- bills
- alerts
- routes

### 4.5 Billing engine
The billing engine calculates:
- consumption = current reading - previous reading
- tariff = effective tariff for service type and billing period
- amount due = (consumption × rate per unit) + fixed charge
- total due = amount due + previous balance

### 4.6 Alert system
The system sends alerts for:
- unreadable meter
- abnormal reading
- missing reading
- wrong meter match
- route not completed
- billing inconsistencies

---

## 5. System architecture

The project is divided into the following layers:

### Layer 1: Field Capture
- mobile app
- officer login
- route assignment
- meter search
- photo capture
- OCR reading

### Layer 2: Validation Layer
- meter lookup
- customer-meter validation
- OCR confidence check
- previous reading comparison
- anomaly detection

### Layer 3: Application Layer
- reading submission API
- customer and meter APIs
- bill generation service
- tariff service
- alert service

### Layer 4: Data Layer
- PostgreSQL database
- customer data
- account data
- meter records
- readings history
- tariffs
- bills
- alerts

### Layer 5: Reporting Layer
- route status reports
- monthly bill summary
- overdue balances
- meter anomalies
- tariff history
- officer performance reports

---

## 6. Customer-to-meter relationship

This is a crucial design rule for the whole system.

### 6.1 Each customer must be mapped to a meter
The system should record the mapping clearly:
- customer record
- customer account number
- meter number
- index number
- service area
- service type

### 6.2 Meter number is the operational key
The meter number should be treated as the main identifier during field collection because it is the most reliable operational key.

### 6.3 Customer name is for display and lookup
Customer name helps users identify the record, but the system should also store and validate the meter number, account number, and index number.

### 6.4 Index number is a reference field
The index number should be stored for reconciliation and matching with the old manual records or the board’s existing paper sheets.

---

## 7. Core data model

### 7.1 Customer table

```sql
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_number VARCHAR(100) UNIQUE NOT NULL,
    account_number VARCHAR(100) UNIQUE,
    customer_name VARCHAR(255) NOT NULL,
    address TEXT,
    plot_no VARCHAR(100),
    service_area VARCHAR(255),
    service_type VARCHAR(100),
    index_number VARCHAR(100),
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### 7.2 Meter table

```sql
CREATE TABLE meters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meter_number VARCHAR(100) UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES customers(id),
    installation_date DATE,
    service_area VARCHAR(255),
    meter_status VARCHAR(50) DEFAULT 'active',
    current_reading NUMERIC(18,3),
    previous_reading NUMERIC(18,3),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### 7.3 Meter reading table

```sql
CREATE TABLE meter_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meter_id UUID NOT NULL REFERENCES meters(id),
    customer_id UUID NOT NULL REFERENCES customers(id),
    officer_id UUID,
    reading_date TIMESTAMP NOT NULL,
    previous_reading NUMERIC(18,3),
    current_reading NUMERIC(18,3),
    consumption NUMERIC(18,3),
    gps_latitude DOUBLE PRECISION,
    gps_longitude DOUBLE PRECISION,
    photo_path TEXT,
    ocr_confidence NUMERIC(5,2),
    validation_status VARCHAR(50) DEFAULT 'pending',
    anomaly_status VARCHAR(50) DEFAULT 'normal',
    source VARCHAR(50) DEFAULT 'mobile_app',
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 7.4 Tariff table

```sql
CREATE TABLE tariffs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_type VARCHAR(100) NOT NULL,
    rate_per_unit NUMERIC(12,4) NOT NULL,
    fixed_charge NUMERIC(12,2) DEFAULT 0,
    effective_from DATE NOT NULL,
    effective_to DATE,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 7.5 Bill table

```sql
CREATE TABLE bills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id),
    meter_id UUID NOT NULL REFERENCES meters(id),
    tariff_id UUID REFERENCES tariffs(id),
    billing_period VARCHAR(50) NOT NULL,
    previous_reading NUMERIC(18,3),
    current_reading NUMERIC(18,3),
    consumption NUMERIC(18,3),
    previous_balance NUMERIC(12,2) DEFAULT 0,
    amount_due NUMERIC(12,2) NOT NULL,
    total_due NUMERIC(12,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    issued_at TIMESTAMP DEFAULT NOW(),
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 7.6 Alert table

```sql
CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meter_id UUID REFERENCES meters(id),
    customer_id UUID REFERENCES customers(id),
    alert_type VARCHAR(100) NOT NULL,
    severity VARCHAR(50) DEFAULT 'medium',
    message TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'open',
    created_at TIMESTAMP DEFAULT NOW(),
    resolved_at TIMESTAMP
);
```

### 7.7 Officer table

```sql
CREATE TABLE officers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    officer_name VARCHAR(255) NOT NULL,
    employee_number VARCHAR(100),
    phone VARCHAR(50),
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 7.8 Route table

```sql
CREATE TABLE routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_name VARCHAR(255),
    assigned_officer_id UUID REFERENCES officers(id),
    service_area VARCHAR(255),
    scheduled_date DATE,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 7.9 Route meter table

```sql
CREATE TABLE route_meters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_id UUID NOT NULL REFERENCES routes(id),
    meter_id UUID NOT NULL REFERENCES meters(id),
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 8. Core data fields from the manual sheet

The fields shown in the sheet should be mapped directly into the system.

### 8.1 Customer fields
- customer number
- account number
- customer name
- address
- plot no
- service area
- service type
- index number

### 8.2 Meter fields
- meter number
- current reading
- previous reading
- consumption
- billing period
- amount

### 8.3 Billing fields
- previous balance
- amount due
- total due
- service area
- service type

---

## 9. Reading workflow

### Step 1: Officer logs in
The officer logs in to the app and sees their assigned route.

### Step 2: Select meter
The officer selects a meter from the list or scans the meter number.

### Step 3: Capture photo
The phone camera captures a clear image of the analog meter display.

### Step 4: OCR extraction
The app extracts the digits from the meter image.

### Step 5: Validation
The backend checks:
- meter exists
- customer matches meter
- reading is not less than a previous valid reading
- meter number is valid
- OCR confidence is acceptable

### Step 6: Submit reading
If validation passes, the reading is submitted.

### Step 7: Anomaly check
The system checks the reading for abnormalities and generates an alert if needed.

### Step 8: Bill generation
At the end of the billing cycle, bills are generated automatically.

---

## 10. OCR workflow

### OCR rules
- read only numeric values from meter images
- ignore non-numeric symbols
- reject unreadable images
- ask officer to re-take if confidence is too low
- store image for evidence and audit

### OCR validation
- if confidence is below threshold, set status to `requires_retake`
- if reading is empty, set status to `unreadable`
- if meter number mismatches, set alert type `meter_mismatch`
- if reading does not make sense, set `anomaly_status = high` or `low`

---

## 11. Anomaly detection rules

### 11.1 Low reading anomaly
If the current reading is lower than previous reading, trigger an alert.

### 11.2 High spike anomaly
If consumption is much higher than normal, trigger a high anomaly alert.

### 11.3 Missing reading
If a meter is scheduled but no reading is captured, raise a missing reading alert.

### 11.4 Unreadable meter
If OCR fails repeatedly or the image is too unclear, raise a meter unreadable alert.

### 11.5 Meter mismatch
If the captured meter number does not belong to the assigned customer or route, raise a mismatch alert.

### 11.6 Duplicate reading
If the same reading is captured repeatedly without changes, flag it.

---

## 12. Alert structure

Each alert should include:
- alert_id
- meter_id
- customer_id
- alert_type
- severity
- message
- status
- created_at
- resolved_at

### Alert examples
- meter_unreadable
- reading_anomaly
- route_missed
- invalid_meter_match
- high_consumption
- no_reading_submitted

---

## 13. Bill calculation logic

### Formula
```
consumption = current_reading - previous_reading
bill_amount = (consumption × rate_per_unit) + fixed_charge
total_due = bill_amount + previous_balance
```

### Example
- previous reading = 4380
- current reading = 4800
- consumption = 420
- rate per unit = 3.25
- fixed charge = 1200
- bill amount = (420 × 3.25) + 1200 = 1365 + 1200 = 2565

### Important rules
- if current reading is lower than previous reading, do not compute a valid bill automatically
- if meter is unreadable, bill is not generated until reading is corrected
- if there are multiple tariffs in the period, use the effective tariff for the reading month

---

## 14. Tariff management and price change model

This is one of the most important business rules.

### 14.1 Rule: never overwrite old tariffs
When a price changes, the system must create a new tariff record instead of replacing the existing one.

### 14.2 Each tariff must contain effective dates
The tariff record should hold:
- service type
- rate per unit
- fixed charge
- effective_from
- effective_to
- status

### 14.3 Billing engine selects the active tariff
When generating a bill, the system chooses the tariff whose effective period contains the billing date.

### 14.4 Tariff history is preserved
This ensures the system can always recreate old bills and audit historic tariffs.

### 14.5 Example
```sql
INSERT INTO tariffs (service_type, rate_per_unit, fixed_charge, effective_from, effective_to, status)
VALUES ('Domestic', 2.80, 1000, '2025-01-01', '2026-09-30', 'inactive');

INSERT INTO tariffs (service_type, rate_per_unit, fixed_charge, effective_from, effective_to, status)
VALUES ('Domestic', 3.25, 1200, '2026-10-01', NULL, 'active');
```

This means:
- September 2026 still uses the old tariff
- October 2026 and beyond use the new tariff
- historical records remain valid

---

## 15. API design

### 15.1 Customer endpoints
- POST /api/customers
- GET /api/customers/:id
- GET /api/customers/search?q=...
- GET /api/customers/by-meter/:meterNumber

### 15.2 Meter endpoints
- POST /api/meters
- GET /api/meters/:id
- GET /api/meters/by-customer/:customerId
- GET /api/meters/by-number/:meterNumber

### 15.3 Reading endpoints
- POST /api/readings
- POST /api/readings/ocr
- GET /api/readings/:meterId
- GET /api/readings/latest/:meterId

### 15.4 Bill endpoints
- POST /api/bills/generate
- GET /api/bills/:customerId
- GET /api/bills/:meterId/:billingPeriod

### 15.5 Tariff endpoints
- POST /api/tariffs
- GET /api/tariffs/active?serviceType=Domestic&date=2026-10-01
- GET /api/tariffs/history

### 15.6 Alert endpoints
- GET /api/alerts
- POST /api/alerts/resolve/:id

### 15.7 Route endpoints
- GET /api/routes
- POST /api/routes
- POST /api/routes/:id/assign

---

## 16. Mobile app design

### 16.1 Screens
- Login screen
- Dashboard
- Route list
- Meter details screen
- Meter photo capture screen
- OCR validation screen
- Reading confirmation screen
- Alerts list screen
- Reports screen

### 16.2 Required fields on the reading form
- meter number
- customer name
- account number
- index number
- service area
- service type
- current reading
- previous reading
- reading date
- GPS location
- photo
- note or reason for re-read

### 16.3 Reading confirmation flow
After OCR returns a result, the app shows:
- extracted reading
- confidence score
- previous reading
- difference from previous reading
- button to accept or retake

---

## 17. Reporting dashboard

### 17.1 Summary cards
- total meters registered
- meters read today
- unreadable meters
- anomalies detected
- pending bills
- total billed amount
- total unpaid amount

### 17.2 Report sections
- daily route completion
- meter anomalies by area
- largest consumption increases
- customer payment status
- tariff changes log
- unreadable meter list
- officer performance

---

## 18. Security and access control

### Roles
- Field officer
- Supervisor
- Billing officer
- Finance officer
- System administrator

### Permissions
- field officers can submit readings and upload meter images
- supervisors can review reading anomalies and route performance
- billing officers can generate and review bills
- finance officers can review payment status
- administrators manage tariffs, users, and configuration

---

## 19. Risk management

### Main risks and mitigation

#### OCR errors
Mitigation:
- require retake on low confidence
- compare with previous reading
- store the image as proof

#### Wrong meter mapping
Mitigation:
- validate meter number before saving
- match with customer account
- create mismatch alert

#### Incomplete route coverage
Mitigation:
- route tracking
- scheduled meters dashboard
- alert for missed visits

#### Inaccurate billing due to tariff changes
Mitigation:
- versioned tariff records
- effective dates on tariffs
- historical billing preserved

#### Data loss
Mitigation:
- backups
- regular audit trails
- transactional database writes

---

## 20. Implementation plan

### Phase 1: Requirements and data mapping
- map all customer fields from the manual sheet
- define meter and customer relationships
- confirm service types and tariff structure

### Phase 2: Core database and APIs
- create customer table
- create meter table
- create readings table
- create tariff and bill tables
- create API endpoints

### Phase 3: Mobile app
- login screen
- route view
- meter capture form
- photo upload and OCR validation
- submission and confirmation

### Phase 4: Anomaly engine
- previous reading comparison
- alert logic
- unreadable meter rules
- route completion checks

### Phase 5: Bill engine
- calculate consumption
- apply active tariff
- generate bills
- store payment status

### Phase 6: Reporting and dashboards
- route performance summary
- bill summary
- anomalies and exceptions
- officer reports

### Phase 7: Pilot rollout
- test with a few routes and several meters
- compare manual readings with system readings
- adjust OCR thresholds and validation rules
- rollout to larger area

---

## 21. Recommended final workflow for AOT

The final recommended workflow is:

Customer and meter registration
→ route creation
→ officer assignment
→ meter reading capture by mobile app
→ OCR extraction and validation
→ anomaly detection
→ reading saved
→ monthly bill generated automatically
→ tariff applied by effective date
→ alerts sent to supervisors when needed

---

## 22. Final recommendation

The correct approach for AOT Water and Sanitation Board is:
- mobile app with OCR
- separate database from the IT department system
- customer-to-meter mapping
- meter number as primary operational key
- index number stored for reconciliation
- automatic consumption and bill calculation
- tariff versioning for any future price updates
- real-time alerts for anomalies and unreadable meters

This design is practical, scalable, and suitable for a district with approximately 1,000 meters.

---

## 23. Execution summary

The system must be designed around these principles:
1. Meter number is the primary key in the field
2. Customer details are linked to the meter and account
3. Readings are captured digitally and validated
4. Bill generation is automated and tariff-based
5. Tariffs are versioned and historical billing is preserved
6. Alerts are generated in real time for suspicious or missing readings
7. The solution is independent from the IT department’s existing system

---

## 24. What should happen next

The next practical steps are:
- create the actual database schema in SQL
- implement the API endpoints
- build the mobile app screens
- implement OCR and validation logic
- create the billing engine
- connect tariff versioning rules
- create reports and dashboard

This blueprint is the foundation for the implementation and should prevent later confusion or design drift.
