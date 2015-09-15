//
//  DetectionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 9/1/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "DetectionManager.h"
#import "SelfChampionManager.h"
#import "AllyChampionManager.h"
#import "EnemyChampionManager.h"
#import "EnemyMinionManager.h"
#import "AllyMinionManager.h"
#import "EnemyTowerManager.h"
#import "AbilityManager.h"
#import "ItemManager.h"
#import "ShopManager.h"
#import "MapManager.h"
#import "SurrenderManager.h"

const int longAlert = 13;

DetectionManager::DetectionManager(dispatch_queue_t _aiThread, dispatch_queue_t _detectionThread) {
    aiThread = _aiThread;
    detectionThread = _detectionThread;
    
    
    itemActive1Thread = dispatch_queue_create("Item Active 1 Thread", DISPATCH_QUEUE_CONCURRENT);
    itemActive2Thread = dispatch_queue_create("Item Active 2 Thread", DISPATCH_QUEUE_CONCURRENT);
    itemActive3Thread = dispatch_queue_create("Item Active 3 Thread", DISPATCH_QUEUE_CONCURRENT);
    itemActive4Thread = dispatch_queue_create("Item Active 4 Thread", DISPATCH_QUEUE_CONCURRENT);
    itemActive5Thread = dispatch_queue_create("Item Active 5 Thread", DISPATCH_QUEUE_CONCURRENT);
    itemActive6Thread = dispatch_queue_create("Item Active 6 Thread", DISPATCH_QUEUE_CONCURRENT);
    
    mapThread = dispatch_queue_create("Map Thread", DISPATCH_QUEUE_CONCURRENT);
    shopThread = dispatch_queue_create("Shop Thread", DISPATCH_QUEUE_CONCURRENT);
    shopAvailableThread = dispatch_queue_create("Shop Available Thread", DISPATCH_QUEUE_CONCURRENT);
    usedPotionThread = dispatch_queue_create("Used Potion Thread", DISPATCH_QUEUE_CONCURRENT);
    trinketActiveThread = dispatch_queue_create("Trinket Active Thread", DISPATCH_QUEUE_CONCURRENT);
    spell1ActiveThread = dispatch_queue_create("Spell 1 Active Thread", DISPATCH_QUEUE_CONCURRENT);
    spell2ActiveThread = dispatch_queue_create("Spell 2 Active Thread", DISPATCH_QUEUE_CONCURRENT);
    spell3ActiveThread = dispatch_queue_create("Spell 3 Active Thread", DISPATCH_QUEUE_CONCURRENT);
    spell4ActiveThread = dispatch_queue_create("Spell 4 Active Thread", DISPATCH_QUEUE_CONCURRENT);
    summonerSpell1ActiveThread = dispatch_queue_create("Summoner Spell 1 Active Thread", DISPATCH_QUEUE_CONCURRENT);
    summonerSpell2ActiveThread = dispatch_queue_create("Summoner Spell 2 Active Thread", DISPATCH_QUEUE_CONCURRENT);
    levelUpDotsThread = dispatch_queue_create("Level Up Dots Thread", DISPATCH_QUEUE_CONCURRENT);
    spell1LevelUpThread = dispatch_queue_create("Spell 1 Level Up Thread", DISPATCH_QUEUE_CONCURRENT);
    spell2LevelUpThread = dispatch_queue_create("Spell 2 Level Up Thread", DISPATCH_QUEUE_CONCURRENT);
    spell3LevelUpThread = dispatch_queue_create("Spell 3 Level Up Thread", DISPATCH_QUEUE_CONCURRENT);
    spell4LevelUpThread = dispatch_queue_create("Spell 4 Level Up Thread", DISPATCH_QUEUE_CONCURRENT);
    allyMinionThread = dispatch_queue_create("Ally Minion Thread", DISPATCH_QUEUE_CONCURRENT);
    enemyMinionThread = dispatch_queue_create("Enemy Minion Thread", DISPATCH_QUEUE_CONCURRENT);
    enemyChampionThread = dispatch_queue_create("Enemy Champion Thread", DISPATCH_QUEUE_CONCURRENT);
    allyChampionThread = dispatch_queue_create("Ally Champion Thread", DISPATCH_QUEUE_CONCURRENT);
    enemyTowerThread = dispatch_queue_create("Enemy Tower Thread", DISPATCH_QUEUE_CONCURRENT);
    selfChampionThread = dispatch_queue_create("Self Champion Thread", DISPATCH_QUEUE_CONCURRENT);
    selfHealthBarThread = dispatch_queue_create("Self Health Bar Thread", DISPATCH_QUEUE_CONCURRENT);
    surrenderThread = dispatch_queue_create("Surrender Thread", DISPATCH_QUEUE_CONCURRENT);
    
    
    allyMinions = [NSMutableArray new];
    enemyMinions = [NSMutableArray new];
    allyChampions = [NSMutableArray new];
    enemyChampions = [NSMutableArray new];
    selfChampions = [NSMutableArray new];
    enemyTowers = [NSMutableArray new];
    buyableItems = [NSMutableArray new];
    spell1LevelDots = [NSMutableArray new];
    spell2LevelDots = [NSMutableArray new];
    spell3LevelDots = [NSMutableArray new];
    spell4LevelDots = [NSMutableArray new];
    
    processAllyMinionLastTime = mach_absolute_time();
    processEnemyMinionLastTime = mach_absolute_time();
    processAllyChampionLastTime = mach_absolute_time();
    processEnemyChampionLastTime = mach_absolute_time();
    processEnemyTowerLastTime = mach_absolute_time();
    processSelfChampionLastTime = mach_absolute_time();
    processSelfHealthBarLastTime = mach_absolute_time();
    processShopLastTime = mach_absolute_time();
    
    surrenderAvailable = false;
    surrenderActive = nil;
    /*
    allyMinionsDetectionObject = [NSMutableArray new];
    allyMinionsDetectionObject = [NSMutableArray new];
    selfChampionsDetectionObject = [NSMutableArray new];
    enemyTowersDetectionObject = [NSMutableArray new];
    allyChampionsDetectionObject = [NSMutableArray new];
    enemyChampionsDetectionObject = [NSMutableArray new];
    
    mapDetectionObject = nullptr;
    shopTopLeftCornerDetectionObject = nullptr;*/
}
/*
 void DetectionManager::processDetection(ImageData image) {
 uint64_t startTime = mach_absolute_time();
 
 dispatch_group_t dispatchGroup = dispatch_group_create();
 
 processAllyMinionDetection(image, dispatchGroup);
 processEnemyMinionDetection(image, dispatchGroup);
 processAllyChampionDetection(image, dispatchGroup);
 processEnemyChampionDetection(image, dispatchGroup);
 processEnemyTowerDetection(image, dispatchGroup);
 processSelfChampionDetection(image, dispatchGroup);
 processSelfHealthBarDetection(image, dispatchGroup);
 processSpellLevelUps(image, dispatchGroup);
 processSpellLevelDots(image, dispatchGroup);
 processSpellActives(image, dispatchGroup);
 processSummonerSpellActives(image, dispatchGroup);
 processItemActives(image, dispatchGroup);
 processUsedPotion(image, dispatchGroup);
 processShopAvailable(image, dispatchGroup);
 processShop(image, dispatchGroup);
 processMap(image, dispatchGroup);
 
 dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
 
 if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
 //NSLog(@"Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
 }
 }*/
