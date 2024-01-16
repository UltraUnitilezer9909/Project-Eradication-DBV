#-------------------------------------------------------------------------------
# Voltseon's Pause Menu
# Pause with style 😎
#-------------------------------------------------------------------------------
#
# Original Script by Yankas
# Updated compatablilty by Cony
# Edited and modified by Voltseon, Golisopod User and ENLS
#
# Made for people who dont want
# to have ugly pause menus
# so here's a really cool one!
# Version: 1.8
#
#
#-------------------------------------------------------------------------------
# Menu Options
#-------------------------------------------------------------------------------
# Main file path for the menu
MENU_FILE_PATH = "Graphics/Pictures/UI/PauseMenuUI/"

# An array of aLL the Menu Entry Classes from 005_VoltseonMenu_Entries that
# need to be loaded
MENU_ENTRIES = [
  "MenuEntryPokemon", "MenuEntryPokedex", "MenuEntryBag", "MenuEntryPokegear",
  "MenuEntryTrainer", "MenuEntryMap", "MenuEntryExitBugContest",
  "MenuEntryExitSafari", "MenuEntrySave", "MenuEntryDebug", "MenuEntryOptions",
  "MenuEntryEncounterList", "MenuEntryQuestsLog", "MenuEntryQuit"
]

# An array of aLL the Menu Component Classes from 004_VoltseonMenu_Components
# that need to be loaded
MENU_COMPONENTS = [
  "SafariHud", "BugContestHud", "PokemonPartyHud", "DateAndTimeHud", "NewQuestHud"
]

# The default theme for the menu screen
DEFAULT_MENU_THEME = 0

# Change Theme in the Options Menu
CHANGE_THEME_IN_OPTIONS = false

#-------------------------------------------------------------------------------
# Look and Feel
#-------------------------------------------------------------------------------
# Background options
BACKGROUND_TINT = Color.new(-80,-80,-80, 100) #Color.new(-30,-30,-30,130) # Tone (Red, Green, Blue, Grey) applied to the background/map.

SHOW_MENU_NAMES = true # Whether or not the Menu option Names show on screen (true = show names)

# Icon options
ACTIVE_SCALE = 1.8

MENU_TEXTCOLOR = [
            Color.new(*$zColorsRGB[25])
          ]
MENU_TEXTOUTLINE = [
            Color.new(*$zColorsRGB[24])
          ]
LOCATION_TEXTCOLOR = [
            Color.new(*$zColorsRGB[25])
          ]
LOCATION_TEXTOUTLINE = [
            Color.new(*$zColorsRGB[24])
          ]

# Sound Options
MENU_OPEN_SOUND   = "Z - Access Non PC"
MENU_CLOSE_SOUND  = "Z - Access Quit PC"
MENU_CURSOR_SOUND = "GUI sel cursor"
