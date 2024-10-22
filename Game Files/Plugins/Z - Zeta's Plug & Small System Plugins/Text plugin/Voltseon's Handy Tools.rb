################################################################################
# Voltseon's Handy Tools
# For more convenience
################################################################################
#
#
# Written by: Voltseon
# Credits not needed (But appreciated)
# Made for people who dont want
# to copy paste long scripts from
# the Pokémon Essentials Wiki
# Version: 1.4
#
################################################################################
#
# Alternate Methods
#
################################################################################
#
# You can ignore these methods as they do not have any comments explaining them
# These are here in case you prefer to use for example:
# vReceiveItem over vRI, just in case
# All of these methods use vA,vB,vC... as their input, they dont mean anything
# They are just indexes. If you are interested in adding your own methods,
# Go ahead, it's free, but don't forget to re-add them when updating the script
# <3 Voltseon
#
# In case these alternate methods are in the way when scrolling through
# the script, I recommend you put these in another seperate section
# !But dont forget to update the Alternate Methods when doing that!
#
################################################################################

#Item Manipulation
def vReceiveItem(vA, vB=1)
vRI(vA, vB)
end

def vItemReceive(vA, vB=1)
vRI(vA, vB)
end

def vGI(vA, vB=1)
vRI(vA, vB)
end

def vGetItem(vA, vB=1)
vRI(vA, vB)
end

def vItemGet(vA, vB=1)
vRI(vA, vB)
end

def vFindItem(vA, vB=1)
vFI(vA, vB)
end

def vItemFind(vA, vB=1)
vFI(vA, vB)
end

def vItemBall(vA, vB=1)
vFI(vA, vB)
end

def vDeleteItem(vA, vB=1)
vDI(vA, vB)
end

def vItemDelete(vA, vB=1)
vDI(vA, vB)
end

def vRemoveItem(vA, vB=1)
vDI(vA, vB)
end

def vItemRemove(vA, vB=1)
vDI(vA, vB)
end

def vAddItem(vA, vB=1)
vAI(vA, vB)
end

def vAddItemSilent(vA, vB=1)
vAI(vA, vB)
end

def vItemAdd(vA, vB=1)
vAI(vA, vB)
end

def vItemSilent(vA, vB=1)
vAI(vA, vB)
end

def vAddItem(vA, vB=1)
vAI(vA, vB)
end

def vItemQuantity(vA)
vIQ(vA)
end

def vQuantityItem(vA)
vIQ(vA)
end

def vHasItem(vA)
vHI(vA)
end

#Pokemon Manipulation
def vGivePokemon(vA, vB)
vGP(vA, vB)
end

def vAddPokemon(vA, vB)
vAP(vA, vB)
end

def vGivePokemonSilent(vA, vB)
vGPS(vA, vB)
end

def vAddPokemonSilent(vA, vB)
vAPS(vA, vB)
end

def vReceivePokemon(vA, vB, vC, vD, vE=0)
vRP(vA, vB, vC, vD, vE)
end

def vDeletePokemon(vA)
vDP(vA)
end

def vRemovePokemon(vA)
vDP(vA)
end

def vHasPokemon(vA)
vHP(vA)
end

def vHS(vA)
vHP(vA)
end

def vHasSpecies(vA)
vHP(vA)
end

#Battles
def vWildBattle(vA, vB, vC=0, vD=true, vE=false)
vWB(vA, vB, vC, vD, vE)
end

def vTrainerBattle(vA, vB, vC, vD=false, vE=0, vF=false, vG=0)
vTB(vA, vB, vC, vD, vE, vF, vG)
end

#Player
def vOutfit(vA)
vO(vA)
end

def vSO(vA)
vO(vA)
end

def vSetOutfit(vA)
vO(vA)
end

def vCharacter(vA)
vC(vA)
end

def vSC(vA)
vC(vA)
end

def vG(vA)
echoln "vG and its alternate methods will be removed in future updates of Voltseon's Handy Tools. Use vC(index) instead."
vC(vA)
end

def vGender(vA)
echoln "vGender and its alternate methods will be removed in future updates of Voltseon's Handy Tools. Use vCharacter(index) instead."
vC(vA)
end
  
def vSG(vA)
echoln "vSG and its alternate methods will be removed in future updates of Voltseon's Handy Tools. Use vSC(index) instead."
vC(vA)
end

