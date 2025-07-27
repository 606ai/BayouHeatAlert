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
