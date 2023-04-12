#===============================================================================
# Additions to the Battle:Battler class.
#===============================================================================
class Battle::Battler
  attr_reader   :tera_type
  attr_accessor :tera_boss
  
  #-----------------------------------------------------------------------------
  # Initializing Tera attributes.
  #-----------------------------------------------------------------------------
  alias tera_pbInitBlank pbInitBlank
  def pbInitBlank
    tera_pbInitBlank
    @tera_type = nil
    @tera_boss = false
  end
  
  alias tera_pbInitDummyPokemon pbInitDummyPokemon
  def pbInitDummyPokemon(pkmn, idxParty)
    tera_pbInitDummyPokemon(pkmn, idxParty)
    @tera_type = pkmn.tera_type
    @tera_boss = false
  end
  
  alias tera_pbInitPokemon pbInitPokemon
  def pbInitPokemon(pkmn, idxParty)
    tera_pbInitPokemon(pkmn, idxParty)
    @tera_type = pkmn.tera_type
    @tera_boss = (self.wild? && pkmn.ace?)
  end
  
  alias tera_pbTypes pbTypes
  def pbTypes(withType3 = false)
    return [@tera_type] if tera?
    return tera_pbTypes(withType3)
  end
  
  #-----------------------------------------------------------------------------
  # Terastallization
  #-----------------------------------------------------------------------------
  # Lower priority than:
  #   -Primal Reversion
  #   -Zodiac Powers
  #   -Ultra Burst
  #   -Z-Moves
  #   -Mega Evolution
  #   -Dynamax
  #   -Battle Styles
  #-----------------------------------------------------------------------------
  def hasTera?
    return false if shadowPokemon?
    return false if mega? || primal? || ultra? || dynamax? || inStyle? || tera? || celestial?
    return false if hasMega? || hasPrimal? || hasZMove? || hasUltra? || hasDynamaxAvail? || hasStyles? || hasZodiacPower?
    return !@pokemon&.tera_type.nil?
  end
  
  def tera?; return @pokemon&.tera?; end
  
  #-----------------------------------------------------------------------------
  # Un-Terastallizes. When teraBreak = true, shows more dramatic animation.
  #-----------------------------------------------------------------------------
  def unTera(teraBreak = false)
    @pokemon.terastallized = false
    @battle.scene.pbRefreshOne(@index)
    @battle.scene.pbRevertTera(@index, teraBreak)
  end
  
  #-----------------------------------------------------------------------------
  # Un-Terastallizes wild Tera Pokemon after reaching HP threshold.
  #-----------------------------------------------------------------------------
  alias tera_pbEffectsAfterMove pbEffectsAfterMove
  def pbEffectsAfterMove(*args)
    args[1].each do |b|
      next if !b || b.fainted?
      next unless b.tera? && b.tera_boss && b.hp <= (b.totalhp / 6)
      b.unTera(true)
      @battle.disablePokeBalls = false
      @battle.pbDisplayPaused(_INTL("{1}'s Tera Jewel shattered!\nIt may now be captured!", b.pbThis))
    end
    tera_pbEffectsAfterMove(*args)
  end
  
  #-----------------------------------------------------------------------------
  # Effects that change type fail if user is Terastallized.
  #-----------------------------------------------------------------------------
  alias tera_canChangeType? canChangeType?
  def canChangeType?
    return false if tera?
    return tera_canChangeType?
  end
  
  alias tera_pbHasOtherType? pbHasOtherType?
  def pbHasOtherType?(type)
    return false if tera?
    return tera_pbHasOtherType?(type)
  end
  
  alias tera_pbChangeTypes pbChangeTypes
  def pbChangeTypes(newType)
    if newType.is_a?(Battle::Battler) && newType.tera?
      newTypes = newType.pokemon.types
      @types = newTypes.clone
      @effects[PBEffects::Type3] = nil
      @effects[PBEffects::BurnUp] = false
      @effects[PBEffects::Roost]  = false
      if defined?(PBEffects::DoubleShock)
        @effects[PBEffects::DoubleShock] = false
      end
    else
      tera_pbChangeTypes(newType)
    end
  end
end


#===============================================================================
# New Pokemon properties.
#===============================================================================
class Pokemon
  attr_accessor :tera_type
  attr_accessor :terastallized
  
  #-----------------------------------------------------------------------------
  # Tera state.
  #-----------------------------------------------------------------------------
  def tera?
    return @terastallized || false
  end
  
  def terastallize=(value)
    @terastallized = (dynamax?) ? false : value
  end
  
  #-----------------------------------------------------------------------------
  # Tera type.
  #-----------------------------------------------------------------------------
  def tera_type
    if !@tera_type
      @tera_type = species_data.types.sample
    end
    return @tera_type
  end
  
  def tera_type=(value)
    if GameData::Type.exists?(value) && ![:QMARKS, :SHADOW].include?(value)
      @tera_type = value
    end
  end
  
  alias tera_initialize initialize  
  def initialize(*args)
    @tera_type = GameData::Species.get(args[0]).types.sample
    @terastallized = false
    tera_initialize(*args)
  end
end