#===============================================================================
# Debug menus.
#===============================================================================

#-------------------------------------------------------------------------------
# General Debug options
#-------------------------------------------------------------------------------
MenuHandlers.add(:debug_menu, :tera_menu, {
  "name"        => _INTL("Terastal Phenomenon..."),
  "parent"      => :dx_menu,
  "description" => _INTL("Edit settings related to the Terastal Phenomenon plugin.")
})


MenuHandlers.add(:debug_menu, :debug_tera, {
  "name"        => _INTL("Toggle Switch"),
  "parent"      => :tera_menu,
  "description" => _INTL("Toggles the availability of Terastallization functionality."),
  "effect"      => proc {
    $game_switches[Settings::NO_TERASTALLIZE] = !$game_switches[Settings::NO_TERASTALLIZE]
    toggle = ($game_switches[Settings::NO_TERASTALLIZE]) ? "disabled" : "enabled"
    pbMessage(_INTL("Terastallization {1}.", toggle))
  }
})


MenuHandlers.add(:debug_menu, :debug_tera_orb, {
  "name"        => _INTL("Toggle Tera Charge"),
  "parent"      => :tera_menu,
  "description" => _INTL("Toggles the charge of the player's Tera Orb."),
  "effect"      => proc {
    $player.tera_charged = !$player.tera_charged
    toggle = ($player.tera_charged?) ? "charged" : "uncharged"
    pbMessage(_INTL("Tera Orb is now {1}.", toggle))
  }
})


#-------------------------------------------------------------------------------
# Pokemon Debug options.
#-------------------------------------------------------------------------------
MenuHandlers.add(:pokemon_debug_menu, :set_tera_type, {
  "name"   => _INTL("Tera Type"),
  "parent" => :dx_pokemon_menu,
  "effect" => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    default = GameData::Type.get(pkmn.tera_type).icon_position
    newType = pbChooseTypeList(default < 10 ? default + 1 : default)
    if newType && newType != pkmn.tera_type
      pkmn.tera_type = newType
      screen.pbDisplay(_INTL("{1}'s Tera Type is now {2}.", pkmn.name, GameData::Type.get(newType).name))
      screen.pbRefreshSingle(pkmnid)
    end
    next false
  }
})


#-------------------------------------------------------------------------------
# Battle Debug options.
#-------------------------------------------------------------------------------
MenuHandlers.add(:battle_debug_menu, :terastallize, {
  "name"        => _INTL("Terastallization"),
  "parent"      => :trainers,
  "description" => _INTL("Whether each trainer is allowed to Terastallize."),
  "effect"      => proc { |battle|
    cmd = 0
    loop do
      commands = []
      cmds = []
      battle.terastallize.each_with_index do |side_values, side|
        trainers = (side == 0) ? battle.player : battle.opponent
        next if !trainers
        side_values.each_with_index do |value, i|
          next if !trainers[i]
          text = (side == 0) ? "Your side:" : "Foe side:"
          text += sprintf(" %d: %s", i, trainers[i].name)
          text += sprintf(" [ABLE]") if value == -1
          text += sprintf(" [UNABLE]") if value == -2
          commands.push(text)
          cmds.push([side, i])
        end
      end
      cmd = pbMessage("\\ts[]" + _INTL("Choose trainer to toggle whether they can Terastallize."),
                      commands, -1, nil, cmd)
      break if cmd < 0
      real_cmd = cmds[cmd]
      if battle.terastallize[real_cmd[0]][real_cmd[1]] == -1
        battle.terastallize[real_cmd[0]][real_cmd[1]] = -2   # Make unable
      else
        battle.terastallize[real_cmd[0]][real_cmd[1]] = -1   # Make able
      end
    end
  }
})


#-------------------------------------------------------------------------------
# Adds Tera Types to trainers.
#-------------------------------------------------------------------------------
module GameData
  class Trainer
    SCHEMA["TeraType"] = [:teratype, "e", :Type]
  end
end


#-------------------------------------------------------------------------------
# Essentials Deluxe integration.
#-------------------------------------------------------------------------------
module Compiler
  PLUGIN_FILES += ["Terastal Phenomenon"]
end