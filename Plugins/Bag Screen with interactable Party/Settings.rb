#===============================================================================
# Bag Screen with interactable Party: Settings
#===============================================================================
module BagScreenWiInParty
# If you want your Bag Screen to have a scrolling panorama (true or false):
  PANORAMA = true
 
# Interface background color:
 # 0 for only orange (newer gens style);
 # 1 for a color matching the player's character gender (BW style);
 # 2 for a different color for each pocket (HGSS style).
  BGSTYLE = 0
  # The page of each pocket of the Bag.
  def self.bag_pocket_num
    return [
      _INTL("[1/9]"),
      _INTL("[2/9]"),
      _INTL("[3/9]"),
      _INTL("[4/9]"),
      _INTL("[5/9]"),
      _INTL("[6/9]"),
      _INTL("[7/9]"),
      _INTL("[8/9]"),
      _INTL("[9/9]")
    ]
  end
end
