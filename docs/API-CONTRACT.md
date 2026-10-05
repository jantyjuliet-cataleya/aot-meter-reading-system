# AOT Water & Sanitation Board - API Contract

## Overview

This document defines the REST API contract for the AOT meter reading system. All endpoints follow RESTful principles and return JSON responses.

### Base URL
```
http://localhost:4000/api
```

### Authentication
All requests should include an authorization header:
```
Authorization: Bearer <token>
```

### Response Format
All successful responses return a 200 status with:
```json
{
  "success": true,
  "data": { /* response payload */ },
  "message": "Operation successful"
}
```

Error responses return appropriate status codes with:
```json
{
  "success": false,
  "error": "Error description",
  "code": "ERROR_CODE"
}
```

---

## Customer Management

### 1. Create Customer
**POST** `/customers`

**Request Body:**
```json
{
  "customer_number": "CUST/AP/2012-001",
  "account_number": "2012-5708-AP-001",
  "customer_name": "Org. Abokobi Presby Mission",
  "address": "P.O. Box 155",
  "plot_no": "001",
  "service_area": "Abokobi",
  "service_type": "Domestic",
  "index_number": "5"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid-string",
    "customer_number": "CUST/AP/2012-001",
    "account_number": "2012-5708-AP-001",
    "customer_name": "Org. Abokobi Presby Mission",
    "address": "P.O. Box 155",
    "plot_no": "001",
    "service_area": "Abokobi",
    "service_type": "Domestic",
    "index_number": "5",
    "status": "active",
    "created_at": "2026-10-05T10:00:00Z"
  }
}
```

---

### 2. Get Customer by ID
**GET** `/customers/:customerId`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid-string",
    "customer_number": "CUST/AP/2012-001",
    "account_number": "2012-5708-AP-001",
    "customer_name": "Org. Abokobi Presby Mission",
    "address": "P.O. Box 155",
    "plot_no": "001",
    "service_area": "Abokobi",
    "service_type": "Domestic",
    "index_number": "5",
    "status": "active",
    "created_at": "2026-10-05T10:00:00Z"
  }
}
```

---

### 3. Search Customers
**GET** `/customers/search?q=Abokobi&limit=10&offset=0`

**Query Parameters:**
- `q` (string): Search query (customer name, number, or account number)
- `limit` (integer): Max results (default: 10)
- `offset` (integer): Pagination offset (default: 0)
- `service_area` (string): Filter by service area
- `service_type` (string): Filter by service type
- `status` (string): Filter by status

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid-string",
      "customer_number": "CUST/AP/2012-001",
      "customer_name": "Org. Abokobi Presby Mission",
      "account_number": "2012-5708-AP-001",
      "index_number": "5",
      "service_area": "Abokobi",
      "service_type": "Domestic",
      "status": "active"
    }
  ],
  "pagination": {
    "total": 15,
    "limit": 10,
    "offset": 0,
    "hasMore": true
  }
}
```

---

### 4. Get Customer by Meter Number
**GET** `/customers/by-meter/:meterNumber`

**Response:** Same as Get Customer by ID

---

### 5. Update Customer
**PUT** `/customers/:customerId`

**Request Body:** Same fields as Create Customer (only non-null fields will be updated)

**Response:** Same as Get Customer by ID

---

## Meter Management

### 1. Create Meter
**POST** `/meters`

**Request Body:**
```json
{
  "meter_number": "88-696786",
  "customer_id": "customer-uuid",
  "installation_date": "2020-01-15",
  "service_area": "Abokobi",
  "meter_status": "active"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "meter-uuid",
    "meter_number": "88-696786",
    "customer_id": "customer-uuid",
    "installation_date": "2020-01-15",
    "service_area": "Abokobi",
    "meter_status": "active",
    "current_reading": null,
    "previous_reading": null,
    "created_at": "2026-10-05T10:00:00Z"
  }
}
```

---

### 2. Get Meter by ID
**GET** `/meters/:meterId`

**Response:** Same as Create Meter response

---

### 3. Get Meter by Number
**GET** `/meters/by-number/:meterNumber`

**Response:** Same as Create Meter response

---

