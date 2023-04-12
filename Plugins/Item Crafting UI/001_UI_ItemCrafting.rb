################################################################################
#                               Item Crafting UI                               #
#                               by ThatWelshOne_                               #
#    Refer to the resource post for instructions on how to use this script.    #
################################################################################

class ItemCraft_Scene
  
  BASELIGHT        = Color.new(248,248,248)
  SHADOWLIGHT      = Color.new(72,80,88)
  BASEDARK         = Color.new(80,80,88)
  SHADOWDARK       = Color.new(160,160,168)
  MOVINGBACKGROUND = true
  
  def initialize
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @adapter = PokemonMartAdapter.new
  end
  
  def pbStartScene
    addBackgroundPlane(@sprites,"bg","Crafting/bg",@viewport)
    @sprites["base"] = IconSprite.new(0,0,@viewport)
    @sprites["base"].setBitmap("Graphics/Pictures/Crafting/base")
    @sprites["base"].ox = @sprites["base"].bitmap.width/2
    @sprites["base"].oy = @sprites["base"].bitmap.height/2
    @sprites["base"].x = Graphics.width/2; @sprites["base"].y = Graphics.height/2 - 16
    @h = @sprites["base"].y - @sprites["base"].oy
    @w = @sprites["base"].x - @sprites["base"].ox
    @xPos = [@w + 70,
             @w + 256]
    @yPos = [@h + 160,
             @h + 212,
             @h + 262]
    @sprites["item"] = ItemIconSprite.new(@w+44,@h+68,nil,@viewport)
    6.times do |i|
      @sprites["ingredient_#{i}"] = ItemIconSprite.new(0,0,nil,@viewport)
      @sprites["ingredient_#{i}"].x = @w + 38
      @sprites["ingredient_#{i}"].x += 186 if i>2
      @sprites["ingredient_#{i}"].y = @h + 198 + (i%3)*48
      @sprites["ingredient_#{i}"].visible = false
    end
    @sprites["itemtext"] = Window_UnformattedTextPokemon.new("")
    @sprites["itemtext"].x = @w + 82
    @sprites["itemtext"].y = @h + 20
    @sprites["itemtext"].width = 360
    @sprites["itemtext"].height = 160
    @sprites["itemtext"].baseColor = BASEDARK
    @sprites["itemtext"].shadowColor = SHADOWDARK
    @sprites["itemtext"].visible = true
    @sprites["itemtext"].viewport = @viewport
    @sprites["itemtext"].windowskin = nil
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    @sprites["rightarrow"].x = Graphics.width - @sprites["rightarrow"].bitmap.width
    @sprites["rightarrow"].y = Graphics.height/2 - @sprites["rightarrow"].bitmap.height/16
    @sprites["rightarrow"].visible = false
    @sprites["rightarrow"].play
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
    @sprites["leftarrow"].x = 0
    @sprites["leftarrow"].y = Graphics.height/2 - @sprites["rightarrow"].bitmap.height/16
    @sprites["leftarrow"].visible = false
    @sprites["leftarrow"].play
    @sprites["bottombar"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["bottombar"].bitmap.fill_rect(0,Graphics.height-32,Graphics.width,32,Color.new(144,184,240))
    @sprites["bottombar"].visible = true
    @sprites["overlay1"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay1 = @sprites["overlay1"].bitmap
    pbSetSystemFont(@overlay1)
    @sprites["overlay2"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay2 = @sprites["overlay2"].bitmap
    pbSetSystemFont(@overlay2)
  end
  
  def pbCraftItem(stock)
    index = 0
    volume = 1
    @stock = stock
    @switching = false
    refreshNumbers(index,volume)
    pbRedrawItem(index,volume)
    pbFadeInAndShow(@sprites) { pbUpdate }
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::RIGHT)
        if index < @stock.length-1
          pbPlayCursorSE
          hideIcons(index)
          volume = 1
          index += 1
          @switching = true
          pbRedrawItem(index,volume)
        end
      end
      if Input.trigger?(Input::LEFT)
        if index > 0
          pbPlayCursorSE
          hideIcons(index)
          volume = 1
          index -= 1
          @switching = true
          pbRedrawItem(index,volume)
        end
      end
      if Input.trigger?(Input::UP)
        if volume < 99
          pbPlayCursorSE
          volume += 1
          refreshNumbers(index,volume)
        elsif volume == 99
          pbPlayCursorSE
          volume = 1
          refreshNumbers(index,volume)
        end
      end
      if Input.trigger?(Input::DOWN)
        if volume > 1
          pbPlayCursorSE
          volume -= 1
          refreshNumbers(index,volume)
        elsif volume == 1
          pbPlayCursorSE
          volume = 99
          refreshNumbers(index,volume)
        end
      end
      if Input.trigger?(Input::USE)
        item = GameData::Item.get(@stock[index][0])
        itemname = (volume>1) ? item.name_plural : item.name
        pocket = item.pocket
        if pbConfirmMessage(_INTL("Would you like to craft {1} {2}?",volume,itemname))
          if canCraft?(index,volume)
            if $bag.can_add?(item,volume) 
              $bag.add(item,volume)
              pbSEPlay("Pkmn move learnt")
              removeIngredients(index,volume)
              pbMessage(_INTL("You put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
                itemname,pocket,PokemonBag.pocket_names()[pocket - 1]))
              refreshNumbers(index,volume)
            else
              pbPlayBuzzerSE
              pbMessage(_INTL("Too bad...\nThe Bag is full..."))
            end
          else
            pbPlayBuzzerSE
            pbMessage(_INTL("You lack the necessary ingredients."))
          end
        end
      end
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      end
    end
  end
  
  def removeIngredients(index,volume)
    for i in 0...@stock[index][1].length/2
      item = @stock[index][1][2*i]
      cost = @stock[index][1][2*i+1]
      $bag.remove(item,volume*cost)
    end
  end
  
  def canCraft?(index,volume)
    ret = []
    for i in 0...@stock[index][1].length/2
      have = @stock[index][1][2*i]
      cost = @stock[index][1][2*i+1]
      if @adapter.getQuantity(have) >= volume*cost
        ret.push(true)
      else
        ret.push(false)
      end
    end
    return ret.include?(false) ? false : true
  end
  
  def hideIcons(index)
    num = @stock[index][1].length/2
    num.times do |i|
      @sprites["ingredient_#{i}"].visible = false
    end
  end
  
  def refreshNumbers(index,volume)
    @overlay2.clear
    num = @stock[index][1].length/2 # Number of ingredients
    textpos = []
    textpos.push([_INTL("x{1}",volume),@w+26,@h+106,0,BASEDARK,SHADOWDARK])
    num.times do |i|
      ingredient = GameData::Item.get(@stock[index][1][2*i])
      quantity = @stock[index][1][2*i+1]
      text = sprintf("% 3d /% 3d",@adapter.getQuantity(ingredient),volume*quantity)
      textpos.push([text,
      @xPos[i/3],
      @yPos[i%3] + 38,
      0,
      (@adapter.getQuantity(ingredient) >= volume*quantity) ? BASEDARK : Color.new(248,192,0),
      (@adapter.getQuantity(ingredient) >= volume*quantity) ? SHADOWDARK : Color.new(144,104,0)])
    end
    pbDrawTextPositions(@overlay2,textpos)
  end
  
  def pbRedrawItem(index,volume)
    refreshNumbers(index,volume) if @switching
    @sprites["rightarrow"].visible = (index < @stock.length-1) ? true : false
    @sprites["leftarrow"].visible = (index > 0) ? true : false
    @overlay1.clear
    item = GameData::Item.get(@stock[index][0])
    @sprites["item"].item = item.id
    @sprites["itemtext"].text = item.description
    num = @stock[index][1].length/2
    textpos = [
    ["USE: Craft",4,Graphics.height-26,0,BASELIGHT,SHADOWLIGHT],
    ["ARROWS: Navigate",Graphics.width/2,Graphics.height-26,2,BASELIGHT,SHADOWLIGHT],
    ["BACK: Exit",Graphics.width-4,Graphics.height-26,1,BASELIGHT,SHADOWLIGHT]
    ]
    textpos.push([item.name,@w+98,@h+12,0,BASEDARK,SHADOWDARK])
    num.times do |i|
      ingredient = GameData::Item.get(@stock[index][1][2*i])
      quantity = @stock[index][1][2*i+1]
      @sprites["ingredient_#{i}"].item = ingredient.id
      @sprites["ingredient_#{i}"].visible = true
      textpos.push([ingredient.name,
      @xPos[i/3],
      @yPos[i%3] + 12,
      0,BASEDARK,SHADOWDARK])
    end
    pbDrawTextPositions(@overlay1,textpos)
    @switching = false
  end
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    if @sprites["bg"] && MOVINGBACKGROUND
      @sprites["bg"].ox-=1
      @sprites["bg"].oy-=1
    end
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end


class ItemCraft_Screen
  def initialize(scene,stock)
    @scene = scene
    @stock = stock
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbCraftItem(@stock)
    @scene.pbEndScene
  end
end

def pbItemCrafter(stock,speech1=nil,speech2=nil)
  for i in 0...stock.length
    raise _INTL("You are missing an ingredient or quantity value.") if stock[i][1].length%2 !=0
    itemdata = GameData::Item.try_get(stock[i][0])
    for j in 0...stock[i][1].length/2
      ingr = stock[i][1][2*j]
      cost = stock[i][1][2*j+1]
      if !GameData::Item.try_get(ingr) || cost==0
        raise _INTL("At least one ingredient or quantity value is invalid.")
      end
    end
    if !itemdata # If target item does not exist
      stock[i] = nil
    end
  end
  stock.compact! # Remove nils
  if stock.empty?
    raise _INTL("After data validation, there are no items left in your input array. Please check for typos before trying again.")
  end
  if pbConfirmMessage(_INTL("Would you like to craft something?"))
    pbMessage(speech1 ? speech1 : _INTL("Let's get started!"))
    pbFadeOutIn {
      scene = ItemCraft_Scene.new
      screen = ItemCraft_Screen.new(scene,stock)
      screen.pbStartScreen
    }
  end
  pbMessage(speech2 ? speech2 : _INTL("Come back soon!"))
end
