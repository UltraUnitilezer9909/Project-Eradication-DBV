#To set up your Field Effects, first register your Field Effect in the Field Effects Main script.
#Then, fill in the information below for each of your field effects, and if your field effects have custom intro scripts
#you will need to define them in the pbStartBattleCore script in the Main file. Just search for these items in the script
#to add custom effects if you so wish.

FIELD_EFFECTS = {
		:None => {
			:field_name => "None",
			:intro_message => "Default message, change to nil when implementing", #message shown when field is active
			:field_gfx => "default image, change to nil if none", #image file name without the file extension
			:nature_power => :TRIATTACK,
			:mimicry => :NORMAL, #what type Camouflage/Mimicry will change you to
			:intro_script => nil, #a script that runs at the beginning of the battle
			#structure: "script name"
			:abilities => [], #abilities affected by this field
			:ability_effects => {}, #specific effects abilities trigger a stat boost that are not their normal effect.
			#ability effects data structure: Ability => [stat,amount boosted] example: :WATERVEIL -> [:EVASION,1]
			:move_damage_boost => {}, #if a move gets a power buff or nerf
			#structure: modifier => [move] i.e 1.2 => [:EARTHQUAKE]
			:move_messages => {}, #message the move getting the power change shows
			#structure: "message" => [move]
			:move_type_change => {}, #if a move changes type
			#structure: type => [move]
			:move_type_mod => {}, #if a move adds a type
			#structure: type => [move]
			:move_accuracy_change => {}, #if a move changes accuracy
			#structure = newAccuracy => [move]
			:defensive_modifiers => {}, #structure = modifier => [type,flag] where flag sets the kind of modifier.
			#flags are: physical, special, fullhp. fullhp flag cuts damage by the 1/modifier. other flags multiply def mods.
			#example: 2 => [:GHOST, "fullhp"] would make it so ghost types take 1/2 damage from full
			:type_damage_change => {}, #if a type gets a power buff or nerf
			#structure = modifier => [type] (i.e 1.2 => [:DRAGON] would boost dragon moves by 1.2 in this field)
			:type_messages => {}, #the message that shows when a type gets a buff or nerf
			#structure: "message" => [type]
			:type_type_mod => {}, #if a type gets added to a matchup based on the move type used due to the field
			#structure: addedType => [originalType]
			:type_mod_message => {}, #the message that shows if a type of move adds a type
			#structure: "message" => [oldType]
			:type_type_change => {}, #if a type changes due to the field
			#structure: newType => [oldType]
			:type_change_message => {}, #the message that shows if a type of move changes type
			#structure: "message" => [oldType]
			:side_effects => {}, #special effects activated when using certain moves or types, using flags as condition references
			#structure: "flag" => [move or type]
			:field_changers => {}, #moves or types that change the field
			#structure: newField => [type or move]
			:change_message => {}, #message that shows when the field changes
			#structure => "message" => [type or move]
			:field_change_conditions => {} #optional conditions that your field can change under
			#example would be if your field can only change in certain weather
			#structure: newField => condition
			#note: condition must be a method that can be run to check if the conditions are met
			#major note: all things in brackets MUST stay in brackets when used in these sections, or the script
			#will fail
		}
	}