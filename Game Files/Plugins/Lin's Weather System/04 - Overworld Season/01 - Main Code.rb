#===============================================================================
# * Weather System - Season Change
#===============================================================================

if WeatherConfig::SEASON_CHANGE
class Game_Map
  alias season_updateTileset updateTileset
  def updateTileset
    tilesets = WeatherConfig::OUTDOOR_TILESETS
    if tilesets.include?(@map.tileset_id)
      if pbIsSummer           # Feb, Jun, Oct
        tileset = $data_tilesets[@map.tileset_id += WeatherConfig::SUMMER_TILESET]
      elsif pbIsAutumn        # Mar, Jul, Nov
        tileset = $data_tilesets[@map.tileset_id += WeatherConfig::AUTUMN_TILESET]
      elsif pbIsWinter        # Apr, Aug, Dec
        tileset = $data_tilesets[@map.tileset_id += WeatherConfig::WINTER_TILESET]
      elsif pbIsSpring        # Jan, May, Sep
        tileset = $data_tilesets[@map.tileset_id += WeatherConfig::SPRING_TILESET]
      end
    else
      tileset = $data_tilesets[@map.tileset_id]
    end
    season_updateTileset
  end
end
end