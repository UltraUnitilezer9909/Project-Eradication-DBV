#===============================================================================
# * Weather System Configuration
#===============================================================================

module WeatherConfig
  # Set to false to use the Weather System.
  NO_WEATHER = false		# Default: false

  # Set to false to use the Weather System.
  SHOW_WEATHER_ON_MAP = true	# Default: true

  # Set to true to use the computer's time. Will not work without Unreal Time System.
  USE_REAL_TIME = true		# Default: true

  # Set to true to have the weather change at midnight.
  CHANGE_MIDNIGHT = true	# Default: true

  # Define the min and max amount of time (in hours) before the weather changes.
  # Set the same number to not randomize the amount of time before the weather changes.
  CHANGE_TIME_MIN = 1		# Default: 1
  CHANGE_TIME_MAX = 4		# Default: 4

#===============================================================================
# * Weather Substitute
#===============================================================================
  # A hash with the ID of the maps that will have or not have certain weathers.
  MAPS_SUBSTITUTE = {
	:Snow => ["exclude", 1, 4],
	:Blizzard => ["exclude", 1, 4],
        :Sandstorm => ["include", 5]
  }

  # The ID of the weathers that will substitute the main when in one of the summer or sandstorm maps.
  # There has to be a hash (defined between {}) for each defined zone with weather to substitute.
  # Any weather not defined in the hash for a zone will use the main weather instead.
  WEATHER_SUBSTITUTE = [
	{:None => :None, :Rain => :Rain, :Storm => :Storm, :Snow => :Rain, :Blizzard => :Storm, :Sandstorm => :None, :HeavyRain => :HeavyRain, :Sun => :Sun, :Fog => :Fog},
	{:Snow => :Rain, :Blizzard => :Storm, :Sandstorm => :None},
	{:Snow => :Rain, :Blizzard => :HeavyRain}
  ]

#===============================================================================
# * Weather Names
#===============================================================================
  # A hash that contains the ID of weather and the name to display for each one.
  # Using .downcase will make them lowercase.
  WEATHER_NAMES = {
	:None		=> _INTL("None"),
	:Rain		=> _INTL("Rain"),
	:Storm		=> _INTL("Storm"),
	:Snow		=> _INTL("Snow"),
	:Blizzard	=> _INTL("Blizzard"),
	:Sandstorm	=> _INTL("Sandstorm"),
	:HeavyRain	=> _INTL("Heavy rain"),
	:Sun		=> _INTL("Sun"),
	:Fog		=> _INTL("Fog")
  }

#===============================================================================
# * Zones Configuration
#===============================================================================
  # Arrays of id of the maps of each zone. Each array within the main array is a zone.
  # The maps within each zone will have the same weather at the same time.
  # Each zone may have a different weather than the others.
  ZONE_MAPS = [
    [1, 2, 3],
    [4, 5],
    [6]
  ]
#===============================================================================
# * Season Probability Configuration
#===============================================================================
  # Arrays of probability of weather for each zone in the different seasons.
  # Each array within the main array corresponds to a zone in ZONE_MAPS.
  # Put 0 to weather you don't want if you define a probability after it.
  # If your game doesn't use seasons, edit the probabilities of one season and copy it to the others.

  # Probability of weather in summer.
  # Order: None, Rain, Storm, Snow, Blizzard, Sandstorm, HeavyRain, Sun/Sunny, Fog
  ZONE_WEATHER_SUMMER = [
    [50, 20, 3, 0, 0, 0, 5, 30],
    [40, 50],
    [60]
  ]

  # Probability of weather in autumn.
  # Order: None, Rain, Storm, Snow, Blizzard, Sandstorm, HeavyRain, Sun/Sunny, Fog
  ZONE_WEATHER_AUTUMN = [
    [50, 20, 3, 0, 0, 0, 5, 30],
    [40, 50],
    [60]
  ]

  # Probability of weather in winter.
  # Order: None, Rain, Storm, Snow, Blizzard, Sandstorm, HeavyRain, Sun/Sunny, Fog
  ZONE_WEATHER_WINTER = [
    [50, 20, 3, 0, 0, 0, 5, 30],
    [40, 50],
    [60]
  ]

  # Probability of weather in spring.
  # Order: None, Rain, Storm, Snow, Blizzard, Sandstorm, HeavyRain, Sun/Sunny, Fog
  ZONE_WEATHER_SPRING = [
    [50, 20, 3, 0, 0, 0, 5, 30],
    [40, 50],
    [60]
  ]
end