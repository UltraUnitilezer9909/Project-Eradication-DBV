#===============================================================================
# Settings
#===============================================================================
module Settings
  #-----------------------------------------------------------------------------
  # Species that may produce eggs of a different species when holding certain items.
  #-----------------------------------------------------------------------------
  EGG_SPECIES_ITEM = {
    :MEW       => { :MEWTWO    => :BERSERKGENE },
    :PHIONE    => { :MANAPHY   => :MYSTICWATER },
    :REGIGIGAS => { :REGIROCK  => :HARDSTONE,
                    :REGICE    => :NEVERMELTICE,
                    :REGISTEEL => :IRONBALL,
                    :REGIELEKI => :LIGHTBALL,
                    :REGIDRAGO => :DRAGONFANG }
  }
  
  
  #-----------------------------------------------------------------------------
  # Species that may act as a blueprint to genetically engineer Ancient Paradox species.
  #-----------------------------------------------------------------------------
  ANCIENT_PARADOX_SPECIES = {
    :JIGGLYPUFF => :SCREAMTAIL,
    :MAGNETON   => :SANDYSHOCKS,
    :MISDREAVUS => :FLUTTERMANE,
    :DONPHAN    => :GREATTUSK,
    :SUICUNE    => :WALKINGWAKE,
    :SALAMENCE  => :ROARINGMOON,
    :AMOONGUS   => :BRUTEBONNET,
    :VOLCARONA  => :SLITHERWING,
    :CYCLIZAR   => :KORAIDON
  }
  
  #-----------------------------------------------------------------------------
  # Species that may act as a blueprint to mechanically engineer Future Paradox species.
  #-----------------------------------------------------------------------------
  FUTURE_PARADOX_SPECIES = {
    :DELIBIRD   => :IRONBUNDLE,
    :DONPHAN    => :IRONTREADS,
    :TYRANITAR  => :IRONTHORNS,
    :GARDEVOIR  => :IRONVALIANT,
    :HARIYAMA   => :IRONHANDS,
    :GALLADE    => :IRONVALIANT,
    :HYDREIGON  => :IRONJUGULIS,
    :VOLCARONA  => :IRONMOTH,
    :VIRIZION   => :IRONLEAVES,
    :CYCLIZAR   => :MIRAIDON
  }
end


#===============================================================================
# Legendary Egg Groups
#===============================================================================
GameData::EggGroup.register({
  :id   => :Skycrest,
  :name => _INTL("Skycrest")
})

GameData::EggGroup.register({
  :id   => :Bestial,
  :name => _INTL("Bestial")
})

GameData::EggGroup.register({
  :id   => :Titan,
  :name => _INTL("Titan")
})

GameData::EggGroup.register({
  :id   => :Overlord,
  :name => _INTL("Overlord")
})

GameData::EggGroup.register({
  :id   => :Nebulous,
  :name => _INTL("Nebulous")
})

GameData::EggGroup.register({
  :id   => :Enchanted,
  :name => _INTL("Enchanted")
})

GameData::EggGroup.register({
  :id   => :Ancestor,
  :name => _INTL("Ancestor")
})

GameData::EggGroup.register({
  :id   => :Ultra,
  :name => _INTL("Ultra")
})


#===============================================================================
# Breeding compatibility functions
#===============================================================================
class DayCare
  module EggGenerator
    module_function
    
    def egg_species_from_item(babyspecies, mother_item, father_item)
      egg_species = Settings::EGG_SPECIES_ITEM[babyspecies]
      return babyspecies if !egg_species
      egg_species.keys.each do |key|
        if [mother_item, father_item].include?(egg_species[key]) 
          babyspecies = key if GameData::Species.exists?(key)
        end
      end
      return babyspecies
    end
    
    def determine_egg_species(parent_species, mother, father)
      ret = GameData::Species.get(parent_species).get_baby_species(true, mother.item_id, father.item_id)
      offspring = GameData::Species.get(ret).offspring
      ret = offspring.sample if offspring.length > 0
      ret = egg_species_from_item(ret, mother.item_id, father.item_id)
      return ret
    end
	
    def inherit_form(egg, species_parent, mother, father)
      if species_parent.species_data.has_flag?("InheritFormFromMother")
        egg.form = species_parent.form
      end
      species_parent.species_data.flags.each do |flag|
        egg.form = $~[1].to_i if flag[/^InheritForm_(\d+)$/i]
      end
      [mother, father].each do |parent|
        next if !parent[2]
        next if !parent[0].species_data.has_flag?("InheritFormWithEverStone")
        next if !parent[0].hasItem?(:EVERSTONE)
        egg.form = parent[0].form
        break
      end
    end
  end
  
  def compatibility(pkmn = [])
    if pkmn.length == 2
      pkmn1, pkmn2 = pkmn[0], pkmn[1]
    else
      return 0 if self.count != 2
      pkmn1, pkmn2 = pokemon_pair
    end
    return 0 if pkmn1.shadowPokemon? || pkmn2.shadowPokemon?
    return 0 if pkmn1.celestial? || pkmn2.celestial?
    egg_groups1 = pkmn1.species_data.egg_groups
    egg_groups2 = pkmn2.species_data.egg_groups
    return 0 if egg_groups1.include?(:Undiscovered) || egg_groups2.include?(:Undiscovered)
    return 0 if egg_groups1.include?(:Ditto) && legendary_egg_group?(egg_groups2)
    return 0 if egg_groups2.include?(:Ditto) && legendary_egg_group?(egg_groups1)
    return 0 if egg_groups1.include?(:Ancestor) && egg_groups2.include?(:Ultra)
    return 0 if egg_groups1.include?(:Ultra)    && egg_groups2.include?(:Ancestor)
    return 0 if !fluid_egg_group?(egg_groups1 + egg_groups2) && (egg_groups1 & egg_groups2).length == 0
    return 0 if !compatible_gender?(pkmn1, pkmn2)
    ret = 1
    ret += 1 if pkmn1.species == pkmn2.species
    ret += 1 if pkmn1.owner.id != pkmn2.owner.id
    return ret
  end
