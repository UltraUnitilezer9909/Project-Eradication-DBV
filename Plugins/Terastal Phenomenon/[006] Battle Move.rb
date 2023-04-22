#===============================================================================
# Battle move code related to Terastallization.
#===============================================================================

#-------------------------------------------------------------------------------
# Changes to dealing damage while Terastallized.
#-------------------------------------------------------------------------------
class Battle::Move
  #-----------------------------------------------------------------------------
  # Aliased to set damage threshold for wild Tera Pokemon.
  #-----------------------------------------------------------------------------
  alias tera_pbCalcDamage pbCalcDamage
  def pbCalcDamage(user, target, numTargets = 1)
    tera_pbCalcDamage(user, target, numTargets)
    if target.tera? && target.tera_boss && target.damageState.calcDamage > 0
      thresh = target.totalhp / 6
      damage = target.damageState.calcDamage
      if (target.hp > thresh) && (damage > target.hp - thresh)
        damage = target.hp - thresh + 1
      elsif target.hp <= thresh
        damage = 1
      end
      target.damageState.calcDamage = damage
    end
  end

  #-----------------------------------------------------------------------------
  # Aliased to alter damage calcs for Tera moves.
  #-----------------------------------------------------------------------------
  alias tera_pbCalcDamageMultipliers pbCalcDamageMultipliers
  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    tera_pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    if type && user.tera?
      if type == user.tera_type
        #-----------------------------------------------------------------------
        # Weak Tera type moves get boosted to 60 BP as long as they aren't 
        # mult-hit moves, have increased priority, or have already been boosted 
        # to or above 60 BP by Technician and other effects.
        #-----------------------------------------------------------------------
        baseDmgMult = baseDmg * multipliers[:base_damage_multiplier]
        if baseDmgMult < 60 && @priority < 1 && !multiHitMove?
          multipliers[:base_damage_multiplier] = 60 / baseDmg
        end
        #-----------------------------------------------------------------------
        # Applies bonus STAB if move type matches the user's Tera Type and is 
        # the same as one of its original types. Adaptability applies an 
        # additional boost. 
        #-----------------------------------------------------------------------
        if user.pokemon.types.include?(type)
          if user.hasActiveAbility?(:ADAPTABILITY)
            multipliers[:final_damage_multiplier] *= 2.25 / 2
          else
            multipliers[:final_damage_multiplier] *= 2 / 1.5
          end
        end
      #-------------------------------------------------------------------------
      # Applies STAB if move type matches one of the user's original types.
      # Adaptability no longer affects these types.
      #-------------------------------------------------------------------------
      elsif user.pokemon.types.include?(type)
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Plays Tera Burst animation when using Tera-boosted moves.
  #-----------------------------------------------------------------------------
  alias tera_pbDisplayUseMessage pbDisplayUseMessage
  def pbDisplayUseMessage(user)
    if user.tera? && damagingMove? && user.tera_type == pbCalcType(user)
      triggers = ["teraType", "teraType" + user.species.to_s, "teraType" + user.tera_type.to_s]
      @battle.scene.pbDeluxeTriggers(user.index, nil, triggers)
      @battle.scene.pbTeraBurst(user.index)
    end
    tera_pbDisplayUseMessage(user)
  end
end


#-------------------------------------------------------------------------------
# Move - Tera Blast
#-------------------------------------------------------------------------------
class Battle::Move::CategoryDependsOnHigherDamageTera < Battle::Move
  def initialize(battle, move)
    super
    @calcCategory = 1
  end

  def physicalMove?(thisType = nil); return (@calcCategory == 0); end
  def specialMove?(thisType = nil);  return (@calcCategory == 1); end
    
  def pbBaseType(user)
    return (user.tera?) ? user.tera_type : :NORMAL
  end

  def pbOnStartUse(user, targets)
    stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
    stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
    atk        = user.attack
    atkStage   = user.stages[:ATTACK] + 6
    realAtk    = (atk.to_f * stageMul[atkStage] / stageDiv[atkStage]).floor
    spAtk      = user.spatk
    spAtkStage = user.stages[:SPECIAL_ATTACK] + 6
    realSpAtk  = (spAtk.to_f * stageMul[spAtkStage] / stageDiv[spAtkStage]).floor
    @calcCategory = (realAtk > realSpAtk) ? 0 : 1
  end
  
  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = GameData::Type.get(pbBaseType(user)).icon_position
    super
  end
end