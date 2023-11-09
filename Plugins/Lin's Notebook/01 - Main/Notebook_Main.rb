#===============================================================================
# * Notebook - by LinKazamine (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It creates everything needed for the Notes.
#
#== INSTALLATION ===============================================================
#
# Drop the folder in your Plugin's folder.
#
#===============================================================================

class PokemonSystem
  attr_accessor :notebook

  alias _plugin_initialize initialize
  def initialize
    _plugin_initialize
    @notebook              = nil
  end
end

class Mail
  attr_accessor :item, :matter, :message, :sender, :poke1, :poke2, :poke3

  def initialize(item, matter, message, sender, poke1 = nil, poke2 = nil, poke3 = nil)
    @item    = GameData::Item.get(item).id   # Item represented by this mail
    @matter  = matter    # Matter of the letter
    @message = message   # Message text
    @sender  = sender    # Name of the message's sender
    @poke1   = poke1     # [species,gender,shininess,form,shadowness,is egg]
    @poke2   = poke2
    @poke3   = poke3
  end
end