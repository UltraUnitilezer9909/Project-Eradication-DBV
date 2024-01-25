# SysFixData is going to be the "Global Variable Storage", you know, where ever fix number is stored?
module SysFixData
  # === # Colors # === #
  $zColorsRGB = [
    # Dark: Color.new(*SysFixData::zColorsRGB[X * 2])
    # Light: Color.new(*SysFixData::zColorsRGB[X * 2 + 1])
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
    [165, 165, 173], [255, 255, 255], # White
    [48, 30, 19], [128, 84, 57], # Wood
    [95, 193, 255], [157, 217, 255], # Candy Blue
    [255, 95, 140], [255, 157, 184], # Candy Pink
    [95, 255, 176], [157, 255, 206], # Candy Teal
    [183, 95, 255], [212, 157, 255] # Candy Magenta
  ].freeze
  $zColorsHex = [
    #  Color.new(*SysFixData::zColorsHex[X])
    # Dark / Light format
    "636363", "9A9A9A", # 0 Grey
    "6161AE", "BCBCFF", # 1 Cresent
    "301E13", "805439", # 2 Bronze
    "00AF09", "0FFF1C", # 3 Lime
    "006CAF", "0FA2FF", # 4 Cyan 
    "AF7E00", "FFBC0F", # 5 Ember
    "00AF9B", "0FFFE4", # 6 Teal
    "B75FFF", "D49DFF", # 7 Lavender
    "AF0900", "FF1C0F", # 8 Crimson
    "AF4400", "FF6C0F", # 9 Orange
    "6300B4", "941FFF", # 10 Shadow
    "C200DB", "E415FF", # 11 Magenta
    "A5A5AD", "FFFFFF", # 12 White
    "301E13", "805439", # 13 Wood
    "5FC1FF", "9DD9FF", # 14 Candy Blue
    "FF5F8C", "FF9DB8", # 15 Candy Pink
    "5FFFB0", "9DFFCE", # 16 Candy Teal
    "B75FFF", "D49DFF"  # 17 Candy Magenta
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
    [154, 154, 154], [99, 99, 99],     # Grey - Unranked
    [188, 188, 255], [97, 97, 174],    # Cresent
    [128, 84, 57], [48, 30, 19],       # Bronze
    [15, 255, 28], [0, 175, 9],        # Green 
    [15, 162, 255], [0, 108, 175],     # Cyan 
    [255, 188, 15], [175, 126, 0],     # Ember 
    [15, 255, 228], [0, 175, 155],     # Teal
    [212, 157, 255], [183, 95, 255],   # Lavender
    [175, 9, 0], [255, 28, 15],        # Crimson
    [175, 68, 0], [255, 108, 15],      # Orange
    [99, 0, 180], [148, 15, 255]       # Purple - Aetherionyx
  ].freeze

  $rank = 0
  $xp = 0
  $xp_needed = Rxp[$rank]
  # Method the get the colors
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
    "±0% Rewards, Risk x1, Easy Decisions", # Standard
    "Stats x1, Enemies x1, ±0% Enemy Stats", 

    "Rewards x1.25, Risk x1.5, Tough Decisions", # Challenging
    "Stats x1, Enemies x2, Enemy Stats x1.5",

    "Rewards x1.75, Risk x2, Hard Decisions", # Formidable 
    "Stats x0.75, Enemies x3, Enemy Stats x2.5", 

    "Rewards x2, Risk x4, Critical Decisions", # Eradication
    "1% HP, -50% Stats, Enemies x4, Enemy Stats x4, AOE x6" 
  ]
  Dcolor = [
    [175, 126, 0], [255, 188, 15],    # Ember - Standard
    [175, 68, 0], [255, 108, 15],     # Orange - Challenging
    [175, 9, 0], [255, 28, 15],       # Crimson - Formidable
    [99, 0, 180], [148, 15, 255]      # Purple - Eradication
  ]
  def self.diff_colors(diff_count)
    diff_dark_color = Color.new(*Dcolor[diff_count * 2])
    diff_light_color = Color.new(*Dcolor[diff_count * 2 + 1])
    [diff_dark_color, diff_light_color]
  end
  # === === === === === #

  # === # Character Name # === #
  $cname = {
    -1 => "System", # 1
    0 => "???", # 1
    1 => "Haru", # 0
    2 => "Sakura", # 11
    3 => "Kaori", # 14
    4 => "Ayumi", # 5
    5 => "Hikaru", # 8 
    6 => "Kohana", # 15
    7 => "Ryo"
  }
  # === === === === === #

  # === # Player Info # === #
  $gender = "M" # default male
  $gender2 = "F" # default female
  $age = 20
  # === === === === === #

  # === # Text Stuff # === #
  $choice = nil
  $choice2 = nil
  # === === === === === #

  # === # File Path # === #
  $bgPath = "UI/bg"
  $bgPath2 = "Graphicc/Pictures/#{$bgPath}"
  # === === === === === #
  # === # Move Route # === #
  # === === === === === #
end