void DetectionManager::processDetection(ImageData image) {
    
    @autoreleasepool {
        //if (scanningScreen) {
        //    //NSLog(@"Screen is being scanned");
        //}
        
        //scanningScreen = true;
        
        
        //uint64_t overallStartTime = mach_absolute_time();
        
        //uint64_t startTime = mach_absolute_time();
        
        dispatch_group_t dispatchGroup = dispatch_group_create();
        
        processAllyMinionDetection(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processAllyMinionDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processEnemyMinionDetection(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processEnemyMinionDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processAllyChampionDetection(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processAllyChampionDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processEnemyChampionDetection(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processEnemyChampionDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processEnemyTowerDetection(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processEnemyTowerDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processSelfChampionDetection(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processSelfChampionDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processSelfHealthBarDetection(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processSelfHealthBarDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processSpellLevelUps(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processSpellLevelUps detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processSpellLevelDots(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processSpellLevelDots detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processSpellActives(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processSpellActives detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processSummonerSpellActives(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processSummonerSpellActives detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //uint64_t startTime3 = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        ////NSLog(@"dispatch group creation time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime3));
        
        //startTime3 = mach_absolute_time();
        processItemActives(image, dispatchGroup);
        ////NSLog(@"processItemActives(image, dispatchGroup) time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime3));
        
        //startTime3 = mach_absolute_time();
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        ////NSLog(@"dispatch_group_wait time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime3));
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        ////NSLog(@"processItemActives detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processUsedPotion(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processUsedPotion detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processShopAvailable(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processShopAvailable detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processShop(image, dispatchGroup);
        
        //dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processShop detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //dispatchGroup = dispatch_group_create();
        
        processMap(image, dispatchGroup);
        
        processTrinketActive(image, dispatchGroup);
        
        processSurrender(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    //NSLog(@"processMap detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        
        //if (getTimeInMilliseconds(mach_absolute_time() - overallStartTime) > longAlert) {
        //    //NSLog(@"\tOverall detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - overallStartTime));
        //}
        
        //scanningScreen = false;
    }
}
/*
NSMutableArray* DetectionManager::getAllyMinions() {
    //__block NSMutableArray* minions = [NSMutableArray new];
    //dispatch_sync(detectionThread, ^(void) {
        //minions = allyMinions;
    //    [minions addObjectsFromArray:allyMinions];
    //});
    //return minions;
}
NSMutableArray* DetectionManager::getEnemyMinions() {
    __block NSMutableArray* minions;
    dispatch_sync(detectionThread, ^(void) {
        minions = enemyMinions;
    });
    return minions;
}
NSMutableArray* DetectionManager::getAllyChampions() {
    __block NSMutableArray* champions;
    dispatch_sync(detectionThread, ^(void) {
        champions = allyChampions;
    });
    return champions;
}
NSMutableArray* DetectionManager::getEnemyChampions() {
    __block NSMutableArray* champions;
    dispatch_sync(detectionThread, ^(void) {
        champions = enemyChampions;
    });
    return champions;
}
NSMutableArray* DetectionManager::getEnemyTowers() {
    __block NSMutableArray* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = enemyTowers;
    });
    return returnVar;
}
NSMutableArray* DetectionManager::getSelfChampions() {
    __block NSMutableArray* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = selfChampions;
    });
    return returnVar;
}
bool DetectionManager::getSelfHealthBarVisible() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = selfHealthBarVisible;
    });
    return returnVar;
}
SelfHealth* DetectionManager::getSelfHealthBar() {
    __block SelfHealth* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = selfHealthBar;
    });
    return returnVar;
}
bool DetectionManager::getSpell1LevelUpVisible() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell1LevelUpAvailable;
    });
    return returnVar;
}
bool DetectionManager::getSpell2LevelUpVisible() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell2LevelUpAvailable;
    });
    return returnVar;
}
bool DetectionManager::getSpell3LevelUpVisible() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell3LevelUpAvailable;
    });
    return returnVar;
}
bool DetectionManager::getSpell4LevelUpVisible() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell4LevelUpAvailable;
    });
    return returnVar;
}
GenericObject* DetectionManager::getSpell1LevelUp() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell1LevelUp;
    });
    return returnVar;
}
GenericObject* DetectionManager::getSpell2LevelUp() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell2LevelUp;
    });
    return returnVar;
}
GenericObject* DetectionManager::getSpell3LevelUp() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell3LevelUp;
    });
    return returnVar;
}
GenericObject* DetectionManager::getSpell4LevelUp() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell4LevelUp;
    });
    return returnVar;
}
NSMutableArray* DetectionManager::getSpell1LevelDots() {
    __block NSMutableArray* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell1LevelDots;
    });
    return returnVar;
}
NSMutableArray* DetectionManager::getSpell2LevelDots() {
    __block NSMutableArray* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell2LevelDots;
    });
    return returnVar;
}
NSMutableArray* DetectionManager::getSpell3LevelDots() {
    __block NSMutableArray* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell3LevelDots;
    });
    return returnVar;
}
NSMutableArray* DetectionManager::getSpell4LevelDots() {
    __block NSMutableArray* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell4LevelDots;
    });
    return returnVar;
}
int DetectionManager::getCurrentLevel() {
    __block int returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = currentLevel;
    });
    return returnVar;
}
bool DetectionManager::getSpell1Available() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell1ActiveAvailable;
    });
    return returnVar;
}
bool DetectionManager::getSpell2Available() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell2ActiveAvailable;
    });
    return returnVar;
}
bool DetectionManager::getSpell3Available() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell3ActiveAvailable;
    });
    return returnVar;
}
bool DetectionManager::getSpell4Available() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell4ActiveAvailable;
    });
    return returnVar;
}
GenericObject* DetectionManager::getSpell1() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell1Active;
    });
    return returnVar;
}
GenericObject* DetectionManager::getSpell2() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell2Active;
    });
    return returnVar;
}
GenericObject* DetectionManager::getSpell3() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell3Active;
    });
    return returnVar;
}
GenericObject* DetectionManager::getSpell4() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = spell4Active;
    });
    return returnVar;
}
bool DetectionManager::getSummonerSpell1Available() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = summonerSpell1ActiveAvailable;
    });
    return returnVar;
}
bool DetectionManager::getSummonerSpell2Available() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = summonerSpell2ActiveAvailable;
    });
    return returnVar;
}
GenericObject* DetectionManager::getSummonerSpell1() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = summonerSpell1Active;
    });
    return returnVar;
}
GenericObject* DetectionManager::getSummonerSpell2() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = summonerSpell2Active;
    });
    return returnVar;
}
bool DetectionManager::getTrinketActiveAvailable() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = trinketActiveAvailable;
    });
    return returnVar;
}
GenericObject* DetectionManager::getTrinketActive() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = trinketActive;
    });
    return returnVar;
}
bool DetectionManager::getItem1ActiveAvailable() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = item1ActiveAvailable;
    });
    return returnVar;
}
bool DetectionManager::getItem2ActiveAvailable() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = item2ActiveAvailable;
    });
    return returnVar;
}
bool DetectionManager::getItem3ActiveAvailable() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = item3ActiveAvailable;
    });
    return returnVar;
}
bool DetectionManager::getItem4ActiveAvailable() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = item4ActiveAvailable;
    });
    return returnVar;
}
bool DetectionManager::getItem5ActiveAvailable() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = item5ActiveAvailable;
    });
    return returnVar;
}
bool DetectionManager::getItem6ActiveAvailable() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = item6ActiveAvailable;
    });
    return returnVar;
}
GenericObject* DetectionManager::getItem1Active() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = item1Active;
    });
    return returnVar;
}
GenericObject* DetectionManager::getItem2Active() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = item2Active;
    });
    return returnVar;
}
GenericObject* DetectionManager::getItem3Active() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = item3Active;
    });
    return returnVar;
}
GenericObject* DetectionManager::getItem4Active() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = item4Active;
    });
    return returnVar;
}
GenericObject* DetectionManager::getItem5Active() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = item5Active;
    });
    return returnVar;
}
GenericObject* DetectionManager::getItem6Active() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = item6Active;
    });
    return returnVar;
}
bool DetectionManager::getPotionActiveAvailable() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = potionActiveAvailable;
    });
    return returnVar;
}
GenericObject* DetectionManager::getPotionActive() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = potionActive;
    });
    return returnVar;
}
bool DetectionManager::getPotionBeingUsedVisible() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = potionBeingUsedShown;
    });
    return returnVar;
}
GenericObject* DetectionManager::getPotionBeingUsed() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = potionBeingUsed;
    });
    return returnVar;
}
bool DetectionManager::getShopAvailable() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = shopAvailableShown;
    });
    return returnVar;
}
GenericObject* DetectionManager::getShopAvailableObject() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = shopAvailable;
    });
    return returnVar;
}
bool DetectionManager::getShopTopLeftCornerVisible() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = shopTopLeftCornerShown;
    });
    return returnVar;
}
GenericObject* DetectionManager::getShopTopLeftCorner() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = shopTopLeftCorner;
    });
    return returnVar;
}
bool DetectionManager::getShopBottomLeftCornerVisible() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = shopBottomLeftCornerShown;
    });
    return returnVar;
}
GenericObject* DetectionManager::getShopBottomleftCorner() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = shopBottomLeftCorner;
    });
    return returnVar;
}
NSMutableArray* DetectionManager::getBuyableItems() {
    __block NSMutableArray* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = buyableItems;
    });
    return returnVar;
}
bool DetectionManager::getMapVisible() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = mapVisible;
    });
    return returnVar;
}
GenericObject* DetectionManager::getMap() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = map;
    });
    return returnVar;
}
bool DetectionManager::getMapShopVisible() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = mapShopVisible;
    });
    return returnVar;
}
GenericObject* DetectionManager::getMapShop() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = mapShop;
    });
    return returnVar;
}
bool DetectionManager::getMapLocationVisible() {
    __block bool returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = mapSelfLocationVisible;
    });
    return returnVar;
}
GenericObject* DetectionManager::getMapLocation() {
    __block GenericObject* returnVar;
    dispatch_sync(detectionThread, ^(void) {
        returnVar = mapSelfLocation;
    });
    return returnVar;
}*/
int DetectionManager::getPotionActiveItemSlot() {
    return potionOnActive;
}
bool DetectionManager::getSurrenderAvailable() {
    return surrenderAvailable;
}
GenericObject* DetectionManager::getSurrender() {
    return surrenderActive;
}
NSMutableArray* DetectionManager::getAllyMinions() {
    return allyMinions;
}
NSMutableArray* DetectionManager::getEnemyMinions() {
    return enemyMinions;
}
NSMutableArray* DetectionManager::getAllyChampions() {
    return allyChampions;
}
NSMutableArray* DetectionManager::getEnemyChampions() {
    return enemyChampions;
}
NSMutableArray* DetectionManager::getEnemyTowers() {
    return enemyTowers;
}
NSMutableArray* DetectionManager::getSelfChampions() {
    return selfChampions;
}
bool DetectionManager::getSelfHealthBarVisible() {
    return selfHealthBarVisible;
}
SelfHealth* DetectionManager::getSelfHealthBar() {
    return selfHealthBar;
}
bool DetectionManager::getSpell1LevelUpVisible() {
    return spell1LevelUpAvailable;
}
bool DetectionManager::getSpell2LevelUpVisible() {
    return spell2LevelUpAvailable;
}
bool DetectionManager::getSpell3LevelUpVisible() {
    return spell3LevelUpAvailable;
}
bool DetectionManager::getSpell4LevelUpVisible() {
    return spell4LevelUpAvailable;
}
GenericObject* DetectionManager::getSpell1LevelUp() {
    return spell1LevelUp;
}
GenericObject* DetectionManager::getSpell2LevelUp() {
    return spell2LevelUp;
}
GenericObject* DetectionManager::getSpell3LevelUp() {
    return spell3LevelUp;
}
GenericObject* DetectionManager::getSpell4LevelUp() {
    return spell4LevelUp;
}
NSMutableArray* DetectionManager::getSpell1LevelDots() {
    return spell1LevelDots;
}
NSMutableArray* DetectionManager::getSpell2LevelDots() {
    return spell2LevelDots;
}
NSMutableArray* DetectionManager::getSpell3LevelDots() {
    return spell3LevelDots;
}
NSMutableArray* DetectionManager::getSpell4LevelDots() {
    return spell4LevelDots;
}
int DetectionManager::getCurrentLevel() {
    return currentLevel;
}
bool DetectionManager::getSpell1Available() {
    return spell1ActiveAvailable;
}
bool DetectionManager::getSpell2Available() {
    return spell2ActiveAvailable;
}
bool DetectionManager::getSpell3Available() {
    return spell3ActiveAvailable;
}
bool DetectionManager::getSpell4Available() {
    return spell4ActiveAvailable;
}
GenericObject* DetectionManager::getSpell1() {
    return spell1Active;
}
GenericObject* DetectionManager::getSpell2() {
    return spell2Active;
}
GenericObject* DetectionManager::getSpell3() {
    return spell3Active;
}
GenericObject* DetectionManager::getSpell4() {
    return spell4Active;
}
bool DetectionManager::getSummonerSpell1Available() {
    return summonerSpell1ActiveAvailable;
}
bool DetectionManager::getSummonerSpell2Available() {
    return summonerSpell2ActiveAvailable;
}
GenericObject* DetectionManager::getSummonerSpell1() {
    return summonerSpell1Active;
}
GenericObject* DetectionManager::getSummonerSpell2() {
    return summonerSpell2Active;
}
bool DetectionManager::getTrinketActiveAvailable() {
    return trinketActiveAvailable;
}
GenericObject* DetectionManager::getTrinketActive() {
    return trinketActive;
}
bool DetectionManager::getItem1ActiveAvailable() {
    return item1ActiveAvailable;
}
bool DetectionManager::getItem2ActiveAvailable() {
    return item2ActiveAvailable;
}
bool DetectionManager::getItem3ActiveAvailable() {
    return item3ActiveAvailable;
}
bool DetectionManager::getItem4ActiveAvailable() {
    return item4ActiveAvailable;
}
bool DetectionManager::getItem5ActiveAvailable() {
    return item5ActiveAvailable;
}
bool DetectionManager::getItem6ActiveAvailable() {
    return item6ActiveAvailable;
}
GenericObject* DetectionManager::getItem1Active() {
    return item1Active;
}
GenericObject* DetectionManager::getItem2Active() {
    return item2Active;
}
GenericObject* DetectionManager::getItem3Active() {
    return item3Active;
}
GenericObject* DetectionManager::getItem4Active() {
    return item4Active;
}
GenericObject* DetectionManager::getItem5Active() {
    return item5Active;
}
GenericObject* DetectionManager::getItem6Active() {
    return item6Active;
}
bool DetectionManager::getPotionActiveAvailable() {
    return potionActiveAvailable;
}
GenericObject* DetectionManager::getPotionActive() {
    return potionActive;
}
bool DetectionManager::getPotionBeingUsedVisible() {
    return potionBeingUsedShown;
}
GenericObject* DetectionManager::getPotionBeingUsed() {
    return potionBeingUsed;
}
bool DetectionManager::getShopAvailable() {
    return shopAvailableShown;
}
GenericObject* DetectionManager::getShopAvailableObject() {
    return shopAvailable;
}
bool DetectionManager::getShopTopLeftCornerVisible() {
    return shopTopLeftCornerShown;
}
GenericObject* DetectionManager::getShopTopLeftCorner() {
    return shopTopLeftCorner;
}
bool DetectionManager::getShopBottomLeftCornerVisible() {
    return shopBottomLeftCornerShown;
}
GenericObject* DetectionManager::getShopBottomleftCorner() {
    return shopBottomLeftCorner;
}
NSMutableArray* DetectionManager::getBuyableItems() {
    return buyableItems;
}
bool DetectionManager::getMapVisible() {
    return mapVisible;
}
GenericObject* DetectionManager::getMap() {
    return map;
}
bool DetectionManager::getMapShopVisible() {
    return mapShopVisible;
}
GenericObject* DetectionManager::getMapShop() {
    return mapShop;
}
bool DetectionManager::getMapLocationVisible() {
    return mapSelfLocationVisible;
}
GenericObject* DetectionManager::getMapLocation() {
    return mapSelfLocation;
}

void DetectionManager::processMap(ImageData image, dispatch_group_t dispatchGroup) {
    //First we do an immediate map location search
    //If the map is found them we search for shop and self location
    
    CGPoint searchStart = CGPointMake(image.imageWidth - 290, image.imageHeight - 290);
    CGPoint searchEnd = CGPointMake(image.imageWidth - 270, image.imageHeight - 270);
    
    int oldMapX = -1;
    int oldMapY = -1;
    if (map != nullptr) {
        oldMapX = map->topLeft.x;
        oldMapY = map->topLeft.y;
    }
    
    dispatch_group_async(dispatchGroup, mapThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            
            
            GenericObject* foundMap = nullptr;
            GenericObject* foundLocation = nullptr;
            GenericObject* foundShop = nullptr;
            
            if (oldMapX != -1) {
                uint8* pixel = getPixel2(image, oldMapX, oldMapY);
                foundMap = MapManager::detectMap(image, pixel, oldMapX, oldMapY);
            }
            
            if (foundMap == nullptr) {
                for (int x = searchStart.x; x < searchEnd.x; x++) {
                    for (int y = searchStart.y; y < searchEnd.y; y++) {
                        uint8* pixel = getPixel2(image, x, y);
                        foundMap = MapManager::detectMap(image, pixel, x, y);
                        if (foundMap != NULL) {
                            x = searchEnd.x;
                            y = searchEnd.y;
                        }
                    }
                }
            }
            
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process Map Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            if (foundMap != NULL) {
                uint64_t startTime = mach_absolute_time();
                //Search for location
                CGPoint searchStart = CGPointMake(foundMap->topLeft.x, foundMap->topLeft.y);
                CGPoint searchEnd = CGPointMake(image.imageWidth, image.imageHeight);
                for (int x = searchStart.x; x < searchEnd.x; x++) {
                    for (int y = searchStart.y; y < searchEnd.y; y++) {
                        uint8* pixel = getPixel2(image, x, y);
                        foundLocation = MapManager::detectLocation(image, pixel, x, y);
                        if (foundLocation != NULL) {
                            x = searchEnd.x;
                            y = searchEnd.y;
                        }
                    }
                }
                if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                    //NSLog(@"Process Map location Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
                }
                
                
                startTime = mach_absolute_time();
                //Search for shop at the bottom left
                searchStart = CGPointMake(image.imageWidth - 270, image.imageHeight - 45);
                searchEnd = CGPointMake(image.imageWidth - 255, image.imageHeight - 30);
                for (int x = searchStart.x; x < searchEnd.x; x++) {
                    for (int y = searchStart.y; y < searchEnd.y; y++) {
                        uint8* pixel = getPixel2(image, x, y);
                        foundShop = MapManager::detectShop(image, pixel, x, y);
                        if (foundShop != NULL) {
                            x = searchEnd.x;
                            y = searchEnd.y;
                        }
                    }
                }
                if (foundShop == NULL) {
                    //Search for shop at top right
                    searchStart = CGPointMake(image.imageWidth - 50, image.imageHeight - 273);
                    searchEnd = CGPointMake(image.imageWidth - 10, image.imageHeight - 250);
                    for (int x = searchStart.x; x < searchEnd.x; x++) {
                        for (int y = searchStart.y; y < searchEnd.y; y++) {
                            uint8* pixel = getPixel2(image, x, y);
                            foundShop = MapManager::detectShop(image, pixel, x, y);
                            if (foundShop != NULL) {
                                x = searchEnd.x;
                                y = searchEnd.y;
                            }
                        }
                    }
                }
                if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                    //NSLog(@"Process Map shop location Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
                }
            }
            /*
            if (foundMap != NULL) {
                dispatch_async(detectionThread, ^(void){
                    @autoreleasepool {
                        //if (mapDetectionObject != NULL) delete mapDetectionObject;
                        map = foundMap;
                    }
                });
            }*/
            
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (foundMap != NULL) {
                        //if (map != NULL) delete map;
                        mapVisible = true;
                        map = foundMap;
                    } else {
                        mapVisible = false;
                    }
                    if (foundLocation != NULL) {
                        //if (mapSelfLocation != NULL) delete mapSelfLocation;
                        mapSelfLocationVisible = true;
                        mapSelfLocation = foundLocation;
                    } else {
                        mapSelfLocationVisible = false;
                    }
                    if (foundShop != NULL) {
                        //if (mapShop != NULL) delete mapShop;
                        mapShopVisible = true;
                        mapShop = foundShop;
                    } else {
                        mapShopVisible = false;
                        if (mapShop == NULL) {
                            mapShop = mapSelfLocation;
                        }
                    }
                }
            });
        }
    });
}
const int shopScanChunksX = 7;
const int shopScanChunksY = 7;
void DetectionManager::processShop(ImageData image, dispatch_group_t dispatchGroup) {
    //First detect top left corner, but do it as a slow scan
    
    //As soon as top left corner is confirmed, do a full scan for bottom left corner
    
    //As soon as bottom left corner is confirmed, do a full scan for all items between
    
    //Probably the most expensive search if shop is open
    float leagueGameWidth = image.imageWidth;
    float leagueGameHeight = image.imageHeight;
    CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
    
    int scanStartX = 0; int scanStartY = 0;
    int scanEndX = leagueGameWidth/2; int scanEndY = leagueGameHeight/2;
    int scanWidth = (scanEndX - scanStartX) / shopScanChunksX;
    int scanHeight = (scanEndY - scanStartY) / shopScanChunksX;
    
    int framesPassed = (getTimeInMilliseconds(mach_absolute_time() - processShopLastTime)) / 16;
    if (framesPassed <= 0) framesPassed = 1;
    if (framesPassed > shopScanChunksX * shopScanChunksY) framesPassed = shopScanChunksX * shopScanChunksY;
    processShopLastTime = mach_absolute_time();
    
    NSMutableArray* scanRectangles = [NSMutableArray new];
    //Increase the scan chunk by 1
    for (int i = 0; i < framesPassed; i++) {
        shopScanCurrentChunkX += 1;
        if (shopScanCurrentChunkX >= shopScanChunksX) {
            shopScanCurrentChunkX = 0;
            shopScanCurrentChunkY++;
        }
        if (shopScanCurrentChunkY >= shopScanChunksY) {
            shopScanCurrentChunkY = 0;
        }
        //Add chunk to scan
        CGRect scanRect = CGRectMake( scanWidth * shopScanCurrentChunkX + scanStartX ,
                                     scanHeight * shopScanCurrentChunkY + scanStartY ,
                                     scanWidth ,
                                     scanHeight );
        scanRect = CGRectIntegral(scanRect);
        scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
        combineRectangles(scanRectangles, scanRect);
    }
    
    //If last seen, add it to the scan
    if (shopTopLeftCorner != NULL) {
        CGRect rect = CGRectMake(shopTopLeftCorner->topLeft.x - 5,
                                 shopTopLeftCorner->topLeft.y - 5,
                                 10,
                                 10);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
        
    }
    
    dispatch_group_async(dispatchGroup, shopThread, ^{
        @autoreleasepool {
            //uint64_t startTime = mach_absolute_time();
            
            
            GenericObject* topLeftCorner = nullptr;
            GenericObject* bottomLeftCorner = nullptr;
            NSMutableArray* itemsCanBuy = [NSMutableArray new];
            //Loop through scan chunks
            for (int i = 0; i < [scanRectangles count]; i++) {
                CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
                for (int x = rect.origin.x; x < rect.origin.x + rect.size.width; x++) {
                    for (int y = rect.origin.y; y < rect.origin.y + rect.size.height; y++) {
                        uint8* pixel = getPixel2(image, x, y);
                        topLeftCorner = ShopManager::detectShopTopLeftCorner(image, pixel, x, y);
                        if (topLeftCorner != nil) {
                            i = (int)[scanRectangles count];
                            x = rect.origin.x + rect.size.width;
                            y = rect.origin.y + rect.size.height;
                        }
                    }
                }
            }
            if (topLeftCorner != NULL) {
                //Scan immediately for bottom left corner
                for (int x = topLeftCorner->topLeft.x - 5; x < topLeftCorner->topLeft.x + 5; x++) {
                    for (int y = topLeftCorner->topLeft.y + 700; y < leagueGameHeight; y++) {
                        uint8* pixel = getPixel2(image, x, y);
                        bottomLeftCorner = ShopManager::detectShopBottomLeftCorner(image, pixel, x, y);
                        if (bottomLeftCorner != nil) {
                            x = topLeftCorner->topLeft.x + 5;
                            y = leagueGameHeight;
                        }
                    }
                }
                if (bottomLeftCorner != NULL) {
                    //Scan immediately for items
                    CGPoint searchStart = CGPointMake(topLeftCorner->topLeft.x + 15, topLeftCorner->topLeft.y + 75);
                    CGPoint searchEnd = CGPointMake(topLeftCorner->topLeft.x + 400, bottomLeftCorner->topLeft.y - 25  - 100);
                    for (int x = searchStart.x; x < searchEnd.x; x++) {
                        for (int y = searchStart.y; y < searchEnd.y; y++) {
                            uint8* pixel = getPixel2(image, x, y);
                            GenericObject* item = ShopManager::detectBuyableItems(image, pixel, x, y);
                            if (item != nil) {
                                [itemsCanBuy addObject: item];
                            }
                        }
                    }
                    //Remove duplicate items
                    for (int i = 0; i < [itemsCanBuy count]; i++) {
                        GenericObject* item = [itemsCanBuy objectAtIndex:i];
                        for (int i2 = 0; i2 < [itemsCanBuy count]; i2++) {
                            if (i != i2) {
                                GenericObject* item2 = [itemsCanBuy objectAtIndex:i2];
                                if (std::abs(item2->topLeft.x - item->topLeft.x) <= 8.0 && std::abs(item2->topLeft.y - item->topLeft.y) <= 8.0) {
                                    [itemsCanBuy removeObjectAtIndex:i];
                                    i--;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process shop Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            //}
            
            //Sort buyable items based on Y value
            
            for (int i = 0; i < itemsCanBuy.count; i++) {
                GenericObject* item = [itemsCanBuy objectAtIndex:i];
                int placeAtIndex = 0;
                for (int i2 = 0; i2 < itemsCanBuy.count; i2++) {
                    GenericObject* item2 = [itemsCanBuy objectAtIndex:i2];
                    placeAtIndex = i2;
                    if (item2->topLeft.y > item->topLeft.y) {
                        break;
                    }
                    [itemsCanBuy removeObject:item];
                    [itemsCanBuy insertObject:item atIndex:placeAtIndex];
                }
            }
            
            /*
            if (topLeftCorner != NULL) {
                dispatch_async(detectionThread, ^(void){
                    @autoreleasepool {
                        //if (shopTopLeftCornerDetectionObject != NULL) delete shopTopLeftCornerDetectionObject;
                        shopTopLeftCornerDetectionObject = topLeftCorner;
                    }
                });
            }*/
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (topLeftCorner != NULL) {
                        //if (shopTopLeftCorner != NULL) delete shopTopLeftCorner;
                        shopTopLeftCornerShown = true;
                        shopTopLeftCorner = topLeftCorner;
                    } else {
                        shopTopLeftCornerShown = false;
                    }
                    if (bottomLeftCorner != NULL) {
                        //if (shopBottomLeftCorner != NULL) delete shopBottomLeftCorner;
                        shopBottomLeftCornerShown = true;
                        shopBottomLeftCorner = bottomLeftCorner;
                    } else {
                        shopBottomLeftCornerShown = false;
                    }
                    while (buyableItems.count > 0) {
                        //GenericObject* item = [buyableItems lastObject];
                        //delete item;
                        [buyableItems removeLastObject];
                    }
                    buyableItems = itemsCanBuy;
                }
            });
        }
    });
}
void DetectionManager::processShopAvailable(ImageData image, dispatch_group_t dispatchGroup) {
    CGPoint searchStart = CGPointMake(1118, 1038);
    CGPoint searchEnd = CGPointMake(1118+20, 1038+20);
    dispatch_group_async(dispatchGroup, shopAvailableThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            
            
            ////NSLog(@"Searching for shop");
            GenericObject* shop = nullptr;
            for (int x = searchStart.x; x < searchEnd.x; x++) {
                for (int y = searchStart.y; y < searchEnd.y; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    shop = ShopManager::detectShopAvailable(image, pixel, x, y);
                    if (shop != NULL) {
                        x = searchEnd.x;
                        y = searchEnd.y;
                    }
                }
            }
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process shop available Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (shop != NULL) {
                        //if (shopAvailable != NULL) delete shopAvailable;
                        shopAvailableShown = true;
                        shopAvailable = shop;
                    } else {
                        shopAvailableShown = false;
                    }
                }
            });
        }
    });
}
void DetectionManager::processUsedPotion(ImageData image, dispatch_group_t dispatchGroup) {
    //Potion being used
    //from 400, 620
    //to 560, 660
    CGPoint searchStart = CGPointMake(640, 800);
    CGPoint searchEnd = CGPointMake(830, 900);
    
    dispatch_group_async(dispatchGroup, usedPotionThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            
            GenericObject* potionUsed = nullptr;
            for (int x = searchStart.x; x < searchEnd.x; x++) {
                for (int y = searchStart.y; y < searchEnd.y; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    potionUsed = ItemManager::detectUsedPotionAtPixel(image, pixel, x, y);
                    if (potionUsed != NULL) {
                        x = searchEnd.x;
                        y = searchEnd.y;
                    }
                }
            }
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process used potion Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (potionUsed != NULL) {
                        //if (potionBeingUsed != NULL) delete potionBeingUsed;
                        potionBeingUsedShown = true;
                        potionBeingUsed = potionUsed;
                    } else {
                        potionBeingUsedShown = false;
                    }
                }
            });
        }
    });
}

