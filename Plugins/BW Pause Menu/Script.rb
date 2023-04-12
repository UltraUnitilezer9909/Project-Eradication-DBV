#=====================================================================================
# * Pokémon Menu like in Black and White by Bhagya Jyoti and updated by Tilles
#   Based on works by Shiney570 with ccripting help of Luka S.J
# 
# * To get this Script work, but it in a new Script above Main.
#*  This Script overwrites some Methods from the Old Menu, and add new ones to it.
# * Put the Graphics in the Graphics/Pictures/Menu folder.
# * If you have any questions or found a bug let me know. (FYI i cannot script that well.)
# * The Debug Scene is accessable with F9
# * Version: 1.1.0
#===============================================================================

NO_BG          = false # true, if you want there to be no background to the pause menu, false, if you want there to be one.
OPENANIMATION  = true  # true, if you want to keep the Open Animation, false, if you don't want it.
CLOSEANIMATION = false # true, if you want to keep the Close Animation, false, if you don't want it. WARNING: MAY LAG THE GAME
BWMENUPOKEGEAR = false  # false, pokeger not shown. true, pokegear at options place of panel while options is shown below the menu.

#===============================================================================
# * 
#===============================================================================
class PokemonPauseMenu_Scene
#===============================================================================
# * STARTING THE SCENE
#===============================================================================
  def pbStartScene
    @MenuScene=1; @frame=0; @frame2=0
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    
    if !NO_BG
     @sprites["bg"]=IconSprite.new(0,0,@viewport)    
     @sprites["bg"].setBitmap("Graphics/Pictures/Menu/background")
    end
    
    @sprites["bg2"]=IconSprite.new(0,0,@viewport)
    @sprites["bg2"].setBitmap("Graphics/Pictures/Menu/background2")
    @sprites["bg2"].y=0
    @sprites["bg2"].y = -32 if OPENANIMATION==true
    
    @sprites["bg3"]=IconSprite.new(0,0,@viewport)
    @sprites["bg3"].setBitmap("Graphics/Pictures/Menu/background3")
    @sprites["bg3"].y = 384-48
    @sprites["bg3"].y = 336+48 if OPENANIMATION==true
   
    @sprites["panel_1"]=IconSprite.new(0,0,@viewport)    
    @sprites["panel_1"].setBitmap("Graphics/Pictures/Menu/panel")
    @sprites["panel_1"].x = 3
    @sprites["panel_1"].y = 47 
    @sprites["panel_1"].y = 47 +200 if OPENANIMATION==true
    
    @sprites["panel_2"]=IconSprite.new(0,0,@viewport)    
    @sprites["panel_2"].setBitmap("Graphics/Pictures/Menu/panel")
    @sprites["panel_2"].x = 261
    @sprites["panel_2"].y = 47 
    @sprites["panel_2"].y = 47 +200 if OPENANIMATION==true
 
    @sprites["panel_3"]=IconSprite.new(0,0,@viewport)    
    @sprites["panel_3"].setBitmap("Graphics/Pictures/Menu/panel")
    @sprites["panel_3"].x = 3
    @sprites["panel_3"].y = 143 
    @sprites["panel_3"].y = 143 +200 if OPENANIMATION==true
   
    @sprites["panel_4"]=IconSprite.new(0,0,@viewport)    
    @sprites["panel_4"].setBitmap("Graphics/Pictures/Menu/panel")
    @sprites["panel_4"].x = 261
    @sprites["panel_4"].y = 143 
    @sprites["panel_4"].y = 143 +200 if OPENANIMATION==true
 
    @sprites["panel_5"]=IconSprite.new(0,0,@viewport)    
    @sprites["panel_5"].setBitmap("Graphics/Pictures/Menu/panel")
    @sprites["panel_5"].x = 3
    @sprites["panel_5"].y = 241 
    @sprites["panel_5"].y = 241 +200 if OPENANIMATION==true
    
    @sprites["panel_6"]=IconSprite.new(0,0,@viewport)    
    @sprites["panel_6"].setBitmap("Graphics/Pictures/Menu/panel")
    @sprites["panel_6"].x = 261
    @sprites["panel_6"].y = 241 
    @sprites["panel_6"].y = 241 +200 if OPENANIMATION==true
   
    @sprites["panel_select"]=IconSprite.new(0,0,@viewport)    
    @sprites["panel_select"].setBitmap("Graphics/Pictures/Menu/panel2")
    @sprites["panel_select"].x = 5000
    @sprites["panel_select"].y = 48
    
    @sprites["party"]=IconSprite.new(0,0,@viewport)    
    @sprites["party"].setBitmap("Graphics/Pictures/Menu/party")
    @sprites["party"].x = 50000
    @sprites["party"].x = 9 if $Trainer.party.length>0
    @sprites["party"].y = 62
   
    @sprites["pokedex"]=IconSprite.new(0,0,@viewport)    
    @sprites["pokedex"].setBitmap("Graphics/Pictures/Menu/pokedex")
    @sprites["pokedex"].x = 50000
    @sprites["pokedex"].x = 267 if $player.has_pokedex
    @sprites["pokedex"].y = 56
   
    @sprites["bag"]=IconSprite.new(0,0,@viewport)    
    @sprites["bag"].setBitmap("Graphics/Pictures/Menu/bag")
    @sprites["bag"].x = 10
    @sprites["bag"].y = 159
   
    @sprites["trainercard"]=IconSprite.new(0,0,@viewport)    
    @sprites["trainercard"].setBitmap("Graphics/Pictures/Menu/trainercard")
    @sprites["trainercard"].x = 268
    @sprites["trainercard"].y = 157
   
    @sprites["save"]=IconSprite.new(0,0,@viewport)    
    @sprites["save"].setBitmap("Graphics/Pictures/Menu/save")
    @sprites["save"].x = 10
    @sprites["save"].y = 255
    
    @sprites["pokegear"]=IconSprite.new(0,0,@viewport)    
    @sprites["pokegear"].setBitmap("Graphics/Pictures/Menu/options")
    @sprites["pokegear"].x = 268
    @sprites["pokegear"].y = 253
    
    
    if BWMENUPOKEGEAR
    @sprites["options"]=IconSprite.new(0,0,@viewport)    
    @sprites["options"].setBitmap("Graphics/Pictures/Menu/op")
    @sprites["options"].x = 420
    @sprites["options"].y = 346
    end
    
    @sprites["exit"]=IconSprite.new(0,0,@viewport)    
    @sprites["exit"].setBitmap("Graphics/Pictures/Menu/exit")
    @sprites["exit"].x = 459
    @sprites["exit"].y = 346
    
    @sprites["overlay"]=BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay2"]=BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    
    if $Trainer.party.length>0
      @select=1
    end
    if $Trainer.party.length==0 && $player.has_pokedex
      @select=2
    end
    if $Trainer.party.length==0 && !$player.has_pokedex
      @select=3
    end
    endscene=true
    pbStartAnimation
  end
