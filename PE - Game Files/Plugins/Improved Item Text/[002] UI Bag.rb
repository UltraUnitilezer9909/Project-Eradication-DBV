#-------------------------------------------------------------------------------
# Item display text in the Bag screen.
#-------------------------------------------------------------------------------
class PokemonBagScreen
  if !PluginManager.installed?("Bag Screen w/int. Party")
    def pbStartScreen
      @scene.pbStartScene(@bag)
      item = nil
      loop do
        item = @scene.pbChooseItem
        break if !item
        itm = GameData::Item.get(item)
        cmdRead     = -1
        cmdUse      = -1
        cmdRegister = -1
        cmdGive     = -1
        cmdToss     = -1
        cmdDebug    = -1
        commands = []
        commands[cmdRead = commands.length] = _INTL("Read") if itm.is_mail?
        if ItemHandlers.hasOutHandler(item) || (itm.is_machine? && $player.party.length > 0)
          if ItemHandlers.hasUseText(item)
            commands[cmdUse = commands.length]    = ItemHandlers.getUseText(item)
          else
            commands[cmdUse = commands.length]    = _INTL("Use")
          end
        end
        commands[cmdGive = commands.length]       = _INTL("Give") if $player.pokemon_party.length > 0 && itm.can_hold?
        commands[cmdToss = commands.length]       = _INTL("Toss") if !itm.is_important? || $DEBUG
        if @bag.registered?(item)
          commands[cmdRegister = commands.length] = _INTL("Deselect")
        elsif pbCanRegisterItem?(item)
          commands[cmdRegister = commands.length] = _INTL("Register")
        end
        commands[cmdDebug = commands.length]      = _INTL("Debug") if $DEBUG
        commands[commands.length]                 = _INTL("Cancel")
        itemname = itm.name
        command = @scene.pbShowCommands(_INTL("{1} is selected.", itemname), commands)
        if cmdRead >= 0 && command == cmdRead
          pbFadeOutIn {
            pbDisplayMail(Mail.new(item, "", ""))
          }
        elsif cmdUse >= 0 && command == cmdUse
          ret = pbUseItem(@bag, item, @scene)
          break if ret == 2
          @scene.pbRefresh
          next
        elsif cmdGive >= 0 && command == cmdGive
          if $player.pokemon_count == 0
            @scene.pbDisplay(_INTL("There is no Pokémon."))
          elsif itm.is_important?
            @scene.pbDisplay(_INTL("The {1} can't be held.", itm.portion_name))
          else
            pbFadeOutIn {
              sscene = PokemonParty_Scene.new
              sscreen = PokemonPartyScreen.new(sscene, $player.party)
              sscreen.pbPokemonGiveScreen(item)
              @scene.pbRefresh
            }
          end
        elsif cmdToss >= 0 && command == cmdToss
          qty = @bag.quantity(item)
          if qty > 1
            helptext = _INTL("Toss out how many {1}?", itm.portion_name_plural)
            qty = @scene.pbChooseNumber(helptext, qty)
          end
          if qty > 0
            itemname = (qty > 1) ? itm.portion_name_plural : itm.portion_name
            if pbConfirm(_INTL("Is it OK to throw away {1} {2}?", qty, itemname))
              pbDisplay(_INTL("Threw away {1} {2}.", qty, itemname))
              qty.times { @bag.remove(item) }
              @scene.pbRefresh
            end
          end
        elsif cmdRegister >= 0 && command == cmdRegister
          if @bag.registered?(item)
            @bag.unregister(item)
          else
            @bag.register(item)
          end
          @scene.pbRefresh
        elsif cmdDebug >= 0 && command == cmdDebug
          command = 0
          loop do
            command = @scene.pbShowCommands(_INTL("Do what with {1}?", itemname),
                                            [_INTL("Change quantity"),
                                             _INTL("Make Mystery Gift"),
                                             _INTL("Cancel")], command)
            case command
            when -1, 2
              break
            when 0
              qty = @bag.quantity(item)
              itemplural = itm.name_plural
              params = ChooseNumberParams.new
              params.setRange(0, Settings::BAG_MAX_PER_SLOT)
              params.setDefaultValue(qty)
              newqty = pbMessageChooseNumber(
                _INTL("Choose new quantity of {1} (max. #{Settings::BAG_MAX_PER_SLOT}).", itemplural), params
              ) { @scene.pbUpdate }
              if newqty > qty
                @bag.add(item, newqty - qty)
              elsif newqty < qty
                @bag.remove(item, qty - newqty)
              end
              @scene.pbRefresh
              break if newqty == 0
            when 1
              pbCreateMysteryGift(1, item)
            end
          end
        end
      end
      ($game_temp.fly_destination) ? @scene.dispose : @scene.pbEndScene
      return item
    end
    
    def pbWithdrawItemScreen
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      storage = $PokemonGlobal.pcItemStorage
      @scene.pbStartScene(storage)
      loop do
        item = @scene.pbChooseItem
        break if !item
        itm = GameData::Item.get(item)
        qty = storage.quantity(item)
        if qty > 1 && !itm.is_important?
          qty = @scene.pbChooseNumber(_INTL("How many do you want to withdraw?"), qty)
        end
        next if qty <= 0
        if @bag.can_add?(item, qty)
          if !storage.remove(item, qty)
            raise "Can't delete items from storage"
          end
          if !@bag.add(item, qty)
            raise "Can't withdraw items from storage"
          end
          @scene.pbRefresh
          dispqty = (itm.is_important?) ? 1 : qty
          itemname = (dispqty > 1) ? itm.portion_name_plural : itm.portion_name
          pbDisplay(_INTL("Withdrew {1} {2}.", dispqty, itemname))
        else
          pbDisplay(_INTL("There's no more room in the Bag."))
        end
      end
      @scene.pbEndScene
    end
  
    def pbDepositItemScreen
      @scene.pbStartScene(@bag)
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      storage = $PokemonGlobal.pcItemStorage
      loop do
        item = @scene.pbChooseItem
        break if !item
        itm = GameData::Item.get(item)
        qty = @bag.quantity(item)
        if qty > 1 && !itm.is_important?
          qty = @scene.pbChooseNumber(_INTL("How many do you want to deposit?"), qty)
        end
        if qty > 0
          if storage.can_add?(item, qty)
            if !@bag.remove(item, qty)
              raise "Can't delete items from Bag"
            end
            if !storage.add(item, qty)
              raise "Can't deposit items to storage"
            end
            @scene.pbRefresh
            dispqty  = (itm.is_important?) ? 1 : qty
            itemname = (dispqty > 1) ? itm.portion_name_plural : itm.portion_name
            pbDisplay(_INTL("Deposited {1} {2}.", dispqty, itemname))
          else
            pbDisplay(_INTL("There's no room to store items."))
          end
        end
      end
      @scene.pbEndScene
    end
  
    def pbTossItemScreen
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      storage = $PokemonGlobal.pcItemStorage
      @scene.pbStartScene(storage)
      loop do
        item = @scene.pbChooseItem
        break if !item
        itm = GameData::Item.get(item)
        if itm.is_important?
          @scene.pbDisplay(_INTL("That's too important to toss out!"))
          next
        end
        qty = storage.quantity(item)
        itemname       = itm.portion_name
        itemnameplural = itm.portion_name_plural
        if qty > 1
          qty = @scene.pbChooseNumber(_INTL("Toss out how many {1}?", itemnameplural), qty)
        end
        next if qty <= 0
        itemname = itemnameplural if qty > 1
        next if !pbConfirm(_INTL("Is it OK to throw away {1} {2}?", qty, itemname))
        if !storage.remove(item, qty)
          raise "Can't delete items from storage"
        end
        @scene.pbRefresh
        pbDisplay(_INTL("Threw away {1} {2}.", qty, itemname))
      end
      @scene.pbEndScene
    end
  end
end