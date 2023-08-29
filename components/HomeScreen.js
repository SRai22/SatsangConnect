import React, { useState, useEffect } from 'react';
import { View, TouchableOpacity, Text, StyleSheet, TextInput, Alert } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useFonts, Poppins_400Regular} from '@expo-google-fonts/poppins';

export default function HomeScreen({ navigation }) {
  const [sections, setSections] = useState(['Naam Jaap', 'Hanuman Chalisa']);
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

  const handleLongPress = (section, index) => {
    Alert.alert(
      'Manage Section',
      `What would you like to do with "${section}"?`,
      [
        {
          text: 'Edit',
          onPress: () => editSection(section, index)
        },
        {
          text: 'Delete',
          onPress: () => deleteSection(index),
          style: 'destructive'
        },
        {
          text: 'Cancel',
          style: 'cancel'
        }
      ],
      { cancelable: true }
    );
  };
  
  const editSection = (section, index) => {
    Alert.prompt(
      'Edit Section',
      'Update the section name:',
      [
        {
          text: 'Cancel',
          style: 'cancel'
        },
        {
          text: 'Save',
          onPress: newName => {
            const updatedSections = [...sections];
            updatedSections[index] = newName;
            setSections(updatedSections);
            AsyncStorage.setItem('sections', JSON.stringify(updatedSections));
          }
        }
      ],
      'plain-text',
      section  // default value
    );
  };
  
  const deleteSection = (index) => {
    const updatedSections = [...sections];
    updatedSections.splice(index, 1);
    setSections(updatedSections);
    AsyncStorage.setItem('sections', JSON.stringify(updatedSections));
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
        onPress={() => navigation.navigate('JaapCounter', { sectionName: section })}
        onLongPress={() => handleLongPress(section, index)}
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
      <TouchableOpacity style={styles.instructionsButton}
            onPress={() => navigation.navigate('Instructions')}>
        <Text style={styles.instructionsText}>How to use this app</Text>
      </TouchableOpacity>
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
  instructionsButton: {
    backgroundColor: '#007BFF',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 10,
    marginTop: 20, // Add some space from the other content
  },
  instructionsText: {
    color: 'white',
    textDecorationLine: 'underline',
    textAlign: 'center',
  },
});
