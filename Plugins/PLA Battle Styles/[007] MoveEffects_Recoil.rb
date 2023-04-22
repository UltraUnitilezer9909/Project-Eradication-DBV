#===============================================================================
# Recoil moves. The amount of recoil taken varies with style.
#===============================================================================


#===============================================================================
# Take Down, Wild Charge, etc. (1/4th recoil moves)
#===============================================================================
class Battle::Move::RecoilQuarterOfDamageDealt < Battle::Move::RecoilMove
  def strongStyleRecoil?; return true; end

  def pbRecoilDamage(user, target)
    amt = (user.strong_style? && self.mastered?) ? 2.0 : 4.0
    return (target.damageState.totalHPLost / amt).round
  end
end


#===============================================================================
# Double-Edge, Brave Bird, etc. (1/3rd recoil moves)
#===============================================================================
class Battle::Move::RecoilThirdOfDamageDealt < Battle::Move::RecoilMove
  def strongStyleRecoil?; return true; end
  
  def pbRecoilDamage(user, target)
    amt = (user.strong_style? && self.mastered?) ? 2.0 : 3.0
    return (target.damageState.totalHPLost / amt).round
  end
end


#===============================================================================
# Volt Tackle
#===============================================================================
class Battle::Move::RecoilThirdOfDamageDealtParalyzeTarget < Battle::Move::RecoilMove
  def strongStyleRecoil?; return true; end

  def pbRecoilDamage(user, target)
    amt = (user.strong_style? && self.mastered?) ? 2.0 : 3.0
    return (target.damageState.totalHPLost / amt).round
  end
end


#===============================================================================
# Flare Blitz
#===============================================================================
class Battle::Move::RecoilThirdOfDamageDealtBurnTarget < Battle::Move::RecoilMove
  def strongStyleRecoil?; return true; end

  def pbRecoilDamage(user, target)
    amt = (user.strong_style? && self.mastered?) ? 2.0 : 3.0
    return (target.damageState.totalHPLost / amt).round
  end
end


#===============================================================================
# Head Smash, Light of Ruin
#===============================================================================
class Battle::Move::RecoilHalfOfDamageDealt < Battle::Move::RecoilMove
  def strongStyleRecoil?; return true; end

  def pbRecoilDamage(user, target)
    return (target.damageState.totalHPLost * 0.75).round if user.strong_style? && self.mastered?
    return (target.damageState.totalHPLost / 2.0).round
  end
end


#===============================================================================
# Steel Beam
#===============================================================================
class Battle::Move::UserLosesHalfOfTotalHP < Battle::Move
  def strongStyleRecoil?; return true; end
  def agileStyleRecoil?;  return true; end

  def pbEffectAfterAllHits(user, target)
    return if !user.takesIndirectDamage?
    if self.mastered? && user.battle_style > 0
      case user.battle_style
      when 1 then amt = (user.totalhp / 1.5).ceil
      when 2 then amt = (user.totalhp / 3.0).ceil
      end
    else
      amt = (user.totalhp / 2.0).ceil
    end
    amt = 1 if amt < 1
    user.pbReduceHP(amt, false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
    user.pbItemHPHealCheck
  end
end