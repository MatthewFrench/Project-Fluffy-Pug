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
    
    lastLevelUp = mach_absolute_time();
    lastShopBuy = 0;
    lastShopOpenTap = 0;
    lastShopCloseTap = 0;
    lastShopBuying = mach_absolute_time();
    lastCameraFocus = mach_absolute_time();
    lastPlacedWard = mach_absolute_time();
    lastRunAwayClick = mach_absolute_time();
    lastClickEnemyChamp = mach_absolute_time();
    lastMovementClick = mach_absolute_time();
    lastClickAllyMinion = mach_absolute_time();
    
    lastClickEnemyMinion = mach_absolute_time();
    lastClickEnemyTower = mach_absolute_time();
    lastClickAllyChampion = mach_absolute_time();
    lastMoveMouse = mach_absolute_time();
    lastRecallTap = mach_absolute_time();
    lastSpell1Use = mach_absolute_time();
    lastSpell2Use = mach_absolute_time();
    lastSpell3Use = mach_absolute_time();
    lastSpell4Use = mach_absolute_time();
    lastSummonerSpell1Use = mach_absolute_time();
    lastSummonerSpell2Use = mach_absolute_time();
    lastItem1Use = mach_absolute_time();
    lastItem2Use = mach_absolute_time();
    lastItem3Use = mach_absolute_time();
    lastItem4Use = mach_absolute_time();
    lastItem5Use = mach_absolute_time();
    lastItem6Use = mach_absolute_time();
}
void BasicAI::handleAbilityLevelUps() {
    int abilityLevelUpOrder[] = {1, 2, 3, 1, 2, 4, 3, 1, 2, 3, 4, 1, 2, 3, 1, 4, 2, 3};
    //Level up an ability as soon as possible but only one ability every 500 milliseconds
    if (getTimeInMilliseconds(mach_absolute_time() - lastLevelUp) >= 500) {
        bool leveledUp = false;
        if (gameState->detectionManager->getCurrentLevel() < 18) {
            int preferredLevelUp = abilityLevelUpOrder[gameState->detectionManager->getCurrentLevel()];
            if (preferredLevelUp == 1 && gameState->detectionManager->getSpell1LevelUpVisible()) {
                levelUpAbility1();
                leveledUp = true;
                NSLog(@"Leveling Spell 1");
            } else if (preferredLevelUp == 2 && gameState->detectionManager->getSpell2LevelUpVisible()) {
                levelUpAbility2();
                leveledUp = true;
                NSLog(@"Leveling Spell 2");
            } else if (preferredLevelUp == 3 && gameState->detectionManager->getSpell3LevelUpVisible()) {
                levelUpAbility3();
                leveledUp = true;
                NSLog(@"Leveling Spell 3");
            } else if (preferredLevelUp == 4 && gameState->detectionManager->getSpell4LevelUpVisible()) {
                levelUpAbility4();
                leveledUp = true;
                NSLog(@"Leveling Spell 4");
            } else if (gameState->detectionManager->getSpell1LevelUpVisible()) {
                levelUpAbility1();
                leveledUp = true;
                NSLog(@"Leveling Spell 1");
            } else if (gameState->detectionManager->getSpell2LevelUpVisible()) {
                levelUpAbility2();
                leveledUp = true;
                NSLog(@"Leveling Spell 2");
            } else if (gameState->detectionManager->getSpell3LevelUpVisible()) {
                levelUpAbility3();
                leveledUp = true;
                NSLog(@"Leveling Spell 3");
            } else if (gameState->detectionManager->getSpell4LevelUpVisible()) {
                levelUpAbility4();
                leveledUp = true;
                NSLog(@"Leveling Spell 4");
            }
        }
        if (leveledUp) {
            lastLevelUp = mach_absolute_time();
        }
    }
}
void BasicAI::handleBuyingItems() {
    //if (gameState->detectionManager->getShopBottomLeftCornerVisible()) {
    //    NSLog(@"Shop bottom left visible");
    //}
    bool closeShop = false;
    if (getTimeInMilliseconds(mach_absolute_time() - lastShopBuy) >= 1000*60*5) {
        if (gameState->detectionManager->getShopAvailable()) {
            
            if (gameState->detectionManager->getShopTopLeftCornerVisible() && gameState->detectionManager->getShopBottomLeftCornerVisible()) {
                lastShopBuy = mach_absolute_time();
                //Buy items
                NSMutableArray* itemsToBuy = gameState->detectionManager->getBuyableItems();
                for (int i = 0; i < [itemsToBuy count]; i++) {
                    GenericObject* item = [itemsToBuy objectAtIndex:i];
                    int clickX = item->center.x;
                    int clickY = item->center.y;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, i * NSEC_PER_SEC / 1000 * 500), dispatch_get_main_queue(), ^{
                        moveMouse(clickX, clickY);
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, i * NSEC_PER_SEC / 1000 * (500+250)), dispatch_get_main_queue(), ^{
                        doubleTapMouseLeft(clickX, clickY);
                    });
                }
                lastShopBuying = mach_absolute_time();
                NSLog(@"Bought items");
            } else { //Open up the shop
                if (getTimeInMilliseconds(mach_absolute_time() - lastShopOpenTap) >= 8000) {
                    lastShopOpenTap = mach_absolute_time();
                    tapStopMoving();
                    tapShop();
                    NSLog(@"Opening shop for initial buy");
                }
            }
        } else {
            if (gameState->detectionManager->getShopTopLeftCornerVisible() && gameState->detectionManager->getShopBottomLeftCornerVisible()) {
                closeShop = true;
                NSLog(@"Shop not available, closing shop");
            }
        }
    } else {
        //Close shop
        if (gameState->detectionManager->getShopTopLeftCornerVisible() && gameState->detectionManager->getShopBottomLeftCornerVisible() &&
            getTimeInMilliseconds(mach_absolute_time() - lastShopBuying) >= 10000) {
            //Gave a 4 seconds to buy
            closeShop = true;
            NSLog(@"Closing shop because we already bought.");
        }
    }
    if (closeShop) {
        if (getTimeInMilliseconds(mach_absolute_time() - lastShopCloseTap) >= 500) {
            lastShopCloseTap = mach_absolute_time();
            tapShop();
        }
    }
}
void BasicAI::handleCameraFocus() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastCameraFocus) >= 4000) {
        if (gameState->detectionManager->getSelfHealthBarVisible() && !gameState->detectionManager->getShopTopLeftCornerVisible()) {
            //We see the health bar at the bottom so lets focus camera
            if (gameState->detectionManager->getSelfChampions().count == 0) {
                lastCameraFocus = mach_absolute_time();
                tapCameraLock();
                NSLog(@"Attempting camera lock cause we don't see ourselves");
            }
        }
    }
}
void BasicAI::handlePlacingWard() {
    if ([gameState->detectionManager->getSelfChampions() count] > 0 && gameState->detectionManager->getTrinketActiveAvailable()) {
        Champion* champ = [gameState->detectionManager->getSelfChampions() firstObject];
        moveMouse(champ->characterCenter.x, champ->characterCenter.y);
        useTrinket();
        NSLog(@"Placing ward");
    }
}
const int ACTION_Run_Away = 0, ACTION_Attack_Enemy_Champion = 1, ACTION_Attack_Enemy_Minion = 2, ACTION_Follow_Ally_Champion = 3, ACTION_Follow_Ally_Minion = 4, ACTION_Move_To_Mid = 5, ACTION_Recall = 6, ACTION_Attack_Tower = 7, ACTION_Go_Ham = 8;
void BasicAI::handleMovementAndAttacking() {
    //If we see our selves and the shop is closed, then lets move around
    
    
    /**  ONLY GET INFO FROM DETECTION MANAGER ONCE. I CAN CHANGE NEXT GET  **/
    
    NSMutableArray* selfChampions = gameState->detectionManager->getSelfChampions();
    bool shopTopLeftCornerVisible = gameState->detectionManager->getShopTopLeftCornerVisible();
    bool mapShopVisible = gameState->detectionManager->getMapShopVisible();
    bool mapVisible = gameState->detectionManager->getMapVisible();
    GenericObject* map = gameState->detectionManager->getMap();
    GenericObject* mapShop = gameState->detectionManager->getMapShop();
    
    
    bool buyingItems = getTimeInMilliseconds(mach_absolute_time() - lastShopBuy) >= 1000*60*5 && gameState->detectionManager->getShopAvailable();
    
    if ([selfChampions count] > 0 && !shopTopLeftCornerVisible && !buyingItems) {
        
        
        int numberOfSelfChamps = (int)selfChampions.count;
        if (numberOfSelfChamps == 0) {
            NSLog(@"We have a problem");
        }
        id firstObject = [selfChampions firstObject];
        Champion* selfChamp = firstObject;
        
        NSMutableArray* enemyChampions = gameState->detectionManager->getEnemyChampions();
        NSMutableArray* enemyMinions = gameState->detectionManager->getEnemyMinions();
        NSMutableArray* allyMinions = gameState->detectionManager->getAllyMinions();
        NSMutableArray* allyChampions = gameState->detectionManager->getAllyChampions();
        NSMutableArray* enemyTowers = gameState->detectionManager->getEnemyTowers();
        
        bool enemyChampionsNear = [enemyChampions count] > 0;
        bool enemyMinionsNear = [enemyMinions count] > 0;
        bool allyMinionsNear = [allyMinions count] > 0;
        bool allyChampionsNear = [allyChampions count] > 0;
        bool enemyTowerNear = [enemyTowers count] > 0;
        bool underEnemyTower = false;
        Champion* lowestHealthEnemyChampion = getLowestHealthChampion(enemyChampions, selfChamp->characterCenter.x, selfChamp->characterCenter.y);
        Minion* lowestHealthEnemyMinion = getLowestHealthMinion(enemyMinions, selfChamp->characterCenter.x, selfChamp->characterCenter.y);
        Minion* closestAllyMinion = getNearestMinion(allyMinions, selfChamp->characterCenter.x, selfChamp->characterCenter.y);
        Champion* nearestAllyChampion = getNearestChampion(allyChampions, selfChamp->characterCenter.x, selfChamp->characterCenter.y);
        Tower* nearestEnemyTower = getNearestTower(enemyTowers, selfChamp->characterCenter.x, selfChamp->characterCenter.y);
        
        if (enemyTowerNear && hypot(selfChamp->characterCenter.x - nearestEnemyTower->towerCenter.x, selfChamp->characterCenter.y - nearestEnemyTower->towerCenter.y) < 430) {
            underEnemyTower = true;
        }
        //Initial action is to move to middle lane
        int action = ACTION_Move_To_Mid;
        
        //If an ally minion is nearby, lets follow them
        if (allyMinionsNear) {
            action = ACTION_Follow_Ally_Minion;
        }
        //Even better, lets follow an ally champion, see if we can help out
        if (allyChampionsNear) {
            action = ACTION_Follow_Ally_Champion;
        }
        //Oh look free gold, lets get that
        if (enemyMinionsNear) {
            action = ACTION_Attack_Enemy_Minion;
        }
        
        //Attack enemy if see enemy but not if there are too many enemies
        if (enemyChampionsNear && ([allyChampions count]+2 >= [enemyChampions count] || [allyChampions count] >= 4 || [enemyChampions count] == 1)) {
            //We got the upper hand, engage
            if (selfChamp->health + 10 > lowestHealthEnemyChampion->health) { //Greater health
                action = ACTION_Attack_Enemy_Champion;
            } else if (selfChamp->health < 40 && !allyChampionsNear && lowestHealthEnemyChampion->health > selfChamp->health) {
                //Lesser health and no allies, bye
                action = ACTION_Run_Away;
            } else if (allyChampionsNear || lowestHealthEnemyChampion->health < selfChamp->health) {
                //Yolo when allies are near, we can take em
                action = ACTION_Attack_Enemy_Champion;
            }
        } else if (enemyChampionsNear && [allyChampions count]+2 < [enemyChampions count]) {
            //Too many baddies, peace.
            action = ACTION_Run_Away;
        }
        //Now some more attack logic
        if (action == ACTION_Attack_Enemy_Champion && enemyTowerNear) {
            //If enemy is under tower, ignore
            if (hypot(lowestHealthEnemyChampion->characterCenter.x - nearestEnemyTower->towerCenter.x, lowestHealthEnemyChampion->characterCenter.y - nearestEnemyTower->towerCenter.y) < 430 && lowestHealthEnemyChampion->health > 20) {
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
        
        if (action == ACTION_Attack_Enemy_Minion && enemyTowerNear) {
            if (hypot(lowestHealthEnemyMinion->characterCenter.x - nearestEnemyTower->towerCenter.x, lowestHealthEnemyMinion->characterCenter.y - nearestEnemyTower->towerCenter.y) < 430) {
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
            for (int i = 0; i < [allyMinions count]; i++) {
                Minion* mb = [allyMinions objectAtIndex:i];
                if (hypot(mb->characterCenter.x - nearestEnemyTower->towerCenter.x, mb->characterCenter.y - nearestEnemyTower->towerCenter.y) < 430) {
                    minionsUnderTower++;
                }
            }
            if (minionsUnderTower > 1) {
                action = ACTION_Attack_Tower;
            } else {
                action = ACTION_Run_Away;
            }
        }
        
        bool enemyChampionCloseEnough = false;
        if ([enemyChampions count] > 0) {
            Champion* closeEnemyChampion = getNearestChampion(enemyChampions, selfChamp->characterCenter.x, selfChamp->characterCenter.y);
            if (hypot(closeEnemyChampion->characterCenter.x - selfChamp->characterCenter.x, closeEnemyChampion->characterCenter.y - selfChamp->characterCenter.y) < 400) {
                enemyChampionCloseEnough = true;
            }
        }
        if (selfChamp->health < 25 && (enemyChampionCloseEnough || enemyMinionsNear || underEnemyTower)) {
            action = ACTION_Run_Away;
        } else if (selfChamp->health < 25 && !enemyChampionsNear && !underEnemyTower) {
            action = ACTION_Recall;
        }
        
        //Go ham
        if (enemyChampionsNear && lowestHealthEnemyChampion->health < 15) {
            action = ACTION_Go_Ham;
        }
        
        //int actionSpeed = 0.25;
        
        switch (action) {
            case ACTION_Run_Away:
            {
                NSLog(@"\t\tAction: Running Away");
                //Run back to base by right clicking on the shop on the minimap
                //If no shop, stand still and fight.
                if (mapShopVisible) {
                    if (getTimeInMilliseconds(mach_absolute_time() - lastRunAwayClick) >= 700) {
                        tapMouseRight(mapShop->center.x, mapShop->center.y);
                        lastRunAwayClick = mach_absolute_time();
                    }
                }
                
                if (selfChamp->health < 15) {
                    int enemyX = selfChamp->characterCenter.x;
                    int enemyY = selfChamp->characterCenter.y;
                    //Panic
                    if (getTimeInMilliseconds(mach_absolute_time() - lastMoveMouse) >= 17) {
                        lastMoveMouse = mach_absolute_time();
                        moveMouse(enemyX, enemyY);
                    }
                    castSpell4();
                    castSpell3();
                    castSpell2();
                    castSpell1();
                    castSummonerSpell1();
                    castSummonerSpell2();
                    useItem1();
                    useItem2();
                    useItem3();
                    useItem4();
                    useItem5();
                    useItem6();
                    useTrinket();
                }
            }
                break;
            case ACTION_Attack_Enemy_Champion:
            case ACTION_Go_Ham:
            {
                NSLog(@"\t\tAction: Attacking enemy champion");
                int x = lowestHealthEnemyChampion->characterCenter.x;
                int y = lowestHealthEnemyChampion->characterCenter.y;
                if (getTimeInMilliseconds(mach_absolute_time() - lastClickEnemyChamp) >= 500) {
                    lastClickEnemyChamp = mach_absolute_time();
                    tapAttackMove(lowestHealthEnemyChampion->characterCenter.x, lowestHealthEnemyChampion->characterCenter.y);
                }
                if (getTimeInMilliseconds(mach_absolute_time() - lastMoveMouse) >= 17) {
                    lastMoveMouse = mach_absolute_time();
                    moveMouse(x, y);
                }
                castSpell4();
                castSpell3();
                castSpell2();
                castSpell1();
                castSummonerSpell1();
                castSummonerSpell2();
                useItem1();
                useItem2();
                useItem3();
                useItem4();
                useItem5();
                useItem6();
                useTrinket();
                
            }
                break;
            case ACTION_Attack_Enemy_Minion:
            {
                NSLog(@"\t\tAction: Attacking Enemy Minion");
                if (getTimeInMilliseconds(mach_absolute_time() - lastClickEnemyMinion) >= 100) {
                    lastClickEnemyMinion = mach_absolute_time();
                    tapAttackMove(lowestHealthEnemyMinion->characterCenter.x, lowestHealthEnemyMinion->characterCenter.y);
                }
                if (getTimeInMilliseconds(mach_absolute_time() - lastMoveMouse) >= 17) {
                    lastMoveMouse = mach_absolute_time();
                    moveMouse(lowestHealthEnemyMinion->characterCenter.x, lowestHealthEnemyMinion->characterCenter.y);
                }
                castSpell1();
                castSpell3();
                if (selfChamp->health < 50) {castSpell2();}
            }
                break;
            case ACTION_Attack_Tower:
            {
                NSLog(@"\t\tAction: Attacking Tower");
                if (getTimeInMilliseconds(mach_absolute_time() - lastClickEnemyTower) >= 100) {
                    lastClickEnemyTower = mach_absolute_time();
                    tapAttackMove(nearestEnemyTower->towerCenter.x, nearestEnemyTower->towerCenter.y);
                }
                if (getTimeInMilliseconds(mach_absolute_time() - lastMoveMouse) >= 17) {
                    lastMoveMouse = mach_absolute_time();
                    moveMouse(nearestEnemyTower->towerCenter.x, nearestEnemyTower->towerCenter.y);
                }
                castSpell1();
                castSpell3();
                if (selfChamp->health < 50) {castSpell2();}
            }
                break;
            case ACTION_Follow_Ally_Champion:
            {
                NSLog(@"\t\tAction: Following Ally Champion");
                if (getTimeInMilliseconds(mach_absolute_time() - lastClickAllyChampion) >= 100) {
                    lastClickAllyChampion = mach_absolute_time();
                    int xMove = (nearestAllyChampion->characterCenter.x - selfChamp->characterCenter.x);
                    int yMove = (nearestAllyChampion->characterCenter.y - selfChamp->characterCenter.y);
                    normalizePoint(xMove, yMove, 300);
                    tapAttackMove(xMove + selfChamp->characterCenter.x, yMove + selfChamp->characterCenter.y);
                }
            }
                break;
            case ACTION_Follow_Ally_Minion:
            {
                NSLog(@"\t\tAction: Following Ally Minion");
                if (getTimeInMilliseconds(mach_absolute_time() - lastClickAllyMinion) >= 100) {
                    lastClickAllyMinion = mach_absolute_time();
                    int xMove = (closestAllyMinion->characterCenter.x - selfChamp->characterCenter.x);
                    int yMove = (closestAllyMinion->characterCenter.y - selfChamp->characterCenter.y);
                    normalizePoint(xMove, yMove, 300);
                    tapAttackMove(xMove + selfChamp->characterCenter.x, yMove + selfChamp->characterCenter.y);
                }
            }
                break;
            case ACTION_Move_To_Mid:
            {
                NSLog(@"\t\tAction: Moving to Mid");
                if (getTimeInMilliseconds(mach_absolute_time() - lastMovementClick) >= 500) {
                    //NSLog(@"Time to move");
                    if (mapVisible) {
                        //NSLog(@"Initating click");
                        lastMovementClick = mach_absolute_time();
                        int x = map->center.x;
                        int y = map->center.y;
                        tapMouseRight(x, y);
                    } else {
                        NSLog(@"Map not visible");
                    }
                }
            }
                break;
            case ACTION_Recall:
            {
                NSLog(@"\t\tAction: Recalling");
                castRecall();
            }
                break;
                
            default:
                break;
        }
        
        //lastAction = action;
        
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
    }
}

void BasicAI::processAI() {
    handleAbilityLevelUps();
    handleBuyingItems();
    handleCameraFocus();
    handlePlacingWard();
    handleMovementAndAttacking();
}

void BasicAI::castSpell1() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastSpell1Use) >= 80) {
        if (gameState->detectionManager->getSpell1Available()) {
            tapSpell1();
            lastSpell1Use = mach_absolute_time();
        }
    }
}
void BasicAI::castSpell2() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastSpell2Use) >= 80) {
        if (gameState->detectionManager->getSpell2Available()) {
            tapSpell2();
            lastSpell2Use = mach_absolute_time();
        }
    }
}
void BasicAI::castSpell3() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastSpell3Use) >= 80) {
        if (gameState->detectionManager->getSpell3Available()) {
            tapSpell3();
            lastSpell3Use = mach_absolute_time();
        }
    }
}
void BasicAI::castSpell4() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastSpell4Use) >= 80) {
        if (gameState->detectionManager->getSpell4Available()) {
            tapSpell4();
            lastSpell4Use = mach_absolute_time();
        }
    }
}
void BasicAI::useTrinket() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastPlacedWard) >= 500) {
        if (gameState->detectionManager->getTrinketActiveAvailable()) {
            tapWard();
            lastPlacedWard = mach_absolute_time();
        }
    }
}
void BasicAI::castSummonerSpell1() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastSummonerSpell1Use) >= 80) {
        if (gameState->detectionManager->getSummonerSpell1Available()) {
            tapSummonerSpell1();
            lastSummonerSpell1Use = mach_absolute_time();
        }
    }
}
void BasicAI::castSummonerSpell2() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastSummonerSpell2Use) >= 80) {
        if (gameState->detectionManager->getSummonerSpell2Available()) {
            tapSummonerSpell2();
            lastSummonerSpell2Use = mach_absolute_time();
        }
    }
}
void BasicAI::useItem1() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastItem1Use) >= 80) {
        if (gameState->detectionManager->getItem1ActiveAvailable()) {
            tapActive1();
            lastItem1Use = mach_absolute_time();
        }
    }
}
void BasicAI::useItem2() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastItem2Use) >= 80) {
        if (gameState->detectionManager->getItem2ActiveAvailable()) {
            tapActive2();
            lastItem2Use = mach_absolute_time();
        }
    }
}
void BasicAI::useItem3() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastItem3Use) >= 80) {
        if (gameState->detectionManager->getItem3ActiveAvailable()) {
            tapActive3();
            lastItem3Use = mach_absolute_time();
        }
    }
}
void BasicAI::useItem4() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastItem4Use) >= 80) {
        if (gameState->detectionManager->getItem4ActiveAvailable()) {
            tapActive5();
            lastItem4Use = mach_absolute_time();
        }
    }
}
void BasicAI::useItem5() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastItem5Use) >= 80) {
        if (gameState->detectionManager->getItem5ActiveAvailable()) {
            tapActive6();
            lastItem5Use = mach_absolute_time();
        }
    }
}
void BasicAI::useItem6() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastItem6Use) >= 80) {
        if (gameState->detectionManager->getItem6ActiveAvailable()) {
            tapActive7();
            lastItem6Use = mach_absolute_time();
        }
    }
}
void BasicAI::castRecall() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastRecallTap) >= 1000 * 11) {
        tapRecall();
        lastRecallTap = mach_absolute_time();
    }
}

