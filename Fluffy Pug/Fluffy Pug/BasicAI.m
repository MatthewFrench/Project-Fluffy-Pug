//
//  BasicAI.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "BasicAI.h"
#import "LeagueGameState.h"

const int ACTION_Run_Away = 0, ACTION_Attack_Enemy_Champion = 1, ACTION_Attack_Enemy_Minion = 2, ACTION_Follow_Ally_Champion = 3, ACTION_Follow_Ally_Minion = 4, ACTION_Move_To_Mid = 5, ACTION_Recall = 6;

BasicAI::BasicAI(LeagueGameState* leagueGameState) {
    gameState = leagueGameState;
    lastMovementClick = clock();
    lastAction = -1;
}
void BasicAI::processAI() {
    if ([gameState->selfChampionManager->championBars count] > 0) {
        ChampionBar selfChamp; [[gameState->selfChampionManager->championBars objectAtIndex:0] getValue:&selfChamp];
        
        bool enemyChampionsNear = [gameState->enemyChampionManager->championBars count] > 0;
        bool enemyMinionsNear = [gameState->enemyMinionManager->minionBars count] > 0;
        bool allyMinionsNear = [gameState->allyMinionManager->minionBars count] > 0;
        bool allyChampionsNear = [gameState->allyChampionManager->championBars count] > 0;
        ChampionBar lowestHealthEnemyChampion = gameState->enemyChampionManager->getLowestHealthChampion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
        MinionBar lowestHealthEnemyMinion = gameState->enemyMinionManager->getLowestHealthMinion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
        MinionBar nearestAllyMinion = gameState->allyMinionManager->getNearestMinion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
        ChampionBar nearestAllyChampion = gameState->allyChampionManager->getNearestChampion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
        
        int action = ACTION_Move_To_Mid;
        
        if (allyChampionsNear) {
            action = ACTION_Follow_Ally_Champion;
        }
        if (allyMinionsNear) {
            action = ACTION_Follow_Ally_Minion;
        }
        if (enemyMinionsNear) {
            action = ACTION_Attack_Enemy_Minion;
        }
        if (enemyChampionsNear && ([gameState->allyChampionManager->championBars count] > [gameState->enemyChampionManager->championBars count] || [gameState->allyChampionManager->championBars count] >= 4 || [gameState->enemyChampionManager->championBars count] == 1)) {
            if (selfChamp.health + 10 > lowestHealthEnemyChampion.health) { //Greater health
                action = ACTION_Attack_Enemy_Champion;
                //NSLog(@"Target in sight and attacking");
            } else if (selfChamp.health < 35 && !allyChampionsNear && lowestHealthEnemyChampion.health > selfChamp.health) { //Lesser health and no allies
                action = ACTION_Run_Away;
                //NSLog(@"Rrun away");
            } else if (allyChampionsNear || lowestHealthEnemyChampion.health < selfChamp.health) { //Yolo when allies are near
                action = ACTION_Attack_Enemy_Champion;
                //NSLog(@"Yolo");
            }
        } else if ([gameState->allyChampionManager->championBars count] < [gameState->enemyChampionManager->championBars count]) {
            action = ACTION_Run_Away;
        }
        
        if (selfChamp.health < 20 && (enemyChampionsNear || enemyMinionsNear)) {
            //NSLog(@"RUN AWAY");
            action = ACTION_Run_Away;
        } else if (selfChamp.health < 20) {
            //NSLog(@"Recall");
            action = ACTION_Recall;
        }
        if (enemyChampionsNear) {
            //NSLog(@"Self health: %f vs Enemy Champ health: %f", selfChamp.health, lowestHealthEnemyChampion.health);
        }
        
        int actionSpeed = 0.25;
        
        switch (action) {
            case ACTION_Run_Away:
            {
                //NSLog(@"Running away");
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= actionSpeed || lastAction != action) {
                    lastMovementClick = clock();
                    if (enemyChampionsNear) {
                        int xMove = (lowestHealthEnemyChampion.characterCenter.x - selfChamp.characterCenter.x);
                        int yMove = (lowestHealthEnemyChampion.characterCenter.y - selfChamp.characterCenter.y);
                        normalizePoint(xMove, yMove, 300);
                    int x = selfChamp.characterCenter.x - xMove;
                    int y = selfChamp.characterCenter.y - yMove;
                        tapMouseRight(x, y);
                    } else
                    if (enemyMinionsNear) {
                        int xMove = (lowestHealthEnemyMinion.characterCenter.x - selfChamp.characterCenter.x);
                        int yMove = (lowestHealthEnemyMinion.characterCenter.y - selfChamp.characterCenter.y);
                        normalizePoint(xMove, yMove, 300);
                        int x = selfChamp.characterCenter.x - xMove;
                        int y = selfChamp.characterCenter.y - yMove;
                        tapMouseRight(x, y);
                    }
                    if (selfChamp.health < 15 && gameState->abilityManager->ability4Ready) {
                        tapSpell4();
                    }
                }
            }
                break;
            case ACTION_Attack_Enemy_Champion:
            {
                //NSLog(@"Attacking enemy champion");
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= actionSpeed || lastAction != action) {
                    lastMovementClick = clock();
                    tapAttackMove(lowestHealthEnemyChampion.characterCenter.x, lowestHealthEnemyChampion.characterCenter.y);
                    if (gameState->abilityManager->ability4Ready) tapSpell4();
                    if (gameState->abilityManager->ability3Ready) tapSpell3();
                    if (gameState->abilityManager->ability2Ready) tapSpell2();
                    if (gameState->abilityManager->ability1Ready) {tapSpell1();}
                }
            }
                break;
            case ACTION_Attack_Enemy_Minion:
            {
                //NSLog(@"Attacking minion");
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= actionSpeed || lastAction != action) {
                    lastMovementClick = clock();
                    tapAttackMove(lowestHealthEnemyMinion.characterCenter.x, lowestHealthEnemyMinion.characterCenter.y);
                    if (gameState->abilityManager->ability1Ready) {tapSpell1();}
                    if (gameState->abilityManager->ability3Ready) {tapSpell3();}
                    if (gameState->abilityManager->ability2Ready && selfChamp.health < 50) {tapSpell2();}
                }
            }
                break;
            case ACTION_Follow_Ally_Champion:
            {
                //NSLog(@"Following ally");
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= actionSpeed || lastAction != action) {
                    lastMovementClick = clock();
                    int xMove = (nearestAllyChampion.characterCenter.x - selfChamp.characterCenter.x);
                    int yMove = (nearestAllyChampion.characterCenter.y - selfChamp.characterCenter.y);
                    normalizePoint(xMove, yMove, 300);
                    tapAttackMove(xMove + selfChamp.characterCenter.x, yMove + selfChamp.characterCenter.y);
                }
            }
                break;
            case ACTION_Follow_Ally_Minion:
            {
                //NSLog(@"Following minion");
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= actionSpeed*2 || lastAction != action) {
                    lastMovementClick = clock();
                    int xMove = (nearestAllyMinion.characterCenter.x - selfChamp.characterCenter.x);
                    int yMove = (nearestAllyMinion.characterCenter.y - selfChamp.characterCenter.y);
                    normalizePoint(xMove, yMove, 300);
                    tapAttackMove(xMove + selfChamp.characterCenter.x, yMove + selfChamp.characterCenter.y);
                }
            }
                break;
            case ACTION_Move_To_Mid:
            {
                //NSLog(@"Going to mid");
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= 3.0 || lastAction != action) {
                    lastMovementClick = clock();
                    int x = gameState->leagueSize.size.width - 116;
                    int y = gameState->leagueSize.size.height - 92;
                    tapMouseRight(x, y);
                }
            }
                break;
            case ACTION_Recall:
            {
                //NSLog(@"Recalling");
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= 12.0 || lastAction != action) {
                    lastMovementClick = clock();
                    tapRecall();
                }
            }
                break;
                
            default:
                break;
        }
        
        lastAction = action;
        
        
        //Level up stuff
        if (gameState->abilityManager->ability4LevelUpAvailable || gameState->abilityManager->ability3LevelUpAvailable || gameState->abilityManager->ability2LevelUpAvailable || gameState->abilityManager->ability1LevelUpAvailable) {
            switch (gameState->abilityManager->levelUpCount+1) {
                case 1:
                case 4:
                case 5:
                case 7:
                case 9:
                    levelUpAbility1();
                    break;
                case 2:
                case 8:
                case 10:
                case 12:
                case 13:
                    levelUpAbility3();
                    break;
                case 3:
                case 14:
                case 15:
                case 17:
                case 18:
                    levelUpAbility2();
                    break;
                case 6:
                case 11:
                case 16:
                    levelUpAbility4();
                    break;
                default:
                    levelUpAbility1();
                    levelUpAbility2();
                    levelUpAbility3();
                    levelUpAbility4();
                    break;
            }
        }
        
        /*
        if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= 3.0) {
            lastMovementClick = clock(); //Move every 3 seconds, less if enemies near
            
            
            if ([gameState->enemyChampionManager->championBars count] > 0) { //Attack enemy champion
                ChampionBar enemyChamp = gameState->enemyChampionManager->getLowestHealthChampion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
                tapMouseRightAttackMove(enemyChamp.characterCenter.x, enemyChamp.characterCenter.y);
                lastMovementClick -= CLOCKS_PER_SEC*2.5;
            } else if ([gameState->enemyMinionManager->minionBars count] > 0) { //Attack enemy minion
                MinionBar enemyMinion = gameState->enemyMinionManager->getLowestHealthMinion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
                tapMouseRightAttackMove(enemyMinion.characterCenter.x, enemyMinion.characterCenter.y);
                lastMovementClick -= CLOCKS_PER_SEC*2.5;
            } else if ([gameState->allyMinionManager->minionBars count] > 0) { //Follow ally minion
                MinionBar allyMinion = gameState->allyMinionManager->getNearestMinion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
                tapMouseRight(allyMinion.characterCenter.x, allyMinion.characterCenter.y);
                lastMovementClick -= CLOCKS_PER_SEC*2.5;
            } else if ([gameState->allyChampionManager->championBars count] > 0) { //Follow ally champion
                ChampionBar allyChamp = gameState->allyChampionManager->getNearestChampion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
                tapMouseRight(allyChamp.characterCenter.x, allyChamp.characterCenter.y);
                lastMovementClick -= CLOCKS_PER_SEC*2.5;
            } else {
                //srand((unsigned int)time(NULL));
                //int x = (rand() % (int)(gameState->leagueSize.size.width-100)) + 50;
                //int y = (rand() % (int)(gameState->leagueSize.size.width-200)) + 100;
                //Go to mid lane
                int x = gameState->leagueSize.size.width - 116;
                int y = gameState->leagueSize.size.height - 92;
                tapMouseRight(x, y);
            }
        }*/
        //NSLog(@"self");
    }// else {
    //    NSLog(@"No self");
    //}
}