module GameData
  class << self
    alias _itemcrafter_load_all load_all
    def load_all
      _itemcrafter_load_all
      Recipe.load
    end
  end
end

module Compiler
  module_function
  
  def compile_recipes(path = "PBS/recipes.txt")
    compile_pbs_file_message_start(path)
    GameData::Recipe::DATA.clear
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::Recipe::SCHEMA
      idx = 0
      pbEachFileSection(f) { |contents, recipe_id|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        contents["InternalName"] = recipe_id
        # Go through schema hash of compilable data and compile this section
        schema.each_key do |key|
          FileLineData.setSection(recipe_id, key, contents[key])   # For error reporting
          # Skip empty properties, or raise an error if a required property is
          # empty
          if contents[key].nil?
            if ["Item", "Ingredients"].include?(key)
              raise _INTL("The entry {1} is required in {2} section {3}.", key, path, recipe_id)
            end
            next
          end
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.empty?
          contents[key] = value
          if value && ["Ingredients"].include?(key)
            # Ensure Ingredients are in arrays and item IDs are symbols
            contents[key].map! do |x|
              next [x[0].to_sym,x[1]] if GameData::Item.exists?(x[0].to_sym)
              next x
            end
          end
        end
        # Construct recipe hash
        recipe_hash = {
          :id          => contents["InternalName"].to_sym,
          :item        => contents["Item"],
          :yield       => contents["Yield"],
          :ingredients => contents["Ingredients"],
          :flags       => contents["Flags"]
        }
        # Add recipe's data to records
        GameData::Recipe.register(recipe_hash)
      }
    }
    # Save all data
    GameData::Recipe.save
    process_pbs_file_message_end
  end
  
  class << self
    alias _itemcrafter_compile_pbs_files compile_pbs_files
    def compile_pbs_files
      _itemcrafter_compile_pbs_files
      compile_recipes
    end
  end
end