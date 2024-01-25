#===============================================================================
# * Weather System - Season Change
#===============================================================================

if WeatherConfig::SEASON_CHANGE
  EventHandlers.add(:on_enter_map, :season_splash,
    proc { |_old_map_id|
      next if !$game_map
      next if !$WeatherSystem.seasonSplash
      next if $game_map.metadata&.outdoor_map && $WeatherSystem.seasons[:outdoor]
      next if !$game_map.metadata&.outdoor_map && !$WeatherSystem.seasons[:outdoor]
      $WeatherSystem.seasons[:outdoor] = false
      $WeatherSystem.seasons[:outdoor] = true if $game_map.metadata&.outdoor_map
      pbSeasonSplash
    }
  )

  def pbToggleSeason(season)
    $WeatherSystem.seasons[:summer] = false
    $WeatherSystem.seasons[:autumn] = false
    $WeatherSystem.seasons[:winter] = false
    $WeatherSystem.seasons[:spring] = false
    $WeatherSystem.seasons[season] = true
  end

  def pbStartSplash
    if Essentials::VERSION.include?("20")
      filePath = "Graphics/Pictures/WeatherSystem/Seasons/Background"
      filePath2 = _INTL("Graphics/Pictures/WeatherSystem/Seasons/")
    else
      filePath = "Graphics/UI/WeatherSystem/Seasons/Background"
      filePath2 = _INTL("Graphics/UI/WeatherSystem/Seasons/")
    end
    # Initialize the sprite hash where all sprites are. This is used to easily
    # do things like update all sprites in pbUpdateSpriteHash.
    @sprites = {}
    # Creates a Viewport (works similar to a camera) with z=99999, so player can
    # see all sprites with z below 99999. The higher z sprites are above the
    # lower ones.
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    # Creates a new IconSprite object and sets its bitmap to image_path
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(filePath)
    # A little trick to centralize if the background hasn't the screen size.
    # If the background and screen are the same size, it will set x/y as 0.
    @sprites["background"].x = (Graphics.width - @sprites["background"].bitmap.width)/2
    @sprites["background"].y = (Graphics.height - @sprites["background"].bitmap.height)/2
    # Creates a new IconSprite object and sets its bitmap to image_path
    @sprites["season"] = IconSprite.new(0, 0, @viewport)
    if pbIsSummer	# Feb, Jun, Oct
      @sprites["season"].setBitmap(filePath2 + "Summer")
    elsif pbIsAutumn	# Mar, Jul, Nov
      @sprites["season"].setBitmap(filePath2 + "Autumn")
    elsif pbIsWinter	# Apr, Aug, Dec
      @sprites["season"].setBitmap(filePath2 + "Winter")
    elsif pbIsSpring	# Jan, May, Sep
      @sprites["season"].setBitmap(filePath2 + "Spring")
    end
    # If the background and screen are the same size, it will set x/y as 0.
    @sprites["season"].x = (Graphics.width - @sprites["season"].bitmap.width)/2
    @sprites["season"].y = (Graphics.height - @sprites["season"].bitmap.height)/2
    # After everything is set, show the sprites with FadeIn effect.
    pbFadeInAndShow(@sprites) { update }
    if Essentials::VERSION.include?("20")
      pbWait(Graphics.frame_rate)	# pbWait(60)
    else
      pbWait(1)
    end
    # Hide all sprites with FadeOut effect.
    pbFadeOutAndHide(@sprites) { update }
    # Remove all sprites.
    pbDisposeSpriteHash(@sprites)
    # Remove the viewpoint.
    @viewport.dispose
  end

  # Called every frame.
  def update
    # Updates all sprites in @sprites variable.
    pbUpdateSpriteHash(@sprites)
  end

  def pbSeasonSplash
    if !$WeatherSystem.seasons[:summer] && pbIsSummer           # Feb, Jun, Oct
      pbToggleSeason(:summer)
      pbStartSplash
    elsif !$WeatherSystem.seasons[:autumn] && pbIsAutumn        # Mar, Jul, Nov
      pbToggleSeason(:autumn)
      pbStartSplash
    elsif !$WeatherSystem.seasons[:winter] && pbIsWinter        # Apr, Aug, Dec
      pbToggleSeason(:winter)
      pbStartSplash
    elsif !$WeatherSystem.seasons[:spring] && pbIsSpring        # Jan, May, Sep
      pbToggleSeason(:spring)
      pbStartSplash
    end
  end
end