#===============================================================================
# * MENU TEXT DISPLAYING
#===============================================================================  
  def pbMenuText
    if @MenuScene==1
      overlay=@sprites["overlay"].bitmap 
      overlay.clear
      baseColor=Color.new(255, 255, 255)
      shadowColor=Color.new(0,0,0)
      shadowColor2=Color.new(156,156,156)
      pbSetSystemFont(@sprites["overlay"].bitmap)
      textos=[]
      textos.push([_ISPRINTF("{1:02d}   {2:02d}", Time.now.hour, Time.now.min),15,5,false,baseColor,shadowColor])
      textos.push([_INTL("POKÉMON"),98,80,false,baseColor,shadowColor2]) if $Trainer.party.length>0
      textos.push([_INTL("POKÉDEX"),354,80,false,baseColor,shadowColor2]) if $player.has_pokedex
      textos.push([_INTL("BAG"),98,175,false,baseColor,shadowColor2])
      textos.push([_INTL("{1}", $Trainer.name),354,175,false,baseColor,shadowColor2])
      textos.push([_INTL("SAVE"),98,275,false,baseColor,shadowColor2])
      if BWMENUPOKEGEAR && $player.has_pokegear
        textos.push([_INTL("POKÉGEAR"),354,275,false,baseColor,shadowColor2])
      elsif !BWMENUPOKEGEAR
        textos.push([_INTL("OPTIONS"),354,275,false,baseColor,shadowColor2])
      end
      pbDrawTextPositions(overlay,textos)
      overlay2=@sprites["overlay2"].bitmap
      overlay2.clear
      pbSetSystemFont(@sprites["overlay2"].bitmap)
      textos2=[]
      textos2.push([_ISPRINTF("       :       "),2,4,false,baseColor,shadowColor])
      pbDrawTextPositions(overlay2,textos2)
    end
  end
