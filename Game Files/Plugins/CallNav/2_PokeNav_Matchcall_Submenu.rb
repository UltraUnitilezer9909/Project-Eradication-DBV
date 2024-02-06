#===============================================================================
# Phone Scene with PokenavPhone Visuals and Dynamic Menu Handlers
#===============================================================================
class PokenavPhoneButton < Sprite
  attr_reader :index
  attr_reader :name
  attr_reader :selected

  TEXT_BASE_COLOR = Color.new(107, 214, 206)
  TEXT_SHADOW_COLOR = Color.new(96, 120, 118)

  
  def initialize(command, x, y, viewport = nil, trainer_name = "", rematch_check = command[2], flag_n = "", map_name = command[3], trainer_type_id = command[4])
    super(viewport)
    @image = command[0]
    @name = command[1]
	@flag = flag_n
    @rematch_check = command[2]
    @selected = false
	@map_name = map_name
    @trainer_name = trainer_name
    @trainer_type = command[4]
     @professor = PROFESSOR
    @button = AnimatedBitmap.new("Graphics/Pictures/CallNav/icon_button")
    @contents = BitmapWrapper.new(@button.width, @button.height)

    # Add the map name text sprite initialization
    @map_name_text = Sprite.new(viewport)
    @map_name_text.bitmap = Bitmap.new(205, 30)  # Adjust the size of the bitmap as needed
    @map_name_text.x = x -330 # Adjust the X position of the map name text
    @map_name_text.y = y + 289 + @button.height / 2  # Adjust the Y position of the map name text
    pbSetSystemFont(@map_name_text.bitmap)
    refresh_map_name

    self.bitmap = @contents
    self.x = x - (@button.width / 2)
    self.y = y
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
    @button.dispose
    @contents.dispose
	@map_name_text.bitmap.dispose
    @map_name_text.dispose
    super
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel != val
  end

  def extract_trainer_type(full_name)
    # Assuming the full_name is in the format "Camper Joe", extract the first part before the space.
    trainer_type = full_name.split(' ').first
    # You may also want to convert the trainer_type to uppercase if necessary.
    # For example: trainer_type.upcase
    return trainer_type
  end
  
  # Add the missing map_name_text method to handle the map name text
  def map_name_text=(new_map_name)
    @map_name = new_map_name
    refresh_map_name
  end
  
    def map_name_text
    @map_name_text
  end

  def refresh_map_name
    # Clear the previous map name text
    @map_name_text.bitmap.clear
    # Draw the new map name text
    text = @map_name
    base_color = TEXT_BASE_COLOR
    shadow_color = TEXT_SHADOW_COLOR
    textpos = [[text, @map_name_text.bitmap.width / 2, 0, 2, base_color, shadow_color]]
    pbDrawTextPositions(@map_name_text.bitmap, textpos)
  end
  
  def refresh
    self.bitmap.clear
    rect = Rect.new(0, 0, @button.width, @button.height / 2)
    rect.y = @button.height / 2 if @selected
    self.bitmap.blt(0, 0, @button.bitmap, rect)
    @map_name_text.visible = @selected
    refresh_map_name

    # Split the name into two parts: Trainer Type and Trainer Name
    trainer_type, trainer_name = @name.split(' ', 2)

    # Check the length of the combined Trainer Type and Name
if @name.length > 15
  # If the combined name exceeds 15 characters, display Trainer Type on the first line and Trainer Name on the second line
pbSetNarrowFont(self.bitmap)
  textpos_type = [
    [@name, rect.width / 2, (rect.height / 2) - 10, 2, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]
  ]
  textpos_name = [] # Empty array for Trainer Name (second line) since it fits in a single line
else
  # If the combined name doesn't exceed 15 characters, display the whole name in a single line with the default font size
  textpos_type = [
    [@name, rect.width / 2, (rect.height / 2) - 10, 2, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]
  ]
  textpos_name = [] # Empty array for Trainer Name (second line) since it fits in a single line
end

