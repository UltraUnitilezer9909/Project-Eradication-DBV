#===============================================================================
# Additions to the Battle class.
#===============================================================================
class Battle
  attr_accessor :terastallize
  
  #-----------------------------------------------------------------------------
  # Aliased for Terastallization.
  #-----------------------------------------------------------------------------
  alias tera_initialize initialize
  def initialize(*args)
    tera_initialize(*args)
    @terastallize = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
    @tera_orbs = []
    GameData::Item.each { |item| @tera_orbs.push(item.id) if item.has_flag?("TeraOrb") }
  end
  
  #-----------------------------------------------------------------------------
  # Tera Orbs
  #-----------------------------------------------------------------------------
  def pbHasTeraOrb?(idxBattler)
    return true if @battlers[idxBattler].wild?
    if pbOwnedByPlayer?(idxBattler)
      @tera_orbs.each { |item| return true if $bag.has?(item) }
    else
      trainer_items = pbGetOwnerItems(idxBattler)
      return false if !trainer_items
      @tera_orbs.each { |item| return true if trainer_items.include?(item) }
    end
    return false
  end
  
  def pbGetTeraOrbName(idxBattler)
    if !@tera_orbs.empty?
      if pbOwnedByPlayer?(idxBattler)
        @tera_orbs.each { |item| return GameData::Item.get(item).name if $bag.has?(item) }
      else
        trainer_items = pbGetOwnerItems(idxBattler)
        @tera_orbs.each { |item| return GameData::Item.get(item).name if trainer_items&.include?(item) }
      end
    end
    return _INTL("Tera Orb")
  end
  
  #-----------------------------------------------------------------------------
  # Eligibility check.
  #-----------------------------------------------------------------------------
  def pbCanTerastallize?(idxBattler)
    battler = @battlers[idxBattler]
    return false if $game_switches[Settings::NO_TERASTALLIZE]               # Don't Terastallize if switch enabled.
    return false if !battler.hasTera?                                       # Don't Terastallize if ineligible.
    return true if $DEBUG && Input.press?(Input::CTRL) && !battler.wild?    # Allows Terastallization with CTRL in Debug.
    return false if battler.effects[PBEffects::SkyDrop] >= 0                # Don't Terastallize if in Sky Drop.
    return false if !pbHasTeraOrb?(idxBattler)                              # Don't Terastallize if no Tera Orb, unless wild Pokemon.
    return false if pbOwnedByPlayer?(idxBattler) && !$player.tera_charged?  # Don't Terastallize if player and Tera Orb not charged.
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @terastallize[side][owner] == -1
  end
  
  #-----------------------------------------------------------------------------
  # Terastallization.
  #-----------------------------------------------------------------------------
  def pbTerastallize(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasTera? || battler.tera?
    $stats.terastallize_count += 1 if battler.pbOwnedByPlayer?
    triggers = ["tera", "tera" + battler.species.to_s, "tera" + battler.tera_type.to_s]
    @scene.pbDeluxeTriggers(idxBattler, nil, triggers)
    battler.effects[PBEffects::Type3] = nil
    battler.effects[PBEffects::Roost] = false
    battler.effects[PBEffects::BurnUp] = false
    changePoke = battler.effects[PBEffects::TransformPokemon] || battler.displayPokemon
    if Settings::SHOW_TERA_ANIM && $PokemonSystem.battlescene == 0
      @scene.pbShowTerastallize(idxBattler)
      battler.pokemon.terastallize = true
      @scene.pbChangePokemon(battler, changePoke)
    else
      if battler.wild?
        pbDisplay(_INTL("{1} surrounded itself in Terastal energy!", battler.pbThis))
      else
        trainerName = pbGetOwnerName(idxBattler)
        pbDisplay(_INTL("{1} is reacting to {2}'s {3}!", battler.pbThis, trainerName, pbGetTeraOrbName(idxBattler)))
      end
      battler.pokemon.terastallize = true
      @scene.pbRevertTera(idxBattler)
    end
    battler.pbUpdate
    @scene.pbRefreshOne(idxBattler)
    pbDisplay(_INTL("{1} Terastallized into the {2}-type!", battler.pbThis, GameData::Type.get(battler.tera_type).name))
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @terastallize[side][owner] = -2
    if pbOwnedByPlayer?(idxBattler) && Settings::TERA_ORB_RECHARGE
      return if $DEBUG && Input.press?(Input::CTRL)
      # Tera Orb doesn't require recharging in Area Zero.
      map_data = GameData::MapMetadata.try_get($game_map.map_id)
      return if $game_map && map_data&.has_flag?("AreaZero")
      $player.tera_charged = false
    end
  end
  
  #-----------------------------------------------------------------------------
  # Registering Terastallization.
  #-----------------------------------------------------------------------------
  def pbRegisterTerastallize(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @terastallize[side][owner] = idxBattler
  end

  def pbUnregisterTerastallize(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @terastallize[side][owner] = -1 if @terastallize[side][owner] == idxBattler
  end
  
  def pbToggleRegisteredTerastallize(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @terastallize[side][owner] == idxBattler
      @terastallize[side][owner] = -1
    else
      @terastallize[side][owner] = idxBattler
    end
  end

  def pbRegisteredTerastallize?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @terastallize[side][owner] == idxBattler
  end
  
  def pbAttackPhaseTerastallize
    pbPriority.each do |b|
	  next if b.wild? && !b.ace?
      next unless @choices[b.index][0] == :UseMove && !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @terastallize[b.idxOwnSide][owner] != b.index
      pbTerastallize(b.index)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Wild Tera Pokemon Terastallize at the start of battle.
  #-----------------------------------------------------------------------------
  alias tera_pbCommandPhase pbCommandPhase
  def pbCommandPhase
    if @turnCount == 0
      @battlers.each do |b|
        next unless b && b.tera_boss && pbCanTerastallize?(b.index)
        @disablePokeBalls = true
        pbTerastallize(b.index)
      end
    end
    tera_pbCommandPhase
  end
  
  #-----------------------------------------------------------------------------
  # Reverting Terastallization. (End of battle)
  #-----------------------------------------------------------------------------
  alias tera_pbEndOfBattle pbEndOfBattle
  def pbEndOfBattle
    @battlers.each { |b| b.unTera if b&.tera? }
    $player.party.each { |p| p.terastallize = false if p&.tera? }
    tera_pbEndOfBattle
  end
end


#-------------------------------------------------------------------------------
# Reverting Terastallization. (Fainting)
#-------------------------------------------------------------------------------
class Battle::Scene
  alias tera_pbFaintBattler pbFaintBattler
  def pbFaintBattler(battler)
    battler.unTera(true) if battler.tera?
    tera_pbFaintBattler(battler)
  end
end


#-------------------------------------------------------------------------------
# Reverting Terastallization. (Capture)
#-------------------------------------------------------------------------------
module Battle::CatchAndStoreMixin
  alias tera_pbStorePokemon pbStorePokemon
  def pbStorePokemon(pkmn)
    pkmn.terastallize = false
    tera_pbStorePokemon(pkmn)
  end
end


#-------------------------------------------------------------------------------
# Triggering Terastallization. (Fight Menu)
#-------------------------------------------------------------------------------
class Battle::Scene::FightMenu < Battle::Scene::MenuBase
  attr_reader :teraType
  
  def teraType=(value)
    oldValue = @teraType
    @teraType = value
    refreshBattleButton if @teraType != oldValue
  end
end
  
class Battle::Scene
  def pbFightMenu_Terastallize(battler, cw)
    battler.power_trigger = !battler.power_trigger
    if battler.power_trigger
      pbPlayBattleButton
      cw.teraType = GameData::Type.get(battler.tera_type).icon_position + 1
    else
      pbPlayCancelSE
      cw.teraType = 0
    end
    pbUpdateMoveInfoWindow(battler, cw.index) if defined?(@moveUIToggle)
    return DXTriggers::MENU_TRIGGER_TERASTALLIZE, false
  end
end


#-------------------------------------------------------------------------------
# Databox Tera Icon.
#-------------------------------------------------------------------------------
class Battle::Scene::PokemonDataBox < Sprite
  alias tera_draw_special_form_icon draw_special_form_icon
  def draw_special_form_icon
    if @battler.tera?
      specialX = (@battler.opposes?(0)) ? 208 : -28
      path = "Graphics/Plugins/Terastal Phenomenon/tera_types"
      type_number = GameData::Type.get(@battler.tera_type).icon_position
      pbDrawImagePositions(self.bitmap, [[path, @spriteBaseX + specialX, 4, 0, type_number * 32, 32, 32]])
    else
      tera_draw_special_form_icon
    end
  end
end


#-------------------------------------------------------------------------------
# AI Terastallization.
#-------------------------------------------------------------------------------
class Battle::AI
  def pbEnemyShouldTerastallize?(idxBattler)
    return false if @battle.pbScriptedMechanic?(idxBattler, :tera)
    battler = @battle.battlers[idxBattler]
    ace = (battler.wild?) ? battler.ace? : (battler.ace? || @battle.pbAbleCount(idxBattler) == 1)
    if @battle.pbCanTerastallize?(idxBattler) && ace
      $stats.wild_tera_battles += 1 if battler.wild?
      PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will Terastallize")
      return true
    end
    return false
  end
end