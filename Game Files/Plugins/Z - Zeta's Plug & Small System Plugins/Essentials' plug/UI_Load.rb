class PokemonLoadPanel < Sprite
attr_reader :selected

TEXTCOLOR = Color.new(148, 15, 255)
TEXTSHADOWCOLOR = Color.new(99, 0, 180)
MALETEXTCOLOR = Color.new(56, 160, 248)
MALETEXTSHADOWCOLOR = Color.new(56, 104, 168)
FEMALETEXTCOLOR = Color.new(255, 56, 60)
FEMALETEXTSHADOWCOLOR = Color.new(160, 64, 64)

RED = FEMALETEXTCOLOR
RED1 = FEMALETEXTSHADOWCOLOR
YELLOW = Color.new(255,188,15)
YELLOW1 = Color.new(175,126,0)
GREEN = Color.new(15,255,28)
GREEN1 = Color.new(0, 175, 9)

PANEL_HEIGHT = 222
MALE_TEXT_COLOR = MALETEXTCOLOR
MALE_TEXT_SHADOW_COLOR = MALETEXTSHADOWCOLOR
FEMALE_TEXT_COLOR = FEMALETEXTCOLOR
FEMALE_TEXT_SHADOW_COLOR = FEMALETEXTSHADOWCOLOR

def initialize(index, title, isContinue, trainer, framecount, stats, mapid, viewport = nil)
    super(viewport)
    @index = index
    @title = title
    @isContinue = isContinue
    @trainer = trainer
    @totalsec = (stats) ? stats.play_time.to_i : ((framecount || 0) / Graphics.frame_rate)
    @mapid = mapid
    @selected = (index == 0)
    @refreshBitmap = true
    initialize_bitmap
    refresh
end

def gvar_data
    @Gvar
end

def dispose
    @bgbitmap.dispose
    self.bitmap.dispose
    super
end

def selected=(value)
    return if @selected == value
    @selected = value
    @refreshBitmap = true
    refresh
end

def refreshBitmap
    @refreshBitmap = true
    refresh
end

def refresh
    return if @refreshing
    return if disposed?
    @refreshing = true
    if !self.bitmap || self.bitmap.disposed?
    self.bitmap = BitmapWrapper.new(@bgbitmap.width, PANEL_HEIGHT)
    pbSetSystemFont(self.bitmap)
    end
    if @refreshBitmap
    @refreshBitmap = false
    self.bitmap&.clear
    if @isContinue
        self.bitmap.blt(0, 0, @bgbitmap.bitmap, Rect.new(0, (@selected) ? PANEL_HEIGHT : 0, @bgbitmap.width, PANEL_HEIGHT))
    else
        self.bitmap.blt(0, 0, @bgbitmap.bitmap, Rect.new(0, 444 + ((@selected) ? 46 : 0), @bgbitmap.width, 46))
    end
    textpos = []
    position_x = [512 - 16, 16]
    position_y = [18, 14 * 3 + 6, 14 * 5 + 8, 14 * 7 + 8, 14 * 9 + 8]

    if @isContinue
        #.money.to_s_formatted
        mapname = pbGetMapNameFromId(@mapid)
        mapname.gsub!(/\\PN/, @trainer.name)
        textpos.push(["Map: " + mapname, position_x[1], position_y[2], 0, TEXTCOLOR, TEXTSHADOWCOLOR, true])
        textpos.push(["Name: #{@trainer.name}", position_x[1], position_y[1], 0, (@trainer.male? ? MALE_TEXT_COLOR : (@trainer.female? ? FEMALE_TEXT_COLOR : TEXTCOLOR)), (@trainer.male? ? MALE_TEXT_SHADOW_COLOR : (@trainer.female? ? FEMALE_TEXT_SHADOW_COLOR : TEXTSHADOWCOLOR)), true])
        textpos.push([@title, position_x[1], position_y[0], 0, TEXTCOLOR, TEXTSHADOWCOLOR, true])
        #dark_color, light_color = SysFixData.rank_colors(@trainer.badge_count)
        #textpos.push(["Rank: " + SysFixData::Rname[@trainer.badge_count].to_s, position_x[1], position_y[3], 0, light_color, dark_color, true])
        #diff_dark_color, diff_light_color = SysFixData.diff_colors(DataStorage::Difficulties)
        #textpos.push(["Difficulty: " + SysFixData::Dnames[DataStorage::Difficulties].to_s, position_x[0], position_y[2], 1, diff_light_color, diff_dark_color, true])
        textpos.push(["Player ID: " + @trainer.public_ID.to_s, position_x[1], position_y[3], 0, TEXTCOLOR, TEXTSHADOWCOLOR, true])
        textpos.push(["Player Money: $" + @trainer.money.to_s_formatted, position_x[0],position_y[4],1,(@trainer.money <= 0) ? RED : (@trainer.money <= 5000) ? YELLOW : GREEN,(@trainer.money <= 500) ? RED1 : (@trainer.money <= 1500) ? YELLOW1 : GREEN1 ,true])
        hour = @totalsec / 60 / 60
        min = @totalsec / 60 % 60
        textpos.push([_INTL("Time: {1}h {2}m", hour, min), position_x[1], position_y[4], 0, TEXTCOLOR, TEXTSHADOWCOLOR, true]) if hour > 0
        textpos.push([_INTL("Time: {1}m", min), position_x[1], position_y[4], 0, TEXTCOLOR, TEXTSHADOWCOLOR, true]) if hour <= 0
    else
        textpos.push([@title, position_x[1], 14, 0, TEXTCOLOR, TEXTSHADOWCOLOR, true])
    end
    pbDrawTextPositions(self.bitmap, textpos)
    end
    @refreshing = false
