#===============================================================================
# Code for party menu skills.
#===============================================================================

#-------------------------------------------------------------------------------
# Healing Skill - Uses own HP to heal a party Pokemon's HP.
#-------------------------------------------------------------------------------
def pbHealPartySkill(pkmn, movename, screen, party, party_idx)
  amt = [(pkmn.totalhp / 5).floor, 1].max
  screen.scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
  old_party_idx = party_idx
  loop do
    screen.scene.pbPreSelect(old_party_idx)
    party_idx = screen.scene.pbChoosePokemon(true, party_idx)
    break if party_idx < 0
    newpkmn = party[party_idx]
    if party_idx == old_party_idx
      screen.scene.pbDisplay(_INTL("{1} can't use {2} on itself!", pkmn.name, movename))
    elsif newpkmn.egg?
      screen.scene.pbDisplay(_INTL("{1} can't be used on an Egg!", movename))
    elsif newpkmn.fainted? || newpkmn.hp == newpkmn.totalhp
      screen.scene.pbDisplay(_INTL("{1} can't be used on that Pokémon.", movename))
    else
      pkmn.hp -= amt
      hpgain = pbItemRestoreHP(newpkmn, amt)
      screen.scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.", newpkmn.name, hpgain))
      screen.scene.pbRefresh
    end
    break if pkmn.hp <= amt
  end
  screen.scene.pbSelect(old_party_idx)
  screen.scene.pbRefresh
end


#-------------------------------------------------------------------------------
# Recover Skill - Allows a Pokemon to recover its own HP.
#-------------------------------------------------------------------------------
def pbRecoverPartySkill(pkmn, movename, screen, party_idx)
  ret = 0
  if pkmn.hp == 0 || pkmn.hp == pkmn.totalhp
    screen.scene.pbDisplay(_INTL("It won't have any effect."))
  else
    amt = [(pkmn.totalhp / 4).floor, 1].max
    hpgain = pbItemRestoreHP(pkmn, amt)
    screen.scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.", pkmn.name, hpgain))
	ret = 1
  end
  screen.scene.pbSelect(party_idx)
  screen.scene.pbRefresh
  return ret
end


#-------------------------------------------------------------------------------
# Life Dew Skill - Allows a Pokemon to restore HP of the whole party at once.
#-------------------------------------------------------------------------------
def pbLifeDewPartySkill(pkmn, movename, screen, party, party_idx)
  ret = 0
  if pkmn.hp == 0
    screen.scene.pbDisplay(_INTL("It won't have any effect."))
  else
    party.each do |p|
      next if p.hp == 0 || p.hp == p.totalhp
      amt = [(p.totalhp / 4).floor, 1].max
      pbItemRestoreHP(p, amt)
      ret += 1
    end
    case ret
    when 0 then screen.scene.pbDisplay(_INTL("It won't have any effect."))
    else        screen.scene.pbDisplay(_INTL("{1} restored the party's HP!", pkmn.name))
    end
  end
  screen.scene.pbSelect(party_idx)
  screen.scene.pbRefresh
  return ret
end


#-------------------------------------------------------------------------------
# Status Skill - Allows a Pokemon to heal the status of the entire party at once.
#-------------------------------------------------------------------------------
def pbStatusPartySkill(pkmn, movename, screen, party, party_idx)
  ret = 0
  if pkmn.hp == 0
    screen.scene.pbDisplay(_INTL("It won't have any effect."))
  else
    party.each do |p|
      next if p.status == :NONE
      p.heal_status
      ret += 1
    end
    case ret
    when 0 then screen.scene.pbDisplay(_INTL("It won't have any effect."))
    else        screen.scene.pbDisplay(_INTL("{1} restored the party's condition!", pkmn.name))
    end
  end
  screen.scene.pbSelect(party_idx)
  screen.scene.pbRefresh
  return ret
end