void DetectionManager::processItemActives(ImageData image, dispatch_group_t dispatchGroup) {
    int searchWidth = 6; int searchHeight = 6;
    CGPoint item1Pos = CGPointMake(1126, 944);
    CGPoint item2Pos = CGPointMake(1177, 944);
    CGPoint item3Pos = CGPointMake(1226, 944);
    CGPoint item4Pos = CGPointMake(1126, 992);
    CGPoint item5Pos = CGPointMake(1177, 992);
    CGPoint item6Pos = CGPointMake(1226, 992);
    
    potionActiveAvailable = false;
    
    //Search for item 1 and if it is a potion
    dispatch_group_async(dispatchGroup, itemActive1Thread, ^{
        @autoreleasepool {
            //uint64_t startTime = mach_absolute_time();
            GenericObject* item = nullptr;
            GenericObject* potion = nullptr;
            for (int x = item1Pos.x; x < item1Pos.x + searchWidth; x++) {
                for (int y = item1Pos.y; y < item1Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    if (item == NULL) {
                        item = ItemManager::detectItemActiveAtPixel(image, pixel, x, y);
                    }
                    if (potion == NULL) {
                        potion = ItemManager::detectPotionActiveAtPixel(image, pixel, x, y);
                    }
                    if (potion != NULL && item != NULL) {
                        x = image.imageWidth; y = image.imageHeight;
                    }
                }
            }
            
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (item != NULL) {
                        //if (item1Active != NULL) delete item1Active;
                        item1ActiveAvailable = true;
                        item1Active = item;
                    } else {
                        item1ActiveAvailable = false;
                    }
                    if (potion != NULL) {
                        //if (potionActive != NULL) delete potionActive;
                        potionActiveAvailable = true;
                        potionActive = potion;
                        potionOnActive = 1;
                    }
                }
            });
            //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
            ////NSLog(@"Processing item actives 1 detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            //}
        }
    });
    
    //Search for item 2 and if it is a potion
    dispatch_group_async(dispatchGroup, itemActive2Thread, ^{
        @autoreleasepool {
            //uint64_t startTime = mach_absolute_time();
            GenericObject* item = nullptr;
            GenericObject* potion = nullptr;
            for (int x = item2Pos.x; x < item2Pos.x + searchWidth; x++) {
                for (int y = item2Pos.y; y < item2Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    if (item == NULL) {
                        item = ItemManager::detectItemActiveAtPixel(image, pixel, x, y);
                    }
                    if (potion == NULL) {
                        potion = ItemManager::detectPotionActiveAtPixel(image, pixel, x, y);
                    }
                    if (potion != NULL && item != NULL) {
                        x = image.imageWidth; y = image.imageHeight;
                    }
                }
            }
            
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (item != NULL) {
                        //if (item2Active != NULL) delete item2Active;
                        item2ActiveAvailable = true;
                        item2Active = item;
                    } else {
                        item2ActiveAvailable = false;
                    }
                    if (potion != NULL) {
                        //if (potionActive != NULL) delete potionActive;
                        potionActiveAvailable = true;
                        potionActive = potion;
                        potionOnActive = 2;
                    }
                }
            });
            //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
            ////NSLog(@"Processing item actives 2 detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            //}
        }
    });
    
    //Search for item 3 and if it is a potion
    dispatch_group_async(dispatchGroup, itemActive3Thread, ^{
        @autoreleasepool {
            //uint64_t startTime = mach_absolute_time();
            GenericObject* item = nullptr;
            GenericObject* potion = nullptr;
            for (int x = item3Pos.x; x < item3Pos.x + searchWidth; x++) {
                for (int y = item3Pos.y; y < item3Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    if (item == NULL) {
                        item = ItemManager::detectItemActiveAtPixel(image, pixel, x, y);
                    }
                    if (potion == NULL) {
                        potion = ItemManager::detectPotionActiveAtPixel(image, pixel, x, y);
                    }
                    if (potion != NULL && item != NULL) {
                        x = image.imageWidth; y = image.imageHeight;
                    }
                }
            }
            
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (item != NULL) {
                        //if (item3Active != NULL) delete item3Active;
                        item3ActiveAvailable = true;
                        item3Active = item;
                    } else {
                        item3ActiveAvailable = false;
                    }
                    if (potion != NULL) {
                        //if (potionActive != NULL) delete potionActive;
                        potionActiveAvailable = true;
                        potionActive = potion;
                        potionOnActive = 3;
                    }
                }
            });//if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
            ////NSLog(@"Processing item actives 3 detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            //}
        }
    });
    
    //Search for item 4 and if it is a potion
    dispatch_group_async(dispatchGroup, itemActive4Thread, ^{
        @autoreleasepool {
            //uint64_t startTime = mach_absolute_time();
            GenericObject* item = nullptr;
            GenericObject* potion = nullptr;
            for (int x = item4Pos.x; x < item4Pos.x + searchWidth; x++) {
                for (int y = item4Pos.y; y < item4Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    if (item == NULL) {
                        item = ItemManager::detectItemActiveAtPixel(image, pixel, x, y);
                    }
                    if (potion == NULL) {
                        potion = ItemManager::detectPotionActiveAtPixel(image, pixel, x, y);
                    }
                    if (potion != NULL && item != NULL) {
                        x = image.imageWidth; y = image.imageHeight;
                    }
                }
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (item != NULL) {
                        //if (item4Active != NULL) delete item4Active;
                        item4ActiveAvailable = true;
                        item4Active = item;
                    } else {
                        item4ActiveAvailable = false;
                    }
                    if (potion != NULL) {
                        //if (potionActive != NULL) delete potionActive;
                        potionActiveAvailable = true;
                        potionActive = potion;
                        potionOnActive = 4;
                    }
                }
            });
            //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
            ////NSLog(@"Processing item actives 4 detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            //}
        }
    });
    
    //Search for item 5 and if it is a potion
    dispatch_group_async(dispatchGroup, itemActive5Thread, ^{
        @autoreleasepool {
            //uint64_t startTime = mach_absolute_time();
            GenericObject* item = nullptr;
            GenericObject* potion = nullptr;
            for (int x = item5Pos.x; x < item5Pos.x + searchWidth; x++) {
                for (int y = item5Pos.y; y < item5Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    if (item == NULL) {
                        item = ItemManager::detectItemActiveAtPixel(image, pixel, x, y);
                    }
                    if (potion == NULL) {
                        potion = ItemManager::detectPotionActiveAtPixel(image, pixel, x, y);
                    }
                    if (potion != NULL && item != NULL) {
                        x = image.imageWidth; y = image.imageHeight;
                    }
                }
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (item != NULL) {
                        //if (item5Active != NULL) delete item5Active;
                        item5ActiveAvailable = true;
                        item5Active = item;
                    } else {
                        item5ActiveAvailable = false;
                    }
                    if (potion != NULL) {
                        //if (potionActive != NULL) delete potionActive;
                        potionActiveAvailable = true;
                        potionActive = potion;
                        potionOnActive = 5;
                    }
                }
            });
            //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
            ////NSLog(@"Processing item actives 5 detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            //}
        }
    });
    
    //Search for item 6 and if it is a potion
    dispatch_group_async(dispatchGroup, itemActive6Thread, ^{
        @autoreleasepool {
            //uint64_t startTime = mach_absolute_time();
            GenericObject* item = nullptr;
            GenericObject* potion = nullptr;
            for (int x = item6Pos.x; x < item6Pos.x + searchWidth; x++) {
                for (int y = item6Pos.y; y < item6Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    if (item == NULL) {
                        item = ItemManager::detectItemActiveAtPixel(image, pixel, x, y);
                    }
                    if (potion == NULL) {
                        potion = ItemManager::detectPotionActiveAtPixel(image, pixel, x, y);
                    }
                    if (potion != NULL && item != NULL) {
                        x = image.imageWidth; y = image.imageHeight;
                    }
                }
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (item != NULL) {
                        //if (item6Active != NULL) delete item6Active;
                        item6ActiveAvailable = true;
                        item6Active = item;
                    } else {
                        item6ActiveAvailable = false;
                    }
                    if (potion != NULL) {
                        //if (potionActive != NULL) delete potionActive;
                        potionActiveAvailable = true;
                        potionActive = potion;
                        potionOnActive = 6;
                    }
                }
            });
            //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
            ////NSLog(@"Processing item actives 6 detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            //}
        }
    });
}
void DetectionManager::processSurrender(ImageData image, dispatch_group_t dispatchGroup) {
    
    int searchWidth = 30; int searchHeight = 30;
    CGPoint surrenderPos = CGPointMake(image.imageWidth - 254, image.imageHeight - 478);
    //Search for trinket to use
    dispatch_group_async(dispatchGroup, surrenderThread, ^{
        @autoreleasepool {
            
            GenericObject* surrender = nullptr;
            for (int x = surrenderPos.x; x < surrenderPos.x + searchWidth; x++) {
                for (int y = surrenderPos.y; y < surrenderPos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    surrender = SurrenderManager::detectSurrenderAtPixel(image, pixel, x, y);
                    if (surrender != nil) {
                        x = image.imageWidth;
                        y = image.imageHeight;
                    }
                }
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (surrender != NULL) {
                        surrenderAvailable = true;
                        surrenderActive = surrender;
                    } else {
                        surrenderAvailable = false;
                    }
                }
            });
        }
    });
}
void DetectionManager::processTrinketActive(ImageData image, dispatch_group_t dispatchGroup) {
    
    int searchWidth = 15; int searchHeight = 15;
    CGPoint trinketPos = CGPointMake(1275, 945);
    //Search for trinket to use
    dispatch_group_async(dispatchGroup, trinketActiveThread, ^{
        @autoreleasepool {
            
            uint64_t startTime = mach_absolute_time();
            GenericObject* trinket = nullptr;
            for (int x = trinketPos.x; x < trinketPos.x + searchWidth; x++) {
                for (int y = trinketPos.y; y < trinketPos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    trinket = ItemManager::detectTrinketActiveAtPixel(image, pixel, x, y);
                    if (trinket != nil) {
                        x = image.imageWidth;
                        y = image.imageHeight;
                    }
                }
            }
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process trinket active Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (trinket != NULL) {
                        //if (trinketActive != NULL) delete trinketActive;
                        trinketActiveAvailable = true;
                        trinketActive = trinket;
                    } else {
                        trinketActiveAvailable = false;
                    }
                }
            });
        }
    });
}
void DetectionManager::processSpellActives(ImageData image, dispatch_group_t dispatchGroup) {
    int searchWidth = 8; int searchHeight = 8;
    CGPoint level1Pos = CGPointMake(728, 946);
    CGPoint level2Pos = CGPointMake(794, 946);
    CGPoint level3Pos = CGPointMake(860, 946);
    CGPoint level4Pos = CGPointMake(927, 946);
    
    //Search for first level up
    dispatch_group_async(dispatchGroup, spell1ActiveThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            
            GenericObject* ability = nullptr;
            for (int x = level1Pos.x; x < level1Pos.x + searchWidth; x++) {
                for (int y = level1Pos.y; y < level1Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    ability = AbilityManager::detectEnabledAbilityAtPixel(image, pixel, x, y);
                    if (ability != nil) {
                        x = image.imageWidth;
                        y = image.imageHeight;
                    }
                }
            }
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process spell actives Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (ability != NULL) {
                        //if (spell1Active != NULL) delete spell1Active;
                        spell1ActiveAvailable = true;
                        spell1Active = ability;
                    } else {
                        spell1ActiveAvailable = false;
                    }
                }
            });
        }
    });
    
    //Search for second level up
    dispatch_group_async(dispatchGroup, spell2ActiveThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            GenericObject* ability = nullptr;
            for (int x = level2Pos.x; x < level2Pos.x + searchWidth; x++) {
                for (int y = level2Pos.y; y < level2Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    ability = AbilityManager::detectEnabledAbilityAtPixel(image, pixel, x, y);
                    if (ability != nil) {
                        x = image.imageWidth;
                        y = image.imageHeight;
                    }
                }
            }
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process spell 2 actives Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (ability != NULL) {
                        //if (spell2Active != NULL) delete spell2Active;
                        spell2ActiveAvailable = true;
                        spell2Active = ability;
                    } else {
                        spell2ActiveAvailable = false;
                    }
                }
            });
        }
    });
    
    //Search for third level up
    dispatch_group_async(dispatchGroup, spell3ActiveThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            GenericObject* ability = nullptr;
            for (int x = level3Pos.x; x < level3Pos.x + searchWidth; x++) {
                for (int y = level3Pos.y; y < level3Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    ability = AbilityManager::detectEnabledAbilityAtPixel(image, pixel, x, y);
                    if (ability != nil) {
                        x = image.imageWidth;
                        y = image.imageHeight;
                    }
                }
            }
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process spell 2 actives Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (ability != NULL) {
                        //if (spell3Active != NULL) delete spell3Active;
                        spell3ActiveAvailable = true;
                        spell3Active = ability;
                    } else {
                        spell3ActiveAvailable = false;
                    }
                }
            });
        }
    });
    
    //Search for fourth level up
    dispatch_group_async(dispatchGroup, spell4ActiveThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            GenericObject* ability = nullptr;
            for (int x = level4Pos.x; x < level4Pos.x + searchWidth; x++) {
                for (int y = level4Pos.y; y < level4Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    ability = AbilityManager::detectEnabledAbilityAtPixel(image, pixel, x, y);
                    if (ability != nil) {
                        x = image.imageWidth;
                        y = image.imageHeight;
                    }
                }
            }
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process spell 2 actives Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (ability != NULL) {
                        //if (spell4Active != NULL) delete spell4Active;
                        spell4ActiveAvailable = true;
                        spell4Active = ability;
                    } else {
                        spell4ActiveAvailable = false;
                    }
                }
            });
        }
    });
}

