# SysFixData is going to be the "Global Variable Storage", you know, where ever fix number is stored?
module SysFixData
  # === # Ranks # === #
  Rname = [
    "Unranked",
    ["Runevox I", "Runevox II", "Runevox III"],
    ["Emberlynx I", "Emberlynx II", "Emberlynx III"],
    ["Astridian I", "Astridian II", "Astridian III"],
    ["Zephyra I", "Zephyra II", "Zephyra III"],
    ["Celestara I", "Celestara II", "Celestara III"],
    ["Vortexium I", "Vortexium II", "Vortexium III"],
    ["Lumithra I", "Lumithra II", "Lumithra III"],
    ["Netherion I", "Netherion II", "Netherion III"],
    ["Solarianth I", "Solarianth II", "Solarianth III", "Solarianth IV", "Solarianth V"],
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
  Rcolor = [
  # Dark / Light format
  [99, 99, 99],[154, 154, 154], # Grey - Unranked
  [97, 97, 174], [188, 188, 255], # Cresent
  [48, 30, 19], [128, 84, 57], # Bronze
  [0, 175, 9], [15, 255, 28], # Green 
  [0, 108, 175], [15, 162, 255], # Cyan 
  [175, 126, 0], [255, 188, 15], # Ember
  [0, 175, 155], [15, 255, 228], # Teal
  [183, 95, 255], [212, 157, 255], # Lavender
  [175, 9, 0], [255, 28, 15], #Crimson
  [175, 68, 0], [255, 108, 15], # Orange
  [99, 0, 180], [148, 15, 255] # Purple - Aetherionyx
  ].freeze
  def self.rank_colors(rank_count)
    dark_color = Color.new(*Rcolor[rank_count * 2])
    light_color = Color.new(*Rcolor[rank_count * 2 + 1])
    [dark_color, light_color]
  end
  # === === === === === #

  # === # Level Difficulties # === #
  @difficulties = 0
  def self.difficulties
    @difficulties
  end
  def self.difficulties=(value)
    @difficulties = value.nil? ? 0 : value
    diff_colors(@difficulties)
  end
  Dnames = ["Standard", "Challenging", "Formidable", "Eradication"]
  Rcolor = [
    [175, 126, 0], [255, 188, 15], # Ember - Standard
    [175, 68, 0], [255, 108, 15], # Orange - Challenging
    [175, 9, 0], [255, 28, 15],    # Crimson - Formidable
    [99, 0, 180], [148, 15, 255]  # Purple - Eradication
  ]
  def self.diff_colors(diff_count)
    diff_dark_color = Color.new(*Rcolor[diff_count * 2])
    diff_light_color = Color.new(*Rcolor[diff_count * 2 + 1])
    [diff_dark_color, diff_light_color]
  end
  # === === === === === #

  # === # Colors # === #
  ZColorsRGB = [
    # Dark: Color.new(*SysFixData::ZColors[X * 2])
    # Light: Color.new(*SysFixData::ZColors[X * 2 + 1])
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
  ZColorsHEX = [
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
end
