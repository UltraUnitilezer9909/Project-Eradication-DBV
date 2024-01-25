#===============================================================================
# * Weather System
#===============================================================================

class WeatherSystem
  attr_accessor :actualWeather
  attr_accessor :nextWeather
  attr_accessor :zoneMaps
  attr_accessor :currentZone
  attr_accessor :seasons
  attr_accessor :seasonSplash

  def initialize
    @actualWeather	= []
    @nextWeather	= []
    @zoneMaps		= WeatherConfig::ZONE_MAPS || []
    @currentZone	= nil
    @seasons		= {
      :outdoor => false,
      :summer => false,
      :autumn => false,
      :winter => false,
      :spring => false
    }
    @seasonSplash	= false
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
  longMonth = [1,3,5,7,8,10]
  shortMonth = [4,6,9,11]
  leapYear = (startTime.year % 4 == 0) ? true : false
  if startTime.year % 100 == 0
    leapYear = (startTime.year % 400 == 0 && leapYear) ? true : false
  end
  if longMonth.include?(startTime.month) && startTime.day == 31
    midnight = Time.new(startTime.year, startTime.month + 1, 1, 0, 0, 0)
  elsif shortMonth.include?(startTime.month) && startTime.day == 30
    midnight = Time.new(startTime.year, startTime.month + 1, 1, 0, 0, 0)
  elsif startTime.month == 2 && leapYear && startTime.day == 29
    midnight = Time.new(startTime.year, startTime.month + 1, 1, 0, 0, 0)
  elsif startTime.month == 2 && !leapYear && startTime.day == 28
    midnight = Time.new(startTime.year, startTime.month + 1, 1, 0, 0, 0)
  elsif startTime.month == 12 && startTime.day == 31
    midnight = Time.new(startTime.year + 1, 1, 1, 0, 0, 0)
  else
    midnight = Time.new(startTime.year, startTime.month, startTime.day + 1, 0, 0, 0)
  end
  hours = rand(WeatherConfig::CHANGE_TIME_MIN...WeatherConfig::CHANGE_TIME_MAX)
  elapse = hours * 60 * 60
  endTime = startTime + elapse
  # Sets the end of the weather at the next midnight or a determined amount of hours in the future
  endTime = (WeatherConfig::CHANGE_MIDNIGHT) ? midnight : endTime
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
    for j in 0...prob.length
      prob[j] = 0 if zoneWeather[i][j] == 0
    end
    main = 0
	weatherChance = 1 + rand(chance)
    for j in 0...zoneWeather[i].length
      break if weatherChance <= prob[j]
      main += 1
    end
    mainType = GameData::Weather.get(main).id
    secondType = pbValidSecondWeather(i, mainType)
    startTime = pbGetStartTime
    endTime = pbGetEndTime(startTime)
    newWeather = WeatherSystemData.new(startTime, endTime, mainType, secondType)
    $WeatherSystem.actualWeather.push(newWeather)
    main = 0
	weatherChance = 1 + rand(chance)
    for j in 0...zoneWeather[i].length
      break if weatherChance <= prob[j]
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

def pbForceUpdateZoneWeather(zone)
  startTime = pbGetStartTime
  $WeatherSystem.actualWeather[zone].startTime = startTime
  endTime = pbGetEndTime(startTime)
  $WeatherSystem.actualWeather[zone].endTime = endTime
  $WeatherSystem.actualWeather[zone].mainWeather = $WeatherSystem.nextWeather[zone].mainWeather
  $WeatherSystem.actualWeather[zone].secondWeather = $WeatherSystem.nextWeather[zone].secondWeather
  pbSetNewWeather(zone)
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
  for j in 0...prob.length
    prob[j] = 0 if zoneWeather[zone][j] == 0
  end
  main = 0
  weatherChance = 1 + rand(chance)
  for j in 0...zoneWeather[zone].length
    break if weatherChance <= prob[j]
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