### 4. Get Meters by Customer
**GET** `/meters/by-customer/:customerId?limit=10&offset=0`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "meter-uuid",
      "meter_number": "88-696786",
      "customer_id": "customer-uuid",
      "service_area": "Abokobi",
      "meter_status": "active",
      "current_reading": 4800,
      "previous_reading": 4380
    }
  ],
  "pagination": {
    "total": 1,
    "limit": 10,
    "offset": 0,
    "hasMore": false
  }
}
```

---

### 5. Update Meter
**PUT** `/meters/:meterId`

**Request Body:** Same fields as Create Meter (only non-null fields will be updated)

**Response:** Same as Get Meter by ID

---

## Meter Readings

### 1. Submit Meter Reading
**POST** `/readings`

**Request Body:**
```json
{
  "meter_id": "meter-uuid",
  "customer_id": "customer-uuid",
  "officer_id": "officer-uuid",
  "reading_date": "2026-10-05T08:30:00Z",
  "current_reading": 4800,
  "gps_latitude": 5.6031,
  "gps_longitude": -0.2304,
  "photo_path": "/uploads/4800.jpg",
  "ocr_confidence": 0.95,
  "notes": "Clear meter reading"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "reading-uuid",
    "meter_id": "meter-uuid",
    "customer_id": "customer-uuid",
    "officer_id": "officer-uuid",
    "reading_date": "2026-10-05T08:30:00Z",
    "previous_reading": 4380,
    "current_reading": 4800,
    "consumption": 420,
    "gps_latitude": 5.6031,
    "gps_longitude": -0.2304,
    "ocr_confidence": 0.95,
    "validation_status": "validated",
    "anomaly_status": "normal",
    "source": "mobile_app",
    "created_at": "2026-10-05T08:30:00Z"
  }
}
```

---

### 2. OCR Scan Reading
**POST** `/readings/ocr`

**Request:** Form data with image file
```
Content-Type: multipart/form-data

Field: image (binary file)
Field: meter_number (string)
```

**Response:**
```json
{
  "success": true,
  "data": {
    "rawValue": "4800",
    "reading": 4800,
    "confidence": 0.98,
    "status": "ok",
    "imagePath": "/uploads/ocr/4800_2026-10-05.jpg"
  }
}
```

---

### 3. Get Latest Reading for Meter
**GET** `/readings/latest/:meterId`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "reading-uuid",
    "meter_id": "meter-uuid",
    "customer_id": "customer-uuid",
    "reading_date": "2026-10-05T08:30:00Z",
    "previous_reading": 4380,
    "current_reading": 4800,
    "consumption": 420,
    "validation_status": "validated",
    "anomaly_status": "normal"
  }
}
```

---

### 4. Get Reading History for Meter
**GET** `/readings/history/:meterId?limit=12&offset=0`

**Query Parameters:**
- `limit` (integer): Max results (default: 12)
- `offset` (integer): Pagination offset (default: 0)
- `start_date` (string): ISO date for filtering
- `end_date` (string): ISO date for filtering

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "reading-uuid",
      "reading_date": "2026-10-05T08:30:00Z",
      "previous_reading": 4380,
      "current_reading": 4800,
      "consumption": 420
    }
  ],
  "pagination": {
    "total": 24,
    "limit": 12,
    "offset": 0,
    "hasMore": true
  }
}
```

---

## Tariff Management

### 1. Create Tariff
**POST** `/tariffs`

**Request Body:**
```json
{
  "service_type": "Domestic",
  "rate_per_unit": 3.25,
  "fixed_charge": 1200,
  "water_expansion_percentage": 2,
  "fire_fighting_percentage": 1,
  "effective_from": "2026-10-01",
  "effective_to": null,
  "status": "active"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "tariff-uuid",
    "service_type": "Domestic",
    "rate_per_unit": 3.25,
    "fixed_charge": 1200,
    "water_expansion_percentage": 2,
    "fire_fighting_percentage": 1,
    "effective_from": "2026-10-01",
    "effective_to": null,
    "status": "active",
    "created_at": "2026-10-05T10:00:00Z"
  }
}
```

---

### 2. Get Active Tariff
**GET** `/tariffs/active?serviceType=Domestic&date=2026-10-05`

**Query Parameters:**
- `serviceType` (string, required): Service type
- `date` (string, optional): ISO date (defaults to today)

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "tariff-uuid",
    "service_type": "Domestic",
    "rate_per_unit": 3.25,
    "fixed_charge": 1200,
    "water_expansion_percentage": 2,
    "fire_fighting_percentage": 1,
    "effective_from": "2026-10-01",
    "effective_to": null,
    "status": "active"
  }
}
```

---

