def get_climate_alerts(weather_data: dict) -> list:
    """Detect extreme weather events from Open-Meteo response."""
    alerts = []
    current = weather_data.get("current", {})
    temp    = current.get("temperature_2m", 0)
    wind    = current.get("wind_speed_10m", 0)
    code    = current.get("weathercode", 0)

    if temp >= 40:
        alerts.append({"type": "EXTREME_HEAT", "message": f"Extreme heat: {temp}°C. Avoid field work 11am–3pm."})
    if temp <= 5:
        alerts.append({"type": "COLD_WAVE", "message": f"Cold wave: {temp}°C. Protect sensitive crops."})
    if wind >= 50:
        alerts.append({"type": "STRONG_WINDS", "message": f"Strong winds: {wind} km/h. Secure irrigation equipment."})
    if code in range(95, 100):
        alerts.append({"type": "THUNDERSTORM", "message": "Thunderstorm expected. Do not go to open fields."})
    if code in range(51, 68):
        alerts.append({"type": "HEAVY_RAIN", "message": "Heavy rain expected. Check drainage in fields."})
    return alerts
