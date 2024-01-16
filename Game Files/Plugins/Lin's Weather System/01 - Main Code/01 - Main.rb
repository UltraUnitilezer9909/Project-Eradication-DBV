#===============================================================================
# * Weather System
#===============================================================================
# To do:
#   - Check season to decide weather								Done
#   - Special maps have custom weather options (beach maps don't have snow or hail)		Done
#   - Allow for weather options to be overwritten by game events				Done
#   - Weather changes everyday at midnight							Done
#   - Weather changes every x hours								Done
#   - Have zones that share weather and may have a different weather than the next zone		Done
#===============================================================================

class WeatherSystem
  attr_accessor :actualWeather
  attr_accessor :nextWeather
  attr_accessor :zoneMaps
  attr_accessor :currentZone

  def initialize
    @actualWeather	= []
    @nextWeather	= []
    @zoneMaps		= WeatherConfig::ZONE_MAPS || []
    @currentZone	= nil
  end
end

class WeatherSystemData
  attr_accessor :startTime
  attr_accessor :endTime
  attr_accessor :mainWeather
  attr_accessor :secondWeather
  def initialize(startTime,endTime,mainWeather,secondWeather)
    validate startTime => Time, endTime => Time, mainWeather => Symbol, secondWeather => Symbol
    @startTime = startTime
    @endTime = endTime
    @mainWeather = mainWeather
    @secondWeather = secondWeather
  end
end

SaveData.register(:weather_system) do
  ensure_class :WeatherSystem
  save_value { $WeatherSystem }
  load_value { |value| $WeatherSystem = value }
  new_game_value { WeatherSystem.new }
end

def pbForceUpdateWeather
  for i in 0...$WeatherSystem.actualWeather.length
    startTime = pbGetStartTime
    $WeatherSystem.actualWeather[i].startTime = startTime
    endTime = pbGetEndTime(startTime)
    $WeatherSystem.actualWeather[i].endTime = endTime
    $WeatherSystem.actualWeather[i].mainWeather = $WeatherSystem.nextWeather[i].mainWeather
    $WeatherSystem.actualWeather[i].secondWeather = $WeatherSystem.nextWeather[i].secondWeather
    pbSetNewWeather(i)
  end
end

def pbForceUpdateWeather(zone)
  startTime = pbGetStartTime
  $WeatherSystem.actualWeather[zone].startTime = startTime
  endTime = pbGetEndTime(startTime)
  $WeatherSystem.actualWeather[zone].endTime = endTime
  $WeatherSystem.actualWeather[zone].mainWeather = $WeatherSystem.nextWeather[zone].mainWeather
  $WeatherSystem.actualWeather[zone].secondWeather = $WeatherSystem.nextWeather[zone].secondWeather
  pbSetNewWeather(zone)
end

def pbFindZone
  $WeatherSystem.currentZone = nil
  $WeatherSystem.zoneMaps.length.times do |i|
    if $WeatherSystem.zoneMaps[i].include?($game_map.map_id)
      $WeatherSystem.currentZone = i
      break
    end
  end
end

def pbCheckValidWeather(weather, zone)
    maps = WeatherConfig::MAPS_SUBSTITUTE[weather]
    maps = ["none"] if maps == nil
    weather = $WeatherSystem.actualWeather[zone].secondWeather if maps.include?($game_map.map_id) && maps[0] == "exclude"
    weather = $WeatherSystem.actualWeather[zone].secondWeather if !maps.include?($game_map.map_id) && maps[0] == "include"
    return weather
end

def pbValidSecondWeather(zone, main)
    second = WeatherConfig::WEATHER_SUBSTITUTE[zone][main]
    second = main if second == nil	# There's no weather defined to substitute the main one for that zone
    return second
end

def pbGetStartTime
  if !WeatherConfig::USE_REAL_TIME && PluginManager.installed?("Unreal Time System")
    startTime = pbGetTimeNow
  else
    startTime = Time.now
  end
  return startTime
end

def pbGetEndTime(startTime)
  # Midnight of the next day
  midnight = Time.new(startTime.year, startTime.month, startTime.day + 1, 0, 0, 0)
  hours = rand(WeatherConfig::CHANGE_TIME_MIN...WeatherConfig::CHANGE_TIME_MAX)
  elapse = hours * 60 * 60
  # Sets the end of the weather at the next midnight or a determined amount of hours in the future
  endTime = (WeatherConfig::CHANGE_MIDNIGHT) ? midnight : startTime + elapse
  return endTime
