#===============================================================================
# Summary additions. Adds mastery display to moves page.
#===============================================================================
class PokemonSummary_Scene
  alias styles_drawPageFour drawPageFour
  def drawPageFour
    styles_drawPageFour
    return if $game_switches[Settings::NO_STYLE_MOVES]
    if @sprites["styles_overlay"]
      @sprites["styles_overlay"].bitmap.clear
    end
    overlay = @sprites["overlay"].bitmap
    imagepos = []
    coords = (PluginManager.installed?("BW Summary Screen")) ? [0, 36, 44, 64] : [305, 100, 24, 64]
    yPos = coords[1]
    Pokemon::MAX_MOVES.times do |i|
      move = @pokemon.moves[i]
      if move && move.mastered?
        xpos = coords[0]
        ypos = yPos + coords[2]
        imagepos.push(["Graphics/Plugins/PLA Battle Styles/mastered_icon", xpos, ypos])
      end
      yPos += coords[3]
    end
    pbDrawImagePositions(overlay, imagepos)
  end
  
  alias styles_drawPageFourSelecting drawPageFourSelecting
  def drawPageFourSelecting(move_to_learn)
    styles_drawPageFourSelecting(move_to_learn)
    return if $game_switches[Settings::NO_STYLE_MOVES]
    if !@sprites["styles_overlay"]
      @sprites["styles_overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    else
      @sprites["styles_overlay"].bitmap.clear
    end
    overlay = @sprites["styles_overlay"].bitmap
    imagepos = []
    coords = (PluginManager.installed?("BW Summary Screen")) ? [228, 52, 44, 64] : [305, 100, 24, 64]
    yPos = coords[1]
    yPos -= 76 if move_to_learn
    limit = (move_to_learn) ? Pokemon::MAX_MOVES + 1 : Pokemon::MAX_MOVES
    limit.times do |i|
      move = @pokemon.moves[i]
      if i == Pokemon::MAX_MOVES
        move = move_to_learn
        yPos += 20
      end
      if move && move.mastered?
        xpos = coords[0]
        ypos = yPos + coords[2]
        imagepos.push(["Graphics/Plugins/PLA Battle Styles/mastered_icon", xpos, ypos])
      end
      yPos += coords[3]
    end
    pbDrawImagePositions(overlay, imagepos)
  end
  
  alias styles_drawSelectedMove drawSelectedMove
  def drawSelectedMove(move_to_learn, selected_move)
    if move_to_learn && @pokemon.mastered_moves.include?(move_to_learn.id)
      move_to_learn.mastered = true
    end
    styles_drawSelectedMove(move_to_learn, selected_move)
  end
end