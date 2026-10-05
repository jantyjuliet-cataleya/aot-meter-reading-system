export const API_BASE_URL = 'http://localhost:4000/api';

export async function submitReading({ meterNumber, reading, officerId, gps }) {
  const response = await fetch(`${API_BASE_URL}/readings`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      meterNumber,
      reading,
      officerId,
      gps,
      timestamp: new Date().toISOString()
    })
  });

  return response.json();
}
