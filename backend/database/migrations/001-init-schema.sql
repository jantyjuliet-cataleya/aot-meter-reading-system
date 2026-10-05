-- AOT Water & Sanitation Board Meter Reading System
-- Database Schema Initialization
-- This migration creates the complete database structure

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "plpgsql";

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
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

CREATE INDEX idx_customers_customer_number ON customers(customer_number);
CREATE INDEX idx_customers_account_number ON customers(account_number);
CREATE INDEX idx_customers_service_area ON customers(service_area);
CREATE INDEX idx_customers_status ON customers(status);

-- Meters table
CREATE TABLE IF NOT EXISTS meters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meter_number VARCHAR(100) UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    installation_date DATE,
    service_area VARCHAR(255),
    meter_status VARCHAR(50) DEFAULT 'active',
    current_reading NUMERIC(18,3),
    previous_reading NUMERIC(18,3),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_meters_meter_number ON meters(meter_number);
CREATE INDEX idx_meters_customer_id ON meters(customer_id);
CREATE INDEX idx_meters_service_area ON meters(service_area);
CREATE INDEX idx_meters_status ON meters(meter_status);

-- Officers table
CREATE TABLE IF NOT EXISTS officers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    officer_name VARCHAR(255) NOT NULL,
    employee_number VARCHAR(100) UNIQUE,
    phone VARCHAR(50),
    email VARCHAR(100),
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_officers_employee_number ON officers(employee_number);
CREATE INDEX idx_officers_status ON officers(status);

-- Routes table
CREATE TABLE IF NOT EXISTS routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_name VARCHAR(255),
    assigned_officer_id UUID REFERENCES officers(id) ON DELETE SET NULL,
    service_area VARCHAR(255),
    scheduled_date DATE,
    status VARCHAR(50) DEFAULT 'pending',
    total_meters INTEGER DEFAULT 0,
    meters_read INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_routes_assigned_officer_id ON routes(assigned_officer_id);
CREATE INDEX idx_routes_service_area ON routes(service_area);
CREATE INDEX idx_routes_scheduled_date ON routes(scheduled_date);
CREATE INDEX idx_routes_status ON routes(status);

-- Route meters junction table
CREATE TABLE IF NOT EXISTS route_meters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_id UUID NOT NULL REFERENCES routes(id) ON DELETE CASCADE,
    meter_id UUID NOT NULL REFERENCES meters(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'pending',
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_route_meters_route_id ON route_meters(route_id);
CREATE INDEX idx_route_meters_meter_id ON route_meters(meter_id);
CREATE INDEX idx_route_meters_status ON route_meters(status);

-- Meter readings table
CREATE TABLE IF NOT EXISTS meter_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meter_id UUID NOT NULL REFERENCES meters(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    officer_id UUID REFERENCES officers(id) ON DELETE SET NULL,
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
    anomaly_reason TEXT,
    source VARCHAR(50) DEFAULT 'mobile_app',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_meter_readings_meter_id ON meter_readings(meter_id);
CREATE INDEX idx_meter_readings_customer_id ON meter_readings(customer_id);
CREATE INDEX idx_meter_readings_reading_date ON meter_readings(reading_date);
CREATE INDEX idx_meter_readings_validation_status ON meter_readings(validation_status);
CREATE INDEX idx_meter_readings_anomaly_status ON meter_readings(anomaly_status);

-- Tariffs table
CREATE TABLE IF NOT EXISTS tariffs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_type VARCHAR(100) NOT NULL,
    rate_per_unit NUMERIC(12,4) NOT NULL,
    fixed_charge NUMERIC(12,2) DEFAULT 0,
    water_expansion_percentage NUMERIC(5,2) DEFAULT 2,
    fire_fighting_percentage NUMERIC(5,2) DEFAULT 1,
    effective_from DATE NOT NULL,
    effective_to DATE,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_tariffs_service_type ON tariffs(service_type);
CREATE INDEX idx_tariffs_status ON tariffs(status);
CREATE INDEX idx_tariffs_effective_from ON tariffs(effective_from);
CREATE INDEX idx_tariffs_effective_to ON tariffs(effective_to);

-- Bills table
CREATE TABLE IF NOT EXISTS bills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    meter_id UUID NOT NULL REFERENCES meters(id) ON DELETE CASCADE,
    tariff_id UUID REFERENCES tariffs(id) ON DELETE SET NULL,
    billing_period VARCHAR(50) NOT NULL,
    previous_reading NUMERIC(18,3),
    current_reading NUMERIC(18,3),
    consumption NUMERIC(18,3),
    rate_per_unit NUMERIC(12,4),
    fixed_charge NUMERIC(12,2),
    base_amount NUMERIC(12,2),
    water_expansion NUMERIC(12,2) DEFAULT 0,
    fire_fighting NUMERIC(12,2) DEFAULT 0,
    previous_balance NUMERIC(12,2) DEFAULT 0,
    amount_due NUMERIC(12,2) NOT NULL,
    total_due NUMERIC(12,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    issued_at TIMESTAMP DEFAULT NOW(),
    due_date DATE,
    paid_at TIMESTAMP,
    paid_amount NUMERIC(12,2),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_bills_customer_id ON bills(customer_id);
CREATE INDEX idx_bills_meter_id ON bills(meter_id);
CREATE INDEX idx_bills_billing_period ON bills(billing_period);
CREATE INDEX idx_bills_status ON bills(status);
CREATE INDEX idx_bills_issued_at ON bills(issued_at);

-- Alerts table
CREATE TABLE IF NOT EXISTS alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meter_id UUID REFERENCES meters(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    alert_type VARCHAR(100) NOT NULL,
    severity VARCHAR(50) DEFAULT 'medium',
    message TEXT NOT NULL,
    details JSONB,
    status VARCHAR(50) DEFAULT 'open',
    created_at TIMESTAMP DEFAULT NOW(),
    resolved_at TIMESTAMP,
    resolved_by UUID REFERENCES officers(id) ON DELETE SET NULL
);

CREATE INDEX idx_alerts_meter_id ON alerts(meter_id);
CREATE INDEX idx_alerts_customer_id ON alerts(customer_id);
CREATE INDEX idx_alerts_alert_type ON alerts(alert_type);
CREATE INDEX idx_alerts_severity ON alerts(severity);
CREATE INDEX idx_alerts_status ON alerts(status);
CREATE INDEX idx_alerts_created_at ON alerts(created_at);

-- Audit log table
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(100),
    entity_id UUID,
    action VARCHAR(50),
    old_values JSONB,
    new_values JSONB,
    actor_id UUID REFERENCES officers(id) ON DELETE SET NULL,
    actor_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_entity_type ON audit_logs(entity_type);
CREATE INDEX idx_audit_logs_entity_id ON audit_logs(entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
