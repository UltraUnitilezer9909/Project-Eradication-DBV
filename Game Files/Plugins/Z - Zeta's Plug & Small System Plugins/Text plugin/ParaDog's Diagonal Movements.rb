#==============================================================================
#     Diagonal Movement for Essentials V1.0
#　　Script by ParaDog and Modified by Pia Carrot
#------------------------------------------------------------------------------
# Additional 'diagonal' movement is now possible by pushing combinations of the
# vertical and horizontal controls (up & left, etc) simultaneously.
#
# Additional charsets  for the  8-directional movement  are to be stored within
# the "Graphics/Characters" folder, just like the regular charactersets.
#
# Name the new  diagonal movement charactersets  the same  as the regular ones,
# but with a new '_quarter' extension.   As such, you would name a copy of a character 
#file named "Red" as: Red_quarter.
#
#
#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player. Its functions include event starting
#  determinants and map scrolling. Refer to "$game_player" for the one
#  instance of this class.
#==============================================================================
=begin
 class PokemonMenu_Scene
  def pbShowCommands(commands)
    ret = -1
    cmdwindow = @sprites["cmdwindow"]
    cmdwindow.viewport = @viewport
    cmdwindow.index = $PokemonTemp.menuLastChoice
    cmdwindow.resizeToFit(commands)
    cmdwindow.commands = commands
    cmdwindow.x = Graphics.width - cmdwindow.width
    cmdwindow.y = 0
    cmdwindow.visible = true
    loop do
      $game_switches[87] = true
      cmdwindow.update
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::B)
        $game_switches[87] = false
        ret = -1
        break
      end
      if Input.trigger?(Input::C)
        ret = cmdwindow.index
        $PokemonTemp.menuLastChoice = ret
        break
      end
    end
    return ret
  end
end
=end

class Game_Player < Game_Character
  alias update_para_quarter update
  def update
    update_para_quarter
    unless $game_player.moving? && !pbMapInterpreterRunning? && $game_switches[88] && !@move_route_forcing && $game_temp.message_window_showing && $game_switches[87]
      if !$game_switches[88] && !$game_temp.message_window_showing && !@move_route_forcing && !pbMapInterpreterRunning? && !$game_player.moving?
        case Input.dir8
        when 1 then move_lower_left
        when 3 then move_lower_right
        when 7 then move_upper_left
        when 9 then move_upper_right
        end
      end
    end
  end
end

class Sprite_Character < RPG::Sprite
  alias update_para_quarter update
  def update
    update_para_quarter
    if @tile_id == 0
      if (@character.direction - 2) % 2 == 1
        if quarter_graphic_exist?(@character)
          if character.dash_on && dash_quarter_graphic_exist?(@character)
            @character_name = @character.character_name
          else
            @character_name = @character.character_name
          end
          self.bitmap = RPG::Cache.character(@character_name, @character.character_hue)
          case @character.direction
          when 1 then n = 0
          when 3 then n = 2
          when 7 then n = 1
          when 9 then n = 3
          end
        else
          @character.direction = @character.sub_direction
          n = (@character.direction - 2) / 2
        end
        sx = @character.pattern * @cw
        sy = n * @ch
        self.src_rect.set(sx, sy, @cw, @ch)
      else
        self.bitmap = RPG::Cache.character(@character.character_name, @character.character_hue)
        sx = @character.pattern * @cw
        sy = (@character.direction - 2) / 2 * @ch
        self.src_rect.set(sx, sy, @cw, @ch)
      end
    end
    if @tile_id == 0
      @cw = @charbitmap.width / 4
      @ch = @charbitmap.height / 4
      @charbitmap = AnimatedBitmap.new("Graphics/Characters/" + @character_name, @character_hue)
      @charbitmapAnimated = true
      @bushbitmap = nil
      @charbitmap.update if @charbitmapAnimated
      bushdepth = @character.bush_depth
      if bushdepth == 0
        self.bitmap = (@charbitmapAnimated) ? @charbitmap.bitmap : @charbitmap
      else
        @bushbitmap = BushBitmap.new(@charbitmap, (@tile_id == 384), bushdepth) if !@bushbitmap
        self.bitmap = @bushbitmap.bitmap
      end
      self.visible = !@character.transparent
      if @tile_id == 0
        sx = @character.pattern * @cw
        self.src_rect.set(sx, sy, @cw, @ch)
        self.oy = (@spriteoffset rescue false) ? @ch - 16 : @ch
        self.oy -= @character.bob_height
      end
    end
  end

  def quarter_graphic_exist?(character)
    begin
	  #RPG::Cache.character(character.character_name.to_s + "_quarter", character.character_hue)
      RPG::Cache.character(character.character_name.to_s, character.character_hue)
    rescue
      return false
    end
    return true
  end

  def dash_quarter_graphic_exist?(character)
    begin
	  ##RPG::Cache.character(character.character_name.to_s + "_dash_quarter", character.character_hue)
      RPG::Cache.character(character.character_name.to_s, character.character_hue)
    rescue
      return false
    end
    return true
  end
end

class Game_Character
  attr_accessor   :direction
  attr_accessor   :sub_direction

  def move_lower_left
    unless @direction_fix
      @sub_direction = @direction
      @direction = 1
      @sub_direction = (@sub_direction == 6 ? 4 : @sub_direction == 8 ? 2 : @sub_direction)
    end
    return if pbLedge(-1, 1)
    return if pbEndSurf(-1, 1)
    return if moving?
    if (passable?(@x, @y, 2) && passable?(@x, @y + 1, 4)) ||
       (passable?(@x, @y, 4) && passable?(@x - 1, @y, 2))
      @x -= 1
      @y += 1
      increase_steps
    end
  end

  def move_lower_right
    unless @direction_fix
      @sub_direction = @direction
      @direction = 3
      @sub_direction = (@sub_direction == 4 ? 6 : @sub_direction == 8 ? 2 : @sub_direction)
    end
    return if pbLedge(1, 1)
    return if pbEndSurf(1, 1)
    return if moving?
    if (passable?(@x, @y, 2) && passable?(@x, @y + 1, 6)) ||
       (passable?(@x, @y, 6) && passable?(@x + 1, @y, 2))
      @x += 1
      @y += 1
      increase_steps
    end
  end

  def move_upper_left
    unless @direction_fix
      @sub_direction = @direction
      @direction = 7
      @sub_direction = (@sub_direction == 6 ? 4 : @sub_direction == 2 ? 8 : @sub_direction)
    end
    return if pbLedge(-1, -1)
    return if pbEndSurf(-1, -1)
    return if moving?
    if (passable?(@x, @y, 8) && passable?(@x, @y - 1, 4)) ||
       (passable?(@x, @y, 4) && passable?(@x - 1, @y, 8))
      @x -= 1
      @y -= 1
      increase_steps
    end
  end

  def move_upper_right
    unless @direction_fix
      @sub_direction = @direction
      @direction = 9
      @sub_direction = (@sub_direction == 4 ? 6 : @sub_direction == 2 ? 8 : @sub_direction)
    end
    return if pbLedge(1, -1)
    return if pbEndSurf(1, -1)
    return if moving?
    if (passable?(@x, @y, 8) && passable?(@x, @y - 1, 6)) ||
       (passable?(@x, @y, 6) && passable?(@x + 1, @y, 8))
      @x += 1
      @y -= 1
      increase_steps
    end
  end

  def dash_on
    @dash_on != nil ? @dash_on : false
  end
end
