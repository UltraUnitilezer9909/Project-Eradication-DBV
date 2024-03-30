#===============================================================================
# * Compile & save BP price
#===============================================================================

module GameData
  class Item
    attr_accessor :real_name
    attr_accessor :real_name_plural
    attr_accessor :real_portion_name
    attr_accessor :real_portion_name_plural
    attr_accessor :pocket
    attr_accessor :bp_price
    attr_accessor :real_description
    attr_accessor :real_held_description
    attr_accessor :field_use
    attr_accessor :battle_use
    attr_accessor :flags
  end
end

#-------------------------------------------------------------------------------
# Compiler.
#-------------------------------------------------------------------------------
module Compiler
  module_function

  if PluginManager.installed?("Essentials Deluxe") || PluginManager.installed?("Lin's Friend Safari")
    PLUGIN_FILES += ["BP System"]
  else
    PLUGIN_FILES = ["BP System"]
  end

  #-----------------------------------------------------------------------------
  # Writing data
  #-----------------------------------------------------------------------------
  def write_items(path = "PBS/items.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      GameData::Item.each do |item|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s]\r\n", item.id))
        f.write(sprintf("Name = %s\r\n", item.real_name))
        f.write(sprintf("NamePlural = %s\r\n", item.real_name_plural))
        f.write(sprintf("PortionName = %s\r\n", item.real_portion_name)) if item.real_portion_name
        f.write(sprintf("PortionNamePlural = %s\r\n", item.real_portion_name_plural)) if item.real_portion_name_plural
        f.write(sprintf("Pocket = %d\r\n", item.pocket))
        f.write(sprintf("Price = %d\r\n", item.price))
        f.write(sprintf("SellPrice = %d\r\n", item.sell_price)) if item.sell_price != item.price / 2
        f.write(sprintf("BPPrice = %d\r\n", item.bp_price)) if item.bp_price != item.price
        field_use = GameData::Item::SCHEMA["FieldUse"][2].key(item.field_use)
        f.write(sprintf("FieldUse = %s\r\n", field_use)) if field_use
        battle_use = GameData::Item::SCHEMA["BattleUse"][2].key(item.battle_use)
        f.write(sprintf("BattleUse = %s\r\n", battle_use)) if battle_use
        f.write(sprintf("Consumable = false\r\n")) if !item.is_important? && !item.consumable
        f.write(sprintf("Flags = %s\r\n", item.flags.join(","))) if item.flags.length > 0
        f.write(sprintf("Move = %s\r\n", item.move)) if item.move
        f.write(sprintf("Description = %s\r\n", item.real_description))
        f.write(sprintf("HeldDescription = %s\r\n", item.real_held_description)) if item.real_held_description
      end
    }
    process_pbs_file_message_end
  end

  #-----------------------------------------------------------------------------
  # Compiles any additional items included by a plugin.
  #-----------------------------------------------------------------------------
  def compile_plugin_items
    compiled = false
    return if PLUGIN_FILES.empty?
    schema = GameData::Item::SCHEMA
    item_names                = []
    item_names_plural         = []
    item_portion_names        = []
    item_portion_names_plural = []
    item_descriptions         = []
    item_held_descriptions    = []
    PLUGIN_FILES.each do |plugin|
      path = "PBS/Plugins/#{plugin}/items.txt"
      next if !safeExists?(path)
      compile_pbs_file_message_start(path)
      item_hash = nil
      idx = 0
      #-------------------------------------------------------------------------
      # Item is an existing item to be edited.
      #-------------------------------------------------------------------------
      File.open(path, "rb") { |f|
        FileLineData.file = path
        pbEachFileSectionEx(f) { |contents, item_id|
          echo "." if idx % 250 == 0
          idx += 1
          FileLineData.setSection(item_id, "header", nil)
          id = item_id.to_sym
          next if !GameData::Item.try_get(id)
          item = GameData::Item::DATA[id]
          schema.keys.each do |key|
            if nil_or_empty?(contents[key])
              contents[key] = nil
              next
            end
            FileLineData.setSection(item_id, key, contents[key])
            value = pbGetCsvRecord(contents[key], key, schema[key])
            value = nil if value.is_a?(Array) && value.length == 0
            contents[key] = value
            case key
            when "Name"
              if item.real_name != contents[key]
                item.real_name = contents[key]
                item_names.push(contents[key])
                compiled = true
              end
            when "NamePlural"
              if item.real_name_plural != contents[key]
                item.real_name_plural = contents[key]
                item_names_plural.push(contents[key])
                compiled = true
              end
            when "PortionName"
              if item.real_portion_name != contents[key]
                item.real_portion_name = contents[key]
                item_portion_names.push(contents[key])
                compiled = true
              end
            when "PortionNamePlural"
              if item.real_portion_name_plural != contents[key]
                item.real_portion_name_plural = contents[key]
                item_portion_names_plural.push(contents[key])
                compiled = true
              end
            when "BPPrice"
              if item.bp_price != contents[key]
                item.bp_price = contents[key]
                compiled = true
              end
            when "Description"
              if item.real_description != contents[key]
                item.real_description = contents[key]
                item_descriptions.push(contents[key])
                compiled = true
              end
            when "HeldDescription"
              if item.real_held_description != contents[key]
                item.real_held_description = contents[key]
                item_held_descriptions.push(contents[key])
                compiled = true
              end
            when "Flags"
              contents[key] = [contents[key]] if !contents[key].is_a?(Array)
              contents[key].compact!
              contents[key].each do |flag|
                next if item.flags.include?(flag)
                if flag.include?("Remove_")
                  string = flag.split("_")
                  item.flags.delete(string[1])
                else
                  item.flags.push(flag)
                end
                compiled = true
              end
            when "Pocket"
              if item.pocket != contents[key]
                item.pocket = contents[key]
                compiled = true
              end
            when "FieldUse"
              if item.field_use != contents[key]
                item.field_use = contents[key]
                compiled = true
              end
            when "BattleUse"
              if item.battle_use != contents[key]
                item.battle_use = contents[key]
                compiled = true
              end
            end
          end
        }
      }
	  #-------------------------------------------------------------------------
	  # Item is a newly added item.
	  #-------------------------------------------------------------------------
      pbCompilerEachPreppedLine(path) { |line, line_no|
        echo "." if idx % 250 == 0
        idx += 1
        if line[/^\s*\[\s*(.+)\s*\]\s*$/]
          GameData::Item.register(item_hash) if item_hash
          item_id = $~[1].to_sym
          if GameData::Item.exists?(item_id)
            item_hash = nil
            next
          end
          item_hash = {
            :id => item_id
          }
        elsif line[/^\s*(\w+)\s*=\s*(.*)\s*$/] && !item_hash.nil?
          property_name = $~[1]
          if property_name == "EditOnly"
            item_hash = nil
            next
          end
          line_schema = schema[property_name]
          next if !line_schema
          property_value = pbGetCsvRecord($~[2], line_no, line_schema)
          item_hash[line_schema[0]] = property_value
          case property_name
          when "Name"
            item_names.push(item_hash[:name])
          when "NamePlural"
            item_names_plural.push(item_hash[:name_plural])
          when "PortionName"
            item_portion_names.push(item_hash[:portion_name])
          when "PortionNamePlural"
            item_portion_names_plural.push(item_hash[:portion_name_plural])
          when "Description"
            item_descriptions.push(item_hash[:description])
          when "HeldDescription"
            item_held_descriptions.push(item_hash[:held_description])
          end
        end
      }
      if item_hash
        GameData::Item.register(item_hash)
        compiled = true
      end
      process_pbs_file_message_end
      begin
        File.delete(path)
        rescue SystemCallError
      end
    end
    if compiled
      GameData::Item.save
      Compiler.write_items
      MessageTypes.setMessagesAsHash(MessageTypes::Items, item_names)
      MessageTypes.setMessagesAsHash(MessageTypes::ItemPlurals, item_names_plural)
      MessageTypes.setMessagesAsHash(MessageTypes::ItemPortionNames, item_portion_names)
      MessageTypes.setMessagesAsHash(MessageTypes::ItemPortionNamePlurals, item_portion_names_plural)
      MessageTypes.setMessagesAsHash(MessageTypes::ItemDescriptions, item_descriptions)
      MessageTypes.setMessagesAsHash(MessageTypes::ItemHeldDescriptions, item_held_descriptions)
    end
  end

  #-----------------------------------------------------------------------------
  # Compiling all plugin data
  #-----------------------------------------------------------------------------
  def compile_all(mustCompile)
    PLUGIN_FILES.each do |plugin|
      for file in ["abilities", "items", "moves", "pokemon", "map_metadata"]
        path = "PBS/Plugins/#{plugin}/#{file}.txt"
        mustCompile = true if safeExists?(path)
      end
    end
    return if !mustCompile
    FileLineData.clear
    Console.echo_h1 _INTL("Starting full compile")
    compile_pbs_files
    if !PLUGIN_FILES.empty?
      echoln ""
      Console.echo_h1 _INTL("Compiling additional plugin data")
      compile_plugin_abilities		if PluginManager.installed?("Essentials Deluxe")
      compile_plugin_items
      compile_plugin_moves		if PluginManager.installed?("Essentials Deluxe")
      compile_plugin_species_data	if PluginManager.installed?("Essentials Deluxe") || PluginManager.installed?("Lin's Friend Safari") || PluginManager.installed?("Charms Compilation")
      compile_plugin_map_metadata	if PluginManager.installed?("Essentials Deluxe")
      echoln ""
      echoln ""
      Console.echo_h2("Plugin data fully compiled", text: :green)
      echoln ""
    end
    compile_animations
    compile_trainer_events(mustCompile)
    Console.echo_li _INTL("Saving messages...")
    pbSetTextMessages
    MessageTypes.saveMessages
    MessageTypes.loadMessageFile("Data/messages.dat") if safeExists?("Data/messages.dat")
    Console.echo_done(true)
    Console.echo_li _INTL("Reloading cache...")
    System.reload_cache
    Console.echo_done(true)
    echoln ""
    Console.echo_h2("Successfully fully compiled", text: :green)
  end
  
  def main
    return if !$DEBUG
    begin
      dataFiles = [
        "abilities.dat",
        "berry_plants.dat",
        "encounters.dat",
        "items.dat",
        "map_connections.dat",
        "map_metadata.dat",
        "metadata.dat",
        "moves.dat",
        "phone.dat",
        "player_metadata.dat",
        "regional_dexes.dat",
        "ribbons.dat",
        "shadow_pokemon.dat",
        "species.dat",
        "species_metrics.dat",
        "town_map.dat",
        "trainer_lists.dat",
        "trainer_types.dat",
        "trainers.dat",
        "types.dat"
      ]
      textFiles = [
        "abilities.txt",
        "battle_facility_lists.txt",
        "berry_plants.txt",
        "encounters.txt",
        "items.txt",
        "map_connections.txt",
        "map_metadata.txt",
        "metadata.txt",
        "moves.txt",
        "phone.txt",
        "pokemon.txt",
        "pokemon_forms.txt",
        "pokemon_metrics.txt",
        "regional_dexes.txt",
        "ribbons.txt",
        "shadow_pokemon.txt",
        "town_map.txt",
        "trainer_types.txt",
        "trainers.txt",
        "types.txt"
      ]
      latestDataTime = 0
      latestTextTime = 0
      mustCompile = false
      mustCompile |= import_new_maps
      if !safeIsDirectory?("PBS")
        Dir.mkdir("PBS") rescue nil
        write_all
        mustCompile = true
      end
      dataFiles.each do |filename|
        if safeExists?("Data/" + filename)
          begin
            File.open("Data/#{filename}") { |file|
              latestDataTime = [latestDataTime, file.mtime.to_i].max
            }
          rescue SystemCallError
            mustCompile = true
          end
        else
          mustCompile = true
          break
        end
      end
      textFiles.each do |filename|
        next if !safeExists?("PBS/" + filename)
        begin
          File.open("PBS/#{filename}") { |file|
            latestTextTime = [latestTextTime, file.mtime.to_i].max
          }
        rescue SystemCallError
        end
      end
      mustCompile |= (latestTextTime >= latestDataTime)
      Input.update
      mustCompile = true if Input.press?(Input::CTRL)
      if mustCompile
        dataFiles.length.times do |i|
          begin
            File.delete("Data/#{dataFiles[i]}") if safeExists?("Data/#{dataFiles[i]}")
          rescue SystemCallError
          end
        end
      end
      compile_all(mustCompile)
      rescue Exception
      e = $!
      raise e if e.class.to_s == "Reset" || e.is_a?(Reset) || e.is_a?(SystemExit)
      pbPrintException(e)
      dataFiles.length.times do |i|
        begin
          File.delete("Data/#{dataFiles[i]}")
        rescue SystemCallError
        end
      end
      raise Reset.new if e.is_a?(Hangup)
      loop do
        Graphics.update
      end
    end
  end
end
