#==================================================
# Defining the Battler for use in Battles! (Code by wrigty12!)
#==================================================

class Battle::Battler
    
	def pbHasEggGroup?(group)
		return false if !group
		eggGroups = self.pokemon.species_data.egg_groups
		return eggGroups.include?(GameData::EggGroup.get(group).id)
	end

	alias egg_group_airborne airborne?
		def airborne?
		ret = egg_group_airborne
		
		return true if pbHasEggGroup?(:Flying)
		return ret
	end
	
	alias egg_group_sandstorm_damage takesSandstormDamage?
		def takesSandstormDamage?
		ret = egg_group_sandstorm_damage
		
		return false if pbHasEggGroup?(:Mineral)
		return ret
	end
		

	alias egg_group_can_confuse pbCanConfuse?
		def pbCanConfuse?(user = nil, showMessages = true, move = nil, selfInflicted = false)
		ret = egg_group_can_confuse(user = nil, showMessages = true, move = nil, selfInflicted = false)
	
		if pbHasEggGroup?(:Bug)
			@battle.pbDisplay(_INTL("{1} can't get confused!", pbThis))
			return false
		end
		return ret	
	end	
  
end