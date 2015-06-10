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
    if ([gameState->selfChampionManager->championBars count] > 0) {
        ChampionBar selfChamp; [[gameState->selfChampionManager->championBars objectAtIndex:0] getValue:&selfChamp];
        if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= 3.0) {
            lastMovementClick = clock(); //Move every 3 seconds, less if enemies near
            
            
            if ([gameState->enemyChampionManager->championBars count] > 0) { //Attack enemy champion
                ChampionBar enemyChamp = gameState->enemyChampionManager->getNearestChampion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
                tapMouseRightAttackMove(enemyChamp.characterCenter.x, enemyChamp.characterCenter.y);
                lastMovementClick -= CLOCKS_PER_SEC*2;
            } else if ([gameState->enemyMinionManager->minionBars count] > 0) { //Attack enemy minion
                MinionBar enemyMinion = gameState->enemyMinionManager->getNearestMinion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
                tapMouseRightAttackMove(enemyMinion.characterCenter.x, enemyMinion.characterCenter.y);
                lastMovementClick -= CLOCKS_PER_SEC*2;
            } else if ([gameState->allyMinionManager->minionBars count] > 0) { //Follow ally minion
                MinionBar allyMinion = gameState->allyMinionManager->getNearestMinion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
                tapMouseRight(allyMinion.characterCenter.x, allyMinion.characterCenter.y);
                lastMovementClick -= CLOCKS_PER_SEC*2;
            } else if ([gameState->allyChampionManager->championBars count] > 0) { //Follow ally champion
                ChampionBar allyChamp = gameState->allyChampionManager->getNearestChampion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
                tapMouseRight(allyChamp.characterCenter.x, allyChamp.characterCenter.y);
                lastMovementClick -= CLOCKS_PER_SEC*2;
            } else {
                //srand((unsigned int)time(NULL));
                //int x = (rand() % (int)(gameState->leagueSize.size.width-100)) + 50;
                //int y = (rand() % (int)(gameState->leagueSize.size.width-200)) + 100;
                //Go to mid lane
                int x = gameState->leagueSize.size.width - 116;
                int y = gameState->leagueSize.size.height - 92;
                tapMouseRight(x, y);
            }
        }
    }
}