#===============================================================================
# * MENU LOOP
#===============================================================================  
  def pbMenuLoop
    while @MenuScene==1
      self.update
      self.pbMenuInput
      self.pbMenuText
      if $MenuClose==true
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
        $MenuClose=false
        @MenuScene=2
      end
    end
  end
#===============================================================================
# * HIDING THE MENU
#===============================================================================
  def pbHideMenu
    @viewport.visible=false
  end
#===============================================================================
# * SHOWING THE MENU
#===============================================================================
  def pbShowMenu
    @viewport.visible=true
  end
#===============================================================================
# * STARTING THE SCENE
#===============================================================================  
  def pbStartAnimation
    pbSEPlay("BW2OpenMenu")
    if OPENANIMATION==true
      @sprites["overlay"].visible=false
      @sprites["panel_1"].visible=false
      @sprites["panel_2"].visible=false 
      @sprites["panel_3"].visible=false
      @sprites["panel_4"].visible=false
      @sprites["panel_5"].visible=false
      @sprites["panel_6"].visible=false
      @sprites["panel_select"].visible=false
      @sprites["party"].visible=false
      @sprites["pokedex"].visible=false
      @sprites["bag"].visible=false
      @sprites["trainercard"].visible=false
      @sprites["save"].visible=false
      @sprites["pokegear"].visible=false
      @sprites["options"].visible=false if @sprites["options"]
      @sprites["exit"].visible=false
         10.times do
           @sprites["bg2"].y += 3.2
           @sprites["bg3"].y -= 5.3
           Graphics.update
           Input.update
          end
          @sprites["bg2"].y = 0
          @sprites["bg3"].y = 384-48
          pbWait(5)
          @sprites["panel_1"].visible=true if $Trainer.party.length>0
          @sprites["panel_2"].visible=true if $player.has_pokedex
          @sprites["panel_3"].visible=true
          @sprites["panel_4"].visible=true
          @sprites["panel_5"].visible=true
          @sprites["panel_6"].visible=true if $player.has_pokegear or !BWMENUPOKEGEAR
          20.times do
            @sprites["panel_1"].y -= 10
            @sprites["panel_2"].y -= 10
            @sprites["panel_3"].y -= 10
            @sprites["panel_4"].y -= 10
            @sprites["panel_5"].y -= 10
            @sprites["panel_6"].y -= 10
            Graphics.update
            Input.update
          end
          pbWait(5)
      @sprites["overlay"].visible=true
      @sprites["panel_select"].visible=true
      @sprites["party"].visible=true       if $Trainer.party.length>0
      @sprites["pokedex"].visible=true     if $player.has_pokedex
      @sprites["bag"].visible=true
      @sprites["trainercard"].visible=true
      @sprites["save"].visible=true
      @sprites["pokegear"].visible=true if $player.has_pokegear or !BWMENUPOKEGEAR
      @sprites["options"].visible=true if @sprites["options"]
      @sprites["exit"].visible=true
    end
    self.pbMenuLoop
  end
