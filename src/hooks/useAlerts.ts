import { useEffect, useState } from 'react';
import * as Location from 'expo-location';
import { getAlerts, getForecast } from '../services/nws';
export default function useAlerts() {
  const [a,setA]=useState([]); const [f,setF]=useState(null); const [l,setL]=useState(true);
  useEffect(()=>{(async()=>{const loc=await Location.getCurrentPositionAsync({});
   setA(await getAlerts()); setF(await getForecast(loc.coords.latitude,loc.coords.longitude)); setL(false);})()},[]);
  return {alerts:a,forecast:f,loading:l};
}
