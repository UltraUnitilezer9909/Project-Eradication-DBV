#===============================================================================
# * Notebook Item
#===============================================================================

ItemHandlers::UseInField.add(:NOTEBOOK, proc { |item, scene|
    commandRobe = pbMessage(
          _INTL("What do you want to do?"),
          [_INTL("Write a note"),
           _INTL("Open the notebook"),
           _INTL("Cancel")], -1
        )
        case commandRobe
        when 0   # Write
          writeNote
        when 1   # Open
          pbPCNotebook
        end
})