end


#===============================================================================
# Counts legendary eggs hatched.
#===============================================================================
alias egg_pbHatch pbHatch
def pbHatch(pokemon)
  $stats.legendary_eggs_hatched += 1 if legendary_egg_group?(pokemon.species_data.egg_groups)
  egg_pbHatch(pokemon)
end


#===============================================================================
# Arceus party menu skill for creating eggs.
#===============================================================================
MenuHandlers.add(:party_menu, :egg_skill, {
  "name"      => _INTL("Form Egg"),
  "order"     => 22,
  "condition" => proc { |screen, party, party_idx| 
      next party[party_idx].isSpecies?(:ARCEUS) &&
           [:ADAMANTORB, 
            :LUSTROUSORB, 
            :GRISEOUSORB, 
            :DIVINEPLATE, 
            :FALSEPLATE].include?(party[party_idx].item_id)
  },
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    if party.length >= Settings::MAX_PARTY_SIZE
      screen.pbDisplay(_INTL("There isn't enough space to carry an Egg."))
    elsif pbConfirmMessage(_INTL("Would you like {1} to form a new Egg out of its held item?", pkmn.name))
      case pkmn.item_id
      when :ADAMANTORB  then spawn = :DIALGA
      when :LUSTROUSORB then spawn = :PALKIA
      when :GRISEOUSORB then spawn = :GIRATINA
      when :DIVINEPLATE then spawn = :ARCEUS
      when :FALSEPLATE  then spawn = :TYPENULL
      end
      if GameData::Species.exists?(spawn)
        screen.pbDisplay(_INTL("{1} gathered immense energy!", pkmn.name))
        pbHiddenMoveAnimation(pkmn)
        origin = (spawn == :TYPENULL) ? _INTL("A Corrupted Force.") : _INTL("A Divine Force.")
        pbGenerateEgg(spawn, origin)
        egg = $player.last_party
        # Egg IV's are influenced by Arceus's IV's.
        stats = []
        GameData::Stat.each_main { |s| stats.push(s) }
        chosen_stats = stats.sample(5)
        chosen_stats.each { |stat| egg.iv[stat] = pkmn.iv[stat] }
        # Egg inherits Arceus's ball type.
        egg.poke_ball = pkmn.poke_ball if ![:MASTERBALL, :CHERISHBALL].include?(pkmn.poke_ball)
        pbMessage(_INTL("\\me[Egg get]You received an Egg from {1}!", pkmn.name))
        if [:ARCEUS, :TYPENULL].include?(spawn)
          screen.pbDisplay(_INTL("{1}'s <c2=65467b14>{2}</c2> shattered!", pkmn.name, pkmn.item.portion_name))
          pkmn.item = nil
        else
          screen.pbDisplay(_INTL("{1}'s <c2=65467b14>{2}</c2> fused with the Egg!", pkmn.name, pkmn.item.portion_name))
          egg.item = pkmn.item
          pkmn.item = nil
        end
        screen.pbHardRefresh
      else
        screen.pbDisplay(_INTL("{1} seems unable to to form an Egg with this item...", pkmn.name))
      end
    end
  }
})


