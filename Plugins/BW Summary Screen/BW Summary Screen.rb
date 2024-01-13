  #===============================================================================
  #
  #===============================================================================
  class MoveSelectionSprite < Sprite
    attr_reader :preselected
    attr_reader :index
    def initialize(viewport = nil, fifthmove = false)
      super(viewport)
      # Sets the Move Selection Cursor
      if SUMMARY_B2W2_STYLE
        @movesel = AnimatedBitmap.new("Graphics/Pictures/UI/SummaryUI/cursor_move_B2W2")
      else
        @movesel = AnimatedBitmap.new("Graphics/Pictures/UI/SummaryUI/cursor_move")
      end
      @frame = 0
      @index = 0
      @fifthmove = fifthmove
      @preselected = false
      @updating = false
      refresh
    end

    def dispose
        @movesel.dispose
        super
      end
      def index=(value)
        @index = value
        refresh
      end
      def preselected=(value)
        @preselected = value
        refresh
      end
      #mainX2 = 528 + 20
      #yPos = 32
    def refresh
      w = @movesel.width
      h = @movesel.height / 2
      self.x =  512 #+ 20
      # Changed the position of the Move Select cursor
      self.y = 26 + (self.index * 64).round
      self.y -= 76 if @fifthmove
      self.y += 20 if @fifthmove && self.index == Pokemon::MAX_MOVES   # Add a gap
      self.bitmap = @movesel.bitmap
      if self.preselected
        self.src_rect.set(0, h, w, h)
      else
        self.src_rect.set(0 ,0, w, h)
      end
    end

    def update
      @updating = true
      super
      @movesel.update
      @updating = false
      refresh
    end
  end

  #===============================================================================
  #
  #===============================================================================
  class RibbonSelectionSprite < MoveSelectionSprite
    def initialize(viewport = nil)
      super(viewport)
      # Sets the Ribbon Selection Cursor
      @movesel = AnimatedBitmap.new("Graphics/Pictures/UI/SummaryUI/cursor_ribbon_B2W2")

      @frame = 0
      @index = 0
      @preselected = false
      @updating = false
      @spriteVisible = true
      refresh
    end

    def visible=(value)
        super
        @spriteVisible = value if !@updating
      end

    def refresh
      w = @movesel.width
      h = @movesel.height / 2
   # Changed the position of the Ribbon Select cursor
      self.x = 0 + (self.index % 4) * 68
      self.y = 72 + ((self.index/4).floor * 68)
      self.bitmap = @movesel.bitmap
      if self.preselected
        self.src_rect.set(0, h, w, h)
      else
        self.src_rect.set(0, 0, w, h)
      end
    end

    def update
      @updating = true
      super
      self.visible = @spriteVisible && @index >= 0 && @index < 12
      @movesel.update
      @updating = false
      refresh
    end
  end

  #===============================================================================
  #
  #===============================================================================
  class PokemonSummary_Scene
    MARK_WIDTH  = 16
    MARK_HEIGHT = 16

    base   = Color.new(255, 255, 255)
    shadow = Color.new(165, 165, 173)
    base1   = Color.new(148, 15, 255)
    shadow1 = Color.new(99, 0, 180)
    base2 = Color.new(120, 184, 232)
    shadow2 = Color.new(0, 112, 248)
    base3 = Color.new(248, 168, 184)
    shadow3 = Color.new(232, 32, 16)

    def pbUpdate
      pbUpdateSpriteHash(@sprites)
      # Sets the Moving Background
      if @sprites["background"]
        @sprites["background"].ox-= -1
        @sprites["background"].oy-= -1
      end
    end
    def pbStartScene(party, partyindex, inbattle = false)
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      @party      = party
      @partyindex = partyindex
      @pokemon    = @party[@partyindex]
      @inbattle   = inbattle
      @page = 1
      @typebitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      @markingbitmap = AnimatedBitmap.new("Graphics/Pictures/UI/SummaryUI/markings")
      @sprites = {}
      # Sets the Summary Background
      # Background glitch fixed by Shashu-Greninja
      @sprites["bg_overlay"] = IconSprite.new(0, 0, @viewport)
      addBackgroundPlane(@sprites, "background", $bgPath, @viewport)
      # Sets the Moving Background Loop
      @sprites["background"].ox+= 6
      @sprites["background"].oy-= 36
      # Sets the Summary Overlays
      @sprites["menuoverlay"] = IconSprite.new(0, 0, @viewport)
      @sprites["pokemon"] = PokemonSprite.new(@viewport)
      @sprites["pokemon"].setOffset(PictureOrigin::CENTER)
      # Changed the position of Pokémon Battler
      @sprites["pokemon"].x = 384 #@sprites["pokemon"].x = 414
      @sprites["pokemon"].y = 216 #@sprites["pokemon"].y = 208
      @sprites["pokemon"].setPokemonBitmap(@pokemon)
      @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
      @sprites["pokeicon"].setOffset(PictureOrigin::CENTER)
      # Changed the position of Pokémon Icon
      @sprites["pokeicon"].x       = 224 #@sprites["pokeicon"].x       = 46
      @sprites["pokeicon"].y       = 32 + 10 #@sprites["pokeicon"].y       = 92
      @sprites["pokeicon"].visible = false
      # Changed the position of the held Item icon
      @sprites["itemicon"] = ItemIconSprite.new(224, 32, @pokemon.item_id, @viewport)
      @sprites["itemicon"].blankzero = true
      @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites["overlay2"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites["overlay3"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      pbSetSystemFont(@sprites["overlay"].bitmap)
      pbSetSystemFont(@sprites["overlay2"].bitmap)
      pbSetSmallFont(@sprites["overlay2"].bitmap)
      pbSetSystemFont(@sprites["overlay3"].bitmap)
      pbSetSmallFont(@sprites["overlay3"].bitmap)
      @sprites["movepresel"] = MoveSelectionSprite.new(@viewport)
      @sprites["movepresel"].visible     = false
      @sprites["movepresel"].preselected = true
      @sprites["movesel"] = MoveSelectionSprite.new(@viewport)
      @sprites["movesel"].visible = false
      # Draws the Ribbon Selection Cursor
      @sprites["ribbonpresel"] = RibbonSelectionSprite.new(@viewport)
      @sprites["ribbonpresel"].visible     = false
      @sprites["ribbonpresel"].preselected = true
      @sprites["ribbonsel"] = RibbonSelectionSprite.new(@viewport)
      @sprites["ribbonsel"].visible = false
      # Sets the Up Arrow in Ribbons Page
      @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8, 28, 40, 2, @viewport)
      # Draws the Up Arrow in Ribbons Page
      @sprites["uparrow"].x = 262
      @sprites["uparrow"].y = 56
      @sprites["uparrow"].play
      @sprites["uparrow"].visible = false
      # Sets the Down Arrow in Ribbons Page
      @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8, 28, 40, 2, @viewport)
      # Draws the Up Arrow in Ribbons Page
      @sprites["downarrow"].x = 262
      @sprites["downarrow"].y = 260
      @sprites["downarrow"].play
      @sprites["downarrow"].visible = false
      # Sets the Marking Overlay
      @sprites["markingbg"] = IconSprite.new(260, 88, @viewport)
      @sprites["markingbg"].setBitmap("Graphics/Pictures/UI/SummaryUI/overlay_marking")
      @sprites["markingbg"].visible = false
      @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites["markingoverlay"].visible = false
      pbSetSystemFont(@sprites["markingoverlay"].bitmap)
      # Sets the Marking Selector
      @sprites["markingsel"] = IconSprite.new(0, 0, @viewport)
      if SUMMARY_B2W2_STYLE
        @sprites["markingsel"].setBitmap("Graphics/Pictures/UI/SummaryUI/cursor_marking_B2W2")
      else
        @sprites["markingsel"].setBitmap("Graphics/Pictures/UI/SummaryUI/cursor_marking")
      end
      @sprites["markingsel"].src_rect.height = @sprites["markingsel"].bitmap.height / 2
      @sprites["markingsel"].visible = false
      @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
      @sprites["messagebox"].viewport       = @viewport
      @sprites["messagebox"].visible        = false
      @sprites["messagebox"].letterbyletter = true
      pbBottomLeftLines(@sprites["messagebox"], 2)
      @nationalDexList = [:NONE]
      GameData::Species.each_species { |s| @nationalDexList.push(s.species) }
      drawPage(@page)
      pbFadeInAndShow(@sprites) { pbUpdate }
    end

    def pbStartForgetScene(party, partyindex, move_to_learn)
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      @party      = party
      @partyindex = partyindex
      @pokemon    = @party[@partyindex]
      @page = 4
      @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      @sprites = {}
      # Sets the Summary Background
      # Background glitch fixed by Shashu-Greninja
      @sprites["bg_overlay"] = IconSprite.new(0, 0, @viewport)
      addBackgroundPlane(@sprites, "background", $bgPath, @viewport)
      # Sets the Moving Background Loop
      @sprites["background"].ox+= 6
      @sprites["background"].oy-= 36
      # Sets the Summary Overlays
      @sprites["menuoverlay"] = IconSprite.new(0, 0, @viewport)
      @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      pbSetSystemFont(@sprites["overlay"].bitmap)
      @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
      @sprites["pokeicon"].setOffset(PictureOrigin:: CENTER)
      # Sets the Pokémon Icon on the scene
      @sprites["pokeicon"].x       = 46
      @sprites["pokeicon"].y       = 92
      @sprites["movesel"] = MoveSelectionSprite.new(@viewport, !move_to_learn.nil?)
      @sprites["movesel"].visible = false
      @sprites["movesel"].visible = true
      @sprites["movesel"].index   = 0
      new_move = (move_to_learn) ? Pokemon::Move.new(move_to_learn) : nil
      drawSelectedMove(new_move, @pokemon.moves[0])
      pbFadeInAndShow(@sprites)
    end

    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        @typebitmap.dispose
        @markingbitmap&.dispose
        @viewport.dispose
      end
      def pbDisplay(text)
        @sprites["messagebox"].text = text
        @sprites["messagebox"].visible = true
        pbPlayDecisionSE
        loop do
          Graphics.update
          Input.update
          pbUpdate
          if @sprites["messagebox"].busy?
            if Input.trigger?(Input::USE)
              pbPlayDecisionSE if @sprites["messagebox"].pausing?
              @sprites["messagebox"].resume
            end
          elsif Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
            break
          end
        end
        @sprites["messagebox"].visible = false
      end
      def pbConfirm(text)
        ret = -1
        @sprites["messagebox"].text    = text
        @sprites["messagebox"].visible = true
        using(cmdwindow = Window_CommandPokemon.new([_INTL("Yes"), _INTL("No")])) {
          cmdwindow.z       = @viewport.z + 1
          cmdwindow.visible = false
          pbBottomRight(cmdwindow)
          cmdwindow.y -= @sprites["messagebox"].height
          loop do
            Graphics.update
            Input.update
            cmdwindow.visible = true if !@sprites["messagebox"].busy?
            cmdwindow.update
            pbUpdate
            if !@sprites["messagebox"].busy?
              if Input.trigger?(Input::BACK)
                ret = false
                break
              elsif Input.trigger?(Input::USE) && @sprites["messagebox"].resume
                ret = (cmdwindow.index == 0)
                break
              end
            end
          end
        }
        @sprites["messagebox"].visible = false
        return ret
      end
      def pbShowCommands(commands, index = 0)
        ret = -1
        using(cmdwindow = Window_CommandPokemon.new(commands)) {
          cmdwindow.z = @viewport.z + 1
          cmdwindow.index = index
          pbBottomRight(cmdwindow)
          loop do
            Graphics.update
            Input.update
            cmdwindow.update
            pbUpdate
            if Input.trigger?(Input::BACK)
              pbPlayCancelSE
              ret = -1
              break
            elsif Input.trigger?(Input::USE)
              pbPlayDecisionSE
              ret = cmdwindow.index
              break
            end
          end
        }
        return ret
      end
      def drawMarkings(bitmap, x, y)
        mark_variants = @markingbitmap.bitmap.height / MARK_HEIGHT
        markings = @pokemon.markings
        markrect = Rect.new(0, 0, MARK_WIDTH, MARK_HEIGHT)
        (@markingbitmap.bitmap.width / MARK_WIDTH).times do |i|
          markrect.x = i * MARK_WIDTH
          markrect.y = [(markings[i] || 0), mark_variants - 1].min * MARK_HEIGHT
          bitmap.blt(x + (i * MARK_WIDTH), y, @markingbitmap.bitmap, markrect)
        end
      end

