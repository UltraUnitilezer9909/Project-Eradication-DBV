#===============================================================================
# * Notebook PC - by LinKazamine (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It creates a storage for the notes.
#
#== INSTALLATION ===============================================================
#
# Drop the folder in your Plugin's folder.
#
#===============================================================================

#===============================================================================
# Move mail to Notebook PC
#===============================================================================
def pbMoveToNotebook(pokemon)
  $PokemonSystem.notebook = [] if !$PokemonSystem.notebook
  return false if $PokemonSystem.notebook.length >= NoteConfig::NUM_NOTE_STORAGE
  return false if !pokemon.mail
  $PokemonSystem.notebook.push(pokemon.mail)
  pokemon.mail = nil
  return true
end


#===============================================================================
# * Notebook PC
#===============================================================================
def pbPCNotebook
  if !$PokemonSystem.notebook || $PokemonSystem.notebook.length == 0
    pbMessage(_INTL("There's no notes here."))
  else
    loop do
      command = 0
      commands = []
      $PokemonSystem.notebook.each do |mail|
        commands.push(mail.matter)
      end
      commands.push(_INTL("Cancel"))
      command = pbShowCommands(nil, commands, -1, command)
      if command >= 0 && command < $PokemonSystem.notebook.length
        mailIndex = command
        commandMail = pbMessage(
          _INTL("What do you want to do with note {1}?", $PokemonSystem.notebook[mailIndex].matter),
          [_INTL("Read"),
           _INTL("Delete"),
           _INTL("Cancel")], -1
        )
        case commandMail
        when 0   # Read
          pbFadeOutIn {
            pbDisplayMail($PokemonSystem.notebook[mailIndex])
          }
        when 1   # Delete
          if pbConfirmMessage(_INTL("The note will be lost. Is that OK?"))
            pbMessage(_INTL("The note was deleted."))
            $PokemonSystem.notebook.delete_at(mailIndex)
          end
        end
      else
        break
      end
    end
  end
end