const fs = require('fs');
const path = require('path');

const tariffPath = path.join(__dirname, '../data/tariffs.json');

function readTariffs() {
  if (!fs.existsSync(tariffPath)) {
    return [];
  }

  const json = fs.readFileSync(tariffPath, 'utf8');
  return JSON.parse(json);
}

function writeTariffs(tariffs) {
  fs.writeFileSync(tariffPath, JSON.stringify(tariffs, null, 2));
}

function getActiveTariff(meterType, date = new Date()) {
  const tariffs = readTariffs().filter((t) => t.meterType === meterType && t.status === 'active');

  const target = new Date(date);
  const active = tariffs.find((tariff) => {
    const start = new Date(tariff.effectiveFrom);
    const end = tariff.effectiveTo ? new Date(tariff.effectiveTo) : null;
    return target >= start && (!end || target <= end);
  });

  return active || null;
}

function updateTariff(newTariff) {
  const tariffs = readTariffs();

  const sanitized = {
    ...newTariff,
    id: newTariff.id || `tariff-${Date.now()}`,
    status: newTariff.status || 'active',
    effectiveTo: newTariff.effectiveTo || null
  };

  const existingIndex = tariffs.findIndex((t) => t.id === sanitized.id);

  if (existingIndex >= 0) {
    tariffs[existingIndex] = sanitized;
  } else {
    tariffs.push(sanitized);
  }

  writeTariffs(tariffs);
  return sanitized;
}

module.exports = {
  getActiveTariff,
  updateTariff,
  readTariffs
};
