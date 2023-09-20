#===============================================================================
# * Notebook Notes - by LinKazamine (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. The code for creating and storing notes.
#
#== INSTALLATION ===============================================================
#
# Drop the folder in your Plugin's folder.
#
#===============================================================================

#===============================================================================
# Create a Note
#===============================================================================
def writeNote
  p=Pokemon.new(NoteConfig::POKEMON,30,$Trainer)
  title = pbEnterText(_INTL("Title for the note?"), 0, 25, _INTL(""))
  if title != ""
    commands = NoteConfig::NOTES_BACKGROUND
    command_list = []
    for i in 0...commands.length
      name = GameData::Item.get(commands[i]).name
      command_list.push(name)
    end
    command_list.push("Cancel")
    choice = pbMessage(
          _INTL("Choose a background for the note."),
          command_list, -1
        )
    if choice <= commands.length
    mailItem = commands[choice]
    msg = pbEnterText(_INTL("Enter a text"), 0, 250, _INTL(""))
    p.mail = Mail.new(mailItem, title, msg, "")
    p.item = mailItem                #gives the mail defined before
    pokemonTeam = $player.party.clone    #clones to restore all the data later
    if $player.party_count == Settings::MAX_PARTY_SIZE #checks if the team is full
      index = $player.party_count - 1
      $player.remove_pokemon_at_index(index) #removes the last pokemon of the team
    end
    pbAddPokemonSilent(p)                #adds the defined pokemon on the party
    pkmn = $player.last_pokemon          #gets the data to modify the pokemon
    pbMoveToNotebook(pkmn)               #sends the held item to the pc
    index = $player.party_count - 1
    $player.remove_pokemon_at_index(index)
    $Trainer.party = pokemonTeam         #restores the party as it was before
    pokemonTeam = nil                    #deletes the data to use again
    mailItem = nil                    #deletes the data to use again
    end
  end
end