#===============================================================================
# * CLOSING THE SCENE
#===============================================================================
  def pbEndScene
    pbSEPlay("BW2CloseMenu")
    @MenuScene=0
    if CLOSEANIMATION==true 
      @sprites["overlay"].visible=false if @sprites["overlay"]
      @sprites["overlay2"].visible=false if @sprites["overlay2"]
      @sprites["panel_select"].visible=false if @sprites["panel_select"]
      @sprites["party"].visible=false if @sprites["party"]
      @sprites["pokedex"].visible=false    if @sprites["pokedex"]  
      @sprites["bag"].visible=false if @sprites["bag"]
      @sprites["trainercard"].visible=false if @sprites["trainercard"]
      @sprites["save"].visible=false if @sprites["save"]
      @sprites["pokegear"].visible=false if @sprites["pokegear"]
      @sprites["options"].visible=false if @sprites["options"]
      @sprites["exit"].visible=false if @sprites["exit"]
      pbWait(5)
      20.times do
            @sprites["panel_1"].y += 10  if @sprites["panel_1"]
            @sprites["panel_2"].y += 10  if @sprites["panel_2"]
            @sprites["panel_3"].y += 10  if @sprites["panel_3"]
            @sprites["panel_4"].y += 10  if @sprites["panel_4"]
            @sprites["panel_5"].y += 10  if @sprites["panel_5"]
            @sprites["panel_6"].y += 10  if @sprites["panel_6"]
            Graphics.update
            Input.update
          end
      @sprites["panel_1"].visible=false if @sprites["panel_1"]
      @sprites["panel_2"].visible=false if @sprites["panel_2"]
      @sprites["panel_3"].visible=false if @sprites["panel_3"]
      @sprites["panel_4"].visible=false if @sprites["panel_4"]
      @sprites["panel_5"].visible=false if @sprites["panel_5"]
      @sprites["panel_6"].visible=false if @sprites["panel_6"]
       10.times do
           @sprites["bg2"].y -= 3.2 if @sprites["bg2"]
           @sprites["bg3"].y += 5.3 if @sprites["bg3"]
            Graphics.update
            Input.update
          end
        end
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
#===============================================================================
# * Update Method
#===============================================================================  
  def update
    Graphics.update
    Input.update
    @frame+=1
    @sprites["party"].x=12  if $Trainer.party.length>0
    @sprites["pokedex"].x=269 if $player.has_pokedex
    @sprites["pokegear"].x=269 if $player.has_pokegear or !BWMENUPOKEGEAR
    @frame=0 if @frame>=20
    frame=[0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1]
    @count=frame[@frame]
    x=[5000,5,263,5,263,5,263,5000]
    y=[5000,49,49,145,145,243,243,5000]
    y=[5000,5000,49,145,145,243,243,5000]   if $Trainer.party.length==0 && $player.has_pokedex
    y=[5000,49,5000,145,145,243,243,5000]   if $Trainer.party.length>0  && !$player.has_pokedex
    y=[5000,5000,5000,145,145,243,243,5000] if $Trainer.party.length==0 && !$player.has_pokedex
    x=[5000,5,263,5,263,5,263,5000,5000] if BWMENUPOKEGEAR
    y=[5000,49,49,145,145,243,5000,5000,5000] if BWMENUPOKEGEAR
    y=[5000,5000,49,145,145,243,5000,5000,5000]   if $Trainer.party.length==0 && $player.has_pokedex && !$player.has_pokegear && BWMENUPOKEGEAR
    y=[5000,5000,49,145,145,243,243,5000,5000]   if $Trainer.party.length==0 && $player.has_pokedex && $player.has_pokegear && BWMENUPOKEGEAR
    y=[5000,49,5000,145,145,243,5000,5000,5000]   if $Trainer.party.length>0  && !$player.has_pokedex && !$player.has_pokegear && BWMENUPOKEGEAR
    y=[5000,49,5000,145,145,243,243,5000,5000]   if $Trainer.party.length>0  && !$player.has_pokedex && $player.has_pokegear && BWMENUPOKEGEAR
    y=[5000,5000,5000,145,145,243,5000,5000,5000] if $Trainer.party.length==0 && !$player.has_pokedex && !$player.has_pokegear && BWMENUPOKEGEAR
    y=[5000,5000,5000,145,145,243,243,5000,5000] if $Trainer.party.length==0 && !$player.has_pokedex && $player.has_pokegear && BWMENUPOKEGEAR
    @sprites["panel_select"].x = x[@select]
    @sprites["panel_select"].y = y[@select]
    @sprites["panel_select"].visible=true
    if @select==1
      @sprites["party"].setBitmap("Graphics/Pictures/Menu/party2")
      if BWMENUPOKEGEAR
        @estop = false
      end
    else
      @sprites["party"].setBitmap("Graphics/Pictures/Menu/party")
    end
    if @select==2
      @sprites["pokedex"].setBitmap("Graphics/Pictures/Menu/pokedex2")
      if BWMENUPOKEGEAR
        @estop = false
      end
    else
      @sprites["pokedex"].setBitmap("Graphics/Pictures/Menu/pokedex")
    end
    if @select==3
      @sprites["bag"].setBitmap("Graphics/Pictures/Menu/bag2")
      if BWMENUPOKEGEAR
        @estop = false
      end
    else
      @sprites["bag"].setBitmap("Graphics/Pictures/Menu/bag")
    end
    if @select==4
      @sprites["trainercard"].setBitmap("Graphics/Pictures/Menu/trainercard2")
      if BWMENUPOKEGEAR
        @estop = false
      end
    else
      @sprites["trainercard"].setBitmap("Graphics/Pictures/Menu/trainercard")
    end
    if @select==5
      @sprites["save"].setBitmap("Graphics/Pictures/Menu/save2")
      if BWMENUPOKEGEAR
        @estop = false
      end
    else
      @sprites["save"].setBitmap("Graphics/Pictures/Menu/save")
    end
    if @select==6
      @sprites["pokegear"].setBitmap("Graphics/Pictures/Menu/options2")
      if BWMENUPOKEGEAR
        @estop = false
      end
    else
      @sprites["pokegear"].setBitmap("Graphics/Pictures/Menu/options")
    end
    if @select==7
      @sprites["exit"].setBitmap("Graphics/Pictures/Menu/exit2")
      if BWMENUPOKEGEAR
        @estop = false
      end
    else
      @sprites["exit"].setBitmap("Graphics/Pictures/Menu/exit")
    end
    if BWMENUPOKEGEAR == true
      if @select==8 && !@estop
        @sprites["options"].setBitmap("Graphics/Pictures/Menu/op2")
        @estop = true
      elsif !@estop
        @sprites["options"].setBitmap("Graphics/Pictures/Menu/op")
      end
    end
    if $Trainer.party.length>0
      @sprites["panel_1"].visible=true
      @sprites["party"].visible=true
    else
      x[1]=5000
      @select=2 if @select==1
      @sprites["panel_1"].visible=false
      @sprites["party"].visible=false
    end
    if $player.has_pokedex
      @sprites["panel_2"].visible=true
      @sprites["pokedex"].visible=true
    else
      x[2]=5000
      @select=3 if @select==2
      @sprites["panel_2"].visible=false
      @sprites["pokedex"].visible=false
    end
    if BWMENUPOKEGEAR
      if $player.has_pokegear
        @sprites["panel_6"].visible=true
        @sprites["pokegear"].visible=true
      else
        x[6]=5000
        @select=8 if @select==6
        @sprites["panel_6"].visible=false
        @sprites["pokegear"].visible=false
      end
    end
  end