void DetectionManager::processSummonerSpellActives(ImageData image, dispatch_group_t dispatchGroup) {
    int searchWidth = 6; int searchHeight = 6;
    CGPoint spell1Pos = CGPointMake(1003, 946);
    CGPoint spell2Pos = CGPointMake(1052, 946);
    
    //Search for first summoner spell
    dispatch_group_async(dispatchGroup, summonerSpell1ActiveThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            GenericObject* ability = nullptr;
            for (int x = spell1Pos.x; x < spell1Pos.x + searchWidth; x++) {
                for (int y = spell1Pos.y; y < spell1Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    ability = AbilityManager::detectEnabledSummonerSpellAtPixel(image, pixel, x, y);
                    if (ability != nil) {
                        x = image.imageWidth;
                        y = image.imageHeight;
                    }
                }
            }
            if (getTimeInMilliseconds(mach_absolute_time() - startTime)* 2 > longAlert) {
                //NSLog(@"Processing summoner spell actives Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (ability != NULL) {
                        //if (summonerSpell1Active != NULL) delete summonerSpell1Active;
                        summonerSpell1ActiveAvailable = true;
                        summonerSpell1Active = ability;
                    } else {
                        summonerSpell1ActiveAvailable = false;
                    }
                }
            });
        }
    });
    
    //Search for second summoner spell
    dispatch_group_async(dispatchGroup, summonerSpell2ActiveThread, ^{
        @autoreleasepool {
            GenericObject* ability = nullptr;
            for (int x = spell2Pos.x; x < spell2Pos.x + searchWidth; x++) {
                for (int y = spell2Pos.y; y < spell2Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    ability = AbilityManager::detectEnabledSummonerSpellAtPixel(image, pixel, x, y);
                    if (ability != nil) {
                        x = image.imageWidth;
                        y = image.imageHeight;
                    }
                }
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (ability != NULL) {
                        //if (summonerSpell2Active != NULL) delete summonerSpell2Active;
                        summonerSpell2ActiveAvailable = true;
                        summonerSpell2Active = ability;
                    } else {
                        summonerSpell2ActiveAvailable = false;
                    }
                }
            });
        }
    });
    
}

