#===============================================================================
# * Point Case
#===============================================================================

ItemHandlers::UseInField.add(:POINTCASE, proc { |item|
  pbMessage(_INTL("BP: {1}", $player.battle_points.to_s_formatted))
  next true
})