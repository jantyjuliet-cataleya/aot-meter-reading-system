const Tesseract = require('tesseract.js');

async function readMeterFromImage(imageBuffer) {
  const text = await Tesseract.recognize(imageBuffer, 'eng', {
    logger: () => {}
  });

  const digits = text.data.text.replace(/[^0-9]/g, '');

  if (!digits) {
    return {
      rawValue: '',
      reading: null,
      confidence: 0,
      status: 'unreadable'
    };
  }

  return {
    rawValue: digits,
    reading: Number(digits),
    confidence: Number((text.data.confidence / 100).toFixed(2)),
    status: 'ok'
  };
}

module.exports = {
  readMeterFromImage
};
