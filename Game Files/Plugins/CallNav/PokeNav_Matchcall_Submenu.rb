#===============================================================================
# Phone Scene with PokenavPhone Visuals and Dynamic Menu Handlers
#===============================================================================
class PokenavPhoneButton < Sprite
  attr_reader :index
  attr_reader :name
  attr_reader :selected

  TEXT_BASE_COLOR = Color.new(248, 248, 248)
  TEXT_SHADOW_COLOR = Color.new(40, 40, 40)

  
  def initialize(command, x, y, viewport = nil, trainer_name = "")
    super(viewport)
    @image = command[0]
    @name = command[1]
    @selected = false
    @trainer_name = trainer_name
    @trainer_type = extract_trainer_type(@name)
    @button = AnimatedBitmap.new("Graphics/Pictures/CallNav/icon_button")
    @contents = BitmapWrapper.new(@button.width, @button.height)
    self.bitmap = @contents
    self.x = x - (@button.width / 2)
    self.y = y
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
    @button.dispose
    @contents.dispose
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

def refresh
    self.bitmap.clear
    rect = Rect.new(0, 0, @button.width, @button.height / 2)
    rect.y = @button.height / 2 if @selected
    self.bitmap.blt(0, 0, @button.bitmap, rect)
    textpos = [
      [@name, rect.width / 2, (rect.height / 2) - 10, 2, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]
    ]
	    # Display the icon based on the sender type
    pbDrawTextPositions(self.bitmap, textpos)
    icon_filename = "Graphics/Pictures/CallNav/Face_Icons/icon_#{@name}.png"
    if icon_exists?(icon_filename)
      icon_bitmap = Bitmap.new(icon_filename)
      self.bitmap.blt(8, -11, icon_bitmap, Rect.new(0, 0, 64, 64)) if icon_bitmap
      icon_bitmap.dispose if icon_bitmap
    else
    # Display the icon based on the sender name
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
    end
    pbUpdateSpriteHash(@sprites)
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
    pbUpdate
  end

  def pbCreateButtons
    @commands.each_with_index do |command, i|
      x_pos = Graphics.width / 2 + 102
      @sprites["button#{i}"] = PokenavPhoneButton.new(command, x_pos, 0, @viewport)
      # Additional logic for setting flags here if necessary
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
    dispose
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
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
    MenuHandlers.each_available(:PokenavPhone_menu) do |option, hash, name|
      command_list.push([hash["icon_name"] || "", name])
      commands.push(hash)
    end
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
            command_list.push(["phone_trainer", trainer_name])
            commands.push({
              "name"      => trainer_name,
              "effect"    => proc { |scene|
                pbCallTrainer(num[1], num[2])
                next false
              }
            })
          else               # if NPC
            command_list.push([num[2], num[2]])
            commands.push({
              "name"      => num[2],
              "effect"    => proc { |scene|
                pbCallTrainer(num[1], num[2])
                next false
              }
            })
          end
        end
      end
    end
  end
end