#-------------------------------------------------------------------------------
# Instruct Skill - Allows a party Pokemon to relearn a move from the party menu.
#-------------------------------------------------------------------------------
def pbInstructPartySkill(pkmn, movename, screen, party, party_idx, idxMove)
  ret = 0
  screen.scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
  old_party_idx = party_idx
  loop do
    screen.scene.pbPreSelect(old_party_idx)
    party_idx = screen.scene.pbChoosePokemon(true, party_idx)
    break if party_idx < 0
    newpkmn = party[party_idx]
    if party_idx == old_party_idx
      screen.scene.pbDisplay(_INTL("{1} can't use {2} on itself!", pkmn.name, movename))
    elsif newpkmn.egg?
      screen.scene.pbDisplay(_INTL("{1} can't be used on an Egg!", movename))
    elsif !newpkmn.can_relearn_move?
      screen.scene.pbDisplay(_INTL("{1} has no moves to remember.", newpkmn.name))
    else
      ret += 1 if pbRelearnMoveScreen(newpkmn)
      screen.scene.pbRefresh
      if Settings::CUSTOM_SKILLS_REQUIRE_MOVE
        break if ret >= pkmn.moves[idxMove].pp
      end
    end
  end
  screen.scene.pbSelect(old_party_idx)
  screen.scene.pbRefresh
  return ret
end


#-------------------------------------------------------------------------------
# Sketch Skill - Sketches a party Pokemon's move from the party menu.
#-------------------------------------------------------------------------------
def pbSketchPartySkill(pkmn, movename, screen, party, party_idx)
  screen.scene.pbSetHelpText(_INTL("Sketch from which Pokémon?"))
  old_party_idx = party_idx
  loop do
    screen.scene.pbPreSelect(old_party_idx)
    party_idx = screen.scene.pbChoosePokemon(true, party_idx)
    break if party_idx < 0
    newpkmn = party[party_idx]
    if party_idx == old_party_idx
      screen.scene.pbDisplay(_INTL("{1} can't use {2} on itself!", pkmn.name, movename))
    elsif newpkmn.egg?
      screen.scene.pbDisplay(_INTL("{1} can't be used on an Egg!", movename))
    else
      newcommands = []
      newpkmn.moves.each do |move|
        newcommands.push(move.name)
      end
      newcommands.push("Cancel")
      newmove = screen.scene.pbShowCommands(_INTL("Sketch which of {1}'s moves?", newpkmn.name), newcommands)
      if newmove < (newcommands.length - 1) && newmove > -1
        newmove = newpkmn.moves[newmove]
        if pkmn.hasMove?(newmove.id)
            screen.scene.pbDisplay(_INTL("{1} already knows {2}.", pkmn.name, newmove.name))
        elsif newmove.type == :SHADOW
            screen.scene.pbDisplay(_INTL("{1} can't be sketched.", newmove.name))
        elsif screen.scene.pbConfirmMessage(_INTL("Sketch {1}?", newmove.name))
          for i in 0..pkmn.moves.length
            if pkmn.moves[i].id == :SKETCH
              pkmn.moves[i] = Pokemon::Move.new(newmove.id)
              screen.scene.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]", pkmn.name, newmove.name))
              break
            end
          end
          screen.scene.pbRefresh
          break
        else
          screen.scene.pbSetHelpText(_INTL("Sketch from which Pokémon?"))
        end
      else
        screen.scene.pbSetHelpText(_INTL("Sketch from which Pokémon?"))
      end
    end
  end
  screen.scene.pbSelect(old_party_idx)
  screen.scene.pbRefresh
  return 0
end


