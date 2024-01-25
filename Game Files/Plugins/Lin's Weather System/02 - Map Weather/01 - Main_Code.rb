#===============================================================================
# * Weather System Map Display
#===============================================================================

def pbCheckValidMapWeather(weather, zone, x, y)
  mapName = pbGetMapLocation(x, y)
  mapName = mapName.to_s
  for i in 0...$WeatherSystem.zoneMaps.length
    map = WeatherConfig::MAPS_POSITIONS[i][mapName]
    break if WeatherConfig::MAPS_POSITIONS[i].has_key?(mapName)
  end
  maps = WeatherConfig::MAPS_SUBSTITUTE[weather]
  maps = ["none"] if maps == nil
  weather = $WeatherSystem.actualWeather[zone].secondWeather if maps.include?(map) && maps[0] == "exclude"
  weather = $WeatherSystem.actualWeather[zone].secondWeather if !maps.include?(map) && maps[0] == "include"
  return weather
end

def pbGetMapZone(x, y)
  mapName = pbGetMapLocation(x, y)
  mapName = mapName.to_s
  for i in 0...$WeatherSystem.zoneMaps.length
    zone = nil
	zone = i if WeatherConfig::MAPS_POSITIONS[i].has_key?(mapName)
    break if WeatherConfig::MAPS_POSITIONS[i].has_key?(mapName)
  end
  return zone
end

def pbGetWeatherDetails(x, y)
  mapZone = pbGetMapZone(x, y)
  for i in 0...$WeatherSystem.zoneMaps.length
    zone = i
    break if mapZone == i
    zone = nil if mapZone != i
  end
  weather = nil
  weather = $WeatherSystem.actualWeather[zone].mainWeather if zone != nil
  weather = pbCheckValidMapWeather(weather, zone, @map_x, @map_y) if zone != nil
  conversion = WeatherConfig::WEATHER_IMAGE
  id = conversion[weather]
  if Essentials::VERSION.include?("20")
    filePath = "Graphics/Pictures/WeatherSystem/Weather/#{id}"
  else
    filePath = "Graphics/UI/WeatherSystem/Weather/#{id}"
  end
  return filePath
end

def pbGetWeatherName(x, y)
  mapZone = pbGetMapZone(x, y)
  for i in 0...$WeatherSystem.zoneMaps.length
    zone = i
	break if mapZone == i
	zone = nil if mapZone != i
  end
  weather = nil
  weather = $WeatherSystem.actualWeather[zone].mainWeather if zone != nil
  weather = pbCheckValidMapWeather(weather, zone, @map_x, @map_y) if zone != nil
  conversion = WeatherConfig::WEATHER_NAMES
  id = conversion[weather]
  return id
end