#==================================================
# Legendary Breeding Compatibility!!!
#==================================================
class Battle::Battler

if PluginManager.installed?("Legendary Breeding")

	alias lb_egg_group_airborne airborne?
		def airborne?
		ret = lb_egg_group_airborne
		
		return true if pbHasEggGroup?(:Skycrest)
		return ret
	end
	
	alias lb_egg_group_sandstorm_damage takesSandstormDamage?
		def takesSandstormDamage?
		ret = lb_egg_group_sandstorm_damage
		
		return false if pbHasEggGroup?(:Bestial)
		return ret
	end
	
	alias lb_egg_group_hail_damage takesHailDamage?
		def takesHailDamage?
		ret = lb_egg_group_hail_damage
		
		return false if pbHasEggGroup?(:Bestial)
		return ret
	end
  
	alias lb_egg_group_indirect_damage takesIndirectDamage?
		def takesIndirectDamage?(showMsg = false)
		ret = lb_egg_group_indirect_damage(showMsg = false)
		
		if pbHasEggGroup?(:Nebulous)
			@battle.pbDisplay(_INTL("{1} is unaffected!", pbThis))
			return false
		end
		return ret	
	end
	
	alias lb_egg_group_can_inflict_status pbCanInflictStatus?
		def pbCanInflictStatus?(newStatus, user, showMessages, move = nil, ignoreStatus = false)
		ret = lb_egg_group_can_inflict_status(newStatus, user, showMessages, move = nil, ignoreStatus = false)
		
		if pbHasEggGroup?(:Enchanted)
			@battle.pbDisplay(_INTL("{1} is shielded from status effects!", pbThis))
			return false
		end
		return ret	
	end
		
		
		
  end	
	
	
	
end

class Battle::Move

if PluginManager.installed?("Legendary Breeding")
		
	alias lb_egg_group_damage_multipliers pbCalcDamageMultipliers
		def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
		ret = lb_egg_group_damage_multipliers(user, target, numTargets, type, baseDmg, multipliers)
		
		# Strong Winds Resist for Skycrest (Egg Group)
		case user.effectiveWeather
		when :StrongWinds
			if target.pbHasEggGroup?(:Skycrest)
			multipliers[:final_damage_multiplier] /= 1.3
		end
		
		# Damage Resist from Physical Moves (Titan)
		if target.pbHasEggGroup?(:Titan) && physicalMove?
			multipliers[:final_damage_multiplier] /= 1.3
		end
		
		# Bonus Damage (Titan)
		if user.pbHasEggGroup?(:Titan)
			multipliers[:final_damage_multiplier] *= 1.15
		end
		
		# Damage Resist for Dragon Moves (Overlord)
		if target.pbHasEggGroup?(:Overlord) && type == :DRAGON
			multipliers[:final_damage_multiplier] /= 1.25
		end
		
		# Bonus Damage for Dragon Moves (Overlord)
		if user.pbHasEggGroup?(:Overlord) && type == :DRAGON
			multipliers[:final_damage_multiplier] *= 1.25
		end
		
		# Bonus Defense (Bestial)
		if user.pbHasEggGroup?(:Bestial)
			multipliers[:defense_multiplier] *= 1.15
		end
		
		# Damage Resist from Special Moves (Ultra)
		if target.pbHasEggGroup?(:Ultra) && specialMove?
			multipliers[:final_damage_multiplier] /= 1.3
		end
		
		# Bonus Defense (Ultra)
		if user.pbHasEggGroup?(:Ultra)
			multipliers[:defense_multiplier] *= 1.15
		end
		
	  end
	end
  end
end	