pbDrawTextPositions(self.bitmap, textpos_type + textpos_name)
#===============================================================================
# Handles the rematch icon for trainer battles
#===============================================================================
    if @rematch_check == true && @trainer_type.start_with?("TEAMAQUA_")
    vsseeker_bitmap = Bitmap.new("Graphics/Pictures/CallNav/Flag_Icons/vsseeker_aqua.png")
    vsseeker_width = 32  # Set the desired width (e.g., 16)
    vsseeker_height = 32  # Set the desired height (e.g., 16)
    self.bitmap.stretch_blt(Rect.new(0, 10, vsseeker_width, vsseeker_height), vsseeker_bitmap, Rect.new(0, 0, 64, 64))
    vsseeker_bitmap.dispose
	else
	if @rematch_check == true && @trainer_type.start_with?("TEAMMAGMA_")
    vsseeker_bitmap = Bitmap.new("Graphics/Pictures/CallNav/Flag_Icons/vsseeker_magma.png")
    vsseeker_width = 32  # Set the desired width (e.g., 16)
    vsseeker_height = 32  # Set the desired height (e.g., 16)
    self.bitmap.stretch_blt(Rect.new(0, 10, vsseeker_width, vsseeker_height), vsseeker_bitmap, Rect.new(0, 0, 64, 64))
    vsseeker_bitmap.dispose
	else
	    if @rematch_check == true && @trainer_type.start_with?("TEAMROCKET_")
    vsseeker_bitmap = Bitmap.new("Graphics/Pictures/CallNav/Flag_Icons/vsseeker_rocket.png")
    vsseeker_width = 32  # Set the desired width (e.g., 16)
    vsseeker_height = 32  # Set the desired height (e.g., 16)
    self.bitmap.stretch_blt(Rect.new(0, 10, vsseeker_width, vsseeker_height), vsseeker_bitmap, Rect.new(0, 0, 64, 64))
    vsseeker_bitmap.dispose
	else 
	if @rematch_check == true
    vsseeker_bitmap = Bitmap.new("Graphics/Pictures/CallNav/Flag_Icons/vsseeker.png")
    vsseeker_width = 32  # Set the desired width (e.g., 16)
    vsseeker_height = 32  # Set the desired height (e.g., 16)
    self.bitmap.stretch_blt(Rect.new(0, 10, vsseeker_width, vsseeker_height), vsseeker_bitmap, Rect.new(0, 0, 64, 64))
    vsseeker_bitmap.dispose
  end
end
end
end
#===============================================================================
# Handles custom icons for NPCs by overriding the rematch icon
#===============================================================================
# This one gives Professor Oak a pokedex icon next to him
#===============================================================================
    if @name == @professor
    vsseeker_bitmap = Bitmap.new("Graphics/Pictures/CallNav/NPC_Icons/pokedex.png")
    vsseeker_width = 32  # Set the desired width (e.g., 16)
    vsseeker_height = 32  # Set the desired height (e.g., 16)
    self.bitmap.stretch_blt(Rect.new(0, 10, vsseeker_width, vsseeker_height), vsseeker_bitmap, Rect.new(0, 0, 64, 64))
    vsseeker_bitmap.dispose
  end
#===============================================================================
# Dynamicly handles names and generic NPC trainer picures
#===============================================================================
    icon_filename = "Graphics/Pictures/CallNav/Face_Icons/icon_#{@name}.png"
    if icon_exists?(icon_filename)
      icon_bitmap = Bitmap.new(icon_filename)
      self.bitmap.blt(8, -11, icon_bitmap, Rect.new(0, 0, 64, 64)) if icon_bitmap
      icon_bitmap.dispose if icon_bitmap
    else
      icon_filename = "Graphics/Pictures/CallNav/Face_Icons/icon_#{@trainer_type}.png"
      if icon_exists?(icon_filename)
        icon_bitmap = Bitmap.new(icon_filename)
        self.bitmap.blt(8, -11, icon_bitmap, Rect.new(0, 0, 64, 64)) if icon_bitmap
        icon_bitmap.dispose if icon_bitmap
      else
        icon_filename = "Graphics/Pictures/CallNav/Face_Icons/icon_Default.png"
        icon_bitmap = Bitmap.new(icon_filename)
        self.bitmap.blt(8, -11, icon_bitmap, Rect.new(0, 0, 64, 64)) if icon_bitmap
        icon_bitmap.dispose if icon_bitmap
      end
    end
end
  
  def icon_exists?(filename)
    File.exist?(filename)
  end
end

