#===============================================================================
# Additions to Battle::Scene to display style info during selection.
#===============================================================================
class Battle::Scene
  alias styles_pbInitSprites pbInitSprites
  def pbInitSprites
    styles_pbInitSprites
    @stylesToggle = false
    @sprites["styleinfo"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["styleinfo"].z = 300
    @sprites["styleinfo"].visible = @styleToggle
    pbSetSmallFont(@sprites["styleinfo"].bitmap)
    @styleOverlay = @sprites["styleinfo"].bitmap
  end
  
  #-----------------------------------------------------------------------------
  # Toggles the style info display.
  #-----------------------------------------------------------------------------
  def pbUpdateStyleWindow(style = 0, info = false)
    @styleOverlay.clear
    xpos = Graphics.width / 2
    ypos = 50
    base = Color.new(232, 232, 232)
    shadow = Color.new(72, 72, 72)
    path = "Graphics/Plugins/PLA Battle Styles/"
    imagePos = [[path + "fade", 0, Graphics.height - 96]]
    textPos = []
    case style
    when 1
      imagePos.push([path + "style_select", 0, Graphics.height - 92, 0, 0, 512, 92])
      if info
        imagePos.push([path + "info_tab", (Graphics.width / 2) - 72, ypos - 38, 0, (style - 1) * 34, 144, 34])
        textPos = [
          [_INTL("Style duration lasts for {1} turn(s).", Settings::STYLE_TURNS),  xpos, ypos,       2, base, shadow],
          [_INTL("Reduces move priority for {1} turn(s).", Settings::STYLE_TURNS), xpos, ypos + 24,  2, base, shadow],
          [_INTL("Boosts move Power/Accuracy/Effects."),                           xpos, ypos + 48,  2, base, shadow],
          [_INTL("Boosts HP recovered from healing moves."),                       xpos, ypos + 72,  2, base, shadow],
          [_INTL("The effects of stat changing moves are increased."),             xpos, ypos + 96,  2, base, shadow],
          [_INTL("Increases damage taken from recoil moves."),                     xpos, ypos + 120, 2, base, shadow],
          [_INTL("User may flinch when struck by foes in Agile Style."),           xpos, ypos + 144, 2, base, shadow],
          [_INTL("Moves cost 1 additional PP per use."),                           xpos, ypos + 168, 2, base, shadow]
        ]
      end
    when 2
      imagePos.push([path + "style_select", 0, Graphics.height - 92, 0, 92, 512, 92])
      if info
        imagePos.push([path + "info_tab", (Graphics.width / 2) - 72, ypos - 38, 0, (style - 1) * 34, 144, 34])
        textPos = [
          [_INTL("Style duration lasts for {1} turn(s).", Settings::STYLE_TURNS),  xpos, ypos,       2, base, shadow],
          [_INTL("Increases move priority for 1 turn."),                           xpos, ypos + 24,  2, base, shadow],
          [_INTL("Reduces move Power."),                                           xpos, ypos + 48,  2, base, shadow],
          [_INTL("Reduces HP recovered from healing moves."),                      xpos, ypos + 72,  2, base, shadow],
          [_INTL("The effects of stat changing moves are reduced."),               xpos, ypos + 96,  2, base, shadow],
          [_INTL("Reduces damage taken from certain recoil moves."),               xpos, ypos + 120, 2, base, shadow],
          [_INTL("User is immune to flinching effects."),                          xpos, ypos + 144, 2, base, shadow],
          [_INTL("Moves cost 1 additional PP per use."),                           xpos, ypos + 168, 2, base, shadow]
        ]
      end
    end
    textPos.length.times { |i| imagePos.push([path + "info_bar", 0, (ypos - 4) + (24 * i), 0, (style - 1) * 24, 512, 24]) }
    pbDrawImagePositions(@styleOverlay, imagePos)
    pbDrawTextPositions(@styleOverlay, textPos)
  end
  
  def pbToggleStyleInfo(style = 0, set = nil, info = false)
    @styleToggle = (set.nil?) ? !@styleToggle : set
    @sprites["styleinfo"].visible = @styleToggle
    pbUpdateStyleWindow(style, info)
  end
  
  #-----------------------------------------------------------------------------
  # Calls the Battle Style animation.
  #-----------------------------------------------------------------------------
  def pbShowBattleStyle(battlers, battler)
    styleAnim = Animation::BattleStyle.new(@sprites, @viewport, battlers, battler)
    loop do
      styleAnim.update
      pbUpdate
      break if styleAnim.animDone?
    end
    styleAnim.dispose
  end
  
  #-----------------------------------------------------------------------------
  # Toggles the use of Battle Styles in the Fight Menu.
  #-----------------------------------------------------------------------------
  def pbFightMenu_BattleStyle(battler, cw)
    pbHidePluginUI
    pbPlayPLASelection
    style_change = false
    apply_style = false
    cw.battleStyle = battler.style_trigger + 1
    pbHideFocusPanel
    show_info = Settings::SHOW_STYLE_INFO_DEFAULT
    pbToggleStyleInfo(battler.style_trigger, true, show_info)
    loop do
      pbUpdate(cw)
      old_style = battler.style_trigger
      #-------------------------------------------------------------------------
      # Strong Style
      if Input.trigger?(Input::LEFT)
        case old_style
        when 0 then battler.style_trigger = 1
        when 2 then battler.style_trigger = 0
        end
        style_change = old_style != battler.style_trigger
        pbPlayCursorSE if style_change
      #-------------------------------------------------------------------------
      # Agile Style
      elsif Input.trigger?(Input::RIGHT)
        case old_style
        when 0 then battler.style_trigger = 2
        when 1 then battler.style_trigger = 0
        end  
        style_change = old_style != battler.style_trigger
        pbPlayCursorSE if style_change
      #-------------------------------------------------------------------------
      # Cancel style choice
      elsif Input.trigger?(Input::BACK)
        @battle.pbSetBattleMechanicUsage(battler.index, "Style", 0)
        battler.toggle_style_moves
        battler.style_trigger = 0
        cw.battleStyle = 0
        pbToggleStyleInfo(0, false)
        pbPlayPLACancel
        break
      #-------------------------------------------------------------------------
      # Toggles style info
      elsif Input.trigger?(Input::SPECIAL)
        if battler.style_trigger > 0
          show_info = !show_info
          pbSEPlay("GUI party switch")
          pbToggleStyleInfo(battler.style_trigger, true, show_info)
        end
      #-------------------------------------------------------------------------
      # Confirm style choice
      elsif Input.trigger?(Input::USE) || Input.trigger?(Input::ACTION)
        if cw.battleStyle > 1
          apply_style = true
          pbPlayPLASelection
        else
          apply_style = true
          battler.toggle_style_moves
          battler.style_trigger = 0
          cw.battleStyle = 0
          pbPlayPLACancel
        end
        if battler.style_trigger > 0
          @battle.pbSetBattleMechanicUsage(battler.index, "Style", -1)
          cw.mode = 1
        else
          @battle.pbSetBattleMechanicUsage(battler.index, "Style", 0)
        end
      end
      #-------------------------------------------------------------------------
      # Apply style changes
      if style_change
        new_style = battler.style_trigger
        cw.battleStyle = new_style + 1
        battler.toggle_style_moves(new_style)
        pbShowWindow(FIGHT_BOX)
        pbSelectBattler(battler.index)
        cw.refreshButtonNames
        pbToggleStyleInfo(new_style, true, show_info)
        style_change = false
      end
      if apply_style
        cw.battleStyle += 2 if cw.battleStyle > 1
        pbToggleStyleInfo(cw.battleStyle, false)
        break
      end
    end
    return DXTriggers::MENU_TRIGGER_BATTLE_STYLE, true
  end
end


#===============================================================================
# Used to get the proper button display during style selection.
#===============================================================================
class Battle::Scene::FightMenu < Battle::Scene::MenuBase
  attr_reader :battleStyle
  
  def battleStyle=(value)
    oldValue = @battleStyle
    @battleStyle = value
    refreshBattleButton if @battleStyle != oldValue
  end
end


#===============================================================================
# Plays the appropriate sound effects during style selection.
#===============================================================================
def pbPlayPLASelection
  if FileTest.audio_exist?("Audio/SE/GUI PLA Select")
    pbSEPlay("GUI PLA Select", 80)
  else
    pbPlayDecisionSE
  end
end

def pbPlayPLACancel
  if FileTest.audio_exist?("Audio/SE/GUI PLA Cancel")
    pbSEPlay("GUI PLA Cancel", 80)
  else
    pbPlayCancelSE
  end
end


#===============================================================================
# Plays the battle style animation.
#===============================================================================
class Battle::Scene::Animation::BattleStyle < Battle::Scene::Animation
  def initialize(sprites, viewport, battlers, battler)
    @battler = battler
    @battlers = battlers
    @style = battler.battle_style
    case @style
    when 1 then @title = "Graphics/Plugins/PLA Battle Styles/title_strong"
    when 2 then @title = "Graphics/Plugins/PLA Battle Styles/title_agile"
    end
    super(sprites, viewport)
  end
  
  def createProcesses
    delay = 0
    xpos = (@battler.opposes?) ? Graphics.width : -Graphics.width
    ypos = (@battler.opposes?) ? 40 : 164
    #---------------------------------------------------------------------------
    # Sets title background.
    #---------------------------------------------------------------------------
    pictureBG = addNewSprite(0, ypos, "Graphics/Plugins/PLA Battle Styles/fade")
    pictureBG.setZ(delay, 999)
    pictureBG.setOpacity(delay, 0)
    #---------------------------------------------------------------------------
    # Sets title.
    #---------------------------------------------------------------------------
    pictureSTYLE = addNewSprite(xpos, ypos, @title)
    pictureSTYLE.setZ(delay, 999)
    #---------------------------------------------------------------------------
    # Fades out battler's databox.
    #---------------------------------------------------------------------------
    @battlers.each do |b|
      next if !b || b.fainted? || b == @battler
      box = addSprite(@sprites["dataBox_#{b.index}"])
      box.moveOpacity(delay, 3, 0)
    end
    delay = 4
    #---------------------------------------------------------------------------
    # Shifts tone of all battle sprites.
    #---------------------------------------------------------------------------
    tone = Tone.new(-60, -60, -60, 150)
    battleBG = addSprite(@sprites["battle_bg"])
    battleBG.moveTone(delay, 4, tone)
    @battlers.each do |b|
	  next if !b || b.fainted?
      battler = addSprite(@sprites["pokemon_#{b.index}"], PictureOrigin::BOTTOM)
      shadow = addSprite(@sprites["shadow_#{b.index}"], PictureOrigin::CENTER)
      box = addSprite(@sprites["dataBox_#{b.index}"])
      battler.moveTone(delay, 4, tone)
      shadow.moveTone(delay, 4, tone)
      box.moveTone(delay, 4, tone)
    end
    delay = battleBG.totalDuration
    #---------------------------------------------------------------------------
    # Fades in title background; slides in title from off screen.
    #---------------------------------------------------------------------------
    pictureBG.moveOpacity(delay, 8, 255)
    pictureSTYLE.moveXY(delay + 2, 6, 0, ypos)
    pictureSTYLE.setSE(delay + 9, "GUI Battle Style", 100)
    delay = pictureSTYLE.totalDuration + 20
    pictureSTYLE.moveXY(delay, 6, -xpos, ypos)
    pictureBG.moveOpacity(delay + 5, 4, 0)
    delay = pictureBG.totalDuration + 1
    #---------------------------------------------------------------------------
    # Returns tone to normal of all battle sprites.
    #---------------------------------------------------------------------------
    tone = Tone.new(0, 0, 0, 0)
    battleBG.moveTone(delay, 6, tone)
    @battlers.each do |b|
	  next if !b || b.fainted?
      battler = addSprite(@sprites["pokemon_#{b.index}"], PictureOrigin::BOTTOM)
      shadow = addSprite(@sprites["shadow_#{b.index}"], PictureOrigin::CENTER)
      box = addSprite(@sprites["dataBox_#{b.index}"])
      battler.moveTone(delay, 6, tone)
      shadow.moveTone(delay, 6, tone)
      box.moveTone(delay, 6, tone)
    end
    #---------------------------------------------------------------------------
    # Fades in battler's databox.
    #---------------------------------------------------------------------------
    @battlers.each do |b|
      next if !b || b.fainted? || b == @battler
      box = addSprite(@sprites["dataBox_#{b.index}"])
      box.moveOpacity(delay + 6, 3, 255)
    end
  end
end