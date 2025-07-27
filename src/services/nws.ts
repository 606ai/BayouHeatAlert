export async function getAlerts(area = 'LA') {
  const res = await fetch(`https://api.weather.gov/alerts/active?area=${area}`);
  return (await res.json()).features.map(f => f.properties);
}
export async function getForecast(lat:number, lon:number) {
  const points = await fetch(`https://api.weather.gov/points/${lat},${lon}`).then(r=>r.json());
  return fetch(points.properties.forecastHourly).then(r=>r.json());
}
