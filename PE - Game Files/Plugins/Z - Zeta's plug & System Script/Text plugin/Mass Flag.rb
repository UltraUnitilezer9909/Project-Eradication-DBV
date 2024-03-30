#Checck: https://reliccastle.com/resources/1303/
# Mass flag by techskylander1812
def pbMassFlag(pbs,flag,array)
    case pbs
      when :Items
        GameData::Item.each do |itm|
          next if !array.include?(itm.id)
          item_hash = {
            :id          => itm.id,
            :name        => itm.real_name,
            :name_plural => itm.real_name_plural,
            :pocket      => itm.pocket,
            :price       => itm.price,
            :sell_price  => itm.sell_price,
            :description => itm.real_description,
            :field_use   => itm.field_use,
            :battle_use  => itm.battle_use,
            :consumable  => itm.consumable,
            :flags       => itm.flags.push(flag),
            :move        => itm.move
          }
          GameData::Item.register(item_hash)
        end
        GameData::Item.save
        Compiler.write_items
      when :Moves
        GameData::Move.each do |move|
          next if !array.include?(move.id)
          move_hash = {
            :id            => move.id,
            :name          => move.name,
            :function_code => move.function_code,
            :base_damage   => move.base_damage,
            :type          => move.type,
            :category      => move.category,
            :accuracy      => move.accuracy,
            :total_pp      => move.total_pp,
            :effect_chance => move.effect_chance,
            :target        => move.target,
            :priority      => move.priority,
            :flags         => move.flags.push(flag),
            :description   => move.description
          }
          GameData::Move.register(move_hash)
        end
        GameData::Move.save
        Compiler.write_moves
      when :Species, :Pokemon
            GameData::Species.each do |spec|
            next if !array.include?(spec.id)
            moves = []
            spec.moves.each_with_index { |m, i| moves.push(m.clone.push(i)) }
            moves.sort! { |a, b| (a[0] == b[0]) ? a[2] <=> b[2] : a[0] <=> b[0] }
            moves.each { |m| m.pop }
            evolutions = []
            spec.evolutions.each { |e| evolutions.push(e.clone) if !e[3] }
            types = [spec.types[0], spec.types[1]].uniq.compact          # Types
            types = nil if types.empty?
            egg_groups = [spec.egg_groups[0], spec.egg_groups[1]].uniq.compact   # Egg groups
            egg_groups = nil if egg_groups.empty?
            abilities = [spec.abilities[0], spec.abilities[1]].uniq.compact    # Abilities
            hidden_abilities = [spec.hidden_abilities[0], spec.hidden_abilities[1], spec.hidden_abilities[2], spec.hidden_abilities[3]].uniq.compact   # Hidden abilities
            # Construct species hash
            species_hash = {
              :id                 => spec.id,
              :name               => spec.real_name,
              :form_name          => spec.real_form_name,
              :category           => spec.real_category,
              :pokedex_entry      => spec.real_pokedex_entry,
              :types              => types,              # 5, 6
              :base_stats         => spec.base_stats,
              :evs                => spec.evs,
              :base_exp           => spec.base_exp, #spec.calculated_exp for scripted xp
              :growth_rate        => spec.growth_rate,
              :gender_ratio       => spec.gender_ratio,
              :catch_rate         => spec.catch_rate,
              :happiness          => spec.happiness,
              :moves              => moves,
              :tutor_moves        => spec.tutor_moves.clone,
              :egg_moves          => spec.egg_moves.clone,
              :abilities          => abilities,          # 17, 18
              :hidden_abilities   => hidden_abilities,   # 19, 20, 21, 22
              :wild_item_common   => spec.wild_item_common.clone,
              :wild_item_uncommon => spec.wild_item_uncommon.clone,
              :wild_item_rare     => spec.wild_item_rare.clone,
              :egg_groups         => egg_groups,         # 26, 27
              :hatch_steps        => spec.hatch_steps,
              :incense            => spec.incense,
              :offspring          => spec.offspring,
              :evolutions         => evolutions,
              :height             => spec.height,
              :weight             => spec.weight,
              :color              => spec.color,
              :shape              => spec.shape,
              :habitat            => spec.habitat,
              :generation         => spec.generation,
              :flags              => spec.flags.push(flag)
            }
            # Add species' data to records
            GameData::Species.register(species_hash)
          end
          GameData::Species.save
          Compiler.write_pokemon
    end
  end
  
  
  def pbMassTutor(move,array)
    GameData::Species.each do |spec|
    next if !array.include?(spec.id)
    moves = []
    spec.moves.each_with_index { |m, i| moves.push(m.clone.push(i)) }
    moves.sort! { |a, b| (a[0] == b[0]) ? a[2] <=> b[2] : a[0] <=> b[0] }
    moves.each { |m| m.pop }
    evolutions = []
    spec.evolutions.each { |e| evolutions.push(e.clone) if !e[3] }
    types = [spec.types[0], spec.types[1]].uniq.compact          # Types
    types = nil if types.empty?
    egg_groups = [spec.egg_groups[0], spec.egg_groups[1]].uniq.compact   # Egg groups
    egg_groups = nil if egg_groups.empty?
    abilities = [spec.abilities[0], spec.abilities[1]].uniq.compact    # Abilities
    hidden_abilities = [spec.hidden_abilities[0], spec.hidden_abilities[1], spec.hidden_abilities[2], spec.hidden_abilities[3]].uniq.compact   # Hidden abilities
    # Construct species hash
    species_hash = {
      :id                 => spec.id,
      :name               => spec.real_name,
      :form_name          => spec.real_form_name,
      :category           => spec.real_category,
      :pokedex_entry      => spec.real_pokedex_entry,
      :types              => types,              # 5, 6
      :base_stats         => spec.base_stats,
      :evs                => spec.evs,
      :base_exp           => spec.base_exp, #spec.calculated_exp for scripted xp
      :growth_rate        => spec.growth_rate,
      :gender_ratio       => spec.gender_ratio,
      :catch_rate         => spec.catch_rate,
      :happiness          => spec.happiness,
      :moves              => moves,
      :tutor_moves        => spec.tutor_moves.clone.push(move).uniq!.sort,
      :egg_moves          => spec.egg_moves.clone,
      :abilities          => abilities,          # 17, 18
      :hidden_abilities   => hidden_abilities,   # 19, 20, 21, 22
      :wild_item_common   => spec.wild_item_common.clone,
      :wild_item_uncommon => spec.wild_item_uncommon.clone,
      :wild_item_rare     => spec.wild_item_rare.clone,
      :egg_groups         => egg_groups,         # 26, 27
      :hatch_steps        => spec.hatch_steps,
      :incense            => spec.incense,
      :offspring          => spec.offspring,
      :evolutions         => evolutions,
      :height             => spec.height,
      :weight             => spec.weight,
      :color              => spec.color,
      :shape              => spec.shape,
      :habitat            => spec.habitat,
      :generation         => spec.generation,
      :flags              => spec.flags
    }
    # Add species' data to records
    GameData::Species.register(species_hash)
    end
    GameData::Species.save
    Compiler.write_pokemon
  end