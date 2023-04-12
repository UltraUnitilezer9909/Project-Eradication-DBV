#===============================================================================
# Revamps base Essentials code related to NPC Trainers to allow for plugin 
# compatibility.
#===============================================================================


#-------------------------------------------------------------------------------
# Rewrites Trainer data to consider plugin properties.
#-------------------------------------------------------------------------------
module GameData
  class Trainer
    SCHEMA["Ace"]        = [:trainer_ace, "b"]
    SCHEMA["Focus"]      = [:focus,       "u"] # Placeholder
    SCHEMA["Birthsign"]  = [:birthsign,   "u"] # Placeholder
    SCHEMA["DynamaxLvl"] = [:dynamax_lvl, "u"]
    SCHEMA["Gigantamax"] = [:gmaxfactor,  "b"]
    SCHEMA["NoDynamax"]  = [:nodynamax,   "b"]
    SCHEMA["Mastery"]    = [:mastery,     "b"]
    SCHEMA["TeraType"]   = [:teratype,    "u"] # Placeholder
    
    alias dx_to_trainer to_trainer
    def to_trainer
      plugins = [
        "ZUD Mechanics", 
        "PLA Battle Styles", 
        "Terastal Phenomenon", 
        "Focus Meter System", 
        "Pokémon Birthsigns"
      ]
      trainer = dx_to_trainer
      trainer.party.each_with_index do |pkmn, i|
        pkmn_data = @pokemon[i]
        pkmn.ace = (pkmn_data[:trainer_ace]) ? true : false
        plugins.each do |plugin|
          if PluginManager.installed?(plugin)
            case plugin
            when "ZUD Mechanics"
              if pkmn.shadowPokemon? || pkmn_data[:nodynamax]
                pkmn.dynamax_able = false
                pkmn.dynamax_lvl = 0
                pkmn.gmax_factor = false
              else
                pkmn.dynamax_lvl = pkmn_data[:dynamax_lvl]
                pkmn.gmax_factor = (pkmn_data[:gmaxfactor]) ? true : false
              end
            when "PLA Battle Styles"
              if pkmn.shadowPokemon?
                pkmn.moves.each { |m| m.mastered = false }
              else
                pkmn.master_moveset if pkmn_data[:mastery]
              end
            when "Terastal Phenomenon"
              pkmn.tera_type = (pkmn.shadowPokemon?) ? nil : pkmn_data[:teratype]
            when "Focus Meter System"
              pkmn.focus_style = (pkmn.shadowPokemon?) ? :None : (pkmn_data[:focus] || Settings::FOCUS_STYLE_DEFAULT)
            when "Pokémon Birthsigns"
              pkmn.birthsign = (pkmn.shadowPokemon?) ? :VOID : (pkmn_data[:birthsign] || :VOID)
            end
          end
        end
        pkmn.calc_stats
      end
      return trainer
    end
  end
end


