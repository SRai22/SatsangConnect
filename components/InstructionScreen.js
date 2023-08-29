import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';

export default function InstructionScreen() {
  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.heading}>How to Use the App</Text>
      <Text style={styles.instruction}>Add new jaap counting section.</Text>
      <Text style={styles.instruction}>Navigate to the section you want to use for jaap counting.</Text>
      <Text style={styles.instruction}>Click on the count button to increase the count.</Text>
      <Text style={styles.instruction}>Use the clear button to reset the count.</Text>
      {/* Add more instructions as needed */}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 16,
  },
  heading: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  instruction: {
    fontSize: 18,
    marginBottom: 10,
    
  },
});