#===============================================================================
# Phone Scene with PokenavPhone Visuals and Dynamic Menu Handlers
#===============================================================================
class PokemonPokenavPhone_Scene
  MAX_VISIBLE_HANDLERS = 5

  def pbUpdate
    @commands.length.times do |i|
      @sprites["button#{i}"].selected = (i == @index)
      button_height = @sprites["button#{i}"].bitmap.height / 2
      visible_handlers = [MAX_VISIBLE_HANDLERS, @commands.length].min
      total_height = visible_handlers * button_height
      @sprites["button#{i}"].y = ((Graphics.height - total_height) / 2) + ((i - @scroll_index) * button_height)
      @sprites["button#{i}"].visible = i >= @scroll_index && i < @scroll_index + visible_handlers

      # Update the visibility of the map name text based on the currently selected button
      @sprites["button#{i}"].map_name_text.visible = (i == @index)
    end

    pbUpdateSlidingImage
    pbUpdateSpriteHash(@sprites)
  end

def pbUpdateSlidingImage
  sliding_speed = 8 # Adjust the sliding speed as desired
  @sprites["NavTitle"].x += sliding_speed if @sprites["NavTitle"].x < @NavTitle_target_x
  @sprites["MatchCallText"].x += sliding_speed if @sprites["MatchCallText"].x < @MatchCallText_target_x
end

def pbStartScene(commands)
  @commands = commands
  @index = 0
  @scroll_index = 0
  @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  @viewport.z = 99999
  @sprites = {}
  @sprites["background"] = IconSprite.new(0, 0, @viewport)
  @sprites["background"].setBitmap("Graphics/Pictures/CallNav/Call_bg.png")
  pbCreateButtons
  pbCreateNavTitle
  pbCreateMatchCallText
  pbUpdate
end
  
def pbCreateNavTitle
  @sprites["NavTitle"] = Sprite.new(@viewport)
  @sprites["NavTitle"].bitmap = Bitmap.new("Graphics/Pictures/CallNav/matchcall")
  @sprites["NavTitle"].x = -@sprites["NavTitle"].bitmap.width
  @sprites["NavTitle"].y = 15 # Adjust the Y position as needed
  @NavTitle_target_x = -8
end

def pbCreateMatchCallText
  @sprites["MatchCallText"] = Sprite.new(@viewport)
  @sprites["MatchCallText"].bitmap = Bitmap.new(Graphics.width, 64)
  pbSetSystemFont(@sprites["MatchCallText"].bitmap)
  
  # Draw the text with a drop shadow
  rect = Rect.new(0, 0, Graphics.width, 64)
  text = "Match Call"
  base_color = PokenavPhoneButton::TEXT_BASE_COLOR
  shadow_color = PokenavPhoneButton::TEXT_SHADOW_COLOR
  textpos = [[text, rect.width / 2, (rect.height / 2) - 10, 2, base_color, shadow_color]]
  pbDrawTextPositions(@sprites["MatchCallText"].bitmap, textpos)
  
  @sprites["MatchCallText"].x = -@sprites["MatchCallText"].bitmap.width
  @sprites["MatchCallText"].y = (@sprites["NavTitle"].y) - 5 # Adjust the Y position as needed
  @MatchCallText_target_x = @NavTitle_target_x -150
end

#Note: As the effects of each handler are directly tied to phone index
#	   you can use pbPhoneRegisterNPCSilent to reserve an index number without
#	   a registration message then use switches to reveal the menu handler.
#===============================================================================
def pbCreateButtons
  @commands.each_with_index do |command, i|
    x_pos = Graphics.width / 2 + 102
    rematch_check = command[2]
    flag_n = command[4]  # Get the flag value from the command list
    map_name = command[3]
    @sprites["button#{i}"] = PokenavPhoneButton.new(command, x_pos, 0, @viewport, "", rematch_check, flag_n, map_name)
  end
end


  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = @index
        break
      elsif Input.trigger?(Input::UP)
        pbPlayCursorSE if @commands.length > 1
        @index -= 1
        @index = @commands.length - 1 if @index < 0
        update_scroll_index
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE if @commands.length > 1
        @index += 1
        @index = 0 if @index >= @commands.length
        update_scroll_index
      end
    end
    return ret
  end

  def update_scroll_index
    return if @commands.length <= MAX_VISIBLE_HANDLERS

    if @index < @scroll_index
      @scroll_index = @index
    elsif @index >= @scroll_index + MAX_VISIBLE_HANDLERS
      @scroll_index = @index - MAX_VISIBLE_HANDLERS + 1
    end

    # Update the visibility of menu handlers
    @commands.length.times do |i|
      button_height = @sprites["button#{i}"].bitmap.height / 2
      visible_handlers = [MAX_VISIBLE_HANDLERS, @commands.length].min
      total_height = visible_handlers * button_height
      @sprites["button#{i}"].y = ((Graphics.height - total_height) / 2) + ((i - @scroll_index) * button_height)
      @sprites["button#{i}"].visible = i >= @scroll_index && i < @scroll_index + visible_handlers
    end
  end