def vSetGender(vA)
echoln "vSetGender and its alternate methods will be removed in future updates of Voltseon's Handy Tools. Use vSetCharacter(index) instead."
vC(vA)
end

def vSetCharacter(vA)
vC(vA)
end

def vToggleGender()
vTG()
end

def vToggleRegionDex(vA)
vTRD(vA)
end

def vTogglePokedex()
vTP()
end

def vTogglePokeDex()
vTP()
end

def vToggleRunningShoes()
vTRS()
end

def vRS()
vTRS()
end

def vRunningShoes()
vTRS()
end

def vTogglePokegear()
vTPG()
end

def vTogglePokeGear()
vTPG()
end

#Miscellaneous
def vPC(vA, vB=80, vC=100, vD=0)
vCry(vA, vB, vC, vD)
end

def vPlayCry(vA, vB=80, vC=100, vD=0)
vCry(vA, vB, vC, vD)
end

def vSST(vA, vB="A")
vSS(vA, vB)
end

def vSSt(vA, vB="A")
vSS(vA, vB)
end

def vSetSelfSwitch(vA, vB="A")
vSS(vA, vB)
end

def vSetSelfSwitchTrue(vA, vB="A")
vSS(vA, vB)
end

def vSetSelfSwitchFalse(vA, vB="A")
vSSF(vA, vB)
end

def vSSf(vA, vB="A")
vSSF(vA, vB)
end

def vtSS(vA, vB="A")
vTSS(vA, vB)
end

def vToggleSelfSwitch(vA, vB="A")
vTSS(vA, vB)
end

def vtGS(vA)
vTGS(vA)
end

def vTS(vA)
vTGS(vA)
end

def vToggleGlobalSwitch(vA)
vTGS(vA)
end

def vToggleGameSwitch(vA)
vTGS(vA)
end

def vTS(vA)
vTGS(vA)
end

def vToggleSelfSwitchRange(vA, vB, vC)
vTSSR(vA, vB, vC)
end

def vRTSS(vA, vB, vC)
vTSSR(vA, vB, vC)
end

def vRangeToggleSelfSwitch(vA, vB, vC)
vTSSR(vA, vB, vC)
end

################################################################################
#
# Manipulating Items
#
################################################################################

# Receive Item | Variables: itm = The Item, qty = Quantity of the item.
def vRI(itm, qty=1)
  pbReceiveItem(itm.upcase,qty)
  #Example: vRI("Potion",5) - The player receives 5 potions.
  #Alternates: vReceiveItem(), vItemReceive(), vGI(), vGetItem(), vItemGet()
end

# Find Item | Variables: itm = The Item, qty = Quantity of the item.
def vFI(itm, qty=1)
  pbItemBall(itm.upcase,qty)
  #Example: vFI("Pokeball",5) - The player finds 5 pokéballs.
  #Alternates: vFindItem(), vItemFind(), vItemBall()
end

# Delete Item | Variables: itm = The Item, qty = Quantity of the item.
def vDI(itm, qty=1)
  $bag.remove(itm.upcase,qty)
  #Example: vDI("Keycard",2) - Deletes 2 keycards from the player.
  #Alternates: vDeleteItem(), vItemDelete(), vRemoveItem(), vItemRemove()
end

# Add Item (Silently) | Variables: itm = The Item, qty = Quantity of the item.
def vAI(itm, qty=1)
  $bag.add(itm.upcase,qty)
  #Example: vAI("Revive",5) - The player receives 5 revives, without a messagebox.
  #Alternates: vAddItem(), vAddItemSilent(), vItemAdd(), vItemSilent()
end

# Item Quantity | Variables: itm = The Item
def vIQ(itm)
  $bag.quantity(itm.upcase)
  #Example: if vIQ("OranBerry") < 1 - Checks if the player has <1 Oran Berries.
  #Example 2: "Player has: #{vIQ("AirMail")} Air mails in their bag.
  #Alternates: vItemQuantity(), vQuantityItem()
end

# Has Item | Variables: itm = The Item
def vHI(itm)
  $bag.has?(itm.upcase)
  #Example: if vHI("Protector") - Checks if the player has a Protector.
  #Alternatives: vHasItem()
end

################################################################################
#
# Manipulating Pokemon
#
################################################################################

