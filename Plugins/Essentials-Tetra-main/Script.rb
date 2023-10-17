#===============================================================================
# * Poké Tetra - by FL based in Unknown script (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It's a variation of 
# Triple Triad minigame played on a 4x4 board with random neutral blocks and
# with a setting that allows the player to use his party as cards.
#
#== INSTALLATION ===============================================================
#
# To this script works, put it above main. Put a 512x384 background for this
# screen in "Graphics/UI/tetra_bg" location (is "Graphics/Pictures/tetra_bg" in 
# Essentials v20 and below).
#
#== HOW TO USE =================================================================
#
# This script called with pbTetraDuel and have the same arguments that
# pbTriadDuel. The rule "elements" doesn't work.
#
#== EXAMPLES ===================================================================
#
# A game versus "Hilbert", using cards between 0-4 levels.
#
#  pbTetraDuel("Hilbert",1,3)
#
# A game versus "Ethan", using cards between 0-4 levels. Player color is
# OLIVE and the opponent is ORANGE:
#
#  pbTetraDuel("Ethan",0,4,nil,nil,nil,PokeTetra::OLIVE,PokeTetra::ORANGE)
#
#== NOTES ======================================================================
#
# You can pass a seventh and eighth parameter as arrays at method 
# call for using color for the player and the opponent. Each array have
# two Color objects, the first is for the border and the second is for inside. 
# There also default color arrays constants at PokeTetra class called 
# BLUE, RED, GREEN, PINK, YELLOW, CYAN, PURPLE, ORANGE, BROWN, OLIVE, 
# DARKGREEN, DARKBLUE, WHITE and BLACK. Look the example.
#
# The cards have a +2 point when attacking a type with weakness, -2 for a 
# type with resistance and -4 for a type with immunity. To disable this,
# just use "disabletype" as one of game rules.
#
# If you inform a deck for the opponent bigger that the HAND_SIZE. The cards
# will be randomly removed until the opponent have the right number of cards.
#
# This script use some of triad classes like TriadSquare.
#
#===============================================================================

if defined?(PluginManager) && !PluginManager.installed?("Poké Tetra")
  PluginManager.register({                                                 
    :name    => "Poké Tetra",                                        
    :version => "1.1",                                                     
    :link    => "https://www.pokecommunity.com/showthread.php?t=360234",
    :credits => ["FL", "Unknown"]
  })
end

