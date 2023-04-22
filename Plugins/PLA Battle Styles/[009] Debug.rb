#===============================================================================
# Adds Battle Style-related tools to debug options.
#===============================================================================

#-------------------------------------------------------------------------------
# General Debug options
#-------------------------------------------------------------------------------
MenuHandlers.add(:debug_menu, :pla_menu, {
  "name"        => _INTL("PLA Battle Styles..."),
  "parent"      => :dx_menu,
  "description" => _INTL("Edit settings related to the PLA Battle Styles plugin.")
})


MenuHandlers.add(:debug_menu, :debug_pla, {
  "name"        => _INTL("Toggle Switch"),
  "parent"      => :pla_menu,
  "description" => _INTL("Toggles the availability of Battle Style functionality."),
  "effect"      => proc {
    $game_switches[Settings::NO_STYLE_MOVES] = !$game_switches[Settings::NO_STYLE_MOVES]
	toggle = ($game_switches[Settings::NO_STYLE_MOVES]) ? "disabled" : "enabled"
	pbMessage(_INTL("Battle Styles are {1}.", toggle))
  }
})


#-------------------------------------------------------------------------------
# Pokemon Debug options
#-------------------------------------------------------------------------------
MenuHandlers.add(:pokemon_debug_menu, :master_moves, {
  "name"   => _INTL("Move Mastery"),
  "parent" => :dx_pokemon_menu,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    pkmn.master_moveset
    screen.pbDisplay(_INTL("{1}'s eligible moves were mastered.", pkmn.name))
    screen.pbRefreshSingle(pkmnid)
    next false
  }
})