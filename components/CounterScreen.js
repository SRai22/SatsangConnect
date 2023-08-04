import React, { useState, useEffect } from 'react';
import { View, TouchableOpacity, Text, StyleSheet } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useFonts, Poppins_900Black, Poppins_400Regular} from '@expo-google-fonts/poppins';


export default function CounterScreen({ route }) {
  const sectionName = route.params.sectionName;
  const [count, setCount] = useState(0);

  let [fontsLoaded] = useFonts({
    Poppins_900Black,
    Poppins_400Regular
  });


  useEffect(() => {
    AsyncStorage.getItem(sectionName).then(storedCount => {
      if (storedCount !== null) {
        setCount(Number(storedCount));
      }
    });
  }, [sectionName]);

  const incrementCounter = () => {
    const newCount = count + 1;
    setCount(newCount);
    AsyncStorage.setItem(sectionName, newCount.toString());
  };

  const clearCounter = () => {
    setCount(0);
    AsyncStorage.removeItem(sectionName);
  };

  if (!fontsLoaded) {
    return <View />;
  }

  return (
    <View style={styles.container}>
      <Text style={styles.heading}>{sectionName}</Text>
      <Text style={styles.countText}>{count}</Text>
      <View style={styles.buttonContainer}>
        <TouchableOpacity style={styles.incrementButton} onPress={incrementCounter}>
          <Text style={styles.buttonText}>COUNT</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.clearButton} onPress={clearCounter}>
          <Text style={styles.buttonText}>CLEAR</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
    fontFamily: 'Poppins_400Regular'
  },
  heading: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    fontFamily: 'Poppins_400Regular'
  },
  countText: {
    fontSize: 48,
    marginBottom: 20,
  },
  buttonContainer: {
    flexDirection: 'row',
  },
  incrementButton: {
    padding: 10,
    backgroundColor: '#007AFF',
    borderRadius: 5,
    marginRight: 5,
  },
  clearButton: {
    padding: 10,
    backgroundColor: 'red',
    borderRadius: 5,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontFamily: 'Poppins_900Black',
  },
});
