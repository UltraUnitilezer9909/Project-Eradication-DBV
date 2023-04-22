#===============================================================================
# New Pokemon::Move properties to check for move mastery.
#===============================================================================
class Pokemon
  attr_accessor :mastered_moves
  
  alias styles_initialize initialize
  def initialize(*args)
    styles_initialize(*args)
    @mastered_moves = []
  end
  
  #-----------------------------------------------------------------------------
  # Returns an array of every move this Pokemon has mastered.
  #-----------------------------------------------------------------------------
  def mastered_moves
    return @mastered_moves || []
  end
  
  #-----------------------------------------------------------------------------
  # Adds the inputted move ID to the array of mastered moves.
  #-----------------------------------------------------------------------------
  def register_mastered_move(move)
    if !@mastered_moves
      @mastered_moves = [move]
    elsif !@mastered_moves.include?(move)
      @mastered_moves.push(move)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Masters the inputted move ID or move index that appears in the Pokemon's moveset.
  #-----------------------------------------------------------------------------
  def master_move(id)
    if id.is_a?(Symbol)
      return if !GameData::Move.exists?(id)
      @moves.each_with_index { |m, i| id = i if id == m.id }
    end
    move = @moves[id]
    return if !move || !move.canMaster?
    move.mastered = true
    register_mastered_move(move.id)
  end
  
  #-----------------------------------------------------------------------------
  # Masters the Pokemon's entire moveset.
  #-----------------------------------------------------------------------------
  def master_moveset
    @moves.length.times { |i| self.master_move(i) }
  end
  
  #-----------------------------------------------------------------------------
  # Rechecks if any of the moves in a Pokemon's moveset should be mastered.
  #-----------------------------------------------------------------------------
  def refresh_mastery
    @moves.each { |m| m.mastered = self.mastered_moves.include?(m.id)}
  end
  
  #-----------------------------------------------------------------------------
  # Refreshes mastery checks whenever the Pokemon learns a new move.
  #-----------------------------------------------------------------------------
  alias styles_learn_move learn_move
  def learn_move(move_id)
    styles_learn_move(move_id)
    refresh_mastery
  end
  
  
  #-----------------------------------------------------------------------------
  # The Pokemon::Move class.
  #-----------------------------------------------------------------------------
  class Move
    attr_accessor :mastered
    
    alias style_initialize initialize
    def initialize(move_id)
      style_initialize(move_id)
      @mastered = false
    end
	
    def mastered=(value)
	  return if !canMaster?
      @mastered = value
    end
    
    def mastered?;  return @mastered; end
    def canMaster?; return !flags.any? { |f| f[/^CantMaster$/i] }; end
  end
end


#===============================================================================
# Additions to Battle::Move to change move properties depending on style.
#===============================================================================
class Battle::Move
  attr_accessor :mastered
  attr_accessor :baseDamage, :accuracy, :addlEffect
  attr_accessor :old_baseDamage, :old_accuracy, :old_addlEffect
  
  alias styles_initialize initialize
  def initialize(battle, move)
    styles_initialize(battle, move)
    @mastered       = move.mastered
    @old_baseDamage = move.base_damage
    @old_accuracy   = move.accuracy
    @old_addlEffect = move.effect_chance
  end
  
  def mastered?;            return @mastered; end
  def canMaster?;           return !@flags.any? { |f| f[/^CantMaster$/i] }; end
  
  #-----------------------------------------------------------------------------
  # Flags certain moves if certain styles affect the attributes of the move.
  #-----------------------------------------------------------------------------
  def strongStyleStatUp?;   return false; end
  def agileStyleStatUp?;    return false; end
  def strongStyleStatDown?; return false; end
  def agileStyleStatDown?;  return false; end
  def strongStyleHealing?;  return false; end
  def agileStyleHealing?;   return false; end
  def strongStyleRecoil?;   return false; end
  def agileStyleRecoil?;    return false; end
  
  #-----------------------------------------------------------------------------
  # Calculates the number of stages to apply for moves that change stats.
  #-----------------------------------------------------------------------------
  def pbStage(user, num)
    return num if !mastered 
    case user.battle_style
    when 0 then stage = num
    when 1 then stage = [num + 1, 6].min
    when 2 then stage = [num - 1, 1].max
    end
    return stage
  end
  
  #-----------------------------------------------------------------------------
  # Calculates the attributes of a move when used in Strong or Agile styles.
  #-----------------------------------------------------------------------------
  def calc_style_changes(style)
    return if !mastered?
    case style
    when 0, "None"
      @addlEffect = @old_addlEffect
      @accuracy   = @old_accuracy
      @baseDamage = @old_baseDamage
      return
    when 1, "Strong"
      #-------------------------------------------------------------------------
      # Boosts effect chance.
      #-------------------------------------------------------------------------
      if @addlEffect > 0
        if @id == :DIRECLAW 
          @addlEffect += 30
        elsif @addlEffect >= 50
          @addlEffect = 100
        else
          @addlEffect += 20
        end
        @addlEffect = 100 if @addlEffect > 100
      end
      #-------------------------------------------------------------------------
      # Boosts accuracy.
      #-------------------------------------------------------------------------
      if @accuracy > 0
        if @category == 2
          if @accuracy >= 80
            @accuracy = 100
          else 
            @accuracy += 20
          end
        elsif @id == :SEEDFLARE
          @accuracy = 100
        elsif @accuracy >= 90
          @accuracy = 100
        elsif @accuracy >= 80
          @accuracy += 10
        else  
          @accuracy += 15
        end
        @accuracy = 100 if @accuracy > 100
      end
    end
    #---------------------------------------------------------------------------
    # Calculates damage changes for each style.
    #---------------------------------------------------------------------------
    if @category < 2 && @baseDamage > 1
      case @id
      when :OCTAZOOKA
        str_dmg = @baseDamage + 35
        agi_dmg = @baseDamage - 25
      when :HIDDENPOWER, :VOLTTACKLE, :STEELBEAM, :CHLOROBLAST
        str_dmg = @baseDamage + 20
        agi_dmg = @baseDamage - 20
      when :SPACIALREND
        str_dmg = @baseDamage + 20
        agi_dmg = @baseDamage - 15
      else
        case function
        when "MultiTurnAttackConfuseUserAtEnd"
          str_dmg = @baseDamage + 30
          agi_dmg = @baseDamage - 30
        else
          if @baseDamage >= 150
            str_dmg = @baseDamage + 50
            agi_dmg = @baseDamage - 30
          elsif @baseDamage >= 120
            str_dmg = @baseDamage + 30
            agi_dmg = @baseDamage - 20
          elsif @baseDamage >= 80
            str_dmg = @baseDamage + 20
            agi_dmg = @baseDamage - 20
          elsif @baseDamage >= 60
            str_dmg = @baseDamage + 15
            agi_dmg = @baseDamage - 15
          elsif @baseDamage >= 20
            str_dmg = @baseDamage + 10
            agi_dmg = @baseDamage - 10
          else
            str_dmg = @baseDamage + 5
            agi_dmg = @baseDamage - 5
          end
        end
        agi_dmg = 5 if agi_dmg <= 0
      end
      case style
      when 0, "None"   then @baseDamage = @old_baseDamage
      when 1, "Strong" then @baseDamage = str_dmg
      when 2, "Agile"  then @baseDamage = agi_dmg
      end
    end
  end
end