void DetectionManager::processSpellLevelDots(ImageData image, dispatch_group_t dispatchGroup) {
    int searchWidth = 50; int searchHeight = 5;
    CGPoint levelDot1Pos = CGPointMake(733, 1011);
    CGPoint levelDot2Pos = CGPointMake(802, 1011);
    CGPoint levelDot3Pos = CGPointMake(867, 1011);
    CGPoint levelDot4Pos = CGPointMake(944, 1011);
    
    //Search for level up dots
    dispatch_group_async(dispatchGroup, levelUpDotsThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            NSMutableArray* level1Dots = [NSMutableArray new];
            for (int x = levelDot1Pos.x; x < levelDot1Pos.x + searchWidth; x++) {
                for (int y = levelDot1Pos.y; y < levelDot1Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    GenericObject* leveldot = AbilityManager::detectLevelDotAtPixel(image, pixel, x, y);
                    if (leveldot != nil) {
                        [level1Dots addObject: leveldot];
                        y = levelDot1Pos.y;
                        x += AbilityManager::levelDotImageData.imageWidth;
                    }
                }
            }
            
            NSMutableArray* level2Dots = [NSMutableArray new];
            for (int x = levelDot2Pos.x; x < levelDot2Pos.x + searchWidth; x++) {
                for (int y = levelDot2Pos.y; y < levelDot2Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    GenericObject* leveldot = AbilityManager::detectLevelDotAtPixel(image, pixel, x, y);
                    if (leveldot != nil) {
                        [level2Dots addObject: leveldot];
                        y = levelDot2Pos.y;
                        x += AbilityManager::levelDotImageData.imageWidth;
                    }
                }
            }
            
            NSMutableArray* level3Dots = [NSMutableArray new];
            for (int x = levelDot3Pos.x; x < levelDot3Pos.x + searchWidth; x++) {
                for (int y = levelDot3Pos.y; y < levelDot3Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    GenericObject* leveldot = AbilityManager::detectLevelDotAtPixel(image, pixel, x, y);
                    if (leveldot != nil) {
                        [level3Dots addObject: leveldot];
                        y = levelDot3Pos.y;
                        x += AbilityManager::levelDotImageData.imageWidth;
                    }
                }
            }
            
            NSMutableArray* level4Dots = [NSMutableArray new];
            for (int x = levelDot4Pos.x; x < levelDot4Pos.x + searchWidth; x++) {
                for (int y = levelDot4Pos.y; y < levelDot4Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    GenericObject* leveldot = AbilityManager::detectLevelDotAtPixel(image, pixel, x, y);
                    if (leveldot != nil) {
                        [level4Dots addObject: leveldot];
                        y = levelDot4Pos.y;
                        x += AbilityManager::levelDotImageData.imageWidth;
                    }
                }
            }
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process level up dots Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    while (spell1LevelDots.count > 0) {
                        //GenericObject* dot = spell1LevelDots.lastObject;
                        //delete dot;
                        [spell1LevelDots removeLastObject];
                    }
                    while (spell2LevelDots.count > 0) {
                        //GenericObject* dot = spell2LevelDots.lastObject;
                        //delete dot;
                        [spell2LevelDots removeLastObject];
                    }
                    while (spell3LevelDots.count > 0) {
                        //GenericObject* dot = spell3LevelDots.lastObject;
                        //delete dot;
                        [spell3LevelDots removeLastObject];
                    }
                    while (spell4LevelDots.count > 0) {
                        //GenericObject* dot = spell4LevelDots.lastObject;
                        //delete dot;
                        [spell4LevelDots removeLastObject];
                    }
                    spell1LevelDots = level1Dots;
                    spell2LevelDots = level2Dots;
                    spell3LevelDots = level3Dots;
                    spell4LevelDots = level4Dots;
                    currentLevel = (int)(spell1LevelDots.count + spell2LevelDots.count + spell3LevelDots.count + spell4LevelDots.count);
                }
            });
        }
    });
    
}

void DetectionManager::processSpellLevelUps(ImageData image, dispatch_group_t dispatchGroup) {
    //If we assume our screen is 1280x800, we can look in specific places
    //Width = 10, Height = 5
    //465, 660
    //515, 660
    //565, 660
    //615, 660
    int searchWidth = 12; int searchHeight = 6;
    CGPoint levelUp1Pos = CGPointMake(731, 893);
    CGPoint levelUp2Pos = CGPointMake(798, 893);
    CGPoint levelUp3Pos = CGPointMake(864, 893);
    CGPoint levelUp4Pos = CGPointMake(931, 893);
    
    //Search for first level up
    dispatch_group_async(dispatchGroup, spell1LevelUpThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            GenericObject* levelUp = nullptr;
            for (int x = levelUp1Pos.x; x < levelUp1Pos.x + searchWidth; x++) {
                for (int y = levelUp1Pos.y; y < levelUp1Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    GenericObject* levelup = AbilityManager::detectLevelUpAtPixel(image, pixel, x, y);
                    if (levelup != nil) {
                        levelUp = levelup;
                        x = image.imageWidth;
                        y = image.imageHeight;
                    }
                }
            }
            if (getTimeInMilliseconds(mach_absolute_time() - startTime)*4 > longAlert) {
                //NSLog(@"Process spell level ups Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (levelUp != NULL) {
                        //if (spell1LevelUp != NULL) delete spell1LevelUp;
                        spell1LevelUpAvailable = true;
                        spell1LevelUp = levelUp;
                    } else {
                        spell1LevelUpAvailable = false;
                    }
                }
            });
        }
    });
    
    //Search for second level up
    dispatch_group_async(dispatchGroup, spell2LevelUpThread, ^{
        @autoreleasepool {
            GenericObject* levelUp = nullptr;
            for (int x = levelUp2Pos.x; x < levelUp2Pos.x + searchWidth; x++) {
                for (int y = levelUp2Pos.y; y < levelUp2Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    GenericObject* levelup = AbilityManager::detectLevelUpAtPixel(image, pixel, x, y);
                    if (levelup != nil) {
                        levelUp = levelup;
                        x = image.imageWidth;
                        y = image.imageHeight;
                    }
                }
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (levelUp != NULL) {
                        //if (spell2LevelUp != NULL) delete spell2LevelUp;
                        spell2LevelUpAvailable = true;
                        spell2LevelUp = levelUp;
                    } else {
                        spell2LevelUpAvailable = false;
                    }
                }
            });
        }
    });
    
    //Search for third level up
    dispatch_group_async(dispatchGroup, spell3LevelUpThread, ^{
        @autoreleasepool {
            GenericObject* levelUp = nullptr;
            for (int x = levelUp3Pos.x; x < levelUp3Pos.x + searchWidth; x++) {
                for (int y = levelUp3Pos.y; y < levelUp3Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    GenericObject* levelup = AbilityManager::detectLevelUpAtPixel(image, pixel, x, y);
                    if (levelup != nil) {
                        levelUp = levelup;
                        x = image.imageWidth;
                        y = image.imageHeight;
                    }
                }
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (levelUp != NULL) {
                        //if (spell3LevelUp != NULL) delete spell3LevelUp;
                        spell3LevelUpAvailable = true;
                        spell3LevelUp = levelUp;
                    } else {
                        spell3LevelUpAvailable = false;
                    }
                }
            });
        }
    });
    
    //Search for fourth level up
    dispatch_group_async(dispatchGroup, spell4LevelUpThread, ^{
        @autoreleasepool {
            GenericObject* levelUp = nullptr;
            for (int x = levelUp4Pos.x; x < levelUp4Pos.x + searchWidth; x++) {
                for (int y = levelUp4Pos.y; y < levelUp4Pos.y + searchHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    GenericObject* levelup = AbilityManager::detectLevelUpAtPixel(image, pixel, x, y);
                    if (levelup != nil) {
                        levelUp = levelup;
                        x = image.imageWidth;
                        y = image.imageHeight;
                    }
                }
            }
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if (levelUp != NULL) {
                        //if (spell4LevelUp != NULL) delete spell4LevelUp;
                        spell4LevelUpAvailable = true;
                        spell4LevelUp = levelUp;
                    } else {
                        spell4LevelUpAvailable = false;
                    }
                }
            });
        }
    });
}

