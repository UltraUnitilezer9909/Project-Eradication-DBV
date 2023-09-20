# FakeMapNameWindow: $scene.spriteset.addUserSprite(FakeMapNameWindow.new($game_map.name))

# FakeMapNameWindow

class FakeMapNameWindow
  def initialize(name = $game_map.name, color = "<c3=940fff,6300b4>")
    @name = name
    @color = color
    create_window
  end

  def create_window
    @window = Window_AdvancedTextPokemon.new("#{@color}#{@name}") #("#{@color}#{@name}") ("\\w[#{wn}]#{@color}#{@name}", wn)
    @window.setSkin("Graphics/Windowskins/bw map post")
    @window.resizeToFit(@name, Graphics.width)
    @window.x = 0
    @window.y = -@window.height
    @window.viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @window.viewport.z = 99999
    @current_map_id = $game_map.map_id
    @frames = 0
  end

  def disposed?
    @window.disposed?
  end

  def dispose
    @window.dispose
  end

  def update
    return if @window.disposed?
    @window.update
    if message_window_active? || map_changed?
      @window.dispose
      return
    end
    move_window
  end

  def message_window_active?
    $game_temp.message_window_showing
  end

  def map_changed?
    @current_map_id != $game_map.map_id
  end

  def move_window
    if @frames > Graphics.frame_rate * 2
      @window.y -= 4
      @window.dispose if @window.y + @window.height < 0
    else
      @window.y += 4 if @window.y < 0
      @frames += 1
    end
  end
end