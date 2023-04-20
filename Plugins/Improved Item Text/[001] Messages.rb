#-------------------------------------------------------------------------------
# Overworld item messages.
#-------------------------------------------------------------------------------
def pbItemBall(item, quantity = 1)
  item = GameData::Item.get(item)
  return false if !item || quantity < 1
  itemname = (quantity > 1) ? item.portion_name_plural : item.portion_name
  if PluginManager.installed?("ZUD Mechanics") && item.is_z_crystal?
    itemname = (quantity > 1) ? item.name_plural : item.name
  end
  pocket = item.pocket
  move = item.move
  if item == :DNASPLICERS
    msg = _INTL("You found \\c[1]{1}\\c[0]!\\wtnp[30]", itemname)
  elsif item.is_machine?
    msg = _INTL("You found \\c[1]{1} {2}\\c[0]!\\wtnp[30]", itemname, GameData::Move.get(move).name)
  elsif quantity > 1
    msg = _INTL("You found {1} \\c[1]{2}\\c[0]!\\wtnp[30]", quantity, itemname)
  elsif itemname.starts_with_vowel?
    msg = _INTL("You found an \\c[1]{1}\\c[0]!\\wtnp[30]", itemname)
  else
    msg = _INTL("You found a \\c[1]{1}\\c[0]!\\wtnp[30]", itemname)
  end
  if $bag.add(item, quantity)
    meName = (item.is_key_item?) ? "\\me[Key item get]" : "\\me[Item get]"
    pbMessage(meName + msg)
    pbMessage(_INTL("You put the {1} in\\nyour Bag's <icon=bagPocket{2}>\\c[1]{3}\\c[0] pocket.",
                    itemname, pocket, PokemonBag.pocket_names[pocket - 1]))
    return true
  end
  pbMessage(msg)
  pbMessage(_INTL("But your Bag is full..."))
  return false
end