//Make it scan a chunk each frame
const int allyMinionScanChunksX = 8; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int allyMinionScanChunksY = 10;
const float allyMinionFrameMove = 80.0; //Assume minions can move 80 pixels in 1 frames
void DetectionManager::processAllyMinionDetection(ImageData image, dispatch_group_t dispatchGroup) {
    float leagueGameWidth = image.imageWidth;
    float leagueGameHeight = image.imageHeight;
    CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
    
    
    
    
    
    int scanStartX = 0; int scanStartY = 0;
    int scanEndX = leagueGameWidth; int scanEndY = leagueGameHeight;
    int scanWidth = (scanEndX - scanStartX) / allyMinionScanChunksX;
    int scanHeight = (scanEndY - scanStartY) / allyMinionScanChunksY;
    
    int framesPassed = (getTimeInMilliseconds(mach_absolute_time() - processAllyMinionLastTime)) / 16;
    if (framesPassed <= 0) framesPassed = 1;
    if (framesPassed > allyMinionScanChunksX * allyMinionScanChunksY) framesPassed = allyMinionScanChunksX * allyMinionScanChunksY;
    
    NSMutableArray* scanRectangles = [NSMutableArray new];
    //Increase the scan chunk by 1
    for (int i = 0; i < framesPassed; i++) {
        allyMinionScanCurrentChunkX += 1;
        if (allyMinionScanCurrentChunkX >= allyMinionScanChunksX) {
            allyMinionScanCurrentChunkX = 0;
            allyMinionScanCurrentChunkY++;
        }
        if (allyMinionScanCurrentChunkY >= allyMinionScanChunksY) {
            allyMinionScanCurrentChunkY = 0;
        }
        //Add chunk to scan
        CGRect scanRect = CGRectMake( scanWidth * allyMinionScanCurrentChunkX + scanStartX ,
                                     scanHeight * allyMinionScanCurrentChunkY + scanStartY ,
                                     scanWidth ,
                                     scanHeight );
        scanRect = CGRectIntegral(scanRect);
        scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
        combineRectangles(scanRectangles, scanRect);
    }
    
    
    
    
    //Why not scan certain sections in intervals?
    //I know it takes about 80 ms for a full scan.
    //I want to keep it to 1 ms scan time per frame.
    //So I need to split the screen into 49 sections and scan one section each frame. Plus where minions already are.
    //A full screen scan happens every 0.8longAlert66666666667 seconds
    
    //Increase the scan chunk by 1
    /*
    allyMinionScanCurrentChunkX += 1;
    if (allyMinionScanCurrentChunkX >= allyMinionScanChunksX) {
        allyMinionScanCurrentChunkX = 0;
        allyMinionScanCurrentChunkY++;
    }
    if (allyMinionScanCurrentChunkY >= allyMinionScanChunksY) {
        allyMinionScanCurrentChunkY = 0;
    }
    NSMutableArray* scanRectangles = [NSMutableArray new];
     
    //Add chunk to scan
    CGRect scanRect = CGRectMake( leagueGameWidth * allyMinionScanCurrentChunkX / allyMinionScanChunksX ,
                                 leagueGameHeight * allyMinionScanCurrentChunkY / allyMinionScanChunksY ,
                                 leagueGameWidth * 1 / allyMinionScanChunksX ,
                                 leagueGameHeight * 1 / allyMinionScanChunksY );
    scanRect = CGRectIntegral(scanRect);
    scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
    combineRectangles(scanRectangles, scanRect);
     */
    //Add previous minions to scan
    for (int i = 0; i < [allyMinions count]; i++) {
        Minion* minion = [allyMinions objectAtIndex:i];
        CGRect rect = CGRectMake(minion->topLeft.x - allyMinionFrameMove*framesPassed,
                                 minion->topLeft.y - allyMinionFrameMove*framesPassed,
                                 minion->bottomRight.x - minion->topLeft.x + allyMinionFrameMove*framesPassed*2,
                                 minion->bottomRight.y - minion->topLeft.y + allyMinionFrameMove*framesPassed*2);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
    dispatch_group_async(dispatchGroup, allyMinionThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            NSMutableArray* minionBars = [NSMutableArray new];
            //Loop through scan chunks
            for (int i = 0; i < [scanRectangles count]; i++) {
                CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
                for (int x = rect.origin.x; x < rect.origin.x + rect.size.width; x++) {
                    for (int y = rect.origin.y; y < rect.origin.y + rect.size.height; y++) {
                        uint8* pixel = getPixel2(image, x, y);
                        Minion* minionBar = AllyMinionManager::detectMinionBarAtPixel(image, pixel, x, y);
                        if (minionBar != nil) {
                            [minionBars addObject: minionBar];
                        }
                    }
                }
            }
            minionBars = AllyMinionManager::validateMinionBars(image, minionBars);
            
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process ally minions Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            /*
            dispatch_async(detectionThread, ^(void){
                @autoreleasepool {
                    while (allyMinionsDetectionObject.count > 0) {
                        //Minion* minion = allyMinionsDetectionObject.lastObject;
                        //delete minion;
                        [allyMinionsDetectionObject removeLastObject];
                    }
                    for (int i = 0; i < minionBars.count; i++) {
                        Minion* minion = [minionBars objectAtIndex:i];
                        [allyMinionsDetectionObject addObject:minion];
                    }
                }
            });*/
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    while (allyMinions.count > 0) {
                        //Minion* minion = allyMinions.lastObject;
                        //delete minion;
                        [allyMinions removeLastObject];
                    }
                    [allyMinions addObjectsFromArray:minionBars];
                    processAllyMinionLastTime = mach_absolute_time();
                }
            });
        }
    });
}

const int enemyMinionScanChunksX = 8; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int enemyMinionScanChunksY = 8;
const float enemyMinionFrameMove = 80.0; //Assume minions can move 80 pixels in 1 frames
void DetectionManager::processEnemyMinionDetection(ImageData image, dispatch_group_t dispatchGroup) {
    float leagueGameWidth = image.imageWidth;
    float leagueGameHeight = image.imageHeight;
    CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
    
    
    
    
    int scanStartX = 0; int scanStartY = 0;
    int scanEndX = leagueGameWidth; int scanEndY = leagueGameHeight;
    int scanWidth = (scanEndX - scanStartX) / enemyMinionScanChunksX;
    int scanHeight = (scanEndY - scanStartY) / enemyMinionScanChunksY;
    
    int framesPassed = (getTimeInMilliseconds(mach_absolute_time() - processEnemyMinionLastTime)) / 16;
    if (framesPassed <= 0) framesPassed = 1;
    if (framesPassed > enemyMinionScanChunksX * enemyMinionScanChunksY) framesPassed = enemyMinionScanChunksX * enemyMinionScanChunksY;
    
    NSMutableArray* scanRectangles = [NSMutableArray new];
    //Increase the scan chunk by 1
    for (int i = 0; i < framesPassed; i++) {
        enemyMinionScanCurrentChunkX += 1;
        if (enemyMinionScanCurrentChunkX >= enemyMinionScanChunksX) {
            enemyMinionScanCurrentChunkX = 0;
            enemyMinionScanCurrentChunkY++;
        }
        if (enemyMinionScanCurrentChunkY >= enemyMinionScanChunksY) {
            enemyMinionScanCurrentChunkY = 0;
        }
        //Add chunk to scan
        CGRect scanRect = CGRectMake( scanWidth * enemyMinionScanCurrentChunkX + scanStartX ,
                                     scanHeight * enemyMinionScanCurrentChunkY + scanStartY ,
                                     scanWidth ,
                                     scanHeight );
        scanRect = CGRectIntegral(scanRect);
        scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
        combineRectangles(scanRectangles, scanRect);
    }
    
    
    
    
    //Why not scan certain sections in intervals?
    //I know it takes about 80 ms for a full scan.
    //I want to keep it to 1 ms scan time per frame.
    //So I need to split the screen into 49 sections and scan one section each frame. Plus where minions already are.
    //A full screen scan happens every 0.8longAlert66666666667 seconds
    
    //Increase the scan chunk by 1
    /*
    enemyMinionScanCurrentChunkX += 1;
    if (enemyMinionScanCurrentChunkX >= enemyMinionScanChunksX) {
        enemyMinionScanCurrentChunkX = 0;
        enemyMinionScanCurrentChunkY++;
    }
    if (enemyMinionScanCurrentChunkY >= enemyMinionScanChunksY) {
        enemyMinionScanCurrentChunkY = 0;
    }
    NSMutableArray* scanRectangles = [NSMutableArray new];
    //Add chunk to scan
    CGRect scanRect = CGRectMake( leagueGameWidth * enemyMinionScanCurrentChunkX / enemyMinionScanChunksX ,
                                 leagueGameHeight * enemyMinionScanCurrentChunkY / enemyMinionScanChunksY ,
                                 leagueGameWidth * 1 / enemyMinionScanChunksX ,
                                 leagueGameHeight * 1 / enemyMinionScanChunksY );
    scanRect = CGRectIntegral(scanRect);
    scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
    combineRectangles(scanRectangles, scanRect);
     */
    
    //MyLog(@"Enemy minion rectangles 1:\n");
    //for (int i = 0; i < [scanRectangles count]; i++) {
    //    CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
    //    MyLog(@"\t X: %f, Y: %f, Width: %f, Height: %f\n", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    //}
     
    //Add previous minions to scan
    for (int i = 0; i < [enemyMinions count]; i++) {
        Minion* minion = [enemyMinions objectAtIndex:i];
        CGRect rect = CGRectMake(minion->topLeft.x - enemyMinionFrameMove*framesPassed,
                                 minion->topLeft.y - enemyMinionFrameMove*framesPassed,
                                 minion->bottomRight.x - minion->topLeft.x + enemyMinionFrameMove*framesPassed*2,
                                 minion->bottomRight.y - minion->topLeft.y + enemyMinionFrameMove*framesPassed*2);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
    ////NSLog(@"Enemy minion rectangles 2:");
    //for (int i = 0; i < [scanRectangles count]; i++) {
    //    CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
    //    //NSLog(@"\t X: %f, Y: %f, Width: %f, Height: %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    //}
    
    
    dispatch_group_async(dispatchGroup, enemyMinionThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            NSMutableArray* minionBars = [NSMutableArray new];
            //Loop through scan chunks
            for (int i = 0; i < [scanRectangles count]; i++) {
                CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
                for (int x = rect.origin.x; x < rect.origin.x + rect.size.width; x++) {
                    for (int y = rect.origin.y; y < rect.origin.y + rect.size.height; y++) {
                        uint8* pixel = getPixel2(image, x, y);
                        Minion* minionBar = EnemyMinionManager::detectMinionBarAtPixel(image, pixel, x, y);
                        if (minionBar != nil) {
                            [minionBars addObject: minionBar];
                        }
                    }
                }
            }
           // //NSLog(@"Found %d possible minions");
            minionBars = EnemyMinionManager::validateMinionBars(image, minionBars);
            
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process enemy minions Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }/*
            dispatch_async(detectionThread, ^(void){
                @autoreleasepool {
                    while (enemyMinionsDetectionObject.count > 0) {
                        //Minion* minion = enemyMinionsDetectionObject.lastObject;
                        //delete minion;
                        [enemyMinionsDetectionObject removeLastObject];
                    }
                    for (int i = 0; i < minionBars.count; i++) {
                        Minion* minion = [minionBars objectAtIndex:i];
                        [enemyMinionsDetectionObject addObject:minion];
                    }
                }
            });*/
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    while (enemyMinions.count > 0) {
                        //Minion* minion = enemyMinions.lastObject;
                        //delete minion;
                        [enemyMinions removeLastObject];
                    }
                    [enemyMinions addObjectsFromArray:minionBars];
                    processEnemyMinionLastTime = mach_absolute_time();
                }
            });
        }
    });
}

const int enemyChampionScanChunksX = 4; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int enemyChampionScanChunksY = 8;
const float enemyChampionFrameMove = 80.0; //Assume Champions can move 80 pixels in 1 frames
void DetectionManager::processEnemyChampionDetection(ImageData image, dispatch_group_t dispatchGroup) {
    float leagueGameWidth = image.imageWidth;
    float leagueGameHeight = image.imageHeight;
    CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
    
    
    int scanStartX = 0; int scanStartY = 0;
    int scanEndX = leagueGameWidth; int scanEndY = leagueGameHeight;
    int scanWidth = (scanEndX - scanStartX) / enemyChampionScanChunksX;
    int scanHeight = (scanEndY - scanStartY) / enemyChampionScanChunksY;
    
    int framesPassed = (getTimeInMilliseconds(mach_absolute_time() - processEnemyChampionLastTime)) / 16;
    if (framesPassed <= 0) framesPassed = 1;
    if (framesPassed > enemyChampionScanChunksX * enemyChampionScanChunksY) framesPassed = enemyChampionScanChunksX * enemyChampionScanChunksY;
    
    NSMutableArray* scanRectangles = [NSMutableArray new];
    //Increase the scan chunk by 1
    for (int i = 0; i < framesPassed; i++) {
        enemyChampionScanCurrentChunkX += 1;
        if (enemyChampionScanCurrentChunkX >= enemyChampionScanChunksX) {
            enemyChampionScanCurrentChunkX = 0;
            enemyChampionScanCurrentChunkY++;
        }
        if (enemyChampionScanCurrentChunkY >= enemyChampionScanChunksY) {
            enemyChampionScanCurrentChunkY = 0;
        }
        //Add chunk to scan
        CGRect scanRect = CGRectMake( scanWidth * enemyChampionScanCurrentChunkX + scanStartX ,
                                     scanHeight * enemyChampionScanCurrentChunkY + scanStartY ,
                                     scanWidth ,
                                     scanHeight );
        scanRect = CGRectIntegral(scanRect);
        scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
        combineRectangles(scanRectangles, scanRect);
    }
    
    
    //Why not scan certain sections in intervals?
    //I know it takes about 80 ms for a full scan.
    //I want to keep it to 1 ms scan time per frame.
    //So I need to split the screen into 49 sections and scan one section each frame. Plus where Champions already are.
    //A full screen scan happens every 0.81666666666667 seconds
    
    //Increase the scan chunk by 1
   /*
    enemyChampionScanCurrentChunkX += 1;
    if (enemyChampionScanCurrentChunkX >= enemyChampionScanChunksX) {
        enemyChampionScanCurrentChunkX = 0;
        enemyChampionScanCurrentChunkY++;
    }
    if (enemyChampionScanCurrentChunkY >= enemyChampionScanChunksY) {
        enemyChampionScanCurrentChunkY = 0;
    }
    NSMutableArray* scanRectangles = [NSMutableArray new];
    //Add chunk to scan
    CGRect scanRect = CGRectMake( leagueGameWidth * enemyChampionScanCurrentChunkX / enemyChampionScanChunksX ,
                                 leagueGameHeight * enemyChampionScanCurrentChunkY / enemyChampionScanChunksY ,
                                 leagueGameWidth * 1 / enemyChampionScanChunksX ,
                                 leagueGameHeight * 1 / enemyChampionScanChunksY );
    scanRect = CGRectIntegral(scanRect);
    scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
    combineRectangles(scanRectangles, scanRect);
    */
    
    //Add previous Champions to scan
    for (int i = 0; i < [enemyChampions count]; i++) {
        Champion* Champion = [enemyChampions objectAtIndex:i];
        CGRect rect = CGRectMake(Champion->topLeft.x - enemyChampionFrameMove*framesPassed,
                                 Champion->topLeft.y - enemyChampionFrameMove*framesPassed,
                                 Champion->bottomRight.x - Champion->topLeft.x + enemyChampionFrameMove*framesPassed*2,
                                 Champion->bottomRight.y - Champion->topLeft.y + enemyChampionFrameMove*framesPassed*2);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
    dispatch_group_async(dispatchGroup, enemyChampionThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            NSMutableArray* ChampionBars = [NSMutableArray new];
            //Loop through scan chunks
            for (int i = 0; i < [scanRectangles count]; i++) {
                CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
                for (int x = rect.origin.x; x < rect.origin.x + rect.size.width; x++) {
                    for (int y = rect.origin.y; y < rect.origin.y + rect.size.height; y++) {
                        uint8* pixel = getPixel2(image, x, y);
                        Champion* ChampionBar = EnemyChampionManager::detectChampionBarAtPixel(image, pixel, x, y);
                        if (ChampionBar != nil) {
                            CGRect rect = CGRectMake(ChampionBar->topLeft.x - 5, ChampionBar->topLeft.y - 5, ChampionBar->bottomRight.x - ChampionBar->topLeft.x + 10, ChampionBar->bottomRight.y - ChampionBar->topLeft.y + 10);
                            rect = CGRectIntegral(rect);
                            rect = fitRectangleInRectangle(rect, leagueWindowRect);
                            combineRectangles(scanRectangles, rect);
                            [ChampionBars addObject: ChampionBar];
                        }
                    }
                }
            }
            ChampionBars = EnemyChampionManager::validateChampionBars(image, ChampionBars);
            
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                ////NSLog(@"Process enemy champions Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }/*
            dispatch_async(detectionThread, ^(void){
                @autoreleasepool {
                    while (enemyChampionsDetectionObject.count > 0) {
                        //Champion* champ = enemyChampionsDetectionObject.lastObject;
                        //delete champ;
                        [enemyChampionsDetectionObject removeLastObject];
                    }
                    for (int i = 0; i < ChampionBars.count; i++) {
                        Champion* champ = [ChampionBars objectAtIndex:i];
                        [enemyChampionsDetectionObject addObject:champ];
                    }
                }
            });*/
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    while (enemyChampions.count > 0) {
                        //Champion* champ = (Champion*)[enemyChampions.lastObject;
                        //delete champ;
                        [enemyChampions removeLastObject];
                    }
                    [enemyChampions addObjectsFromArray:ChampionBars];
                    processEnemyChampionLastTime = mach_absolute_time();
                }
            });
        }
    });
}

