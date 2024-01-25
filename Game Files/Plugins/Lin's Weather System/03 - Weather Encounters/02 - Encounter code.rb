#===============================================================================
# * Weather System - Encounters code
#===============================================================================

class PokemonEncounters
  # Checks the defined encounters for the current map and returns the encounter
  # type that the given weather should produce. Only returns an encounter type if
  # it has been defined for the current map.
  def find_valid_encounter_type_for_weather(base_type, new_type)
    ret = nil
    try_type = nil
    weather = $game_screen.weather_type if $game_screen.weather_type != :None
    try_type = (new_type.to_s + weather.to_s).to_sym
    if try_type && !has_encounter_type?(try_type)
      try_type = (base_type.to_s + weather.to_s).to_sym
    end
    ret = try_type if try_type && has_encounter_type?(try_type)
    return ret if ret
    return (has_encounter_type?(base_type)) ? base_type : nil
  end

  # Checks the defined encounters for the current map and returns the encounter
  # type that the given time should produce. Only returns an encounter type if
  # it has been defined for the current map.
  def find_valid_encounter_type_for_time(base_type, time)
    ret = nil
    if PBDayNight.isDay?(time)
      try_type = nil
      if PBDayNight.isMorning?(time)
        try_type = (base_type.to_s + "Morning").to_sym
      elsif PBDayNight.isAfternoon?(time)
        try_type = (base_type.to_s + "Afternoon").to_sym
      elsif PBDayNight.isEvening?(time)
        try_type = (base_type.to_s + "Evening").to_sym
      end
      ret = try_type if try_type && has_encounter_type?(try_type)
      if !ret
        try_type = (base_type.to_s + "Day").to_sym
        ret = try_type if has_encounter_type?(try_type)
      end
    else
      try_type = (base_type.to_s + "Night").to_sym
      ret = try_type if has_encounter_type?(try_type)
    end
    ret = find_valid_encounter_type_for_weather(base_type, try_type)
    return ret if ret
    return (has_encounter_type?(base_type)) ? base_type : nil
  end

  # Returns the encounter method that the current encounter should be generated
  # from, depending on the player's current location.
  def encounter_type
    time = pbGetTimeNow
    ret = nil
    if $PokemonGlobal.surfing
      ret = find_valid_encounter_type_for_time(:Water, time)
    else   # Land/Cave (can have both in the same map)
      if has_land_encounters? && $game_map.terrain_tag($game_player.x, $game_player.y).land_wild_encounters
        ret = :BugContest if pbInBugContest? && has_encounter_type?(:BugContest)
        ret = find_valid_encounter_type_for_time(:Land, time) if !ret
      end
      if !ret && has_cave_encounters?
        ret = find_valid_encounter_type_for_time(:Cave, time)
      end
    end
    return ret
  end
end