Champion* getNearestChampion(NSMutableArray* championBars, int x, int y) {
    Champion* closest = nullptr;
    for (int i = 0; i < [championBars count]; i++) {
        Champion* cb = [championBars objectAtIndex:i];
        
        if (i == 0) {
            closest = cb;
        } else if (hypot(closest->characterCenter.x - x, closest->characterCenter.y - y) > hypot(cb->characterCenter.x - x, cb->characterCenter.y - y)) {
            closest = cb;
        }
    }
    return closest;
}
Champion* getLowestHealthChampion(NSMutableArray* championBars, int x, int y) {
    Champion* closest = nullptr;
    for (int i = 0; i < [championBars count]; i++) {
        Champion* cb = [championBars objectAtIndex:i];
        
        if (i == 0) {
            closest = cb;
        } else if (closest->health > cb->health) {
            closest = cb;
        } else if (closest->health == cb->health && hypot(closest->characterCenter.x - x, closest->characterCenter.y - y) > hypot(cb->characterCenter.x - x, cb->characterCenter.y - y)) {
            closest = cb;
        }
    }
    return closest;
}
Minion* getNearestMinion(NSMutableArray* minionBars, int x, int y) {
    Minion* closest = nullptr;
    for (int i = 0; i < [minionBars count]; i++) {
        Minion* cb = [minionBars objectAtIndex:i];
        
        if (i == 0) {
            closest = cb;
        } else if (hypot(closest->characterCenter.x - x, closest->characterCenter.y - y) > hypot(cb->characterCenter.x - x, cb->characterCenter.y - y)) {
            closest = cb;
        }
    }
    return closest;
}
Minion* getLowestHealthMinion(NSMutableArray* minionBars, int x, int y) {
    Minion* closest = nullptr;
    for (int i = 0; i < [minionBars count]; i++) {
        Minion* cb = [minionBars objectAtIndex:i];
        
        if (i == 0) {
            closest = cb;
        } else if (cb->health < closest->health) {
            closest = cb;
        } else if (closest->health == cb->health && hypot(closest->characterCenter.x - x, closest->characterCenter.y - y) > hypot(cb->characterCenter.x - x, cb->characterCenter.y - y)) {
            closest = cb;
        }
    }
    return closest;
}
Tower* getLowestHealthTower(NSMutableArray* towerBars, int x, int y) {
    Tower* closest = nullptr;
    for (int i = 0; i < [towerBars count]; i++) {
        Tower* cb = [towerBars objectAtIndex:i];
        
        if (i == 0) {
            closest = cb;
        } else if (closest->health > cb->health) {
            closest = cb;
        } else if (closest->health == cb->health && hypot(closest->towerCenter.x - x, closest->towerCenter.y - y) > hypot(cb->towerCenter.x - x, cb->towerCenter.y - y)) {
            closest = cb;
        }
    }
    return closest;
}
Tower* getNearestTower(NSMutableArray* towerBars, int x, int y) {
    Tower* closest = nullptr;
    for (int i = 0; i < [towerBars count]; i++) {
        Tower* cb = [towerBars objectAtIndex:i];
        
        if (i == 0) {
            closest = cb;
        } else if (hypot(closest->towerCenter.x - x, closest->towerCenter.y - y) > hypot(cb->towerCenter.x - x, cb->towerCenter.y - y)) {
            closest = cb;
        }
    }
    return closest;
}