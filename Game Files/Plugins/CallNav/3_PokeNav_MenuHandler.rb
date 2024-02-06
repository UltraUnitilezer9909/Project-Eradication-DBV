#===============================================================================
# Monkey patch the existing PokenavButton class to add the "Phone" button icon
#===============================================================================
class PokenavButton
  alias original_refresh refresh

  def refresh
    original_refresh

    # Add the logic for the "Phone" button icon here
    if @name == "Phone"
	  empty_phone = $PokemonGlobal.phoneNumbers.nil? || $PokemonGlobal.phoneNumbers.empty?
	  if $game_switches[VSOFF] == true || empty_phone
        icon_filename = "Graphics/Pictures/CallNav/NavMenu/vsseeker_off.png"
      else
      if $game_switches[VSBLOCK] == true
        icon_filename = "Graphics/Pictures/CallNav/NavMenu/vsseeker_blocked.png"
      else
        icon_filename = "Graphics/Pictures/CallNav/NavMenu/vsseeker.png"
      end
	 end

      icon_bitmap = Bitmap.new(icon_filename)
      self.bitmap.blt(8, 6, icon_bitmap, Rect.new(0, 0, 48, 48)) if icon_bitmap
      icon_bitmap.dispose if icon_bitmap
  end
end
end
#===============================================================================
# Monkey patch the existing PokemonPokenavScreen class to add the "Phone" button
#===============================================================================
class PokemonPokenavScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    # Get all commands
    command_list = []
    commands = []
    MenuHandlers.each_available(:pokenav_menu) do |option, hash, name|
      command_list.push([hash["icon_name"] || "", name])
      commands.push(hash)
    end
    @scene.pbStartScene(command_list)
    # Main loop
    end_scene = false
    loop do
      choice = @scene.pbScene
      if choice < 0
        end_scene = true
        break
      end
      break if commands[choice]["effect"].call(@scene)
    end
    @scene.pbEndScene if end_scene
  end
  end

#===============================================================================
# Add the new "Phone" option to the existing Pokenav menu
#===============================================================================
MenuHandlers.add(:pokenav_menu, :Phone, {
  "name"      => _INTL("Phone"),
  "order"     => 70,
  "effect"    => proc { |_menu|
    # The rest of your code for the "Phone" button effect remains unchanged
    empty_phone = $PokemonGlobal.phoneNumbers.nil? || $PokemonGlobal.phoneNumbers.empty?
    if empty_phone
      pbMessage(_INTL("This function is not available."))
      Input.update
    else
	if $game_switches[VSOFF] == true
          pbMessage(_INTL("This function is not available."))
          Input.update
        else
      if $game_switches[VSBLOCK] == true
        pbMessage(_INTL("Some strange interference is blocking calls."))
        Input.update
      else
		  scene = PokemonPokenavPhone_Scene.new
          screen = PokemonPokenavPhoneScreen.new(scene)
          screen.pbStartScreen
        end
      end
    end
  }
})