def pbReceiveItem(item, quantity = 1)
  item = GameData::Item.get(item)
  return false if !item || quantity < 1
  itemname = (quantity > 1) ? item.portion_name_plural : item.portion_name
  if PluginManager.installed?("ZUD Mechanics") && item.is_z_crystal?
    itemname = (quantity > 1) ? item.name_plural : item.name
  end
  pocket = item.pocket
  move = item.move
  meName = (item.is_key_item?) ? "Key item get" : "Item get"
  if item == :DNASPLICERS
    pbMessage(_INTL("\\me[{1}]You obtained \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
  elsif item.is_machine?
    pbMessage(_INTL("\\me[{1}]You obtained \\c[1]{2} {3}\\c[0]!\\wtnp[30]", meName, itemname, GameData::Move.get(move).name))
  elsif quantity > 1
    pbMessage(_INTL("\\me[{1}]You obtained {2} \\c[1]{3}\\c[0]!\\wtnp[30]", meName, quantity, itemname))
  elsif itemname.starts_with_vowel?
    pbMessage(_INTL("\\me[{1}]You obtained an \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
  else
    pbMessage(_INTL("\\me[{1}]You obtained a \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
  end
  if $bag.add(item, quantity)
    pbMessage(_INTL("You put the {1} in\\nyour Bag's <icon=bagPocket{2}>\\c[1]{3}\\c[0] pocket.",
                    itemname, pocket, PokemonBag.pocket_names[pocket - 1]))
    return true
  end
  return false
end


def pbBuyPrize(item, quantity = 1)
  item = GameData::Item.get(item)
  return false if !item || quantity < 1
  item_name = (quantity > 1) ? item.portion_name_plural : item.portion_name
  if PluginManager.installed?("ZUD Mechanics") && item.is_z_crystal?
    item_name = (quantity > 1) ? item.name_plural : item.name
  end
  pocket = item.pocket
  return false if !$bag.add(item, quantity)
  pbMessage(_INTL("\\CNYou put the {1} in\\nyour Bag's <icon=bagPocket{2}>\\c[1]{3}\\c[0] pocket.",
                  item_name, pocket, PokemonBag.pocket_names[pocket - 1]))
  return true
end


def pbPickBerry(berry, qty = 1)
  berry = GameData::Item.get(berry)
  berry_name = (qty > 1) ? berry.portion_name_plural : berry.portion_name
  if qty > 1
    message = _INTL("There are {1} \\c[1]{2}\\c[0]!\nWant to pick them?", qty, berry_name)
  else
    message = _INTL("There is 1 \\c[1]{1}\\c[0]!\nWant to pick it?", berry_name)
  end
  return false if !pbConfirmMessage(message)
  if !$bag.can_add?(berry, qty)
    pbMessage(_INTL("Too bad...\nThe Bag is full..."))
    return false
  end
  $stats.berry_plants_picked += 1
  if qty >= GameData::BerryPlant.get(berry.id).maximum_yield
    $stats.max_yield_berry_plants += 1
  end
  $bag.add(berry, qty)
  if qty > 1
    pbMessage(_INTL("\\me[Berry get]You picked the {1} \\c[1]{2}\\c[0].\\wtnp[30]", qty, berry_name))
  else
    pbMessage(_INTL("\\me[Berry get]You picked the \\c[1]{1}\\c[0].\\wtnp[30]", berry_name))
  end
  pocket = berry.pocket
  pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0] in the <icon=bagPocket{3}>\\c[1]{4}\\c[0] Pocket.\1",
                  $player.name, berry_name, pocket, PokemonBag.pocket_names[pocket - 1]))
  if Settings::NEW_BERRY_PLANTS
    pbMessage(_INTL("The soil returned to its soft and earthy state."))
  else
    pbMessage(_INTL("The soil returned to its soft and loamy state."))
  end
  this_event = pbMapInterpreter.get_self
  pbSetSelfSwitch(this_event.id, "A", true)
  return true
end


#-------------------------------------------------------------------------------
# Usage messages.
#-------------------------------------------------------------------------------
def pbUseItem(bag, item, bagscene = nil)
  itm = GameData::Item.get(item)
  useType = itm.field_use
  if useType == 1
    if $player.pokemon_count == 0
      pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    ret = false
    annot = nil
    if itm.is_evolution_stone?
      annot = []
      $player.party.each do |pkmn|
        elig = pkmn.check_evolution_on_use_item(item)
        annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
      end
    end
    pbFadeOutIn {
      scene = PokemonParty_Scene.new
      screen = PokemonPartyScreen.new(scene, $player.party)
      screen.pbStartScene(_INTL("Use on which Pokémon?"), false, annot)
      loop do
        scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
        chosen = screen.pbChoosePokemon
        if chosen < 0
          ret = false
          break
        end
        pkmn = $player.party[chosen]
        next if !pbCheckUseOnPokemon(item, pkmn, screen)
        qty = 1
        max_at_once = ItemHandlers.triggerUseOnPokemonMaximum(item, pkmn)
        max_at_once = [max_at_once, $bag.quantity(item)].min
        if max_at_once > 1
          qty = screen.scene.pbChooseNumber(
            _INTL("How many {1} do you want to use?", GameData::Item.get(item).portion_name_plural), max_at_once
          )
          screen.scene.pbSetHelpText("") if screen.is_a?(PokemonPartyScreen)
        end
        next if qty <= 0
        ret = ItemHandlers.triggerUseOnPokemon(item, qty, pkmn, screen)
        next unless ret && itm.consumed_after_use?
        bag.remove(item, qty)
        next if bag.has?(item)
        pbMessage(_INTL("You used your last {1}.", itm.portion_name)) { screen.pbUpdate }
        break
      end
      screen.pbEndScene
      bagscene&.pbRefresh
    }
    return (ret) ? 1 : 0
  elsif useType == 2 || itm.is_machine?
    intret = ItemHandlers.triggerUseFromBag(item)
    if intret >= 0
      bag.remove(item) if intret == 1 && itm.consumed_after_use?
      return intret
    end
    pbMessage(_INTL("Can't use that here."))
    return 0
  end
  pbMessage(_INTL("Can't use that here."))
  return 0
end


def pbUseItemOnPokemon(item, pkmn, scene)
  itm = GameData::Item.get(item)
  if itm.is_machine?
    machine = itm.move
    return false if !machine
    movename = GameData::Move.get(machine).name
    if pkmn.shadowPokemon?
      pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { scene.pbUpdate }
    elsif !pkmn.compatible_with_move?(machine)
      pbMessage(_INTL("{1} can't learn {2}.", pkmn.name, movename)) { scene.pbUpdate }
    else
      pbMessage(_INTL("\\se[PC access]You booted up {1}.\1", itm.portion_name)) { scene.pbUpdate }
      if pbConfirmMessage(_INTL("Do you want to teach {1} to {2}?", movename, pkmn.name)) { scene.pbUpdate }
        if pbLearnMove(pkmn, machine, false, true) { scene.pbUpdate }
          $bag.remove(item) if itm.consumed_after_use?
          return true
        end
      end
    end
    return false
  end
  qty = 1
  max_at_once = ItemHandlers.triggerUseOnPokemonMaximum(item, pkmn)
  max_at_once = [max_at_once, $bag.quantity(item)].min
  if max_at_once > 1
    qty = scene.scene.pbChooseNumber(
      _INTL("How many {1} do you want to use?", itm.portion_name_plural), max_at_once
    )
    scene.scene.pbSetHelpText("") if scene.is_a?(PokemonPartyScreen)
  end
  return false if qty <= 0
  ret = ItemHandlers.triggerUseOnPokemon(item, qty, pkmn, scene)
  scene.pbClearAnnotations
  scene.pbHardRefresh
  if ret && itm.consumed_after_use?
    $bag.remove(item, qty)
    if !$bag.has?(item)
      pbMessage(_INTL("You used your last {1}.", itm.portion_name)) { scene.pbUpdate }
    end
  end
  return ret
end


def pbUseItemMessage(item)
  item = GameData::Item.get(item)
  itemName = item.portion_name
  itemname = item.name if PluginManager.installed?("ZUD Mechanics") && item.is_z_crystal?
  if itemname.starts_with_vowel?
    pbMessage(_INTL("You used an {1}.", itemname))
  else
    pbMessage(_INTL("You used a {1}.", itemname))
  end
end


#-------------------------------------------------------------------------------
# Mystery Gift messages.
#-------------------------------------------------------------------------------
def pbReceiveMysteryGift(id)
  index = -1
  $player.mystery_gifts.length.times do |i|
    if $player.mystery_gifts[i][0] == id && $player.mystery_gifts[i].length > 1
      index = i
      break
    end
  end
  if index == -1
    pbMessage(_INTL("Couldn't find an unclaimed Mystery Gift with ID {1}.", id))
    return false
  end
  gift = $player.mystery_gifts[index]
  if gift[1] == 0
    gift[2].personalID = rand(2**16) | (rand(2**16) << 16)
    gift[2].calc_stats
    time = pbGetTimeNow
    gift[2].timeReceived = time.getgm.to_i
    gift[2].obtain_method = 4
    gift[2].record_first_moves
    gift[2].obtain_level = gift[2].level
    gift[2].obtain_map = $game_map&.map_id || 0
    was_owned = $player.owned?(gift[2].species)
    if pbAddPokemonSilent(gift[2])
      pbMessage(_INTL("\\me[Pkmn get]{1} received {2}!", $player.name, gift[2].name))
      $player.mystery_gifts[index] = [id]
      if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && !was_owned && $player.has_pokedex
        pbMessage(_INTL("{1}'s data was added to the Pokédex.", gift[2].name))
        $player.pokedex.register_last_seen(gift[2])
        pbFadeOutIn {
          scene = PokemonPokedexInfo_Scene.new
          screen = PokemonPokedexInfoScreen.new(scene)
          screen.pbDexEntry(gift[2].species)
        }
      end
      return true
    end
  elsif gift[1] > 0
    item = gift[2]
    qty = gift[1]
    if $bag.can_add?(item, qty)
      $bag.add(item, qty)
      itm = GameData::Item.get(item)
      itemname = (qty > 1) ? itm.portion_name_plural : itm.portion_name
      if PluginManager.installed?("ZUD Mechanics") && itm.is_z_crystal?
        itemname = (qty > 1) ? itm.name_plural : itm.name
      end
      if itm.is_machine?
        pbMessage(_INTL("\\me[Item get]You obtained \\c[1]{1} {2}\\c[0]!\\wtnp[30]", itemname,
                        GameData::Move.get(itm.move).name))
      elsif qty > 1
        pbMessage(_INTL("\\me[Item get]You obtained {1} \\c[1]{2}\\c[0]!\\wtnp[30]", qty, itemname))
      elsif itemname.starts_with_vowel?
        pbMessage(_INTL("\\me[Item get]You obtained an \\c[1]{1}\\c[0]!\\wtnp[30]", itemname))
      else
        pbMessage(_INTL("\\me[Item get]You obtained a \\c[1]{1}\\c[0]!\\wtnp[30]", itemname))
      end
      $player.mystery_gifts[index] = [id]
      return true
    end
  end
  return false
end


#-------------------------------------------------------------------------------
# Battle messages.
#-------------------------------------------------------------------------------
class Battle
  def pbUseItemMessage(item, trainerName)
    item = GameData::Item.get(item)
    itemName = item.portion_name
    itemname = item.name if PluginManager.installed?("ZUD Mechanics") && item.is_z_crystal?
    if itemName.starts_with_vowel?
      pbDisplayBrief(_INTL("{1} used an {2}.", trainerName, itemName))
    else
      pbDisplayBrief(_INTL("{1} used a {2}.", trainerName, itemName))
    end
  end
end