#===============================================================================
# Engineering paradox species.
#===============================================================================
class DayCare
  module EggGenerator
    module_function
	
    def generate_paradox(paradox_type, pkmn1, pkmn2)
      pkmn1_data = [pkmn1, pkmn1.species_data.egg_groups.include?(:Ditto), false]
      pkmn2_data = [pkmn2, pkmn2.species_data.egg_groups.include?(:Ditto), false]
      paradox_species = determine_paradox_species(paradox_type, pkmn1.species)
      return if !paradox_species || !GameData::Species.exists?(paradox_species)
      paradox = generate_basic_paradox(paradox_type, paradox_species)
      inherit_nature(paradox, pkmn1, pkmn2)
      inherit_ability(paradox, pkmn1_data, pkmn2_data)
      inherit_moves(paradox, pkmn1_data, pkmn2_data)
      inherit_IVs(paradox, pkmn1, pkmn2)
      inherit_poke_ball(paradox, pkmn1_data, pkmn2_data)
      inherit_birthsign(paradox, pkmn1, pkmn2) if PluginManager.installed?("Pokémon Birthsigns")
      set_shininess(paradox, pkmn1, pkmn2)
      set_pokerus(paradox)
      paradox.steps_to_hatch = 0
      paradox.calc_stats
      return paradox
    end
	
    def determine_paradox_species(paradox_type, parent_species)
      case paradox_type
      when 0, :ancient then paradox_hash = Settings::ANCIENT_PARADOX_SPECIES
      when 1, :future  then paradox_hash = Settings::FUTURE_PARADOX_SPECIES
      end
      return paradox_hash[parent_species]
    end
	
    def generate_basic_paradox(paradox_type, species)
      paradox = Pokemon.new(species, Settings::EGG_LEVEL)
      paradox.obtain_text    = _INTL("Paradox Engineer")
      paradox.happiness      = 120
      paradox.form           = 0
      new_form = MultipleForms.call("getFormOnEggCreation", paradox)
      paradox.form = new_form if new_form
      return paradox
    end
  end
  
  def self.set_paradox(paradox_type, pkmn1, pkmn2)
    paradox = EggGenerator.generate_paradox(paradox_type, pkmn1, pkmn2)
    raise _INTL("Couldn't generate the paradox Pokémon.") if paradox.nil?
    return paradox
  end
end