#=============================================================================

    def drawPage(page)
      if @pokemon.egg?
        drawPageOneEgg
        return
      end
      @sprites["itemicon"].item = @pokemon.item_id
      overlay = @sprites["overlay"].bitmap
      overlay.clear
      # Changes the color of the text, to the one used in BW
      base   = Color.new(255, 255, 255)
      shadow = Color.new(165, 165, 173)
      base1   = Color.new(148, 15, 255)
      shadow1 = Color.new(99, 0, 180)
      base2 = Color.new(120, 184, 232)
      shadow2 = Color.new(0, 112, 248)
      base3 = Color.new(248, 168, 184)
      shadow3 = Color.new(232, 32, 16)
      # Set background image
      @sprites["menuoverlay"].setBitmap("Graphics/Pictures/UI/SummaryUI/bg_page_#{page}")
      imagepos = []
      # Show the Poké Ball containing the Pokémon
      #ballimage = sprintf("Graphics/Pictures/UI/SummaryUI/icon_ball_%s", @pokemon.poke_ball)
      #imagepos.push([ballimage, 250-32, 4, 2])
      #AAAAA
      # Show status/fainted/Pokérus infected icon
      status = -1
      if @pokemon.fainted?
        status = GameData::Status.count - 0
      elsif @pokemon.status != :NONE
        status = GameData::Status.get(@pokemon.status).icon_position + 1
      elsif @pokemon.pokerusStage == 1
        status = GameData::Status.count + 1
      end
      status -= 1
      if status >= 0
        imagepos.push(["Graphics/Pictures/statuses", 8, 66, 0, 16 * status, 46, 16])
      end
      # Show Pokérus cured icon
      if @pokemon.pokerusStage == 2
        if SUMMARY_B2W2_STYLE
          imagepos.push([sprintf("Graphics/Pictures/UI/SummaryUI/icon_pokerus"), 376, 303])
        else
          imagepos.push([sprintf("Graphics/Pictures/UI/SummaryUI/icon_pokerus"), 376, 305])
        end
      end
      # Show shininess star
      imagepos.push([sprintf("Graphics/Pictures/shiny"), 350, 303]) if @pokemon.shiny?
      # Draw all images
      pbDrawImagePositions(overlay,imagepos)
      # Draw the Pokémon's markings
      textpos = []
      pagename = [_INTL("#{@pokemon.name}'s Info"),
      _INTL("#{@pokemon.owner.name}'s Memo"),
      _INTL("#{@pokemon.name}'s Skills"),
      _INTL("#{@pokemon.name}'s Moves"),
      _INTL("#{@pokemon.name}'s Ribbons")][page - 1]
    
      textpos.push([pagename, Graphics.width / 2, 10, 2, base, shadow, true])
      textpos.push(["Name: " + @pokemon.name, 8, 8, 0, base1, shadow1, true])
      textpos.push(["Level: " + @pokemon.level.to_s, 8, 36, 0, base2, shadow2, true])
      # Write the held item's name
      if @pokemon.hasItem?
        textpos.push(["Item: " + @pokemon.item.name.to_s, 8, 64+28, 0, base2, shadow2, true])
      else
        textpos.push([_INTL("Item: None"), 8, 64+28, 0, base3, shadow3, true])
      end
      # Write the gender symbol
      if @pokemon.male?
        textpos.push([_INTL("Gender: ♀"), 8, 64+28+28, 0,base2, shadow2, true])
      elsif @pokemon.female?
        textpos.push([_INTL("Gender: ♂"), 8, 64+28+28, 0, base3, shadow3, true])
      else 
      textpos.push([_INTL("Gender: X"), 8, 64+28+28, 0,  base, shadow, true])
      end
      # Draw all text 
      pbDrawTextPositions(overlay, textpos)
      #I like this one actually: drawMarkings(overlay,  Graphics.width / 2 - 96/2, 32)
      drawMarkings(overlay,  8, 64+28+28+28)
      # Draw page-specific information
      case page
      when 1 then drawPageOne
      when 2 then drawPageTwo
      when 3 then drawPageThree
      when 4 then drawPageFour
      #when 5 then drawPageFive
      end
    end

    

    def drawPageOne
      overlay = @sprites["overlay"].bitmap
      overlay2 = @sprites["overlay2"].bitmap

      base_colors = [
        Color.new(255, 255, 255),
        Color.new(148, 15, 255),
        Color.new(120, 184, 232),
        Color.new(248, 168, 184)
      ]
      shadow_colors = [
        Color.new(165, 165, 173),
        Color.new(99, 0, 180),
        Color.new(0, 112, 248),
        Color.new(232, 32, 16)
      ]

      dexNumBase = base_colors[0]
      dexNumShadow = shadow_colors[0]

      textpos = [
        ["Specie: " + @pokemon.speciesName, 8, 276 + 28, 0, base_colors[3], shadow_colors[3], true]
      ]

      dexnumshift = false
      if $player.pokedex.unlocked?(-1)
        dexnum = @nationalDexList.index(@pokemon.species_data.species) || 0
        dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(-1)
      else
        dexnum = 0
        ($player.pokedex.dexes_count - 1).times do |i|
          next if !$player.pokedex.unlocked?(i)
          num = pbGetRegionalNumber(i, @pokemon.species)
          next if num <= 0
          dexnum = num
          dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(i)
          break
        end
      end

      if dexnum <= 0
        textpos.push(["Dex ID: ???", 8, 276, 0, base_colors[3], shadow_colors[3], true])
      else
        dexnum -= 1 if dexnumshift
        textpos.push([sprintf("Dex ID: " + "%03d", dexnum), 8, 276, 0, base_colors[2], shadow_colors[2], true])
      end

      textpos.push([sprintf("Public ID: " + "%05d", @pokemon.owner.public_id), 8, 276 + 28 + 28, 0, base_colors[0], shadow_colors[0], true])

      endexp = @pokemon.growth_rate.minimum_exp_for_level(@pokemon.level + 1)
      textpos.push(["Exp. Points: " + @pokemon.exp.to_s_formatted, 8, 276 + 28 + 28 + 28, 0, base_colors[1], shadow_colors[1], true])
      textpos.push(["To Next Lv: " + (endexp - @pokemon.exp).to_s_formatted, 8, 276 + 28 + 28 + 28 + 28, 0, base_colors[2], shadow_colors[2], true])

      height = @pokemon.species_data.height
      weight = @pokemon.species_data.weight
      if System.user_language[3..4] == "US"
        inches = (height / 0.254).round
        pounds = (weight / 0.45359).round
        textpos.push([_ISPRINTF("Height: {1:d}'{2:02d}\"", inches / 12, inches % 12), 520, 276 + 28, 0, base_colors[2], shadow_colors[2], true])
        textpos.push([_ISPRINTF("Weight: {1:4.1f} lbs.", pounds / 10.0), 520, 276 + 28 + 28, 0, base_colors[3], shadow_colors[3], true])
      else
        textpos.push([_ISPRINTF("Height: {1:.1f} m", height / 10.0), 520, 276 + 28, 0, base_colors[2], shadow_colors[2], true])
        textpos.push([_ISPRINTF("Weight: {1:.1f} kg", weight / 10.0), 520, 276 + 28 + 28, 0, base_colors[3], shadow_colors[3], true])
      end

      textpos.push(["Category: " + @pokemon.species_data.category.to_s, 520, 276, 0, base_colors[1], shadow_colors[1], true])

      pbDrawTextPositions(overlay, textpos)

      footprint = RPG::Cache.load_bitmap("Graphics/Pokemon/Footprints/", @pokemon.speciesName)
      if GameData::Species.footprint_filename(@pokemon, @form)
          overlay.blt(720, 384, footprint, footprint.rect)
      end
      arckyTextWrapping(overlay2, @pokemon.species_data.pokedex_entry.to_s, 520, 8, 20, 0, [[240, 1]], base_colors[2], shadow_colors[2], 1, true)
      @pokemon.types.each_with_index do |type, i|
        type_number = GameData::Type.get(type).icon_position
        type_rect = Rect.new(0, type_number * 28, 30, 28)
        type_x = (@pokemon.types.length == 1) ? 182 - 6 + 30 : 182 - 6 + (30 * i)
        overlay.blt(type_x, 266, @typebitmap.bitmap, type_rect)
      end

      if @pokemon.level < GameData::GrowthRate.max_level
        w = @pokemon.exp_fraction * 236
        w = ((w / 2).round) * 2
        pbDrawImagePositions(overlay, [["Graphics/Pictures/UI/SummaryUI/overlay_exp", 10, 418, 0, 0, w, 6]])
      end
    end

    def drawPageOneEgg
      base_colors = [
        Color.new(255, 255, 255),
        Color.new(148, 15, 255),
        Color.new(120, 184, 232),
        Color.new(248, 168, 184)
      ]
      shadow_colors = [
        Color.new(165, 165, 173),
        Color.new(99, 0, 180),
        Color.new(0, 112, 248),
        Color.new(232, 32, 16)
      ]
      base, shadow, base1, shadow1, base2, shadow2, base3, shadow3 = base_colors.zip(shadow_colors).flatten
      dexNumBase = base
      dexNumShadow = shadow
      @sprites["itemicon"].item = @pokemon.item_id
      overlay = @sprites["overlay"].bitmap
      overlay2 = @sprites["overlay2"].bitmap
      @sprites["bg_overlay"].setBitmap("Graphics/Pictures/UI/SummaryUI/bg_page_egg")
      @sprites["menuoverlay"].setBitmap("Graphics/Pictures/UI/SummaryUI/bg_page_egg")
      textpos = [
        [_INTL("#{@pokemon.owner.name}'s Memo"), Graphics.width / 2, 10, 2, base, shadow, true],
        ["Name: " + @pokemon.name, 8, 8, 0, base1, shadow1, true]
      ]
      if @pokemon.hasItem?
        textpos.push(["Item: " + @pokemon.item.name.to_s, 8, 8+28, 0, base2, shadow2, true])
      else
        textpos.push([_INTL("Item: None"), 290, 8+28, 0, base2, shadow2])
      end
      textpos.push(["Obtained:", 8, 8+28+28, 0, base, shadow, true])
      if @pokemon.timeReceived
        date  = @pokemon.timeReceived.day
        month = pbGetMonthName(@pokemon.timeReceived.mon)
        year  = @pokemon.timeReceived.year
        textpos.push(["#{date} #{month}, #{year}", 8, 8+28+28+28, 0, base3, shadow3, true])
      else
        textpos.push(["< Unknown >", 8, 8+28+28+28, 0, base3, shadow3, true])
      end
      mapname = pbGetMapNameFromId(@pokemon.obtain_map)
      mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
      if mapname && mapname != ""
        textpos.push(["From: #{mapname}", 8, 8+28+28+28+28, 0, base1, shadow1, true])
      else
        textpos.push(["From: < Unknown >", 8, 8+28+28+28+28, 0, base1, shadow1, true])
      end
      arckyTextWrapping(overlay, "\"The Egg Watch\"",  8, 276, 20, 0, [[240, 1]], base1, shadow1, 1, true)
      case
      when @pokemon.steps_to_hatch > 10_200
        arckyTextWrapping(overlay2, "It seems this Egg will take some time to hatch, requiring a bit of patience on our part.", 8, 276+28, 20, 0, [[240, 1]], base, shadow, 1, true)
      when @pokemon.steps_to_hatch < 10_200
        arckyTextWrapping(overlay2, "What mysterious creature awaits us within this Egg? It's not quite ready to hatch, and the mystery lingers.", 8, 276+28, 20, 0, [[240, 1]], base, shadow, 1, true)
      when @pokemon.steps_to_hatch < 2550
        arckyTextWrapping(overlay2, "This Egg shows subtle signs of movement, hinting at the nearing moment of hatching.", 8, 276+28, 20, 0, [[240, 1]], base, shadow, 1, true)
      when @pokemon.steps_to_hatch < 1275
        arckyTextWrapping(overlay2, "Mysterious sounds emanate from within, indicating that the awaited hatching moment is approaching!", 8, 276+28, 20, 0, [[240, 1]], base, shadow, 1, true)
      end
      pbDrawTextPositions(overlay, textpos)
      drawMarkings(overlay,  8, 64+28+28+28)
    end

    def drawPageTwo
      base_colors = [
        Color.new(255, 255, 255),
        Color.new(148, 15, 255),
        Color.new(120, 184, 232),
        Color.new(248, 168, 184)
      ]
      shadow_colors = [
        Color.new(165, 165, 173),
        Color.new(99, 0, 180),
        Color.new(0, 112, 248),
        Color.new(232, 32, 16)
      ]

      base, shadow, base1, shadow1, base2, shadow2, base3, shadow3 = base_colors.zip(shadow_colors).flatten

      overlay = @sprites["overlay"].bitmap
      overlay2 = @sprites["overlay2"].bitmap
      overlay2.clear
      memo = ""
      textpos = []

      if !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
        textpos.push(["Nature: " + @pokemon.nature.name.to_s, 8,  276, 0, base1, shadow1, true])
      end

      if @pokemon.timeReceived
        date  = @pokemon.timeReceived.day
        month = pbGetMonthName(@pokemon.timeReceived.mon)
        year  = @pokemon.timeReceived.year
        textpos.push(["#{date} #{month}, #{year}", 8, 276+28, 0, base2, shadow2, true])
      else
        textpos.push(["< Unknown >", 8, 276+28, 0, base2, shadow2, true])
      end

      mapname = pbGetMapNameFromId(@pokemon.obtain_map)
      mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?

      if !mapname || mapname==""
        textpos.push(["From: A distant place", 8, 276+28+28, 0, base3, shadow3, true])
      else
        textpos.push(["From: " + mapname, 8,  276+28+28, 0, base3, shadow3, true])
      end

      metText = [
        "Met at Lv #{@pokemon.obtain_level}",
        "Egg received",
        "Traded at Lv #{@pokemon.obtain_level}",
        "",
        "Encountered at #{@pokemon.obtain_level}"
      ][@pokemon.obtain_method]

      textpos.push([metText, 8, 276+28+28+28, 0, base1, shadow1, true])

      if @pokemon.obtain_method == 1
        if @pokemon.timeReceived
          date  = @pokemon.timeReceived.day
          month = pbGetMonthName(@pokemon.timeReceived.mon)
          year  = @pokemon.timeReceived.year
          textpos.push(["#{date} #{month}, #{year}", 8, 276+28, 0, base2, shadow2, true])
        else
          textpos.push(["< Unknown >", 8, 276+28, 0, base2, shadow2, true])
        end

        mapname = pbGetMapNameFromId(@pokemon.hatched_map)
        mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?

        if !mapname || mapname==""
          textpos.push(["From: A distant place", 8, 276+28+28, 0, base3, shadow3, true])
        else
          textpos.push(["From: " + mapname, 8,  276+28+28, 0, base3, shadow3, true])
        end
      end

      best_stat = nil
      best_iv = 0
      stats_order = [:HP, :ATTACK, :DEFENSE, :SPEED, :SPECIAL_ATTACK, :SPECIAL_DEFENSE]
      start_point = @pokemon.personalID % stats_order.length

      stats_order.length.times do |i|
        stat = stats_order[(i + start_point) % stats_order.length]
        if !best_stat || @pokemon.iv[stat] > @pokemon.iv[best_stat]
          best_stat = stat
          best_iv = @pokemon.iv[best_stat]
        end
      end

      characteristics = {
        :HP              => ["Absolutely adores savoring delicious meals, often savoring every bite with pure delight.",
                             "Finds joy in taking numerous siestas, embracing the art of relaxation and rejuvenation.",
                             "Frequently nods off, navigating through a world filled with dreams and moments of peaceful slumber.",
                             "Has a tendency to scatter belongings, creating a playful and lively environment wherever it goes.",
                             "Finds true happiness in the simple pleasure of unwinding and embracing moments of serene relaxation."],

        :ATTACK          => ["Takes great pride in showcasing its immense power, exuding confidence in every step it takes.",
                             "Thrives on the thrill of energetic movements, frequently indulging in bouts of enthusiastic activity.",
                             "Carries a slightly quick-tempered demeanor, adding a fiery spark to its lively and passionate nature.",
                             "Finds true joy in engaging in spirited battles, displaying a love for the art of combat.",
                             "Demonstrates a quick-tempered personality, adding an element of unpredictability to its character."],

        :DEFENSE         => ["Boasts a robust and sturdy body, capable of withstanding formidable hits with ease.",
                             "Possesses an exceptional ability to endure and persevere, facing challenges with unwavering determination.",
                             "Exhibits a highly persistent nature, never backing down when confronted with obstacles.",
                             "Showcases remarkable endurance, navigating through various challenges with resilience and fortitude.",
                             "Embodies the spirit of perseverance, tackling every task with unwavering commitment and dedication."],

        :SPECIAL_ATTACK  => ["Radiates an air of intense curiosity, constantly seeking to explore the wonders of its surroundings.",
                             "Engages in mischievous antics, adding a playful and lighthearted touch to its daily activities.",
                             "Demonstrates a thoroughly cunning mindset, always one step ahead in its strategic thinking.",
                             "Often found lost in profound thoughts, showcasing a depth of contemplation and introspection.",
                             "Displays a very finicky nature, paying meticulous attention to detail in its preferences and choices."],

        :SPECIAL_DEFENSE => ["Possesses a strong-willed character, facing challenges with unwavering determination and resilience.",
                             "Exhibits a somewhat vain demeanor, taking pride in its unique and remarkable qualities.",
                             "Stands firmly in its strong defiance, refusing to yield or compromise in the face of opposition.",
                             "Harbors an intense aversion to losing, approaching every endeavor with a competitive spirit.",
                             "Demonstrates a somewhat stubborn nature, persistently holding onto its beliefs and convictions."],

        :SPEED           => ["Finds pure joy in the act of running, embracing the liberating feeling of swift and carefree movement.",
                             "Maintains a heightened sense of alertness to surrounding sounds, attuned to the rhythm of the environment.",
                             "Navigates through life with an impetuous and silly demeanor, adding a touch of whimsy to every moment.",
                             "Easily transforms into a delightful clown, infusing a sense of humor and playfulness into its interactions.",
                             "Possesses a quick-to-flee instinct, effortlessly darting away from situations that evoke a sense of unease."]
      }
      arckyTextWrapping(overlay2, characteristics[best_stat][best_iv % 5].to_s, 520, 8, 20, 0, [[240, 1]], base3, shadow3, 1, true)
      pbDrawTextPositions(overlay, textpos)
    end

      #===============================================================================
      # IV Ratings - Shows IV ratings on Page 3 (Stats)
      #   Adaptaded from Lucidious89's IV star script by Tommaniacal
      #
      # Converted to BW Summary Pack by DeepBlue PacificWaves
      #	Updated to v19 by Shashu-Greninja
      # Simplified by ChatGPT
      #===============================================================================
    def pbDisplayIVRating
      ratings_base = "Graphics/Pictures/UI/SummaryUI/Rating"
      overlay = @sprites["overlay"].bitmap
      imagepos = []

      stats_order = [:HP, :ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED]

      stats_order.each_with_index do |stat, index|
        rating_image = sprintf("%s%s", ratings_base, getRatingLetter(@pokemon.iv[stat], @pokemon.ivMaxed[stat]))
        imagepos.push([rating_image, 528 + 48 - 24, 30 + index * 64, 0, 0, -1, -1]) # X: 552
      end

      pbDrawImagePositions(overlay, imagepos)
    end

    def getRatingLetter(iv, iv_maxed)
      return 'S' if iv > 30 || iv_maxed
      return 'A' if iv > 22 && iv < 31
      return 'B' if iv > 15 && iv < 23
      return 'C' if iv > 7 && iv < 16
      return 'D' if iv > 0 && iv < 8
      'F'
    end

    def drawPageThree
      overlay = @sprites["overlay"].bitmap
      overlay2 = @sprites["overlay2"].bitmap
      overlay2.clear
      overlay3 = @sprites["overlay3"].bitmap
      overlay3.clear

      base_colors = [
        Color.new(255, 255, 255),
        Color.new(148, 15, 255),
        Color.new(120, 184, 232),
        Color.new(248, 168, 184)
      ]

      shadow_colors = [
        Color.new(165, 165, 173),
        Color.new(99, 0, 180),
        Color.new(0, 112, 248),
        Color.new(232, 32, 16)
      ]

      base, shadow, base1, shadow1, base2, shadow2, base3, shadow3 = base_colors.zip(shadow_colors).flatten

      @sprites["bg_overlay"].setBitmap("Graphics/Pictures/UI/SummaryUI/bg_page_3")
      @sprites["menuoverlay"].setBitmap("Graphics/Pictures/UI/SummaryUI/bg_page_3")

      pbDisplayIVRating if SHOW_IV_RATINGS

      statshadows = {}
      statbase = {}
      GameData::Stat.each_main { |s| statshadows[s.id], statbase[s.id] = shadow, base }

      if !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
        @pokemon.nature_for_stats.stat_changes.each do |change|
          statshadows[change[0]] = shadow2 if change[1] > 0
          statbase[change[0]] = base2 if change[1] > 0
          statshadows[change[0]] = shadow3 if change[1] < 0
          statbase[change[0]] = base3 if change[1] < 0
        end
      end

      textpos = []
      mainX = 528 + 48 # 576
      mainY = 32
      offset = 32

      if SHOW_EV_IV
        textpos.push(["HP: | #{@pokemon.totalhp} |", mainX, mainY, 0, statbase[:HP], statshadows[:HP], true])
        textpos.push(["ATK: | #{@pokemon.attack} |", mainX, mainY + offset + offset, 0, statbase[:ATTACK], statshadows[:ATTACK], true])
        textpos.push(["DEF: | #{@pokemon.defense} |", mainX, mainY + offset + offset + offset + offset, 0,  statbase[:DEFENSE], statshadows[:DEFENSE], true])
        textpos.push(["SPATK: | #{@pokemon.spatk} |", mainX, mainY + offset + offset + offset + offset + offset + offset, 0, statbase[:SPECIAL_ATTACK], statshadows[:SPECIAL_ATTACK], true])
        textpos.push(["SPDEF: | #{@pokemon.spdef} |", mainX, mainY + offset + offset + offset + offset + offset + offset + offset + offset, 0,  statbase[:SPECIAL_DEFENSE], statshadows[:SPECIAL_DEFENSE], true])
        textpos.push(["SPD: | #{@pokemon.speed} |", mainX, mainY + offset + offset + offset + offset + offset + offset + offset + offset + offset + offset, 0, statbase[:SPEED], statshadows[:SPEED], true])
      end

      textpos2 = [
        ["| Ev: #{@pokemon.ev[:HP]} | Iv: #{@pokemon.iv[:HP]} |", mainX, mainY + offset, 0, statbase[:HP], statshadows[:HP], true],
        ["| Ev: #{@pokemon.ev[:ATTACK]} | Iv: #{@pokemon.iv[:ATTACK]} |", mainX, mainY + offset + offset + offset, 0, statbase[:ATTACK], statshadows[:ATTACK], true],
        ["| Ev: #{@pokemon.ev[:DEFENSE]} | Iv: #{@pokemon.iv[:DEFENSE]} |", mainX, mainY + offset + offset + offset + offset + offset, 0,  statbase[:DEFENSE], statshadows[:DEFENSE], true],
        ["| Ev: #{@pokemon.ev[:SPECIAL_ATTACK]} | Iv: #{@pokemon.iv[:SPECIAL_ATTACK]} |", mainX, mainY + offset + offset + offset + offset + offset + offset + offset, 0, statbase[:SPECIAL_ATTACK], statshadows[:SPECIAL_ATTACK], true],
        ["| Ev: #{@pokemon.ev[:SPECIAL_DEFENSE]} | Iv: #{@pokemon.iv[:SPECIAL_DEFENSE]} |", mainX, mainY + offset + offset + offset + offset + offset + offset + offset + offset + offset, 0, statbase[:SPECIAL_DEFENSE], statshadows[:SPECIAL_DEFENSE], true],
        ["| Ev: #{@pokemon.ev[:SPEED]} | Iv: #{@pokemon.iv[:SPEED]} |", mainX, mainY + offset + offset + offset + offset + offset + offset + offset + offset + offset + offset + offset , 0, statbase[:SPEED], statshadows[:SPEED], true]
      ]

      if @pokemon.ability
        textpos.push(["Ability: #{@pokemon.ability.name}", 8, 276, 0, base1, shadow1, true])
        arckyTextWrapping(overlay2, @pokemon.ability.description, 8, 276 + 28, 20, 0, [[240, 1]], base2, shadow2, 1, true)
      end

      pbDrawTextPositions(overlay2, textpos2)
      pbDrawTextPositions(overlay, textpos)
    end

    def drawPageFour
      overlay = @sprites["overlay"].bitmap
      overlay2 = @sprites["overlay2"].bitmap
      overlay2.clear
      overlay3 = @sprites["overlay3"].bitmap
      overlay3.clear

      # Changes the color of the text, to the one used in BW
      base_colors = [
        Color.new(255, 255, 255),
        Color.new(148, 15, 255),
        Color.new(120, 184, 232),
        Color.new(248, 168, 184)
      ]
      shadow_colors = [
        Color.new(165, 165, 173),
        Color.new(99, 0, 180),
        Color.new(0, 112, 248),
        Color.new(232, 32, 16)
      ]
      move_base = base_colors[0]
      move_shadow = shadow_colors[0]
      pp_base = [
        move_base,
        Color.new(255, 214, 0),
        Color.new(255, 115, 0),
        Color.new(255, 8, 72)
      ]
      pp_shadow = [
        move_shadow,
        Color.new(123, 99, 0),
        Color.new(115, 57, 0),
        Color.new(123, 8, 49)
      ]

      @sprites["pokeicon"].visible = false
      @sprites["itemicon"].visible = true
      text_positions = []
      text_positions2 = []
      image_positions = []
      main_x2 = 528 + 20
      y_pos = 32
      offset = 0

      Pokemon::MAX_MOVES.times do |i|
        move = @pokemon.moves[i]

        if move
          type_number = GameData::Type.get(move.display_type(@pokemon)).icon_position
          image_positions.push(["Graphics/Pictures/types", main_x2, y_pos, 0, type_number * 28, 64, 28])
          text_positions.push([move.name, main_x2 + 34, y_pos + 4, 0, move_base, move_shadow, true])

          if move.total_pp > 0
            pp_fraction = 0

            if move.pp == 0
              pp_fraction = 3
            elsif move.pp * 4 <= move.total_pp
              pp_fraction = 2
            elsif move.pp * 2 <= move.total_pp
              pp_fraction = 1
            end

            text_positions2.push(["Power Points: #{move.pp}/#{move.total_pp}", main_x2 + 2, y_pos - offset + 32, 0, pp_base[pp_fraction], pp_shadow[pp_fraction], true])
          end
        else
          text_positions.push(["-", main_x2 + 100, y_pos, 0, move_base, move_shadow, true])
          text_positions.push(["--", main_x2 + 226, y_pos + 44, 1, move_base, move_shadow, true])
        end

        y_pos += 64
      end

      pbDrawTextPositions(overlay, text_positions)
      pbDrawTextPositions(overlay2, text_positions2)
      pbDrawImagePositions(overlay, image_positions)
    end

    def drawPageFourSelecting(move_to_learn)
      overlay = @sprites["overlay"].bitmap
      overlay.clear
      overlay2 = @sprites["overlay2"].bitmap
      overlay3 = @sprites["overlay3"].bitmap
      overlay3.clear

      base_colors = [
        Color.new(255, 255, 255),
        Color.new(148, 15, 255),
        Color.new(120, 184, 232),
        Color.new(248, 168, 184)
      ]
      shadow_colors = [
        Color.new(165, 165, 173),
        Color.new(99, 0, 180),
        Color.new(0, 112, 248),
        Color.new(232, 32, 16)
      ]
      move_base = base_colors[0]
      move_shadow = shadow_colors[0]
      pp_base = [
        move_base,
        Color.new(255, 214, 0),
        Color.new(255, 115, 0),
        Color.new(255, 8, 74)
      ]
      pp_shadow = [
        move_shadow,
        Color.new(123, 99, 0),
        Color.new(115, 57, 0),
        Color.new(123, 8, 49)
      ]

      @sprites["menuoverlay"].setBitmap("Graphics/Pictures/UI/SummaryUI/bg_page_4")

      text_positions2 = []
      text_positions = []
      image_positions = []

      if move_to_learn || SUMMARY_B2W2_STYLE
        text_positions.push([_INTL("Category: "), 8, 8, 0, base_colors[0], shadow_colors[0], true])
      end

      main_x2 = 528 + 20
      y_pos = 32
      offset = 0
      limit = move_to_learn ? Pokemon::MAX_MOVES + 1 : Pokemon::MAX_MOVES

      limit.times do |i|
        move = @pokemon.moves[i]

        if i == Pokemon::MAX_MOVES
          move = move_to_learn
          y_pos += 20
        end

        if move
          type_number = GameData::Type.get(move.display_type(@pokemon)).icon_position
          image_positions.push(["Graphics/Pictures/types", main_x2, y_pos, 0, type_number * 28, 64, 28])
          text_positions.push([move.name, main_x2 + 34, y_pos + 4, 0, move_base, move_shadow, true])

          if move.total_pp > 0
            pp_fraction = 0

            if move.pp == 0
              pp_fraction = 3
            elsif move.pp * 4 <= move.total_pp
              pp_fraction = 2
            elsif move.pp * 2 <= move.total_pp
              pp_fraction = 1
            end

            text_positions2.push(["Power Points: #{move.pp}/#{move.total_pp}", main_x2 + 2, y_pos - offset + 32, 0, pp_base[pp_fraction], pp_shadow[pp_fraction], true])
          end
        else
          text_positions.push(["-", 328, y_pos + 12, 0, move_base, move_shadow, true])
          text_positions.push(["--", 454, y_pos + 44, 1, move_base, move_shadow, true])
        end

        y_pos += 64
      end

      text_positions.push(["#{@pokemon.name}'s Moves", Graphics.width / 2, 10, 2, base_colors[0], shadow_colors[0], true])

      pbDrawTextPositions(overlay, text_positions)
      pbDrawImagePositions(overlay, image_positions)

      @pokemon.types.each_with_index do |type, i|
        type_number = GameData::Type.get(type).icon_position
        type_rect = Rect.new(0, type_number * 28, 30, 28)
        type_x = (@pokemon.types.length == 1) ? 216 - 22 + 30 : 216 - 22 + (30 * i)
        overlay.blt(type_x, 64, @typebitmap.bitmap, type_rect)
      end
    end

    def drawSelectedMove(move_to_learn, selected_move)
      drawPageFourSelecting(move_to_learn)
      overlay = @sprites["overlay"].bitmap
      overlay2 = @sprites["overlay2"].bitmap
      overlay3 = @sprites["overlay3"].bitmap
      base_colors = [
        Color.new(255, 255, 255),
        Color.new(148, 15, 255),
        Color.new(120, 184, 232),
        Color.new(248, 168, 184)
      ]
      shadow_colors = [
        Color.new(165, 165, 173),
        Color.new(99, 0, 180),
        Color.new(0, 112, 248),
        Color.new(232, 32, 16)
      ]
      move_base = base_colors[0]
      move_shadow = shadow_colors[0]
      text_positions = []
      text_positions2 = []

      case selected_move.display_damage(@pokemon)
      when 0
        text_positions.push(["Power: " + "...", 8, 8 + 28, 0, base_colors[1], shadow_colors[1], true])
      when 1
        text_positions.push(["Power: " + "???", 8, 8 + 28, 0, base_colors[1], shadow_colors[1], true])
      else
        text_positions.push(["Power: " + selected_move.display_damage(@pokemon).to_s, 8, 8 + 28, 0, base_colors[1], shadow_colors[1], true])
      end

      if selected_move.display_accuracy(@pokemon) == 0
        text_positions.push(["Accuracy: " + "...", 8, 8 + 28 + 28, 0, base_colors[1], shadow_colors[1], true])
      else
        text_positions.push(["Accuracy: " + selected_move.display_accuracy(@pokemon).to_s + "%", 8, 8 + 28 + 28, 0, base_colors[1], shadow_colors[1], true])
      end

      text_positions.push(["#{@pokemon.name}'s Moves", Graphics.width / 2, 10, 2, base_colors[0], shadow_colors[0], true])

      pbDrawTextPositions(overlay, text_positions)

      image_positions = [["Graphics/Pictures/category", 122, 6, 0, selected_move.display_category(@pokemon) * 28, 64, 28]]
      pbDrawImagePositions(overlay, image_positions)

      arckyTextWrapping(overlay3, selected_move.description, 8, 276, 20, 0, [[240, 1]], base_colors[2], shadow_colors[2], 1, true)
    end

    # def drawPageFive
    #   base   = Color.new(255, 255, 255)
    #   shadow = Color.new(165, 165, 173)
    #   base1   = Color.new(148, 15, 255)
    #   shadow1 = Color.new(99, 0, 180)
    #   base2 = Color.new(120, 184, 232)
    #   shadow2 = Color.new(0, 112, 248)
    #   base3 = Color.new(248, 168, 184)
    #   shadow3 = Color.new(232, 32, 16)
    #   overlay = @sprites["overlay"].bitmap
    #   overlay2 = @sprites["overlay2"].bitmap
    #   overlay2.clear
    #   overlay3 = @sprites["overlay3"].bitmap
    #   overlay3.clear
    #   @sprites["uparrow"].visible   = false
    #   @sprites["downarrow"].visible = false
    #   # Write various bits of text
    #   textpos = [
    #      [_INTL("No. of Ribbons:"), 38, 308, 0, base, shadow],
    #      [@pokemon.numRibbons.to_s, 157, 340, 1, base1, shadow1],
    #   ]
    #   # Draw all text
    #   pbDrawTextPositions(overlay, textpos)
    #   # Show all ribbons
    #   imagepos = []
    #   coord = 0
    #   (@ribbonOffset * 4...(@ribbonOffset * 4) + 12).each do |i|
    #     break if !@pokemon.ribbons[i]
    #     ribbon_data = GameData::Ribbon.get(@pokemon.ribbons[i])
    #     ribn = ribbon_data.icon_position
    #     imagepos.push(["Graphics/Pictures/ribbons",
    #        2 + (68 * (coord % 4)), 74 + (68 * (coord / 4).floor),
    #        64 * (ribn % 8), 64 * (ribn / 8).floor, 64, 64])
    #     coord += 1
    #   end
    #   # Draw all images
    #   pbDrawImagePositions(overlay, imagepos)
    # end

    # def drawSelectedRibbon(ribbonid)
    #   # Draw all of page five
    #   drawPage(5)
    #   # Set various values
    #   overlay = @sprites["overlay"].bitmap
    #   # Changes the color of the text, to the one used in BW
    #   base   = Color.new(255, 255, 255)
    #   shadow = Color.new(165, 165, 173)
    #   nameBase   = Color.new(148, 15, 255)
    #   nameShadow = Color.new(99, 0, 180)
    #   # Get data for selected ribbon
    #   name = ribbonid ? GameData::Ribbon.get(ribbonid).name : ""
    #   desc = ribbonid ? GameData::Ribbon.get(ribbonid).description : ""
    #   # Draw the description box
    #   if SUMMARY_B2W2_STYLE
    #     imagepos = [["Graphics/Pictures/UI/SummaryUI/overlay_ribbon_B2W2", 0, 280]]
    #   else
    #     imagepos = [["Graphics/Pictures/UI/SummaryUI/overlay_ribbon", 0, 280]]
    #   end
    #   pbDrawImagePositions(overlay, imagepos)

    #   # Draw name of selected ribbon
    #   textpos = [
    #      [name,30, 292, 0, nameBase, nameShadow]
    #   ]
    #   pbDrawTextPositions(overlay, textpos)
    #   # Draw selected ribbon's description
    #   drawTextEx(overlay, 30, 324, 480, 0, desc, base, shadow)
    # end

    def pbGoToPrevious
      newindex = @partyindex
      while newindex > 0
        newindex -= 1
        if @party[newindex] && (@page == 1 || !@party[newindex].egg?)
          @partyindex = newindex
          break
        end
      end
    end

    def pbGoToNext
      newindex = @partyindex
      while newindex < @party.length - 1
        newindex += 1
        if @party[newindex] && (@page == 1 || !@party[newindex].egg?)
          @partyindex = newindex
          break
        end
      end
    end

    def pbChangePokemon
      @pokemon = @party[@partyindex]
      @sprites["pokemon"].setPokemonBitmap(@pokemon)
      @sprites["itemicon"].item = @pokemon.item_id
      pbSEStop
      @pokemon.play_cry
    end

    def pbMoveSelection
      @sprites["movesel"].visible = true
      @sprites["movesel"].index   = 0
      selmove    = 0
      oldselmove = 0
      switching = false
      drawSelectedMove(nil, @pokemon.moves[selmove])
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["movepresel"].index == @sprites["movesel"].index
          @sprites["movepresel"].z = @sprites["movesel"].z + 1
        else
          @sprites["movepresel"].z = @sprites["movesel"].z
        end
        if Input.trigger?(Input::BACK)
          (switching) ? pbPlayCancelSE : pbPlayCloseMenuSE
          break if !switching
          @sprites["movepresel"].visible = false
          switching = false
        elsif Input.trigger?(Input::USE)
          pbPlayDecisionSE
          if selmove == Pokemon::MAX_MOVES
            break if !switching
            @sprites["movepresel"].visible = false
            switching = false
          elsif !@pokemon.shadowPokemon?
            if switching
              tmpmove                    = @pokemon.moves[oldselmove]
              @pokemon.moves[oldselmove] = @pokemon.moves[selmove]
              @pokemon.moves[selmove]    = tmpmove
              @sprites["movepresel"].visible = false
              switching = false
              drawSelectedMove(nil, @pokemon.moves[selmove])
            else
              @sprites["movepresel"].index   = selmove
              @sprites["movepresel"].visible = true
              oldselmove = selmove
              switching = true
            end
          end
        elsif Input.trigger?(Input::UP)
          selmove -= 1
          if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
            selmove = @pokemon.numMoves - 1
          end
          selmove = 0 if selmove >= Pokemon::MAX_MOVES
          selmove = @pokemon.numMoves - 1 if selmove < 0
          @sprites["movesel"].index = selmove
          pbPlayCursorSE
          drawSelectedMove(nil, @pokemon.moves[selmove])
        elsif Input.trigger?(Input::DOWN)
          selmove += 1
          selmove = 0 if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
          selmove = 0 if selmove >= Pokemon::MAX_MOVES
          selmove = Pokemon::MAX_MOVES if selmove < 0
          @sprites["movesel"].index = selmove
          pbPlayCursorSE
          drawSelectedMove(nil, @pokemon.moves[selmove])
        end
      end
      @sprites["movesel"].visible = false
    end

    # def pbRibbonSelection
    #   @sprites["ribbonsel"].visible = true
    #   @sprites["ribbonsel"].index   = 0
    #   selribbon    = @ribbonOffset * 4
    #   oldselribbon = selribbon
    #   switching = false
    #   numRibbons = @pokemon.ribbons.length
    #   numRows    = [((numRibbons + 3) / 4).floor, 3].max
    #   drawSelectedRibbon(@pokemon.ribbons[selribbon])
    #   loop do
    #     @sprites["uparrow"].visible   = (@ribbonOffset > 0)
    #     @sprites["downarrow"].visible = (@ribbonOffset < numRows - 3)
    #     Graphics.update
    #     Input.update
    #     pbUpdate
    #     if @sprites["ribbonpresel"].index == @sprites["ribbonsel"].index
    #       @sprites["ribbonpresel"].z = @sprites["ribbonsel"].z + 1
    #     else
    #       @sprites["ribbonpresel"].z = @sprites["ribbonsel"].z
    #     end
    #     hasMovedCursor = false
    #     if Input.trigger?(Input::BACK)
    #       (switching) ? pbPlayCancelSE : pbPlayCloseMenuSE
    #       break if !switching
    #       @sprites["ribbonpresel"].visible = false
    #       switching = false
    #     elsif Input.trigger?(Input::USE)
    #       if switching
    #         pbPlayDecisionSE
    #         tmpribbon                      = @pokemon.ribbons[oldselribbon]
    #         @pokemon.ribbons[oldselribbon] = @pokemon.ribbons[selribbon]
    #         @pokemon.ribbons[selribbon]    = tmpribbon
    #         if @pokemon.ribbons[oldselribbon] || @pokemon.ribbons[selribbon]
    #           @pokemon.ribbons.compact!
    #           if selribbon >= numRibbons
    #             selribbon = numRibbons - 1
    #             hasMovedCursor = true
    #           end
    #         end
    #         @sprites["ribbonpresel"].visible = false
    #         switching = false
    #         drawSelectedRibbon(@pokemon.ribbons[selribbon])
    #       else
    #         if @pokemon.ribbons[selribbon]
    #           pbPlayDecisionSE
    #           @sprites["ribbonpresel"].index = selribbon - (@ribbonOffset * 4)
    #           oldselribbon = selribbon
    #           @sprites["ribbonpresel"].visible = true
    #           switching = true
    #         end
    #       end
    #     elsif Input.trigger?(Input::UP)
    #       selribbon -= 4
    #       selribbon += numRows * 4 if selribbon < 0
    #       hasMovedCursor = true
    #       pbPlayCursorSE
    #     elsif Input.trigger?(Input::DOWN)
    #       selribbon += 4
    #       selribbon -= numRows * 4 if selribbon >= numRows * 4
    #       hasMovedCursor = true
    #       pbPlayCursorSE
    #     elsif Input.trigger?(Input::LEFT)
    #       selribbon -= 1
    #       selribbon += 4 if selribbon % 4 == 3
    #       hasMovedCursor = true
    #       pbPlayCursorSE
    #     elsif Input.trigger?(Input::RIGHT)
    #       selribbon += 1
    #       selribbon -= 4 if selribbon % 4 == 0
    #       hasMovedCursor = true
    #       pbPlayCursorSE
    #     end
    #   next if !hasMovedCursor
    #       @ribbonOffset = (selribbon / 4).floor if selribbon < @ribbonOffset * 4
    #       @ribbonOffset = (selribbon / 4).floor - 2 if selribbon >= (@ribbonOffset + 3) * 4
    #       @ribbonOffset = 0 if @ribbonOffset < 0
    #       @ribbonOffset = numRows - 3 if @ribbonOffset > numRows - 3
    #       @sprites["ribbonsel"].index    = selribbon - (@ribbonOffset * 4)
    #       @sprites["ribbonpresel"].index = oldselribbon - (@ribbonOffset * 4)
    #     drawSelectedRibbon(@pokemon.ribbons[selribbon])
    #   end
    #       @sprites["ribbonsel"].visible = false
    # end

    def pbMarking(pokemon)
      @sprites["markingbg"].visible      = true
      @sprites["markingoverlay"].visible = true
      @sprites["markingsel"].visible     = true
      # Changed the color of the text, to the one used in BW
      base   = Color.new(255, 255, 255)
      shadow = Color.new(165, 165, 173)
      ret = pokemon.markings.clone
      markings = pokemon.markings.clone
      mark_variants = @markingbitmap.bitmap.height / MARK_HEIGHT
      index = 0
      redraw = true
      markrect = Rect.new(0, 0, MARK_WIDTH, MARK_HEIGHT)
      loop do
        # Redraw the markings and text
        if redraw
          @sprites["markingoverlay"].bitmap.clear
          (@markingbitmap.bitmap.width / MARK_WIDTH).times do |i|
            markrect.x = i * MARK_WIDTH
            markrect.y = [(markings[i] || 0), mark_variants - 1].min * MARK_HEIGHT
            @sprites["markingoverlay"].bitmap.blt(300 + (58 * (i % 3)), 154 + (50 * (i / 3)),
                                                  @markingbitmap.bitmap, markrect)
          end
          textpos = [
             [_INTL("Mark {1}", pokemon.name), 366, 102, 2, base, shadow],
             [_INTL("OK"), 366, 254, 2, base, shadow],
             [_INTL("Cancel"), 366, 302, 2, base, shadow]
          ]
          pbDrawTextPositions(@sprites["markingoverlay"].bitmap, textpos)
          redraw = false
        end
        # Reposition the marking cursor
        @sprites["markingsel"].x = 284 + (58 * (index % 3))
        @sprites["markingsel"].y = 144 + (50 * (index / 3))
        case index
        when 6    # OK
          @sprites["markingsel"].x = 284
          @sprites["markingsel"].y = 244
          @sprites["markingsel"].src_rect.y = @sprites["markingsel"].bitmap.height / 2
        when 7    # Cancel
          @sprites["markingsel"].x = 284
          @sprites["markingsel"].y = 294
          @sprites["markingsel"].src_rect.y = @sprites["markingsel"].bitmap.height / 2
        else
          @sprites["markingsel"].src_rect.y = 0
        end
        Graphics.update
        Input.update
        pbUpdate
        if Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        elsif Input.trigger?(Input::USE)
          pbPlayDecisionSE
          case index
          when 6   # OK
            ret = markings
            break
          when 7   # Cancel
            break
          else
            markings[index] = ((markings[index] || 0) + 1) % mark_variants
            redraw = true
          end
        elsif Input.trigger?(Input::ACTION)
          if index < 6 && markings[index] > 0
            pbPlayDecisionSE
            markings[index] = 0
            redraw = true
          end
        elsif Input.trigger?(Input::UP)
          if index == 7
            index = 6
          elsif index == 6
            index = 4
          elsif index < 3
            index = 7
          else
            index -= 3
          end
          pbPlayCursorSE
        elsif Input.trigger?(Input::DOWN)
          if index == 7
            index = 1
          elsif index == 6
            index = 7
          elsif index >= 3
            index = 6
          else
            index += 3
          end
          pbPlayCursorSE
        elsif Input.trigger?(Input::LEFT)
          if index < 6
            index -= 1
            index += 3 if index % 3 == 2
            pbPlayCursorSE
          end
        elsif Input.trigger?(Input::RIGHT)
          if index < 6
            index += 1
            index -= 3 if index % 3 == 0
            pbPlayCursorSE
          end
        end
      end
      @sprites["markingbg"].visible      = false
      @sprites["markingoverlay"].visible = false
      @sprites["markingsel"].visible     = false
      if pokemon.markings != ret
        pokemon.markings = ret
        return true
      end
      return false
    end

    def pbOptions
      dorefresh = false
      commands = []
      cmdGiveItem = -1
      cmdTakeItem = -1
      cmdPokedex  = -1
      cmdMark     = -1
      if !@pokemon.egg?
        commands[cmdGiveItem = commands.length] = _INTL("Give item")
        commands[cmdTakeItem = commands.length] = _INTL("Take item") if @pokemon.hasItem?
        commands[cmdPokedex = commands.length]  = _INTL("View Pokédex") if $player.has_pokedex
      end
      commands[cmdMark = commands.length]       = _INTL("Mark")
      commands[commands.length]                 = _INTL("Cancel")
      command = pbShowCommands(commands)
      if cmdGiveItem >= 0 && command == cmdGiveItem
        item = nil
        pbFadeOutIn {
          scene = PokemonBag_Scene.new
          screen = PokemonBagScreen.new(scene, $bag)
          item = screen.pbChooseItemScreen(proc { |itm| GameData::Item.get(itm).can_hold? })
        }
        if item
          dorefresh = pbGiveItemToPokemon(item, @pokemon, self, @partyindex)
        end
      elsif cmdTakeItem >= 0 && command == cmdTakeItem
        dorefresh = pbTakeItemFromPokemon(@pokemon, self)
      elsif cmdPokedex >= 0 && command == cmdPokedex
        $player.pokedex.register_last_seen(@pokemon)
        pbFadeOutIn {
          scene = PokemonPokedexInfo_Scene.new
          screen = PokemonPokedexInfoScreen.new(scene)
          screen.pbStartSceneSingle(@pokemon.species)
        }
        dorefresh = true
      elsif cmdMark >= 0 && command == cmdMark
        dorefresh = pbMarking(@pokemon)
      end
      return dorefresh
    end

    def pbChooseMoveToForget(move_to_learn)
      new_move = (move_to_learn) ? Pokemon::Move.new(move_to_learn) : nil
      selmove = 0
      maxmove = (new_move) ? Pokemon::MAX_MOVES : Pokemon::MAX_MOVES - 1
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if Input.trigger?(Input::BACK)
          selmove = Pokemon::MAX_MOVES
          pbPlayCloseMenuSE if new_move
          break
        elsif Input.trigger?(Input::USE)
          pbPlayDecisionSE
          break
        elsif Input.trigger?(Input::UP)
          selmove -= 1
          selmove = maxmove if selmove < 0
          if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
            selmove = @pokemon.numMoves - 1
          end
          @sprites["movesel"].index = selmove
          selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
          drawSelectedMove(new_move, selected_move)
        elsif Input.trigger?(Input::DOWN)
          selmove += 1
          selmove = 0 if selmove > maxmove
          if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
            selmove = (new_move) ? maxmove : 0
          end
          @sprites["movesel"].index = selmove
          selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
          drawSelectedMove(new_move, selected_move)
        end
      end
      return (selmove == Pokemon::MAX_MOVES) ? -1 : selmove
    end

    def pbScene
      @pokemon.play_cry
      loop do
        Graphics.update
        Input.update
        pbUpdate
        dorefresh = false
        if Input.trigger?(Input::ACTION)
          pbSEStop
          @pokemon.play_cry
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        elsif Input.trigger?(Input::USE)
          if @page == 4
            pbPlayDecisionSE
            pbMoveSelection
            dorefresh = true
          # elsif @page == 5
          #   pbPlayDecisionSE
          #   pbRibbonSelection
          #   dorefresh = true
          elsif !@inbattle
            pbPlayDecisionSE
            dorefresh = pbOptions
          end
        elsif Input.trigger?(Input::UP) && @partyindex > 0
          oldindex = @partyindex
          pbGoToPrevious
          if @partyindex != oldindex
            pbChangePokemon
            @ribbonOffset = 0
            dorefresh = true
          end
        elsif Input.trigger?(Input::DOWN) && @partyindex < @party.length - 1
          oldindex = @partyindex
          pbGoToNext
          if @partyindex != oldindex
            pbChangePokemon
            @ribbonOffset = 0
            dorefresh = true
          end
        elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
          oldpage = @page
          @page -= 1
          @page = 1 if @page < 1
          @page = 4 if @page > 4
          if @page != oldpage   # Move to next page
            pbSEPlay("GUI summary change page")
            @ribbonOffset = 0
            dorefresh = true
          end
        elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
          oldpage = @page
          @page += 1
          @page = 1 if @page < 1
          @page = 4 if @page > 4
          if @page != oldpage   # Move to next page
            pbSEPlay("GUI summary change page")
            @ribbonOffset = 0
            dorefresh = true
          end
        end
        if dorefresh
          drawPage(@page)
        end
      end
      return @partyindex
    end
  end

  #===============================================================================
  #
  #===============================================================================
  class PokemonSummaryScreen
    def initialize(scene, inbattle = false)
      @scene = scene
      @inbattle = inbattle
    end

    def pbStartScreen(party, partyindex)
      @scene.pbStartScene(party, partyindex, @inbattle)
      ret = @scene.pbScene
      @scene.pbEndScene
      return ret
    end

    def pbStartForgetScreen(party, partyindex, move_to_learn)
      ret = -1
      @scene.pbStartForgetScene(party, partyindex, move_to_learn)
      loop do
        ret = @scene.pbChooseMoveToForget(move_to_learn)
        break if ret < 0 || !move_to_learn
        break if $DEBUG || !party[partyindex].moves[ret].hidden_move?
        pbMessage(_INTL("HM moves can't be forgotten now.")) { @scene.pbUpdate }
      end
      @scene.pbEndScene
      return ret
    end

    def pbStartChooseMoveScreen(party, partyindex, message)
      ret = -1
      @scene.pbStartForgetScene(party, partyindex, nil)
      pbMessage(message) { @scene.pbUpdate }
      loop do
        ret = @scene.pbChooseMoveToForget(nil)
        break if ret >= 0
        pbMessage(_INTL("You must choose a move!")) { @scene.pbUpdate }
      end
      @scene.pbEndScene
      return ret
    end
  end

  #===============================================================================
  #
  #===============================================================================
  def pbChooseMove(pokemon, variableNumber, nameVarNumber)
    return if !pokemon
    ret = -1
    pbFadeOutIn {
      scene = PokemonSummary_Scene.new
      screen = PokemonSummaryScreen.new(scene)
      ret = screen.pbStartForgetScreen([pokemon], 0, nil)
    }
    $game_variables[variableNumber] = ret
    if ret >= 0
      $game_variables[nameVarNumber] = pokemon.moves[ret].name
    else
      $game_variables[nameVarNumber] = ""
    end
    $game_map.need_refresh = true if $game_map
  end
