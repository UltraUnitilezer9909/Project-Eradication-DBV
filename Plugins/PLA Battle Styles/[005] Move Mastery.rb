#===============================================================================
# Seed of Mastery - Masters one of a Pokemon's selected moves.
# May not be used to master level-up moves if PLA_MOVE_MASTERY is true.
#===============================================================================
ItemHandlers::UseOnPokemon.add(:SEEDOFMASTERY, proc { |item, qty, pkmn, scene|
  move = scene.pbChooseMove(pkmn, _INTL("Master which move?"))
  if move >= 0
    sel_move = pkmn.moves[move]
    if sel_move.mastered?
      scene.pbDisplay(_INTL("{1} has already been mastered.", sel_move.name))
      next false
    elsif !sel_move.canMaster? || $game_switches[Settings::NO_STYLE_MOVES]
      scene.pbDisplay(_INTL("{1} isn't capable of being mastered.", sel_move.name))
      next false
    elsif Settings::PLA_MOVE_MASTERY && pkmn.level < GameData::GrowthRate.max_level 
      level_up_move = false
      pkmn.getMoveList.each do |move|
        if move[1] == sel_move.id
          scene.pbDisplay(_INTL("{1} may only master {2} through level-up.", pkmn.name, sel_move.name))
          level_up_move = true
          break
        end
      end
      next false if level_up_move
    end
    $stats.total_moves_mastered += 1
    pkmn.master_move(move)
    pbSEPlay("Pkmn move learnt")
    scene.pbDisplay(_INTL("{1} mastered {2}!", pkmn.name, sel_move.name))
    next true
  end
  next false
})


#===============================================================================
# Allows for taught moves to be automatically mastered if previously mastered.
#===============================================================================
alias styles_pbLearnMove pbLearnMove
def pbLearnMove(*args)
  ret = styles_pbLearnMove(*args)
  args[0].refresh_mastery if ret
  return ret
end


#===============================================================================
# Allows for move mastery through level-up.
#===============================================================================
def pbMasterMoves(pkmn, battler, scene)
  return if $game_switches[Settings::NO_STYLE_MOVES]
  moveList = pkmn.getMoveList
  moveList.each do |m|
    pkmn.moves.each do |move|
      next if move.id != m[1]
      next if move.mastered? || !move.canMaster?
      min_lvl = (m[0] >= 35) ? 11 : (m[0] >= 25) ? 10 : 9
      if pkmn.level >= [m[0] + min_lvl, Settings::MAXIMUM_LEVEL].min
        $stats.total_moves_mastered += 1
        pkmn.master_move(move.id)
        scene.pbDisplay(_INTL("{1} mastered {2}!", pkmn.name, move.name)) { pbSEPlay("Pkmn move learnt") }
        break
      end
    end
  end
  if battler.is_a?(Battle::Battler) && !battler.effects[PBEffects::Transform]
    battler.moves.each_with_index do |m, i|
	  next if battler.moves[i].id != pkmn.moves[i].id
	  m.mastered = pkmn.moves[i].mastered?
    end	  
  end
end

#-------------------------------------------------------------------------------
# Used for Rare Candy level-up.
#-------------------------------------------------------------------------------
alias styles_pbChangeLevel pbChangeLevel
def pbChangeLevel(pkmn, new_level, scene)
  new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
  master_moves = pkmn.level < new_level || pkmn.level == Settings::MAXIMUM_LEVEL
  styles_pbChangeLevel(pkmn, new_level, scene)
  pbMasterMoves(pkmn, nil, scene) if master_moves
end

#-------------------------------------------------------------------------------
# Used for Exp. Candy level-up.
#-------------------------------------------------------------------------------
alias styles_pbChangeExp pbChangeExp
def pbChangeExp(pkmn, new_exp, scene)
  old_lvl = pkmn.level
  styles_pbChangeExp(pkmn, new_exp, scene)
  pbMasterMoves(pkmn, nil, scene) if pkmn.level > old_lvl
end

#-------------------------------------------------------------------------------
# Used for in-battle level-up.
#-------------------------------------------------------------------------------
class Battle::Scene
  alias styles_pbLevelUp pbLevelUp
  def pbLevelUp(*args)
    styles_pbLevelUp(*args)
    pbMasterMoves(args[0], args[1], self)
  end
end


#===============================================================================
# Allows for the possibility of random wild Pokemon spawning with a mastered move.
# The odds of this happening are set with WILD_MASTERY_CHANCE.
#===============================================================================
EventHandlers.add(:on_wild_pokemon_created, :wild_mastery,
  proc { |pkmn|
    next if $game_switches[Settings::NO_STYLE_MOVES]
    i = rand(pkmn.moves.length)
    pkmn.master_move(i) if rand(100) < Settings::WILD_MASTERY_CHANCE
  }
)


#===============================================================================
# Compiles a text file of master-able moves.
#===============================================================================
module Compiler
  module_function
  
  PLUGIN_FILES += ["PLA Battle Styles"]
  
  def write_mastery(removal = false, path = "PBS/Plugins/PLA Battle Styles/moves.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      idx = 0
      GameData::Move.each do |m|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        next if !m.has_flag?("CantMaster")
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s]\r\n", m.id))
        f.write(sprintf("EditOnly =\r\n"))
        if removal
          f.write(sprintf("Flags = Remove_CantMaster\r\n"))
        else
          f.write(sprintf("Flags = CantMaster\r\n"))
        end
      end
    }
    process_pbs_file_message_end
  end
end