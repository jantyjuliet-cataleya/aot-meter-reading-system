const fs = require('fs');
const path = require('path');

const dataDir = path.join(__dirname, '..', 'data');
const storeFile = path.join(dataDir, 'app-data.json');

const initialState = {
  customers: [
    {
      id: 'cust-001',
      customer_number: 'CUST/AP/2012-001',
      account_number: '2012-5708-AP-001',
      customer_name: 'Org. Abokobi Presby Mission',
      address: 'P.O. Box 155',
      plot_no: '001',
      service_area: 'Abokobi',
      service_type: 'Domestic',
      index_number: '5',
      status: 'active',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }
  ],
  meters: [
    {
      id: 'meter-001',
      meter_number: '88-696786',
      customer_id: 'cust-001',
      installation_date: '2020-01-15',
      service_area: 'Abokobi',
      meter_status: 'active',
      current_reading: 4800,
      previous_reading: 4380,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }
  ],
  officers: [
    {
      id: 'officer-001',
      officer_name: 'John Mensah',
      employee_number: 'EMP-001',
      phone: '+233501234567',
      email: 'john.mensah@aot.gov.gh',
      status: 'active',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }
  ],
  routes: [],
  route_meters: [],
  tariffs: [
    {
      id: 'tariff-001',
      service_type: 'Domestic',
      rate_per_unit: 2.8,
      fixed_charge: 1000,
      water_expansion_percentage: 2,
      fire_fighting_percentage: 1,
      effective_from: '2025-01-01',
      effective_to: '2026-09-30',
      status: 'inactive',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: 'tariff-002',
      service_type: 'Domestic',
      rate_per_unit: 3.25,
      fixed_charge: 1200,
      water_expansion_percentage: 2,
      fire_fighting_percentage: 1,
      effective_from: '2026-10-01',
      effective_to: null,
      status: 'active',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    },
    {
      id: 'tariff-003',
      service_type: 'Commercial',
      rate_per_unit: 4.5,
      fixed_charge: 2000,
      water_expansion_percentage: 2,
      fire_fighting_percentage: 1,
      effective_from: '2026-10-01',
      effective_to: null,
      status: 'active',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }
  ],
  meter_readings: [],
  bills: [],
  alerts: [],
  audit_logs: []
};

function ensureDataDir() {
  if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
  }
}

function readStore() {
  ensureDataDir();

  if (!fs.existsSync(storeFile)) {
    fs.writeFileSync(storeFile, JSON.stringify(initialState, null, 2));
    return JSON.parse(JSON.stringify(initialState));
  }

  const raw = fs.readFileSync(storeFile, 'utf8');
  if (!raw || raw.trim() === '') {
    fs.writeFileSync(storeFile, JSON.stringify(initialState, null, 2));
    return JSON.parse(JSON.stringify(initialState));
  }

  try {
    return JSON.parse(raw);
  } catch (error) {
    fs.writeFileSync(storeFile, JSON.stringify(initialState, null, 2));
    return JSON.parse(JSON.stringify(initialState));
  }
}

function writeStore(store) {
  ensureDataDir();
  fs.writeFileSync(storeFile, JSON.stringify(store, null, 2));
}

function makeId(prefix) {
  return `${prefix}-${Date.now()}-${Math.random().toString(16).slice(2, 8)}`;
}

module.exports = {
  readStore,
  writeStore,
  makeId,
  initialState,
  storeFile
};
