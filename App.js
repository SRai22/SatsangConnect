import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import InstructionScreen from './components/InstructionScreen'
import HomeScreen from './components/HomeScreen';
import CounterScreen from './components/CounterScreen';

const Stack = createStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="SatsangConnect">
        <Stack.Screen name="SatsangConnect" component={HomeScreen} />
        <Stack.Screen name="Instructions" component={InstructionScreen} />
        <Stack.Screen name="JaapCounter" component={CounterScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
