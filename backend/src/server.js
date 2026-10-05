require('dotenv').config();
const express = require('express');
const cors = require('cors');
const multer = require('multer');

const { readMeterFromImage } = require('./src/services/ocrService');
const { calculateBill, getBillHistory } = require('./src/services/billingService');
const { getActiveTariff, updateTariff } = require('./src/services/pricingService');

const app = express();
const upload = multer({ storage: multer.memoryStorage() });

app.use(cors());
app.use(express.json({ limit: '10mb' }));

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'AOT meter reading backend' });
});

app.post('/api/readings/scan', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Image file is required' });
    }

    const imageBuffer = req.file.buffer;
    const reading = await readMeterFromImage(imageBuffer);

    return res.json({
      success: true,
      reading,
      confidence: reading.confidence,
      source: 'ocr'
    });
  } catch (error) {
    return res.status(500).json({ error: error.message || 'OCR failed' });
  }
});

app.post('/api/readings', (req, res) => {
  const { meterNumber, officerId, reading, timestamp, gps } = req.body;

  if (!meterNumber || !reading || !officerId) {
    return res.status(400).json({ error: 'meterNumber, reading and officerId are required' });
  }

  const meterRead = {
    meterNumber,
    officerId,
    reading: Number(reading),
    timestamp: timestamp || new Date().toISOString(),
    gps: gps || null,
    status: 'captured'
  };

  res.json({ success: true, reading: meterRead });
});

app.get('/api/pricing/active', (req, res) => {
  const meterType = req.query.meterType || 'domestic';
  const date = req.query.date || new Date().toISOString();
  const tariff = getActiveTariff(meterType, new Date(date));

  res.json({ success: true, tariff });
});

app.post('/api/pricing/update', (req, res) => {
  const tariff = req.body;

  if (!tariff || !tariff.meterType || !tariff.ratePerUnit || !tariff.effectiveFrom) {
    return res.status(400).json({ error: 'Incomplete tariff information' });
  }

  const result = updateTariff(tariff);
  res.json({ success: true, tariff: result });
});

app.get('/api/bills/:meterId', (req, res) => {
  const { meterId } = req.params;
  const history = getBillHistory(meterId);
  res.json({ success: true, meterId, bills: history });
});

app.post('/api/bills/calculate', (req, res) => {
  const { meterId, currentReading, previousReading, meterType, billingDate } = req.body;

  if (currentReading === undefined || previousReading === undefined || !meterType) {
    return res.status(400).json({ error: 'currentReading, previousReading and meterType are required' });
  }

  const result = calculateBill({
    meterId,
    currentReading,
    previousReading,
    meterType,
    billingDate: billingDate || new Date().toISOString()
  });

  res.json({ success: true, bill: result });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`AOT meter backend running on port ${PORT}`);
});
