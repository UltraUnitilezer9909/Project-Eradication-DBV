#===============================================================================
# Turn certain settings on/off according to your preferences.
#===============================================================================
module RegionMapSettings
    #===============================================================================
    # Hidden Region Locations
    #===============================================================================
    # This is similar to the REGION_MAP_EXTRAS you set-up in the Settings script section.
    # Why it is here? Well this is simply because it's easier to access if it's all on 1 place.
    # A set of arrays, each containing details of a graphic to be shown on the
    # region map if appropriate. The values for each array are as follows:
    #   * Region number.
    #   * Game Switch; The graphic is shown if this is ON (non-wall maps only unless you set the last setting to nil).
    #   * X coordinate of the graphic on the map, in squares.
    #   * Y coordinate of the graphic on the map, in squares.
    #   * Name of the graphic, found in the Graphics/Pictures folder.
    #   * The graphic will always (true), never (false) or only when the switch is ON (nil) be shown on a wall map.
    REGION_MAP_EXTRAS = [
      [0, 51, 16, 15, "mapHiddenBerth"], #last option is set to nil
      [0, 52, 20, 14, "mapHiddenFaraday", true] #last option is set to true
    ]
    #===============================================================================
    # Fly From Town Map
    #===============================================================================
    # Whether the player can use Fly while looking at the Town Map. This is only
    # allowed if the player can use Fly normally.
    CAN_FLY_FROM_TOWN_MAP = true

    #===============================================================================
    # Quick Fly Feature Settings
    #===============================================================================
    # Set this to true if you want to enable the Quick Fly feature.
    # Set this to false if you don't want to use this feature, all other settings below will be ignored.
    CAN_QUICK_FLY = true

    # Choose which button will activate the Quick Fly Feature
    # Possible buttons are: JUMPUP, JUMPDOWN, SPECIAL, AUX1 and AUX2. any other buttons are not recommended.
    # Press F1 in game to know which key a button is linked to.
    # IMPORTANT: only change the "JUMPUP" to SPECIAL for example so QUICK_FLY_BUTTON = Input::SPECIAL
    QUICK_FLY_BUTTON = Input::JUMPUP

    # Set this to true if you want to enable that the cursor moves automatically to the selected map from the Quick Fly Menu (on selecting, not confirming).
    # Set this to false if you don't want to enable this.
    AUTO_CURSOR_MOVEMENT = true 

    # Set a Switch that needs to be ON in order to enable the Quick Fly Feature.
    # Set this to nil if you don't want to require any switch to be ON.
    # Example: SWITCH_TO_ENABLE_QUICK_FLY = 11 # Quick Fly will be enabled when Switch with ID 11 (Defeated Gym 8) is set to ON. (This is a default essentials Switch) 
    SWITCH_TO_ENABLE_QUICK_FLY = nil 

    #===============================================================================
    # Show Quest Icons on the Region Map (IMPORTANT: Required the MQS Plugin to funcion correctly!)
    #===============================================================================
    # Set this to true if you want to display Quest Icons on the Region map (this only shows on the Town Map the player owns and the PokeGear map).
    # Set this to false if you don't want to display Quest Icons or if you are simply not using the MQS Plugin.
    # If the MQS is not installed and this is set to true, it won't harm anything.
    SHOW_QUEST_ICONS = true  

    # Choose which button will activate the Quest Review. 
    # Possible buttons are: USE, JUMPUP, JUMPDOWN, SPECIAL, AUX1 and AUX2. any other buttons are not recommended.
    # USE can be used this time because unlike with the fly map, it won't do anything.
    # Press F1 in game to know which key a button is linked to.
    # IMPORTANT: only change the "JUMPUP" to JUMPDOWN for example so SHOW_QUEST_BUTTON = Input::JUMPDOWN
    SHOW_QUEST_BUTTON = Input::JUMPUP
    #===============================================================================
    # Cursor Map Movement Offset
    #===============================================================================
    # This is a optional Setting to make the map move before the Cursor is at the edge of the map screen.
    # - false = No offset, the map will only move (if possible) when the cursor is on the direction's edge of the screen.
    #     example: When you  want to move to the Right, the map will only start moving once the cursor is all the way on the Right edge of the screen. 
    # - true = the map will move (if possible) when the cursor is 1 position away from the direction's edge of the screen.
    #     example: When you want to move to the Right, the map will start moving once the cursor is 1 tile away from the Right edge of the screen. 
    CURSOR_MAP_OFFSET = true
    #===============================================================================
    # Region District Names
    #===============================================================================
    # Set this to true if you want to change the default name (defined in the PBS) for certain parts of your Region Map.
    USE_REGION_DISTRICTS_NAMES = true 

    #   * Region Number
    #   * [min X, max X]; the minimum X value and the maximum X value, in squares.
    #       example: [0, 32]; when the cursor is between 0 and 32 (including 0 and 32) the name of the region changes (depending on the Y value as well).
    #   * [min Y, max Y]; the minimum Y value and the maximum Y value, in squares.
    #       example: [0, 10]; when the cursor is between 0 and 10 (including 0 and 10) the name of the region changes (depending on the X value as well).
    #   * Region District Name; this is the name the script will use only when the cursor is inside X and Y range.
    REGION_DISTRICTS = [
      [0, [9, 12], [8, 11], "West Essen"],
      [0, [9, 19], [12, 15], "South Essen"],
      [0, [9, 19], [4, 7], "North Essen"],
      [0, [15, 19], [7, 11], "East Essen"],
      [0, [13, 14], [8, 11], "Central Essen"],
      [1, [10, 20], [5, 15], "Central Tiall"]
    ]
    #===============================================================================
    # Unvisited Map Image name exceptions
    #===============================================================================
    # Add the Healspot of the map and a new image name you want the script to use a different unvisited map image for.
    # Healspot = mapID, mapX, mapY (this is where you'll fly to when using fly with that map as destination).
    # The image name should not include map, just like in the PBS.
    # This exception can be used when the top left point of a city/town has a different highlight image, like a location in a town/city.
    # example USE_UNVISITED_IMAGE_EXCEPTION = [[11, 19, 32, "Size2x2Special1"]]
    # There might be a different work around but this setting makes it much easier and prevents you from having to make tons of new images with different names which can get confusing.
    USE_UNVISITED_IMAGE_EXCEPTION = [
      [11, 19, 32, "Size2x2Special1"]
    ]
  end