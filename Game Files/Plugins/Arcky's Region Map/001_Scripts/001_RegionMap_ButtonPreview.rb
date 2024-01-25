class PokemonRegionMap_Scene  
  def showButtonPreview
    if !@sprites["buttonPreview"]
      @sprites["buttonPreview"] = IconSprite.new(0, 0, @viewport)
      @sprites["buttonPreview"].setBitmap(findUsableUI("mapButtonBox"))
      @sprites["buttonPreview"].z = 24
      @sprites["buttonPreview"].visible = !@flyMap && !@wallmap
    end 
  end

  def convertButtonToString(button)
    controlPanel = $PokemonSystem.respond_to?(:game_controls)
    case button 
    when 11
      buttonName = controlPanel ? _INTL("Menu") : _INTL("ACTION")
    when 12
      buttonName = controlPanel ? _INTL("Cancel") : _INTL("BACK")
    when 13 
      buttonName = controlPanel ? _INTL("Action") : _INTL("USE")
    when 14 
      buttonName = controlPanel ? _INTL("Scroll Up") : _INTL("JUMPUP")
    when 15
      buttonName = controlPanel ? _INTL("Scroll Down") : _INTL("JUMPDOWN")
    when 16
      buttonName = controlPanel ? _INTL("Ready Menu") : _INTL("SPECIAL")
    when 17
      buttonName = "AUX1" #Unused 
    when 18
      buttonName = "AUX2" #Unused
    end 
    if controlPanel
      buttonName = $PokemonSystem.game_controls.find{|c| c.control_action==buttonName}.key_name 
      buttonName = makeButtonNameShorter(buttonName)
    end 
    return buttonName
  end 

  def makeButtonNameShorter(button)
    case button 
    when "Backspace"
      button = _INTL("Return")
    when "Caps Lock"
      button = _INTL("Caps")
    when "Page Up"
      button = _INTL("pg Up")
    when "Page Down"
      button = _INTL("pg Dn")
    when "Print Screen"
      button = _INTL("prt Scr")
    when "Numpad 0"
      button = _INTL("Num 0")
    when "Numpad 1"
      button = _INTL("Num 1")
    when "Numpad 2"
      button = _INTL("Num 2")
    when "Numpad 3"
      button = _INTL("Num 3")
    when "Numpad 4"
      button = _INTL("Num 4")
    when "Numpad 5"
      button = _INTL("Num 5")
    when "Numpad 6"
      button = _INTL("Num 6")
    when "Numpad 7"
      button = _INTL("Num 7")
    when "Numpad 8"
      button = _INTL("Num 8")
    when "Numpad 9"
      button = _INTL("Num 9")
    when "multiply"
      button = _INTL("Multi")
    when "Separator"
      button = _INTL("Sep")
    when "Subtract"
      button = _INTL("Sub")
    when "Decimal"
      button = _INTL("Dec")
    when "Divide"
      button = _INTL("Div")
    when "Num Lock"
      button = _INTL("Num")
    when "Scroll Lock"
      button = _INTL("Scroll")
    end 
    return button 
  end 

  def updateButtonInfo(name = "", replaceName = "")
    return if @wallmap || @flyMap
    @timer = 0 if !@timer
    frames = ARMSettings::BUTTON_PREVIEW_TIME_CHANGE * Graphics.frame_rate
    width = @previewShow && @mode == 2 && BOX_TOP_LEFT ? (Graphics.width - @sprites["previewBox"].width) : @sprites["buttonPreview"].width 
    textPos = getTextPosition
    getAvailableActions(name, replaceName)
    avActions = @mapActions.select { |_, action| action[:condition]}.values
    avActions.sort_by! { |action| action[:priority] ? 0 : 1 }
    if avActions != @prevAvActions
      @prevAvActions = avActions
      @timer = 0
    end
    @indActions = (@timer / frames) % avActions.length
    if avActions.any?
      selActions = avActions[@indActions % avActions.length]
      button = pbGetMessageFromHash(SCRIPTTEXTS, convertButtonToString(selActions[:button]))
      text = "#{button}: #{selActions[:text]}"
      @sprites["buttonName"].bitmap.clear
      pbDrawTextPositions(
      @sprites["buttonName"].bitmap,
      [[text, (textPos[0] + (width / 2)) + ARMSettings::BUTTON_BOX_TEXT_OFFSET_X, (textPos[1] + 14) + ARMSettings::BUTTON_BOX_TEXT_OFFSET_Y, 2, ARMSettings::BUTTON_BOX_TEXT_MAIN, ARMSettings::BUTTON_BOX_TEXT_SHADOW]]
      )
      @sprites["buttonName"].visible = !@flyMap && !@wallmap
      @sprites["buttonName"].z = 25
    end 
  end 

  def getAvailableActions(name = "", replaceName = "")
    getAvailableRegions if !@avRegions
    @mapActions = {
      :ChangeMode => {
        condition: @modeCount >= 2,
        text: _INTL("Change Mode"),
        button: ARMSettings::CHANGE_MODE_BUTTON
      },
      :ChangeRegion => {
        condition: @avRegions.length >= 2 && !@previewShow,
        text: _INTL("Change Region"),
        button: ARMSettings::CHANGE_REGION_BUTTON
      },
      :ViewInfo => {
        condition: @mode == 0 && !@previewShow && name != "" && (name != replaceName || ARMSettings::CAN_VIEW_INFO_UNVISITED_MAPS) || @lineCount == 0,
        text: _INTL("View Info"),
        button: ARMSettings::SHOW_LOCATION_BUTTON,
        priority: true
      },
      :HideInfo => {
        condition: @mode == 0 && @previewShow && @lineCount != 0 && @curLocName != "",
        text: _INTL("Hide Info"),
        button: Input::BACK
      },
      :QuickFly => {
        condition: @mode == 1 && ARMSettings::CAN_QUICK_FLY && (ARMSettings::SWITCH_TO_ENABLE_QUICK_FLY.nil? || $game_switches[ARMSettings::SWITCH_TO_ENABLE_QUICK_FLY]),
        text: _INTL("Quick Fly"),
        button: ARMSettings::QUICK_FLY_BUTTON,
        priority: true
      },
      :ShowQuest => {
        condition: @mode == 2 && @questNames.is_a?(Array) && @questNames.length < 2 && !@previewShow,
        text: _INTL("View Quest"),
        button: ARMSettings::SHOW_QUEST_BUTTON,
        priority: true 
      },
      :HideQuest => {
        condition: @mode == 2 && @previewShow,
        text: _INTL("Hide Quest"),
        button: Input::BACK
      },
      :ShowQuests => {
        condition: @mode == 2 && @questNames.is_a?(Array) && @questNames.length >= 2 && !@previewShow,
        text: _INTL("View Quests"),
        button: ARMSettings::SHOW_QUEST_BUTTON,
        priority: true
      },
      :ChangeQuest => {
        condition: @mode == 2 && @questNames.is_a?(Array) && @questNames.length >= 2 && @previewShow,
        text: _INTL("Change Quest"),
        button: ARMSettings::SHOW_QUEST_BUTTON
      },
      :Quit => {
        condition: !@previewShow,
        text: _INTL("Close Map"),
        button: Input::BACK
      }
    }
  end 
end 