#-------------------------------------------------------------------------------
# Future Sight Skill - Views the species of an Egg, or the upcoming evolution/move of a party member.
#-------------------------------------------------------------------------------
def pbFutureSightPartySkill(pkmn, movename, screen, party, party_idx, idxMove)
  ret = 0
  screen.scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
  old_party_idx = party_idx
  loop do
    screen.scene.pbPreSelect(old_party_idx)
    party_idx = screen.scene.pbChoosePokemon(true, party_idx)
    break if party_idx < 0
    newpkmn = party[party_idx]
    if newpkmn.egg?
      #-------------------------------------------------------------------------
      # View Summary of Egg.
      #-------------------------------------------------------------------------
      annotations = [nil, nil, nil, nil, nil, nil]
      annotations[party_idx] = " "
      screen.scene.pbAnnotate(annotations)
      steps                  = newpkmn.steps_to_hatch
      newpkmn.name           = newpkmn.speciesName
      newpkmn.steps_to_hatch = 0
      newpkmn.hatched_map    = 0
      newpkmn.timeEggHatched = pbGetTimeNow
      screen.scene.pbDisplay(_INTL("{1} caught a glimpse of this Egg's future...", pkmn.name))
      ret += 1 if screen.scene.pbSummary(party_idx)
      newpkmn.steps_to_hatch = steps
      newpkmn.hatched_map    = nil
      newpkmn.timeEggHatched = nil
      newpkmn.name           = "Egg"
      screen.scene.pbRefresh
    else
      #-------------------------------------------------------------------------
      # Reveal evolution method of Pokemon.
      #-------------------------------------------------------------------------
      selpkmn = (pkmn == newpkmn) ? "its own" : "#{newpkmn.name}'s"
      screen.scene.pbDisplay(_INTL("{1} caught a glimpse of {2} future...", pkmn.name, selpkmn))
      evos = newpkmn.species_data.get_evolutions
      evos.each_with_index do |evo, i|
        case evo[1]
        when :None, :Shedinja then evos[i] = nil 
        when :Silcoon         then evos[i] = nil if (((pkmn.personalID >> 16) & 0xFFFF) % 10) >= 5
        when :Cascoon         then evos[i] = nil if (((pkmn.personalID >> 16) & 0xFFFF) % 10) < 5
        when :LevelMale, :HappinessMale, :HoldItemMale, :ItemMale, :TradeMale
          evos[i] = nil if !newpkmn.male?
        when :LevelFemale, :HappinessFemale, :HoldItemFemale, :ItemFemale, :TradeFemale		 
          evos[i] = nil if !newpkmn.female?
        end
      end
      evos.compact!
      evo_msg = pbGetEvolutionText(evos.sample)
      if evo_msg
        screen.scene.pbDisplay(_INTL("{1} {2}", newpkmn.name, evo_msg))
        ret += 1
      #-------------------------------------------------------------------------
      # Reveal next level-up move of Pokemon.
      #-------------------------------------------------------------------------
      elsif newpkmn.level < GameData::GrowthRate.max_level
        next_move = nil
        moveList = newpkmn.getMoveList
        moveList.each do |m|
          next if newpkmn.level > m[0]
          next if newpkmn.hasMove?(m[1])
          next_move = m
          break
        end
        if next_move
          next_move_name = GameData::Move.get(next_move[1]).name
          screen.scene.pbDisplay(_INTL("{1} may learn {2} at level {3}.", newpkmn.name, next_move_name, next_move[0]))
          ret += 1
        else
          screen.scene.pbDisplay(_INTL("{1}'s future is too vast to read.", newpkmn.name))
        end
      #-------------------------------------------------------------------------
      else
        screen.scene.pbDisplay(_INTL("{1}'s future is too vast to read.", newpkmn.name))
      end
    end
    if Settings::CUSTOM_SKILLS_REQUIRE_MOVE
      break if ret >= pkmn.moves[idxMove].pp
    end
  end
  screen.scene.pbSelect(old_party_idx)
  screen.scene.pbRefresh
  return ret
end


