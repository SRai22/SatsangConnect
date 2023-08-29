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
    marginBottom: 50,
    fontFamily: 'Poppins_400Regular'
  },
  countText: {
    fontSize: 72,  // Increase font size for count display
    marginBottom: 200,
    fontFamily: 'Poppins_400Regular'
  },
  buttonContainer: {
    flexDirection: 'row',
    position: 'absolute',  // Position the buttons at the bottom
    bottom: 100,  // Adjust as needed for margin from the bottom
    width: '100%',
    justifyContent: 'center',  // Center the buttons horizontally
  },
  incrementButton: {
    padding: 5,
    width: '50%',  // 40% of the screen width
    aspectRatio: 1,  // Makes it a perfect circle
    backgroundColor: '#007AFF',
    borderRadius: 700,  // Large enough value to ensure a circle
    justifyContent: 'center',  // Center the text inside the button vertically
    alignItems: 'center',  // Center the text inside the button horizontally
  },
  clearButton: {
    padding: 10,
    width: 90,  // Width of the clear button
    height: 90,  // Height of the clear button
    backgroundColor: 'red',
    borderRadius: 30,  // Half of the width/height for a perfect circle
    marginLeft: 20,  // Space between the count and clear buttons
    justifyContent: 'center',  // Center the text inside the button vertically
    alignItems: 'center',  // Center the text inside the button horizontally
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontFamily: 'Poppins_900Black',
  },
});