const int allyChampionScanChunksX = 5; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int allyChampionScanChunksY = 24;
const float allyChampionFrameMove = 80.0; //Assume Champions can move 80 pixels in 1 frames
void DetectionManager::processAllyChampionDetection(ImageData image, dispatch_group_t dispatchGroup) {
    float leagueGameWidth = image.imageWidth;
    float leagueGameHeight = image.imageHeight;
    CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
    
    
    
    int scanStartX = 0; int scanStartY = 0;
    int scanEndX = leagueGameWidth; int scanEndY = leagueGameHeight;
    int scanWidth = (scanEndX - scanStartX) / allyChampionScanChunksX;
    int scanHeight = (scanEndY - scanStartY) / allyChampionScanChunksY;
    
    int framesPassed = (getTimeInMilliseconds(mach_absolute_time() - processAllyChampionLastTime)) / 16;
    if (framesPassed <= 0) framesPassed = 1;
    if (framesPassed > allyChampionScanChunksX * allyChampionScanChunksY) framesPassed = allyChampionScanChunksX * allyChampionScanChunksY;
    
    NSMutableArray* scanRectangles = [NSMutableArray new];
    //Increase the scan chunk by 1
    for (int i = 0; i < framesPassed; i++) {
        allyChampionScanCurrentChunkX += 1;
        if (allyChampionScanCurrentChunkX >= allyChampionScanChunksX) {
            allyChampionScanCurrentChunkX = 0;
            allyChampionScanCurrentChunkY++;
        }
        if (allyChampionScanCurrentChunkY >= allyChampionScanChunksY) {
            allyChampionScanCurrentChunkY = 0;
        }
        //Add chunk to scan
        CGRect scanRect = CGRectMake( scanWidth * allyChampionScanCurrentChunkX + scanStartX ,
                                     scanHeight * allyChampionScanCurrentChunkY + scanStartY ,
                                     scanWidth ,
                                     scanHeight );
        scanRect = CGRectIntegral(scanRect);
        scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
        combineRectangles(scanRectangles, scanRect);
    }
    
    
    
    //Why not scan certain sections in intervals?
    //I know it takes about 80 ms for a full scan.
    //I want to keep it to 1 ms scan time per frame.
    //So I need to split the screen into 49 sections and scan one section each frame. Plus where Champions already are.
    //A full screen scan happens every 0.81666666666667 seconds
    
    //Increase the scan chunk by 1
    /*
    allyChampionScanCurrentChunkX += 1;
    if (allyChampionScanCurrentChunkX >= allyChampionScanChunksX) {
        allyChampionScanCurrentChunkX = 0;
        allyChampionScanCurrentChunkY++;
    }
    if (allyChampionScanCurrentChunkY >= allyChampionScanChunksY) {
        allyChampionScanCurrentChunkY = 0;
    }
    NSMutableArray* scanRectangles = [NSMutableArray new];
    //Add chunk to scan
    CGRect scanRect = CGRectMake( leagueGameWidth * allyChampionScanCurrentChunkX / allyChampionScanChunksX ,
                                 leagueGameHeight * allyChampionScanCurrentChunkY / allyChampionScanChunksY ,
                                 leagueGameWidth * 1 / allyChampionScanChunksX ,
                                 leagueGameHeight * 1 / allyChampionScanChunksY );
    scanRect = CGRectIntegral(scanRect);
    scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
    combineRectangles(scanRectangles, scanRect);
     
     */
    
    //Add previous Champions to scan
    for (int i = 0; i < [allyChampions count]; i++) {
        Champion* Champion = [allyChampions objectAtIndex:i];
        CGRect rect = CGRectMake(Champion->topLeft.x - allyChampionFrameMove*framesPassed,
                                 Champion->topLeft.y - allyChampionFrameMove*framesPassed,
                                 Champion->bottomRight.x - Champion->topLeft.x + allyChampionFrameMove*framesPassed*2,
                                 Champion->bottomRight.y - Champion->topLeft.y + allyChampionFrameMove*framesPassed*2);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
    dispatch_group_async(dispatchGroup, allyChampionThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            NSMutableArray* ChampionBars = [NSMutableArray new];
            //Loop through scan chunks
            for (int i = 0; i < [scanRectangles count]; i++) {
                CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
                for (int x = rect.origin.x; x < rect.origin.x + rect.size.width; x++) {
                    for (int y = rect.origin.y; y < rect.origin.y + rect.size.height; y++) {
                        uint8* pixel = getPixel2(image, x, y);
                        Champion* ChampionBar = AllyChampionManager::detectChampionBarAtPixel(image, pixel, x, y);
                        if (ChampionBar != nil) {
                            //Add extra rectangle to scan
                            CGRect rect = CGRectMake(ChampionBar->topLeft.x - 5, ChampionBar->topLeft.y - 5, ChampionBar->bottomRight.x - ChampionBar->topLeft.x + 10, ChampionBar->bottomRight.y - ChampionBar->topLeft.y + 10);
                            rect = CGRectIntegral(rect);
                            rect = fitRectangleInRectangle(rect, leagueWindowRect);
                            combineRectangles(scanRectangles, rect);
                            [ChampionBars addObject: ChampionBar];
                        }
                    }
                }
            }
            ChampionBars = AllyChampionManager::validateChampionBars(image, ChampionBars);
            
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process ally champions Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }/*
            dispatch_async(detectionThread, ^(void){
                @autoreleasepool {
                    while (allyChampionsDetectionObject.count > 0) {
                        //Champion* champ = (Champion*)[allyChampionsDetectionObject.lastObject;
                        //delete champ;
                        [allyChampionsDetectionObject removeLastObject];
                    }
                    for (int i = 0; i < ChampionBars.count; i++) {
                        Champion* champ = [ChampionBars objectAtIndex:i];
                        [allyChampionsDetectionObject addObject:champ];
                    }
                }
            });*/
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    while (allyChampions.count > 0) {
                        //Champion* champ = allyChampions.lastObject;
                        //delete champ;
                        [allyChampions removeLastObject];
                    }
                    [allyChampions addObjectsFromArray:ChampionBars];
                    processAllyChampionLastTime = mach_absolute_time();
                }
            });
        }
    });
}

const int enemyTowerScanChunksX = 4; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int enemyTowerScanChunksY = 8;
const float enemyTowerFrameMove = 80.0; //Assume Towers can move 80 pixels in 1 frames
void DetectionManager::processEnemyTowerDetection(ImageData image, dispatch_group_t dispatchGroup) {
    float leagueGameWidth = image.imageWidth;
    float leagueGameHeight = image.imageHeight;
    CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
    
    
    
    
    int scanStartX = 0; int scanStartY = 0;
    int scanEndX = leagueGameWidth; int scanEndY = leagueGameHeight;
    int scanWidth = (scanEndX - scanStartX) / enemyTowerScanChunksX;
    int scanHeight = (scanEndY - scanStartY) / enemyTowerScanChunksY;
    
    int framesPassed = (getTimeInMilliseconds(mach_absolute_time() - processEnemyTowerLastTime)) / 16;
    if (framesPassed <= 0) framesPassed = 1;
    if (framesPassed > enemyTowerScanChunksX * enemyTowerScanChunksY) framesPassed = enemyTowerScanChunksX * enemyTowerScanChunksY;
    
    NSMutableArray* scanRectangles = [NSMutableArray new];
    //Increase the scan chunk by 1
    for (int i = 0; i < framesPassed; i++) {
        enemyTowerScanCurrentChunkX += 1;
        if (enemyTowerScanCurrentChunkX >= enemyTowerScanChunksX) {
            enemyTowerScanCurrentChunkX = 0;
            enemyTowerScanCurrentChunkY++;
        }
        if (enemyTowerScanCurrentChunkY >= enemyTowerScanChunksY) {
            enemyTowerScanCurrentChunkY = 0;
        }
        //Add chunk to scan
        CGRect scanRect = CGRectMake( scanWidth * enemyTowerScanCurrentChunkX + scanStartX ,
                                     scanHeight * enemyTowerScanCurrentChunkY + scanStartY ,
                                     scanWidth ,
                                     scanHeight );
        scanRect = CGRectIntegral(scanRect);
        scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
        combineRectangles(scanRectangles, scanRect);
    }
    
    
    
    //Why not scan certain sections in intervals?
    //I know it takes about 80 ms for a full scan.
    //I want to keep it to 1 ms scan time per frame.
    //So I need to split the screen into 49 sections and scan one section each frame. Plus where Towers already are.
    //A full screen scan happens every 0.81666666666667 seconds
    
    //Increase the scan chunk by 1
    /*
    enemyTowerScanCurrentChunkX += 1;
    if (enemyTowerScanCurrentChunkX >= enemyTowerScanChunksX) {
        enemyTowerScanCurrentChunkX = 0;
        enemyTowerScanCurrentChunkY++;
    }
    if (enemyTowerScanCurrentChunkY >= enemyTowerScanChunksY) {
        enemyTowerScanCurrentChunkY = 0;
    }
    NSMutableArray* scanRectangles = [NSMutableArray new];
    //Add chunk to scan
    CGRect scanRect = CGRectMake( leagueGameWidth * enemyTowerScanCurrentChunkX / enemyTowerScanChunksX ,
                                 leagueGameHeight * enemyTowerScanCurrentChunkY / enemyTowerScanChunksY ,
                                 leagueGameWidth * 1 / enemyTowerScanChunksX ,
                                 leagueGameHeight * 1 / enemyTowerScanChunksY );
    scanRect = CGRectIntegral(scanRect);
    scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
    combineRectangles(scanRectangles, scanRect);
     */
    //Add previous Towers to scan
    for (int i = 0; i < [enemyTowers count]; i++) {
        Tower* Tower = [enemyTowers objectAtIndex:i];
        CGRect rect = CGRectMake(Tower->topLeft.x - enemyTowerFrameMove*framesPassed,
                                 Tower->topLeft.y - enemyTowerFrameMove*framesPassed,
                                 Tower->bottomRight.x - Tower->topLeft.x + enemyTowerFrameMove*framesPassed*2,
                                 Tower->bottomRight.y - Tower->topLeft.y + enemyTowerFrameMove*framesPassed*2);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
    dispatch_group_async(dispatchGroup, enemyTowerThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            NSMutableArray* TowerBars = [NSMutableArray new];
            //Loop through scan chunks
            for (int i = 0; i < [scanRectangles count]; i++) {
                CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
                for (int x = rect.origin.x; x < rect.origin.x + rect.size.width; x++) {
                    for (int y = rect.origin.y; y < rect.origin.y + rect.size.height; y++) {
                        uint8* pixel = getPixel2(image, x, y);
                        Tower* TowerBar = EnemyTowerManager::detectTowerBarAtPixel(image, pixel, x, y);
                        if (TowerBar != nil) {
                            //Add extra rectangle to scan
                            CGRect rect = CGRectMake(TowerBar->topLeft.x - 5, TowerBar->topLeft.y - 5, TowerBar->bottomRight.x - TowerBar->topLeft.x + 10, TowerBar->bottomRight.y - TowerBar->topLeft.y + 10);
                            rect = CGRectIntegral(rect);
                            rect = fitRectangleInRectangle(rect, leagueWindowRect);
                            combineRectangles(scanRectangles, rect);
                            [TowerBars addObject: TowerBar];
                        }
                    }
                }
            }
            TowerBars = EnemyTowerManager::validateTowerBars(image, TowerBars);
            
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process enemy tower Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }/*
            dispatch_async(detectionThread, ^(void){
                @autoreleasepool {
                    while (enemyTowersDetectionObject.count > 0) {
                        //Tower* tower = (Tower*)[enemyTowersDetectionObject.lastObject;
                        //delete tower;
                        [enemyTowersDetectionObject removeLastObject];
                    }
                    for (int i = 0; i < TowerBars.count; i++) {
                        Tower* tower = [TowerBars objectAtIndex:i];
                        [enemyTowersDetectionObject addObject:tower];
                    }
                }
            });*/
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    while (enemyTowers.count > 0) {
                        //Tower* tower = (Tower*)[enemyTowers.lastObject;
                        //delete tower;
                        [enemyTowers removeLastObject];
                    }
                    [enemyTowers addObjectsFromArray:TowerBars];
                    processEnemyTowerLastTime = mach_absolute_time();
                }
            });
        }
    });
}