#-------------------------------------------------------------------------------
# Rewrites in-game Trainer editor to consider plugin properties.
#-------------------------------------------------------------------------------
module TrainerPokemonProperty
  def self.set(settingname, initsetting)
    initsetting = { :species => nil, :level => 10 } if !initsetting
    oldsetting = [
      initsetting[:species],
      initsetting[:level],
      initsetting[:name],
      initsetting[:form],
      initsetting[:gender],
      initsetting[:shininess],
      initsetting[:super_shininess],
      initsetting[:shadowness]
    ]
    Pokemon::MAX_MOVES.times do |i|
      oldsetting.push((initsetting[:moves]) ? initsetting[:moves][i] : nil)
    end
    oldsetting.concat([
      initsetting[:ability],
      initsetting[:ability_index],
      initsetting[:item],
      initsetting[:nature],
      initsetting[:iv],
      initsetting[:ev],
      initsetting[:happiness],
      initsetting[:poke_ball],
      initsetting[:trainer_ace],
      initsetting[:focus],
      initsetting[:birthsign],
      initsetting[:dynamax_lvl], 
      initsetting[:gmaxfactor],
      initsetting[:nodynamax],
      initsetting[:mastery],
      initsetting[:teratype]
    ])
    max_level = GameData::GrowthRate.max_level
    pkmn_properties = [
      [_INTL("Species"),       SpeciesProperty,                         _INTL("Species of the Pokémon.")],
      [_INTL("Level"),         NonzeroLimitProperty.new(max_level),     _INTL("Level of the Pokémon (1-{1}).", max_level)],
      [_INTL("Name"),          StringProperty,                          _INTL("Name of the Pokémon.")],
      [_INTL("Form"),          LimitProperty2.new(999),                 _INTL("Form of the Pokémon.")],
      [_INTL("Gender"),        GenderProperty,                          _INTL("Gender of the Pokémon.")],
      [_INTL("Shiny"),         BooleanProperty2,                        _INTL("If set to true, the Pokémon is a different-colored Pokémon.")],
      [_INTL("SuperShiny"),    BooleanProperty2,                        _INTL("Whether the Pokémon is super shiny (shiny with a special shininess animation).")],
      [_INTL("Shadow"),        BooleanProperty2,                        _INTL("If set to true, the Pokémon is a Shadow Pokémon.")]
    ]
    Pokemon::MAX_MOVES.times do |i|
      pkmn_properties.push([_INTL("Move {1}", i + 1),
                            MovePropertyForSpecies.new(oldsetting), _INTL("A move known by the Pokémon. Leave all moves blank (use Z key to delete) for a wild moveset.")])
    end
    #---------------------------------------------------------------------------
    # Plugin-specific properties.
    nil_prop = [_INTL("Plugin Property"), ReadOnlyProperty, _INTL("This property requires a certain plugin to be installed to set.")]
    #---------------------------------------------------------------------------
    # Focus Style
    if PluginManager.installed?("Focus Meter System")
      property_Focus = [_INTL("Focus"), GameDataProperty.new(:Focus), _INTL("Focus style of the Pokémon.")]
    else
      plugin_name = "\n[Focus Meter System]"
      property_Focus = [nil_prop[0], nil_prop[1], nil_prop[2] + plugin_name]
    end
    #---------------------------------------------------------------------------
    # Birthsign
    if PluginManager.installed?("Pokémon Birthsigns")
      property_Birthsign = [_INTL("Birthsign"), GameDataProperty.new(:Birthsign), _INTL("Birthsign of the Pokémon.")]
    else
      plugin_name = "\n[Pokémon Birthsigns]"
      property_Birthsign = [nil_prop[0], nil_prop[1], nil_prop[2] + plugin_name]
    end
    #---------------------------------------------------------------------------
    # Dynamax Level/G-Max Factor/Eligibility
    if PluginManager.installed?("ZUD Mechanics")
      property_DynamaxLvl = [_INTL("Dynamax Lvl"), LimitProperty2.new(10), _INTL("Dynamax level of the Pokémon (0-10).")]
      property_GmaxFactor = [_INTL("G-Max Factor"), BooleanProperty2, _INTL("If set to true, the Pokémon will have G-Max Factor.")]
      property_NoDynamax  = [_INTL("No Dynamax"), BooleanProperty2, _INTL("If set to true, the Pokémon will be unable to Dynamax. This allows for other mechanics such as Battle Styles or Terastallization.")]
    else
      plugin_name = "\n[ZUD Plugin]"
      property_DynamaxLvl = [nil_prop[0], nil_prop[1], nil_prop[2] + plugin_name]
      property_GmaxFactor = [nil_prop[0], nil_prop[1], nil_prop[2] + plugin_name]
      property_NoDynamax  = [nil_prop[0], nil_prop[1], nil_prop[2] + plugin_name]
    end
    #---------------------------------------------------------------------------
    # Move Mastery
    if PluginManager.installed?("PLA Battle Styles")
      property_Mastery = [_INTL("Mastery"), BooleanProperty2, _INTL("If set to true, the Pokémon's eligible moves will be mastered.")]
    else
      plugin_name = "\n[PLA Battle Styles]"
      property_Mastery = [nil_prop[0], nil_prop[1], nil_prop[2] + plugin_name]
    end
    #---------------------------------------------------------------------------
    # Tera Type
    if PluginManager.installed?("Terastal Phenomenon")
      property_Tera = [_INTL("Tera Type"), GameDataProperty.new(:Type), _INTL("Tera Type of the Pokémon.")]
    else
      plugin_name = "\n[Terastal Phenomenon]"
      property_Tera = [nil_prop[0], nil_prop[1], nil_prop[2] + plugin_name]
    end
    #---------------------------------------------------------------------------
    pkmn_properties.concat(
      [[_INTL("Ability"),       AbilityProperty,                         _INTL("Ability of the Pokémon. Overrides the ability index.")],
       [_INTL("Ability index"), LimitProperty2.new(99),                  _INTL("Ability index. 0=first ability, 1=second ability, 2+=hidden ability.")],
       [_INTL("Held item"),     ItemProperty,                            _INTL("Item held by the Pokémon.")],
       [_INTL("Nature"),        GameDataProperty.new(:Nature),           _INTL("Nature of the Pokémon.")],
       [_INTL("IVs"),           IVsProperty.new(Pokemon::IV_STAT_LIMIT), _INTL("Individual values for each of the Pokémon's stats.")],
       [_INTL("EVs"),           EVsProperty.new(Pokemon::EV_STAT_LIMIT), _INTL("Effort values for each of the Pokémon's stats.")],
       [_INTL("Happiness"),     LimitProperty2.new(255),                 _INTL("Happiness of the Pokémon (0-255).")],
       [_INTL("Poké Ball"),     BallProperty.new(oldsetting),            _INTL("The kind of Poké Ball the Pokémon is kept in.")],
       [_INTL("Ace"),           BooleanProperty2,                        _INTL("Flags this Pokémon as this trainer's ace. Used by certain plugins below.")],
       property_Focus, 
       property_Birthsign, 
       property_DynamaxLvl, 
       property_GmaxFactor, 
       property_NoDynamax, 
       property_Mastery, 
       property_Tera
    ])
    pbPropertyList(settingname, oldsetting, pkmn_properties, false)
    return nil if !oldsetting[0]
    ret = {
      :species         => oldsetting[0],
      :level           => oldsetting[1],
      :name            => oldsetting[2],
      :form            => oldsetting[3],
      :gender          => oldsetting[4],
      :shininess       => oldsetting[5],
      :super_shininess => oldsetting[6],
      :shadowness      => oldsetting[7],
      :ability         => oldsetting[8 + Pokemon::MAX_MOVES],
      :ability_index   => oldsetting[9 + Pokemon::MAX_MOVES],
      :item            => oldsetting[10 + Pokemon::MAX_MOVES],
      :nature          => oldsetting[11 + Pokemon::MAX_MOVES],
      :iv              => oldsetting[12 + Pokemon::MAX_MOVES],
      :ev              => oldsetting[13 + Pokemon::MAX_MOVES],
      :happiness       => oldsetting[14 + Pokemon::MAX_MOVES],
      :poke_ball       => oldsetting[15 + Pokemon::MAX_MOVES],
      :trainer_ace     => oldsetting[16 + Pokemon::MAX_MOVES],
      :focus           => oldsetting[17 + Pokemon::MAX_MOVES],
      :birthsign       => oldsetting[18 + Pokemon::MAX_MOVES],
      :dynamax_lvl     => oldsetting[19 + Pokemon::MAX_MOVES],
      :gmaxfactor      => oldsetting[20 + Pokemon::MAX_MOVES],
      :nodynamax       => oldsetting[21 + Pokemon::MAX_MOVES],
      :mastery         => oldsetting[22 + Pokemon::MAX_MOVES],
      :teratype        => oldsetting[23 + Pokemon::MAX_MOVES]
    }
    moves = []
    Pokemon::MAX_MOVES.times do |i|
      moves.push(oldsetting[7 + i])
    end
    moves.uniq!
    moves.compact!
    ret[:moves] = moves
    return ret
  end
end