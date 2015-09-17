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
    
    activeAutoUseTime = mach_absolute_time();
    
    moveToLane = arc4random_uniform(3) + 1;
    NSLog(@"Chose lane %d", moveToLane);
    moveToLanePathSwitch = mach_absolute_time();
    
    boughtStarterItems = false;
    
    boughtItems = [NSMutableArray new];
    gameCurrentTime = mach_absolute_time();
    
    lastSurrender = mach_absolute_time();
}
void BasicAI::resetAI() {
    baseLocation = CGPointMake(-1, -1);
    
    boughtStarterItems = false;
    [boughtItems removeAllObjects];
    gameCurrentTime = mach_absolute_time();
    lastSurrender = mach_absolute_time();
    
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
    
    activeAutoUseTime = mach_absolute_time();
    
    moveToLane = arc4random_uniform(3) + 1;
    NSLog(@"Chose lane %d", moveToLane);
    moveToLanePathSwitch = mach_absolute_time();
    
    boughtStarterItems = false;
    
    boughtItems = [NSMutableArray new];
    gameCurrentTime = mach_absolute_time();
    
    lastSurrender = mach_absolute_time();
    
    healthGainedPerSecond = 0;
    healthGainedTime = mach_absolute_time();
    lastHealthtimePassed = mach_absolute_time();
    lastHealthAmount = 0.0;
    
    standStillTime = mach_absolute_time();
    
    lastTimeSawEnemyChamp = mach_absolute_time();
}
void BasicAI::handleAbilityLevelUps() {
    int abilityLevelUpOrder[] = {1, 2, 3, 1, 2, 4, 3, 1, 2, 3, 4, 1, 2, 3, 1, 4, 2, 3};
    //Level up an ability as soon as possible but only one ability every 500 milliseconds
    if (getTimeInMilliseconds(mach_absolute_time() - lastLevelUp) >= 500) {
        lastLevelUp = mach_absolute_time();
        bool leveledUp = false;
        if (gameState->detectionManager->getCurrentLevel() < 18) {
            int preferredLevelUp = abilityLevelUpOrder[gameState->detectionManager->getCurrentLevel()];
            if (gameState->detectionManager->getSpell1LevelUpVisible() || gameState->detectionManager->getSpell2LevelUpVisible() || gameState->detectionManager->getSpell3LevelUpVisible() || gameState->detectionManager->getSpell4LevelUpVisible()) {
                if (preferredLevelUp == 1) {
                    levelUpAbility1();
                    leveledUp = true;
                } else if (preferredLevelUp == 2) {
                    levelUpAbility2();
                    leveledUp = true;
                } else if (preferredLevelUp == 3) {
                    levelUpAbility3();
                    leveledUp = true;
                } else if (preferredLevelUp == 4) {
                    levelUpAbility4();
                    leveledUp = true;
                }
            }
            if (gameState->detectionManager->getSpell4LevelUpVisible()) {
                levelUpAbility4();
                leveledUp = true;
            } else if (gameState->detectionManager->getSpell1LevelUpVisible()) {
                levelUpAbility1();
                leveledUp = true;
            } else if (gameState->detectionManager->getSpell2LevelUpVisible()) {
                levelUpAbility2();
                leveledUp = true;
            } else if (gameState->detectionManager->getSpell3LevelUpVisible()) {
                levelUpAbility3();
                leveledUp = true;
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
    if (getTimeInMilliseconds(mach_absolute_time() - lastShopBuy) >= 1000*60*8) {
        if (gameState->detectionManager->getShopAvailable()) {
            
            if (gameState->detectionManager->getShopTopLeftCornerVisible() && gameState->detectionManager->getShopBottomLeftCornerVisible()) {
                lastShopBuy = mach_absolute_time();
                //Buy items
                int bought = 0;
                NSMutableArray* itemsToBuy = gameState->detectionManager->getBuyableItems();
                for (int i = 0; i < [itemsToBuy count]; i++) {
                    GenericObject* item = [itemsToBuy objectAtIndex:i];
                    int clickX = item->center.x;
                    int clickY = item->center.y;
                    if (boughtStarterItems && clickY < gameState->detectionManager->getShopTopLeftCorner()->topLeft.y + 200) {
                        continue; //Skip buying this item because we already bought starter items. No troll build.
                    }
                    //Skip buying this item if we already bought it once
                    bool skipBuying = false;
                    for (GenericObject *boughtItem in boughtItems) {
                        if (abs(boughtItem->topLeft.y - item->topLeft.y) <= 50 &&
                            abs(boughtItem->topLeft.x - item->topLeft.x) <= 50) {
                            skipBuying = true;
                            break;
                        }
                    }
                    if (skipBuying) {
                        continue;
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, i * NSEC_PER_SEC / 1000 * 500), dispatch_get_main_queue(), ^{
                        moveMouse(clickX, clickY);
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, i * NSEC_PER_SEC / 1000 * (500+200)), dispatch_get_main_queue(), ^{
                        tapMouseLeft(clickX, clickY);
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, i * NSEC_PER_SEC / 1000 * (500+400)), dispatch_get_main_queue(), ^{
                        doubleTapMouseLeft(clickX, clickY);
                    });
                    if (bought < 2) {
                        bought++;
                        [boughtItems addObject:item];
                    }
                }
                if ([itemsToBuy count] > 0 && !boughtStarterItems) {
                    boughtStarterItems = true;
                }
                lastShopBuying = mach_absolute_time();
                //NSLog(@"Bought items");
            } else { //Open up the shop
                if (getTimeInMilliseconds(mach_absolute_time() - lastShopOpenTap) >= 8000) {
                    lastShopOpenTap = mach_absolute_time();
                    tapStopMoving();
                    tapShop();
                    //NSLog(@"Opening shop for initial buy");
                }
            }
        } else {
            if (gameState->detectionManager->getShopTopLeftCornerVisible() && gameState->detectionManager->getShopBottomLeftCornerVisible()) {
                closeShop = true;
                //NSLog(@"Shop not available, closing shop");
            }
        }
    } else {
        //Close shop
        if (gameState->detectionManager->getShopTopLeftCornerVisible() && gameState->detectionManager->getShopBottomLeftCornerVisible() &&
            getTimeInMilliseconds(mach_absolute_time() - lastShopBuying) >= 10000) {
            //Gave a 4 seconds to buy
            closeShop = true;
            //NSLog(@"Closing shop because we already bought.");
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
                //NSLog(@"Attempting camera lock cause we don't see ourselves");
            }
        }
    }
}
void BasicAI::handlePlacingWard() {
    if ([gameState->detectionManager->getSelfChampions() count] > 0 && gameState->detectionManager->getTrinketActiveAvailable() &&
        getTimeInMilliseconds(mach_absolute_time() - lastPlacedWard) >= 1500) {
        Champion* champ = [gameState->detectionManager->getSelfChampions() firstObject];
        moveMouse(champ->characterCenter.x, champ->characterCenter.y);
        useTrinket();
        //NSLog(@"Placing ward");
    }
}
const int ACTION_Run_Away = 0, ACTION_Attack_Enemy_Champion = 1, ACTION_Attack_Enemy_Minion = 2, ACTION_Follow_Ally_Champion = 3, ACTION_Follow_Ally_Minion = 4, ACTION_Move_To_Mid = 5, ACTION_Recall = 6, ACTION_Attack_Tower = 7, ACTION_Go_Ham = 8, ACTION_Stand_Still = 9;
void BasicAI::handleMovementAndAttacking() {
    //If we see our selves and the shop is closed, then lets move around
    
    NSMutableArray* selfChampions = gameState->detectionManager->getSelfChampions();
    bool shopTopLeftCornerVisible = gameState->detectionManager->getShopTopLeftCornerVisible();
    //bool mapShopVisible = gameState->detectionManager->getMapShopVisible();
    bool mapVisible = gameState->detectionManager->getMapVisible();
    GenericObject* map = gameState->detectionManager->getMap();
    //GenericObject* mapShop = gameState->detectionManager->getMapShop();
    
    bool earlyGame = getTimeInMilliseconds(mach_absolute_time() - gameCurrentTime) < 1000 * 60 * 8;
    
    CGPoint tempBaseLocation;
    if (baseLocation.x == -1 && mapVisible) {
        //Set base location to blue side by default
        tempBaseLocation.x = (map->topLeft.x - map->bottomRight.x) * 0.1 + map->topLeft.x;
        tempBaseLocation.y = (map->topLeft.y - map->bottomRight.y) * 0.9 + map->topLeft.x;
    }
    if (baseLocation.x == -1) { // Try to set base location
        if (gameState->detectionManager->getMapLocationVisible()) {
            baseLocation.x = gameState->detectionManager->getMapLocation()->center.x;
            baseLocation.y = gameState->detectionManager->getMapLocation()->center.y;
        } else if (gameState->detectionManager->getMapShopVisible()) {
            baseLocation.x = gameState->detectionManager->getMapShop()->center.x;
            baseLocation.y = gameState->detectionManager->getMapShop()->center.y;
        }
    }
    if (baseLocation.x != -1) {
        tempBaseLocation = baseLocation;
    }
    
    //Calculate health gained per second
    //float healthGainedPerSecond;
    //uint64_t healthGainedTime;
    if (gameState->detectionManager->getSelfHealthBarVisible()) {
        float currentHealth = gameState->detectionManager->getSelfHealthBar()->health;
        float gainedHealthInFrame = lastHealthAmount - currentHealth;
        lastHealthAmount = currentHealth;
        healthGainedPerSecond += gainedHealthInFrame * getTimeInMilliseconds(mach_absolute_time() - lastHealthtimePassed)/1000.0;
        lastHealthtimePassed = mach_absolute_time();
    }
    
    
    bool buyingItems = getTimeInMilliseconds(mach_absolute_time() - lastShopBuy) >= 1000*60*8 && gameState->detectionManager->getShopAvailable();
    
    if ([selfChampions count] > 0 && !shopTopLeftCornerVisible && !buyingItems) {
        
        
        int numberOfSelfChamps = (int)selfChampions.count;
        if (numberOfSelfChamps == 0) {
            NSLog(@"We have a problem");
        }
        id firstObject = [selfChampions firstObject];
        Champion* selfChamp = firstObject;
        if (gameState->detectionManager->getSelfHealthBar() != nil) {
            selfChamp->health = gameState->detectionManager->getSelfHealthBar()->health;
        }
        
        NSMutableArray* enemyChampions = gameState->detectionManager->getEnemyChampions();
        NSMutableArray* enemyMinions = gameState->detectionManager->getEnemyMinions();
        NSMutableArray* allyMinions = gameState->detectionManager->getAllyMinions();
        NSMutableArray* allyChampions = gameState->detectionManager->getAllyChampions();
        NSMutableArray* enemyTowers = gameState->detectionManager->getEnemyTowers();
        
        bool enemyChampionsNear = [enemyChampions count] > 0;
        
        if (enemyChampionsNear) {
            lastTimeSawEnemyChamp = mach_absolute_time();
        }
        
        bool enemyMinionsNear = [enemyMinions count] > 0;
        bool allyMinionsNear = [allyMinions count] > 0;
        bool allyChampionsNear = [allyChampions count] > 0;
        bool enemyTowerNear = [enemyTowers count] > 0;
        bool underEnemyTower = false;
        bool enemyChampionWasNear = getTimeInMilliseconds(mach_absolute_time() - lastTimeSawEnemyChamp) <= 1000*10; //Ten seconds
        //bool inEarlyGame = getTimeInMilliseconds(mach_absolute_time() - gameCurrentTime) <= 1000*60*8; //Plays safe for first 8 minutes
        
        Champion* lowestHealthEnemyChampion = getLowestHealthChampion(enemyChampions, selfChamp->characterCenter.x, selfChamp->characterCenter.y);
        Champion* closestEnemyChampion = getNearestChampion(enemyChampions, selfChamp->characterCenter.x, selfChamp->characterCenter.y);
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
            //Only follow ally champions if we're not in base
            if (gameState->detectionManager->getMapLocation() != nil) {
                CGPoint mapLoc = CGPointMake(gameState->detectionManager->getMapLocation()->center.x, gameState->detectionManager->getMapLocation()->center.y);
                if (hypot(mapLoc.x - tempBaseLocation.x, mapLoc.y - tempBaseLocation.y) > 60) {
                    action = ACTION_Follow_Ally_Champion;
                }
            }
        }
        //Oh look free gold, lets get that
        if (enemyMinionsNear) {
            action = ACTION_Attack_Enemy_Minion;
        }
        
        //If on pad stand still
        if (healthGainedPerSecond >= 3.0) { //Gaining 3% health per second
            action = ACTION_Stand_Still;
        }
        if (healthGainedPerSecond <= -5.0) { //Losing health rapidly
            action = ACTION_Run_Away;
        }
        
        //Attack enemy if there are more allies than enemies
        /*
        if (enemyChampionsNear &&
            ([allyChampions count] > [enemyChampions count] || ([allyChampions count] == [enemyChampions count] && [allyChampions count] > 2)) && !earlyGame && [allyChampions count] > 0) {
            
            //Only attack if allies are close
            if (hypot(nearestAllyChampion->characterCenter.x - selfChamp->characterCenter.x, nearestAllyChampion->characterCenter.y - selfChamp->characterCenter.y) < 400 ) {
                action = ACTION_Attack_Enemy_Champion;
            } else {
                action = ACTION_Run_Away;
            }
        } else */if (enemyChampionsNear) {
            //Too many baddies, peace.
            action = ACTION_Run_Away;
        }
        
        if (action == ACTION_Attack_Enemy_Minion && enemyTowerNear) {
            if (hypot(lowestHealthEnemyMinion->characterCenter.x - nearestEnemyTower->towerCenter.x, lowestHealthEnemyMinion->characterCenter.y - nearestEnemyTower->towerCenter.y) < 430) {
                action = ACTION_Run_Away;
                
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
        /*
        bool enemyChampionCloseEnough = false;
        if ([enemyChampions count] > 0) {
            Champion* closeEnemyChampion = getNearestChampion(enemyChampions, selfChamp->characterCenter.x, selfChamp->characterCenter.y);
            if (hypot(closeEnemyChampion->characterCenter.x - selfChamp->characterCenter.x, closeEnemyChampion->characterCenter.y - selfChamp->characterCenter.y) < 600) {
                enemyChampionCloseEnough = true;
            }
        }*/
        if (selfChamp->health < 50 && (enemyMinionsNear || underEnemyTower || enemyChampionsNear || enemyChampionWasNear)) {
            action = ACTION_Run_Away;
        } else if (selfChamp->health < 50 && !enemyChampionsNear && !underEnemyTower) {
            if (selfChamp->health > 35 && !enemyChampionWasNear) {
                action = ACTION_Recall;
            } else {
                action = ACTION_Run_Away;
            }
        } else if (selfChamp->health <= 35) {
            action = ACTION_Run_Away;
        }
        if (gameState->detectionManager->getPotionActiveAvailable() && selfChamp->health < 80) {
            if (gameState->detectionManager->getPotionActiveItemSlot() == 1) useItem1();
            if (gameState->detectionManager->getPotionActiveItemSlot() == 2) useItem2();
            if (gameState->detectionManager->getPotionActiveItemSlot() == 3) useItem3();
            if (gameState->detectionManager->getPotionActiveItemSlot() == 4) useItem4();
            if (gameState->detectionManager->getPotionActiveItemSlot() == 5) useItem5();
            if (gameState->detectionManager->getPotionActiveItemSlot() == 6) useItem6();
        }
        
        //Go ham
        if (enemyChampionsNear && lowestHealthEnemyChampion->health < 5 && !earlyGame) {
            action = ACTION_Go_Ham;
        }
        
        if (action == ACTION_Attack_Enemy_Minion && [allyMinions count] < 2) {
            action = ACTION_Run_Away;
        }
        
        //int actionSpeed = 0.25;
        
        switch (action) {
            case ACTION_Run_Away:
            {
                //NSLog(@"\t\tAction: Running Away");
                if (getTimeInMilliseconds(mach_absolute_time() - lastRunAwayClick) >= 700) {
                    tapMouseRight(baseLocation.x, baseLocation.y);
                    lastRunAwayClick = mach_absolute_time();
                }
                
                if (selfChamp->health < 40 && enemyChampionsNear) {
                    int enemyX = (closestEnemyChampion->characterCenter.x - selfChamp->characterCenter.x);
                    int enemyY = (closestEnemyChampion->characterCenter.y - selfChamp->characterCenter.y);
                    normalizePoint(enemyX, enemyY, 300);
                    //enemyX = -enemyX;
                    //enemyY = -enemyY;
                    //Panic
                    if (getTimeInMilliseconds(mach_absolute_time() - lastMoveMouse) >= 50) {
                        lastMoveMouse = mach_absolute_time();
                        moveMouse(enemyX, enemyY);
                        castSpell4();
                        castSpell2();
                        useTrinket();
                        moveMouse(-enemyX, -enemyY);
                        castSummonerSpell1();
                        castSummonerSpell2();
                        useItem1();
                        useItem2();
                        useItem3();
                        useItem4();
                        useItem5();
                        useItem6();
                    }
                }
            }
                break;
            case ACTION_Attack_Enemy_Champion:
            case ACTION_Go_Ham:
            {
                //NSLog(@"\t\tAction: Attacking enemy champion");
                int x = lowestHealthEnemyChampion->characterCenter.x;
                int y = lowestHealthEnemyChampion->characterCenter.y;
                if (getTimeInMilliseconds(mach_absolute_time() - lastClickEnemyChamp) >= 500) {
                    lastClickEnemyChamp = mach_absolute_time();
                    tapAttackMove(lowestHealthEnemyChampion->characterCenter.x, lowestHealthEnemyChampion->characterCenter.y);
                }
                if (getTimeInMilliseconds(mach_absolute_time() - lastMoveMouse) >= 50) {
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
                //NSLog(@"\t\tAction: Attacking Enemy Minion");
                if (getTimeInMilliseconds(mach_absolute_time() - lastClickEnemyMinion) >= 100) {
                    lastClickEnemyMinion = mach_absolute_time();
                    tapAttackMove(lowestHealthEnemyMinion->characterCenter.x, lowestHealthEnemyMinion->characterCenter.y);
                }
                if (getTimeInMilliseconds(mach_absolute_time() - lastMoveMouse) >= 50) {
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
                //NSLog(@"\t\tAction: Attacking Tower");
                if (getTimeInMilliseconds(mach_absolute_time() - lastClickEnemyTower) >= 100) {
                    lastClickEnemyTower = mach_absolute_time();
                    tapAttackMove(nearestEnemyTower->towerCenter.x, nearestEnemyTower->towerCenter.y);
                }
                if (getTimeInMilliseconds(mach_absolute_time() - lastMoveMouse) >= 50) {
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
                //NSLog(@"\t\tAction: Following Ally Champion");
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
                //NSLog(@"\t\tAction: Following Ally Minion");
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
                //NSLog(@"\t\tAction: Moving to Mid");
                
                if (getTimeInMilliseconds(mach_absolute_time() - moveToLanePathSwitch) >= 1000 * 60 * 5) {
                    //Switch to a random lane
                    moveToLane = arc4random_uniform(3) + 1;
                    moveToLanePathSwitch = mach_absolute_time();
                }
                
                if (getTimeInMilliseconds(mach_absolute_time() - lastMovementClick) >= 500) {
                    //NSLog(@"Time to move");
                    if (mapVisible) {
                        //NSLog(@"Initating click");
                        lastMovementClick = mach_absolute_time();
                        int x = map->center.x;
                        int y = map->center.y;
                        if (moveToLane == 1) {
                            x = (map->bottomRight.x - map->topLeft.x) * 0.1 + map->topLeft.x;
                            y = (map->bottomRight.y - map->topLeft.y) * 0.1 + map->topLeft.y;
                        }
                        if (moveToLane == 3) {
                            x = (map->bottomRight.x - map->topLeft.x) * 0.9 + map->topLeft.x;
                            y = (map->bottomRight.y - map->topLeft.y) * 0.9 + map->topLeft.y;
                        }
                        tapMouseRight(x, y);
                    }// else {
                    //    NSLog(@"Map not visible");
                    //}
                }
            }
                break;
            case ACTION_Recall:
            {
                //NSLog(@"\t\tAction: Recalling");
                castRecall();
            }
                break;
            case ACTION_Stand_Still:
            {
                if (getTimeInMilliseconds(mach_absolute_time() - standStillTime) >= 500) {
                    standStillTime = mach_absolute_time();
                    tapStopMoving();
                }
            }
                
            default:
                break;
        }
        if (getTimeInMilliseconds(mach_absolute_time() - activeAutoUseTime) >= 1000 * 60 * 5) {
            activeAutoUseTime = mach_absolute_time();
            moveMouse(selfChamp->characterCenter.x, selfChamp->characterCenter.y);
            //Use all actives
            useItem1();
            useItem2();
            useItem3();
            useItem4();
            useItem5();
            useItem6();
            useTrinket();
        }
    } else if (mapVisible && !shopTopLeftCornerVisible && !buyingItems) {
        if (getTimeInMilliseconds(mach_absolute_time() - moveToLanePathSwitch) >= 1000 * 60 * 2) {
            //Switch to a random lane
            moveToLane = arc4random_uniform(3) + 1;
            moveToLanePathSwitch = mach_absolute_time();
        }
        
        if (getTimeInMilliseconds(mach_absolute_time() - lastMovementClick) >= 500) {
            //NSLog(@"Time to move");
            if (mapVisible) {
                //NSLog(@"Initating click");
                lastMovementClick = mach_absolute_time();
                int x = map->center.x;
                int y = map->center.y;
                if (moveToLane == 1) {
                    x = (map->bottomRight.x - map->topLeft.x) * 0.1 + map->topLeft.x;
                    y = (map->bottomRight.y - map->topLeft.y) * 0.1 + map->topLeft.y;
                }
                if (moveToLane == 3) {
                    x = (map->bottomRight.x - map->topLeft.x) * 0.9 + map->topLeft.x;
                    y = (map->bottomRight.y - map->topLeft.y) * 0.9 + map->topLeft.y;
                }
                tapMouseRight(x, y);
            }// else {
            //    NSLog(@"Map not visible");
            //}
        }
    }
    if (getTimeInMilliseconds(mach_absolute_time() - healthGainedTime) >= 1000) {
        healthGainedPerSecond = 0.1;
        healthGainedTime = mach_absolute_time();
    }
}

void BasicAI::processAI() {
    handleAbilityLevelUps();
    handleBuyingItems();
    handleCameraFocus();
    handlePlacingWard();
    handleMovementAndAttacking();
    
    if (getTimeInMilliseconds(mach_absolute_time() - lastSurrender) >= 1000 && gameState->detectionManager->getSurrenderAvailable()) {
        lastSurrender = mach_absolute_time();
        GenericObject* surrender = gameState->detectionManager->getSurrender();
        tapMouseLeft(surrender->center.x, surrender->center.y);
    }
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
            //NSLog(@"Placed Ward");
        }
    }
}
void BasicAI::castSummonerSpell1() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastSummonerSpell1Use) >= 200) {
        if (gameState->detectionManager->getSummonerSpell1Available()) {
            tapSummonerSpell1();
            lastSummonerSpell1Use = mach_absolute_time();
        }
    }
}
void BasicAI::castSummonerSpell2() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastSummonerSpell2Use) >= 200) {
        if (gameState->detectionManager->getSummonerSpell2Available()) {
            tapSummonerSpell2();
            lastSummonerSpell2Use = mach_absolute_time();
        }
    }
}
void BasicAI::useItem1() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastItem1Use) >= 200) {
        //if (gameState->detectionManager->getItem1ActiveAvailable()) {
        tapActive1();
        lastItem1Use = mach_absolute_time();
        //}
    }
    
}
void BasicAI::useItem2() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastItem2Use) >= 200) {
        //if (gameState->detectionManager->getItem2ActiveAvailable()) {
        tapActive2();
        lastItem2Use = mach_absolute_time();
        //}
    }
}
void BasicAI::useItem3() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastItem3Use) >= 200) {
        //if (gameState->detectionManager->getItem3ActiveAvailable()) {
        tapActive3();
        lastItem3Use = mach_absolute_time();
        //}
    }
}
void BasicAI::useItem4() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastItem4Use) >= 200) {
        //if (gameState->detectionManager->getItem4ActiveAvailable()) {
        tapActive5();
        lastItem4Use = mach_absolute_time();
        //}
    }
}
void BasicAI::useItem5() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastItem5Use) >= 200) {
        //if (gameState->detectionManager->getItem5ActiveAvailable()) {
        tapActive6();
        lastItem5Use = mach_absolute_time();
        //}
    }
}
void BasicAI::useItem6() {
    if (getTimeInMilliseconds(mach_absolute_time() - lastItem6Use) >= 200) {
        //if (gameState->detectionManager->getItem6ActiveAvailable()) {
        tapActive7();
        lastItem6Use = mach_absolute_time();
        //}
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