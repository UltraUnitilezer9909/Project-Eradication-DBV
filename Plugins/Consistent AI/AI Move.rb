class Battle::AI
    #=============================================================================
    # Main move-choosing method (moves with higher scores are more likely to be
    # chosen)
    #=============================================================================
    def pbChooseMoves(idxBattler)
      user        = @battle.battlers[idxBattler]
      wildBattler = user.wild?
      skill       = 0
      if !wildBattler
        skill     = @battle.pbGetOwnerFromBattlerIndex(user.index).skill_level || 0
      end
      # Get scores and targets for each move
      # NOTE: A move is only added to the choices array if it has a non-zero
      #       score.
      choices     = []
      user.eachMoveWithIndex do |_m, i|
        next if !@battle.pbCanChooseMove?(idxBattler, i, false)
        if wildBattler
          pbRegisterMoveWild(user, i, choices)
        else
          pbRegisterMoveTrainer(user, i, choices, skill)
        end
      end
      Console.echo_h2(choices)
      # Figure out useful information about the choices
      totalScore = 0
      maxScore   = 0
      choices.each do |c|
        totalScore += c[1]
        maxScore = c[1] if maxScore < c[1]
      end
      # Log the available choices
      if $INTERNAL
        logMsg = "[AI] Move choices for #{user.pbThis(true)} (#{user.index}): "
        choices.each_with_index do |c, i|
          logMsg += "#{user.moves[c[0]].name}=#{c[1]}"
          logMsg += " (target #{c[2]})" if c[2] >= 0
          logMsg += ", " if i < choices.length - 1
        end
        PBDebug.log(logMsg)
      end
      # Find any preferred moves and just choose from them
      if !wildBattler && skill >= PBTrainerAI.highSkill && maxScore > 100
        #stDev = pbStdDev(choices)
        #if stDev >= 40 && pbAIRandom(100) < 90
        # DemICE removing randomness of AI
          preferredMoves = []
          choices.each do |c|
            next if c[1] < 200 && c[1] < maxScore * 0.8
            #preferredMoves.push(c)
            # DemICE prefer ONLY the best move
            preferredMoves.push(c) if c[1] == maxScore   # Doubly prefer the best move
          end
          if preferredMoves.length > 0
            m = preferredMoves[pbAIRandom(preferredMoves.length)]
            PBDebug.log("[AI] #{user.pbThis} (#{user.index}) prefers #{user.moves[m[0]].name}")
            @battle.pbRegisterMove(idxBattler, m[0], false)
            @battle.pbRegisterTarget(idxBattler, m[2]) if m[2] >= 0
            return
          end
        #end
      end
      # Decide whether all choices are bad, and if so, try switching instead
      if !wildBattler && skill >= PBTrainerAI.highSkill
        badMoves = false
        if ((maxScore <= 20 && user.turnCount > 2) ||
           (maxScore <= 40 && user.turnCount > 5)) #&& pbAIRandom(100) < 80  # DemICE removing randomness
          badMoves = true
        end
        if !badMoves && totalScore < 100 && user.turnCount >= 1
          badMoves = true
          choices.each do |c|
            next if !user.moves[c[0]].damagingMove?
            badMoves = false
            break
          end
          #badMoves = false if badMoves && pbAIRandom(100) < 10 # DemICE removing randomness
        end
        if badMoves && pbEnemyShouldWithdrawEx?(idxBattler, true)
          if $INTERNAL
            PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will switch due to terrible moves")
          end
          return
        end
      end
      # If there are no calculated choices, pick one at random
      if choices.length == 0
        PBDebug.log("[AI] #{user.pbThis} (#{user.index}) doesn't want to use any moves; picking one at random")
        user.eachMoveWithIndex do |_m, i|
          next if !@battle.pbCanChooseMove?(idxBattler, i, false)
          choices.push([i, 100, -1])   # Move index, score, target
        end
        if choices.length == 0   # No moves are physically possible to use; use Struggle
          @battle.pbAutoChooseMove(user.index)
        end
      end
      # Randomly choose a move from the choices and register it
      randNum = pbAIRandom(totalScore)
      choices.each do |c|
        randNum -= c[1]
        next if randNum >= 0
        @battle.pbRegisterMove(idxBattler, c[0], false)
        @battle.pbRegisterTarget(idxBattler, c[2]) if c[2] >= 0
        break
      end
      # Log the result
      if @battle.choices[idxBattler][2]
        PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[idxBattler][2].name}")
      end
    end
  
    #=============================================================================
    # Get a score for the given move being used against the given target
    #=============================================================================
    def pbGetMoveScore(move, user, target, skill = 100)
      skill = PBTrainerAI.minimumSkill if skill < PBTrainerAI.minimumSkill
      score = 100
      score = pbGetMoveScoreFunctionCode(score, move, user, target, skill)
      # A score of 0 here means it absolutely should not be used
      return 0 if score <= 0
      # Adjust score based on how much damage it can deal
      # DemICE moved damage calculation to the beginning
      if move.damagingMove?
        score = pbGetMoveScoreDamage(score, move, user, target, skill)
      else   # Status moves
        # Don't prefer attacks which don't deal damage
        score -= 10
        # Account for accuracy of move
        accuracy = pbRoughAccuracy(move, user, target, skill)
        score *= accuracy / 100.0
        score = 0 if score <= 10 && skill >= PBTrainerAI.highSkill
      end
      if skill >= PBTrainerAI.mediumSkill
        # Prefer damaging moves if AI has no more Pokémon or AI is less clever
        if @battle.pbAbleNonActiveCount(user.idxOwnSide) == 0 &&
           !(skill >= PBTrainerAI.highSkill && @battle.pbAbleNonActiveCount(target.idxOwnSide) > 0)
          if move.statusMove?
            score /= 1.5
          elsif target.hp <= target.totalhp / 2
            score *= 1.5
          end
        end
        # Converted all score alterations to multiplicative
        # Don't prefer attacking the target if they'd be semi-invulnerable
        if skill >= PBTrainerAI.highSkill && move.accuracy > 0 &&
           (target.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0)
          miss = true
          miss = false if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
          if miss && pbRoughStat(user, :SPEED, skill) > pbRoughStat(target, :SPEED, skill)
            # Knows what can get past semi-invulnerability
            if target.effects[PBEffects::SkyDrop] >= 0 ||
               target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                       "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                                       "TwoTurnAttackInvulnerableInSkyTargetCannotAct")
              miss = false if move.hitsFlyingTargets?
            elsif target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")
              miss = false if move.hitsDiggingTargets?
            elsif target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderwater")
              miss = false if move.hitsDivingTargets?
            end
          end
          score *= 0.2 if miss
        end
        # Pick a good move for the Choice items
        if user.hasActiveItem?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
           user.hasActiveAbility?(:GORILLATACTICS)
          if move.baseDamage >= 60
            score *= 1.2
          elsif move.damagingMove?
            score *= 1.2
          elsif move.function == "UserTargetSwapItems"
            score *= 1.2  # Trick
          else
            score *= 0.8
          end
        end
        # If user is asleep, prefer moves that are usable while asleep
        if user.status == :SLEEP && !move.usableWhenAsleep? && user.statusCount==1 # DemICE check if it'll wake up this turn
          user.eachMove do |m|
            next unless m.usableWhenAsleep?
            score *= 2
            break
          end
        end
        # If user is frozen, prefer a move that can thaw the user
        if user.status == :FROZEN
          if move.thawsUser?
            score *= 2
          else
            user.eachMove do |m|
              next unless m.thawsUser?
              score *= 0.8
              break
            end
          end
        end
        # If target is frozen, don't prefer moves that could thaw them
        if target.status == :FROZEN
          user.eachMove do |m|
            next if m.thawsUser?
            score *= 0.3 if score<120
            break
          end
        end
      end
      # Don't prefer moves that are ineffective because of abilities or effects
      return 0 if pbCheckMoveImmunity(score, move, user, target, skill)
      score = score.to_i
      score = 0 if score < 0
      return score
    end
  
    #=============================================================================
    # Add to a move's score based on how much damage it will deal (as a percentage
    # of the target's current HP)
    #=============================================================================
    def pbGetMoveScoreDamage(score, move, user, target, skill)
      return 0 if score <= 0
      # Calculate how much damage the move will do (roughly)
      baseDmg = pbMoveBaseDamage(move, user, target, skill)
      realDamage = pbRoughDamage(move, user, target, skill, baseDmg)
      # Account for accuracy of move
      accuracy = pbRoughAccuracy(move, user, target, skill)
      #realDamage *= accuracy / 100.0 # DemICE
      # Two-turn attacks waste 2 turns to deal one lot of damage
      if move.chargingTurnMove? || move.function == "AttackAndSkipNextTurn"   # Hyper Beam
        realDamage *= 2 / 3   # Not halved because semi-invulnerable during use or hits first turn
      end
      # Prefer flinching external effects (note that move effects which cause
      # flinching are dealt with in the function code part of score calculation)
      if skill >= PBTrainerAI.mediumSkill && !move.flinchingMove? &&
         !target.hasActiveAbility?(:INNERFOCUS) &&
         !target.hasActiveAbility?(:SHIELDDUST) &&
         target.effects[PBEffects::Substitute] == 0
        canFlinch = false
        if user.hasActiveItem?([:KINGSROCK, :RAZORFANG]) ||
           user.hasActiveAbility?(:STENCH)
          canFlinch = true
        end
        realDamage *= 1.3 if canFlinch
      end
      # Convert damage to percentage of target's remaining HP
      damagePercentage = realDamage * 100.0 / target.hp
      # Don't prefer weak attacks
     #    damagePercentage /= 2 if damagePercentage<20
      # Prefer damaging attack if level difference is significantly high
      #damagePercentage *= 1.2 if user.level - 10 > target.level
      # Adjust score
      damagePercentage = 110 if damagePercentage > 100   # Treat all lethal moves the same   # DemICE
      damagePercentage -= 1 if accuracy < 100  # DemICE
      #damagePercentage += 40 if damagePercentage > 100   # Prefer moves likely to be lethal  # DemICE
      score += damagePercentage.to_i
      return score
    end
  

end


