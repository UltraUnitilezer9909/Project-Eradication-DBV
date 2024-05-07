#direction => 1 ( up ) 2 ( down )
#tiles => how many does it move
class ZF # Zeta's Feilds
  def waterfall(direction, tiles)
    return if $game_player.direction != 8 && direction == 1 # not facing up
    return if $game_player.direction != 2 && direction == 2 # not facing down
    return if direction < 1 || direction > 2 || tiles < 0 # return if  the input is invalid
    move = 0
    oldthrough = $game_player.through; oldmovespeed = $game_player.move_speed # save the previus state
    $game_player.through = true; $game_player.move_speed = 2 # override the state
    until move == tiles do
      direction == 2 ? $game_player.move_down : $game_player.move_up
      move += 1 if move != tiles
    end
    $game_player.through = oldthrough; $game_player.move_speed = oldmovespeed # return to original state
  end
end

def ZWF(direction = 1, tiles = 0)
  zf = ZF.new
  zf.waterfall(direction, tiles)
end
