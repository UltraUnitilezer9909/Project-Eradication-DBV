#===============================================================================
#
#===============================================================================
class PokemonCardUI_Scene
    def pbUpdate
      pbUpdateSpriteHash(@sprites)
      if @sprites["bg"]
        @sprites["bg"].ox+=1
        @sprites["bg"].oy+=1
      end
    end
  
    def pbStartScene
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      @sprites = {}
      addBackgroundPlane(@sprites, "bg", $bgPath, @viewport)
      @sprites["card"] = IconSprite.new(0, 0, @viewport)
      @sprites["card"].setBitmap("Graphics/Pictures/UI/CardUI/card")
      @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites["overlay2"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      pbSetSystemFont(@sprites["overlay"].bitmap)
      pbSetSystemFont(@sprites["overlay2"].bitmap)
      @sprites["trainer"] = IconSprite.new(590, 26, @viewport) #IconSprite.new(336, 112, @viewport)
      @sprites["trainer"].setBitmap(GameData::TrainerType.player_front_sprite_filename($player.trainer_type))
      @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width - 128) / 2
      @sprites["trainer"].y -= (@sprites["trainer"].bitmap.height - 128)
      @sprites["trainer"].z = 2
      pbDrawCardUIFront
      pbFadeInAndShow(@sprites) { pbUpdate }
    end

    def calculate_colorz(rank)
      case rank
      when 0 then 0
      when 1..3 then 1
      when 4..6 then 2
      when 7..9 then 3
      when 10..12 then 4
      when 13..15 then 5
      when 16..18 then 6
      when 19..21 then 7
      when 22..24 then 8
      when 25..27 then 9
      else 10
      end
    end
  
    def pbDrawCardUIFront
      overlay = @sprites["overlay"].bitmap
      overlay.clear
      overlay2 = @sprites["overlay2"].bitmap
      overlay2.clear 
      pbSetSmallFont(overlay2)
      baseColor   = Color.new(255, 255, 255)
      shadowColor = Color.new(165, 165, 173)
      baseColor1   = Color.new(148, 15, 255)
      shadowColor1 = Color.new(99, 0, 180)
      baseColor2 = Color.new(120, 184, 232)
      shadowColor2 = Color.new(0, 112, 248)
      baseColor3 = Color.new(248, 168, 184)
      shadowColor3 = Color.new(232, 32, 16)
      @RED = baseColor3
      @RED1 = shadowColor3
      @YELLOW = Color.new(255,188,15)
      @YELLOW1 = Color.new(175,126,0)
      @GREEN = Color.new(15,255,28)
      @GREEN1 = Color.new(0, 175, 9)

      totalsec = $stats.play_time.to_i
      hour = totalsec / 60 / 60
      min = totalsec / 60 % 60
      time = (hour > 0) ? _INTL("{1}h {2}m", hour, min) : _INTL("{1}m", min)
      $PokemonGlobal.startTime = Time.now if !$PokemonGlobal.startTime
      #$PokemonGlobal.startTime = pbGetTimeNow if !$PokemonGlobal.startTime
      starttime = _INTL("{1} {2}, {3}",
                        pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
                        $PokemonGlobal.startTime.day,
                        $PokemonGlobal.startTime.year
                        )
      pbDrawTextPositions(overlay,[[_INTL("Credential Card",),40,34,0,baseColor1,shadowColor1,true]])
      diff_dark_color, diff_light_color = SysFixData.diff_colors(SysFixData.difficulties)
      @Xposition = [42, 528]
      @Yposition = [78, 78 + (30*1), 78 + (30*2), 78 + (30*3), 78 + (30*4)]
      @Yposition1 = [214, 214 + (30*1), 214 + (30*2)]
      @Yposition2 = [
        320, 
        320 + (30*1),
        320 + (30*1) + 26
      ]
      colorz = calculate_colorz($rank)
      light_color, dark_color  = SysFixData.rank_colors(colorz)
      next_rank_index = $rank + 1
      next_rank_name = (next_rank_index < SysFixData::Rname.length) ? SysFixData::Rname[next_rank_index] : "Max Rank"

      SysFixData.xp_meter  # Call the method to update XP and display meter
      percent_complete = SysFixData.xp_meter  # Retrieve the completion percentage 
      SysFixData.xp_meter_needed
      percent_needed = SysFixData.xp_meter_needed
      #pbMessage("#{$xp}/#{SysFixData::Rxp[$rank]} (#{percent_complete}% complete)")
      textPositions = [
        [_INTL("Name: " + $player.name.to_s), @Xposition[0], @Yposition[0], 0, ($player.male? ? baseColor2 : ($player.female? ? baseColor3 : baseColor)), ($player.male? ? shadowColor2 : ($player.female? ? shadowColor3 : shadowColor)),true],
        [_INTL("ID No: " + $player.public_ID.to_s), @Xposition[0], @Yposition[1], 0, baseColor, shadowColor,true],
        [_INTL("Money: $" + $player.money.to_s_formatted), @Xposition[0], @Yposition[2], 0, ($player.money <= 0) ? @RED : ($player.money <= 5000) ? @YELLOW : @GREEN,($player.money <= 500) ? @RED1 : ($player.money <= 1500) ? @YELLOW1 : @GREEN1 , true],
        [_INTL("Unidex: " + $player.pokedex.owned_count.to_s + "/" + $player.pokedex.seen_count.to_s), @Xposition[0], @Yposition[3], 0, baseColor, shadowColor,true],
        [_INTL("Time: " + time), @Xposition[1], @Yposition[0], 1, baseColor2, shadowColor2,true],
        [_INTL("Started: " + starttime.to_s), @Xposition[1], @Yposition[1], 1, baseColor3, shadowColor3,true],
        [_INTL("Difficulty: " + SysFixData::Dnames[SysFixData.difficulties]), @Xposition[0], @Yposition2[0], 0, diff_light_color, diff_dark_color, true],
        [_INTL("Rank: " + SysFixData::Rname[$rank]), @Xposition[0], @Yposition1[0], 0, light_color, dark_color, true],
        [_INTL($xp.to_s + "/" + SysFixData::Rxp[$rank].to_s + " [" + percent_complete.to_s + "%]" + " | " + percent_needed.to_s +  "% to Rank up"), @Xposition[0], @Yposition1[1], 0, light_color, dark_color, true],
        [_INTL("Next Rank: " + next_rank_name), @Xposition[0], @Yposition1[2], 0, baseColor, shadowColor, true]      
      ]
      #smalltextPositions = [
        
      #]
      smalltextPositions1 = [
        [_INTL(SysFixData::Ddesc[SysFixData.difficulties * 2].to_s), @Xposition[0], @Yposition2[1], 0, diff_light_color, diff_dark_color, true],
        [_INTL(SysFixData::Ddesc[SysFixData.difficulties * 2 + 1].to_s), @Xposition[0], @Yposition2[2], 0, diff_light_color, diff_dark_color, true]
      ]
      pbDrawTextPositions(overlay, textPositions)
      pbDrawTextPositions(overlay2, smalltextPositions1)
      #pbDrawTextPositions(overlay2, smalltextPositions)
      x = 72
      region = pbGetCurrentRegion(0) # Get the current region
      imagePositions = []
      8.times do |i|
        if $player.badges[i + (region * 8)]
          imagePositions.push(["Graphics/Pictures/UI/CardUI/icon_badges", x, 310, i * 32, region * 32, 32, 32])
        end
        x += 48
      end
      pbDrawImagePositions(overlay, imagePositions)
    end
  
    def pbCardUI
      pbSEPlay("GUI trainer card open")
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        end
      end
    end
  
    def pbEndScene
      pbFadeOutAndHide(@sprites) { pbUpdate }
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
      
    end
  end
  
  #===============================================================================
  #
  #===============================================================================
  class PokemonCardUIScreen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartScreen
      @scene.pbStartScene
      @scene.pbCardUI
      @scene.pbEndScene
    end
  end
  