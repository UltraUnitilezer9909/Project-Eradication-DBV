#===============================================================================
# * Pokegear Notebook Button
#===============================================================================

MenuHandlers.add(:pokegear_menu, :open_notes, {
  "name"      => _INTL("Notebook"),
  "icon_name" => "map",
  "order"     => 30,
  "effect"    => proc { |menu|
    pbNoteBg
    next false
  }
})