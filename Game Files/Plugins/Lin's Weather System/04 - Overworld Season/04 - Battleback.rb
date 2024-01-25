#===============================================================================
# * Weather System - Season Change
#===============================================================================

if WeatherConfig::SEASON_CHANGE
class Battle::Scene
  alias season_pbCreateBackdropSprites pbCreateBackdropSprites
  def pbCreateBackdropSprites
    if pbIsSummer           # Feb, Jun, Oct
      season = "summer"
    elsif pbIsAutumn        # Mar, Jul, Nov
      season = "autumn"
    elsif pbIsWinter        # Apr, Aug, Dec
      season = "winter"
    elsif pbIsSpring        # Jan, May, Sep
      season = "spring"
    end
    # Put everything together into backdrop, bases and message bar filenames
    backdropFilename = @battle.backdrop
    baseFilename = @battle.backdrop
    baseFilename = sprintf("%s_%s", baseFilename, @battle.backdropBase) if @battle.backdropBase
    messageFilename = @battle.backdrop
    if season
      trialName = sprintf("%s_%s", backdropFilename, season)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_bg"))
        backdropFilename = trialName
      end
      trialName = sprintf("%s_%s", baseFilename, season)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_base0"))
        baseFilename = trialName
      end
      trialName = sprintf("%s_%s", messageFilename, season)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_message"))
        messageFilename = trialName
      end
    end
    if !pbResolveBitmap(sprintf("Graphics/Battlebacks/" + baseFilename + "_base0")) &&
       @battle.backdropBase
      baseFilename = @battle.backdropBase
      if season
        trialName = sprintf("%s_%s", baseFilename, season)
        if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_base0"))
          baseFilename = trialName
        end
      end
    end
    @battle.backdrop = backdropFilename
    season_pbCreateBackdropSprites
  end
end
end