end

def pbInitializeWeather
  zoneWeather = WeatherConfig::ZONE_WEATHER_SUMMER if pbIsSummer
  zoneWeather = WeatherConfig::ZONE_WEATHER_AUTUMN if pbIsAutumn
  zoneWeather = WeatherConfig::ZONE_WEATHER_WINTER if pbIsWinter
  zoneWeather = WeatherConfig::ZONE_WEATHER_SPRING if pbIsSpring
  for i in 0...$WeatherSystem.zoneMaps.length
    chance = 0
    last = 0
    prob = []
    for j in 0...zoneWeather[i].length
      chance += zoneWeather[i][j]
      newprob = zoneWeather[i][j] + last
      prob.push(newprob)
      last = newprob
    end
    chance += 1
    for j in 0...prob.length
      prob[j] = 0 if zoneWeather[i][j] == 0
    end
    main = 0
    for j in 0...zoneWeather[i].length
      break if rand(chance) <= prob[j]
      main += 1
    end
    mainType = GameData::Weather.get(main).id
    secondType = pbValidSecondWeather(i, mainType)
    startTime = pbGetStartTime
    endTime = pbGetEndTime(startTime)
    newWeather = WeatherSystemData.new(startTime, endTime, mainType, secondType)
    $WeatherSystem.actualWeather.push(newWeather)
    main = 0
    for j in 0...zoneWeather[i].length
      break if rand(chance) <= prob[j]
      main += 1
    end
    mainType = GameData::Weather.get(main).id
    secondType = pbValidSecondWeather(i, mainType)
    newWeather = WeatherSystemData.new(startTime, endTime, mainType, secondType)
    $WeatherSystem.nextWeather.push(newWeather)
  end
end

def pbUpdateWeather
  for i in 0...$WeatherSystem.actualWeather.length
    startTime = pbGetStartTime
    if startTime.to_i >= $WeatherSystem.actualWeather[i].endTime.to_i
      $WeatherSystem.actualWeather[i].startTime = startTime
      endTime = pbGetEndTime(startTime)
      $WeatherSystem.actualWeather[i].endTime = endTime
      $WeatherSystem.actualWeather[i].mainWeather = $WeatherSystem.nextWeather[i].mainWeather
      $WeatherSystem.actualWeather[i].secondWeather = $WeatherSystem.nextWeather[i].secondWeather
      pbSetNewWeather(i)
    end
  end
end

def pbUpdateWeather(zone)
  startTime = pbGetStartTime
  if startTime.to_i >= $WeatherSystem.actualWeather[zone].endTime.to_i
    $WeatherSystem.actualWeather[zone].startTime = startTime
    endTime = pbGetEndTime(startTime)
    $WeatherSystem.actualWeather[zone].endTime = endTime
    $WeatherSystem.actualWeather[zone].mainWeather = $WeatherSystem.nextWeather[zone].mainWeather
    $WeatherSystem.actualWeather[zone].secondWeather = $WeatherSystem.nextWeather[zone].secondWeather
    pbSetNewWeather(zone)
  end
end

def pbSetNewWeather(zone)
  zoneWeather = WeatherConfig::ZONE_WEATHER_SUMMER if pbIsSummer
  zoneWeather = WeatherConfig::ZONE_WEATHER_AUTUMN if pbIsAutumn
  zoneWeather = WeatherConfig::ZONE_WEATHER_WINTER if pbIsWinter
  zoneWeather = WeatherConfig::ZONE_WEATHER_SPRING if pbIsSpring
  chance = 0
  last = 0
  prob = []
  for j in 0...zoneWeather[zone].length
    chance += zoneWeather[zone][j]
    newprob = zoneWeather[zone][j] + last
    prob.push(newprob)
    last = newprob
  end
  chance += 1
  for j in 0...prob.length
    prob[j] = 0 if zoneWeather[zone][j] == 0
  end
  main = 0
  for j in 0...zoneWeather[zone].length
    break if rand(chance) <= prob[j]
    main += 1
  end
  mainType = GameData::Weather.get(main).id
  secondType = pbValidSecondWeather(zone, mainType)
  startTime = pbGetStartTime
  $WeatherSystem.nextWeather[zone].startTime = startTime
  $WeatherSystem.nextWeather[zone].endTime = startTime
  $WeatherSystem.nextWeather[zone].mainWeather = mainType
  $WeatherSystem.nextWeather[zone].secondWeather = secondType
end