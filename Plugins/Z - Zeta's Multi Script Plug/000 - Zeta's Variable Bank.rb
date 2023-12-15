# SysFixData is going to be the "Global Variable Storage", you know, where ever fix number is stored?
module SysFixData
  # === # Colors # === #
  $zColorsRGB = [
    # Dark: Color.new(*SysFixData::zColors[X * 2])
    # Light: Color.new(*SysFixData::zColors[X * 2 + 1])
    # Dark / Light format
    [99, 99, 99],[154, 154, 154], # Grey
    [97, 97, 174], [188, 188, 255], # Cresent
    [48, 30, 19], [128, 84, 57], # Bronze
    [0, 175, 9], [15, 255, 28], # Lime
    [0, 108, 175], [15, 162, 255], # Cyan 
    [175, 126, 0], [255, 188, 15], # Ember
    [0, 175, 155], [15, 255, 228], # Teal
    [183, 95, 255], [212, 157, 255], # Lavender
    [175, 9, 0], [255, 28, 15], # Crimson
    [175, 68, 0], [255, 108, 15], # Orange
    [99, 0, 180], [148, 15, 255], # Shadow
    [194, 0, 219], [228, 15, 255], # Magenta
    [200,200,208], [240,240, 248], # White
    [48, 30, 19], [128, 84, 57], # Wood
    [95, 193, 255], [157, 217, 255], # Candy Blue
    [255, 95, 140], [255, 157, 184], # Candy Pink
    [95, 255, 176], [157, 255, 206], # Candy Teal
    [183, 95, 255], [212, 157, 255] # Candy Magenta
  ].freeze
  $ColorsHEX = [
    "636363", "9A9A9A", # Grey
    "6161AE", "BCBCFF", # Cresent
    "301E13", "805439", # Bronze
    "00AF09", "0FFF1C", # Lime
    "006CAF", "0FA2FF", # Cyan
    "AF7E00", "FFBC0F", # Ember
    "00AF9B", "0FFFE4", # Teal
    "B75FFF", "D49DFF", # Lavender
    "AF0900", "FF1C0F", # Crimson
    "AF4400", "FF6C0F", # Orange
    "6300B4", "940FFF", # Shadow
    "C200DB", "E415FF", # Magenta
    "C8C8D0", "F0F0F8", # White
    "301E13", "805439", # Wood
    "5FC1FF", "9DD9FF", # Candy Blue
    "FF5F8C", "FF9DB8", # Candy Pink
    "5FFFB0", "9DFFCE", # Candy Teal
    "B75FFF", "D49DFF"  # Candy Magenta
  ].freeze
  # === === === === === #

  # SysFixData.difficulties = 0~3
  # === # Ranks # === #
  # win = +10
  # lose = -12
  # Earn  XP: SysFixData.earn_xp(X)
  # Rank up: SysFixData.rank_change(true) [Each call is 1 rank up]
  # Rank down:  SysFixData.rank_change(false) [Each call is 1 rank down]
  basePoints = 100
  Rxp = [
    basePoints, # Unranked
    basePoints * 1.5, basePoints * 2, basePoints * 2.5, # Runevox
    basePoints * 3.0, basePoints * 3.5, basePoints * 4, # Emberlynx
    basePoints * 4.5, basePoints * 5, basePoints * 5.5, # Astridian
    basePoints * 6.0, basePoints * 6.5, basePoints * 7, # Zephyra
    basePoints * 7.5, basePoints * 8, basePoints * 8.5, # Celestara
    basePoints * 9.0, basePoints * 9.5, basePoints * 10, # Vortexium
    basePoints * 10.5, basePoints * 11, basePoints * 11.5, # Lumithra
    basePoints * 12.0, basePoints * 12.5, basePoints * 13, # Netherion
    basePoints * 13.5, basePoints * 14, basePoints * 14.5, basePoints * 15, basePoints * 15.5, # Solarianth
    basePoints * 16, # Aetherionyx or higher
  ]
  Rname = [
    "Unranked",
    "Runevox I", "Runevox II", "Runevox III",
    "Emberlynx I", "Emberlynx II", "Emberlynx III",
    "Astridian I", "Astridian II", "Astridian III",
    "Zephyra I", "Zephyra II", "Zephyra III",
    "Celestara I", "Celestara II", "Celestara III",
    "Vortexium I", "Vortexium II", "Vortexium III",
    "Lumithra I", "Lumithra II", "Lumithra III",
    "Netherion I", "Netherion II", "Netherion III",
    "Solarianth I", "Solarianth II", "Solarianth III", "Solarianth IV", "Solarianth V",
    "Aetherionyx"
  ].freeze
  RExtraAetherionyxRank = [
    "Aetherionyx I", "Aetherionyx II", "Aetherionyx III", "Aetherionyx IV", "Aetherionyx V",
    "Aetherionyx VI", "Aetherionyx VII", "Aetherionyx VIII", "Aetherionyx IX", "Aetherionyx X",
    "Aetherionyx XI", "Aetherionyx XII", "Aetherionyx XIII", "Aetherionyx XIV", "Aetherionyx XV",
    "Aetherionyx XVI", "Aetherionyx XVII", "Aetherionyx XVIII", "Aetherionyx XIX", "Aetherionyx XX",
    "Aetherionyx XXI", "Aetherionyx XXII", "Aetherionyx XXIII", "Aetherionyx XXIV", "Aetherionyx XXV",
    "Aetherionyx XXVI", "Aetherionyx XXVII", "Aetherionyx XXVIII", "Aetherionyx XXIX", "Aetherionyx XXX",
    "Aetherionyx XXXI", "Aetherionyx XXXII", "Aetherionyx XXXIII", "Aetherionyx XXXIV", "Aetherionyx XXXV",
    "Aetherionyx XXXVI", "Aetherionyx XXXVII", "Aetherionyx XXXVIII", "Aetherionyx XXXIX", "Aetherionyx XL",
    "Aetherionyx XLI", "Aetherionyx XLII", "Aetherionyx XLIII", "Aetherionyx XLIV", "Aetherionyx XLV",
    "Aetherionyx XLVI", "Aetherionyx XLVII", "Aetherionyx XLVIII", "Aetherionyx XLIX", "Aetherionyx L",
    "Aetherionyx L+"
  ].freeze
  RcolorRank = [
    [154, 154, 154], [99, 99, 99], # Grey - Unranked
    [188, 188, 255], [97, 97, 174], # Cresent
    [128, 84, 57], [48, 30, 19], # Bronze
    [15, 255, 28], [0, 175, 9], # Green 
    [15, 162, 255], [0, 108, 175], # Cyan 
    [255, 188, 15], [175, 126, 0], # Ember 
    [15, 255, 228], [0, 175, 155], # Teal
    [212, 157, 255], [183, 95, 255], # Lavender
    [175, 9, 0], [255, 28, 15], # Crimson
    [175, 68, 0], [255, 108, 15], # Orange
    [99, 0, 180], [148, 15, 255] # Purple - Aetherionyx
  ].freeze

  $rank = 0
  $xp = 0
  $xp_needed = Rxp[$rank]

  def self.rank_colors(rank_count)
    dark_color = Color.new(*RcolorRank[rank_count * 2])
    light_color = Color.new(*RcolorRank[rank_count * 2 + 1])
    [dark_color, light_color]
  end
  # Method to update rank based on XP
  def self.update_rank
    if $xp >= $xp_needed
      $rank += 1
      $xp = 0
      $xp_needed = Rxp[$rank]
      # Update colors based on the new rank
      #dark_color, $light_color = rank_colors($rank)
      #puts "Congratulations! You've been promoted to #{Rname[$rank]}."
    end
  end
  # Method to handle ranking up and down
  def self.rank_change(is_up)
    is_up ? $rank += 1 : $rank -= 1
    $rank = [$rank, 0].max  # Ensure rank doesn't go below 0
    $xp_needed = Rxp[$rank]
    #puts "Your rank is now #{Rname[$rank]}."
  end
  # Method to display XP meter
  def self.xp_meter
    percent_complete = ($xp.to_f / $xp_needed * 100).round(2)
    $perMax = percent_complete
    #puts "XP: #{$xp}/#{Rxp[$rank]} (#{percent_complete}% complete)"
  end
  # Method to display percentage needed to rank up
  def self.xp_meter_needed
    percent_needed = ((Rxp[$rank] - $xp).to_f / Rxp[$rank] * 100).round(2)
    $perNeeded = percent_needed
    #puts "XP needed to rank up: #{percent_needed}%"
  end
  # Method to earn XP
  def self.earn_xp(amount)
    $xp += amount
    update_rank
    xp_meter
  end
  # === === === === === #

  # === # Level Difficulties # === #
  $difficulties = 0
  def self.difficulties
    $difficulties
  end
  def self.difficulties=(value)
    $difficulties = value.nil? ? 0 : value
    diff_colors($difficulties)
  end
  Dnames = ["Standard", "Challenging", "Formidable", "Eradication"]
  Ddesc = [
    "+0% Rewards, +0% Risk, Easy Decisions", # Standard
    "±0% Stats, +0% Enemies, +0% Enemy Stats", 

    "+25% Rewards, +50% Risk, Tough Decisions", # Challenging
    "±0% Stats, +100% Enemies, +150% Enemy Stats",

    "+75% Rewards, +100% Risk, Hard Decisions", # Formidable 
    "-25% Stats, +200% Enemies, +250% Enemy Stats", 

    "+100% Rewards, +300% Risk, Critical Decisions", # Eradication
    "-99.9% HP, -50% Stats, +400% Enemies, Enemy Stats x4" 
  ]
  Dcolor = [
    [175, 126, 0], [255, 188, 15], # Ember - Standard
    [175, 68, 0], [255, 108, 15], # Orange - Challenging
    [175, 9, 0], [255, 28, 15],    # Crimson - Formidable
    [99, 0, 180], [148, 15, 255]  # Purple - Eradication
  ]
  def self.diff_colors(diff_count)
    diff_dark_color = Color.new(*Dcolor[diff_count * 2])
    diff_light_color = Color.new(*Dcolor[diff_count * 2 + 1])
    [diff_dark_color, diff_light_color]
  end
  # === === === === === #
end
