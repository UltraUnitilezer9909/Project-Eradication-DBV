A Persistent Switch or Variable is one that's value will be saved even if the player doesn't end up saving the game,
or if they start a new game. This could be used for something like a New Game+ or an achievement that the player
only needs to complete once across all save files.

To turn a Switch or Variable into a persistent one, simply include "[p]" in the Switch/Variable name.
	- Example: To create a persistent variable for the player's favorite number, name the variable: 
		[p]Favorite Number
	- Example: To create a persistent switch for if the player completed the Pokedex, name the variable:
		[p]Completed Pokedex

To control a persistent Switch or Variable, you can manipulate it in all the normal ways like through event commands
or script calls. There isn't any special handling.