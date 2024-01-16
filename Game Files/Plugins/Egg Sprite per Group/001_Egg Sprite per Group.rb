#===============================================================================
# * Egg Sprite per Group - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It displays egg sprite based on pokémon 
# first egg group.
#
#===============================================================================

module GameData
  class Species
    class << self
      alias :_check_egg_graphic_file_FL_group :check_egg_graphic_file
      def check_egg_graphic_file(path, species, form, suffix = "")
        ret = _check_egg_graphic_file_FL_group(path, species, form, suffix)
        return ret if ret
        return pbResolveBitmap(sprintf(
          "%s%s%s", path, 
          group_for_egg_graphic(get_species_form(species, form)).to_s, suffix
        ))
      end

      # Returns the selected group symbol.
      # Override this logic if you want to use the second group or create
      # more complex rules.
      def group_for_egg_graphic(data)
        return get_species_data_with_valid_egg_group(data).egg_groups[0]
      end

      # Species that can't breed like Igglybuff uses it's evolution species.
      def get_species_data_with_valid_egg_group(data)
        if data.egg_groups[0] == :Undiscovered && !data.get_evolutions.empty?
          return GameData::Species.get(data.get_evolutions[0][0])
        end
        return data
      end
    end
  end
end