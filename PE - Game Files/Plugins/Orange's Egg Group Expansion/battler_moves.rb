#==================================================
# Making Airborne Pokemon immune to Ground Moves.
#==================================================
class Battle::Move

	alias egg_group_airborne_immunity pbCalcTypeModSingle
		def pbCalcTypeModSingle(moveType, defType, user, target)
			ret = egg_group_airborne_immunity(moveType, defType, user, target)
			if target.airborne? && moveType == :GROUND
				ret = Effectiveness::INEFFECTIVE
				end
			return ret
		 end
		 
	alias egg_group_damage_multipliers pbCalcDamageMultipliers
		def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
		ret = egg_group_damage_multipliers(user, target, numTargets, type, baseDmg, multipliers)
		
		# Damage Resist From Physical Moves (Amorphous)
		if target.pbHasEggGroup?(:Amorphous) && physicalMove?
			multipliers[:final_damage_multiplier] /= 1.3
		end
		
		# Damage Bonus from Physical Moves (Monster)
		if user.pbHasEggGroup?(:Monster) && physicalMove?
			multipliers[:final_damage_multiplier] *= 1.3
		end
		
		# Damage Resist from Water Moves (Water Groups)
		if target.pbHasEggGroup?(:Water1) && type == :WATER
			multipliers[:final_damage_multiplier] /= 1.5
		end
		
		if target.pbHasEggGroup?(:Water2) && type == :WATER
			multipliers[:final_damage_multiplier] /= 1.5
		end
		
		if target.pbHasEggGroup?(:Water3) && type == :WATER
			multipliers[:final_damage_multiplier] /= 1.5
		end
		 
		 # Bonus Damage in Rain (Water1)
		case user.effectiveWeather
			when :Rain, :HeavyRain
				if user.pbHasEggGroup?(:Water1)
				multipliers[:final_damage_multiplier] *= 1.15
			end
		end
		
		# Bonus Damage for Water Moves (Water2)
		if user.pbHasEggGroup?(:Water2) && type == :WATER
			multipliers[:final_damage_multiplier] *= 1.15
		end
		
		# Damage Resist from Special Moves (Water3)
		if target.pbHasEggGroup?(:Water2) && specialMove?
			multipliers[:final_damage_multiplier] /= 1.15
		end
		
		# Bonus Damage for all Moves (Humanlike)
		if user.pbHasEggGroup?(:Humanlike)
			multipliers[:final_damage_multiplier] *= 1.1
		end
		
		# Bonus Damage in Sandstorm (Mineral)
		case user.effectiveWeather
			when :Sandstorm
				if user.pbHasEggGroup?(:Mineral)
				multipliers[:final_damage_multiplier] *= 1.3
			end
		end
		
		# Bonus Defense (Field)
		if user.pbHasEggGroup?(:Field)
			multipliers[:defense_multiplier] *= 1.15
		end
		
		# Damage Resist From Special Moves (Fairy)
		if target.pbHasEggGroup?(:Fairy) && specialMove?
			multipliers[:final_damage_multiplier] /= 1.3
		end
		
		# Bonus Damage in Sunlight (Grass)
		case user.effectiveWeather
			when :Sun, :HarshSun
				if user.pbHasEggGroup?(:Grass)
				multipliers[:final_damage_multiplier] *= 1.3
			end
		end
		
		# Damage Bonus from Physical Moves (Dragon)
		if user.pbHasEggGroup?(:Dragon) && physicalMove?
			multipliers[:final_damage_multiplier] *= 1.1
		end
		
		# Damage Resist From Physical Moves (Dragon)
		if target.pbHasEggGroup?(:Dragon) && physicalMove?
			multipliers[:final_damage_multiplier] /= 1.1
		end
		
	end



end
