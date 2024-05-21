class PokemonRegionMap_Scene  
  ENCOUNTER_TYPES = {
    :Land => "Grass",
    :LandMorning => "Grass (Morning)",
    :LandDay => "Grass (Day)",
    :LandAfternoon => "Grass (Afternoon)", 
    :LandEvening => "Grass (Evening)",
    :LandNight => "Grass (Night)",
    :PokeRadar => "Poké Radar", 
    :Cave => "Cave",
    :CaveMorning => "Cave (Morning)",
    :CaveDay => "Cave (Day)",
    :CaveAfternoon => "Cave (Afternoon)",
    :CaveEvening => "Cave (Evening)",
    :CaveNight => "Cave (Night)",
    :Water => "Surfing",
    :WaterMorning => "Surfing (Morning)",
    :WaterDay => "Surfing (Day)",
    :WaterAfternoon => "Surfing (Afternoon)",
    :WaterEvening => "Surfing (Evening)",
    :WaterNight => "Surfing (Night)",
    :OldRod => "Fishing (Old Rod)",
    :GoodRod => "Fishing (Good Rod)",
    :SuperRod => "Fishing (Super Rod)",
    :RockSmash => "Rock Smash",
    :HeadbuttLow => "Headbutt (Rare)",
    :HeadbuttHigh => "Headbutt (Common)",
    :BugContest => "Bug Contest"
  }

  def getExtendedPreview
    if !@sprites["previewExtBox"]
      @sprites["previewExtBox"] = IconSprite.new(0, 0, @viewport)
      @sprites["previewExtBox"].x = UI_BORDER_WIDTH
      @sprites["previewExtBox"].y = UI_BORDER_HEIGHT
      @sprites["previewExtBox"].z = 40
      @sprites["previewExtBox"].visible = false
      @sprites["previewExtBox"].setBitmap(findUsableUI("ExtendedPreview/mapExtBox"))
    end 
    if !@sprites["extendedText"]
      @sprites["extendedText"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      pbSetSystemFont(@sprites["extendedText"].bitmap)
      @sprites["extendedText"].visible = false
      @sprites["extendedText"].z = 80
      @sprites["extendedText"].x = UI_BORDER_WIDTH + 6
      @sprites["extendedText"].y = UI_BORDER_HEIGHT
    end
  end 

  def showExtendedPreview
    @sprites["modeName"].visible = false
    @sprites["previewExtBox"].visible = true
    @previewBox.extShow
    updateArrows
    getExtendedInfo
    extendedMain
  end 

  def extendedMain
    loop do
      Graphics.update
      Input.update
      pbUpdate
      @timer += 1 if @timer
      updateButtonInfo
      if Input.trigger?(Input::BACK)
        if @previewBox.isExtShown
          hideExtendedPreview
          showAndUpdateMapInfo
          break
        end
      elsif Input.trigger?(Input::LEFT)
        if @dataIndex > 0 
          @dataIndex -= 1 
        else 
          @dataIndex = @getData.length - 1
        end 
        drawDataMain
      elsif Input.trigger?(Input::RIGHT)
        if @dataIndex < @getData.length - 1
          @dataIndex += 1
        else 
          @dataIndex = 0
        end 
        drawDataMain
      elsif Input.trigger?(ARMSettings::SHOW_EXTENDED_SUB_MENU) && @data[:wildAv]
        @sprites["extendedText"].bitmap.clear
        @extendedBox.subOne
        showExtendedSub
      end 
    end 
  end 

  def getExtendedInfo
    gameMaps = getGameMaps
    @getData = {}
    gameMaps.each do |gameMap|
      percentage = { progress: 0, total: 0 }
      map = GameData::MapMetadata.try_get(gameMap)
      name = ARMSettings::LINK_POI_TO_MAP.key(map.id) || map.name 
      match = name.match(/\\v\[(\d+)\](.*)/)
      if match
        varPart = match[0]
        varNum = match[1]
        varRem = match[2]
        name = "#{$game_variables[varNum.to_i]}#{varRem}"
      end
      next unless $PokemonGlobal.visitedMaps[map.id] || (!ARMSettings::NO_UNVISITED_MAP_INFO && ARMSettings::CAN_VIEW_INFO_UNVISITED_MAPS )
      totalWild, seen, caught, battled, wildText = getWildInfo(map, gameMap)
      district = getDistrictName(map)
      totalTrainers, trainers, defeated, trainerText = getTrainerInfo(map, district)
      totalItems, items, found, itemText = getItemInfo(map, district)
      percentage[:progress] = [seen, caught, battled, defeated, found].each { |value| toNumber(value) }.sum 
      percentage[:total] = [totalWild, totalTrainers, totalItems].sum
      unless percentage[:total] == 0
        progress = "- #{convertIntegerOrFloat(((percentage[:progress].to_f / percentage[:total]) * 100).round(1))}%"
      end 
      @getData[map.id] = { 
        :wild => wildText,
        :wildAv => !wildText.include?("No Encounter Data"),
        :trainers => trainerText,
        :trainerAv => !trainerText.include?("No Trainers to defeat."),
        :items => itemText,
        :itemAv => !itemText.include?("No Items to find."),
        :name => name,
        :progress => progress
      } if !@getData.keys.include?(name)
    end
    @dataIndex = @getData.find_index { |data| data[0] == $game_map.map_id }
    @dataIndex = 0 if @dataIndex.nil?
    drawDataMain
    @sprites["extendedText"].visible = true
  end

  def getGameMaps
    map = nil
    gameMaps = []
    GameData::MapMetadata.each do |gameMap| 
      mapPos = gameMap.town_map_position
      next unless (!mapPos.nil? && pbGetMapLocation(@mapX, @mapY) == gameMap.name) || (gameMap.name.include?($player.name) || gameMap.name.include?("\\v[")) && gameMap.town_map_position == [@region, @mapX, @mapY]
      gameMaps << gameMap.id
      map = gameMap if map.nil?
    end
    mapPosArray = getValidMapPositions(map)
    ARMSettings::LINK_POI_TO_MAP.each do |name, id|
      break if map.nil?
      mapToAdd = GameData::MapMetadata.try_get(id)
      if !mapToAdd.town_map_position.nil? && mapPosArray.include?(mapToAdd.town_map_position) && !gameMaps.include?(id)  
        gameMaps << id
      end 
    end
    return gameMaps
  end

  def getValidMapPositions(map)
    return if map.nil?
    mapSize = map.town_map_size
    mapPosArray = []
    if mapSize && mapSize[0] && mapSize[0] > 0
      sqwidth  = mapSize[0]
      sqheight = (mapSize[1].length.to_f / mapSize[0]).ceil
      mapPos = map.town_map_position
      for i in 0...sqwidth
        for j in 0...sqheight
          mapPosArray << [mapPos[0], mapPos[1] + i, mapPos[2] + j]
        end 
      end 
    else 
      mapPosArray = [map.town_map_position]
    end
    return mapPosArray
  end 

  def getWildInfo(map, gameMap)
    unless GameData::Encounter.get(map.id, $PokemonGlobal.encounter_version).nil?
      seen = $ArckyGlobal.countSeenSpeciesMap(gameMap) || 0
      caught = $ArckyGlobal.countCaughtSpeciesMap(gameMap) || 0 
      battled = $ArckyGlobal.countDefeatedSpeciesMap(gameMap) || 0
      wildText = "Wild Encounters\n#{" "*5}#{seen} seen\n#{" "*5}#{caught} caught\n#{" "*5}#{battled} defeated"
    else 
      seen = caught = battled = 0
      wildText = "No Encounter Data."
    end
    totalWild = @globalCounter[:gameMaps][:wild][map.id] || 0
    totalWild *= 3 if !totalWild.nil?
    return totalWild, seen, caught, battled, wildText
  end 

  def getTrainerInfo(map, district)
    totalTrainers = @globalCounter[:gameMaps][:trainers][map.id]
    trainers = $ArckyGlobal.trainerTracker&.dig(district, :maps, map.id) unless $ArckyGlobal.trainerTracker&.dig(district, :maps)&.empty?
    defeated = trainers.nil? ? 0 : trainers[:defeated]
    if totalTrainers == 0
      trainerText = "No Trainers to defeat." 
    else 
      if defeated == totalTrainers
        trainerText = "Trainers\nHooray! All trainers are defeated!"
      else 
        trainerText = "Trainers\n#{" "*5}#{defeated} out of #{totalTrainers} defeated."
      end 
    end
    return totalTrainers, trainers, defeated, trainerText
  end 

  def getItemInfo(map, district)
    totalItems = @globalCounter[:gameMaps][:items][map.id]
    items = $ArckyGlobal.itemTracker&.dig(district, :maps, map.id) unless $ArckyGlobal.itemTracker&.dig(district, :maps)&.empty?
    found = items.nil? ? 0 : items[:found]
    if totalItems == 0
      itemText = "No Items to find."
    else
      if found == totalItems 
        itemText = "Items\n#{" "*5}Hooray! All Items are found!"
      else
        itemText = "Items\n#{" "*5}#{found} out of #{totalItems} found."
      end 
    end 
    return totalItems, items, found, itemText
  end 

  def toNumber(value)
    return 0 if value.nil?
    value.to_i.to_s == value ? value.to_i : 0
  end 

  def drawDataMain
    @sprites["extendedText"].bitmap.clear
    @lineHeight = 36
    @extWidth = @sprites["previewExtBox"].width - 20
    @extHeight = @sprites["previewExtBox"].height
    @xExt = 8
    @yExt = 8
    if ENGINE20
      @base = colorToRgb16(ARMSettings::DESCRIPTION_TEXT_MAIN)
      @shadow = colorToRgb16(ARMSettings::DESCRIPTION_TEXT_SHADOW)
    else 
      @base = (ARMSettings::DESCRIPTION_TEXT_MAIN).to_rgb15
      @shadow = (ARMSettings::DESCRIPTION_TEXT_SHADOW).to_rgb15
    end 
    @data = @getData.values[@dataIndex]
    @sprites["mapbottom"].mapname = "#{@data[:name]} #{@data[:progress]}" if !@data.nil?
    @sprites["mapbottom"].maplocation = "Page #{@dataIndex + 1}/#{@getData.length}"
    @sprites["mapbottom"].mapdetails  = ""
    text = "<c2=#{@base}#{@shadow}>#{@data[:wild]}</ac>#{@data[:trainers]}\n#{@data[:items]}" if !@data.nil?
    if @data.nil? || [@data[:wild], @data[:trainers], @data[:items]].all? { |value| value.include?("No") }
      text = "<c2=#{@base}#{@shadow}><ac>No Data for this Location</ac>" 
      @yExt = ((@extHeight / 2)) - 8
    end
    chars = getFormattedText(@sprites["extendedText"].bitmap, @xExt, @yExt, @extWidth, @extHeight, text, @lineHeight)
    drawFormattedChars(@sprites["extendedText"].bitmap, chars)
  end 

  def showExtendedSub
    mapID = @getData.keys[@dataIndex]
    @revealAllSeen = ARMSettings::REVEAL_ALL_SEEN_SPECIES_BUTTON.nil?
    getEncounterInfo
    drawEncTable
    extendedSub
  end 
  
  def getEncounterInfo
    @tableData = {}
    mapID = @getData.keys[@dataIndex]
    encounterData = GameData::Encounter.get(mapID, $PokemonGlobal.encounter_version)
    @encounterTables = Marshal.load(Marshal.dump(encounterData.types))
    @encounterTables.each do |type, enc|
      encType = ENCOUNTER_TYPES[type]
      data = getEncChances(enc, encType)
      encounters = enc.map { |enc| enc[1] }.uniq
      @tableData[encType] = data
    end
    @tableIndex = 0
  end 

  def getEncChances(enc, encType)
    data = {}
    total = enc.map { |chance| chance[0] }.sum 
    enc.each do |chance, species, min, max|
      speciesData = GameData::Species.get(species)
      entry = {
        :chance => ((chance.to_f / total) * 100).round(1),
        :level => { :min => min, :max => max || min },
      }
      if data.key?(species)
        data[species][:entries] << entry 
      else 
        data[species] = { :type => getSpeciesTypes(speciesData), :catchRate => "#{convertIntegerOrFloat(((speciesData.catch_rate.to_f / 255) * 100).round(1))}%", :entries => [entry] }
      end 
    end 
    return data
  end 

  def extendedSub
    loop do
      Graphics.update
      Input.update
      pbUpdate
      @timer += 1 if @timer
      updateButtonInfo
      updateSprites
      if Input.trigger?(Input::BACK)
        @sprites["EncounterBoxes"].visible = false
        disposeSprites
        drawDataMain
        @extendedBox.main
        break
      elsif Input.trigger?(Input::LEFT)
        if @tableIndex > 0 
          @tableIndex -= 1 
        else 
          @tableIndex = @tableData.length - 1
        end
        @lastIndex = 0
        disposeSprites
        drawEncTable
      elsif Input.trigger?(Input::RIGHT)
        if @tableIndex < @tableData.length - 1
          @tableIndex += 1
        else 
          @tableIndex = 0
        end
        @lastIndex = 0
        disposeSprites
        drawEncTable
      elsif Input.trigger?(Input::DOWN)
        @textRow += 1 if @textRow < @maxTextRow - 2
        drawEncTableInfo
      elsif Input.trigger?(Input::UP)
        @textRow -= 1 if @textRow > 0
        drawEncTableInfo
      elsif Input.trigger?(ARMSettings::SELECT_SPECIES_BUTTON) && !@activeIndex.empty?
        @extendedBox.subTwo
        getEncCursor
      elsif !ARMSettings::REVEAL_ALL_SEEN_SPECIES_BUTTON.nil? && Input.trigger?(ARMSettings::REVEAL_ALL_SEEN_SPECIES_BUTTON)
        @revealAllSeen = !@revealAllSeen
        if @typeCount != updateTypeCount[0]
          disposeSprites
          drawEncTable
        end 
      end
    end 
  end 

  def drawEncTable
    @pageIndex = 0
    @textRow = 0
    getEncIcons
    drawEncTableInfo
    @sprites["mapbottom"].mapname = "#{@data[:name]} #{@typeProgress}" 
    @sprites["mapbottom"].maplocation = "Page #{@tableIndex + 1}/#{@tableData.length}"
  end

  def getEncIcons
    @boxWidth = @boxHeight = 64
    @spaceX = @spaceY = 12
    # Calculate the max boxes in a row
    screenWidth = @sprites["previewExtBox"].bitmap.width # default = 480
    @rowLength = (screenWidth / (@boxWidth + @spaceX)).floor # using .floor to prevent boxes being too close to the edge without spacing.
    textSpace = @lineHeight * 4 # making sure there's enough space for 4 lines of text.
    screenHeight = @sprites["previewExtBox"].bitmap.height - textSpace
    @yExt = ((textSpace - @spaceY) - @sprites["previewExtBox"].bitmap.height).abs 
    # Calculate the rows and colums needed for the boxes to draw.
    @list = @tableData.values[@tableIndex].map { |key, value| key }
    @rowList = []
    @list.each_slice(@rowLength) { |array| @rowList << array }
    @totalPages = @rowList.length - 1
    @totalPages = 1 if @totalPages <= 0 # making the minimum 1
    @sprites["EncounterBoxes"].bitmap.clear if @sprites["EncounterBoxes"]
    @encSprites = []
    @colLength = [((@list.length).to_f / @rowLength).ceil, screenHeight / (@boxHeight + @spaceY).floor].min
    maxHeight = (@colLength * (@boxHeight + @spaceY)) - @spaceY
    @startY = UI_BORDER_HEIGHT + ((screenHeight - maxHeight) / 2)
    mapID = @getData.keys[@dataIndex]
    @activeIndex = @list.map.with_index do |species, index| 
      speciesData = GameData::Species.get(species)
      seenFormAnyGender(mapID, species, speciesData.form) ? index : nil 
    end.compact
    index = @rowLength * @pageIndex
    @rowList[@pageIndex..(@pageIndex + 1)].each_with_index do |rows, j|
      maxWidth = (rows.length * (@boxWidth + @spaceX)) - @spaceX
      @startX = UI_BORDER_WIDTH + (screenWidth - maxWidth) / 2
      rows.each_with_index do |species, i|
        speciesData = GameData::Species.get(species)
        @encSprites[index] = PokemonSpeciesIconSprite.new(nil, @viewport)
        if !seenFormAnyGender(mapID, species, speciesData.form)
          @encSprites[index].species = nil
        else
          @encSprites[index].species = species 
          @encSprites[index].shiny = false
          @encSprites[index].tone = Tone.new(0,0,0,255) if !caughtFormAnyGender(mapID, species, speciesData.form)
        end
        x = @startX + ((@boxWidth + @spaceX) * i)
        y = @startY + ((@boxHeight + @spaceY) * j)
        @encSprites[index].x = x
        @encSprites[index].y = y
        @encSprites[index].z = 48
        @encSprites[index].visible = true
        drawIconBoxes(x, y)
        index += 1
      end 
    end
  end 

  def getSpeciesTypes(speciesData)
    type = speciesData.types
    typeNames = type.map { |type| GameData::Type.try_get(type).name }
    if typeNames.size > 1
      textType = typeNames.join("/")
    else 
      textType = typeNames.first
    end
    return textType
  end 

  def drawIconBoxes(x, y)
    if !@sprites["EncounterBoxes"]
      @sprites["EncounterBoxes"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites["EncounterBoxes"].z = 42
    end
    pbDrawImagePositions(@sprites["EncounterBoxes"].bitmap, [[findUsableUI("ExtendedPreview/mapEncBox"), x, y]])
    @sprites["EncounterBoxes"].visible = true
  end

  def drawEncTableInfo
    @sprites["extendedText"].bitmap.clear
    @yExt = (((@lineHeight * 4) - @spaceY) - @sprites["previewExtBox"].bitmap.height).abs 
    @typeCount, counter = updateTypeCount
    @typeProgress = "- #{convertIntegerOrFloat(((counter.to_f / (@list.length * 3)) * 100).round(1))}%"
    typeWidths = []
    getTypes = []
    extra = @sprites["extendedText"].bitmap.text_size(" -  ").width
    @typeCount.each do |type, count|
      txt = "#{count} #{type}"
      getTypes << txt
      typeWidths << @sprites["extendedText"].bitmap.text_size(txt).width
    end
    getTypes = textToLines(typeWidths, getTypes, extra)
    typeString = getTypes.join(" - ")
    count = getTypes.count { |el| el.include?("\n") } 
    @maxTextRow = count - 2 > 0 ? count : 0
    if @maxTextRow > 0
      parts = typeString.split("\n")
      result = parts[@textRow...@textRow + @maxTextRow] 
      typeString = result.join("\n")
    end 
    if typeString == ""
      typeString = "<ac>No Information Available.</ac>" 
      @yExt += (((@sprites["previewExtBox"].bitmap.height - @yExt) / 2) - 18)
    end 
    @sprites["mapbottom"].mapdetails  = @tableData.keys[@tableIndex] 
    text = "<c2=#{@base}#{@shadow}>#{typeString}"
    chars = getFormattedText(@sprites["extendedText"].bitmap, @xExt, @yExt, @extWidth, @extHeight, text, 36)
    drawFormattedChars(@sprites["extendedText"].bitmap, chars)
  end 

  def updateTypeCount(revealAllSeen = nil)
    typeCount = {}
    counter = 0
    mapID = @getData.keys[@dataIndex]
    @list.each do |species|
      count = 0
      speciesData = GameData::Species.get(species)
      count += 1 if seenFormAnyGender(mapID, species, speciesData.form, revealAllSeen)
      count += 1 if caughtFormAnyGender(mapID, species, speciesData.form)
      count += 1 if defeatedFormAnyGender(mapID, species, speciesData.form)
      if count != 0
        textType = getSpeciesTypes(speciesData) 
        counter += count
        typeCount[textType] ||= 0
        typeCount[textType] += 1
      end 
    end 
    return typeCount, counter
  end 

  def textToLines(widths, text, extra)
    currSum = 0
    newLines = []
    widths.each_with_index do |width, index|
      currSum += width 
      currSum += extra if index != widths.length - 1
      if currSum > @extWidth
        newLines << index
        currSum = width
      end 
    end 
    newLines.each do |index|
      text[index] = "\n#{text[index]}"
    end
    return text
  end 

  def seenFormAnyGender(mapID, species, form, revealAllSeen = nil)
    revealAllSeen = @revealAllSeen if revealAllSeen.nil?
    seen = false 
    if revealAllSeen
      if $ArckyGlobal.countSeenSpecies(species, 0, form) > 0 || $ArckyGlobal.countSeenSpecies(species, 1, form) > 0
        seen = true 
      end 
    else 
      if $ArckyGlobal.countSeenSpeciesMap(mapID, species, 0, form) > 0 || $ArckyGlobal.countSeenSpeciesMap(mapID, species, 1, form) > 0
        seen = true 
      end 
    end 
    return seen 
  end

  def caughtFormAnyGender(mapID, species, form)
    caught = false 
    if $ArckyGlobal.countCaughtSpecies(species, 0, form) > 0 || $ArckyGlobal.countCaughtSpecies(species, 1, form) > 0
      caught = true 
    end 
    return caught
  end 

  def defeatedFormAnyGender(mapID, species, form)
    defeated = false
    if $ArckyGlobal.countDefeatedSpeciesMap(mapID, species, 0, form) > 0 || $ArckyGlobal.countDefeatedSpeciesMap(mapID, species, 1, form) > 0
      defeated = true 
    end 
    return defeated 
  end 

  def getEncCursor
    if !@sprites["ExtCursor"]
      @sprites["ExtCursor"] = IconSprite.new(0, 0, @viewport)
      @sprites["ExtCursor"].setBitmap(findUsableUI("ExtendedPreview/mapEncCursor"))
      @sprites["ExtCursor"].z = 50
    end
    @sprites["ExtCursor"].visible = true 
    updateEncCursor(@lastIndex)
    extendedEnc
  end 

  def updateEncCursor(index)
    index = @activeIndex.first if index.nil?
    @sprites["ExtCursor"].x = @encSprites[index].x - 2
    @sprites["ExtCursor"].y = @encSprites[index].y - 2
  end 

  def updateSpeciesInfo(index = 0, pageInfo = 0)
    @sprites["extendedText"].bitmap.clear
    @yExt = (((@lineHeight * 4) - @spaceY) - @sprites["previewExtBox"].bitmap.height).abs 
    unless @encSprites[index].species.nil? 
      species = @list[index]
      speciesData = GameData::Species.get(species)
      mapID = @getData.keys[@dataIndex]
      formName = speciesData.real_form_name
      entryData = @tableData.values[@tableIndex][species]
      @sprites["mapbottom"].mapname = formName.nil? ? "#{speciesData.real_name}" : formName.include?(speciesData.real_name) ? formName : "#{formName} #{speciesData.real_name}"
      seen = $ArckyGlobal.countSeenSpeciesMap(mapID, species, nil, speciesData.form)
      totalSeen = $ArckyGlobal.countSeenSpecies(species, nil, speciesData.form)
      totalSeen = totalSeen != seen ? "- #{totalSeen} total" : ""
      caught = $ArckyGlobal.countCaughtSpeciesMap(mapID, species, nil, speciesData.form)
      totalCaught = $ArckyGlobal.countCaughtSpecies(species, nil, speciesData.form)
      totalCaught = totalCaught != caught ? "- #{totalCaught} total" : ""
      defeated = $ArckyGlobal.countDefeatedSpeciesMap(mapID, species, nil, speciesData.form)
      totalDefeated = $ArckyGlobal.countDefeatedSpecies(species, nil, speciesData.form)
      totalDefeated = totalDefeated != defeated ? "- #{totalDefeated} total" : ""
      entryData = @tableData.values[@tableIndex][species]
      dataText = "Type: #{entryData[:type]}#{" "*11}Catch Rate: #{entryData[:catchRate]}\nEncounter Rate:\n"
      array = []
      widths = []
      extra = @sprites["extendedText"].bitmap.text_size(' - ').width
      entryData[:entries].each do |data|
        levelRange = data[:level][:min] == data[:level][:max] ? "#{data[:level][:min]}" : "#{data[:level][:min]} - #{data[:level][:max]}"
        txt = "#{convertIntegerOrFloat(data[:chance])}% (lv. #{levelRange})"
        array << txt
        widths << @sprites["extendedText"].bitmap.text_size(txt).width
      end
      array = textToLines(widths, array, extra)
      dataText += array.join(' - ')
      if pageInfo == 0
        text = dataText
      elsif pageInfo == 1
        text = "Counters:\n#{seen.to_s} seen #{totalSeen}\n#{caught.to_s} caught #{totalCaught}\n#{defeated.to_s} defeated #{totalDefeated}"
      end 
    else 
      @sprites["mapbottom"].mapname = "#{@data[:name]} #{@typeProgress}"
      text = "<ac>No Data</ac>"
      @yExt += (((@sprites["previewExtBox"].bitmap.height - @yExt) / 2) - 18)
    end 
    extHeight = @sprites["previewExtBox"].height
    text = "<c2=#{@base}#{@shadow}>#{text}"
    chars = getFormattedText(@sprites["extendedText"].bitmap, @xExt, @yExt, @extWidth, @extHeight, text, @lineHeight)
    drawFormattedChars(@sprites["extendedText"].bitmap, chars)
  end

  def extendedEnc
    index = @lastIndex || @activeIndex.first
    pageInfo = 0
    disposeSprites
    getEncIcons
    loop do
      Graphics.update
      Input.update
      pbUpdate
      @timer += 1 if @timer
      minPageInd = @pageIndex != 0 ? @rowList[0..@pageIndex - 1].map { |row| row.length }.sum : 0 
      maxPageInd = @rowList[0..(@pageIndex + 1)].map { |row| row.length }.sum - 1
      updateButtonInfo
      updateSprites
      if Input.trigger?(Input::BACK)
        @lastIndex = index
        @sprites["ExtCursor"].visible = false
        @sprites["mapbottom"].mapname = "#{@data[:name]} #{@typeProgress}"
        @sprites["mapbottom"].maplocation = "Page #{@tableIndex + 1}/#{@tableData.length}"
        @extendedBox.subOne
        drawEncTableInfo
        break 
      elsif Input.trigger?(Input::RIGHT)
        index += 1
        if index > maxPageInd
          if maxPageInd < @list.length - 1            
            @pageIndex += 1
          else 
            @pageIndex = 0
            index = 0
          end 
        end 
        disposeSprites
        getEncIcons
      elsif Input.trigger?(Input::LEFT)
        index -= 1
        if index < minPageInd
          if minPageInd > 0
            @pageIndex -= 1
          else
            @pageIndex = @totalPages - 1
            index = @list.length - 1
          end 
        end 
        disposeSprites
        getEncIcons
      elsif Input.trigger?(Input::UP)
        if index - @rowLength >= 0
          index -= @rowLength
          if index < minPageInd
            @pageIndex -= 1
          end 
        else 
          index += @rowLength * @totalPages
          if index > @list.length - 1
            index = @list.length - 1
          end 
          @pageIndex = @totalPages - 1
        end 
        disposeSprites
        getEncIcons
      elsif Input.trigger?(Input::DOWN)
        if index + @rowLength <= @list.length - 1
          index += @rowLength
          if index > maxPageInd
            @pageIndex += 1
          end 
        else 
          index -= @rowLength * @totalPages
          if index < 0
            index = @list.length - 1
            @pageIndex = @totalPages - 1
          else 
            @pageIndex = 0
          end 
        end 
        disposeSprites
        getEncIcons
      elsif Input.trigger?(Input::JUMPUP) && !@activeIndex.empty?
        index = @activeIndex.reverse.find { |value| value < index }
        index ||= @activeIndex.last
        if index < minPageInd
          if minPageInd > 0
            if @pageIndex > 0 
              @pageIndex -= 1
            else 
              @pageIndex = @totalPages
            end
          end 
        elsif index > maxPageInd
          @pageIndex = (index / @rowLength) - 1
        end 
        disposeSprites
        getEncIcons
      elsif Input.trigger?(Input::JUMPDOWN) && !@activeIndex.empty?
        index = @activeIndex.find { |value| value > index }
        index ||= @activeIndex.first
        if index > maxPageInd
          if maxPageInd < @list.length - 1   
            if @pageIndex < @totalPages        
              @pageIndex += 1
            else 
              @pageIndex = 0
            end 
          end 
        elsif index < minPageInd
          @pageIndex = (index / @rowLength)
        end 
        disposeSprites
        getEncIcons
      elsif Input.trigger?(ARMSettings::SELECT_SPECIES_BUTTON)
        pageInfo += 1
        if pageInfo > 1
          pageInfo = 0
        end 
      end
      updateSpeciesInfo(index, pageInfo)
      updateEncCursor(index)
      @extIndex = index
      @sprites["mapbottom"].maplocation = "Species #{index + 1}/#{@list.length}"
    end 
  end 

  def updateSprites
    @encSprites.each { |s| s.update if !s.nil? }
    Graphics.update
  end

  def disposeSprites
    @encSprites.each { |s| s.dispose if !s.nil? }
  end 

  def hideExtendedPreview
    @sprites["previewExtBox"].visible = false 
    @sprites["modeName"].visible = true
    @sprites["extendedText"].visible = false
    @previewBox.extHide
    updateArrows
  end 
end 

class ExtendedState
  def initialize
    @state = :main
  end

  def page
    @state 
  end 

  def main 
    @state = :main
  end 

  def subOne 
    @state = :subOne
  end 

  def subTwo
    @state = :subTwo 
  end 

  def isMain
    return @state == :main
  end 

  def isSubOne
    return @state == :subOne
  end 

  def isSubTwo
    return @state == :subTwo
  end 
end 