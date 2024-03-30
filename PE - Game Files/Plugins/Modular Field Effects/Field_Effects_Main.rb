=begin
#To set your field effects, do one of these:
#Set it to be set as a move or ability
#In a parallel process event on the map, use setBattleRule("defaultField",:FieldEffect)

module GameData
  class FieldEffects
    attr_reader :id
    attr_reader :real_name

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id        = hash[:id]
      @real_name = hash[:name] || "Unnamed"
    end

    # @return [String] the translated name of this field effect
    def name
      return _INTL(@real_name)
    end
  end
end

#Define all your Field Effects here

GameData::FieldEffects.register({
  :id   => :None,
  :name => _INTL("None")
})

#Define Environments to match your Field Effects here

GameData::Environment.register({
  :id          => :None,
  :name        => _INTL("None"),
  :battle_base => "grass_night"
})


class Fields
  sound = []
  pulse = []
  moves = pbLoadMovesData
  for move in moves
    next if move == nil
    m = move[1].to_sym
    mv = Battle::Move.from_pokemon_move(@battle,Pokemon::Move.new(GameData::Move.try_get(m)))
    sound.push(m) if mv.flags[/k/]
  end
  SOUND_MOVES = sound
  IGNITE_MOVES = [:EMBER,:ERUPTION]
  #These are examples of arrays you can make for moves that will affect or be affected by a field effect
end

class Game_Temp
  def add_battle_rule(rule, var = nil)
    rules = self.battle_rules
    case rule.to_s.downcase
    when "single", "1v1", "1v2", "2v1", "1v3", "3v1",
         "double", "2v2", "2v3", "3v2", "triple", "3v3"
      rules["size"] = rule.to_s.downcase
    when "canlose"                then rules["canLose"]             = true
    when "cannotlose"             then rules["canLose"]             = false
    when "canrun"                 then rules["canRun"]              = true
    when "cannotrun"              then rules["canRun"]              = false
    when "roamerflees"            then rules["roamerFlees"]         = true
    when "noexp"                  then rules["expGain"]             = false
    when "nomoney"                then rules["moneyGain"]           = false
    when "disablepokeballs"       then rules["disablePokeBalls"]    = true
    when "forcecatchintoparty"    then rules["forceCatchIntoParty"] = true
    when "switchstyle"            then rules["switchStyle"]         = true
    when "setstyle"               then rules["switchStyle"]         = false
    when "anims"                  then rules["battleAnims"]         = true
    when "noanims"                then rules["battleAnims"]         = false
    when "terrain"
      rules["defaultTerrain"] = GameData::BattleTerrain.try_get(var)&.id
    when "weather"
      rules["defaultWeather"] = GameData::BattleWeather.try_get(var)&.id
    when "field"
      rules["defaultField"] = GameData::FieldEffects.try_get(var)&.id
    when "environment", "environ"
      rules["environment"] = GameData::Environment.try_get(var)&.id
    when "backdrop", "battleback" then rules["backdrop"]            = var
    when "base"                   then rules["base"]                = var
    when "outcome", "outcomevar"  then rules["outcomeVar"]          = var
    when "nopartner"              then rules["noPartner"]           = true
    when "inversebattle"          then rules["inverseBattle"] = true
    else
      raise _INTL("Battle rule \"{1}\" does not exist.", rule)
    end
	$game_screen.field_effects(rules["defaultfield"])
	$PokemonGlobal.nextBattleBack = FIELD_EFFECTS[rules["defaultField"]][:field_gfx]
  end
end

def setBattleRule(*args)
  r = nil
  args.each do |arg|
    if r
      $game_temp.add_battle_rule(r, arg)
      r = nil
    else
      case arg.downcase
      when "terrain", "weather", "environment", "environ", "backdrop",
           "battleback", "base", "outcome", "outcomevar","field"
        r = arg
        next
      end
      $game_temp.add_battle_rule(arg)
    end
  end
  raise _INTL("Argument {1} expected a variable after it but didn't have one.", r) if r
end

