#===============================================================================
# * Notebook Settings
#===============================================================================

module NoteConfig
  # The number of notes that can be stored.
  NUM_NOTE_STORAGE = 100

  # The species of the pokemon used to create the note. It'll be erased after the note is created.
  POKEMON = :BULBASAUR

  # A list of the id of the mails to be used for the notes
  NOTES_BACKGROUND = [
    :BRIDGETMAIL, :BRIDGEDMAIL, :BRIDGESMAIL, :BRIDGEVMAIL, :BRIDGEMMAIL, :FAVOREDMAIL, :THANKSMAIL,
    :INQUIRYMAIL, :GREETMAIL, :RSVPMAIL, :LIKEMAIL, :REPLYMAIL
  ]

  # The path for the background to use for the pokegear scene.
  # Note: If you are using my pokegear theme's plugin, keep the path up to the pokegear folder.
  BACKGROUND = "bg"
  BACKGROUND_PATH = "Graphics/Pictures/Pokegear/"

  # Set to true if you want the background to change with the pokegear themes
  THEME_CHANGE = true
end