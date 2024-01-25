#===============================================================================
# * Weather System Forecast
#===============================================================================

def pbWeatherForecast(zone)
  weatherNow = WeatherConfig::WEATHER_NAMES[$WeatherSystem.actualWeather[zone].mainWeather]
  weatherNow2 = WeatherConfig::WEATHER_NAMES[$WeatherSystem.actualWeather[zone].secondWeather]
  weatherNext = WeatherConfig::WEATHER_NAMES[$WeatherSystem.nextWeather[zone].mainWeather]
  weatherNext2 = WeatherConfig::WEATHER_NAMES[$WeatherSystem.nextWeather[zone].secondWeather]
  weatherStart = $WeatherSystem.actualWeather[zone].startTime
  weatherEnd = $WeatherSystem.actualWeather[zone].endTime
  pbMessage(_INTL("The weather on the zone has been {1}, with chance of some places having {2}, since {3}:{4}.", weatherNow.downcase, weatherNow2.downcase, weatherStart.hour, weatherStart.min))
  pbMessage(_INTL("The weather will change at {1}:{2} to {3} with chance of {4} on some places.", weatherEnd.hour, weatherEnd.min, weatherNext.downcase, weatherNext2.downcase))
end