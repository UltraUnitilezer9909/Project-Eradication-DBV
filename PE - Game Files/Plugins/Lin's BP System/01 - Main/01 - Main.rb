#===============================================================================
# * Main
#===============================================================================

module GameData
  class Item
    attr_reader :bp_price

    SCHEMA["BPPrice"] = [:bp_price, "u"]

    alias bp_initialize initialize
    def initialize(hash)
      bp_initialize(hash)
      @bp_price = hash[:bp_price] || @price
    end
  end

  class TrainerType
    attr_reader :base_bp

    SCHEMA["BaseBP"] = [:base_bp, "u"]

    alias bp_initialize initialize
    def initialize(hash)
      bp_initialize(hash)
      @base_bp = hash[:base_bp] || @base_money
    end
  end
end

def pbTrainerTypeEditor
  gender_array = []
  GameData::TrainerType::SCHEMA["Gender"][2].each { |key, value| gender_array[value] = key if !gender_array[value] }
  trainer_type_properties = [
    [_INTL("ID"),         ReadOnlyProperty,               _INTL("ID of this Trainer Type (used as a symbol like :XXX).")],
    [_INTL("Name"),       StringProperty,                 _INTL("Name of this Trainer Type as displayed by the game.")],
    [_INTL("Gender"),     EnumProperty.new(gender_array), _INTL("Gender of this Trainer Type.")],
    [_INTL("BaseMoney"),  LimitProperty.new(9999),        _INTL("Player earns this much money times the highest level among the trainer's Pokémon.")],
	[_INTL("BaseBP"),     LimitProperty.new(9999),        _INTL("Player earns this much BP times the highest level among the trainer's Pokémon.")],
    [_INTL("SkillLevel"), LimitProperty.new(9999),        _INTL("Skill level of this Trainer Type.")],
    [_INTL("Flags"),      StringListProperty,             _INTL("Words/phrases that can be used to make trainers of this type behave differently to others.")],
    [_INTL("IntroBGM"),   BGMProperty,                    _INTL("BGM played before battles against trainers of this type.")],
    [_INTL("BattleBGM"),  BGMProperty,                    _INTL("BGM played in battles against trainers of this type.")],
    [_INTL("VictoryBGM"), BGMProperty,                    _INTL("BGM played when player wins battles against trainers of this type.")]
  ]
  pbListScreenBlock(_INTL("Trainer Types"), TrainerTypeLister.new(0, true)) { |button, tr_type|
    if tr_type
      case button
      when Input::ACTION
        if tr_type.is_a?(Symbol) && pbConfirmMessageSerious("Delete this trainer type?")
          GameData::TrainerType::DATA.delete(tr_type)
          GameData::TrainerType.save
          pbConvertTrainerData
          pbMessage(_INTL("The Trainer type was deleted."))
        end
      when Input::USE
        if tr_type.is_a?(Symbol)
          t_data = GameData::TrainerType.get(tr_type)
          data = [
            t_data.id.to_s,
            t_data.real_name,
            t_data.gender,
            t_data.base_money,
            t_data.base_bp,
            t_data.skill_level,
            t_data.flags,
            t_data.intro_BGM,
            t_data.battle_BGM,
            t_data.victory_BGM
          ]
          if pbPropertyList(t_data.id.to_s, data, trainer_type_properties, true)
            # Construct trainer type hash
            type_hash = {
              :id          => t_data.id,
              :name        => data[1],
              :gender      => data[2],
              :base_money  => data[3],
              :base_bp     => data[4],
              :skill_level => data[5],
              :flags       => data[6],
              :intro_BGM   => data[7],
              :battle_BGM  => data[8],
              :victory_BGM => data[9]
            }
            # Add trainer type's data to records
            GameData::TrainerType.register(type_hash)
            GameData::TrainerType.save
            pbConvertTrainerData
          end
        else   # Add a new trainer type
          pbTrainerTypeEditorNew(nil)
        end
      end
    end
  }
end

class Trainer
  def base_bp; return GameData::TrainerType.get(self.trainer_type).base_bp; end
end

def pbActiveCharm(charm)
  if PluginManager.installed?("Charms Compilation") || PluginManager.installed?("Charms Case")
    return $player.activeCharm?(charm)
  else
    return $bag.has?(charm)
  end
end