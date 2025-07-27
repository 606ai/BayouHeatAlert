import React from 'react';
import { ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import useAlerts from '../hooks/useAlerts';
import MorningCard from '../components/MorningCard';
export default function Home(){
  const {alerts,forecast,loading}=useAlerts();
  const today=forecast?.properties?.periods?.[0];
  if(loading) return null;
  return (
    <SafeAreaView>
      <ScrollView>
        <MorningCard alerts={alerts} today={today}/>
      </ScrollView>
    </SafeAreaView>
  );
}
