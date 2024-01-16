#===============================================================================
# * Notebook Pokegear - by LinKazamine (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It creates a scene for the pokegear.
#
#== INSTALLATION ===============================================================
#
# Drop the folder in your Plugin's folder.
#
#===============================================================================

class NoteBgScene
  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    if PluginManager.installed?("Pokegear Themes") && NoteConfig::THEME_CHANGE == true
      image_path = NoteConfig::BACKGROUND_PATH + "#{$PokemonSystem.pokegear}/" + NoteConfig::BACKGROUND
    else
      image_path = NoteConfig::BACKGROUND_PATH + NoteConfig::BACKGROUND
    end
    @sprites["background"].setBitmap(image_path)
    @sprites["background"].x = (Graphics.width - @sprites["background"].bitmap.width)/2
    @sprites["background"].y = (Graphics.height - @sprites["background"].bitmap.height)/2
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbFadeInAndShow(@sprites) { update }
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class NoteBgScreen
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    pbPCNotebook
    @scene.pbEndScene
  end
end

def pbNoteBg
  pbFadeOutIn(99999) {
    scene = NoteBgScene.new
    screen = NoteBgScreen.new(scene)
    screen.pbStartScreen
  }
end