#===============================================================================
# Core additions to the Battle class.
#===============================================================================
class Battle
  alias styles_initialize initialize
  def initialize(*args)
    styles_initialize(*args)
    @styleCounter = [
      [0] * (@player ? @player.length : 1),
      [0] * (@opponent ? @opponent.length : 1)
    ]
    @battleStyle = [
      [-1] * (@player ? @player.length : 1),
      [-1] * (@opponent ? @opponent.length : 1)
    ]
  end
  
  #-----------------------------------------------------------------------------
  # Priority calculation during battle styles.
  #-----------------------------------------------------------------------------
  alias styles_pbCalculatePriority pbCalculatePriority
  def pbCalculatePriority(*args)
    styles_pbCalculatePriority(*args)
    needRearranging = false
    @priority.each do |entry|
      battler = entry[0]
      next if battler.style_counter == 0
      case battler.battle_style
      when 1 # Strong style reduces priority until style effect ends.
        entry[4] = -5
        needRearranging = true
      when 2 # Agile style increases priority for 1 turn.
        next if battler.style_counter < Settings::STYLE_TURNS
        entry[4] = 5
        needRearranging = true
      end
    end
    if needRearranging
      @priority.sort! { |a, b|
        if a[5] != b[5]
          b[5] <=> a[5]
        elsif a[4] != b[4]
          b[4] <=> a[4]
        elsif @priorityTrickRoom
          (a[1] == b[1]) ? b[6] <=> a[6] : a[1] <=> b[1]
        else
          (a[1] == b[1]) ? b[6] <=> a[6] : b[1] <=> a[1]
        end
      }
      logMsg = "[Round order recalculated] "
      comma = false
      @priority.each do |entry|
        logMsg += ", " if comma
        logMsg += "#{entry[0].pbThis(comma)} (#{entry[0].index})"
        comma = true
      end
      PBDebug.log(logMsg)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Resets the usage of battle styles.
  #-----------------------------------------------------------------------------
  alias styles_pbEndOfRoundPhase pbEndOfRoundPhase
  def pbEndOfRoundPhase
    styles_pbEndOfRoundPhase
    return if @decision > 0
    #---------------------------------------------------------------------------
    # Counts down the number of turns each battler remains in a selected style.
    allBattlers.each do |b|
      next if b.style_counter == 0
      b.style_counter -= 1
      if b.style_counter == 0
        style = (b.battle_style == 1) ? _INTL("Strong Style") : _INTL("Agile Style")
        b.battle_style = 0
        b.style_trigger = 0
        b.style_flinch = false
        b.toggle_style_moves
        pbDisplay(_INTL("The effects of {1}'s {2} faded!", b.pbThis(true), style))
      end
    end
    #---------------------------------------------------------------------------
    # Counts down the number of turns spent in cooldown before styles can be used again.
    2.times do |side|
      trainer = (side == 0) ? @player.length : (@opponent.nil?) ? 1 : @opponent.length
      trainer.times do |owner|
        next if @styleCounter[side][owner] <= 0
        @styleCounter[side][owner] -= 1
        if @styleCounter[side][owner] == 0
          @battleStyle[side][owner] = -1
          case side
          when 0
            next if @player[owner].all_fainted?
            name = (owner == 0) ? _INTL("You") : @player[owner].full_name
            trigger = (owner == 0) ? "styleEnd" : "styleEnd_ally"
          when 1
            next if @opponent && @opponent[owner].all_fainted?
            name = (@opponent.nil?) ? _INTL("The opposing Pokémon") : @opponent[owner].full_name
            trigger = "styleEnd_foe"
          end
          pbDisplay(_INTL("{1} may use battle styles once again!", name))
          @scene.dx_midbattle(nil, nil, trigger)
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Eligibility checks.
  #-----------------------------------------------------------------------------
  def pbCanUseStyle?(idxBattler)
    battler = @battlers[idxBattler]
    return false if $game_switches[Settings::NO_STYLE_MOVES]  # No style if switch enabled.
    return false if !battler.hasStyles?                       # No style if ineligible.
    return false if battler.battle_style > 0                  # No style if already in a style.
    return true if $DEBUG && Input.press?(Input::CTRL)        # Allows style with CTRL in Debug.
    return false if battler.effects[PBEffects::SkyDrop] >= 0  # No style if in Sky Drop.
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return false if @styleCounter[side][owner] > 0
    return @battleStyle[side][owner] == -1
  end
  
  #-----------------------------------------------------------------------------
  # Uses the eligible battle mechanic.
  #-----------------------------------------------------------------------------
  def pbBattleStyle(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasStyles?
    return if @choices[idxBattler][2] == @struggle
    style = battler.style_trigger
    battler.battle_style = style
    battler.style_counter = Settings::STYLE_TURNS
    triggers = ["battleStyle", "battleStyle" + battler.species.to_s]
    case style
    when 1
      $stats.strong_style_count += 1 if battler.pbOwnedByPlayer?
      triggers += ["strongStyle", "strongStyle" + battler.species.to_s]
      msg1 = _INTL("{1} entered Strong Style!", battler.pbThis)
      msg2 = _INTL("{1} may act slower due to its Strong Style!", battler.pbThis)
    when 2
      $stats.agile_style_count += 1 if battler.pbOwnedByPlayer?
      triggers += ["agileStyle", "agileStyle" + battler.species.to_s]
      msg1 = _INTL("{1} entered Agile Style!", battler.pbThis)
      msg2 = _INTL("{1} may act sooner due to its Agile Style!", battler.pbThis)
    end
    @scene.pbDeluxeTriggers(idxBattler, nil, triggers)
    pbDisplay(msg1)
    @scene.pbShowBattleStyle(@battlers, battler)
    pbDisplay(msg2)
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @styleCounter[side][owner] = Settings::STYLE_COOLDOWN
    @battleStyle[side][owner] = -2
    pbCalculatePriority(false, [idxBattler])
  end
  
  #-----------------------------------------------------------------------------
  # Registering Styles.
  #-----------------------------------------------------------------------------
  def pbRegisterStyle(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @battleStyle[side][owner] = idxBattler
  end
  
  def pbUnregisterStyle(idxBattler)
    battler = @battlers[idxBattler]
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @battleStyle[side][owner] == idxBattler
      @battleStyle[side][owner] = -1
      @styleCounter[side][owner] = 0
      battler.battle_style = 0
      battler.style_trigger = 0
      battler.style_counter = 0
      battler.toggle_style_moves
    end
  end

  def pbToggleRegisteredStyle(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @battleStyle[side][owner] == idxBattler
      pbUnregisterStyle(idxBattler)
    else
      pbRegisterStyle(idxBattler)
    end
  end
  
  def pbRegisteredStyle?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @battleStyle[side][owner] == idxBattler
  end
  
  def pbAttackPhaseStyles
    pbPriority.each do |b|
      next unless @choices[b.index][0] == :UseMove && !b.fainted?
      next if b.style_trigger == 0
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @styleCounter[b.idxOwnSide][owner] > 0
      next if @battleStyle[b.idxOwnSide][owner] != b.index
      pbBattleStyle(b.index)
    end
  end
end


#===============================================================================
# Additions to Battle::Battler.
#===============================================================================
class Battle::Battler
  attr_accessor :battle_style, :style_trigger, :style_counter, :style_flinch
  
  alias styles_pbInitEffects pbInitEffects  
  def pbInitEffects(batonPass)
    styles_pbInitEffects(batonPass)
    @style_trigger = 0
    @battle_style  = 0
    @style_counter = 0
    @style_flinch  = false
  end
  
  def inStyle?;      return @battle_style > 0;  end
  def strong_style?; return @battle_style == 1; end
  def agile_style?;  return @battle_style == 2; end
  
  #-----------------------------------------------------------------------------
  # Battle Styles
  #-----------------------------------------------------------------------------
  # Higher priority than:
  #   -Terastallization
  #
  # Lower priority than:
  #   -Primal Reversion
  #   -Zodiac Powers
  #   -Ultra Burst
  #   -Z-Moves
  #   -Mega Evolution
  #   -Dynamax
  #-----------------------------------------------------------------------------
  def hasStyles?
    return false if shadowPokemon?
    return false if mega? || primal? || ultra? || dynamax? || inStyle? || tera? || celestial?
    return false if hasMega? || hasPrimal? || hasZMove? || hasUltra? || hasDynamaxAvail? || hasZodiacPower?
    @moves.each { |move| return true if move.mastered? }
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Used to toggle the power/accuracy/effect changes of moves based on style.
  #-----------------------------------------------------------------------------
  def toggle_style_moves(style = 0)
    @moves.each do |move|
      next if !move.mastered?
      move.calc_style_changes(style)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Strong Style users are flinched when attacked by Agile Style users.
  # This may only happen once per style use.
  #-----------------------------------------------------------------------------
  alias styles_pbEffectsAfterMove pbEffectsAfterMove
  def pbEffectsAfterMove(user, targets, move, numHits)
    if user.battle_style == 2 && move.damagingMove?
      targets.each do |b|
        next if b.movedThisRound?
        next if b.style_flinch || b.battle_style != 1
        next if b.damageState.protected  || b.damageState.missed || 
                b.damageState.unaffected || b.damageState.substitute
        b.pbFlinch
      end
    end
    styles_pbEffectsAfterMove(user, targets, move, numHits)
  end
  
  #-----------------------------------------------------------------------------
  # Agile Style users are immune to flinching.
  #-----------------------------------------------------------------------------
  alias styles_pbFlinch pbFlinch
  def pbFlinch(*args)
    return if @battle_style == 2
    styles_pbFlinch(*args)
    @style_flinch = (@battle_style == 1 && @effects[PBEffects::Flinch])
  end
end


#===============================================================================
# Additions to Battle::AI.
#===============================================================================
class Battle::AI
  def pbEnemyShouldUseStyle?(idxBattler)
    return false if $game_switches[Settings::NO_STYLE_MOVES]
    return false if @battle.pbScriptedMechanic?(idxBattler, :style)
    battler = @battle.battlers[idxBattler]
    move = @battle.choices[idxBattler][2]
    return false if !move || !move.mastered?
    return false if PluginManager.installed?("ZUD Mechanics") && move.powerMove?
    if @battle.pbCanUseStyle?(idxBattler)
      str_score = agi_score = 0
      #-------------------------------------------------------------------------
      # Calculates style score from user's moves.
      #-------------------------------------------------------------------------
      battler.moves.each do |m|
        next if !m.mastered?
        #-----------------------------------------------------------------------
        # More likely to use Strong Style if moves deal damage or already have priority.
        str_score += 10 if m.priority != 0
        str_score += 10 if m.baseDamage > 1
        #-----------------------------------------------------------------------
        # More likely to use Strong Style if moves have low accuracy.
        if m.accuracy > 0
          if    m.accuracy   <= 50 then str_score += 40
          elsif m.accuracy   <= 75 then str_score += 30
          elsif m.accuracy   <= 85 then str_score += 20
          elsif m.accuracy   < 100 then str_score += 10
          end
        end
        #-----------------------------------------------------------------------
        # More likely to use Strong Style if moves have a chance for additional effects.
        if m.addlEffect > 0
          if    m.addlEffect <= 10 then str_score += 10
          elsif m.addlEffect <= 20 then str_score += 20
          elsif m.addlEffect <= 30 then str_score += 30
          elsif m.addlEffect < 100 then str_score += 40
          end
        end
        #-----------------------------------------------------------------------
        # More likely to use Strong Style if moves positively influence stat changes.
        str_score += 10 if m.strongStyleStatUp? || m.strongStyleStatDown?
        agi_score -= 10 if m.agileStyleStatUp?  || m.agileStyleStatDown?
        #-----------------------------------------------------------------------
        # Adjusts score style for recoil moves based on remaining HP.
        if m.recoilMove? && battler.hp <= battler.totalhp
          str_score -= 20
          agi_score += 10
        end
        #-----------------------------------------------------------------------
        # Adjusts score style for healing moves based on remaining HP.
        if m.healingMove? && battler.hp <= battler.totalhp
          str_score += 10 
          agi_score += 10
        end
      end
      str_score += 20 if move.priority > 0
      #-------------------------------------------------------------------------
      # Calculates style score from opponents.
      #-------------------------------------------------------------------------
      battler.allOpposing.each do |b|
        #-----------------------------------------------------------------------
        # More likely to use Agile style if an opponent is in Strong style.
        if b.style_trigger == 1
          agi_score += 20
        #-----------------------------------------------------------------------
        # More likely to use Agile style if faster than an opponent in that style.
        elsif b.style_trigger == 2
          if battler.speed > b.speed
            agi_score += 20
          else
            agi_score -= 10
          end
        #-----------------------------------------------------------------------
        # More likely to use Agile style if opponent is faster. Considers Trick Room.
        elsif battler.speed < b.speed
          if @battle.field.effects[PBEffects::TrickRoom] == 0 && b.style_trigger < 2
            agi_score += 30
          else
            agi_score -= 10
          end
        else
          if @battle.field.effects[PBEffects::TrickRoom] == 0 && b.style_trigger < 2
            agi_score -= 10
          else
            agi_score += 20
          end
        end
        #-----------------------------------------------------------------------
        # More likely to use Agile style when opponent's HP is low.
        agi_score += 20 if b.hp <= b.totalhp / 4
        #-----------------------------------------------------------------------
        # Less likely to use any style if wide level gap is in opponent's favor.
        levelDiff = battler.level - b.level
        if levelDiff > 0
          if levelDiff >= 30
            agi_score = 0
            str_score = 0
          elsif levelDiff >= 20
            agi_score = 0
          end
        end
      end
      # Adds a bit of randomness to final score.
      str_score -= rand(0..20) 
      agi_score -= rand(0..20)
      return false if str_score <= 0 && agi_score <= 0
      result = (str_score == agi_score) ? rand(3) : (str_score > agi_score) ? 1 : 2
      battler.style_trigger = result
      PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will use a battle style")
      return true
    end
    return false
  end
end