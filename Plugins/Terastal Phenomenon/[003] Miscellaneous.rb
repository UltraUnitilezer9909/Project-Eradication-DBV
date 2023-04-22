#-------------------------------------------------------------------------------
# Player Tera methods.
#-------------------------------------------------------------------------------
class Player < Trainer
  attr_accessor :tera_charged
  
  def tera_charged?
    return true if @tera_charged.nil?
    return @tera_charged
  end
  
  def tera_charged=(value)
    @tera_charged = value
  end
  
  def has_pokemon_tera_type?(type)
    return false if !GameData::Type.exists?(type)
    type = GameData::Type.get(type).id
    return pokemon_party.any? { |p| p&.tera_type == type }
  end
  
  alias tera_initialize initialize
  def initialize(*args)
    tera_initialize(*args)
    @tera_charged = true
  end
end


#-------------------------------------------------------------------------------
# Recharges Tera Orb when healing at a Pokemon Center.
#-------------------------------------------------------------------------------
class Interpreter
  alias tera_command_314 command_314
  def command_314
    $player.tera_charged = true
    return tera_command_314
  end
end


#-------------------------------------------------------------------------------
# Used to display Tera Types in the Summary/Storage.
#-------------------------------------------------------------------------------
class PokemonSummary_Scene
  alias tera_drawPageOne drawPageOne
  def drawPageOne
    tera_drawPageOne
    if Settings::SUMMARY_TERA_TYPES
      overlay = @sprites["overlay"].bitmap
      coords = (PluginManager.installed?("BW Summary Screen")) ? [122, 129] : [330, 143]
      pbDisplayTeraType(@pokemon, overlay, coords[0], coords[1])
    end
  end
end

def pbDisplayTeraType(pokemon, overlay, xpos, ypos)
  type_number = GameData::Type.get(pokemon.tera_type).icon_position
  tera_rect = Rect.new(0, type_number * 32, 32, 32)
  terabitmap = AnimatedBitmap.new(_INTL("Graphics/Plugins/Terastal Phenomenon/tera_types"))
  overlay.blt(xpos, ypos, terabitmap.bitmap, tera_rect)
end


#-------------------------------------------------------------------------------
# Sprite data for Terastal sprite patterns.
#-------------------------------------------------------------------------------
class Sprite
  def applyTera
    self.unDynamax
    return if !Settings::SHOW_TERA_OVERLAY
    self.pattern = Bitmap.new("Graphics/Plugins/Terastal Phenomenon/tera_pattern")
    self.pattern_opacity = 150
    rand1 = rand(5) - 2
    rand2 = rand(5) - 2
    self.pattern_scroll_x += rand1 * 5
    self.pattern_scroll_y += rand2 * 5
  end
  
  def unTera
    self.pattern = nil
  end
  
  def applyTeraIcon
    self.unDynamax
    if Settings::SHOW_TERA_OVERLAY && self.pokemon&.tera?
      self.pattern = Bitmap.new("Graphics/Plugins/Terastal Phenomenon/tera_pattern")
      self.pattern_opacity = 150
      rand1 = rand(5) - 2
      rand2 = rand(5) - 2
      self.pattern_scroll_x += rand1 * 5
      self.pattern_scroll_y += rand2 * 5
    else
      self.unTera
    end
  end
end


#-------------------------------------------------------------------------------
# Ability - Color Change
# Type cannot be changed if the user is Terastallized.
#-------------------------------------------------------------------------------
Battle::AbilityEffects::AfterMoveUseFromTarget.add(:COLORCHANGE,
  proc { |ability, target, user, move, switched_battlers, battle|
    next if target.tera?
    next if target.damageState.calcDamage == 0 || target.damageState.substitute
    next if !move.calcType || GameData::Type.get(move.calcType).pseudo_type
    next if target.pbHasType?(move.calcType) && !target.pbHasOtherType?(move.calcType)
    typeName = GameData::Type.get(move.calcType).name
    battle.pbShowAbilitySplash(target)
    target.pbChangeTypes(move.calcType)
    battle.pbDisplay(_INTL("{1}'s type changed to {2} because of its {3}!",
       target.pbThis, typeName, target.abilityName))
    battle.pbHideAbilitySplash(target)
  }
)


#-------------------------------------------------------------------------------
# Ability - Mimicry
# Type cannot be changed if the user is Terastallized.
#-------------------------------------------------------------------------------
Battle::AbilityEffects::OnTerrainChange.add(:MIMICRY,
  proc { |ability, battler, battle, ability_changed|
    next if battler.tera?
    if battle.field.terrain == :None
      battle.pbShowAbilitySplash(battler)
      battler.pbResetTypes
      battle.pbDisplay(_INTL("{1} changed back to its regular type!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
    else
      terrain_hash = {
        :Electric => :ELECTRIC,
        :Grassy   => :GRASS,
        :Misty    => :FAIRY,
        :Psychic  => :PSYCHIC
      }
      new_type = terrain_hash[battle.field.terrain]
      new_type_name = nil
      if new_type
        type_data = GameData::Type.try_get(new_type)
        new_type = nil if !type_data
        new_type_name = type_data.name if type_data
      end
      if new_type
        battle.pbShowAbilitySplash(battler)
        battler.pbChangeTypes(new_type)
        battle.pbDisplay(_INTL("{1}'s type changed to {2}!", battler.pbThis, new_type_name))
        battle.pbHideAbilitySplash(battler)
      end
    end
  }
)