#===============================================================================
# Stat changing moves. The number of stages vary with style.
#===============================================================================


#===============================================================================
# Raise one of user's stats.
#===============================================================================
class Battle::Move::StatUpMove < Battle::Move
  def strongStyleStatUp?; return @statUp[1] < 6; end
  def agileStyleStatUp?;  return @statUp[1] > 1; end
  
  def pbEffectGeneral(user)
    return if damagingMove?
    user.pbRaiseStatStage(@statUp[0], pbStage(user, @statUp[1]), user)
  end

  def pbAdditionalEffect(user, target)
    if user.pbCanRaiseStatStage?(@statUp[0], user, self)
      user.pbRaiseStatStage(@statUp[0], pbStage(user, @statUp[1]), user)
    end
  end
end


#===============================================================================
# Raise multiple of user's stats.
#===============================================================================
class Battle::Move::MultiStatUpMove < Battle::Move
  def strongStyleStatUp?
    @statUp.each { |s| return true if s.is_a?(Numeric) && s < 6 }
	return false
  end
  
  def agileStyleStatUp?
    @statUp.each { |s| return true if s.is_a?(Numeric) && s > 1 }
	return false
  end
  
  def pbEffectGeneral(user)
    return if damagingMove?
    showAnim = true
    (@statUp.length / 2).times do |i|
      next if !user.pbCanRaiseStatStage?(@statUp[i * 2], user, self)
      if user.pbRaiseStatStage(@statUp[i * 2], pbStage(user, @statUp[(i * 2) + 1]), user, showAnim)
        showAnim = false
      end
    end
  end

  def pbAdditionalEffect(user, target)
    showAnim = true
    (@statUp.length / 2).times do |i|
      next if !user.pbCanRaiseStatStage?(@statUp[i * 2], user, self)
      if user.pbRaiseStatStage(@statUp[i * 2], pbStage(user, @statUp[(i * 2) + 1]), user, showAnim)
        showAnim = false
      end
    end
  end
end


#===============================================================================
# Lower one of target's stats.
#===============================================================================
class Battle::Move::TargetStatDownMove < Battle::Move
  def strongStyleStatDown?; return @statDown[1] < 6; end
  def agileStyleStatDown?;  return @statDown[1] > 1; end
  
  def pbEffectAgainstTarget(user, target)
    return if damagingMove?
    target.pbLowerStatStage(@statDown[0], pbStage(user, @statDown[1]), user)
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    return if !target.pbCanLowerStatStage?(@statDown[0], user, self)
    target.pbLowerStatStage(@statDown[0], pbStage(user, @statDown[1]), user)
  end
end


#===============================================================================
# Lower multiple of target's stats.
#===============================================================================
class Battle::Move::TargetMultiStatDownMove < Battle::Move
  def strongStyleStatDown?
    @statDown.each { |s| return true if s.is_a?(Numeric) && s < 6 }
	return false
  end

  def agileStyleStatDown?
    @statDown.each { |s| return true if s.is_a?(Numeric) && s > 1 }
	return false
  end
  
  def pbLowerTargetMultipleStats(user, target)
    return if !pbCheckForMirrorArmor(user, target)
    showAnim = true
    showMirrorArmorSplash = true
    (@statDown.length / 2).times do |i|
      next if !target.pbCanLowerStatStage?(@statDown[i * 2], user, self)
      if target.pbLowerStatStage(@statDown[i * 2], pbStage(user, @statDown[(i * 2) + 1]), user,
                                 showAnim, false, (showMirrorArmorSplash) ? 1 : 3)
        showAnim = false
      end
      showMirrorArmorSplash = false
    end
    @battle.pbHideAbilitySplash(target)
  end
end