end

def initialize_bitmap
    @bgbitmap = AnimatedBitmap.new("Graphics/Pictures/UI/LoadUI/loadPanels")
end
end

class PokemonLoad_Scene

TEXTCOLOR = Color.new(148, 15, 255)
TEXTSHADOWCOLOR = Color.new(99, 0, 180)
MALETEXTCOLOR = Color.new(56, 160, 248)
MALETEXTSHADOWCOLOR = Color.new(56, 104, 168)
FEMALETEXTCOLOR = Color.new(255, 56, 60)
FEMALETEXTSHADOWCOLOR = Color.new(160, 64, 64)

def pbStartScene(commands, show_continue, trainer, frame_count, stats, map_id)
    @commands = commands
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @overlaysprite = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @overlaysprite.z = 11
    @selected_save_index = 0
    pbSetSystemFont(@overlaysprite.bitmap)
    pbSetSmallFont(@overlaysprite.bitmap)
    # overlay controls
    pbDrawTextPositions(@overlaysprite.bitmap,[["Switch Save: [A/D]", Graphics.width - 2, 6, 1, TEXTCOLOR, TEXTSHADOWCOLOR, true]])
    pbDrawTextPositions(@overlaysprite.bitmap,[["Navigate: [W/S]", Graphics.width - 2, 30, 1, TEXTCOLOR, TEXTSHADOWCOLOR, true]])
    pbDrawTextPositions(@overlaysprite.bitmap,[["Confirm: [E]", Graphics.width - 2, 54, 1, TEXTCOLOR, TEXTSHADOWCOLOR, true]])
    
    pbSetSystemFont(@overlaysprite.bitmap) #@overlayspritetext
    addBackgroundOrColoredPlane(@sprites, "background", $bgPath, Color.new(248, 248, 248), @viewport)
    y = 10 #10
    commands.length.times do |i|
    @sprites["panel#{i}"] = PokemonLoadPanel.new(
        i, commands[i], (show_continue) ? (i == 0) : false, trainer, frame_count, stats, map_id, @viewport
    )
    @sprites["panel#{i}"].x = Graphics.width - (256*2.5) #@sprites["panel#{i}"].x = 48
    @sprites["panel#{i}"].y = y
    @sprites["panel#{i}"].refreshBitmap
    y += (show_continue && i == 0) ? 224 : 48

    end
    @sprites["cmdwindow"] = Window_CommandPokemon.new([])
    @sprites["cmdwindow"].viewport = @viewport
    @sprites["cmdwindow"].visible = false
end

def pbStartScene2
    pbFadeInAndShow(@sprites) { pbUpdate }
end

def pbStartDeleteScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    addBackgroundOrColoredPlane(@sprites, "background", "UI/LoadUI/bg", Color.new(248, 248, 248), @viewport)
end

def pbUpdate
    oldi = @sprites["cmdwindow"].index rescue 0
    pbUpdateSpriteHash(@sprites)
    newi = @sprites["cmdwindow"].index rescue 0
    @sprites["background"].ox += 1
    @sprites["background"].oy += 1
    if oldi != newi
        @sprites["panel#{oldi}"].selected = false
        @sprites["panel#{oldi}"].refreshBitmap
        @sprites["panel#{newi}"].selected = true
        @sprites["panel#{newi}"].refreshBitmap
        while @sprites["panel#{newi}"].y > Graphics.height - 52 #80
            @commands.length.times do |i|
                @sprites["panel#{i}"].y -= 10
            end
            6.times do |i|
            break if !@sprites["party#{i}"]
                @sprites["party#{i}"].y -= 10
            end
        end
        while @sprites["panel#{newi}"].y < 10 #32
            @commands.length.times do |i|
                @sprites["panel#{i}"].y += 10
            end
            6.times do |i|
            break if !@sprites["party#{i}"]
                @sprites["party#{i}"].y += 10
            end
        end
    end
end

