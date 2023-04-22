#===============================================================================
# Settings.
#===============================================================================
module Settings
  #-----------------------------------------------------------------------------
  # Battle UI
  #-----------------------------------------------------------------------------
  # Whether or not the Style Info UI should be visible by default when toggling 
  # styles in battle. This info is toggled on/off with the SPECIAL key.
  #-----------------------------------------------------------------------------
  SHOW_STYLE_INFO_DEFAULT = true
  
  #-----------------------------------------------------------------------------
  # Style Settings
  #-----------------------------------------------------------------------------
  # The number of turns a battler remains in a selected style before wearing off.
  # (Default = 2)
  #-----------------------------------------------------------------------------
  STYLE_TURNS = 2
  
  #-----------------------------------------------------------------------------
  # The number of cooldown turns before Battle Styles can be selected again.
  # (Default = 3)
  #-----------------------------------------------------------------------------
  STYLE_COOLDOWN = 3
  
  #-----------------------------------------------------------------------------
  # Move Mastery
  #-----------------------------------------------------------------------------
  # When true, Seeds of Mastery will fail to work on level-up moves, like in PLA.
  # When false, Seeds of Mastery will work on any move, including level-up moves.
  #-----------------------------------------------------------------------------
  PLA_MOVE_MASTERY = true
  
  #-----------------------------------------------------------------------------
  # Controls the likelihood of random wild Pokemon spawning with a mastered move
  # in its moveset, allowing it to use battle styles in combat. Set this to a
  # number between 0-100 to control the percent chance of this happening.
  #-----------------------------------------------------------------------------
  WILD_MASTERY_CHANCE = 10
end