### 3. Get Tariff History
**GET** `/tariffs/history?serviceType=Domestic&limit=10&offset=0`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "tariff-uuid",
      "service_type": "Domestic",
      "rate_per_unit": 2.80,
      "fixed_charge": 1000,
      "effective_from": "2025-01-01",
      "effective_to": "2026-09-30",
      "status": "inactive"
    },
    {
      "id": "tariff-uuid-2",
      "service_type": "Domestic",
      "rate_per_unit": 3.25,
      "fixed_charge": 1200,
      "effective_from": "2026-10-01",
      "effective_to": null,
      "status": "active"
    }
  ],
  "pagination": {
    "total": 2,
    "limit": 10,
    "offset": 0,
    "hasMore": false
  }
}
```

---

## Billing

### 1. Calculate Bill
**POST** `/bills/calculate`

**Request Body:**
```json
{
  "customer_id": "customer-uuid",
  "meter_id": "meter-uuid",
  "billing_period": "2026-10",
  "previous_reading": 4380,
  "current_reading": 4800,
  "service_type": "Domestic"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "customer_id": "customer-uuid",
    "meter_id": "meter-uuid",
    "billing_period": "2026-10",
    "previous_reading": 4380,
    "current_reading": 4800,
    "consumption": 420,
    "rate_per_unit": 3.25,
    "fixed_charge": 1200,
    "base_amount": 2565,
    "water_expansion": 51.30,
    "fire_fighting": 25.65,
    "previous_balance": 0,
    "amount_due": 2641.95,
    "total_due": 2641.95,
    "status": "calculated"
  }
}
```

---

### 2. Generate Bills for Billing Period
**POST** `/bills/generate-period`

**Request Body:**
```json
{
  "billing_period": "2026-10",
  "service_area": "Abokobi",
  "service_type": "Domestic"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "billing_period": "2026-10",
    "bills_generated": 25,
    "bills_failed": 2,
    "total_amount": 85500.75,
    "details": [
      {
        "customer_id": "customer-uuid",
        "status": "generated",
        "amount_due": 2641.95
      }
    ]
  }
}
```

---

### 3. Get Bill
**GET** `/bills/:billId`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "bill-uuid",
    "customer_id": "customer-uuid",
    "meter_id": "meter-uuid",
    "billing_period": "2026-10",
    "previous_reading": 4380,
    "current_reading": 4800,
    "consumption": 420,
    "rate_per_unit": 3.25,
    "fixed_charge": 1200,
    "base_amount": 2565,
    "water_expansion": 51.30,
    "fire_fighting": 25.65,
    "previous_balance": 0,
    "amount_due": 2641.95,
    "total_due": 2641.95,
    "status": "pending",
    "issued_at": "2026-10-05T10:00:00Z",
    "due_date": "2026-10-31",
    "paid_at": null
  }
}
```

---

### 4. Get Bills for Customer
**GET** `/customers/:customerId/bills?limit=12&offset=0&status=all`

**Query Parameters:**
- `limit` (integer): Max results (default: 12)
- `offset` (integer): Pagination offset (default: 0)
- `status` (string): Filter by status (pending, paid, overdue, all)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "bill-uuid",
      "billing_period": "2026-10",
      "amount_due": 2641.95,
      "total_due": 2641.95,
      "status": "pending",
      "issued_at": "2026-10-05T10:00:00Z"
    }
  ],
  "pagination": {
    "total": 24,
    "limit": 12,
    "offset": 0,
    "hasMore": true
  },
  "summary": {
    "total_pending": 5264.85,
    "total_paid": 15000.00,
    "total_overdue": 2641.95
  }
}
```

---

### 5. Record Payment
**POST** `/bills/:billId/pay`

**Request Body:**
```json
{
  "amount_paid": 2641.95,
  "payment_method": "cash",
  "payment_reference": "REF-2026-10-001"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "bill-uuid",
    "billing_period": "2026-10",
    "amount_due": 2641.95,
    "paid_amount": 2641.95,
    "status": "paid",
    "paid_at": "2026-10-05T10:15:00Z"
  }
}
```

---

## Alerts

### 1. Get Alerts
**GET** `/alerts?status=open&severity=high&limit=20&offset=0`

**Query Parameters:**
- `status` (string): Filter by status (open, resolved, all)
- `severity` (string): Filter by severity (low, medium, high, critical)
- `alert_type` (string): Filter by alert type
- `limit` (integer): Max results (default: 20)
- `offset` (integer): Pagination offset (default: 0)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "alert-uuid",
      "meter_id": "meter-uuid",
      "customer_id": "customer-uuid",
      "alert_type": "meter_unreadable",
      "severity": "high",
      "message": "Meter AOT-1048 could not be read. OCR confidence was too low.",
      "status": "open",
      "created_at": "2026-10-05T08:30:00Z"
    }
  ],
  "pagination": {
    "total": 15,
    "limit": 20,
    "offset": 0,
    "hasMore": false
  },
  "summary": {
    "total_open": 15,
    "critical_count": 2,
    "high_count": 5,
    "medium_count": 8
  }
}
```

---

### 2. Resolve Alert
**POST** `/alerts/:alertId/resolve`

