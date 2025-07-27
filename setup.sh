#!/data/data/com.termux/files/usr/bin/env bash
# setup.sh  –  One-snap BayouHeat bootstrap in Termux
# Run from inside ~/BayouHeatAlert
set -e

echo "🦾 BayouHeat One-Snap Builder"

# 0.  Termux prep
pkg update -y && pkg upgrade -y
pkg install git gh curl unzip jq nodejs-lts -y

# 1.  Git identity (only once)
git config --global user.email "sexy606ai@gmail.com"
git config --global user.name  "606ai"

# 2.  Install Expo CLI locally (no global)
npm install --save-dev @expo/cli @expo/ngrok@^4.1.0

# 3.  Create folder tree
mkdir -p src/{components,screens,services,hooks,styles}

# 4.  Drop minimal starter files
cat > src/styles/theme.ts <<'EOF'
export const theme = {
  colors: {
    heatRed: '#d62828',
    heatAmber: '#f77f00',
    heatGreen: '#06ffa5',
    primary: '#005f73',
  },
};
EOF

cat > src/services/nws.ts <<'EOF'
export async function getAlerts(area = 'LA') {
  const res = await fetch(`https://api.weather.gov/alerts/active?area=${area}`);
  return (await res.json()).features.map(f => f.properties);
}
export async function getForecast(lat:number, lon:number) {
  const points = await fetch(`https://api.weather.gov/points/${lat},${lon}`).then(r=>r.json());
  return fetch(points.properties.forecastHourly).then(r=>r.json());
}
EOF

cat > src/hooks/useAlerts.ts <<'EOF'
import { useEffect, useState } from 'react';
import * as Location from 'expo-location';
import { getAlerts, getForecast } from '../services/nws';
export default function useAlerts() {
  const [a,setA]=useState([]); const [f,setF]=useState(null); const [l,setL]=useState(true);
  useEffect(()=>{(async()=>{const loc=await Location.getCurrentPositionAsync({});
   setA(await getAlerts()); setF(await getForecast(loc.coords.latitude,loc.coords.longitude)); setL(false);})()},[]);
  return {alerts:a,forecast:f,loading:l};
}
EOF

cat > src/components/MorningCard.tsx <<'EOF'
import React from 'react';
import { Card, Text } from 'react-native-paper';
export default ({alerts,today}:any)=>{
  const heat=alerts.find((a:any)=>a.event.toLowerCase().includes('heat'));
  const color=heat?'#d62828':'#06ffa5';
  return (
    <Card style={{backgroundColor:color,margin:16}}>
      <Card.Content>
        <Text style={{color:'#fff'}}>{heat?.headline||'No heat advisory'}</Text>
        <Text style={{color:'#fff'}}>{today?.temperature||'--'}°F</Text>
      </Card.Content>
    </Card>
  );
};
EOF

cat > src/screens/Home.tsx <<'EOF'
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
EOF

cat > src/screens/Onboarding.tsx <<'EOF'
import React,{useState} from 'react';
import {View} from 'react-native';
import {Button,Text,RadioButton} from 'react-native-paper';
import AsyncStorage from '@react-native-async-storage/async-storage';
const prof=[{id:'labourer',l:'Outdoor Labourer'},{id:'supervisor',l:'Outdoor Supervisor'},{id:'indoor_noac',l:'Indoor (no A/C)'},{id:'indoor_ac',l:'Indoor (with A/C)'}];
export default function Onboarding({navigation}:{navigation:any}){
  const [p,setP]=useState('labourer');
  const finish=async()=>{await AsyncStorage.setItem('userProfile',p);navigation.replace('Home');};
  return(
    <View style={{flex:1,justifyContent:'center',padding:24}}>
      <Text variant="headlineSmall">Choose profile</Text>
      <RadioButton.Group onValueChange={setP} value={p}>
        {prof.map(x=><RadioButton.Item key={x.id} label={x.l} value={x.id}/>)}
      </RadioButton.Group>
      <Button mode="contained" onPress={finish} style={{marginTop:24}}>Start</Button>
    </View>
  );
}
EOF

# 5.  Install deps
npm install axios react-native-paper @react-navigation/native \
  @react-navigation/native-stack expo-location expo-notifications \
  @react-native-async-storage/async-storage react-native-safe-area-context \
  react-native-vector-icons

# 6.  Add GitHub Actions workflow
mkdir -p .github/workflows
cat > .github/workflows/build.yml <<'EOF'
name: Build APK
on:
  push: { branches: [main] }
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v3 with: {distribution: temurin, java-version: 17}
      - uses: android-actions/setup-android@v3
      - uses: actions/cache@v3 with: {path: ~/.gradle/caches, key: gradle-${{hashFiles('**/*.gradle*')}}}
      - run: npm ci
      - run: npx expo prebuild --platform android
      - run: cd android && chmod +x gradlew && ./gradlew assembleRelease
      - uses: actions/upload-artifact@v3 with: {name: BayouHeat-APK, path: android/app/build/outputs/apk/release/*.apk}
EOF

# 7.  Initial commit & push
git add .
git commit -m "feat: all-in-one starter"
git push -u origin main

# 8.  Local dev server
echo "🚀  Run:  npx expo start --lan"
