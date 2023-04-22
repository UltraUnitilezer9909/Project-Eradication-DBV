#===============================================================================
# Adds debug options for Deluxe Plugins.
#===============================================================================

#-------------------------------------------------------------------------------
# General debug menus.
#-------------------------------------------------------------------------------
MenuHandlers.add(:debug_menu, :dx_menu, {
  "name"        => _INTL("Deluxe Plugins..."),
  "parent"      => :main,
  "description" => _INTL("Edit settings related to various plugins that utilize Essentials Deluxe.")
})


MenuHandlers.add(:debug_menu, :deluxe_menu, {
  "name"        => _INTL("Essentials Deluxe..."),
  "parent"      => :dx_menu,
  "description" => _INTL("Edit settings related to the Essentials Deluxe plugin.")
})


MenuHandlers.add(:debug_menu, :debug_mega, {
  "name"        => _INTL("Toggle Switch"),
  "parent"      => :deluxe_menu,
  "description" => _INTL("Toggles the availability of Mega Evolution functionality."),
  "effect"      => proc {
    $game_switches[Settings::NO_MEGA_EVOLUTION] = !$game_switches[Settings::NO_MEGA_EVOLUTION]
    toggle = ($game_switches[Settings::NO_MEGA_EVOLUTION]) ? "disabled" : "enabled"
    pbMessage(_INTL("Mega Evolution {1}.", toggle))
  }
})


MenuHandlers.add(:debug_menu, :debug_birthday, {
  "name"        => _INTL("Set Player's Birthday"),
  "parent"      => :deluxe_menu,
  "description" => _INTL("Sets the month and day of the player's birthday."),
  "effect"      => proc {
    pbSetPlayerBirthday
    day = $player.birthdate.day
    month = pbGetMonthName($player.birthdate.mon)
    pbMessage(_INTL("The player's birthdate was set to {1} {2}.", month, day))
  }
})


#-------------------------------------------------------------------------------
# Pokemon debug menus.
#-------------------------------------------------------------------------------
MenuHandlers.add(:pokemon_debug_menu, :dx_pokemon_menu, {
  "name"   => _INTL("Deluxe Options..."),
  "parent" => :main
})


MenuHandlers.add(:pokemon_debug_menu, :set_ace, {
  "name"   => _INTL("Toggle Ace"),
  "parent" => :dx_pokemon_menu,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    if pkmn.ace?
      pkmn.ace = false
      toggle = "unflagged"
    else
      pkmn.ace = true
      toggle = "flagged"
    end
    screen.pbDisplay(_INTL("{1} is {2} as an ace Pokémon.", pkmn.name, toggle))
    next false
  }
})


MenuHandlers.add(:pokemon_debug_menu, :set_scale, {
  "name"   => _INTL("Set Size"),
  "parent" => :dx_pokemon_menu,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(pkmn.scale)
    newval = pbMessageChooseNumber(
      _INTL("Scale the Pokémon's size (max. 255)."), params
    ) { screen.pbUpdate }
    if newval != pkmn.scale
      pkmn.scale = newval
      screen.pbRefreshSingle(pkmnid)
      case pkmn.scale
      when 255      then size = "XXXL"
      when 242..254 then size = "XXL"
      when 196..241 then size = "XL"
      when 161..195 then size = "Large"
      when 100..160 then size = "Medium"
      when 61..99   then size = "Small"
      when 31..60   then size = "XS"
      when 1..30    then size = "XXS"
      when 0        then size = "XXXS"
      end
      screen.pbDisplay(_INTL("{1} is now considered {2} in size.", pkmn.name, size))
    end
    next false
  }
})