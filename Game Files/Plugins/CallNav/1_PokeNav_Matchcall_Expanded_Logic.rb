#===============================================================================
# Phone register silent
#===============================================================================
#You can use this method to pre register NPCs like the Professor or Rival
#=================================================
def pbPhoneRegisterNPCSilent(ident, name, mapid, showmessage = false)
  $PokemonGlobal.phoneNumbers = [] if !$PokemonGlobal.phoneNumbers
  exists = pbFindPhoneTrainer(ident, name)
  if exists
    return if exists[0]   # Already visible
    exists[0] = true   # Make visible
  else
    phonenum = [true, ident, name, mapid]
    $PokemonGlobal.phoneNumbers.push(phonenum)
  end
end
#===============================================================================
# Phone register Nav message
#===============================================================================
def pbPhoneRegisterNPCNav(ident, name, mapid, showmessage = true, flag = "")
  $PokemonGlobal.phoneNumbers = [] if !$PokemonGlobal.phoneNumbers
  exists = pbFindPhoneTrainer(ident, name)
  if exists
    return if exists[0]   # Already visible
    exists[0] = true   # Make visible
  else
    phonenum = [true, ident, name, mapid, flag]
    $PokemonGlobal.phoneNumbers.push(phonenum)
  end
  pbMessage(_INTL("\\me[Register phone]Registered {1} in the PokéNav.", name)) if showmessage
 end
#===============================================================================
# Phone-related counters
#===============================================================================
EventHandlers.add(:on_frame_update, :phone_call_counter,
  proc {
	EventHandlers.add(:on_frame_update, :phone_call_counter,
	proc {
    next if !$bag.has?(:POKENAV) && ($game_switches[VSOFF] == true || $game_switches[VSBLOCK] == true)
    # Reset time to next phone call if necessary
    if !$PokemonGlobal.phoneTime || $PokemonGlobal.phoneTime <= 0
      $PokemonGlobal.phoneTime = rand(20...40) * 60 * Graphics.frame_rate
    end
    # Don't count down various phone times if other things are happening
    $PokemonGlobal.phoneNumbers = [] if !$PokemonGlobal.phoneNumbers
    next if $game_temp.in_menu || $game_temp.in_battle || $game_temp.message_window_showing
    next if $game_player.move_route_forcing || pbMapInterpreterRunning?
    # Count down time to next phone call
    $PokemonGlobal.phoneTime -= 1
    # Count down time to next can-battle for each trainer contact
    if $PokemonGlobal.phoneTime % Graphics.frame_rate == 0   # Every second
      $PokemonGlobal.phoneNumbers.each do |num|
        next if !num[0] || num.length != 8   # if not visible or not a trainer
        # Reset time to next can-battle if necessary
        if num[4] == 0
          num[3] = rand(20...40) * 60   # 20-40 minutes
          num[4] = 1
        end
        # Count down time to next can-battle
        num[3] -= 1
        # Ready to battle
        if num[3] <= 0 && num[4] == 1
          num[4] = 2   # set ready-to-battle flag
          pbSetReadyToBattle(num)
        end
      end
    end
    # Time for a random phone call; generate one
    if $PokemonGlobal.phoneTime <= 0
      # find all trainer phone numbers
      phonenum = pbRandomPhoneTrainer
      if phonenum
        call = pbPhoneGenerateCall(phonenum)
        pbPhoneCall(call, phonenum)
      end
    end
  }
)
}
)
#===============================================================================
# Phone register Nav trainers
#===============================================================================
def pbPhoneRegisterBattleNav(message, event, trainertype, trainername, maxbattles)
  return if !$bag.has?(:POKENAV)    # Can't register without a PokéNav
  return false if !GameData::TrainerType.exists?(trainertype)
  trainertype = GameData::TrainerType.get(trainertype).id
  contact = pbFindPhoneTrainer(trainertype, trainername)
  return if contact && contact[0]              # Existing contact and is visible
  message = _INTL("Let me register you.") if !message
  return if !pbConfirmMessage(message)
  displayname = _INTL("{1} {2}", GameData::TrainerType.get(trainertype).name,
                      pbGetMessageFromHash(MessageTypes::TrainerNames, trainername))
  if contact                          # Previously registered, just make visible
    contact[0] = true
  else                                                         # Add new contact
    pbPhoneRegister(event, trainertype, trainername)
    pbPhoneIncrement(trainertype, trainername, maxbattles)
  end
  pbMessage(_INTL("\\me[Register phone]Registered {1} in the PokéNav.", displayname))
end
#===============================================================================
# Phone register Delete NPCs
#===============================================================================
def pbPhoneDeleteNPC(ident,name,mapid,showmessage=true) #edited by Telemetius
  if !$PokemonGlobal.phoneNumbers
    $PokemonGlobal.phoneNumbers=[]
  end
  exists=pbFindPhoneTrainer(ident,name)
  if exists
      exists[0]=false
  else
    phonenum=[]
    phonenum.push(false)  
    phonenum.push(ident)
    phonenum.push(name) 
    phonenum.push(mapid)
  end
  $PokemonGlobal.phoneNumbers.delete(phonenum)
end
#===============================================================================
# Phone register Modify NPCs (Change Map ID with Flag)
#===============================================================================
def pbPhoneModifyNPCmap(ident, name, new_mapid, showmessage = true, flag = "") #edited by Telemetius
  if !$PokemonGlobal.phoneNumbers
    $PokemonGlobal.phoneNumbers = []
  end

  existing_trainer = pbFindPhoneTrainer_with_flag(ident, name, flag)
  if existing_trainer
    existing_trainer[3] = new_mapid
  else
    phonenum = []
    phonenum.push(false)  
    phonenum.push(ident)
    phonenum.push(name) 
    phonenum.push(new_mapid)
    phonenum.push(flag)
    $PokemonGlobal.phoneNumbers.push(phonenum)
  end
end

def pbFindPhoneTrainer_with_flag(tr_type, tr_name, flag = "")
  return nil if !$PokemonGlobal.phoneNumbers
  $PokemonGlobal.phoneNumbers.each do |num|
    return num if num[1] == tr_type && num[2] == tr_name && num[4] == flag # If a match with the flag
  end
  return nil
end
