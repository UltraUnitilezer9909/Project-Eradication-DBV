# Adds menu button to pokenav menu but could be used elsewhere
MenuHandlers.add(:pokenav_menu, :Phone, {
  "name"      => _INTL("Match call"),
  "icon_name" => "mail",
  "order"     => 70,
  "effect"    => proc { |_menu|
    # Check if phoneNumbers is empty
    empty_mailbox = $PokemonGlobal.phoneNumbers.nil? || $PokemonGlobal.phoneNumbers.empty?
    if empty_mailbox
      pbMessage(_INTL("Your mailbox is empty."))
    else
      scene = PokemonPokenavPhone_Scene.new
      screen = PokemonPokenavPhoneScreen.new(scene)
      screen.pbStartScreen
    end
  }
})