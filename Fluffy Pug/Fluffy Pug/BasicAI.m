//
//  BasicAI.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "BasicAI.h"
#import "LeagueGameState.h"

BasicAI::BasicAI(LeagueGameState* leagueGameState) {
    gameState = leagueGameState;
    lastMovementClick = clock();
}
void BasicAI::processAI() {
    //Move randomly every 3 seconds
    if (clock() - lastMovementClick >= 3.0) {
        lastMovementClick = clock();
        
        if ([gameState->selfChampionManager->championBars count] > 0) {
            ChampionBar selfChamp; [[gameState->selfChampionManager->championBars objectAtIndex:0] getValue:&selfChamp];
            if (clock() - lastMovementClick >= 3.0) {
                if ([gameState->enemyChampionManager->championBars count] > 0) { //Attack enemy champion
                    ChampionBar enemyChamp = gameState->enemyChampionManager->getNearestChampion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
                    tapMouseRight(enemyChamp.characterCenter.x, enemyChamp.characterCenter.y);
                } else if ([gameState->enemyMinionManager->minionBars count] > 0) { //Attack enemy minion
                    MinionBar enemyMinion = gameState->allyMinionManager->getNearestMinion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
                    tapMouseRight(enemyMinion.characterCenter.x, enemyMinion.characterCenter.y);
                } else if ([gameState->allyMinionManager->minionBars count] > 0) { //Follow ally minion
                    MinionBar allyMinion = gameState->allyMinionManager->getNearestMinion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
                    tapMouseRight(allyMinion.characterCenter.x, allyMinion.characterCenter.y);
                } else if ([gameState->allyChampionManager->championBars count] > 0) { //Follow ally champion
                    ChampionBar allyChamp = gameState->allyChampionManager->getNearestChampion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
                    tapMouseRight(allyChamp.characterCenter.x, allyChamp.characterCenter.y);
                } else {
                    srand((unsigned int)time(NULL));
                    int x = (rand() % (int)(gameState->leagueSize.size.width-100)) + 50;
                    int y = (rand() % (int)(gameState->leagueSize.size.width-200)) + 100;
                    tapMouseRight(x, y);
                }
            }
        }
    }
}