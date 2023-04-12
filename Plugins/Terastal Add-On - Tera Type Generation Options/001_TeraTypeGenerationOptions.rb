module TDWSettings
#If true, then any new Pokemon will be assigned a random TeraType, not just one of their original Types
#If false, then new Pokemon will have one of their original Types be their TeraType
TERA_TYPE_ALWAYS_RANDOM		= false
#If true, and TERA_TYPE_ALWAYS_RANDOM = true, a Pokemon's TeraType will have a WEIGHT_PERCENT chance of being one of its original Types instead of a different type.
#If false, and TERA_TYPE_ALWAYS_RANDOM = true, a Pokemon's TeraType will have an even chance of being any Type
WEIGHT_RANDOM_TO_ORIGINAL	= true
WEIGHT_PERCENT				= 50 #integer out of 100; Default 50

#If a Pokemon is wild and you are in a map defined in this MAP_TERA_TYPES array, it will generate its tera type based on the associated settings
#	[[map ids array],[possible tera types array],percent chance integer]
# 		map ids array - as an array, add in map ids you wish to have special tera type generation settings
# 		possible tera types array - as an array, add in possible tera types Pokemon can be in the associated maps
# 			- If you set this item to "random" instead of an array, it will select a tera type at random
#			- If you wish to make this act similar to the TERA_TYPE_ALWAYS_RANDOM functionality, but that only applies to a specific map(s),
#				 you can set the percent chance integer to be the "weight percent" of being random, otherwise it will use the default method (by default, an original Type of the Pokemon)
#		percent chance integer - as an integer out of 100, this is the chance of these generation effects applying to Pokemon, otherwise it sets to the default method.

MAP_TERA_TYPES = [
	[[1,2,3],[:DRAGON,:FAIRY,:FIRE],50],
	[[4],[:WATER],100],
	[[5,6],"random",1] 
]

#If you want certain types to not be included when assigning a random Tera Type to Pokemon, set them in this array.
#		- If one of the Pokemon's original Types include a type in this array, that Pokemon can still have that Tera Type.
#			- For example, even if :DRAGON is in BLOCKED_TERA_TYPES, Dragonite can still have a Dragon Tera Type.
BLOCKED_TERA_TYPES = [
	#:DRAGON,:FAIRY
]

end

class Pokemon 

  alias tdw_tera_type tera_type
  def tera_type
    if !@tera_type
      @tera_type = tdwGenerateTeraType(species_data)
    end
    return tdw_tera_type
  end
  
  def tdwGenerateTeraType(species,wild:false)
	#return @tera_type if @tera_type
	if wild
		TDWSettings::MAP_TERA_TYPES.each do |g|
			if g[0].include?($game_map.map_id)
				if g[1].is_a?(Array) && rand(100)<g[2]
					return g[1].sample
				elsif (g[1] == "random" || "rand") && rand(100)<g[2]
					return pbPickRandomType(species.types)
				end
			end
		end
	end
	if TDWSettings::TERA_TYPE_ALWAYS_RANDOM
		if TDWSettings::WEIGHT_RANDOM_TO_ORIGINAL && rand(100)<TDWSettings::WEIGHT_PERCENT
			return species.types.sample
		else
			return pbPickRandomType(species.types)
		end
	else 
		return tdw_tera_type
	end
  end
  
  alias tdw_tera_type_initialize initialize  
  def initialize(*args)
    tdw_tera_type_initialize(*args)
    @tera_type = tdwGenerateTeraType(GameData::Species.get(args[0]))
  end  

end


alias tdw_tera_Generate_Wild pbGenerateWildPokemon
def pbGenerateWildPokemon(*args)
	pkmn = tdw_tera_Generate_Wild(*args)
	pkmn.tera_type = pkmn.tdwGenerateTeraType(GameData::Species.get(args[0]),wild:true)
	return pkmn
end

def pbPickRandomType(origTypes=[])
	types = []
	GameData::Type.each do |t|
		next if t.pseudo_type || t.id == :SHADOW || (TDWSettings::BLOCKED_TERA_TYPES.include?(t.id) && !origTypes.include?(t.id))
		types.push(t.id)
	end
	return types.sample
end