module BattleCreationHelperMethods
  def prepare_battle(battle)
    battleRules = $game_temp.battle_rules
    # The size of the battle, i.e. how many Pokémon on each side (default: "single")
    battle.setBattleMode(battleRules["size"]) if !battleRules["size"].nil?
    # Whether the game won't black out even if the player loses (default: false)
    battle.canLose = battleRules["canLose"] if !battleRules["canLose"].nil?
    # Whether the player can choose to run from the battle (default: true)
    battle.canRun = battleRules["canRun"] if !battleRules["canRun"].nil?
    # Whether wild Pokémon always try to run from battle (default: nil)
    battle.rules["alwaysflee"] = battleRules["roamerFlees"]
    # Whether Pokémon gain Exp/EVs from defeating/catching a Pokémon (default: true)
    battle.expGain = battleRules["expGain"] if !battleRules["expGain"].nil?
    # Whether the player gains/loses money at the end of the battle (default: true)
    battle.moneyGain = battleRules["moneyGain"] if !battleRules["moneyGain"].nil?
    # Whether Poké Balls cannot be thrown at all
    battle.disablePokeBalls = battleRules["disablePokeBalls"] if !battleRules["disablePokeBalls"].nil?
    # Whether the player is asked what to do with a new Pokémon when their party is full
    battle.sendToBoxes = $PokemonSystem.sendtoboxes if Settings::NEW_CAPTURE_CAN_REPLACE_PARTY_MEMBER
    battle.sendToBoxes = 2 if battleRules["forceCatchIntoParty"]
    # Whether the player is able to switch when an opponent's Pokémon faints
    battle.switchStyle = ($PokemonSystem.battlestyle == 0)
    battle.switchStyle = battleRules["switchStyle"] if !battleRules["switchStyle"].nil?
    # Whether battle animations are shown
    battle.showAnims = ($PokemonSystem.battlescene == 0)
    battle.showAnims = battleRules["battleAnims"] if !battleRules["battleAnims"].nil?
    # Terrain
    if battleRules["defaultTerrain"].nil? && Settings::OVERWORLD_WEATHER_SETS_BATTLE_TERRAIN
      case $game_screen.weather_type
      when :Storm
        battle.defaultTerrain = :Electric
      when :Fog
        battle.defaultTerrain = :Misty
      end
    else
      battle.defaultTerrain = battleRules["defaultTerrain"]
    end
    # Weather
    if battleRules["defaultWeather"].nil?
      case GameData::Weather.get($game_screen.weather_type).category
      when :Rain, :Storm
        battle.defaultWeather = :Rain
      when :Hail
        battle.defaultWeather = :Hail
      when :Sandstorm
        battle.defaultWeather = :Sandstorm
      when :Sun
        battle.defaultWeather = :Sun
      end
    else
      battle.defaultWeather = battleRules["defaultWeather"]
    end
    if battleRules["defaultField"].nil?
	  battle.defaultField = $game_screen.field_effects == nil ? :None : $game_screen.field_effects
    else
      battle.defaultField = battleRules["defaultField"]
    end
    # Environment
    if battleRules["environment"].nil?
      battle.environment = pbGetEnvironment
    else
      battle.environment = battleRules["environment"]
    end
    # Backdrop graphic filename
    if !battleRules["backdrop"].nil?
      backdrop = battleRules["backdrop"]
    elsif $PokemonGlobal.nextBattleBack
      backdrop = $PokemonGlobal.nextBattleBack
    elsif $PokemonGlobal.surfing
      backdrop = "water"   # This applies wherever you are, including in caves
    elsif $game_map.metadata
      back = $game_map.metadata.battle_background
      backdrop = back if back && back != ""
    end
    backdrop = "indoor1" if !backdrop
    battle.backdrop = backdrop
    # Choose a name for bases depending on environment
    if battleRules["base"].nil?
      environment_data = GameData::Environment.try_get(battle.environment)
      base = environment_data.battle_base if environment_data
    else
      base = battleRules["base"]
    end
    battle.backdropBase = base if base
    # Time of day
    if $game_map.metadata&.battle_environment == :Cave
      battle.time = 2   # This makes Dusk Balls work properly in caves
    elsif Settings::TIME_SHADING
      timeNow = pbGetTimeNow
      if PBDayNight.isNight?(timeNow)
        battle.time = 2
      elsif PBDayNight.isEvening?(timeNow)
        battle.time = 1
      else
        battle.time = 0
      end
    end
  end
end

class Game_Screen
  attr_reader   :field_effects
  alias initialize_field initialize
  def initialize
    initialize_field
    @field_effects = :None
  end
  def field_effect(type)
    @field_effects = GameData::FieldEffects.try_get(type).id
  end
end

class Battle::ActiveField
  attr_accessor :defaultField
  attr_accessor :field_effects
  alias initialize_field initialize
  def initialize
    initialize_field
    @effects[PBEffects::EchoChamber] = 0
    default_field_effects = :None
    field_effects = :None
  end
end