#-------------------------------------------------------------------------------
# Paradox Engineer event.
#-------------------------------------------------------------------------------
def pbParadoxEngineer(paradox_type = 0, gender = -1, item = nil)
  interp = pbMapInterpreter
  paradox_event = interp.getVariable
  g = (gender == 0) ? "\\b" : (gender == 1) ? "\\r" : ""
  if paradox_event.is_a?(Array)
    paradox_pkmn, event_steps = paradox_event[0], paradox_event[1]
    event_steps -= $PokemonGlobal.paradox_tracker
    event_steps = 0 if $DEBUG && Input.press?(Input::CTRL)
    $PokemonGlobal.paradox_tracker = 0
    if event_steps > 0
      pbMessage(_INTL("#{g}I still need more time to finish engineering this Pokémon."))
      pbMessage(_INTL("#{g}Come back in a little while to see the results!"))
      interp.setVariable([paradox_pkmn, [0, event_steps].max])
    else
      pbMessage(_INTL("#{g}Ah, you're back! Where were you?\nThe Pokémon I engineered for you is complete!"))
      if pbConfirmMessage(_INTL("#{g}Go on, take it!\nYou do want it, don't you?"))
        if pbAddPokemon(paradox_pkmn)
          $stats.paradox_pokemon_engineered += 1
          pbMessage(_INTL("#{g}Whew, that was a lot of work.\nPlease take good care of it!"))
          interp.setVariable(nil)
        end
      else
        pbMessage(_INTL("#{g}Ok, I'll hold on to it for now.\nCome back for it when you're ready!"))
        interp.setVariable([paradox_pkmn, 0])
      end
    end
  else
    interp.setVariable(nil)
    item = :BOOSTERENERGY if !item
    itemname = GameData::Item.get(item).portion_name
    $PokemonGlobal.paradox_tracker = 0
    if interp.tsOff?("A")
      case paradox_type
      when 0, :ancient
        pbMessage(_INTL("#{g}I'm doing research on the mysterious ancient paradox Pokémon!"))
        pbMessage(_INTL("#{g}Data suggests that these prehistoric Pokémon are distant relatives to our modern-day species, " +
                        "and are from an era millions of years in the past."))
        pbMessage(_INTL("#{g}If only I were to find willing subjects to provide data samples, " +
                        "I'm sure that I could use my know-how to replicate these ancient Pokémon in the modern era!"))
      when 1, :future
        pbMessage(_INTL("#{g}I'm doing research on the mysterious futuristic paradox Pokémon!"))
        pbMessage(_INTL("#{g}Data suggests that these cybernetic Pokémon are modeled after our modern-day species, " +
                        "and were built by a civilization far in the future."))
        pbMessage(_INTL("#{g}If only I were to find willing subjects to provide data samples, " +
                        "I'm sure that I could use my know-how to replicate these futuristic Pokémon in the modern era!"))
      end
      pbMessage(_INTL("#{g}Bah! Even if that were true, I'm still missing the proper energy source for my experiments..."))
      if $bag.has?(item)
        pbMessage(_INTL("#{g}Huh?\nWhat's this?"))
        pbMessage(_INTL("#{g}That {1} - that's exactly what I've been looking for!", itemname))
        pbMessage(_INTL("#{g}Tell you what, if you give me that {1}, I can use it to engineer a paradox Pokémon for you!", itemname))
        pbMessage(_INTL("#{g}C'mon, what do you say?"))
        interp.setTempSwitchOn("A")
      else
        text = (itemname.starts_with_vowel?) ? "an" : "a"
        pbMessage(_INTL("#{g}If you ever find {1} {2} in your travels, please come find me again!", text, itemname))
        return
      end
    end
    if pbConfirmMessage(_INTL("#{g}Would you like me to engineer a new paradox Pokémon?"))
      if $bag.has?(item)
        case paradox_type
        when 0, :ancient then paradox_hash = Settings::ANCIENT_PARADOX_SPECIES
        when 1, :future  then paradox_hash = Settings::FUTURE_PARADOX_SPECIES
        end
        has_blueprint = false
        paradox_hash.keys.each { |s| has_blueprint = true if $player.has_species?(s) }
        if has_blueprint
          pbMessage(_INTL("#{g}Excellent!\nFirst, provide a Pokémon sample for me to model my work on."))
          pbChoosePokemon(1, 2, proc { |pkmn|
            next !pkmn.egg? && !pkmn.shadowPokemon? && paradox_hash.include?(pkmn.species)
          })
          if pbGet(1) < 0
            pbMessage(_INTL("#{g}Hmm? Did you change your mind?"))
          else
            pkmn1 = $player.party[pbGet(1)]
            pbMessage(_INTL("#{g}Next, I'll need a sample from a second Pokémon that is compatible with {1}.\nThis'll help modify my results!", pkmn1.name))
            pbChoosePokemon(1, 2, proc { |pkmn|
              compatible = $PokemonGlobal.day_care.compatibility([pkmn1, pkmn]) > 0
              next !pkmn.egg? && !pkmn.shadowPokemon? && pkmn != pkmn1 && compatible
            })
            if pbGet(1) < 0
              pbMessage(_INTL("#{g}Hmm? Did you change your mind?"))
            else
              pkmn2 = $player.party[pbGet(1)]
              pbMessage(_INTL("#{g}Almost done! Finally, I'll need that {1} to finish the experiment.", itemname))
              if pbConfirmMessage(_INTL("#{g}Would you like me to use the {1} to complete the process?", itemname))
                $bag.remove(item)
                paradox_pkmn = DayCare.set_paradox(paradox_type, pkmn1, pkmn2)
                interp.setVariable([paradox_pkmn, paradox_pkmn.species_data.hatch_steps])
                pbMessage(_INTL("#{g}It'll take some time to finish engineering this Pokémon."))
                pbMessage(_INTL("#{g}Come back in a little while to see the results!"))
                return
              else
                pbMessage(_INTL("#{g}Hmm? Did you change your mind?"))
              end
            end
          end
        else
          pbMessage(_INTL("#{g}Hmm? You don't seem to have any Pokémon with you that are related to any known paradox species."))
          pbMessage(_INTL("#{g}Come back if you find any!"))
          return
        end
      else
        pbMessage(_INTL("#{g}Hmm? I'm gonna need another {1} if you want to engineer more Pokémon.", itemname))
        pbMessage(_INTL("#{g}Come back if you find any!"))
        return
      end
    else
      pbMessage(_INTL("#{g}No? Aw, okay..."))
    end
    pbMessage(_INTL("#{g}I'm always willing to do more research - come back again anytime!"))
  end
end


#-------------------------------------------------------------------------------
# Tracker for paradox engineering.
#-------------------------------------------------------------------------------
class PokemonGlobalMetadata
  attr_accessor :paradox_tracker
  
  alias paradox_initialize initialize
  def initialize
    @paradox_tracker = 0
    paradox_initialize
  end
end

EventHandlers.add(:on_player_step_taken, :paradox_tracker,
  proc {
    $PokemonGlobal.paradox_tracker = 0 if !$PokemonGlobal.paradox_tracker
    $PokemonGlobal.paradox_tracker += 1
  }
)


#===============================================================================
# Compiler
#===============================================================================
module Compiler
  PLUGIN_FILES += ["Legendary Breeding"]
end