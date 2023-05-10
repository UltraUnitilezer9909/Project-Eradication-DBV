class Battle::AI

    alias stupidity_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

    def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
        case move.function
        #---------------------------------------------------------------------------
        when "FlinchTargetFailsIfNotUserFirstTurn"
            if user.turnCount == 0
                if skill >= PBTrainerAI.highSkill
                    score +=120 if !target.hasActiveAbility?(:INNERFOCUS) &&
                                target.effects[PBEffects::Substitute] == 0
                end
            else
                score -= 90   # Because it will fail here
                score = 0 if skill >= PBTrainerAI.bestSkill
            end
        else
            score = stupidity_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
        end
            # found=false
            # if !move.damagingMove?
            #     for i in user.moves
            #         dmg=pbGetMoveScoreDamage(1, i, user, target, skill)
            #         found if dmg > 50
            #     end  
            #     score *=2 if !found
            # end     
        return score
    end

end