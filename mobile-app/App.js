import React, { useState } from 'react';
import { View, Text, TextInput, Button, Alert, StyleSheet } from 'react-native';

export default function MeterReadingScreen() {
  const [meterNumber, setMeterNumber] = useState('AOT-1048');
  const [reading, setReading] = useState('12345');
  const [status, setStatus] = useState('Ready');

  const handleCaptureReading = async () => {
    setStatus('Processing OCR...');

    try {
      const response = await fetch('http://localhost:4000/api/readings/scan', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          meterNumber,
          reading
        })
      });

      const data = await response.json();
      setStatus(data.success ? 'Reading captured successfully' : 'OCR failed');
    } catch (error) {
      setStatus('Offline or backend unavailable');
      Alert.alert('Connection error', 'Could not reach backend service.');
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>AOT Meter Reading</Text>

      <Text style={styles.label}>Meter Number</Text>
      <TextInput
        style={styles.input}
        value={meterNumber}
        onChangeText={setMeterNumber}
      />

      <Text style={styles.label}>Reading</Text>
      <TextInput
        style={styles.input}
        value={reading}
        onChangeText={setReading}
        keyboardType="numeric"
      />

      <Button title="Capture Reading" onPress={handleCaptureReading} />

      <Text style={styles.status}>{status}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    padding: 20,
    backgroundColor: '#f5f7fb'
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    marginBottom: 20,
    color: '#0d2f5f'
  },
  label: {
    fontSize: 16,
    marginBottom: 8,
    color: '#1f2d3d'
  },
  input: {
    borderWidth: 1,
    borderColor: '#cfd8e3',
    borderRadius: 10,
    padding: 12,
    marginBottom: 18,
    backgroundColor: '#fff'
  },
  status: {
    marginTop: 18,
    color: '#0f766e',
    fontWeight: '600'
  }
});