# Give Pokémon | Variables: pok = The Pokemon, lvl = Level of the Pokemon.
def vGP(pok, lvl)
  pbAddPokemon(pok.upcase,lvl)
  #Example: vGP("Pikachu",5) - Gives the player a level 5 Pikachu.
  #Alternatives: vGivePokemon()
end

# Add Pokémon | Variables: pok = The Pokemon, lvl = Level of the Pokemon.
def vAP(pok, lvl)
  pbAddToParty(pok.upcase,lvl)
  #Example: vAP("Lotad",10) - Gives the player a level 10 Lotad.
  #Different from Give Pokémon: Adds it to your party instead of sending it to your PC.
  #Alternatives: vAddPokemon()
end

# Receive Pokémon | Variables: pok = The Pokemon, lvl = Level of the Pokemon.
# from = The NPC's name, nick = Pokémon's nickname
  # gen = Gender of the NPC: 0=male 1=female 2=unknown
def vRP(pok, lvl, from, nick, gen=0)
  pbAddForeignPokemon(pok.upcase,lvl,from,nick,gen)
  #Example: vRP("Dunsparce",50,"Volt","Seon",2) - Receives a Level 50 Dunsparce from Volt called Seon, Volt is unkown gender.
  #Alternatives: vReceivePokemon()
end

# Delete Pokémon | Variables: i = index.
def vDP(i=0)
  $player.remove_pokemon_at_index(i)
  #Example: vDP(1) - Removes the 2nd Pokémon in the party.
  #Alternatives: vDeletePokemon(), vRemovePokemon()
end

# Give Pokémon Silent | Variables: pok = The Pokemon, lvl = Level of the Pokemon.
def vGPS(pok, lvl)
  pbAddPokemonSilent(pok.upcase,lvl)
  #Example: vGPS("Pikachu",5) - Gives the player a level 5 Pikachu silently.
  #Alternatives: vGivePokemonSilent()
end

# Add Pokémon Silent | Variables: pok = The Pokemon, lvl = Level of the Pokemon.
def vAPS(pok, lvl)
  pbAddToPartySilent(pok.upcase,lvl)
  #Example: vAPS("Lotad",10) - Gives the player a level 10 Lotad silently.
  #Alternatives: vAddPokemonSilent()
end

# Has Pokemon | Variables: pok = The Pokemon
def vHP(pok)
  $player.has_species?(pok.upcase)
  #Example: if vHP("Jirachi") - Returns true if the player has a Jirachi
  #Alternatives: vHasPokemon(), vHS(), vHasSpecies()
end

################################################################################
#
# Battles
#
################################################################################

# Wild Battle | Variables: pok = The Pokemon, lvl = Level of the Pokemon.
# rslt = Game Variable in which the outcome will be recorded: 1=won 2=lost 3=run 4=caught 5=draw.
# escp = if you can run away from the battle.
# lose = if you can lose the battle or black out.
def vWB(pok,lvl,rslt=0,escp=true,lose=false)
  setBattleRule("outcomeVar", rslt) if rslt != 1
  setBattleRule("cannotRun") if !escp
  setBattleRule("canLose") if lose
  WildBattle.start(pok.upcase,lvl)
  #Example: vWB("Nosepass",10,5,true,false) - Battles a level 10 Nosepass that you cannot lose but can escape and result is stored in variable 5.
  #Alternatives: vWildBattle()
end

# Trainer Battle | Variables: cls = Trainer Class, nam = Trainer Name.
# mes = Lose message, dbl = Is it a double battle?
# trn = Trainer Number, cnt = Can you continue?
# out = Game Variable in which the outcome will be stored.
def vTB(cls,nam,mes="...",dbl=false,trn=0,cnt=false,out=0)
  setBattleRule("outcomeVar", out) if out != 1
  setBattleRule("canLose") if cnt
  setBattleRule("double") if dbl
  TrainerBattle.start(cls.upcase,nam,trn)
  #Example: vTB("Camper","Liam","Darn!",false,1,true,2) - Battles Camper Liam #1 who says "Darn!" after he loses, that you can lose and result is stored in variable 2.
  #Alternatives: vTrainerBattle()
end

################################################################################
#
# Manipulate Player
#
################################################################################

