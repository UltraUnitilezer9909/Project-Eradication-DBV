#===============================================================================
# * Give BP
#===============================================================================

def pbReceiveBP(quantity = 1)
  meName = "Item get"
  return false if quantity < 1
  quantity *= BPConfig::BP_MULTIPLY if pbActiveCharm(:POINTSCHARM)
  $player.battle_points += quantity
  pbMessage(_INTL("\\me[{1}]You obtained {2} BP!", meName, quantity))
end