#===============================================================================
# * Menu Left Click Animation
#===============================================================================    
  def pbMenuClick
    pbWait(10)
    @sprites["panel_select"].visible=false
    pbWait(5)
    self.update
  end
#===============================================================================
# * Menu Left Click Animation on the Exit Button
#===============================================================================  
  def pbMenuClickExit
    @sprites["exit"].setBitmap("Graphics/Pictures/Menu/exit2")
    pbWait(10)
    @sprites["exit"].setBitmap("Graphics/Pictures/Menu/exit")
    pbWait(5)
    pbHideMenu
  end
#===============================================================================
# * Button Inputs
#===============================================================================  
  def pbMenuInput
    if BWMENUPOKEGEAR
      if Input.trigger?(Input::RIGHT) && !(@select>=7) && !(@select==8) && !(@select==6)
        @select+=1; pbSEPlay("BW2MenuSelect")
      elsif Input.trigger?(Input::RIGHT) && @select==6
        @select+=2; pbSEPlay("BW2MenuSelect")
      elsif Input.trigger?(Input::RIGHT) && @select==8
        @select-=1; pbSEPlay("BW2MenuSelect")
      end
      if Input.trigger?(Input::LEFT) && !(@select==1) && !(@select>=7)
        @select-=1; pbSEPlay("BW2MenuSelect")
      elsif Input.trigger?(Input::LEFT) && (@select==7) && BWMENUPOKEGEAR == true
        @select+=1; pbSEPlay("BW2MenuSelect")
      elsif Input.trigger?(Input::LEFT) && @select==8
        if $player.has_pokegear
          @select-=2; pbSEPlay("BW2MenuSelect")
        else
          @select-=3; pbSEPlay("BW2MenuSelect")
        end
      end
      if Input.trigger?(Input::DOWN) && @select==6
        if BWMENUPOKEGEAR == true
          @select+=2; pbSEPlay("BW2MenuSelect")
        else
          @select+=1; pbSEPlay("BW2MenuSelect")
        end
      elsif Input.trigger?(Input::DOWN) && !(@select>4) && !(@select==8)
        @select+=2; pbSEPlay("BW2MenuSelect") 
      elsif Input.trigger?(Input::DOWN) && (@select==5)
        if BWMENUPOKEGEAR == true
          @select+=3; pbSEPlay("BW2MenuSelect")
        else
          @select+=2; pbSEPlay("BW2MenuSelect")
        end
      end
      if Input.trigger?(Input::UP) && @select==7
        @select-=1; pbSEPlay("BW2MenuSelect")
      elsif Input.trigger?(Input::UP) && !(@select<3) && !(@select==8)
        @select-=2; pbSEPlay("BW2MenuSelect")
      elsif Input.trigger?(Input::UP) && @select==8
        if $player.has_pokegear
          @select-=2; pbSEPlay("BW2MenuSelect")
        else
          @select-=4; pbSEPlay("BW2MenuSelect")
        end
      end
    else
      if Input.trigger?(Input::RIGHT) && !(@select>=7)
        @select+=1; pbSEPlay("BW2MenuSelect")
      end
      if Input.trigger?(Input::LEFT) && !(@select==1)
        @select-=1; pbSEPlay("BW2MenuSelect")
      end
      if Input.trigger?(Input::DOWN) && @select==6
        @select+=1; pbSEPlay("BW2MenuSelect")
      elsif Input.trigger?(Input::DOWN) && !(@select>4)
        @select+=2; pbSEPlay("BW2MenuSelect") 
      end
      if Input.trigger?(Input::UP) && @select==7
        @select-=1; pbSEPlay("BW2MenuSelect")
      elsif Input.trigger?(Input::UP) && !(@select<3)
        @select-=2; pbSEPlay("BW2MenuSelect")
      end
    end
      
    if Input.trigger?(Input::F9) && $DEBUG
      pbFadeOutIn(99999) { 
      pbDebugMenu
      }
    end
     
    if Input.trigger?(Input::BACK) or Input.trigger?(Input::ACTION)
      self.pbMenuClickExit
      pbEndScene
    end
        
    if Input.trigger?(Input::USE) 
      case @select
      when 1 # Party
      if $Trainer.party.length>0
        self.pokemonParty
      end
      when 2 #Pokedex
      if $player.has_pokedex
        self.pokeDex
      end
      when 3 #Bag
        self.bag
      when 4 #Trainercard
        self.trainerCard
      when 5 #Save
        self.save
      when 6 #Options
        self.pokegear if BWMENUPOKEGEAR
        self.options if !BWMENUPOKEGEAR
      when 7 #Quit 
        self.pbMenuClickExit
        pbEndScene
      when 8 #Options 
        self.options if BWMENUPOKEGEAR
      end 
    end
  end
