#===============================================================================
# * Weather System Map Display
#===============================================================================

if !PluginManager.installed?("Arcky's Region Map") && Essentials::VERSION.include?("20")
class PokemonRegionMap_Scene
  alias weather_pbStartScene pbStartScene
  def pbStartScene(as_editor = false, fly_map = false)
    weather_pbStartScene(as_editor = false, fly_map = false)
    @sprites["weatherbg"] = IconSprite.new(0, 0, @viewport)
    if PluginManager.installed?("Lin's Pokegear Themes")
      filePATH = "Graphics/Pictures/Pokegear/#{$PokemonSystem.pokegear}/weatherbg"
    else
      filePATH = "Graphics/Pictures/Pokegear/weatherbg"
    end
    @sprites["weatherbg"].setBitmap(filePATH)
    zone = pbGetMapZone(@map_x, @map_y)
	weather = :None
	if zone != nil
      weather = $WeatherSystem.actualWeather[zone].mainWeather
      weather = pbCheckValidWeather(weather, zone)
	end
    conversion = WeatherConfig::WEATHER_IMAGE
    id = conversion[weather]
    @sprites["weather"] = IconSprite.new(0, 0, @viewport)
    filePath = "Graphics/Pictures/WeatherSystem/Weather/#{id}"
    @sprites["weather"].setBitmap(filePath)
    @sprites["weather"].x = 20
    @sprites["weather"].y = 36
    refresh_fly_screen
    @changed = false
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbMapScene
    x_offset = 0
    y_offset = 0
    new_x    = 0
    new_y    = 0
    dist_per_frame = 8 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if x_offset != 0 || y_offset != 0
        x_offset += (x_offset > 0) ? -dist_per_frame : (x_offset < 0) ? dist_per_frame : 0
        y_offset += (y_offset > 0) ? -dist_per_frame : (y_offset < 0) ? dist_per_frame : 0
        @sprites["cursor"].x = new_x - x_offset
        @sprites["cursor"].y = new_y - y_offset
        next
      end
      ox = 0
      oy = 0
      case Input.dir8
      when 1, 2, 3
        oy = 1 if @map_y < BOTTOM
      when 7, 8, 9
        oy = -1 if @map_y > TOP
      end
      case Input.dir8
      when 1, 4, 7
        ox = -1 if @map_x > LEFT
      when 3, 6, 9
        ox = 1 if @map_x < RIGHT
      end
      if ox != 0 || oy != 0
        @map_x += ox
        @map_y += oy
        x_offset = ox * SQUARE_WIDTH
        y_offset = oy * SQUARE_HEIGHT
        new_x = @sprites["cursor"].x + x_offset
        new_y = @sprites["cursor"].y + y_offset
      end
      @sprites["mapbottom"].maplocation = pbGetMapLocation(@map_x, @map_y)
      @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@map_x, @map_y)
      filePath = pbGetWeatherDetails(@map_x, @map_y)
      @sprites["weather"].setBitmap(filePath)
      if Input.trigger?(Input::BACK)
        if @editor && @changed
          pbSaveMapData if pbConfirmMessage(_INTL("Save changes?")) { pbUpdate }
          break if pbConfirmMessage(_INTL("Exit from the map?")) { pbUpdate }
        else
          break
        end
      elsif Input.trigger?(Input::USE) && @mode == 1   # Choosing an area to fly to
        healspot = pbGetHealingSpot(@map_x, @map_y)
        if healspot && ($PokemonGlobal.visitedMaps[healspot[0]] ||
           ($DEBUG && Input.press?(Input::CTRL)))
          return healspot if @fly_map
          name = pbGetMapNameFromId(healspot[0])
          return healspot if pbConfirmMessage(_INTL("Would you like to use Fly to go to {1}?", name)) { pbUpdate }
        end
      elsif Input.trigger?(Input::USE) && @editor   # Intentionally after other USE input check
        pbChangeMapLocation(@map_x, @map_y)
      elsif Input.trigger?(Input::ACTION) && !@wallmap && !@fly_map && pbCanFly?
        pbPlayDecisionSE
        @mode = (@mode == 1) ? 0 : 1
        refresh_fly_screen
      end
    end
    pbPlayCloseMenuSE
    return nil
  end
end
end