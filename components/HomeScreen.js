import React, { useState, useEffect } from 'react';
import { View, TouchableOpacity, Text, StyleSheet, TextInput, Alert } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useFonts, Poppins_400Regular} from '@expo-google-fonts/poppins';

export default function HomeScreen({ navigation }) {
  const [sections, setSections] = useState([]);
  const [newSectionName, setNewSectionName] = useState('');

  let [fontsLoaded] = useFonts({
    Poppins_400Regular,
  });

  useEffect(() => {
    // Fetch the stored sections when the app loads
    AsyncStorage.getItem('sections').then(storedSections => {
      if (storedSections !== null) {
        setSections(JSON.parse(storedSections));
      }
    });
  }, []);

  const addSection = () => {
    if (newSectionName.trim() === '') {
      Alert.alert('Error', 'Section name cannot be empty');
      return;
    }
    const newSections = [...sections, newSectionName];
    setSections(newSections);
    setNewSectionName('');
    AsyncStorage.setItem('sections', JSON.stringify(newSections));
  };

  if (!fontsLoaded) {
    return null;
  }

  return (
    <View style={styles.container}>
      {sections.map((section, index) => (
        <TouchableOpacity
          key={index}
          style={[styles.sectionButton, { flex: 1 / sections.length }]}
          onPress={() => navigation.navigate('Counter', { sectionName: section })}
        >
          <Text style={styles.buttonText}>{section}</Text>
        </TouchableOpacity>
      ))}
      <View style={styles.addSectionContainer}>
        <TextInput
          style={styles.input}
          placeholder="New Section Name"
          value={newSectionName}
          onChangeText={setNewSectionName}
        />
        <TouchableOpacity style={styles.addButton} onPress={addSection}>
          <Text style={styles.buttonText}>ADD SECTION</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: '#f0f0f0',
  },
  sectionButton: {
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ADD8E6',
  },
  addSectionContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 5,
    backgroundColor: '#ddd',
  },
  input: {
    flex: 1,
    padding: 10,
    backgroundColor: 'white',
    marginRight: 5,
    borderRadius: 5,
  },
  addButton: {
    padding: 10,
    backgroundColor: '#007AFF',
    borderRadius: 5,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontFamily: 'Poppins_400Regular',
  },
});
