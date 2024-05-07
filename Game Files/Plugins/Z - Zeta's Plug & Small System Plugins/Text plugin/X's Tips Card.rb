module Settings
    #====================================================================================
    #=============================== Tip Cards Settings =================================
    #====================================================================================
    
        #--------------------------------------------------------------------------------
        #  Set the default background for tip cards.
        #  The files are located in Graphics/Pictures/Tip Cards
        #--------------------------------------------------------------------------------	
        TIP_CARDS_DEFAULT_BG            = "bg"

        #--------------------------------------------------------------------------------
        #  Set the default text colors
        #--------------------------------------------------------------------------------	
        TIP_CARDS_TEXT_MAIN_COLOR       = Color.new(80, 80, 88)
        TIP_CARDS_TEXT_SHADOW_COLOR     = Color.new(160, 160, 168)

        #--------------------------------------------------------------------------------
        #  Set the sound effect to play when showing and dismissing tip cards.
        #--------------------------------------------------------------------------------	
        TIP_CARDS_SHOW_SE               = "GUI menu open"
        TIP_CARDS_DISMISS_SE            = "GUI menu close"

        #--------------------------------------------------------------------------------
        #  
        # 
        #--------------------------------------------------------------------------------	
        TIP_CARDS_CONFIGURATION         = {
            :EXAMPLE => { # ID of the tip
                    # Required Settings
                    :Title => _INTL("Example Tip"),
                    :Text => _INTL("This is the text of the tip. You can include formatting."),
                    # Optional Settings
                    :Image => "example", # An image located in Graphics/Pictures/Tip Cards/Images
                    :YAdjustment => 0 # Adjust the vertical spacing of the tip's text (in pixels)
            },
            :CATCH => {
                :Title => _INTL("Catching Pokémon"),
                :Text => _INTL("This is the text of the tip. You catch Pokémon by throwing a <c2=0999367C><b>Poké Ball</b></c2> at them."),
                :Image => "catch"
            },
            :ITEMS => {
                :Title => _INTL("Items"),
                :Text => _INTL("This is the text of the other tip. You may find items lying around."),
                :Image => "items",
                :YAdjustment => 64
            }
        }

end

def pbShowTipCard(*ids)
    scene = TipCard_Scene.new(ids)
    screen = TipCard_Screen.new(scene)
    screen.pbStartScreen
end

alias pbTipCard pbShowTipCard

#===============================================================================
# Tip Card Scene
#===============================================================================  
class TipCard_Screen
    def initialize(scene)
        @scene = scene
    end
  
    def pbStartScreen
        @scene.pbStartScene
        @scene.pbScene
        @scene.pbEndScene
    end
end
  
class TipCard_Scene
    def initialize(tips)
        @tips = tips
    end

    def pbStartScene
        @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z = 99999
        @index = 0
        @pages = @tips.length
        @sprites = {}
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/#{Settings::TIP_CARDS_DEFAULT_BG}"))
        @sprites["background"].x = (Graphics.width - @sprites["background"].bitmap.width) / 2
        @sprites["background"].y = (Graphics.height - @sprites["background"].bitmap.height) / 2
        @sprites["background"].visible = true
        @sprites["image"] = IconSprite.new(0, 0, @viewport)
        @sprites["image"].visible = false
        @sprites["arrow_right"] = IconSprite.new(0, 0, @viewport)
        @sprites["arrow_right"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/arrow_right"))
        @sprites["arrow_right"].x = Graphics.width / 2 + 48
        @sprites["arrow_right"].y = @sprites["background"].y + @sprites["background"].bitmap.height -  @sprites["arrow_right"].bitmap.height - 4
        @sprites["arrow_right"].visible = false
        @sprites["arrow_left"] = IconSprite.new(0, 0, @viewport)
        @sprites["arrow_left"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/arrow_left"))
        @sprites["arrow_left"].x = Graphics.width / 2 - 48 - @sprites["arrow_left"].bitmap.width
        @sprites["arrow_left"].y = @sprites["background"].y + @sprites["background"].bitmap.height -  @sprites["arrow_left"].bitmap.height - 4
        @sprites["arrow_left"].visible = false
      
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        @sprites["overlay"].visible = true
        pbSEPlay(Settings::TIP_CARDS_SHOW_SE)
        pbDrawTip
    end
    
    def pbScene
        loop do
            Graphics.update
            Input.update
            pbUpdate
            oldindex = @index
            quit = false
            if Input.trigger?(Input::USE)
                if @index < @pages - 1
                    @index += 1
                else 
                    pbSEPlay(Settings::TIP_CARDS_DISMISS_SE)
                    break
                end
            elsif Input.trigger?(Input::BACK) || Input.trigger?(Input::LEFT)
                @index -= 1 if @index > 0
            elsif Input.trigger?(Input::RIGHT)
                @index += 1 if @index < @pages - 1
            end
            if oldindex != @index
                pbDrawTip
                pbSEPlay("GUI sel cursor") 
            end
        end
    end
    
    def pbEndScene
        # pbFadeOutAndHide(@sprites) { pbUpdate }
        pbUpdate
        Graphics.update
        Input.update
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
    end
  
    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

    def pbDrawTip
        tip = @tips[@index]
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        @sprites["image"].visible = false
        @sprites["arrow_right"].visible = false
        @sprites["arrow_left"].visible = false
        pbSetSystemFont(overlay)
        info = Settings::TIP_CARDS_CONFIGURATION[tip] || nil
        text_y_adj = 64
        text_x_adj = 16
        text_width_adj = 0
        base = Settings::TIP_CARDS_TEXT_MAIN_COLOR
        shadow = Settings::TIP_CARDS_TEXT_SHADOW_COLOR
        if info
            if info[:Image]
                @sprites["image"].setBitmap(_INTL("Graphics/Pictures/Tip Cards/Images/#{info[:Image]}"))
                horizontal = (@sprites["image"].width > @sprites["image"].height)
                if horizontal
                    @sprites["image"].x = (Graphics.width - @sprites["image"].bitmap.width) / 2
                    @sprites["image"].y = @sprites["background"].y + 64
                    text_y_adj += @sprites["image"].height + 16
                else
                    @sprites["image"].x = @sprites["background"].x + 16
                    @sprites["image"].y = @sprites["background"].y + 64
                    text_x_adj += @sprites["image"].width + 16
                end
                @sprites["image"].visible = true
            end
            title = "<ac>" + info[:Title] + "</ac>"
            # drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
            drawFormattedTextEx(overlay, @sprites["background"].x, @sprites["background"].y + 18, @sprites["background"].width, 
                title, base, shadow)
            text_y_adj += info[:YAdjustment] if info[:YAdjustment]
            text = "<ac>" + info[:Text] + "</ac>"
            drawFormattedTextEx(overlay, @sprites["background"].x + text_x_adj, @sprites["background"].y + text_y_adj, 
                @sprites["background"].width - 16 - text_x_adj, text, base, shadow)
        else
            Console.echo_warn tip.to_s + " is not defined."
            drawFormattedTextEx(overlay, @sprites["background"].x, @sprites["background"].y+ 18, @sprites["background"].width, 
                _INTL("<ac>Tip not defined.</ac>"), base, shadow)
        end
        if @pages > 1
            @sprites["arrow_left"].visible = (@index > 0)
            @sprites["arrow_right"].visible = (@index < @pages - 1)
            pbDrawTextPositions(overlay, [[_INTL("{1}/{2}",@index+1, @pages), Graphics.width/2, @sprites["background"].y + @sprites["background"].bitmap.height - 26, 
                2, base, shadow]])
        end
    end
end