**Request Body:**
```json
{
  "resolved_by": "officer-uuid",
  "resolution_notes": "Re-read meter successfully"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "alert-uuid",
    "status": "resolved",
    "resolved_at": "2026-10-05T09:00:00Z",
    "resolution_notes": "Re-read meter successfully"
  }
}
```

---

## Routes

### 1. Create Route
**POST** `/routes`

**Request Body:**
```json
{
  "route_name": "Abokobi North Route",
  "assigned_officer_id": "officer-uuid",
  "service_area": "Abokobi",
  "scheduled_date": "2026-10-05",
  "meter_ids": [
    "meter-uuid-1",
    "meter-uuid-2",
    "meter-uuid-3"
  ]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "route-uuid",
    "route_name": "Abokobi North Route",
    "assigned_officer_id": "officer-uuid",
    "service_area": "Abokobi",
    "scheduled_date": "2026-10-05",
    "status": "pending",
    "total_meters": 3,
    "meters_read": 0,
    "created_at": "2026-10-05T09:00:00Z"
  }
}
```

---

### 2. Get Route
**GET** `/routes/:routeId`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "route-uuid",
    "route_name": "Abokobi North Route",
    "assigned_officer_id": "officer-uuid",
    "assigned_officer_name": "John Mensah",
    "service_area": "Abokobi",
    "scheduled_date": "2026-10-05",
    "status": "in_progress",
    "total_meters": 3,
    "meters_read": 2,
    "meters": [
      {
        "meter_id": "meter-uuid-1",
        "meter_number": "88-696786",
        "customer_name": "Org. Abokobi Presby Mission",
        "status": "read",
        "read_at": "2026-10-05T08:30:00Z"
      }
    ]
  }
}
```

---

### 3. Get Routes for Officer
**GET** `/officers/:officerId/routes?status=pending&date=2026-10-05`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "route-uuid",
      "route_name": "Abokobi North Route",
      "service_area": "Abokobi",
      "status": "pending",
      "total_meters": 3,
      "meters_read": 0
    }
  ]
}
```

---

## Reports

### 1. Daily Summary Report
**GET** `/reports/daily?date=2026-10-05&service_area=Abokobi`

**Response:**
```json
{
  "success": true,
  "data": {
    "date": "2026-10-05",
    "service_area": "Abokobi",
    "total_routes": 5,
    "routes_completed": 3,
    "routes_in_progress": 2,
    "total_meters_assigned": 150,
    "total_meters_read": 120,
    "meters_unreadable": 5,
    "completion_percentage": 80,
    "anomalies_detected": 3,
    "average_readings_per_officer": 40
  }
}
```

---

### 2. Billing Summary Report
**GET** `/reports/billing?billing_period=2026-10&service_area=Abokobi`

**Response:**
```json
{
  "success": true,
  "data": {
    "billing_period": "2026-10",
    "service_area": "Abokobi",
    "total_customers": 150,
    "total_bills_generated": 145,
    "bills_failed": 5,
    "total_amount_due": 385500.75,
    "total_paid": 150000.00,
    "total_pending": 235500.75,
    "total_overdue": 10000.00,
    "average_bill_amount": 2655.86,
    "highest_bill": 15000.00,
    "lowest_bill": 500.00
  }
}
```

---

### 3. Anomaly Report
**GET** `/reports/anomalies?start_date=2026-10-01&end_date=2026-10-05&severity=all`

**Response:**
```json
{
  "success": true,
  "data": {
    "period": {
      "start_date": "2026-10-01",
      "end_date": "2026-10-05"
    },
    "total_anomalies": 8,
    "by_type": {
      "meter_unreadable": 5,
      "reading_anomaly": 2,
      "high_consumption": 1
    },
    "by_severity": {
      "critical": 1,
      "high": 3,
      "medium": 4
    },
    "details": [
      {
        "id": "alert-uuid",
        "meter_number": "88-696786",
        "customer_name": "Org. Abokobi Presby Mission",
        "alert_type": "meter_unreadable",
        "severity": "high",
        "message": "Meter could not be read",
        "created_at": "2026-10-05T08:30:00Z"
      }
    ]
  }
}
```

---

## Status Codes

- `200 OK`: Successful request
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid input data
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource already exists or conflict
- `422 Unprocessable Entity`: Validation error
- `500 Internal Server Error`: Server error

---

## Error Response Example

```json
{
  "success": false,
  "error": "Customer with number CUST/AP/2012-001 already exists",
  "code": "DUPLICATE_CUSTOMER_NUMBER",
  "details": {
    "field": "customer_number",
    "value": "CUST/AP/2012-001"
  }
}
```