class Battle
  def pbSendOut(sendOuts, startBattle = false)
    sendOuts.each { |b| @peer.pbOnEnteringBattle(self, @battlers[b[0]], b[1]) }
    @scene.pbSendOutBattlers(sendOuts, startBattle)
    sendOuts.each do |b|
      @scene.pbResetMoveIndex(b[0])
      pbSetSeen(@battlers[b[0]])
      @usedInBattle[b[0] & 1][b[0] / 2] = true
	  case @field.field_effects
	  #This is here in case you want a field effect gimmick to activate on battle start
	  end
    end
  end
  def pbEORTerrainHealing(battler)
    return if battler.fainted?
    # Grassy Terrain (healing)
    if @field.terrain == :Grassy && battler.affectedByTerrain? && battler.canHeal?
      PBDebug.log("[Lingering effect] Grassy Terrain heals #{battler.pbThis(true)}")
      battler.pbRecoverHP(battler.totalhp / 16)
      pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    end
	#Field Effects
    
  end
  def defaultField=(value)
    @field.defaultField  = value
    @field.field_effects         = value
  end
  def pbStartFieldEffect(user, newField)
    return if @field.field_effects == newField
    @field.field_effects = newField
    field_data = GameData::FieldEffects.try_get(@field.field_effects)
	msg = FIELD_EFFECTS[newField][:intro_message]
  	bg = FIELD_EFFECTS[newField][:field_gfx]
    pbDisplay(_INTL(msg)) if msg != nil
  	$field_effect_bg = bg
	pbHideAbilitySplash(user) if user
  	@scene.pbRefreshEverything
	fe = FIELD_EFFECTS[newField]
    # Check for abilities/items that trigger upon the terrain changing
  end
  def pbStartWeather(user, newWeather, fixedDuration = false, showAnim = true)
    return if @field.weather == newWeather
    @field.weather = newWeather
    duration = (fixedDuration) ? 5 : -1
    if duration > 0 && user && user.itemActive?
      duration = Battle::ItemEffects.triggerWeatherExtender(user.item, @field.weather,
                                                            duration, user, self)
    end
    @field.weatherDuration = duration
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if showAnim && weather_data
    pbHideAbilitySplash(user) if user
    case @field.weather
    when :Sun         then pbDisplay(_INTL("The sunlight turned harsh!"))
    when :Rain        then pbDisplay(_INTL("It started to rain!"))
    when :Sandstorm   then pbDisplay(_INTL("A sandstorm brewed!"))
    when :Hail        then pbDisplay(_INTL("It started to hail!"))
    when :HarshSun    then pbDisplay(_INTL("The sunlight turned extremely harsh!"))
    when :HeavyRain   then pbDisplay(_INTL("A heavy rain began to fall!"))
    when :StrongWinds then pbDisplay(_INTL("Mysterious strong winds are protecting Flying-type Pokémon!"))
    when :ShadowSky   then pbDisplay(_INTL("A shadow sky appeared!"))
    end
	
    case @field.field_effects
		#add changes to fields when weather changes here
    end
    # Check for end of primordial weather, and weather-triggered form changes
    allBattlers.each { |b| b.pbCheckFormOnWeatherChange }
    pbEndPrimordialWeather
  end
  def pbStartBattleCore
    # Set up the battlers on each side
    @field.field_effects = $game_screen.field_effects
    $field_effect_bg = nil
    sendOuts = pbSetUpSides
    # Create all the sprites and play the battle intro animation
    @scene.pbStartBattle(self)
    # Show trainers on both sides sending out Pokémon
    pbStartBattleSendOut(sendOuts)	
    # Weather announcement
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if weather_data
    case @field.weather
    when :Sun         then pbDisplay(_INTL("The sunlight is strong."))
    when :Rain        then pbDisplay(_INTL("It is raining."))
    when :Sandstorm   then pbDisplay(_INTL("A sandstorm is raging."))
    when :Hail        then pbDisplay(_INTL("Hail is falling."))
    when :HarshSun    then pbDisplay(_INTL("The sunlight is extremely harsh."))
    when :HeavyRain   then pbDisplay(_INTL("It is raining heavily."))
    when :StrongWinds then pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky   then pbDisplay(_INTL("The sky is shadowy."))
    end
    # Terrain announcement
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    case @field.terrain
    when :Electric
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
    when :Grassy
      pbDisplay(_INTL("Grass is covering the battlefield!"))
    when :Misty
      pbDisplay(_INTL("Mist swirls about the battlefield!"))
    when :Psychic
      pbDisplay(_INTL("The battlefield is weird!"))
    end
	fe = @field.field_effects == :None ? nil : FIELD_EFFECTS[@field.field_effects]
	if fe[:intro_message] != nil
		pbDisplay(_INTL(fe[:intro_message]))
	end
	case fe[:intro_script]
	#add your intro scripts here for certain gimmicks the field effect can start the battle with, like weather or terrain
	end
			
    # Abilities upon entering battle
    pbOnAllBattlersEnteringBattle
    # Main battle loop
    pbBattleLoop
  end
  def pbEORField(battler)
    return if battler.fainted?
    amt = -1
	fe = FIELD_EFFECTS[@field.field_effects]
    #add damage done at the end of the field by field effects
    return if amt < 0
    @scene.pbDamageAnimation(battler)
    battler.pbReduceHP(amt, false)
    battler.pbItemHPHealCheck
    battler.pbFaint if battler.fainted?
  end
  def pbEndOfRoundPhase
    PBDebug.log("")
    PBDebug.log("[End of round]")
    @endOfRound = true
    @scene.pbBeginEndOfRoundPhase
    pbCalculatePriority           # recalculate speeds
    priority = pbPriority(true)   # in order of fastest -> slowest speeds only
    # Weather
    pbEOREndWeather(priority)
    # Future Sight/Doom Desire
    @positions.each_with_index { |pos, idxPos| pbEORUseFutureSight(pos, idxPos) }
    # Wish
    pbEORWishHealing
    # Sea of Fire damage (Fire Pledge + Grass Pledge combination)
    pbEORSeaOfFireDamage(priority)
    # Status-curing effects/abilities and HP-healing items
    priority.each do |battler|
      #Field Effects
      pbEORField(battler)
      #Terrain Healing
      pbEORTerrainHealing(battler)
      # Healer, Hydration, Shed Skin
      if battler.abilityActive?
        Battle::AbilityEffects.triggerEndOfRoundHealing(battler.ability, battler, self)
      end
      # Black Sludge, Leftovers
      if battler.itemActive?
        Battle::ItemEffects.triggerEndOfRoundHealing(battler.item, battler, self)
      end
    end
    # Self-curing of status due to affection
    if Settings::AFFECTION_EFFECTS && @internalBattle
      priority.each do |battler|
        next if battler.fainted? || battler.status == :NONE
        next if !battler.pbOwnedByPlayer? || battler.affection_level < 4 || battler.mega?
        next if pbRandom(100) < 80
        old_status = battler.status
        battler.pbCureStatus(false)
        case old_status
        when :SLEEP
          pbDisplay(_INTL("{1} shook itself awake so you wouldn't worry!", battler.pbThis))
        when :POISON
          pbDisplay(_INTL("{1} managed to expel the poison so you wouldn't worry!", battler.pbThis))
        when :BURN
          pbDisplay(_INTL("{1} healed its burn with its sheer determination so you wouldn't worry!", battler.pbThis))
        when :PARALYSIS
          pbDisplay(_INTL("{1} gathered all its energy to break through its paralysis so you wouldn't worry!", battler.pbThis))
        when :FROZEN
          pbDisplay(_INTL("{1} melted the ice with its fiery determination so you wouldn't worry!", battler.pbThis))
        end
      end
    end
    # Healing from Aqua Ring, Ingrain, Leech Seed
    pbEORHealingEffects(priority)
    # Damage from Hyper Mode (Shadow Pokémon)
    priority.each do |battler|
      next if !battler.inHyperMode? || @choices[battler.index][0] != :UseMove
      hpLoss = battler.totalhp / 24
      @scene.pbDamageAnimation(battler)
      battler.pbReduceHP(hpLoss, false)
      pbDisplay(_INTL("The Hyper Mode attack hurts {1}!", battler.pbThis(true)))
      battler.pbFaint if battler.fainted?
    end
    # Damage from poison/burn
    pbEORStatusProblemDamage(priority)
    # Damage from Nightmare and Curse
    pbEOREffectDamage(priority)
    # Trapping attacks (Bind/Clamp/Fire Spin/Magma Storm/Sand Tomb/Whirlpool/Wrap)
    priority.each { |battler| pbEORTrappingDamage(battler) }
    # Octolock
    priority.each do |battler|
      next if battler.fainted? || battler.effects[PBEffects::Octolock] < 0
      pbCommonAnimation("Octolock", battler)
      battler.pbLowerStatStage(:DEFENSE, 1, nil) if battler.pbCanLowerStatStage?(:DEFENSE)
      battler.pbLowerStatStage(:SPECIAL_DEFENSE, 1, nil) if battler.pbCanLowerStatStage?(:SPECIAL_DEFENSE)
      battler.pbItemOnStatDropped
    end
    # Effects that apply to a battler that wear off after a number of rounds
    pbEOREndBattlerEffects(priority)
    # Check for end of battle (i.e. because of Perish Song)
    if @decision > 0
      pbGainExp
      return
    end
    # Effects that apply to a side that wear off after a number of rounds
    2.times { |side| pbEOREndSideEffects(side, priority) }
    # Effects that apply to the whole field that wear off after a number of rounds
    pbEOREndFieldEffects(priority)
    # End of terrains
    pbEOREndTerrain
    priority.each do |battler|
      # Self-inflicted effects that wear off after a number of rounds
      pbEOREndBattlerSelfEffects(battler)
      # Bad Dreams, Moody, Speed Boost
      if battler.abilityActive?
        Battle::AbilityEffects.triggerEndOfRoundEffect(battler.ability, battler, self)
      end
      # Flame Orb, Sticky Barb, Toxic Orb
      if battler.itemActive?
        Battle::ItemEffects.triggerEndOfRoundEffect(battler.item, battler, self)
      end
      # Harvest, Pickup, Ball Fetch
      if battler.abilityActive?
        Battle::AbilityEffects.triggerEndOfRoundGainItem(battler.ability, battler, self)
      end
    end
    pbGainExp
    return if @decision > 0
    # Form checks
    priority.each { |battler| battler.pbCheckForm(true) }
    # Switch Pokémon in if possible
    pbEORSwitch
    return if @decision > 0
    # In battles with at least one side of size 3+, move battlers around if none
    # are near to any foes
    pbEORShiftDistantBattlers
    # Try to make Trace work, check for end of primordial weather
    priority.each { |battler| battler.pbContinualAbilityChecks }
    # Reset/count down battler-specific effects (no messages)
    allBattlers.each do |battler|
      battler.effects[PBEffects::BanefulBunker]    = false
      battler.effects[PBEffects::Charge]           -= 1 if battler.effects[PBEffects::Charge] > 0
      battler.effects[PBEffects::Counter]          = -1
      battler.effects[PBEffects::CounterTarget]    = -1
      battler.effects[PBEffects::Electrify]        = false
      battler.effects[PBEffects::Endure]           = false
      battler.effects[PBEffects::FirstPledge]      = nil
      battler.effects[PBEffects::Flinch]           = false
      battler.effects[PBEffects::FocusPunch]       = false
      battler.effects[PBEffects::FollowMe]         = 0
      battler.effects[PBEffects::HelpingHand]      = false
      battler.effects[PBEffects::HyperBeam]        -= 1 if battler.effects[PBEffects::HyperBeam] > 0
      battler.effects[PBEffects::KingsShield]      = false
      battler.effects[PBEffects::LaserFocus]       -= 1 if battler.effects[PBEffects::LaserFocus] > 0
      if battler.effects[PBEffects::LockOn] > 0   # Also Mind Reader
        battler.effects[PBEffects::LockOn]         -= 1
        battler.effects[PBEffects::LockOnPos]      = -1 if battler.effects[PBEffects::LockOn] == 0
      end
      battler.effects[PBEffects::MagicBounce]      = false
      battler.effects[PBEffects::MagicCoat]        = false
      battler.effects[PBEffects::MirrorCoat]       = -1
      battler.effects[PBEffects::MirrorCoatTarget] = -1
      battler.effects[PBEffects::Obstruct]         = false
      battler.effects[PBEffects::Powder]           = false
      battler.effects[PBEffects::Prankster]        = false
      battler.effects[PBEffects::PriorityAbility]  = false
      battler.effects[PBEffects::PriorityItem]     = false
      battler.effects[PBEffects::Protect]          = false
      battler.effects[PBEffects::RagePowder]       = false
      battler.effects[PBEffects::Snatch]           = 0
      battler.effects[PBEffects::SpikyShield]      = false
      battler.effects[PBEffects::Spotlight]        = 0
      battler.effects[PBEffects::ThroatChop]       -= 1 if battler.effects[PBEffects::ThroatChop] > 0
      battler.lastHPLost                           = 0
      battler.lastHPLostFromFoe                    = 0
      battler.droppedBelowHalfHP                   = false
      battler.statsDropped                         = false
      battler.tookDamageThisRound                  = false
      battler.tookPhysicalHit                      = false
      battler.statsRaisedThisRound                 = false
      battler.statsLoweredThisRound                = false
      battler.canRestoreIceFace                    = false
      battler.lastRoundMoveFailed                  = battler.lastMoveFailed
      battler.lastAttacker.clear
      battler.lastFoeAttacker.clear
    end
    # Reset/count down side-specific effects (no messages)
    2.times do |side|
      @sides[side].effects[PBEffects::CraftyShield]         = false
      if !@sides[side].effects[PBEffects::EchoedVoiceUsed]
        @sides[side].effects[PBEffects::EchoedVoiceCounter] = 0
      end
      @sides[side].effects[PBEffects::EchoedVoiceUsed]      = false
      @sides[side].effects[PBEffects::MatBlock]             = false
      @sides[side].effects[PBEffects::QuickGuard]           = false
      @sides[side].effects[PBEffects::Round]                = false
      @sides[side].effects[PBEffects::WideGuard]            = false
    end
    # Reset/count down field-specific effects (no messages)
    @field.effects[PBEffects::IonDeluge]   = false
    @field.effects[PBEffects::FairyLock]   -= 1 if @field.effects[PBEffects::FairyLock] > 0
    @field.effects[PBEffects::FusionBolt]  = false
    @field.effects[PBEffects::FusionFlare] = false
    @endOfRound = false
  end