def pbGetEvolutionText(evo)
  return if !evo || evo.empty?
  method, param = evo[1], evo[2]
  if param && param.is_a?(Symbol)
    case method
    when :HasMove, :HappinessMove             then name = GameData::Move.get(param).name
	when :LevelUseMoveCount                   then name = GameData::Move.get(param).name
    when :HasMoveType, :HappinessMoveType     then name = GameData::Type.get(param).name
    when :HasInParty, :TradeSpecies           then name = GameData::Species.get(param).name
    else                                           name = GameData::Item.get(param).name
    end
    article = (param == :LEFTOVERS) ? "some" : (name.starts_with_vowel?) ? "an" : "a"
  end
  evo_data = GameData::Evolution.get(method)
  if evo_data.event_proc                      then text = "may evolve when something special happens"
  elsif evo_data.after_battle_proc            then text = "may evolve after concluding a battle"
  elsif evo_data.on_trade_proc                then text = "may evolve upon being traded"
  elsif evo_data.use_item_proc                then text = "may evolve when exposed to #{article} #{name}"
  elsif evo_data.level_up_proc
    if evo_data.minimum_level == 1            then text = "may evolve upon leveling up"
    else                                           text = "may evolve upon reaching level #{param} or higher"
    end
  else return
  end
  case method
  when :LevelDay, :ItemDay, :TradeDay         then text += " during the day."
  when :LevelNight, :ItemNight, :TradeNight   then text += " at nighttime."
  when :LevelMorning                          then text += " in the morning."
  when :LevelAfternoon                        then text += " in the afternoon."
  when :LevelEvening                          then text += " during the evening."
  when :LevelNoWeather                        then text += " while the weather is clear."
  when :LevelSun                              then text += " while the sunlight is harsh."
  when :LevelRain                             then text += " while its raining."
  when :LevelSnow                             then text += " during a hailstorm."
  when :LevelSandstorm                        then text += " during a sandstorm."
  when :LevelCycling                          then text += " while traveling by bicycle."
  when :LevelSurfing                          then text += " while traveling over water."
  when :LevelDiving                           then text += " while traveling underwater."
  when :LevelDarkness                         then text += " while traveling in darkness."
  when :LevelDarkInParty                      then text += " while there's a Dark-type influence in the party."
  when :AttackGreater                         then text += " while its Attack stat is higher than its Defense."
  when :DefenseGreater                        then text += " while its Defense stat is higher than its Attack."
  when :AtkDefEqual                           then text += " while its Attack and Defense stats are equal."
  when :Ninjask                               then text += "...huh?\nIt looks like another Pokémon may emerge after it evolves..." 
  when :Location, :LocationFlag               then text += " while in a certain location."
  when :Region                                then text += " while in the #{pbGetMessage(MessageTypes::RegionNames, param)} region."
  when :HasMove                               then text += " while it knows the move #{name}."
  when :HasMoveType                           then text += " while it knows #{article} #{name}-type move."
  when :HasInParty                            then text += " while #{article} #{name} is in the party."
  when :TradeSpecies                          then text += " for #{article} #{name}."
  when :DayHoldItem                           then text += " while holding #{article} #{name} during the day."
  when :NightHoldItem                         then text += " while holding #{article} #{name} at night."
  when :MaxHappiness                          then text += " while having total trust in its trainer."
  when :HappinessDay                          then text += " while feeling happy during daytime hours."
  when :HappinessNight                        then text += " while feeling happy during nighttime hours."
  when :HappinessMove                         then text += " while feeling happy and it knows the move #{name}."
  when :HappinessMoveType                     then text += " while feeling happy and it knows #{article} #{name}-type move."
  when :HappinessHoldItem, :HoldItemHappiness then text += " while feeling happy and holding #{article} #{name}."
  when :Beauty                                then text += " while its feeling beautiful."
  when :BattleDealCriticalHit                 then text += " where it landed at least #{param} critical hits."
  when :EventAfterDamageTaken                 then text += " after it took a certain amount of damage in battle."
  when :HoldItem, :TradeItem, 
       :HoldItemMale, :HoldItemFemale         then text += " while holding #{article} #{name}."
  when :Happiness, :ItemHappiness, 
       :HappinessMale, :HappinessFemale       then text += " while having great affection for its trainer."
  #-----------------------------------------------------------------------------
  # PLA & SV Evolution methods
  #-----------------------------------------------------------------------------
  when :LevelWithPartner                      then text += " while you are partnered up with another trainer."
  when :LevelUseMoveCount                     then text += " after it has used the move #{name} 20 times."
  when :Walk                                  then text += " after walking #{param} steps with it in the lead slot."
  when :CollectItems                          then text += " after 999 #{name}s have been collected."
  when :LevelDefeatItsKindWithItem            then text += " after it has defeated 3 of its own species that held #{article} #{name}."
  when :LevelRecoilDamage                     then text += " after a certain amount of recoil damage has been taken while battling."
  #-----------------------------------------------------------------------------
  else                                             text += "."
  end
  return text
end