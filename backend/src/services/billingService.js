const { getActiveTariff } = require('./pricingService');

function calculateBill({ meterId, currentReading, previousReading, meterType, billingDate }) {
  if (Number(currentReading) < Number(previousReading)) {
    return {
      meterId,
      status: 'anomaly',
      message: 'Current reading is lower than previous reading. Please verify meter',
      amount: 0
    };
  }

  const tariff = getActiveTariff(meterType, new Date(billingDate));

  if (!tariff) {
    return {
      meterId,
      status: 'error',
      message: 'No active tariff found for the selected meter type',
      amount: 0
    };
  }

  const consumption = Number(currentReading) - Number(previousReading);
  const amount = (consumption * Number(tariff.ratePerUnit)) + Number(tariff.fixedCharge || 0);

  return {
    meterId,
    meterType,
    billingDate,
    previousReading,
    currentReading,
    consumption,
    tariffId: tariff.id,
    ratePerUnit: tariff.ratePerUnit,
    fixedCharge: tariff.fixedCharge,
    amount,
    status: 'calculated'
  };
}

function getBillHistory(meterId) {
  return [
    {
      meterId,
      month: '2026-09',
      status: 'paid',
      amount: 18000
    },
    {
      meterId,
      month: '2026-10',
      status: 'pending',
      amount: 23550
    }
  ];
}

module.exports = {
  calculateBill,
  getBillHistory
};