end

class Battle::Battler
 #Save this class here in case you want to use these for modifying certain methods for the field
end

#Field Changes due to Move Usage
class Battle::Scene
  def pbCreateBackdropSprites
    case @battle.time
    when 1 then time = "eve"
    when 2 then time = "night"
    end
    # Put everything together into backdrop, bases and message bar filenames
    @battle.backdrop = $field_effect_bg if $field_effect_bg != nil
    @battle.backdropBase = $field_effect_bg if $field_effect_bg != nil
    backdropFilename = @battle.backdrop
    baseFilename = @battle.backdrop
    baseFilename = sprintf("%s_%s", baseFilename, @battle.backdropBase) if @battle.backdropBase
    messageFilename = @battle.backdrop
    if time
      trialName = sprintf("%s_%s", backdropFilename, time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_bg"))
        backdropFilename = trialName
      end
      trialName = sprintf("%s_%s", baseFilename, time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_base0"))
        baseFilename = trialName
      end
      trialName = sprintf("%s_%s", messageFilename, time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_message"))
        messageFilename = trialName
      end
    end
    if !pbResolveBitmap(sprintf("Graphics/Battlebacks/" + baseFilename + "_base0")) &&
       @battle.backdropBase
      baseFilename = @battle.backdropBase
      if time
        trialName = sprintf("%s_%s", baseFilename, time)
        if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_base0"))
          baseFilename = trialName
        end
      end
    end
    # Finalise filenames
    battleBG   = "Graphics/Battlebacks/" + backdropFilename + "_bg"
    playerBase = "Graphics/Battlebacks/" + baseFilename + "_base0"
    enemyBase  = "Graphics/Battlebacks/" + baseFilename + "_base1"
    messageBG  = "Graphics/Battlebacks/" + messageFilename + "_message"
    # Apply graphics
    bg = pbAddSprite("battle_bg", 0, 0, battleBG, @viewport)
    bg.z = 0
    bg = pbAddSprite("battle_bg2", -Graphics.width, 0, battleBG, @viewport)
    bg.z      = 0
    bg.mirror = true
    2.times do |side|
      baseX, baseY = Battle::Scene.pbBattlerPosition(side)
      base = pbAddSprite("base_#{side}", baseX, baseY,
                         (side == 0) ? playerBase : enemyBase, @viewport)
      base.z = 1
      if base.bitmap
        base.ox = base.bitmap.width / 2
        base.oy = (side == 0) ? base.bitmap.height : base.bitmap.height / 2
      end
    end
    cmdBarBG = pbAddSprite("cmdBar_bg", 0, Graphics.height - 96, messageBG, @viewport)
    cmdBarBG.z = 180
  end
end

class Battle::Move
#Move Accuracy Changes for Field Effects
def pbAccuracyCheck(user, target)
    # "Always hit" effects and "always hit" accuracy
    return true if target.effects[PBEffects::Telekinesis] > 0
    return true if target.effects[PBEffects::Minimize] && tramplesMinimize? && Settings::MECHANICS_GENERATION >= 6
    baseAcc = pbBaseAccuracy(user, target)
    return true if baseAcc == 0
    # Calculate all multiplier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user, target, modifiers)
    # Check if move can't miss
    return true if modifiers[:base_accuracy] == 0
	fe = FIELD_EFFECTS[@battle.field.field_effects]
	if fe[:move_accuracy_change] != nil
		for key in fe[:move_accuracy_change].keys
			if fe[:move_accuracy_change][key].is_a?(Array)
				modifiers[:base_accuracy] = key if fe[:move_accuracy_change][key].include?(self.id)
			else
				modifiers[:base_accuracy] = key if fe[:move_accuracy_change][key] == self.id
			end
		end
	end
	# Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
    stageMul = [3, 3, 3, 3, 3, 3, 3, 4, 5, 6, 7, 8, 9]
    stageDiv = [9, 8, 7, 6, 5, 4, 3, 3, 3, 3, 3, 3, 3]
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
    evasion  = (evasion  * modifiers[:evasion_multiplier]).round
    evasion = 1 if evasion < 1
    threshold = modifiers[:base_accuracy] * accuracy / evasion
    # Calculation
    r = @battle.pbRandom(100)
    if Settings::AFFECTION_EFFECTS && @battle.internalBattle &&
       target.pbOwnedByPlayer? && target.affection_level == 5 && !target.mega?
      return true if r < threshold - 10
      target.damageState.affection_missed = true if r < threshold
      return false
    end
    return r < threshold
  end
def pbCalcType(user)
    @powerBoost = false
    ret = pbBaseType(user)
    if ret && GameData::Type.exists?(:ELECTRIC)
      if @battle.field.effects[PBEffects::IonDeluge] && ret == :NORMAL
        ret = :ELECTRIC
        @powerBoost = false
      end
      if user.effects[PBEffects::Electrify]
        ret = :ELECTRIC
        @powerBoost = false
      end
    end
    #New Field Effect Modifier Method
	if fe[:type_type_mod].keys != nil
		for type_mod in fe[:type_type_mod].keys
			if isConst?(ret,PBTypes,type_mod)
				ret = GameData::Type.get(fe[:type_type_mod][type_mod]).id
				for message in fe[:type_change_message].keys
					if fe[:type_change_message][message].include?(type_mod)
						msg = message
					end
				end
				@battle.pbDisplay(_INTL(msg))
				@powerBoost = false
			end
		end
	end
    return ret
  end
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = Effectiveness.calculate_one(moveType, defType)
    if Effectiveness.ineffective_type?(moveType, defType)
      # Ring Target
      if target.hasActiveItem?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Foresight
      if (user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]) &&
         defType == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Miracle Eye
      if target.effects[PBEffects::MiracleEye] && defType == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
    elsif Effectiveness.super_effective_type?(moveType, defType)
      # Delta Stream's weather
      if target.effectiveWeather == :StrongWinds && defType == :FLYING
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne? && defType == :FLYING && moveType == :GROUND
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE
    end
	fe = FIELD_EFFECTS[@battle.field.field_effects]
	if fe[:type_type_mod] != nil
		for key in fe[:type_type_mod]
			if fe[:type_type_mod][key] == moveType
				eff = Effectiveness.calculate_one(key,defType)
				ret *= eff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
				for mess in fe[:type_mod_message].keys
					pbDisplay(_INTL(mess)) if fe[:type_mod_message][mess] == moveType
				end
			end
		end
	end
	if fe[:move_type_mod] != nil
		for mv in fe[:move_type_mod]
			if fe[:move_type_mod][mv].include?(self.id)
				eff = Effectiveness.calculate_one(mv,defType)
				ret *= eff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
				for msg in fe[:type_mod_message].keys
					pbDisplay(_INTL(msg)) if fe[:type_mod_message][msg].include?(self.id)
				end
			end
		end
	end
    return ret
  end

  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    # Global abilities
    if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
       (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY) || (@battle.pbCheckGlobalAbility(:GAIAFORCE) && type == :GROUND)
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:base_damage_multiplier] *= 2 / 3.0
      else
        multipliers[:base_damage_multiplier] *= 4 / 3.0
      end
    end
    # Ability effects that alter damage
    if user.abilityActive?
      Battle::AbilityEffects.triggerDamageCalcFromUser(
        user.ability, user, target, self, multipliers, baseDmg, type
      )
    end
    if !@battle.moldBreaker
      # NOTE: It's odd that the user's Mold Breaker prevents its partner's
      #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
      #       how it works.
      user.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromAlly(
          b.ability, user, target, self, multipliers, baseDmg, type
        )
      end
      if target.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTarget(
          target.ability, user, target, self, multipliers, baseDmg, type
        )
        Battle::AbilityEffects.triggerDamageCalcFromTargetNonIgnorable(
          target.ability, user, target, self, multipliers, baseDmg, type
        )
      end
      target.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTargetAlly(
          b.ability, user, target, self, multipliers, baseDmg, type
        )
      end
    end
    # Item effects that alter damage
    if user.itemActive?
      Battle::ItemEffects.triggerDamageCalcFromUser(
        user.item, user, target, self, multipliers, baseDmg, type
      )
    end
    if target.itemActive?
      Battle::ItemEffects.triggerDamageCalcFromTarget(
        target.item, user, target, self, multipliers, baseDmg, type
      )
    end
    # Parental Bond's second attack
    if user.effects[PBEffects::ParentalBond] == 1
      multipliers[:base_damage_multiplier] /= (Settings::MECHANICS_GENERATION >= 7) ? 4 : 2
    end
    if user.effects[PBEffects::EchoChamber] == 1
      multipliers[:base_damage_multiplier] /= (Settings::MECHANICS_GENERATION >= 7) ? 4 : 2
    end
    # Other
    if user.effects[PBEffects::MeFirst]
      multipliers[:base_damage_multiplier] *= 1.5
    end
    if user.effects[PBEffects::HelpingHand] && !self.is_a?(Battle::Move::Confusion)
      multipliers[:base_damage_multiplier] *= 1.5
    end
    if user.effects[PBEffects::Charge] > 0 && type == :ELECTRIC
      multipliers[:base_damage_multiplier] *= 2
    end
    # Mud Sport
    if type == :ELECTRIC
      if @battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
        multipliers[:base_damage_multiplier] /= 3
      end
      if @battle.field.effects[PBEffects::MudSportField] > 0
        multipliers[:base_damage_multiplier] /= 3
      end
    end
    # Water Sport
    if type == :FIRE
      if @battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
        multipliers[:base_damage_multiplier] /= 3
      end
      if @battle.field.effects[PBEffects::WaterSportField] > 0
        multipliers[:base_damage_multiplier] /= 3
      end
    end
    # Terrain moves
    terrain_multiplier = (Settings::MECHANICS_GENERATION >= 8) ? 1.3 : 1.5
    case @battle.field.terrain
    when :Electric
      multipliers[:base_damage_multiplier] *= terrain_multiplier if type == :ELECTRIC && user.affectedByTerrain?
    when :Grassy
      multipliers[:base_damage_multiplier] *= terrain_multiplier if type == :GRASS && user.affectedByTerrain?
    when :Psychic
      multipliers[:base_damage_multiplier] *= terrain_multiplier if type == :PSYCHIC && user.affectedByTerrain?
    when :Misty
      multipliers[:base_damage_multiplier] /= 2 if type == :DRAGON && target.affectedByTerrain?
    end
    # Badge multipliers
    if @battle.internalBattle
      if user.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_ATTACK
          multipliers[:attack_multiplier] *= 1.1
        elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPATK
          multipliers[:attack_multiplier] *= 1.1
        end
      end
      if target.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
          multipliers[:defense_multiplier] *= 1.1
        elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
          multipliers[:defense_multiplier] *= 1.1
        end
      end
    end
    # Multi-targeting attacks
    if numTargets > 1
      multipliers[:final_damage_multiplier] *= 0.75
    end
    # Weather
    case user.effectiveWeather
    when :Sun, :HarshSun
      case type
      when :FIRE
        multipliers[:final_damage_multiplier] *= 1.5
      when :WATER
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Rain, :HeavyRain
      case type
      when :FIRE
        multipliers[:final_damage_multiplier] /= 2
      when :WATER
        multipliers[:final_damage_multiplier] *= 1.5
      end
    when :Sandstorm
      if target.pbHasType?(:ROCK) && specialMove? && @function != "UseTargetDefenseInsteadOfTargetSpDef"
        multipliers[:defense_multiplier] *= 1.5
      end
    end
    # Field Effects
    fe = FIELD_EFFECTS[@battle.field.field_effects]
	 if fe[:field_changers] != nil
		 priority = @battle.pbPriority(true)
		 msg = nil
		 for fc in fe[:field_changers].keys
			if @battle.field.field_effects != PBFieldEffects::None
				if fe[:field_changers][fc].include?(self.id) && fe[:field_change_conditions][fc] != nil && fe[:field_change_conditions][fc] == true
					for message in fe[:change_message].keys
						msg = message if fe[:change_message][message].include?(self.id)
					end
					@battle.pbDisplay(_INTL(msg)) if msg != nil
                    @battle.field.field_effects = fc
					fe = FIELD_EFFECTS[@battle.field.field_effects]
					$field_effect_bg = fe[:field_gfx]
					@battle.scene.pbRefreshEverything
					@battle.field.weather == :None
					priority.each do |pkmn|
						if pkmn.hasActiveAbility?([fe[:abilities]])
							for key in fe[:ability_effects].keys
								if pkmn.ability != fc
									abil = nil
								else
									abil = fe[:ability_effects][pkmn.ability]
								end
								if pkmn.ability == fc && abil.is_a?(Array)
									trigger = true
								end
							end
							BattleHandlers.triggerAbilityOnSwitchIn(fc,pkmn,@battle) if trigger
							pkmn.pbRaiseStatStage(abil[0],abil[1],user) if abil != nil && !trigger
						end
					end
				end
			end
		end
	  end
 #Field Effect Type Boosts
	 trigger = false
	 mesg = false
	 if fe[:type_damage_change] != nil
		 for key in fe[:type_damage_change].keys
			 if @battle.field.field_effects != PBFieldEffects::None
				if if fe[:type_damage_change][key].include?(type)
					multipliers[FINAL_DMG_MULT] *= key
					mesg = true
				end
				if mesg == true
					for mess in fe[:type_messages].keys
						msg = mess if fe[:type_messages][mess].include?(type)
					end
					@battle.pbDisplay(_INTL(msg))
				end
			 end
		 end
	 end
	 #Field Effect Specific Move Boost
	 if fe[:move_damage_boost] != nil
		 for dmg in fe[:move_damage_boost].keys
			 if @battle.field.field_effects != :None
				if fe[:move_damage_boost][dmg].is_a?(Array)
					if fe[:move_damage_boost][dmg].include?(self.id)
						multipliers[FINAL_DMG_MULT] *= dmg 
						mesg = true if j == type
					end
				elsif type == getConst(PBTypes,fe[:move_damage_boost][dmg])
					multipliers[FINAL_DMG_MULT] *= dmg
					mesg = true
				end
				if mesg == true
					for mess in fe[:move_messages].keys
						if fe[:move_messages][mess].is_a?(Array)
							msg = mess if fe[move_messages][mess].include?(self.id)
						else
							msg = mess if GameData::Type.get(fe[:move_messages][mess]).id == type
						end
					end
					@battle.pbDisplay(INTL(msg))
				end
			 end
		 end
	 end

	#Field Effect Defensive Modifiers
	 if fe[:defensive_modifiers] != nil
		priority = @battle.pbPriority(true)
		msg = nil
		for d in fe[:defensive_modifiers].keys
			if fe[:defensive_modifiers][d][1] == "fullhp"
				multipliers[FINAL_DMG_MULT] /= d
			elsif fe[:defensive_modifiers][d][1] == "physical"
				multipliers[DEF_MULT] *= d if physicalMove?
			elsif fe[:defensive_modifiers][d][1] == "special"
				multipliers[DEF_MULT] *= d if specialMove?
			elsif fe[:defensive_modifiers][d][1] == nil
				multipliers[DEF_MULT] *= d
			end
		end
	end
	#Additional Effects of Field Effects
	 if fe[:side_effects] != nil
		priority = @battle.pbPriority(true)
		msg = nil
		f = fe[:side_effects].keys
		for eff in fe[:side_effects].keys
			if (fe[:side_effects][eff].is_a?(Array) && fe[:side_effects][eff].include?(self.id)) || (!fe[:side_effects][eff].is_a?(Array) && type == GameData::Type.get(fe[:side_effects][eff]).id)
				case eff
					#add side effects for fields here
				end
			end
		end
	end
   end
    # Critical hits
    if target.damageState.critical
      if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
        multipliers[:final_damage_multiplier] *= 1.5
      else
        multipliers[:final_damage_multiplier] *= 2
      end
    end
    # Random variance
    if !self.is_a?(Battle::Move::Confusion)
      random = 85 + @battle.pbRandom(16)
      multipliers[:final_damage_multiplier] *= random / 100.0
    end
    # STAB
    if type && user.pbHasType?(type)
      if user.hasActiveAbility?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end
    # Type effectiveness
    multipliers[:final_damage_multiplier] *= target.damageState.typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
    # Burn
    if user.status == :BURN && physicalMove? && damageReducedByBurn? &&
       !user.hasActiveAbility?(:GUTS)
      multipliers[:final_damage_multiplier] /= 2
    end
    # Aurora Veil, Reflect, Light Screen
    if !ignoresReflect? && !target.damageState.critical &&
       !user.hasActiveAbility?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end
    # Minimize
    if target.effects[PBEffects::Minimize] && tramplesMinimize?
      multipliers[:final_damage_multiplier] *= 2
    end
    # Move-specific base damage modifiers
    multipliers[:base_damage_multiplier] = pbBaseDamageMultiplier(multipliers[:base_damage_multiplier], user, target)
    # Move-specific final damage modifiers
    multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
  end
 end
=end