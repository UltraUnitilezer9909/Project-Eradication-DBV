#=====================================================================
# Adjustable Dark Circles
#
# Written by Mej71 for the "Blinded by the Fright" 2016 Game Jam on
# PokeCommunity.
#
# Ported to Version 20.1 of Essentials by DerxwnaKapsyla
#=====================================================================

# --- DEFAULT SETTING ---
DEFAULTDARKCIRCLERAD = 64		# Sets the default radius for the Dark Circle. Default is 64.

# --- CODE BELOW ---
$DarknessSprite = nil

class Player
  attr_writer :beginDarkCircle
  attr_writer :darkCircleRadius
   
  def beginDarkCircle
    @beginDarkCircle = false if !@beginDarkCircle
    return @beginDarkCircle
  end
  
  def darkCircleRadius
    if !@darkCircleRadius
      @darkCircleRadius = DEFAULTDARKCIRCLERAD
    end
    return @darkCircleRadius
  end  
end

def beginDarkCircle
  $DarknessSprite = DarknessSprite.new
  $DarknessSprite.radius = $player.darkCircleRadius
  $player.beginDarkCircle = true
end

def endDarkCircle
  return if !$player.beginDarkCircle
  $DarknessSprite.dispose
  $DarknessSprite = nil
  $player.beginDarkCircle = false
  $player.darkCircleRadius = DEFAULTDARKCIRCLERAD
end

def changeDarkCircleRadius(newRadius)
  return if $DarknessSprite == nil
  $player.darkCircleRadius = newRadius
  $DarknessSprite.radius = $player.darkCircleRadius
end

def changeDarkCircleRadiusSlowly(newRadius)
  return if $DarknessSprite == nil
  $player.darkCircleRadius = newRadius
  changeRate = (newRadius - $DarknessSprite.radius)/12
  return if changeRate == 0
  for i in 0...12
    $DarknessSprite.radius += changeRate
    pbWait(1)
  end
  $DarknessSprite.radius = $player.darkCircleRadius
end


#Events.onMapSceneChange+=proc{|sender,e|
#  scene=e[0]
#  mapChanged=e[1]
#  return if !$player
#  beginDarkCircle if $player.beginDarkCircle && $DarknessSprite == nil
#  if $player.beginDarkCircle && $game_temp.darkness_sprite
#    $game_temp.darkness_sprite.dispose
#    $game_temp.darkness_sprite = nil
#  end
#}

EventHandlers.add(:on_map_or_spriteset_change, :dark_circle_modifier,
  proc { |scene, _map_changed|
  return if !$player
  beginDarkCircle if $player.beginDarkCircle && $DarknessSprite == nil
  if $player.beginDarkCircle && $game_temp.darkness_sprite
    $game_temp.darkness_sprite.dispose
    $game_temp.darkness_sprite = nil
  end
  }
)