# PSDK Technical Demo
PSDK Technical Demo is a standard PokémonSDK/Studio project which aims to let beginners create their fangame the best way possible by giving them as many information as possible, such as:
- how to use basic RMXP commands
- how to use PokémonSDK commands
- how to create complex events
- how to make the link between the information created with Studio in PokémonSDK
- and much more...

It features all of the above in the form of a small educational game which lasts around 3 to 4 hours.

## Useful links
[![Discord](https://img.shields.io/discord/143824995867557888.svg?logo=discord&colorB=728ADA&label=Discord)](https://discord.gg/0noB0gBDd91B8pMk)
[![Twitter PSDK](https://img.shields.io/twitter/follow/PokemonSDK?label=Twitter%20PSDK&logoColor=%23333333&style=social)](https://twitter.com/PokemonSDK)
[![Twitter PW](https://img.shields.io/twitter/follow/PokemonWorkshop?label=Twitter%20PW&logoColor=%23333333&style=social)](https://twitter.com/PokemonWorkshop)
[![GitHub Pokémon Studio](https://img.shields.io/badge/Powered_by-Pokémon_Studio-6562f8?style=flat&logo=github&labelColor=1d1c22)]((https://github.com/PokemonWorkshop/PokemonStudio))

You can also head to the [Pokémon Workshop website](https://pokemonworkshop.com/) to find some useful articles about using some of PokémonSDK's features.

### Information about playing the Demo
Here is everything you need to know to enjoy this demo to the fullest.
- It is **STRONGLY** recommended that you play the game first before opening it with RMXP, as it was made to be an educational game. If you play it, you'll understand a lot quicker which event does what, and you'll know where to find the right events.
  - The game is considered finished when you have found the 16 Intriguing Stones and talked to SirMalo in the Hub. You will find one in all maps, except for the Hub and the two elevators.
  - This game was made with lots of time, dedication and love by Rey and SirMalo.
  - The game was thoroughly tested by around 25 testers. Of course, some last minutes oddities might have been forgotten. Let us know on the Discord server of you find any of these bugs!
- In front of every message, you'll find a series of number. Example: `3, 30 This is a message`. This series indicates the CSV file and the line you should seek. PokémonSDK uses CSV for enabling translations of your game, and this code indicates PokémonSDK to seek the CSV `3.csv`, at the line 30. Warning: 30 here actually counts as line 32 when opened in any respectable text editing software (VSCode is highly recommended), as the first line (fr, en, etc.) isn't counted, and counting in Ruby starts at 0. Always remember to add 2 to your number to find the proper line, or substract 2 to go from the line to the right code to input in an event.
  - Do not mistake `3, 30` for `\t[3, 30]` as those two strings aren't the same thing. In the case of `\t[3, 30]`, this string will indicate PokémonSDK to get the text in the CSV `100003.csv`. The line logic from previous paragraph is still valid.

### Information about this base project
Here are some information about this base project:
- This base project uses Tiled by default. The maps, tilesets, and assets are located in Data/Tiled. Your own maps/tilesets/assets **MUST** be located at the same places.
- It is recommended you keep these maps in your project to be able to refer to these at any times. But you can also create two projects: your own without the demo, and a project solely for tests and for refering to the demo.
  - If you go the second route, make sure to delete the maps in Studio, and delete the tilesets in the RMXP tileset editor **before** initiating the first Tiled map conversion.
- The maps **WILL** look weird in RMXP after a Tiled map conversion involving animated tiles. This behavior is totally normal and the maps will look absolutely fine ingame. To ensure we could convert Tiled animated tiles to RMXP, we had to make this choice to ensure the best compatibility.

Thank you for choosing to use PokémonSDK and Pokémon Studio to make your fangame, and we hope you'll enjoy this demo! ❤

Let us know what you thought of it in either the [#💬🌎・psdk-talk](https://ptb.discord.com/channels/143824995867557888/520273477144412171) (EN channel) or [#💬🥖・psdk-discussions](https://ptb.discord.com/channels/143824995867557888/360856242111119360) (FR channel)!
