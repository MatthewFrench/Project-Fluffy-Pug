//
//  BasicAI.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "BasicAI.h"
#import "LeagueGameState.h"

const int ACTION_Run_Away = 0, ACTION_Attack_Enemy_Champion = 1, ACTION_Attack_Enemy_Minion = 2, ACTION_Follow_Ally_Champion = 3, ACTION_Follow_Ally_Minion = 4, ACTION_Move_To_Mid = 5, ACTION_Recall = 6, ACTION_Attack_Tower = 7, ACTION_Go_Ham = 8;

BasicAI::BasicAI(LeagueGameState* leagueGameState) {
    gameState = leagueGameState;
    lastMovementClick = clock();
    lastAction = -1;
    passiveUseWardTimer = clock();
    cameraLockTimer = clock();
    lastShopBuy = -999999999999999999;
    //gameState->shopManager->buyingItems = false;
}
void BasicAI::processAI() {
    /*
    if ((clock() - lastShopBuy)/CLOCKS_PER_SEC >= 120 && gameState->shopManager->shopAvailable) {
        //If shop is availabe and haven't bought in 2 minutes, buy items
        gameState->shopManager->buyingItems = true;
        lastShopBuy = clock();
        gameState->shopManager->boughtItems = false;
        stopMovement();
    }*/
    /*
    if (gameState->shopManager->buyingItems) {
        if (gameState->shopManager->shopOpen == false && gameState->shopManager->boughtItems == false) {
            stopMovement();
            //If shop isn't open and we haven't bought items, wait for shop to open
            gameState->shopManager->openShop();
        } else if (gameState->shopManager->shopOpen == true) {
            //If shop is open, wait to buy items
            gameState->shopManager->buyItems();
            if (gameState->shopManager->boughtItems == true) {
                //It bought items, wait for shop to close
                gameState->shopManager->closeShop();
            }
        } else {
            //If shop isn't open and we bought items, finish it
            gameState->shopManager->buyingItems = false;
            lastShopBuy = clock();
        }
    } else if ([gameState->selfChampionManager->championBars count] == 0 && gameState->shopManager->shopOpen) {
        gameState->shopManager->closeShop();
    }
    */
    /*
    if ([gameState->selfChampionManager->championBars count] > 0 && !gameState->shopManager->buyingItems) {
        ChampionBar selfChamp; [[gameState->selfChampionManager->championBars objectAtIndex:0] getValue:&selfChamp];
        
        bool enemyChampionsNear = [gameState->enemyChampionManager->championBars count] > 0;
        bool enemyMinionsNear = [gameState->enemyMinionManager->minionBars count] > 0;
        bool allyMinionsNear = [gameState->allyMinionManager->minionBars count] > 0;
        bool allyChampionsNear = [gameState->allyChampionManager->championBars count] > 0;
        bool enemyTowerNear = [gameState->enemyTowerManager->towerBars count] > 0;
        bool underEnemyTower = false;
        ChampionBar lowestHealthEnemyChampion = gameState->enemyChampionManager->getLowestHealthChampion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
        MinionBar lowestHealthEnemyMinion = gameState->enemyMinionManager->getLowestHealthMinion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
        MinionBar closestAllyMinion = gameState->allyMinionManager->getNearestMinion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
        ChampionBar nearestAllyChampion = gameState->allyChampionManager->getNearestChampion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
        TowerBar nearestEnemyTower = gameState->enemyTowerManager->getNearestTower(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
        
        if (enemyTowerNear && hypot(selfChamp.characterCenter.x - nearestEnemyTower.towerCenter.x, selfChamp.characterCenter.y - nearestEnemyTower.towerCenter.y) < 430) {
            underEnemyTower = true;
        }
        
        int action = ACTION_Move_To_Mid;
        
        if (allyMinionsNear) {
            action = ACTION_Follow_Ally_Minion;
        }
        if (allyChampionsNear) {
            action = ACTION_Follow_Ally_Champion;
        }
        if (enemyMinionsNear) {
            action = ACTION_Attack_Enemy_Minion;
        }
        //Attack enemy if see enemy
        if (enemyChampionsNear && ([gameState->allyChampionManager->championBars count]+2 >= [gameState->enemyChampionManager->championBars count] || [gameState->allyChampionManager->championBars count] >= 4 || [gameState->enemyChampionManager->championBars count] == 1)) {
            if (selfChamp.health + 10 > lowestHealthEnemyChampion.health) { //Greater health
                action = ACTION_Attack_Enemy_Champion;
                //NSLog(@"Target in sight and attacking");
            } else if (selfChamp.health < 40 && !allyChampionsNear && lowestHealthEnemyChampion.health > selfChamp.health) { //Lesser health and no allies
                action = ACTION_Run_Away;
                //NSLog(@"Rrun away");
            } else if (allyChampionsNear || lowestHealthEnemyChampion.health < selfChamp.health) { //Yolo when allies are near
                action = ACTION_Attack_Enemy_Champion;
                //NSLog(@"Yolo");
            }
        } else if (enemyChampionsNear && [gameState->allyChampionManager->championBars count]+2 < [gameState->enemyChampionManager->championBars count]) {
            action = ACTION_Run_Away;
        }
        //Now some more attack logic
        if (action == ACTION_Attack_Enemy_Champion) {
            //If enemy is under tower, ignore
            if (hypot(lowestHealthEnemyChampion.characterCenter.x - nearestEnemyTower.towerCenter.x, lowestHealthEnemyChampion.characterCenter.y - nearestEnemyTower.towerCenter.y) < 430 && lowestHealthEnemyChampion.health > 20) {
                action = ACTION_Move_To_Mid;
                
                if (allyMinionsNear) {
                    action = ACTION_Follow_Ally_Minion;
                }
                if (allyChampionsNear) {
                    action = ACTION_Follow_Ally_Champion;
                }
                if (enemyMinionsNear) {
                    action = ACTION_Attack_Enemy_Minion;
                }
            }
        }
        
        if (action == ACTION_Attack_Enemy_Minion) {
            if (hypot(lowestHealthEnemyMinion.characterCenter.x - nearestEnemyTower.towerCenter.x, lowestHealthEnemyMinion.characterCenter.y - nearestEnemyTower.towerCenter.y) < 430) {
                action = ACTION_Move_To_Mid;
                
                if (allyMinionsNear) {
                    action = ACTION_Follow_Ally_Minion;
                }
                if (allyChampionsNear) {
                    action = ACTION_Follow_Ally_Champion;
                }
            }
        }
        
        //Attack tower if allied minions under tower
        if (enemyTowerNear && (action == ACTION_Move_To_Mid || action == ACTION_Follow_Ally_Minion || action == ACTION_Follow_Ally_Champion || action == ACTION_Attack_Enemy_Minion)) {
            int minionsUnderTower = 0;
            for (int i = 0; i < [gameState->allyMinionManager->minionBars count]; i++) {
                MinionBar mb;
                [[gameState->allyMinionManager->minionBars objectAtIndex:i] getValue:&mb];
                if (hypot(mb.characterCenter.x - nearestEnemyTower.towerCenter.x, mb.characterCenter.y - nearestEnemyTower.towerCenter.y) < 430) {
                    minionsUnderTower++;
                }
            }
            if (minionsUnderTower > 1) {
                action = ACTION_Attack_Tower;
            } else {
                action = ACTION_Run_Away;
            }
        }
        
        //if (enemyTowerNear && hypot(selfChamp.characterCenter.x - nearestEnemyTower.towerCenter.x, selfChamp.characterCenter.y - nearestEnemyTower.towerCenter.y) < 430) {
        //    action = ACTION_Run_Away;
        //}
        bool enemyChampionCloseEnough = false;
        if ([gameState->enemyChampionManager->championBars count] > 0) {
        ChampionBar closeEnemyChampion = gameState->enemyChampionManager->getNearestChampion(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
        if (hypot(closeEnemyChampion.characterCenter.x - selfChamp.characterCenter.x, closeEnemyChampion.characterCenter.y - selfChamp.characterCenter.y) < 350) {
            enemyChampionCloseEnough = true;
        }
        }
        if (selfChamp.health < 25 && enemyChampionCloseEnough) {
            //NSLog(@"RUN AWAY");
            action = ACTION_Run_Away;
        } else if (selfChamp.health < 25 && (!enemyChampionsNear && !enemyMinionsNear)) {
            //NSLog(@"Recall");
            action = ACTION_Recall;
        }
        //if (enemyChampionsNear) {
            //NSLog(@"Self health: %f vs Enemy Champ health: %f", selfChamp.health, lowestHealthEnemyChampion.health);
        //}
        
        //Go ham
        if (enemyChampionsNear && lowestHealthEnemyChampion.health < 15) {
            action = ACTION_Go_Ham;
        }
        
        int actionSpeed = 0.25;
        
        switch (action) {
            case ACTION_Run_Away:
            {
                //NSLog(@"Running away");
                int enemyX = selfChamp.characterCenter.x;
                int enemyY = selfChamp.characterCenter.y;
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= actionSpeed) {
                    lastMovementClick = clock();
                    
                    if (enemyChampionsNear) {
                        int xMove = (lowestHealthEnemyChampion.characterCenter.x - selfChamp.characterCenter.x);
                        int yMove = (lowestHealthEnemyChampion.characterCenter.y - selfChamp.characterCenter.y);
                        normalizePoint(xMove, yMove, 300);
                    int x = selfChamp.characterCenter.x - xMove;
                    int y = selfChamp.characterCenter.y - yMove;
                        tapMouseRight(x, y);
                        enemyX = lowestHealthEnemyChampion.characterCenter.x;
                        enemyY = lowestHealthEnemyChampion.characterCenter.y;
                    } else
                    if (enemyMinionsNear) {
                        int xMove = (lowestHealthEnemyMinion.characterCenter.x - selfChamp.characterCenter.x);
                        int yMove = (lowestHealthEnemyMinion.characterCenter.y - selfChamp.characterCenter.y);
                        normalizePoint(xMove, yMove, 300);
                        int x = selfChamp.characterCenter.x - xMove;
                        int y = selfChamp.characterCenter.y - yMove;
                        tapMouseRight(x, y);
                        enemyX = lowestHealthEnemyMinion.characterCenter.x;
                        enemyY = lowestHealthEnemyMinion.characterCenter.y;
                    }
                }
                if (selfChamp.health < 15) {
                    //Panic
                    if (gameState->abilityManager->ability4Ready) {moveMouse(enemyX, enemyY); gameState->abilityManager->useSpell4();}
                    if (gameState->abilityManager->ability3Ready) {moveMouse(enemyX, enemyY); gameState->abilityManager->useSpell3();}
                    if (gameState->abilityManager->ability2Ready) {moveMouse(enemyX, enemyY); gameState->abilityManager->useSpell2();}
                    if (gameState->abilityManager->ability1Ready) {moveMouse(enemyX, enemyY); gameState->abilityManager->useSpell1();}
                    if (gameState->abilityManager->summonerSpell1Ready) {moveMouse(enemyX, enemyY); gameState->abilityManager->useSummonerSpell1();}
                    if (gameState->abilityManager->summonerSpell2Ready) {moveMouse(enemyX, enemyY); gameState->abilityManager->useSummonerSpell2();}
                    if (gameState->itemManager->item1Active) {moveMouse(enemyX, enemyY); gameState->itemManager->useItem1();}
                    if (gameState->itemManager->item2Active) {moveMouse(enemyX, enemyY); gameState->itemManager->useItem2();}
                    if (gameState->itemManager->item3Active) {moveMouse(enemyX, enemyY); gameState->itemManager->useItem3();}
                    if (gameState->itemManager->item5Active) {moveMouse(enemyX, enemyY); gameState->itemManager->useItem5();}
                    if (gameState->itemManager->item6Active) {moveMouse(enemyX, enemyY); gameState->itemManager->useItem6();}
                    if (gameState->itemManager->item7Active) {moveMouse(enemyX, enemyY); gameState->itemManager->useItem7();}
                    if (gameState->itemManager->trinketActive) gameState->itemManager->useTrinket(enemyX, enemyY);
                }
            }
                break;
            case ACTION_Attack_Enemy_Champion:
            case ACTION_Go_Ham:
            {
                //NSLog(@"Attacking enemy champion");
                int x = lowestHealthEnemyChampion.characterCenter.x;
                int y = lowestHealthEnemyChampion.characterCenter.y;
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= actionSpeed) {
                    lastMovementClick = clock();
                    tapAttackMove(lowestHealthEnemyChampion.characterCenter.x, lowestHealthEnemyChampion.characterCenter.y);
                }
                if (gameState->abilityManager->ability4Ready) {moveMouse(x, y); gameState->abilityManager->useSpell4();}
                if (gameState->abilityManager->ability3Ready) {moveMouse(x, y);  gameState->abilityManager->useSpell3();}
                if (gameState->abilityManager->ability2Ready) {moveMouse(x, y);  gameState->abilityManager->useSpell2();}
                if (gameState->abilityManager->ability1Ready) {moveMouse(x, y);  gameState->abilityManager->useSpell1();}
                if (gameState->abilityManager->summonerSpell1Ready) {moveMouse(x, y); gameState->abilityManager->useSummonerSpell1();}
                if (gameState->abilityManager->summonerSpell2Ready) {moveMouse(x, y); gameState->abilityManager->useSummonerSpell2();}
                if (gameState->itemManager->item1Active) {moveMouse(x, y); gameState->itemManager->useItem1();}
                if (gameState->itemManager->item2Active) {moveMouse(x, y); gameState->itemManager->useItem2();}
                if (gameState->itemManager->item3Active) {moveMouse(x, y); gameState->itemManager->useItem3();}
                if (gameState->itemManager->item5Active) {moveMouse(x, y); gameState->itemManager->useItem5();}
                if (gameState->itemManager->item6Active) {moveMouse(x, y); gameState->itemManager->useItem6();}
                if (gameState->itemManager->item7Active) {moveMouse(x, y); gameState->itemManager->useItem7();}
                if (gameState->itemManager->trinketActive) gameState->itemManager->useTrinket(x, y);
            }
                break;
            case ACTION_Attack_Enemy_Minion:
            {
                //NSLog(@"Attacking minion");
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= actionSpeed) {
                    lastMovementClick = clock();
                    tapAttackMove(lowestHealthEnemyMinion.characterCenter.x, lowestHealthEnemyMinion.characterCenter.y);
                }
                if (gameState->abilityManager->ability1Ready) {gameState->abilityManager->useSpell1();}
                if (gameState->abilityManager->ability3Ready) {gameState->abilityManager->useSpell3();}
                if (gameState->abilityManager->ability2Ready && selfChamp.health < 50) {gameState->abilityManager->useSpell2();}
            }
                break;
            case ACTION_Attack_Tower:
            {
                //NSLog(@"Attacking tower");
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= actionSpeed) {
                    lastMovementClick = clock();
                    tapAttackMove(nearestEnemyTower.towerCenter.x, nearestEnemyTower.towerCenter.y);
                }
                if (gameState->abilityManager->ability1Ready) {gameState->abilityManager->useSpell1();}
                if (gameState->abilityManager->ability3Ready) {gameState->abilityManager->useSpell3();}
                if (gameState->abilityManager->ability2Ready && selfChamp.health < 50) {gameState->abilityManager->useSpell2();}
            }
                break;
            case ACTION_Follow_Ally_Champion:
            {
               // NSLog(@"Following ally");
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= actionSpeed) {
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
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= actionSpeed*2) {
                    lastMovementClick = clock();
                    int xMove = (closestAllyMinion.characterCenter.x - selfChamp.characterCenter.x);
                    int yMove = (closestAllyMinion.characterCenter.y - selfChamp.characterCenter.y);
                    normalizePoint(xMove, yMove, 300);
                    tapAttackMove(xMove + selfChamp.characterCenter.x, yMove + selfChamp.characterCenter.y);
                }
            }
                break;
            case ACTION_Move_To_Mid:
            {
                //NSLog(@"Going to mid");
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= actionSpeed) {
                    lastMovementClick = clock();
                    int x = gameState->leagueSize.size.width - 150;
                    int y = gameState->leagueSize.size.height - 140;
                    tapMouseRight(x, y);
                }
            }
                break;
            case ACTION_Recall:
            {
                //NSLog(@"Recalling");
                if ((clock() - lastMovementClick)/CLOCKS_PER_SEC >= actionSpeed) {
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
        
        if (gameState->abilityManager->ability3LevelUpAvailable || gameState->abilityManager->ability2LevelUpAvailable || gameState->abilityManager->ability1LevelUpAvailable  || gameState->abilityManager->ability4LevelUpAvailable) {
            levelUpAbility4();
            levelUpAbility1();
            levelUpAbility2();
            levelUpAbility3();
        }
     
        if (gameState->abilityManager->ability4LevelUpAvailable || gameState->abilityManager->ability3LevelUpAvailable || gameState->abilityManager->ability2LevelUpAvailable || gameState->abilityManager->ability1LevelUpAvailable) {
            //NSLog(@"Dots: %d", gameState->abilityManager->levelUpCount);
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
        
        //Randomly place wards
        if (gameState->itemManager->trinketActive && (clock()-passiveUseWardTimer)/CLOCKS_PER_SEC >= 20.0 && lastAction!=ACTION_Recall) {
         gameState->itemManager->useTrinket(selfChamp.characterCenter.x, selfChamp.characterCenter.y);
            passiveUseWardTimer = clock();
        }
        
        //Detect unlocked camera
        //getTimeInMilliseconds(mach_absolute_time() - cameraLockTimer)
        if (getTimeInMilliseconds(mach_absolute_time() - cameraLockTimer) >= 1000.0) {
            cameraLockTimer = mach_absolute_time();
            tapCameraLock();
            //Go to mid
            int x = gameState->leagueSize.size.width - 150;
            int y = gameState->leagueSize.size.height - 140;
            tapMouseRight(x, y);
        }
        
    
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
        }
        //NSLog(@"self");
    } else if ([gameState->selfChampionManager->championBars count] == 0 && !gameState->shopManager->buyingItems) {
        //Doesn't see self but if we do see shop available, assume camera unlocked
        if ((clock() - cameraLockTimer)/CLOCKS_PER_SEC >= 5.0) {
            cameraLockTimer = clock();
            tapCameraLock();
            //Go to mid
            int x = gameState->leagueSize.size.width - 150;
            int y = gameState->leagueSize.size.height - 140;
            tapMouseRight(x, y);
        }
    }
    //Try this
    if ((clock() - cameraLockTimer)/CLOCKS_PER_SEC >= 60.0 && !gameState->shopManager->buyingItems) { //Try a random camera tap to make sure the AI isn't stuck
        cameraLockTimer = clock();
        tapCameraLock();
        gameState->shopManager->closeShop();
        //Go to mid
        int x = gameState->leagueSize.size.width - 150;
        int y = gameState->leagueSize.size.height - 140;
        tapMouseRight(x, y);
        moveMouse(0, 0);
    }
*/
}