def pbSetParty(trainer)
    return if !trainer || !trainer.party
    trainer.party.each_with_index do |pkmn, i|
    @sprites["party#{i}"] = PokemonIconSprite.new(pkmn, @viewport)
    @sprites["party#{i}"].setOffset(PictureOrigin::CENTER)
    @sprites["party#{i}"].x = 164 + (62 * (i % 8))
    @sprites["party#{i}"].y = 202
    @sprites["party#{i}"].z = 99999
    end
end

def pbChoose(commands)
    @sprites["cmdwindow"].commands = commands
    loop do
    Graphics.update
    Input.update
    pbUpdate
    if Input.trigger?(Input::USE)
        return @sprites["cmdwindow"].index
    end
    end
end

def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
end

def pbCloseScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
end
end

#===============================================================================
#
#===============================================================================
class PokemonLoadScreen
def initialize(scene)
    @scene = scene
    if SaveData.exists?
    @save_data = load_save_file(SaveData::FILE_PATH)
    else
    @save_data = {}
    end
end

def load_save_file(file_path)
    save_data = SaveData.read_from_file(file_path)
    unless SaveData.valid?(save_data)
    if File.file?(file_path + ".bak")
        pbMessage(_INTL("The save file is corrupt. A backup will be loaded."))
        save_data = load_save_file(file_path + ".bak")
    else
        prompt_save_deletion
        return {}
    end
    end
    return save_data
end

def prompt_save_deletion
    pbMessage(_INTL("The save file is corrupt, or is incompatible with this game."))
    exit unless pbConfirmMessageSerious(
    _INTL("Do you want to delete the save file and start anew?")
    )
    delete_save_data
    $game_system = Game_System.new
    $PokemonSystem = PokemonSystem.new
end

def pbStartDeleteScreen
    @scene.pbStartDeleteScene
    @scene.pbStartScene2
    if SaveData.exists?
    if pbConfirmMessageSerious(_INTL("Delete all saved data?"))
        pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
        if pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
        pbMessage(_INTL("Deleting all data. Don't turn off the power.\\wtnp[0]"))
        delete_save_data
        end
    end
    else
    pbMessage(_INTL("No save file was found."))
    end
    @scene.pbEndScene
    $scene = pbCallTitle
end

def delete_save_data
    begin
    SaveData.delete_file
    pbMessage(_INTL("The saved data was deleted."))
    rescue SystemCallError
    pbMessage(_INTL("All saved data could not be deleted."))
    end
end

def pbStartLoadScreen
    commands = []
    cmd_continue = -1
    cmd_new_game = -1
    cmd_options = -1 #-1
    cmd_language = -1
    cmd_mystery_gift = -1
    cmd_debug = -1
    cmd_quit = -1
    show_continue = !@save_data.empty?
    if show_continue
    commands[cmd_continue = commands.length] = _INTL("Continue")
    if @save_data[:player].mystery_gift_unlocked
        commands[cmd_mystery_gift = commands.length] = _INTL("Mystery Gift")
    end
    end
    commands[cmd_new_game = commands.length] = _INTL("New Game")
    commands[cmd_options = commands.length] = _INTL("Options")
    commands[cmd_language = commands.length] = _INTL("Language") if Settings::LANGUAGES.length >= 2
    commands[cmd_debug = commands.length] = _INTL("Debug") if $DEBUG
    commands[cmd_quit = commands.length] = _INTL("Quit Game")
    map_id = show_continue ? @save_data[:map_factory].map.map_id : 0
    @scene.pbStartScene(commands, show_continue, @save_data[:player],
    #@save_data[:frame_count] || 0, @save_data[:stats], map_id)
    @save_data[:frame_count] || 0, @save_data[:stats], map_id)
    @scene.pbSetParty(@save_data[:player]) if show_continue
    @scene.pbStartScene2
    loop do
    command = @scene.pbChoose(commands)
    pbPlayDecisionSE if command != cmd_quit
    case command
    when cmd_continue
        @scene.pbEndScene
        Game.load(@save_data)
        return
    when cmd_new_game
        @scene.pbEndScene
        Game.start_new
        return
    when cmd_mystery_gift
        pbFadeOutIn { pbDownloadMysteryGift(@save_data[:player]) }
    when cmd_options
        pbFadeOutIn do
        scene = PokemonOption_Scene.new
        screen = PokemonOptionScreen.new(scene)
        screen.pbStartScreen(true)
        end
    when cmd_language
        @scene.pbEndScene
        $PokemonSystem.language = pbChooseLanguage
        pbLoadMessages("Data/" + Settings::LANGUAGES[$PokemonSystem.language][1])
        if show_continue
        @save_data[:pokemon_system] = $PokemonSystem
        File.open(SaveData::FILE_PATH, "wb") { |file| Marshal.dump(@save_data, file) }
        end
        $scene = pbCallTitle
        return
    when cmd_debug
        pbFadeOutIn { pbDebugMenu(false) }
    when cmd_quit
        pbPlayCloseMenuSE
        @scene.pbEndScene
        $scene = nil
        return
    else
        pbPlayBuzzerSE
    end
    end
end
end