module PokeTetra
  # If true, instead of selecting your cards from your deck, the selected
  # pokémon are from your current party.
  USE_PARTY = true 
  
  # When this number of cards is on the board, the game ends and the result
  # is show.
  PLAYABLE_CARDS = 10
  
  # The hand size of each player.
  HAND_SIZE = 6
  
  # Default colors.
  # colorArrays - Border/Inside
  BLUE=[Color.new(64,64,255),Color.new(160,160,255)]
  RED=[Color.new(255,64,64),Color.new(255,160,160)]
  GREEN=[Color.new(64,255,64),Color.new(160,255,160)]
  PINK=[Color.new(255,64,255),Color.new(255,160,255)] # Magenta
  YELLOW=[Color.new(255,255,64),Color.new(255,255,160)]
  CYAN=[Color.new(64,255,255),Color.new(160,255,255)]
  PURPLE=[Color.new(128,32,128),Color.new(128,80,128)]
  ORANGE=[Color.new(255,128,32),Color.new(255,128,80)]
  BROWN=[Color.new(128,32,32),Color.new(128,80,80)]
  OLIVE=[Color.new(128,128,32),Color.new(128,128,80)]
  DARKGREEN=[Color.new(32,128,32),Color.new(80,128,80)]
  DARKBLUE=[Color.new(32,32,128),Color.new(80,80,128)]
  WHITE=[Color.new(224,224,224),Color.new(255,255,255)]
  BLACK=[Color.new(64,64,64),Color.new(160,160,160)]

  class Card
    attr_reader :north, :east, :south, :west, :type, :species
    
    WIDTH=84
    HEIGHT=84
    
    def baseStatToValue(stat)
      return 9 if stat>=190
      return 8 if stat>=150
      return 7 if stat>=120
      return 6 if stat>=100
      return 5 if stat>=80
      return 4 if stat>=65
      return 3 if stat>=50
      return 2 if stat>=35
      return 1 if stat>=20
      return 0
    end

    def attack(panel)
      return [@west,@east,@north,@south][panel]
    end

    def defense(panel)
      return [@east,@west,@south,@north][panel]
    end

    def bonus(opponent)
      return Bridge.type_effectiveness(@type, opponent.type)*2
    end

    def initialize(species)
      baseStats = Bridge.species_base_stats(species)
      @species=species
      hp=baseStatToValue(baseStats[:HP])
      attack=baseStatToValue(baseStats[:ATTACK])
      defense=baseStatToValue(baseStats[:DEFENSE])
      speed=baseStatToValue(baseStats[:SPEED])
      specialAttack=baseStatToValue(baseStats[:SPECIAL_ATTACK])
      specialDefense=baseStatToValue(baseStats[:SPECIAL_DEFENSE])
      @west=(attack>specialAttack) ? attack : specialAttack # Picks the bigger
      @east=(defense>specialDefense) ? defense : specialDefense # Same
      @north=hp
      @south=speed
      types=Bridge.species_types(species)
      @type=types[0]
      @type=types[1] if (
        types.size>1 && Bridge.compare_type(types[0], :NORMAL) && 
        !Bridge.compare_type(types[1], :NORMAL)
      )
    end

    def self.createBack(type=nil,colorArray=nil)
      bitmap=BitmapWrapper.new(WIDTH,HEIGHT)
      fillColor(bitmap,colorArray) if colorArray # noback==false
      if type
        typebitmap=AnimatedBitmap.new(Bridge.type_image_path)
        typerect=Rect.new(0,Bridge.type_icon_index(type)*28,64,28)
        bitmap.blt((WIDTH-64)/2,(HEIGHT-28)/2,typebitmap.bitmap,typerect,192)
        typebitmap.dispose
      end
      return bitmap
    end

    def createBitmap(owner,colorArray)
      return self.class.createBack(nil,colorArray) if owner==0
      bitmap=BitmapWrapper.new(WIDTH,HEIGHT)
      typebitmap=AnimatedBitmap.new(Bridge.type_image_path)
      icon=AnimatedBitmap.new(Bridge.species_icon_path(@species))
      typerect=Rect.new(0,Bridge.type_icon_index(@type)*28,64,28)
      self.class.fillColor(bitmap,colorArray)
      bitmap.blt(
        (WIDTH-64)/2,(HEIGHT-28)/2, typebitmap.bitmap,typerect,192
      )
      bitmap.blt(10,2,icon.bitmap,Rect.new(0,0,64,64))
      pbSetSmallFont(bitmap)
      Bridge.draw_text_positions(bitmap,[
        [
          "0123456789A"[@north,1],WIDTH/2,8,2,
          Color.new(248,248,248),Color.new(96,96,96)
        ],[
          "0123456789A"[@south,1],WIDTH/2,(HEIGHT-2)-18,2,
          Color.new(248,248,248),Color.new(96,96,96)
        ],[
          "0123456789A"[@west,1],2,(HEIGHT/2)-6,0,
          Color.new(248,248,248),Color.new(96,96,96)
        ],[
          "0123456789A"[@east,1],WIDTH-2,(HEIGHT/2)-6,1,
          Color.new(248,248,248),Color.new(96,96,96)
        ]
      ])
      icon.dispose
      typebitmap.dispose
      return bitmap
    end
    
    def self.createBlockBitmap
      bitmap=BitmapWrapper.new(WIDTH,HEIGHT)
      cardColor = Color.new(29,107,64)
      fillColor(bitmap,[cardColor,cardColor])
      return bitmap
    end  
    
    def self.fillColor(bitmap,colorArray)
      bitmap.fill_rect(0,0,WIDTH,HEIGHT,colorArray[0])
      bitmap.fill_rect(2,2,WIDTH-4,HEIGHT-4,colorArray[1])
    end  
  end

  # Scene class for handling appearance of the screen
  class Scene
    # Initialize the colors and the default values
    def initialize(colorArrayPlayer, colorArrayOpponent)
      @colorArrayPlayer = colorArrayPlayer
      @colorArrayOpponent = colorArrayOpponent
      if !@colorArrayPlayer || (
        @colorArrayPlayer==@colorArrayOpponent && @colorArrayPlayer==RED
      )
        @colorArrayPlayer = BLUE 
      end
      if !@colorArrayOpponent || (
        @colorArrayPlayer==@colorArrayOpponent && @colorArrayPlayer==BLUE
      )
        @colorArrayOpponent = RED 
      end
    end  
    
    # Update the scene here, this is called once each frame
    def pbUpdate
      pbUpdateSpriteHash(@sprites)
    end

    # End the scene here
    def pbEndScene
      pbBGMFade(1.0)
      # Fade out all sprites
      pbFadeOutAndHide(@sprites) { pbUpdate }
      # Dispose all sprites
      pbDisposeSpriteHash(@sprites)
      @bitmaps.each{|bm| bm.dispose }
      # Dispose the viewport
      @viewport.dispose
    end

    FIELD_BASE_X = 88
    FIELD_BASE_Y = 46
    HAND_BASE_Y = 34
    HAND_BONUS_Y = 48
    OPPONENT_HAND_BASE_X = 2

    # To correctly get width
    def playerHandBaseX
      return Graphics.width-Card::WIDTH-2
    end
    
    def pbStartScene(battle)
      # Create sprite hash
      @sprites={}
      @bitmaps=[]
      @battle=battle
      # Allocate viewport
      @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z=99999
      addBackgroundPlane(@sprites,"background","tetra_bg",@viewport)
      @sprites["helpwindow"]=Window_AdvancedTextPokemon.newWithSize(
        "",0,Graphics.height-64,Graphics.width,64,@viewport
      )
      for i in 0...@battle.width*@battle.height
        @sprites["sprite#{i}"]=Sprite.new(@viewport)
        cardX=FIELD_BASE_X + (i % @battle.width)*Card::WIDTH
        cardY=FIELD_BASE_Y + (i / @battle.width)*Card::HEIGHT
        @sprites["sprite#{i}"].z=2
        @sprites["sprite#{i}"].x=cardX
        @sprites["sprite#{i}"].y=cardY
        bm=Card.createBack(@battle.board[i].type)
        @bitmaps.push(bm)
        @sprites["sprite#{i}"].bitmap=bm
      end
      @cardBitmaps=[]
      @opponentCardBitmaps=[]
      @cardIndexes=[]
      @opponentCardIndexes=[]
      @boardSprites=[]
      @boardCards=[]
      for i in 0...HAND_SIZE
        @sprites["player#{i}"]=Sprite.new(@viewport)
        @sprites["player#{i}"].z=2
        @sprites["player#{i}"].x=playerHandBaseX
        @sprites["player#{i}"].y=HAND_BASE_Y+6+16*i
        @cardIndexes.push(i)
      end
      @sprites["overlay"]=Sprite.new(@viewport)
      @sprites["overlay"].bitmap=BitmapWrapper.new(
        Graphics.width,Graphics.height
      )
      pbSetSystemFont(@sprites["overlay"].bitmap)
      Bridge.draw_text_positions(@sprites["overlay"].bitmap,[
        [
          @battle.opponentName,54,6,2,
          Color.new(248,248,248),Color.new(96,96,96)
        ],[
          @battle.playerName,Graphics.width-54,6,2,
          Color.new(248,248,248),Color.new(96,96,96)
        ]
      ])
      @sprites["score"]=Sprite.new(@viewport)
      @sprites["score"].bitmap=BitmapWrapper.new(Graphics.width,Graphics.height)
      pbSetSystemFont(@sprites["score"].bitmap)
      pbBGMPlay(Bridge.bgm_path)
      # Fade in all sprites
      pbFadeInAndShow(@sprites) { pbUpdate }
    end

    def pbUpdateScore
      bitmap=@sprites["score"].bitmap
      bitmap.clear
      playerscore=0
      oppscore=0
      for i in 0...@battle.width*@battle.height
        if @boardSprites[i]
          playerscore+=1 if @battle.board[i].owner==1
          oppscore+=1 if @battle.board[i].owner==2
        end
      end
      if @battle.countUnplayedCards
        playerscore+=@cardIndexes.length
        oppscore+=@opponentCardIndexes.length
      end
      Bridge.draw_text_positions(bitmap,[[
        _INTL("{1}-{2}",oppscore,playerscore),Graphics.width/2,6,2,
        Color.new(248,248,248),Color.new(96,96,96)
      ]])
    end

    def pbNotifyCards(playerCards,opponentCards)
      @playerCards=playerCards
      @opponentCards=opponentCards
    end

    def pbDisplay(text)
      @sprites["helpwindow"].visible=true
      @sprites["helpwindow"].text=text
      60.times do
        Graphics.update
        Input.update
        pbUpdate
      end
    end

    def pbDisplayPaused(text)
      @sprites["helpwindow"].letterbyletter=true
      @sprites["helpwindow"].text=text+"\1"
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if Input.trigger?(Input::C)
          if @sprites["helpwindow"].busy?
            pbPlayDecisionSE() if @sprites["helpwindow"].pausing?
            @sprites["helpwindow"].resume
          else
            break
          end
        end
      end
      @sprites["helpwindow"].letterbyletter=false
      @sprites["helpwindow"].text=""
    end
    
    def pbWindowVisible(visible)
      @sprites["helpwindow"].visible=visible
    end  

    def pbShowPlayerCards(cards)
      for i in 0...HAND_SIZE
        @sprites["player#{i}"]=Sprite.new(@viewport)
        @sprites["player#{i}"].z=2
        @sprites["player#{i}"].x=playerHandBaseX
        @sprites["player#{i}"].y=HAND_BASE_Y+HAND_BONUS_Y*i
        @sprites["player#{i}"].bitmap=Card.new(cards[i]).createBitmap(
          1,colorArrayPlayer
        )
        @cardBitmaps.push(@sprites["player#{i}"].bitmap)
      end
    end

    def pbShowOpponentCards(cards)
      for i in 0...HAND_SIZE
        @sprites["opponent#{i}"]=Sprite.new(@viewport)
        @sprites["opponent#{i}"].z=2
        @sprites["opponent#{i}"].x=OPPONENT_HAND_BASE_X
        @sprites["opponent#{i}"].y=HAND_BASE_Y+HAND_BONUS_Y*i
        @sprites["opponent#{i}"].bitmap= (
          @battle.openHand ? 
          Card.new(cards[i]).createBitmap(2,@colorArrayOpponent) : 
          Card.createBack(nil,@colorArrayOpponent)
        )
        @opponentCardBitmaps.push(@sprites["opponent#{i}"].bitmap)
        @opponentCardIndexes.push(i)
      end
    end

    def pbViewOpponentCards(numCards)
      choice=0
      lastChoice=-1
      loop do
        if lastChoice!=choice
          y=HAND_BASE_Y
          for i in 0...@opponentCardIndexes.length
            index = @opponentCardIndexes[i]
            @sprites["opponent#{index}"].bitmap =@opponentCardBitmaps[index]
            @sprites["opponent#{index}"].z=(i==choice) ? 4 : 2
            @sprites["opponent#{index}"].x=(
              i==choice ? OPPONENT_HAND_BASE_X+22 : OPPONENT_HAND_BASE_X
            )
            @sprites["opponent#{index}"].y=y
            y+=HAND_BONUS_Y
          end
          lastChoice=choice
        end
        if choice==-1
          break
        end
        Graphics.update
        Input.update
        pbUpdate
        if Input.repeat?(Input::DOWN)
          pbPlayCursorSE()
          choice+=1
          choice=0 if choice>=numCards
        elsif Input.repeat?(Input::UP)
          pbPlayCursorSE()
          choice-=1
          choice=numCards-1 if choice<0
        elsif Input.trigger?(Input::B)
          pbPlayCancelSE()
          choice=-1
        end
      end
      return choice
    end

    def pbPlayerChooseCard(numCards)
      pbWindowVisible(false)
      choice=0
      lastChoice=-1
      loop do
        if lastChoice!=choice
          y=HAND_BASE_Y
          for i in 0...@cardIndexes.length
            @sprites["player#{@cardIndexes[i]}"].bitmap=@cardBitmaps[
              @cardIndexes[i]
            ]
            @sprites["player#{@cardIndexes[i]}"].z=(i==choice) ? 4 : 2
            @sprites["player#{@cardIndexes[i]}"].x=(
              i==choice ? playerHandBaseX-32 : playerHandBaseX
            )
            @sprites["player#{@cardIndexes[i]}"].y=y
            y+=HAND_BONUS_Y
          end
          lastChoice=choice
        end
        Graphics.update
        Input.update
        pbUpdate
        if Input.repeat?(Input::DOWN)
          pbPlayCursorSE()
          choice+=1
          choice=0 if choice>=numCards
        elsif Input.repeat?(Input::UP)
          pbPlayCursorSE()
          choice-=1
          choice=numCards-1 if choice<0
        elsif Input.trigger?(Input::C)
          pbPlayDecisionSE()
          break
        elsif Input.trigger?(Input::A) && @battle.openHand
          pbPlayDecisionSE()
          pbViewOpponentCards(numCards)
          pbWindowVisible(false)
          choice=0
          lastChoice=-1
        end
      end
      return choice
    end

    def pbRefresh
      for i in 0...@battle.width*@battle.height
        x=i % @battle.width
        y=i / @battle.width
        if @boardSprites[i]
          owner=@battle.getOwner(x,y)
          @boardSprites[i].bitmap.dispose if @boardSprites[i].bitmap
          @boardSprites[i].bitmap = (
            @boardCards[i] ? 
            @boardCards[i].createBitmap(owner, owner==2 ? @colorArrayOpponent : 
            @colorArrayPlayer) : Card.createBlockBitmap
          )
        end
      end
    end

    def pbEndPlaceCard(position, cardIndex)
      spriteIndex=@cardIndexes[cardIndex]
      boardIndex=position[1]*@battle.width+position[0]
      @boardSprites[boardIndex]=@sprites["player#{spriteIndex}"]
      @boardCards[boardIndex]=Card.new(@playerCards[spriteIndex])
      pbRefresh
      @cardIndexes.delete_at(cardIndex)
      pbUpdateScore
    end

    def pbEndOpponentPlaceCard(position, cardIndex)
      spriteIndex=@opponentCardIndexes[cardIndex]
      boardIndex=position[1]*@battle.width+position[0]
      @boardSprites[boardIndex]=@sprites["opponent#{spriteIndex}"]
      @boardCards[boardIndex]=Card.new(@opponentCards[spriteIndex])
      pbRefresh
      @opponentCardIndexes.delete_at(cardIndex)
      pbUpdateScore
    end
    
    def pbPutBlockCards(blockArray)
      for i in 0...blockArray.size
        spriteIndex=i
        boardIndex=blockArray[i]
        @sprites["block#{spriteIndex}"]=Sprite.new(@viewport)
        @sprites["block#{spriteIndex}"].z=2
        @sprites["block#{spriteIndex}"].x=FIELD_BASE_X + Card::WIDTH*(
          boardIndex % @battle.width
        )
        @sprites["block#{spriteIndex}"].y=FIELD_BASE_Y + Card::HEIGHT*(
          boardIndex/@battle.width
        )
        @boardSprites[boardIndex]=@sprites["block#{spriteIndex}"]
      end  
      pbRefresh
    end

    def pbOpponentPlaceCard(card, position, cardIndex)
      y=HAND_BASE_Y
      for i in 0...@opponentCardIndexes.length
        sprite=@sprites["opponent#{@opponentCardIndexes[i]}"]
        if i!=cardIndex
          sprite.z=2
          sprite.y=y
          sprite.x=OPPONENT_HAND_BASE_X
          y+=HAND_BONUS_Y
        else
          @opponentCardBitmaps[@opponentCardIndexes[i]]=card.createBitmap(
            2,@colorArrayOpponent
          )
          sprite.bitmap.dispose if sprite.bitmap
          sprite.bitmap=@opponentCardBitmaps[@opponentCardIndexes[i]]
          sprite.z=2
          sprite.x=FIELD_BASE_X + position[0]*Card::WIDTH
          sprite.y=FIELD_BASE_Y + position[1]*Card::HEIGHT
        end
      end
    end

    def pbPlayerPlaceCard(card, cardIndex)
      boardX=0
      boardY=0
      doRefresh=true
      loop do
        if doRefresh
          y=HAND_BASE_Y
          for i in 0...@cardIndexes.length
            if i!=cardIndex
              @sprites["player#{@cardIndexes[i]}"].z=2
              @sprites["player#{@cardIndexes[i]}"].y=y
              @sprites["player#{@cardIndexes[i]}"].x=playerHandBaseX
              y+=HAND_BONUS_Y
            else
              @sprites["player#{@cardIndexes[i]}"].z=4
              @sprites["player#{@cardIndexes[i]}"].x=(
                FIELD_BASE_X + boardX*Card::WIDTH
              )
              @sprites["player#{@cardIndexes[i]}"].y=(
                FIELD_BASE_Y + boardY*Card::HEIGHT
              )
            end
          end
          doRefresh=false
        end
        Graphics.update
        Input.update
        pbUpdate
        if Input.repeat?(Input::DOWN)
          pbPlayCursorSE()
          boardY+=1
          boardY=0 if boardY>=@battle.height
          doRefresh=true
        elsif Input.repeat?(Input::UP)
          pbPlayCursorSE()
          boardY-=1
          boardY=@battle.height-1 if boardY<0
          doRefresh=true
        elsif Input.repeat?(Input::LEFT)
          pbPlayCursorSE()
          boardX-=1
          boardX=@battle.width-1 if boardX<0
          doRefresh=true
        elsif Input.repeat?(Input::RIGHT)
          pbPlayCursorSE()
          boardX+=1
          boardX=0 if boardX>=@battle.width
          doRefresh=true
        elsif Input.trigger?(Input::B)
          return nil
        elsif Input.trigger?(Input::C)
          if @battle.isOccupied?(boardX,boardY)
            pbPlayBuzzerSE()
          else
            pbPlayDecisionSE()
            @sprites["player#{@cardIndexes[cardIndex]}"].z=2
            break
          end
        end
      end
      return [boardX,boardY] 
    end

    def pbChooseCard(cardStorage)
      commands=[]
      chosenCards=[]
      for item in cardStorage
        commands.push(_INTL("{1} x{2}",Bridge.species_name(item[0]),item[1]))
      end
      command=Window_CommandPokemonEx.newWithSize(
        commands,0,0,256,Graphics.height-64,@viewport
      )
      @sprites["helpwindow"].text=_INTL(
        "Choose {1} cards to use for this duel.",HAND_SIZE
      )
      preview=Sprite.new(@viewport)
      preview.z=4
      preview.x=276
      preview.y=60
      index=-1
      for i in 0...HAND_SIZE
        @sprites["player#{i}"]=Sprite.new(@viewport)
        @sprites["player#{i}"].z=2
        @sprites["player#{i}"].x=playerHandBaseX
        @sprites["player#{i}"].y=HAND_BASE_Y+HAND_BONUS_Y*i
      end
      loop do
        Graphics.update
        Input.update
        pbUpdate
        command.update
        if command.index!=index
          preview.bitmap.dispose if preview.bitmap
          if command.index<cardStorage.length
            item=cardStorage[command.index]
            preview.bitmap=Card.new(item[0]).createBitmap(1,@colorArrayPlayer)
          end
          index=command.index
        end
        if Input.trigger?(Input::B)
          if chosenCards.length>0
            item=chosenCards.pop
            @battle.pbAdd(cardStorage,item)
            commands=[]
            for item in cardStorage
              commands.push(
                _INTL("{1} x{2}",Bridge.species_name(item[0]),item[1])
              )
            end
            command.commands=commands
            index=-1
          else
            pbPlayBuzzerSE()
          end
        elsif Input.trigger?(Input::C)
          if chosenCards.length==HAND_SIZE
            break
          end
          item=cardStorage[command.index]
          if !item || (@battle.pbQuantity(cardStorage,item[0])==0)
            pbPlayBuzzerSE()
          else
            pbPlayDecisionSE()
            sprite=@sprites["player#{chosenCards.length}"]
            sprite.bitmap.dispose if sprite.bitmap
            @cardBitmaps[chosenCards.length]=Card.new(
              item[0]).createBitmap(1,@colorArrayPlayer
            )
            sprite.bitmap=@cardBitmaps[chosenCards.length]
            chosenCards.push(item[0])
            @battle.pbSubtract(cardStorage,item[0])
            commands=[]
            for item in cardStorage
              commands.push(
                _INTL("{1} x{2}",Bridge.species_name(item[0]),item[1])
              )
            end
            command.commands=commands
            command.index=commands.length-1 if command.index>=commands.length
            index=-1
          end
        end
        if Input.trigger?(Input::C) || Input.trigger?(Input::B)
          for i in 0...HAND_SIZE
            @sprites["player#{i}"].visible=(i<chosenCards.length)
          end
          if chosenCards.length==HAND_SIZE
            @sprites["helpwindow"].text=_INTL(
              "{1} cards have been chosen.",HAND_SIZE
            )
            command.visible=false
            command.active=false
            preview.visible=false
          else
            @sprites["helpwindow"].text=_INTL(
              "Choose {1} cards to use for this duel.",HAND_SIZE
            )
            command.visible=true
            command.active=true
            preview.visible=true
          end
        end
      end
      command.dispose
      preview.bitmap.dispose if preview.bitmap
      preview.dispose
      return chosenCards
    end
    
    def pbAutoSetCard(cardStorage)
      chosenCards=[]
      i=0
      for item in cardStorage
        item[1].times do
          @sprites["player#{i}"]=Sprite.new(@viewport)
          @sprites["player#{i}"].z=2
          @sprites["player#{i}"].x=playerHandBaseX
          @sprites["player#{i}"].y=HAND_BASE_Y+HAND_BONUS_Y*i
          #@sprites["player#{i}"].dispose if @sprites["player#{i}"].bitmap
          @cardBitmaps[chosenCards.length]=Card.new(item[0]).createBitmap(
            1,@colorArrayPlayer
          )
          @sprites["player#{i}"].bitmap=@cardBitmaps[chosenCards.length]
          chosenCards.push(item[0])
          #@battle.pbSubtract(cardStorage,item[0])
          i+=1
        end
      end
      return chosenCards
    end
  end

  # Screen class for handling game logic
  class Screen
    attr_accessor :openHand,:countUnplayedCards
    attr_reader :width,:height

    def initialize(scene)
      @scene=scene
      @width              = 4
      @height             = 4
      @sameWins           = false
      @openHand           = false
      @wrapAround         = false
      @randomHand         = false
      @countUnplayedCards = false
      @disableTypeBonus   = false
      @trade              = 0
    end

    def board
      @board
    end

    def playerName
      @playerName
    end

    def opponentName
      @opponentName
    end

    def isOccupied?(x,y)
      return @board[y*@width+x].owner!=0
    end

    def getOwner(x,y)
      return @board[y*@width+x].owner
    end

    def getPanel(x,y)
      return @board[y*@width+x]
    end

    def pbQuantity(items,item)
      return Bridge.storage_quantity_triad_card(
        items, $PokemonGlobal.triads.maxSize, item
      )
    end

    def pbAdd(items,item)
      return Bridge.storage_add_triad_card(
        items,$PokemonGlobal.triads.maxSize,TriadStorage::MAX_PER_SLOT,item,1
      )
    end

    def pbSubtract(items,item)
      return Bridge.storage_remove_triad_card(
        items, $PokemonGlobal.triads.maxSize, item, 1
      )
    end
      
    def maxSize
      return Bridge.species_count
    end

    def maxPerSlot
      return 99
    end

    def flipBoard(x,y,attackerParam=nil,recurse=false)
      panels=[x-1,y,x+1,y,x,y-1,x,y+1]
      panels[0]=(@wrapAround ? @width-1 : 0) if panels[0]<0 # left
      panels[2]=(@wrapAround ? 0 : @width-1) if panels[2]>@width-1 # right
      panels[5]=(@wrapAround ? @height-1 : 0) if panels[5]<0 # top
      panels[7]=(@wrapAround ? 0 : @height-1) if panels[7]>@height-1 # bottom
      attacker=attackerParam!=nil ? attackerParam : @board[y*@width+x]
      flips=[]
      return nil if attackerParam!=nil && @board[y*@width+x].owner!=0
      return nil if !attacker.card || attacker.owner==0
      for i in 0...4
        defenderX=panels[i*2]
        defenderY=panels[i*2+1]
        defender=@board[defenderY*@width+defenderX]
        next if !defender.card
        if attacker.owner!=defender.owner
          attack=attacker.attack(i)
          defense=defender.defense(i)
          attack+=attacker.bonus(defender) if !@disableTypeBonus # Type bonus
          if attack>defense || (attack==defense && @sameWins)
            flips.push([defenderX,defenderY])
            if attackerParam==nil
              defender.owner=attacker.owner
              if @sameWins
                # Combo with the "sameWins" rule
                ret=flipBoard(defenderX,defenderY,nil,true)
                flips.concat(ret) if ret
              end
            else
              if @sameWins
                # Combo with the "sameWins" rule
                ret=flipBoard(defenderX,defenderY,attackerParam,true)
                flips.concat(ret) if ret
              end
            end
          end
        end
      end
      return flips
    end
    
    def blockPlacement(blockNumber=nil)
      blockNumber = rand(@width*@height-PLAYABLE_CARDS+1) if !blockNumber
      blockIndexArray=[]  
      while blockIndexArray.size<blockNumber
        index=rand(@board.size)
        blockIndexArray.push(index) if !blockIndexArray.include?(index)
      end
      blockArray2=[]
      # Checks if a square is alone. If so, redo the method (except the 
      # blockNumber). Uses a bidimensional array for easily manipulation
      for i in 0...@height
        blockArray2[i]=[]
        for j in 0...@width
          blockArray2[i][j]=blockIndexArray.include?(@height*i+j)
        end 
      end
      for i in 0...@height
        for j in 0...@width
          # If is a square, checks the 4 positions. Ignores the @wrapAround rule
          if !blockArray2[i][j] && ( 
              (i==0 || blockArray2[i-1][j]) && # Checks up
              (i==@height-1 || blockArray2[i+1][j]) && # Checks down
              (j==0 || blockArray2[i][j-1]) && # Checks left
              (j==@width-1 || blockArray2[i][j+1])) # Checks right
            blockPlacement(blockNumber)  
            return    
          end   
        end 
      end
      # End of checking
      for blockIndex in blockIndexArray
        square=TriadSquare.new
        square.owner=-1
        @board[blockIndex]=square  
      end  
      @scene.pbPutBlockCards(blockIndexArray)
    end  

  # If pbStartScreen includes parameters, it should
  # pass the parameters to pbStartScene.
    def pbStartScreen(opponentName,minLevel,maxLevel,
        rules=nil,oppdeck=nil,prize=nil)
      if minLevel<0 || minLevel>9
        raise _INTL("Minimum level must be 0 through 9.")
      end
      if maxLevel<0 || maxLevel>9
        raise _INTL("Maximum level must be 0 through 9.")
      end
      if maxLevel<minLevel
        raise _INTL("Maximum level shouldn't be less than the minimum level.")
      end
      if rules && rules.is_a?(Array) && rules.length>0
        for rule in rules
          @sameWins           = true if rule=="samewins"
          @openHand           = true if rule=="openhand"
          @wrapAround         = true if rule=="wrap"
          @randomHand         = true if rule=="randomhand"
          @countUnplayedCards = true if rule=="countunplayed"
          @disableTypeBonus   = true if rule=="disabletype" # Disable type bonus
          @trade              = 1    if rule=="direct"
          @trade              = 2    if rule=="winall"
        end
      end
      @cards=[]
      count=0
      if USE_PARTY
        for pokemon in Bridge.player.party
          if !pokemon.egg?
            Bridge.storage_add_triad_card(
              @cards,maxSize,maxPerSlot,pokemon.species,1
            )
            count+=1
          end          
        end  
      else  
        if !$PokemonGlobal
          $PokemonGlobal=PokemonGlobalMetadata.new
        end
        for i in 0...$PokemonGlobal.triads.length
          item=$PokemonGlobal.triads[i]
          Bridge.storage_add_triad_card(
            @cards,maxSize,maxPerSlot,item[0],item[1]
          )
          count+=item[1] # Add item count to total count
        end
      end
      @board=[]
      @playerName=Bridge.player.name
      @opponentName=opponentName
      for i in 0...@width*@height
        @board.push(TriadSquare.new)
      end
      @scene.pbStartScene(self) # (param1, param2)
      # Check whether there are enough cards.
      if count<HAND_SIZE
        @scene.pbDisplayPaused(_INTL("You don't have enough cards."))
        @scene.pbEndScene
        return 0
      end
      # Set the player's cards.
      cards=[]
      if @randomHand   # Determine hand at random
        HAND_SIZE.times do
          randCard=@cards[rand(@cards.length)]
          pbSubtract(@cards,randCard[0])
          cards.push(randCard[0]) 
        end
        @scene.pbShowPlayerCards(cards)
      else
        if USE_PARTY && HAND_SIZE>6
          raise _INTL("HAND_SIZE cannot be bigger than 6 when USE_PARTY=true")
        elsif USE_PARTY && HAND_SIZE==6
          # When HAND_SIZE it's 6 and USE_PARTY, just copy the party
          cards=@scene.pbAutoSetCard(@cards)
        else  
          cards=@scene.pbChooseCard(@cards)
        end
      end
      # Set the opponent's cards.
      if oppdeck && oppdeck.is_a?(Array) && oppdeck.length>=HAND_SIZE
        # If the oppdeck is bigger that the HAND_SIZE,
        # remove random pokémon until the size is right 
        while oppdeck.length>HAND_SIZE
          oppdeck.delete_at(rand(oppdeck.length))
        end  
        opponentCards=[]
        for i in oppdeck
          card=Bridge.species(i)
          if !card
            @scene.pbDisplayPaused(
              _INTL("Opponent has an illegal card, \"{1}\".",i)
            )
            @scene.pbEndScene
            return nil
          end
          opponentCards.push(card)
        end
      else
        candidates=[]
        while candidates.length<200
          card=Bridge.random_species
          tetra=Card.new(card)
          total=tetra.north+tetra.south+tetra.east+tetra.west
          # Add random species and its total point count
          candidates.push([card,total])
        end
        # sort by total point count
        candidates.sort!{|a,b| a[1]<=>b[1] }
        minIndex=minLevel*20
        maxIndex=maxLevel*20+20
        opponentCards=[]
        for i in 0...HAND_SIZE
          # generate random card based on level
          index=minIndex+rand(maxIndex-minIndex)
          opponentCards.push(candidates[index][0])
        end
      end
      originalCards=cards.clone
      originalOpponentCards=opponentCards.clone
      @scene.pbNotifyCards(cards.clone,opponentCards.clone)
      @scene.pbShowOpponentCards(opponentCards)
      blockPlacement
      @scene.pbDisplay(_INTL("Choosing the starting player..."))
      @scene.pbUpdateScore
      playerTurn=false
      if rand(2)==0
        @scene.pbDisplay(_INTL("{1} will go first.",@playerName))
        playerTurn=true
      else
        @scene.pbDisplay(_INTL("{1} will go first.",@opponentName))
        playerTurn=false
      end
      for i in 0...PLAYABLE_CARDS
        position=nil
        card=nil
        cardIndex=0
        if playerTurn
          # Player's turn
          while !position
            cardIndex=@scene.pbPlayerChooseCard(cards.length)
            card=Card.new(cards[cardIndex])
            position=@scene.pbPlayerPlaceCard(card,cardIndex)
          end
        else
          # Opponent's turn
          @scene.pbDisplay(_INTL("{1} is making a move...",@opponentName))    
          scores=[]
          for cardIndex in 0...opponentCards.length
            square=TriadSquare.new
            square.card=Card.new(opponentCards[cardIndex])
            square.owner=2
            for i in 0...@width*@height
              x=i%@width
              y=i/@width
              square.type=@board[i].type
              flips=flipBoard(x,y,square)
              if flips!=nil
                scores.push([cardIndex,x,y,flips.length])
              end
            end
          end
          # Sort by number of flips
          scores.sort!{|a,b| 
            if b[3]==a[3]
              next [-1,1,0][rand(3)]
            else
              next b[3]<=>a[3]
            end
          } 
          scores=scores[0,opponentCards.length*3/2] # Get the best results
          if scores.length==0
            @scene.pbDisplay(_INTL("{1} can't move somehow...",@opponentName))
            playerTurn=!playerTurn
            continue
          end
          bestScore = scores[0][3]
          result=nil
          while !result
            result=scores[rand(scores.length)]
            # A random chance of not choosing the best result
            result=nil if result[3]<bestScore && rand(10)!=0
          end  
          cardIndex=result[0]
          card=Card.new(opponentCards[cardIndex])
          position=[result[1],result[2]]
          @scene.pbOpponentPlaceCard(card,position,cardIndex)
        end
        boardIndex=position[1]*@width+position[0]
        board[boardIndex].card=card
        board[boardIndex].owner=playerTurn ? 1 : 2
        flipBoard(position[0],position[1])
        if playerTurn
          cards.delete_at(cardIndex)
          @scene.pbEndPlaceCard(position,cardIndex)
        else
          opponentCards.delete_at(cardIndex)
          @scene.pbEndOpponentPlaceCard(position,cardIndex)
        end
        playerTurn=!playerTurn
      end
      # Determine the winner
      playerCount=0
      opponentCount=0
      for i in 0...@width*@height
        playerCount+=1 if board[i].owner==1
        opponentCount+=1 if board[i].owner==2
      end
      if @countUnplayedCards
        playerCount+=cards.length
        opponentCount+=opponentCards.length
      end
      @scene.pbWindowVisible(true)
      result=0
      if playerCount==opponentCount
        @scene.pbDisplayPaused(_INTL("The game is a draw."))
        result=3
        if !USE_PARTY
          case @trade
          when 1
            # Keep only cards of your color
            for card in originalCards
              Bridge.remove_triad_card(card)
            end
            for i in cards
              PokeTetra.add_triad_card(i)
            end
            for i in 0...@width*@height
              if board[i].owner==1
                PokeTetra.add_triad_card(board[i].card.species)
              end
            end
            @scene.pbDisplayPaused(_INTL("Kept all cards of your color."))
          end
        end  
      elsif playerCount>opponentCount
        @scene.pbDisplayPaused(_INTL("{1} won against {2}.",
            @playerName,@opponentName))
        result=1
        if !USE_PARTY
          if prize
            card=Bridge.species(prize)
            if card && Bridge.add_triad_card(card)
              cardname=Bridge.species_name(card)
              @scene.pbDisplayPaused(_INTL("Got opponent's {1} card.",cardname))
            end
          else
            case @trade
              when 0
                # Gain 1 random card from opponent's deck
                card=originalOpponentCards[rand(originalOpponentCards.length)]
                if Bridge.add_triad_card(card)
                  cardname=Bridge.species_name(card)
                  @scene.pbDisplayPaused(
                      _INTL("Got opponent's {1} card.",cardname))
                end
              when 1
                # Keep only cards of your color
                for card in originalCards
                  Bridge.remove_triad_card(card)
                end
                for i in cards
                  PokeTetra.add_triad_card(i)
                end
                for i in 0...@width*@height
                  if board[i].owner==1
                    PokeTetra.add_triad_card(board[i].card.species)
                  end
                end
                @scene.pbDisplayPaused(_INTL("Kept all cards of your color."))
              when 2
                # Gain all opponent's cards
                for card in originalOpponentCards
                  Bridge.add_triad_card(card)
                end
                @scene.pbDisplayPaused(_INTL("Got all opponent's cards."))
            end
          end
        end  
      else
        @scene.pbDisplayPaused(
          _INTL("{1} lost against {2}.",@playerName,@opponentName)
        )
        result=2
        if !USE_PARTY
          case @trade
          when 0
            # Lose 1 random card from your deck
            card=originalCards[rand(originalCards.length)]
            Bridge.remove_triad_card(card)
            cardname=Bridge.species_name(card)
            @scene.pbDisplayPaused(
              _INTL("Opponent won your {1} card.",cardname)
            )
          when 1
            # Keep only cards of your color
            for card in originalCards
              Bridge.remove_triad_card(card)
            end
            for i in cards
              PokeTetra.add_triad_card(i)
            end
            for i in 0...@width*@height
              if board[i].owner==1
                PokeTetra.add_triad_card(board[i].card.species)
              end
            end
            @scene.pbDisplayPaused(
                _INTL("Kept all cards of your color.",cardname))
          when 2
            # Lose all your cards
            for card in originalCards
              Bridge.remove_triad_card(card)
            end
            @scene.pbDisplayPaused(_INTL("Opponent won all your cards."))
          end  
        end
      end
      @scene.pbEndScene
      return result
    end
  end

  module Bridge
    module_function

    def major_version
      ret = 0
      if defined?(Essentials)
        ret = Essentials::VERSION.split(".")[0].to_i
      elsif defined?(ESSENTIALS_VERSION)
        ret = ESSENTIALS_VERSION.split(".")[0].to_i
      elsif defined?(ESSENTIALSVERSION)
        ret = ESSENTIALSVERSION.split(".")[0].to_i
      end
      return ret
    end

    MAJOR_VERSION = major_version

    def player
      return $Trainer if MAJOR_VERSION < 20
      return $player
    end

    def species(species)
      return getConst(PBSpecies,species) if MAJOR_VERSION < 19
      return species
    end

    def random_species
      return rand(PBSpecies.maxValue)+1 if MAJOR_VERSION < 19
      random_species_array = create_random_species_array_v19_plus
      return random_species_array[rand(random_species_array.size)]
    end    
    
    def create_random_species_array_v19_plus
      ret =[]
      GameData::Species.each_species{ |species| ret.push(species.id)}
      return ret
    end

    def species_name(species)
      return PBSpecies.getName(getID(PBSpecies, species)) if MAJOR_VERSION < 19
      return GameData::Species.get(species).name
    end

    def species_base_stats(species)
      if MAJOR_VERSION < 19
        ret = {}
        dexdata=pbOpenDexData
        pbDexDataOffset(dexdata,species,10)
        for s in [:HP,:ATTACK,:DEFENSE,:SPEED,:SPECIAL_ATTACK,:SPECIAL_DEFENSE]
          ret[s] = dexdata.fgetb
        end
        dexdata.close
        return ret
      end
      return GameData::Species.get(species).base_stats
    end

    def species_types(species)
      if MAJOR_VERSION < 19
        dexdata=pbOpenDexData
        pbDexDataOffset(dexdata,species,8)
        ret = [dexdata.fgetb, dexdata.fgetb]
        ret.pop if !ret[1] || ret[0] == ret[1]
        dexdata.close
        return ret
      end
      return GameData::Species.get(species).types
    end

    def species_count
      return PBSpecies.getCount if MAJOR_VERSION < 19
      return GameData::Species.count
    end

    def species_icon_path(species)
      if MAJOR_VERSION < 19
        return pbCheckPokemonIconFiles([species,0,false,0,false])
      end
      return GameData::Species.icon_filename(species)
    end

    def compare_type(type1, type2)
      if MAJOR_VERSION < 19
        return type1==type2 || (
          getConst(PBTypes,type1) == getConst(PBTypes,type2) && 
          getConst(PBTypes,type1) != nil
        ) || getConst(PBTypes,type1)==type2 || type1==getConst(PBTypes,type2)
      end
      return type1==type2
    end

    def type_effectiveness(attacker_type, opponent_type)
      if MAJOR_VERSION < 19
        return type_effectiveness_v18_minus(attacker_type, opponent_type)
      end
      return type_effectiveness_v19_plus(attacker_type, opponent_type)
    end
    
    def type_effectiveness_v18_minus(attacker_type, opponent_type)
      return case PBTypes.getEffectiveness(attacker_type,opponent_type)
        when 0; -2
        when 1; -1
        when 4; 1
        else; 0
      end
    end
    
    def type_effectiveness_v19_plus(attacker_type, opponent_type)
      effectiveness = Effectiveness.calculate(attacker_type, opponent_type)
      if Effectiveness.ineffective?(effectiveness)
        return -2
      elsif Effectiveness.not_very_effective?(effectiveness)
        return -1
      elsif Effectiveness.super_effective?(effectiveness)
        return 1
      end
      return 0
    end

    def type_image_path
      return _INTL("Graphics/Pictures/types") if MAJOR_VERSION < 21
      return _INTL("Graphics/UI/types")
    end

    def type_icon_index(type)
      return type if MAJOR_VERSION < 19
      return GameData::Type.get(type).icon_position
    end

    def add_triad_card(card)
      if MAJOR_VERSION < 19
        $PokemonGlobal.triads.pbStoreItem(card)
        return
      end
      $PokemonGlobal.triads.add(card)
    end

    def remove_triad_card(card)
      if MAJOR_VERSION < 19
        $PokemonGlobal.triads.pbDeleteItem(card)
        return
      end
      $PokemonGlobal.triads.remove(card)
    end

    def storage_add_triad_card(items,maxSize,maxPerSlot,item,qty)
      if MAJOR_VERSION < 19
        return ItemStorageHelper.pbStoreItem(items,maxSize,maxPerSlot,item,qty)
      end
      return ItemStorageHelper.add(items, maxSize, maxPerSlot, item, qty)
    end

    def storage_remove_triad_card(items,maxSize,item,qty)
      if MAJOR_VERSION < 19
        return ItemStorageHelper.pbDeleteItem(items,maxSize,item,qty)
      end
      return ItemStorageHelper.remove(items, item, qty)
    end

    def storage_quantity_triad_card(items,maxSize,item)
      if MAJOR_VERSION < 19
        return ItemStorageHelper.pbQuantity(items,maxSize,item)
      end
      return ItemStorageHelper.quantity(items, item)
    end
    
    def draw_text_positions(bitmap,textPos)
      if MAJOR_VERSION < 20
        for single_text_pos in textPos
          single_text_pos[2] -= MAJOR_VERSION==19 ? 12 : 6
        end
      end
      return pbDrawTextPositions(bitmap,textPos)
    end

    def bgm_path
      return "021-Field04" if MAJOR_VERSION < 17
      return "Triple Triad"
    end
  end
end

def pbTetraDuel(
  name,minLevel,maxLevel,rules=nil,oppdeck=nil,prize=nil,
  colorArrayPlayer=nil, colorArrayOpponent=nil
)
  pbFadeOutInWithMusic(99999){
    scene = PokeTetra::Scene.new(colorArrayPlayer,colorArrayOpponent)
    screen = PokeTetra::Screen.new(scene)
    screen.pbStartScreen(name,minLevel,maxLevel,rules,oppdeck,prize)
  }
end