#===============================================================================
# * MENU SCENE'S
#===============================================================================    
  def pokemonParty
    pbSEPlay("BW2MenuChoose")
    hiddenmove = nil
    pbFadeOutIn {
      sscene = PokemonParty_Scene.new
      sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
      hiddenmove = sscreen.pbPokemonScreen
      (hiddenmove) ? pbEndScene : pbRefresh
    }
    if hiddenmove
      $game_temp.in_menu = false
      pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
      return
    end
  end
  
  def pokeDex
    pbSEPlay("BW2MenuChoose")
    #pbPlayDecisionSE
    if Settings::USE_CURRENT_REGION_DEX
      pbFadeOutIn {
        scene = PokemonPokedex_Scene.new
        screen = PokemonPokedexScreen.new(scene)
        screen.pbStartScreen
        menu.pbRefresh
      }
    elsif $player.pokedex.accessible_dexes.length == 1
      $PokemonGlobal.pokedexDex = $player.pokedex.accessible_dexes[0]
      pbFadeOutIn {
        scene = PokemonPokedex_Scene.new
        screen = PokemonPokedexScreen.new(scene)
        screen.pbStartScreen
        menu.pbRefresh
      }
    else
      pbFadeOutIn {
        scene = PokemonPokedexMenu_Scene.new
        screen = PokemonPokedexMenuScreen.new(scene)
        screen.pbStartScreen
        #menu.pbRefresh
        pbRefresh
      }
    end
  end
        
  def bag
    pbSEPlay("BW2MenuChoose")
    item=0
    pbPlayDecisionSE
    item = nil
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene, $bag)
      item = screen.pbStartScreen
      (item) ? pbEndScene : pbRefresh
    }
    $game_temp.in_menu = false
    if item
      pbUseKeyItemInField(item)
    end
  end
  
  def trainerCard
    pbSEPlay("BW2MenuChoose")
    pbFadeOutIn {
      scene = PokemonTrainerCard_Scene.new
      screen = PokemonTrainerCardScreen.new(scene)
      screen.pbStartScreen
      pbRefresh
    }
  end
 
  def save
    pbSEPlay("BW2MenuChoose")
    pbHideMenu
    scene = PokemonSave_Scene.new
    screen = PokemonSaveScreen.new(scene)
    if screen.pbSaveScreen
    else
      pbShowMenu
    end
    pbShowMenu
  end
  
  def pokegear
    pbFadeOutIn {
      scene = PokemonPokegear_Scene.new
      screen = PokemonPokegearScreen.new(scene)
      screen.pbStartScreen
      pbRefresh
    }
  end
      
  def options
    pbSEPlay("BW2MenuChoose")
    pbFadeOutIn {
      scene = PokemonOption_Scene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
      pbUpdateSceneMap
      pbRefresh
    }
  end
end
#===============================================================================
# * class PokemonMenu
#===============================================================================
class PokemonPauseMenu
#===============================================================================
# * SHOWING THE MENU
#===============================================================================  
  def pbShowMenu
    @scene.pbShowMenu
  end
#===============================================================================
# * STARTING THE MENU
#===============================================================================  
  def pbStartPokemonMenu
    @scene.pbStartScene
  end
end
#===============================================================================
#===============================================================================