# Set outfit | Variables: i = Index, outfit number
def vO(i=0)
  $player.outfit=i
  #Example: vO(5) - Sets the outfit to outfit 5 (trchar000_5)
  #Alternatives: vOutfit(), vSO(), vSetOutfit()
end

# Set character | Variables: i = Index, character number (0=RED, 1=LEAF)
def vC(i=0)
  pbChangePlayer(i)
  #Example: vC(1) - Sets the player character to 1 (LEAF)
  #Alternatives: vGender(), vSG(), vSetGender()
end

# Toggle gender | Variables: none
def vTG()
  i = $player.character_ID
  (i == 1) ? i = 2 : i = 1
  pbChangePlayer(i)
  #Example: vTG() - Toggles the player gender
  #Alternatives: vToggleGender()
  #Note! This only works if there's 2 genders in your game.
end

# Toggle Region Dex | Variables: i = Index, dex number
def vTRD(i=0)
  if $player.pokedex.unlocked?(i)
    $player.pokedex.lock(i)
  else
    $player.pokedex.unlock(i)
  end
  #Example: vTRD(0) - Toggles the region dex #0
  #Alternatives: vToggleRegionDex()
end

# Toggle Pokedex | Variables: none
def vTPD()
  $player.has_pokedex = !$player.has_pokedex
  #Example: vTPD() - Toggles the pokegear
  #Alternatives: vTogglePokedex(), vTogglePokeDex()
end

# Toggle Running Shoes | Variables: none
def vTRS()
  $player.has_running_shoes = !$player.has_running_shoes
  #Example: vTRS() - Toggles the runningshoes
  #Alternatives: vToggleRunningShoes(), vRS(), vRunningShoes()
end

# Toggle Pokegear | Variables: none
def vTPG()
  $player.has_pokegear = !$player.has_pokegear
  #Example: vTPG() - Toggles the pokegear
  #Alternatives: vTogglePokegear(), vTogglePokeGear()
end
################################################################################
#
# Miscellaneous
#
################################################################################

# Play Cry | Variables: i = Index, the National Number of the Pokémon
# vol = Volume, pch = Pitch
def vCry(i,vol=80,pch=100,form=0)
  cry=GameData::Species.cry_filename(i,form)
  pbSEPlay(cry,vol,pch)
  #Example: vCry(25,120,50) - Plays Pikachu's Cry at 120% volume and 50% pitch.
  #Alternatives: vPlayCry(), vPC()
end

# Set Selfswitch = True | Variables: i = Index, Event Number & swt = Switch
def vSS(i,swt="A")
  pbSetSelfSwitch(i,swt,true)
  #Example: vSS(5,"C") - Sets Self Switch C of Event #5 to true
  #Alternatives: vSST(), vSSt(), vSetSelfSwitch(), vSetSelfSwitchTrue()
end

# Set Selfswitch = False | Variables: i = Index, Event Number & swt = Switch
def vSSF(i,swt="A")
  pbSetSelfSwitch(i,swt,false)
  #Example: vSSF(2,"B") - Sets Self Switch B of Event #2 to false
  #Alternatives: vSSf(), vSetSelfSwitchFalse()
end

# Toggle Selfswitch | Variables: i = Index, Event Number & evt = Event ID
def vTSS(evt=@event_id,i="A")
  $game_self_switches[[$game_map.map_id,evt,i]]=!$game_self_switches[[$game_map.map_id,evt,i]]
  $game_map.need_refresh = true
  #Example: vTSS(5,"C") - Toggles Self Switch C of Event #5
  #Alternatives: vtSS(), vToggleSelfSwitch()
end

# Toggle Global Switch | Variables: i = Index
def vTGS(i)
  $game_switches[i]=!$game_switches[i]
  $game_map.need_refresh = true
  #Example: vTGS(50) - Toggles Global Switch #50
  #Alternatives: vtGS(), vTS(), vToggleGlobalSwitch(), vToggleGameSwitch(), vToggleSwitch()
end

# Toggle Selfswitch in Range | Variables: swt = Switch, min & max = range
def vTSSR(swt,min,max)
  i=min
  while i <= max
    vTSS(i,swt)
    i+=1
  end
  #Example: vTSSR("A",5,15) - Toggles Self Switch "A" for event 5 through 15
  #Alternatives: vToggleSelfSwitchRange(), vRTSS(), vRangeToggleSelfSwitch()
end