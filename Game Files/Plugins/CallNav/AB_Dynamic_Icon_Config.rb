#===============================================================================
# Monkey patch the existing PokenavButton class to add the icons
#								(DO NOT EDIT!!!)
#===============================================================================
class PokenavPhoneButton
  alias original_refresh refresh

  def refresh
    original_refresh
#===============================================================================
#								(EDIT AREA STARTS BELOW)
#===============================================================================


#===============================================================================
#								REMATCH ICON REPLACERS
#===============================================================================
# Below Handles adding decorative icons on NPCs by replacing the rematch icon.
# NPC's don't use this function space and so i used it for decorative icons.
# The professor's icon will always be a pokedex and the professor's name can be
# defined in "AA_input_config.rb".
# It is not suggested to override a Trainer's rematch icon with this method.
#===============================================================================


#===============================================================================	
# This one gives your rival a the bluecard icon next to him
#===============================================================================  
    if @name == $game_variables[RIVAL].to_s && @flag == "Rival"
      vsseeker_bitmap = Bitmap.new("Graphics/Pictures/CallNav/NPC_Icons/rival.png")
      vsseeker_width = 32  # Set the desired width (e.g., 16)
      vsseeker_height = 32  # Set the desired height (e.g., 16)
      self.bitmap.stretch_blt(Rect.new(0, 10, vsseeker_width, vsseeker_height), vsseeker_bitmap, Rect.new(0, 0, 64, 64))
      vsseeker_bitmap.dispose
    end
#===============================================================================  
# This one gives NPC Brendan a ticket icon next to him.
#===============================================================================  
    if @name == "Brendan" && @flag == "Hoenn"
      vsseeker_bitmap = Bitmap.new("Graphics/Pictures/CallNav/NPC_Icons/Hoenn.png")
      vsseeker_width = 32  # Set the desired width (e.g., 16)
      vsseeker_height = 32  # Set the desired height (e.g., 16)
      self.bitmap.stretch_blt(Rect.new(0, 10, vsseeker_width, vsseeker_height), vsseeker_bitmap, Rect.new(0, 0, 64, 64))
      vsseeker_bitmap.dispose
    end
  
#===============================================================================


  
#===============================================================================
#								FACE ICON REPLACERS
#===============================================================================
# Below Handles adding Dynamic Face icons to NPCs.
# This is best for NPCs that are dynamicly names or for story reasons should you
# need a face image to change it this part comes with that function.
#===============================================================================
# Handles icon matching for rival due to dynamic naming
#===============================================================================
 if @name == $game_variables[RIVAL].to_s && @flag == "Rival"
  icon_filename = "Graphics/Pictures/CallNav/Face_Icons/icon_rival.png"
  if icon_exists?(icon_filename)
    icon_bitmap = Bitmap.new(icon_filename)
    self.bitmap.blt(8, -11, icon_bitmap, Rect.new(0, 0, 64, 64)) if icon_bitmap
    icon_bitmap.dispose if icon_bitmap
  end
  end
# Note: Above code handles the rival icon as the name is dynamic, which is why default icon is a blank .png
#		You can replace default with another image but that image will be on top of this one.
#===============================================================================
# Handles Brendan from Hoenn's Switch based dynamic icon
#===============================================================================
 if @name == "Brendan" && @flag == "Hoenn" && !$game_switches[61] 
  icon_filename = "Graphics/Pictures/CallNav/Face_Icons/icon_Brendan_D.png"
  if icon_exists?(icon_filename)
    icon_bitmap = Bitmap.new(icon_filename)
    self.bitmap.blt(8, -11, icon_bitmap, Rect.new(0, 0, 64, 64)) if icon_bitmap
    icon_bitmap.dispose if icon_bitmap
  end
  else
   if @name == "Brendan" && @flag == "Hoenn"
  icon_filename = "Graphics/Pictures/CallNav/Face_Icons/icon_Brendan_G.png"
  if icon_exists?(icon_filename)
    icon_bitmap = Bitmap.new(icon_filename)
    self.bitmap.blt(8, -11, icon_bitmap, Rect.new(0, 0, 64, 64)) if icon_bitmap
    icon_bitmap.dispose if icon_bitmap
  end
  end
  end
#===============================================================================
# Note: In the above example when switch 61 is triggered his icon will change.
#		This is good for story beats when you want to change the look due to
#		a character's visual change or grey the icon to show unavailabilty.
#===============================================================================
 if @name == "Matt" && @flag == "Traveler"
  icon_filename = "Graphics/Pictures/CallNav/Face_Icons/icon_Traveler_Matt.png"
  if icon_exists?(icon_filename)
    icon_bitmap = Bitmap.new(icon_filename)
    self.bitmap.blt(8, -11, icon_bitmap, Rect.new(0, 0, 64, 64)) if icon_bitmap
    icon_bitmap.dispose if icon_bitmap
  end
  end

#===============================================================================
  end
  end
  