const int selfChampionScanChunksX = 14; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int selfChampionScanChunksY = 24;
const float SelfChampionFrameMove = 80.0; //Assume Champions can move 80 pixels in 1 frames
void DetectionManager::processSelfChampionDetection(ImageData image, dispatch_group_t dispatchGroup) {
    float leagueGameWidth = image.imageWidth;
    float leagueGameHeight = image.imageHeight;
    CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
    
    
    
    
    int scanStartX = 0; int scanStartY = 0;
    int scanEndX = leagueGameWidth; int scanEndY = leagueGameHeight;
    int scanWidth = (scanEndX - scanStartX) / selfChampionScanChunksX;
    int scanHeight = (scanEndY - scanStartY) / selfChampionScanChunksY;
    
    int framesPassed = (getTimeInMilliseconds(mach_absolute_time() - processSelfChampionLastTime)) / 16;
    if (framesPassed <= 0) framesPassed = 1;
    if (framesPassed > selfChampionScanChunksX * selfChampionScanChunksY) framesPassed = selfChampionScanChunksX * selfChampionScanChunksY;
    
    NSMutableArray* scanRectangles = [NSMutableArray new];
    //Increase the scan chunk by 1
    for (int i = 0; i < framesPassed; i++) {
        selfChampionScanCurrentChunkX += 1;
        if (selfChampionScanCurrentChunkX >= selfChampionScanChunksX) {
            selfChampionScanCurrentChunkX = 0;
            selfChampionScanCurrentChunkY++;
        }
        if (selfChampionScanCurrentChunkY >= selfChampionScanChunksY) {
            selfChampionScanCurrentChunkY = 0;
        }
        //Add chunk to scan
        CGRect scanRect = CGRectMake( scanWidth * selfChampionScanCurrentChunkX + scanStartX ,
                                     scanHeight * selfChampionScanCurrentChunkY + scanStartY ,
                                     scanWidth ,
                                     scanHeight );
        scanRect = CGRectIntegral(scanRect);
        scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
        combineRectangles(scanRectangles, scanRect);
    }
    
    
    
    
    //Why not scan certain sections in intervals?
    //I know it takes about 80 ms for a full scan.
    //I want to keep it to 1 ms scan time per frame.
    //So I need to split the screen into 49 sections and scan one section each frame. Plus where Champions already are.
    //A full screen scan happens every 0.81666666666667 seconds
    
    //Increase the scan chunk by 1
    /*
    selfChampionScanCurrentChunkX += 1;
    if (selfChampionScanCurrentChunkX >= SelfChampionScanChunksX) {
        selfChampionScanCurrentChunkX = 0;
        selfChampionScanCurrentChunkY++;
    }
    if (selfChampionScanCurrentChunkY >= SelfChampionScanChunksY) {
        selfChampionScanCurrentChunkY = 0;
    }
    NSMutableArray* scanRectangles = [NSMutableArray new];
    //Add chunk to scan
    CGRect scanRect = CGRectMake( leagueGameWidth * selfChampionScanCurrentChunkX / SelfChampionScanChunksX ,
                                 leagueGameHeight * selfChampionScanCurrentChunkY / SelfChampionScanChunksY ,
                                 leagueGameWidth * 1 / SelfChampionScanChunksX ,
                                 leagueGameHeight * 1 / SelfChampionScanChunksY );
    scanRect = CGRectIntegral(scanRect);
    scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
    combineRectangles(scanRectangles, scanRect);
     */
    //Add previous Champions to scan
    for (int i = 0; i < [selfChampions count]; i++) {
        Champion* Champion = [selfChampions objectAtIndex:i];
        CGRect rect = CGRectMake(Champion->topLeft.x - SelfChampionFrameMove*framesPassed,
                                 Champion->topLeft.y - SelfChampionFrameMove*framesPassed,
                                 Champion->bottomRight.x - Champion->topLeft.x + SelfChampionFrameMove*framesPassed*2,
                                 Champion->bottomRight.y - Champion->topLeft.y + SelfChampionFrameMove*framesPassed*2);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    //Scan middle of the screen
    CGRect rect = CGRectMake(image.imageWidth / 2 - 200,
                             image.imageHeight / 2 - 280,
                             320,
                             220);
    rect = CGRectIntegral(rect);
    rect = fitRectangleInRectangle(rect, leagueWindowRect);
    combineRectangles(scanRectangles, rect);
    
    dispatch_group_async(dispatchGroup, selfChampionThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            NSMutableArray* ChampionBars = [NSMutableArray new];
            //Loop through scan chunks
            for (int i = 0; i < [scanRectangles count]; i++) {
                CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
                for (int x = rect.origin.x; x < rect.origin.x + rect.size.width; x++) {
                    for (int y = rect.origin.y; y < rect.origin.y + rect.size.height; y++) {
                        uint8* pixel = getPixel2(image, x, y);
                        Champion* ChampionBar = SelfChampionManager::detectChampionBarAtPixel(image, pixel, x, y);
                        if (ChampionBar != nil) {
                            //Add extra rectangle to scan
                            //CGRect rect = CGRectMake(ChampionBar->topLeft.x-5, ChampionBar->topLeft.y-5, ChampionBar->bottomRight.x - ChampionBar->topLeft.x + 10, ChampionBar->bottomRight.y - ChampionBar->topLeft.y + 10);
                            //rect = CGRectIntegral(rect);
                            //rect = fitRectangleInRectangle(rect, leagueWindowRect);
                            //combineRectangles(scanRectangles, rect);
                            [ChampionBars addObject: ChampionBar];
                            ////NSLog(@"Adding self champ");
                        }
                    }
                }
            }
            ChampionBars = SelfChampionManager::validateChampionBars(image, ChampionBars);
            
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process self champs Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }/*
            dispatch_async(detectionThread, ^(void){
                @autoreleasepool {
                    while (selfChampionsDetectionObject.count > 0) {
                        //Champion* champ = (Champion*)[selfChampionsDetectionObject.lastObject;
                        //delete champ;
                        [selfChampionsDetectionObject removeLastObject];
                    }
                    for (int i = 0; i < ChampionBars.count; i++) {
                        Champion* champ = [ChampionBars objectAtIndex:i];
                        [selfChampionsDetectionObject addObject:champ];
                    }
                }
            });*/
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    while (selfChampions.count > 0) {
                        //Champion* champ = (Champion*)[selfChampions.lastObject;
                        //delete champ;
                        [selfChampions removeLastObject];
                    }
                    [selfChampions addObjectsFromArray:ChampionBars];
                    processSelfChampionLastTime = mach_absolute_time();
                }
            });
        }
    });
}

//const int selfHealthBarScanChunksX = 8; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
//const int selfHealthBarScanChunksY = 8;
void DetectionManager::processSelfHealthBarDetection(ImageData image, dispatch_group_t dispatchGroup) {
    //float leagueGameWidth = image.imageWidth - 600;
    //float leagueGameHeight = image.imageHeight - 700;
    //CGRect leagueWindowRect = CGRectMake(300, 700, leagueGameWidth, leagueGameHeight);
    //float leagueGameWidth = image.imageWidth;
    //float leagueGameHeight =image.imageHeight;
    //CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
    CGPoint searchStart1 = CGPointMake(658, 1024);
    CGPoint searchEnd1 = CGPointMake(672, 1034);
    
    CGPoint searchStart2 = CGPointMake(1089, 1024);
    CGPoint searchEnd2 = CGPointMake(1099, 1033);
    
    dispatch_group_async(dispatchGroup, selfHealthBarThread, ^{
        @autoreleasepool {
            //uint64_t startTime = mach_absolute_time();
            NSMutableArray* HealthBarBars = [NSMutableArray new];
            //Loop through scan chunks
            //for (int i = 0; i < [scanRectangles count]; i++) {
            //    CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
            for (int x = searchStart1.x; x < searchEnd1.x; x++) {
                for (int y = searchStart1.y; y < searchEnd1.y; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    SelfHealth* HealthBarBar = SelfChampionManager::detectSelfHealthBarAtPixel(image, pixel, x, y);
                    if (HealthBarBar != nil) {
                        ////NSLog(@"Found self health bar");
                        //Add extra rectangle to scan
                        //CGRect rect = CGRectMake(HealthBarBar->topLeft.x-5, HealthBarBar->topLeft.y-5, HealthBarBar->bottomRight.x - HealthBarBar->topLeft.x + 10, HealthBarBar->bottomRight.y - HealthBarBar->topLeft.y + 10);
                        //rect = CGRectIntegral(rect);
                        //rect = fitRectangleInRectangle(rect, leagueWindowRect);
                        //combineRectangles(scanRectangles, rect);
                        [HealthBarBars addObject: HealthBarBar];
                        x = searchEnd1.x;
                        y = searchEnd1.y;
                    }
                }
            }
            
            for (int x = searchStart2.x; x < searchEnd2.x; x++) {
                for (int y = searchStart2.y; y < searchEnd2.y; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    SelfHealth* HealthBarBar = SelfChampionManager::detectSelfHealthBarAtPixel(image, pixel, x, y);
                    if (HealthBarBar != nil) {
                        ////NSLog(@"Found self health bar");
                        //Add extra rectangle to scan
                        //CGRect rect = CGRectMake(HealthBarBar->topLeft.x-5, HealthBarBar->topLeft.y-5, HealthBarBar->bottomRight.x - HealthBarBar->topLeft.x + 10, HealthBarBar->bottomRight.y - HealthBarBar->topLeft.y + 10);
                        //rect = CGRectIntegral(rect);
                        //rect = fitRectangleInRectangle(rect, leagueWindowRect);
                        //combineRectangles(scanRectangles, rect);
                        [HealthBarBars addObject: HealthBarBar];
                        x = searchEnd2.x;
                        y = searchEnd2.y;
                    }
                }
            }
            //}
            ////NSLog(@"health bars: %lu", (unsigned long)HealthBarBars.count);
            HealthBarBars = SelfChampionManager::validateSelfHealthBars(image, HealthBarBars);
            //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                //NSLog(@"Process self health bar Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            //}
            dispatch_async(detectionThread, ^(void) {
                @autoreleasepool {
                    if ([HealthBarBars count] > 0) {
                        //if (selfHealthBar != NULL) delete selfHealthBar;
                        selfHealthBarVisible = true;
                        selfHealthBar = [HealthBarBars firstObject];
                    } else {
                        selfHealthBarVisible = false;
                    }
                }
            });
        }
    });
    
}














