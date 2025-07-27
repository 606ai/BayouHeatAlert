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
