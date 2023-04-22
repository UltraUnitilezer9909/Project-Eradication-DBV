#===============================================================================
# Healing moves. The amount of healing done varies with style.
#===============================================================================


#===============================================================================
# Recover, Soft-Boiled, etc. (1/2 recovery moves)
#===============================================================================
class Battle::Move::HealUserHalfOfTotalHP < Battle::Move::HealingMove
  def strongStyleHealing?; return true; end
  def agileStyleHealing?;  return true; end
  
  def pbHealAmount(user)
    if self.mastered? && user.battle_style > 0
      case user.battle_style
      when 1 then return (user.totalhp * 0.7).round
      when 2 then return (user.totalhp * 0.3).round
      end
    else
      return (user.totalhp * 0.5).round
    end
  end
end


#===============================================================================
# Moonlight, Morning Sun, Synthesis
#===============================================================================
class Battle::Move::HealUserDependingOnWeather < Battle::Move::HealingMove
  def strongStyleHealing?; return true; end
  def agileStyleHealing?;  return true; end

  def pbHealAmount(user)
    if self.mastered? && user.battle_style > 0
      case user.battle_style
      when 1 then return (@healAmount * 0.7).round
      when 2 then return (@healAmount * 0.3).round
      end
    else
      return (@healAmount * 0.5).round
    end
  end
end


#===============================================================================
# Shore Up
#===============================================================================
class Battle::Move::HealUserDependingOnSandstorm < Battle::Move::HealingMove
  def strongStyleHealing?; return true; end
  def agileStyleHealing?;  return true; end

  def pbHealAmount(user)
    amt = (user.effectiveWeather == :Sandstorm) ? (user.totalhp * 2 / 3.0).round : (user.totalhp / 2.0).round
    if self.mastered? && user.battle_style > 0
      case user.battle_style
      when 1 then return (amt * 0.7).round
      when 2 then return (amt * 0.3).round
      end
    else
      return (amt * 0.5).round
    end
  end
end


#===============================================================================
# Roost
#===============================================================================
class Battle::Move::HealUserHalfOfTotalHPLoseFlyingTypeThisTurn < Battle::Move::HealingMove
  def strongStyleHealing?; return true; end
  def agileStyleHealing?;  return true; end

  def pbHealAmount(user)
    if self.mastered? && user.battle_style > 0
      case user.battle_style
      when 1 then return (user.totalhp * 0.7).round
      when 2 then return (user.totalhp * 0.3).round
      end
    else
      return (user.totalhp * 0.5).round
    end
  end
end


#===============================================================================
# Purify
#===============================================================================
class Battle::Move::CureTargetStatusHealUserHalfOfTotalHP < Battle::Move::HealingMove
  def strongStyleHealing?; return true; end
  def agileStyleHealing?;  return true; end

  def pbHealAmount(user)
    if self.mastered? && user.battle_style > 0
      case user.battle_style
      when 1 then return (user.totalhp * 0.7).round
      when 2 then return (user.totalhp * 0.3).round
      end
    else
      return (user.totalhp * 0.5).round
    end
  end
end


#===============================================================================
# Life Dew
#===============================================================================
class Battle::Move::HealUserAndAlliesQuarterOfTotalHP < Battle::Move
  def strongStyleHealing?; return true; end

  def pbEffectAgainstTarget(user, target)
    hpGain = (user.strong_style? && self.mastered?) ? (target.totalhp / 3.0).round  : (target.totalhp / 4.0).round
    target.pbRecoverHP(hpGain)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
  end
end


#===============================================================================
# Jungle Healing
#===============================================================================
class Battle::Move::HealUserAndAlliesQuarterOfTotalHPCureStatus < Battle::Move
  def strongStyleHealing?; return true; end

  def pbEffectAgainstTarget(user, target)
    if target.canHeal?
      hpGain = (user.strong_style? && self.mastered?) ? (target.totalhp / 3.0).round  : (target.totalhp / 4.0).round
      target.pbRecoverHP(hpGain)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
    end
    if target.status != :NONE
      old_status = target.status
      target.pbCureStatus(false)
      case old_status
      when :SLEEP
        @battle.pbDisplay(_INTL("{1} was woken from sleep.", target.pbThis))
      when :POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.", target.pbThis))
      when :BURN
        @battle.pbDisplay(_INTL("{1}'s burn was healed.", target.pbThis))
      when :PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of paralysis.", target.pbThis))
      when :FROZEN
        @battle.pbDisplay(_INTL("{1} was thawed out.", target.pbThis))
      end
    end
  end
end


#===============================================================================
# Heal Pulse
#===============================================================================
class Battle::Move::HealTargetHalfOfTotalHP < Battle::Move
  def strongStyleHealing?; return true; end

  def pbEffectAgainstTarget(user, target)
    hpGain = (target.totalhp / 2.0).round
    if (user.strong_style? && self.mastered?) || (pulseMove? && user.hasActiveAbility?(:MEGALAUNCHER))
      hpGain = (target.totalhp * 3 / 4.0).round
    end
    target.pbRecoverHP(hpGain)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
  end
end


#===============================================================================
# Floral Healing
#===============================================================================
class Battle::Move::HealTargetDependingOnGrassyTerrain < Battle::Move
  def strongStyleHealing?; return true; end

  def pbEffectAgainstTarget(user, target)
    hpGain = (target.totalhp / 2.0).round
    hpGain = (target.totalhp * 2 / 3.0).round if @battle.field.terrain == :Grassy || (user.strong_style? && self.mastered?)
    target.pbRecoverHP(hpGain)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
  end
end


#===============================================================================
# Drain moves. The amount of HP drained varies with style.
#===============================================================================


#===============================================================================
# Absorb, Leech Life, etc.
#===============================================================================
class Battle::Move::HealUserByHalfOfDamageDone < Battle::Move
  def strongStyleHealing?; return true; end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    hpGain = (user.strong_style? && self.mastered?) ? (target.damageState.hpLost * 0.75).round : (target.damageState.hpLost / 2.0).round
    user.pbRecoverHPFromDrain(hpGain, target)
  end
end


#===============================================================================
# Dream Eater
#===============================================================================
class Battle::Move::HealUserByHalfOfDamageDoneIfTargetAsleep < Battle::Move
  def strongStyleHealing?; return true; end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    hpGain = (user.strong_style? && self.mastered?) ? (target.damageState.hpLost * 0.75).round : (target.damageState.hpLost / 2.0).round
    user.pbRecoverHPFromDrain(hpGain, target)
  end
end


#===============================================================================
# Draining Kiss, Oblivion Wing
#===============================================================================
class Battle::Move::HealUserByThreeQuartersOfDamageDone < Battle::Move
  def strongStyleHealing?; return true; end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    hpGain = (user.strong_style? && self.mastered?) ? target.damageState.hpLost : (target.damageState.hpLost * 0.75).round
    user.pbRecoverHPFromDrain(hpGain, target)
  end
end