def pbEndScene
  pbUpdate
  pbDisposeSpriteHash(@sprites)
  @viewport.dispose
  pbDisposeNavTitle
  pbDisposeMatchCallText
end

  def pbDisposeNavTitle
    if @sprites["NavTitle"] && !@sprites["NavTitle"].disposed?
      @sprites["NavTitle"].bitmap.dispose
      @sprites["NavTitle"].dispose
    end
  end

  def pbDisposeMatchCallText
    if @sprites["MatchCallText"] && !@sprites["MatchCallText"].disposed?
      @sprites["MatchCallText"].bitmap.dispose
      @sprites["MatchCallText"].dispose
    end
  end
end
#===============================================================================
# Phone Scene with PokenavPhone Visuals and Dynamic Menu Handlers
#===============================================================================
class PokemonPokenavPhoneScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    # Get all commands
    command_list = []
    commands = []
    pbAddPhoneNumberCommands(command_list, commands)  # Add this line to include phone numbers initially

    # Separate commands with "NPC" flag from others and sort accordingly
    npc_commands = []
    non_npc_commands = []
    commands.each_with_index do |command, index|
      if command["NPC"]
        npc_commands.push(command_list[index])
      else
        non_npc_commands.push(command_list[index])
      end
    end

    command_list = npc_commands + non_npc_commands
    commands = commands.select { |command| command["NPC"] } + commands.reject { |command| command["NPC"] }

    @scene.pbStartScene(command_list)
    # Main loop
    loop do
      choice = @scene.pbScene
      if choice < 0
        break
      end
      ret = commands[choice]["effect"].call(@scene)
      # No need to refresh the scene since the effect only involves displaying text
    end
    @scene.pbEndScene
  end


def pbAddPhoneNumberCommands(command_list, commands)
  # Get phone numbers from $PokemonGlobal.phoneNumbers and add commands
  if $PokemonGlobal.phoneNumbers
    $PokemonGlobal.phoneNumbers.each do |num|
      if num[0]   # if visible
        if num.length == 8   # if trainer
          trainer_name = _INTL("{1} {2}", GameData::TrainerType.get(num[1]).name,
                               pbGetMessageFromHash(MessageTypes::TrainerNames, num[2]))
		  trainer_type_id = "#{num[1]}"
          rematch_check = (num[4] == 2) || (num[4] == 3)
          map_data = num[6]
          map_name = "#{pbGetMapNameFromId(map_data)}"  # Dynamically retrieve map name
          command_list.push([num[1], trainer_name, rematch_check, map_name, trainer_type_id])  # Store map name instead of map_data
          commands.push({
            "name"          => trainer_name,
            "rematch_check" => rematch_check,
            "map_name"      => map_name,  # Store map name instead of map_data
			"trainer_type_id" => trainer_type_id,
            "effect"        => proc { |scene|
              pbCallTrainer(num[1], num[2])
              next false
            }
          })
		  puts "Created NPC handler for: #{num[1]}"
          puts "ID value: #{num[2]}"
          puts "Map name: #{map_name}"
        else               # if NPC
          flag_n = ("#{num[4]}")
          map_data = num[3]
          map_name = "#{pbGetMapNameFromId(map_data)}"  # Dynamically retrieve map name
          command_list.push([num[1], num[2], num[4], map_name, flag_n])  # Store map name instead of map_data
          commands.push({
            "name"          => num[2],
            "NPC"           => true,
            "flag"          => flag_n,  # Convert the flag to an integer for NPCs
            "map_name"      => map_name,  # Store map name instead of map_data
            "effect"        => proc { |scene|
              pbCallTrainer(num[1], num[2])
              next false
            }
          })
		  puts "Created NPC handler for: #{num[2]}"
          puts "Flag value: #{num[4].to_i}"
          puts "Map name: #{map_name}"
        end
      end
    end
  end
end
end
