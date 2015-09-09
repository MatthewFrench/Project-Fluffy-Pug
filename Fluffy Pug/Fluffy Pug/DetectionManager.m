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

const int longAlert = 5;

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
    
    allyMinionsDetectionObject = [NSMutableArray new];
    allyMinionsDetectionObject = [NSMutableArray new];
    selfChampionsDetectionObject = [NSMutableArray new];
    enemyTowersDetectionObject = [NSMutableArray new];
    allyChampionsDetectionObject = [NSMutableArray new];
    enemyChampionsDetectionObject = [NSMutableArray new];
    
    mapDetectionObject = nullptr;
    shopTopLeftCornerDetectionObject = nullptr;
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
 NSLog(@"Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
 }
 }*/
void DetectionManager::processDetection(ImageData image) {
    
    @autoreleasepool {
        if (scanningScreen) {
            NSLog(@"Screen is being scanned");
        }
        
        scanningScreen = true;
        
        
        //uint64_t overallStartTime = mach_absolute_time();
        
        //uint64_t startTime = mach_absolute_time();
        
        dispatch_group_t dispatchGroup = dispatch_group_create();
        
        processAllyMinionDetection(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processAllyMinionDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processEnemyMinionDetection(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processEnemyMinionDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processAllyChampionDetection(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processAllyChampionDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processEnemyChampionDetection(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processEnemyChampionDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processEnemyTowerDetection(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processEnemyTowerDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processSelfChampionDetection(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processSelfChampionDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processSelfHealthBarDetection(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processSelfHealthBarDetection detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processSpellLevelUps(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processSpellLevelUps detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processSpellLevelDots(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processSpellLevelDots detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processSpellActives(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processSpellActives detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processSummonerSpellActives(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processSummonerSpellActives detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        //uint64_t startTime3 = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        //NSLog(@"dispatch group creation time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime3));
        
        //startTime3 = mach_absolute_time();
        processItemActives(image, dispatchGroup);
        //NSLog(@"processItemActives(image, dispatchGroup) time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime3));
        
        //startTime3 = mach_absolute_time();
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //NSLog(@"dispatch_group_wait time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime3));
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //NSLog(@"processItemActives detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processUsedPotion(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processUsedPotion detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processShopAvailable(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processShopAvailable detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processShop(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processShop detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        //startTime = mach_absolute_time();
        dispatchGroup = dispatch_group_create();
        
        processMap(image, dispatchGroup);
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
        //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
        //    NSLog(@"processMap detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
        //}
        
        //if (getTimeInMilliseconds(mach_absolute_time() - overallStartTime) > longAlert) {
        //    NSLog(@"\tOverall detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - overallStartTime));
        //}
        
        scanningScreen = false;
    }
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
SelfHealthBar* DetectionManager::getSelfHealthBar() {
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
    
    CGPoint searchStart = CGPointMake(image.imageWidth - 210, image.imageHeight - 210);
    CGPoint searchEnd = CGPointMake(image.imageWidth - 200, image.imageHeight - 200);
    
    int oldMapX = -1;
    int oldMapY = -1;
    if (mapDetectionObject != nullptr) {
        oldMapX = mapDetectionObject->topLeft.x;
        oldMapY = mapDetectionObject->topLeft.y;
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
                NSLog(@"Process Map Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
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
                    NSLog(@"Process Map location Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
                }
                
                
                startTime = mach_absolute_time();
                //Search for shop at the bottom left
                searchStart = CGPointMake(image.imageWidth - 200, image.imageHeight - 34);
                searchEnd = CGPointMake(image.imageWidth - 196, image.imageHeight - 30);
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
                    searchStart = CGPointMake(image.imageWidth - 34, image.imageHeight - 200);
                    searchEnd = CGPointMake(image.imageWidth - 30, image.imageHeight - 196);
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
                    NSLog(@"Process Map shop location Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
                }
            }
            
            if (foundMap != NULL) {
                dispatch_async(detectionThread, ^(void){
                    @autoreleasepool {
                        if (mapDetectionObject != NULL) delete mapDetectionObject;
                        mapDetectionObject = new GenericObject(*foundMap);
                    }
                });
            }
            
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (foundMap != NULL) {
                        if (map != NULL) delete map;
                        mapVisible = true;
                        map = foundMap;
                    } else {
                        mapVisible = false;
                    }
                    if (foundLocation != NULL) {
                        if (mapSelfLocation != NULL) delete mapSelfLocation;
                        mapSelfLocationVisible = true;
                        mapSelfLocation = foundLocation;
                    } else {
                        mapSelfLocationVisible = false;
                    }
                    if (foundShop != NULL) {
                        if (mapShop != NULL) delete mapShop;
                        mapShopVisible = true;
                        mapShop = foundShop;
                    } else {
                        mapShopVisible = false;
                    }
                }
            });
        }
    });
}
const int shopScanChunksX = 14;
const int shopScanChunksY = 14;
void DetectionManager::processShop(ImageData image, dispatch_group_t dispatchGroup) {
    //First detect top left corner, but do it as a slow scan
    
    //As soon as top left corner is confirmed, do a full scan for bottom left corner
    
    //As soon as bottom left corner is confirmed, do a full scan for all items between
    
    //Probably the most expensive search if shop is open
    float leagueGameWidth = image.imageWidth;
    float leagueGameHeight = image.imageHeight;
    CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
    
    //Increase the scan chunk by 1
    shopScanCurrentChunkX += 1;
    if (shopScanCurrentChunkX >= shopScanChunksX) {
        shopScanCurrentChunkX = 0;
        shopScanCurrentChunkY++;
    }
    if (shopScanCurrentChunkY >= shopScanChunksY) {
        shopScanCurrentChunkY = 0;
    }
    NSMutableArray* scanRectangles = [NSMutableArray new];
    //If last seen, add it to the scan
    if (shopTopLeftCornerDetectionObject != NULL) {
        CGRect rect = CGRectMake(shopTopLeftCornerDetectionObject->topLeft.x - 5,
                                 shopTopLeftCornerDetectionObject->topLeft.y - 5,
                                 10,
                                 10);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
        
    }
    //Add chunk to scan
    CGRect scanRect = CGRectMake( leagueGameWidth * shopScanCurrentChunkX / shopScanChunksX ,
                                 leagueGameHeight * shopScanCurrentChunkY / shopScanChunksY ,
                                 leagueGameWidth * 1 / shopScanChunksX ,
                                 leagueGameHeight * 1 / shopScanChunksY );
    scanRect = CGRectIntegral(scanRect);
    scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
    combineRectangles(scanRectangles, scanRect);
    
    dispatch_group_async(dispatchGroup, shopThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            
            
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
                    for (int y = topLeftCorner->topLeft.y + 500; y < leagueGameHeight; y++) {
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
                    CGPoint searchEnd = CGPointMake(topLeftCorner->topLeft.x + 400, bottomLeftCorner->topLeft.y - 25);
                    for (int x = searchStart.x; x < searchEnd.x; x++) {
                        for (int y = searchStart.y; y < searchEnd.y; y++) {
                            uint8* pixel = getPixel2(image, x, y);
                            GenericObject* item = ShopManager::detectBuyableItems(image, pixel, x, y);
                            if (item != nil) {
                                [itemsCanBuy addObject: [NSValue valueWithPointer:item]];
                            }
                        }
                    }
                }
            }
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                NSLog(@"Process shop Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            if (topLeftCorner != NULL) {
                dispatch_async(detectionThread, ^(void){
                    @autoreleasepool {
                        if (shopTopLeftCornerDetectionObject != NULL) delete shopTopLeftCornerDetectionObject;
                        shopTopLeftCornerDetectionObject = new GenericObject(*topLeftCorner);
                    }
                });
            }
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (topLeftCorner != NULL) {
                        if (shopTopLeftCorner != NULL) delete shopTopLeftCorner;
                        shopTopLeftCornerShown = true;
                        shopTopLeftCorner = topLeftCorner;
                    } else {
                        shopTopLeftCornerShown = false;
                    }
                    if (bottomLeftCorner != NULL) {
                        if (shopBottomLeftCorner != NULL) delete shopBottomLeftCorner;
                        shopBottomLeftCornerShown = true;
                        shopBottomLeftCorner = bottomLeftCorner;
                    } else {
                        shopBottomLeftCornerShown = false;
                    }
                    while (buyableItems.count > 0) {
                        GenericObject* item = (GenericObject*)[[buyableItems lastObject] pointerValue];
                        delete item;
                        [buyableItems removeLastObject];
                    }
                    buyableItems = itemsCanBuy;
                }
            });
        }
    });
}
void DetectionManager::processShopAvailable(ImageData image, dispatch_group_t dispatchGroup) {
    CGPoint searchStart = CGPointMake(760, 765);
    CGPoint searchEnd = CGPointMake(770, 780);
    dispatch_group_async(dispatchGroup, shopAvailableThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            
            
            //NSLog(@"Searching for shop");
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
                NSLog(@"Process shop available Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (shop != NULL) {
                        if (shopAvailable != NULL) delete shopAvailable;
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
    CGPoint searchStart = CGPointMake(400, 620);
    CGPoint searchEnd = CGPointMake(560, 660);
    
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
                NSLog(@"Process used potion Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (potionUsed != NULL) {
                        if (potionBeingUsed != NULL) delete potionBeingUsed;
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
    CGPoint item1Pos = CGPointMake(764, 700);
    CGPoint item2Pos = CGPointMake(800, 700);
    CGPoint item3Pos = CGPointMake(836, 700);
    CGPoint item4Pos = CGPointMake(764, 734);
    CGPoint item5Pos = CGPointMake(800, 734);
    CGPoint item6Pos = CGPointMake(836, 734);
    
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
            
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (item != NULL) {
                        if (item1Active != NULL) delete item1Active;
                        item1ActiveAvailable = true;
                        item1Active = item;
                    } else {
                        item1ActiveAvailable = false;
                    }
                    if (potion != NULL) {
                        if (potionActive != NULL) delete potionActive;
                        potionActiveAvailable = true;
                        potionActive = potion;
                        potionOnActive = 1;
                    }
                }
            });
            //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
            //NSLog(@"Processing item actives 1 detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
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
            
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (item != NULL) {
                        if (item2Active != NULL) delete item2Active;
                        item2ActiveAvailable = true;
                        item2Active = item;
                    } else {
                        item2ActiveAvailable = false;
                    }
                    if (potion != NULL) {
                        if (potionActive != NULL) delete potionActive;
                        potionActiveAvailable = true;
                        potionActive = potion;
                        potionOnActive = 2;
                    }
                }
            });
            //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
            //NSLog(@"Processing item actives 2 detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
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
            
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (item != NULL) {
                        if (item3Active != NULL) delete item3Active;
                        item3ActiveAvailable = true;
                        item3Active = item;
                    } else {
                        item3ActiveAvailable = false;
                    }
                    if (potion != NULL) {
                        if (potionActive != NULL) delete potionActive;
                        potionActiveAvailable = true;
                        potionActive = potion;
                        potionOnActive = 3;
                    }
                }
            });//if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
            //NSLog(@"Processing item actives 3 detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
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
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (item != NULL) {
                        if (item4Active != NULL) delete item4Active;
                        item4ActiveAvailable = true;
                        item4Active = item;
                    } else {
                        item4ActiveAvailable = false;
                    }
                    if (potion != NULL) {
                        if (potionActive != NULL) delete potionActive;
                        potionActiveAvailable = true;
                        potionActive = potion;
                        potionOnActive = 4;
                    }
                }
            });
            //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
            //NSLog(@"Processing item actives 4 detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
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
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (item != NULL) {
                        if (item5Active != NULL) delete item5Active;
                        item5ActiveAvailable = true;
                        item5Active = item;
                    } else {
                        item5ActiveAvailable = false;
                    }
                    if (potion != NULL) {
                        if (potionActive != NULL) delete potionActive;
                        potionActiveAvailable = true;
                        potionActive = potion;
                        potionOnActive = 5;
                    }
                }
            });
            //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
            //NSLog(@"Processing item actives 5 detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
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
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (item != NULL) {
                        if (item6Active != NULL) delete item6Active;
                        item6ActiveAvailable = true;
                        item6Active = item;
                    } else {
                        item6ActiveAvailable = false;
                    }
                    if (potion != NULL) {
                        if (potionActive != NULL) delete potionActive;
                        potionActiveAvailable = true;
                        potionActive = potion;
                        potionOnActive = 6;
                    }
                }
            });
            //if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
            //NSLog(@"Processing item actives 6 detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            //}
        }
    });
}
void DetectionManager::processTrinketActive(ImageData image, dispatch_group_t dispatchGroup) {
    
    int searchWidth = 6; int searchHeight = 6;
    CGPoint trinketPos = CGPointMake(873, 702);
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
                NSLog(@"Process trinket active Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (trinket != NULL) {
                        if (trinketActive != NULL) delete trinketActive;
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
    int searchWidth = 6; int searchHeight = 6;
    CGPoint level1Pos = CGPointMake(466, 700);
    CGPoint level2Pos = CGPointMake(515, 700);
    CGPoint level3Pos = CGPointMake(565, 700);
    CGPoint level4Pos = CGPointMake(614, 700);
    
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
                NSLog(@"Process spell actives Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (ability != NULL) {
                        if (spell1Active != NULL) delete spell1Active;
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
                NSLog(@"Process spell 2 actives Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (ability != NULL) {
                        if (spell2Active != NULL) delete spell2Active;
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
                NSLog(@"Process spell 2 actives Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (ability != NULL) {
                        if (spell3Active != NULL) delete spell3Active;
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
                NSLog(@"Process spell 2 actives Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (ability != NULL) {
                        if (spell4Active != NULL) delete spell4Active;
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
    CGPoint spell1Pos = CGPointMake(670, 700);
    CGPoint spell2Pos = CGPointMake(708, 700);
    
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
                NSLog(@"Processing summoner spell actives Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (ability != NULL) {
                        if (summonerSpell1Active != NULL) delete summonerSpell1Active;
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
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (ability != NULL) {
                        if (summonerSpell2Active != NULL) delete summonerSpell2Active;
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
    int searchWidth = 40; int searchHeight = 5;
    CGPoint levelDot1Pos = CGPointMake(470, 750);
    CGPoint levelDot2Pos = CGPointMake(522, 750);
    CGPoint levelDot3Pos = CGPointMake(572, 750);
    CGPoint levelDot4Pos = CGPointMake(620, 750);
    
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
                        [level1Dots addObject: [NSValue valueWithPointer:leveldot]];
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
                        [level2Dots addObject: [NSValue valueWithPointer:leveldot]];
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
                        [level3Dots addObject: [NSValue valueWithPointer:leveldot]];
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
                        [level4Dots addObject: [NSValue valueWithPointer:leveldot]];
                        y = levelDot4Pos.y;
                        x += AbilityManager::levelDotImageData.imageWidth;
                    }
                }
            }
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                NSLog(@"Process level up dots Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    while (spell1LevelDots.count > 0) {
                        GenericObject* dot = (GenericObject*)[spell1LevelDots.lastObject pointerValue];
                        delete dot;
                        [spell1LevelDots removeLastObject];
                    }
                    while (spell2LevelDots.count > 0) {
                        GenericObject* dot = (GenericObject*)[spell2LevelDots.lastObject pointerValue];
                        delete dot;
                        [spell2LevelDots removeLastObject];
                    }
                    while (spell3LevelDots.count > 0) {
                        GenericObject* dot = (GenericObject*)[spell3LevelDots.lastObject pointerValue];
                        delete dot;
                        [spell3LevelDots removeLastObject];
                    }
                    while (spell4LevelDots.count > 0) {
                        GenericObject* dot = (GenericObject*)[spell4LevelDots.lastObject pointerValue];
                        delete dot;
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
    int searchWidth = 10; int searchHeight = 5;
    CGPoint levelUp1Pos = CGPointMake(465, 660);
    CGPoint levelUp2Pos = CGPointMake(515, 660);
    CGPoint levelUp3Pos = CGPointMake(565, 660);
    CGPoint levelUp4Pos = CGPointMake(615, 660);
    
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
                NSLog(@"Process spell level ups Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (levelUp != NULL) {
                        if (spell1LevelUp != NULL) delete spell1LevelUp;
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
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (levelUp != NULL) {
                        if (spell2LevelUp != NULL) delete spell2LevelUp;
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
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (levelUp != NULL) {
                        if (spell3LevelUp != NULL) delete spell3LevelUp;
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
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if (levelUp != NULL) {
                        if (spell4LevelUp != NULL) delete spell4LevelUp;
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
const int allyMinionScanChunksY = 8;
const float allyMinionFrameMove = 80.0; //Assume minions can move 80 pixels in 1 frames
void DetectionManager::processAllyMinionDetection(ImageData image, dispatch_group_t dispatchGroup) {
    float leagueGameWidth = image.imageWidth;
    float leagueGameHeight = image.imageHeight;
    CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
    
    //Why not scan certain sections in intervals?
    //I know it takes about 80 ms for a full scan.
    //I want to keep it to 1 ms scan time per frame.
    //So I need to split the screen into 49 sections and scan one section each frame. Plus where minions already are.
    //A full screen scan happens every 0.8longAlert66666666667 seconds
    
    //Increase the scan chunk by 1
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
    //Add previous minions to scan
    for (int i = 0; i < [allyMinionsDetectionObject count]; i++) {
        MinionBar* minion = (MinionBar*)[[allyMinionsDetectionObject objectAtIndex:i] pointerValue];
        CGRect rect = CGRectMake(minion->topLeft.x - allyMinionFrameMove,
                                 minion->topLeft.y - allyMinionFrameMove,
                                 minion->bottomRight.x - minion->topLeft.x + allyMinionFrameMove,
                                 minion->bottomRight.y - minion->topLeft.y + allyMinionFrameMove);
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
                        MinionBar* minionBar = AllyMinionManager::detectMinionBarAtPixel(image, pixel, x, y);
                        if (minionBar != nil) {
                            [minionBars addObject: [NSValue valueWithPointer:minionBar]];
                        }
                    }
                }
            }
            minionBars = AllyMinionManager::validateMinionBars(image, minionBars);
            
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                NSLog(@"Process ally minions Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void){
                @autoreleasepool {
                    while (allyMinionsDetectionObject.count > 0) {
                        MinionBar* minion = (MinionBar*)[allyMinionsDetectionObject.lastObject pointerValue];
                        delete minion;
                        [allyMinionsDetectionObject removeLastObject];
                    }
                    for (int i = 0; i < minionBars.count; i++) {
                        MinionBar* minion = (MinionBar*)[[minionBars objectAtIndex:i] pointerValue];
                        [allyMinionsDetectionObject addObject:[NSValue valueWithPointer:new MinionBar(*minion)]];
                    }
                }
            });
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    while (allyMinions.count > 0) {
                        MinionBar* minion = (MinionBar*)[allyMinions.lastObject pointerValue];
                        delete minion;
                        [allyMinions removeLastObject];
                    }
                    [allyMinions addObjectsFromArray:minionBars];
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
    
    //Why not scan certain sections in intervals?
    //I know it takes about 80 ms for a full scan.
    //I want to keep it to 1 ms scan time per frame.
    //So I need to split the screen into 49 sections and scan one section each frame. Plus where minions already are.
    //A full screen scan happens every 0.8longAlert66666666667 seconds
    
    //Increase the scan chunk by 1
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
    //Add previous minions to scan
    for (int i = 0; i < [enemyMinionsDetectionObject count]; i++) {
        MinionBar* minion = (MinionBar*)[[enemyMinionsDetectionObject objectAtIndex:i] pointerValue];
        CGRect rect = CGRectMake(minion->topLeft.x - enemyMinionFrameMove,
                                 minion->topLeft.y - enemyMinionFrameMove,
                                 minion->bottomRight.x - minion->topLeft.x + enemyMinionFrameMove,
                                 minion->bottomRight.y - minion->topLeft.y + enemyMinionFrameMove);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
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
                        MinionBar* minionBar = EnemyMinionManager::detectMinionBarAtPixel(image, pixel, x, y);
                        if (minionBar != nil) {
                            [minionBars addObject: [NSValue valueWithPointer:minionBar]];
                        }
                    }
                }
            }
            minionBars = EnemyMinionManager::validateMinionBars(image, minionBars);
            
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                NSLog(@"Process enemy minions Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void){
                @autoreleasepool {
                    while (enemyMinionsDetectionObject.count > 0) {
                        MinionBar* minion = (MinionBar*)[enemyMinionsDetectionObject.lastObject pointerValue];
                        delete minion;
                        [enemyMinionsDetectionObject removeLastObject];
                    }
                    for (int i = 0; i < minionBars.count; i++) {
                        MinionBar* minion = (MinionBar*)[[minionBars objectAtIndex:i] pointerValue];
                        [enemyMinionsDetectionObject addObject:[NSValue valueWithPointer:new MinionBar(*minion)]];
                    }
                }
            });
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    while (enemyMinions.count > 0) {
                        MinionBar* minion = (MinionBar*)[enemyMinions.lastObject pointerValue];
                        delete minion;
                        [enemyMinions removeLastObject];
                    }
                    [enemyMinions addObjectsFromArray:minionBars];
                }
            });
        }
    });
}

const int enemyChampionScanChunksX = 5; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int enemyChampionScanChunksY = 24;
const float enemyChampionFrameMove = 80.0; //Assume Champions can move 80 pixels in 1 frames
void DetectionManager::processEnemyChampionDetection(ImageData image, dispatch_group_t dispatchGroup) {
    float leagueGameWidth = image.imageWidth;
    float leagueGameHeight = image.imageHeight;
    CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
    
    //Why not scan certain sections in intervals?
    //I know it takes about 80 ms for a full scan.
    //I want to keep it to 1 ms scan time per frame.
    //So I need to split the screen into 49 sections and scan one section each frame. Plus where Champions already are.
    //A full screen scan happens every 0.81666666666667 seconds
    
    //Increase the scan chunk by 1
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
    //Add previous Champions to scan
    for (int i = 0; i < [enemyChampionsDetectionObject count]; i++) {
        ChampionBar* Champion = (ChampionBar*)[[enemyChampionsDetectionObject objectAtIndex:i] pointerValue];
        CGRect rect = CGRectMake(Champion->topLeft.x - enemyChampionFrameMove,
                                 Champion->topLeft.y - enemyChampionFrameMove,
                                 Champion->bottomRight.x - Champion->topLeft.x + enemyChampionFrameMove,
                                 Champion->bottomRight.y - Champion->topLeft.y + enemyChampionFrameMove);
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
                        ChampionBar* ChampionBar = EnemyChampionManager::detectChampionBarAtPixel(image, pixel, x, y);
                        if (ChampionBar != nil) {
                            CGRect rect = CGRectMake(ChampionBar->topLeft.x - 5, ChampionBar->topLeft.y - 5, ChampionBar->bottomRight.x - ChampionBar->topLeft.x + 10, ChampionBar->bottomRight.y - ChampionBar->topLeft.y + 10);
                            rect = CGRectIntegral(rect);
                            rect = fitRectangleInRectangle(rect, leagueWindowRect);
                            combineRectangles(scanRectangles, rect);
                            [ChampionBars addObject: [NSValue valueWithPointer:ChampionBar]];
                        }
                    }
                }
            }
            ChampionBars = EnemyChampionManager::validateChampionBars(image, ChampionBars);
            
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                NSLog(@"Process enemy champions Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void){
                @autoreleasepool {
                    while (enemyChampionsDetectionObject.count > 0) {
                        ChampionBar* champ = (ChampionBar*)[enemyChampionsDetectionObject.lastObject pointerValue];
                        delete champ;
                        [enemyChampionsDetectionObject removeLastObject];
                    }
                    for (int i = 0; i < ChampionBars.count; i++) {
                        ChampionBar* champ = (ChampionBar*)[[ChampionBars objectAtIndex:i] pointerValue];
                        [enemyChampionsDetectionObject addObject:[NSValue valueWithPointer:new ChampionBar(*champ)]];
                    }
                }
            });
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    while (enemyChampions.count > 0) {
                        ChampionBar* champ = (ChampionBar*)[enemyChampions.lastObject pointerValue];
                        delete champ;
                        [enemyChampions removeLastObject];
                    }
                    [enemyChampions addObjectsFromArray:ChampionBars];
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
    
    //Why not scan certain sections in intervals?
    //I know it takes about 80 ms for a full scan.
    //I want to keep it to 1 ms scan time per frame.
    //So I need to split the screen into 49 sections and scan one section each frame. Plus where Champions already are.
    //A full screen scan happens every 0.81666666666667 seconds
    
    //Increase the scan chunk by 1
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
    //Add previous Champions to scan
    for (int i = 0; i < [allyChampionsDetectionObject count]; i++) {
        ChampionBar* Champion = (ChampionBar*)[[allyChampionsDetectionObject objectAtIndex:i] pointerValue];
        CGRect rect = CGRectMake(Champion->topLeft.x - allyChampionFrameMove,
                                 Champion->topLeft.y - allyChampionFrameMove,
                                 Champion->bottomRight.x - Champion->topLeft.x + allyChampionFrameMove,
                                 Champion->bottomRight.y - Champion->topLeft.y + allyChampionFrameMove);
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
                        ChampionBar* ChampionBar = AllyChampionManager::detectChampionBarAtPixel(image, pixel, x, y);
                        if (ChampionBar != nil) {
                            //Add extra rectangle to scan
                            CGRect rect = CGRectMake(ChampionBar->topLeft.x - 5, ChampionBar->topLeft.y - 5, ChampionBar->bottomRight.x - ChampionBar->topLeft.x + 10, ChampionBar->bottomRight.y - ChampionBar->topLeft.y + 10);
                            rect = CGRectIntegral(rect);
                            rect = fitRectangleInRectangle(rect, leagueWindowRect);
                            combineRectangles(scanRectangles, rect);
                            [ChampionBars addObject: [NSValue valueWithPointer:ChampionBar]];
                        }
                    }
                }
            }
            ChampionBars = AllyChampionManager::validateChampionBars(image, ChampionBars);
            
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                NSLog(@"Process ally champions Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void){
                @autoreleasepool {
                    while (allyChampionsDetectionObject.count > 0) {
                        ChampionBar* champ = (ChampionBar*)[allyChampionsDetectionObject.lastObject pointerValue];
                        delete champ;
                        [allyChampionsDetectionObject removeLastObject];
                    }
                    for (int i = 0; i < ChampionBars.count; i++) {
                        ChampionBar* champ = (ChampionBar*)[[ChampionBars objectAtIndex:i] pointerValue];
                        [allyChampionsDetectionObject addObject:[NSValue valueWithPointer:new ChampionBar(*champ)]];
                    }
                }
            });
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    while (allyChampions.count > 0) {
                        ChampionBar* champ = (ChampionBar*)[allyChampions.lastObject pointerValue];
                        delete champ;
                        [allyChampions removeLastObject];
                    }
                    [allyChampions addObjectsFromArray:ChampionBars];
                }
            });
        }
    });
}

const int enemyTowerScanChunksX = 4; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int enemyTowerScanChunksY = 24;
const float enemyTowerFrameMove = 80.0; //Assume Towers can move 80 pixels in 1 frames
void DetectionManager::processEnemyTowerDetection(ImageData image, dispatch_group_t dispatchGroup) {
    float leagueGameWidth = image.imageWidth;
    float leagueGameHeight = image.imageHeight;
    CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
    
    //Why not scan certain sections in intervals?
    //I know it takes about 80 ms for a full scan.
    //I want to keep it to 1 ms scan time per frame.
    //So I need to split the screen into 49 sections and scan one section each frame. Plus where Towers already are.
    //A full screen scan happens every 0.81666666666667 seconds
    
    //Increase the scan chunk by 1
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
    //Add previous Towers to scan
    for (int i = 0; i < [enemyTowersDetectionObject count]; i++) {
        TowerBar* Tower = (TowerBar*)[[enemyTowersDetectionObject objectAtIndex:i] pointerValue];
        CGRect rect = CGRectMake(Tower->topLeft.x - enemyTowerFrameMove,
                                 Tower->topLeft.y - enemyTowerFrameMove,
                                 Tower->bottomRight.x - Tower->topLeft.x + enemyTowerFrameMove,
                                 Tower->bottomRight.y - Tower->topLeft.y + enemyTowerFrameMove);
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
                        TowerBar* TowerBar = EnemyTowerManager::detectTowerBarAtPixel(image, pixel, x, y);
                        if (TowerBar != nil) {
                            //Add extra rectangle to scan
                            CGRect rect = CGRectMake(TowerBar->topLeft.x - 5, TowerBar->topLeft.y - 5, TowerBar->bottomRight.x - TowerBar->topLeft.x + 10, TowerBar->bottomRight.y - TowerBar->topLeft.y + 10);
                            rect = CGRectIntegral(rect);
                            rect = fitRectangleInRectangle(rect, leagueWindowRect);
                            combineRectangles(scanRectangles, rect);
                            [TowerBars addObject: [NSValue valueWithPointer:TowerBar]];
                        }
                    }
                }
            }
            TowerBars = EnemyTowerManager::validateTowerBars(image, TowerBars);
            
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                NSLog(@"Process enemy tower Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void){
                @autoreleasepool {
                    while (enemyTowersDetectionObject.count > 0) {
                        TowerBar* tower = (TowerBar*)[enemyTowersDetectionObject.lastObject pointerValue];
                        delete tower;
                        [enemyTowersDetectionObject removeLastObject];
                    }
                    for (int i = 0; i < TowerBars.count; i++) {
                        TowerBar* tower = (TowerBar*)[[TowerBars objectAtIndex:i] pointerValue];
                        [enemyTowersDetectionObject addObject:[NSValue valueWithPointer:new TowerBar(*tower)]];
                    }
                }
            });
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    while (enemyTowers.count > 0) {
                        TowerBar* tower = (TowerBar*)[enemyTowers.lastObject pointerValue];
                        delete tower;
                        [enemyTowers removeLastObject];
                    }
                    [enemyTowers addObjectsFromArray:TowerBars];
                }
            });
        }
    });
}

const int SelfChampionScanChunksX = 16; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int SelfChampionScanChunksY = 16;
const float SelfChampionFrameMove = 80.0; //Assume Champions can move 80 pixels in 1 frames
void DetectionManager::processSelfChampionDetection(ImageData image, dispatch_group_t dispatchGroup) {
    float leagueGameWidth = image.imageWidth;
    float leagueGameHeight = image.imageHeight;
    CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
    
    //Why not scan certain sections in intervals?
    //I know it takes about 80 ms for a full scan.
    //I want to keep it to 1 ms scan time per frame.
    //So I need to split the screen into 49 sections and scan one section each frame. Plus where Champions already are.
    //A full screen scan happens every 0.81666666666667 seconds
    
    //Increase the scan chunk by 1
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
    //Add previous Champions to scan
    for (int i = 0; i < [selfChampionsDetectionObject count]; i++) {
        ChampionBar* Champion = (ChampionBar*)[[selfChampionsDetectionObject objectAtIndex:i] pointerValue];
        CGRect rect = CGRectMake(Champion->topLeft.x - SelfChampionFrameMove,
                                 Champion->topLeft.y - SelfChampionFrameMove,
                                 Champion->bottomRight.x - Champion->topLeft.x + SelfChampionFrameMove,
                                 Champion->bottomRight.y - Champion->topLeft.y + SelfChampionFrameMove);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
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
                        ChampionBar* ChampionBar = SelfChampionManager::detectChampionBarAtPixel(image, pixel, x, y);
                        if (ChampionBar != nil) {
                            //Add extra rectangle to scan
                            CGRect rect = CGRectMake(ChampionBar->topLeft.x-5, ChampionBar->topLeft.y-5, ChampionBar->bottomRight.x - ChampionBar->topLeft.x + 10, ChampionBar->bottomRight.y - ChampionBar->topLeft.y + 10);
                            rect = CGRectIntegral(rect);
                            rect = fitRectangleInRectangle(rect, leagueWindowRect);
                            combineRectangles(scanRectangles, rect);
                            [ChampionBars addObject: [NSValue valueWithPointer:ChampionBar]];
                        }
                    }
                }
            }
            ChampionBars = SelfChampionManager::validateChampionBars(image, ChampionBars);
            
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                NSLog(@"Process self champs Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(detectionThread, ^(void){
                @autoreleasepool {
                    while (selfChampionsDetectionObject.count > 0) {
                        ChampionBar* champ = (ChampionBar*)[selfChampionsDetectionObject.lastObject pointerValue];
                        delete champ;
                        [selfChampionsDetectionObject removeLastObject];
                    }
                    for (int i = 0; i < ChampionBars.count; i++) {
                        ChampionBar* champ = (ChampionBar*)[[ChampionBars objectAtIndex:i] pointerValue];
                        [selfChampionsDetectionObject addObject:[NSValue valueWithPointer:new ChampionBar(*champ)]];
                    }
                }
            });
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    while (selfChampions.count > 0) {
                        ChampionBar* champ = (ChampionBar*)[selfChampions.lastObject pointerValue];
                        delete champ;
                        [selfChampions removeLastObject];
                    }
                    [selfChampions addObjectsFromArray:ChampionBars];
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
    CGPoint searchStart = CGPointMake(410, 750);
    CGPoint searchEnd = CGPointMake(430, 770);
    
    //Increase the scan chunk by 1
    /*
     selfHealthBarScanCurrentChunkX += 1;
     if (selfHealthBarScanCurrentChunkX >= selfHealthBarScanChunksX) {
     selfHealthBarScanCurrentChunkX = 0;
     selfHealthBarScanCurrentChunkY++;
     }
     if (selfHealthBarScanCurrentChunkY >= selfHealthBarScanChunksY) {
     selfHealthBarScanCurrentChunkY = 0;
     }*/
    /*
     NSMutableArray* scanRectangles = [NSMutableArray new];
     //Add chunk to scan
     CGRect scanRect = CGRectMake( leagueGameWidth * selfHealthBarScanCurrentChunkX / selfHealthBarScanChunksX ,
     leagueGameHeight * selfHealthBarScanCurrentChunkY / selfHealthBarScanChunksY ,
     leagueGameWidth * 1 / selfHealthBarScanChunksX ,
     leagueGameHeight * 1 / selfHealthBarScanChunksY );
     scanRect = CGRectIntegral(scanRect);
     scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
     combineRectangles(scanRectangles, scanRect);
     //Add previous HealthBars to scan
     if (selfHealthBar != NULL) {
     //NSLog(@"Health bar exists at %d, %d", selfHealthBar->topLeft.x, selfHealthBar->topLeft.y);
     CGRect rect = CGRectMake(selfHealthBar->topLeft.x - 20,
     selfHealthBar->topLeft.y - 20,
     selfHealthBar->bottomRight.x - selfHealthBar->topLeft.x + 20,
     selfHealthBar->bottomRight.y - selfHealthBar->topLeft.y + 20);
     rect = CGRectIntegral(rect);
     rect = fitRectangleInRectangle(rect, leagueWindowRect);
     combineRectangles(scanRectangles, rect);
     }*/
    
    dispatch_group_async(dispatchGroup, selfHealthBarThread, ^{
        @autoreleasepool {
            uint64_t startTime = mach_absolute_time();
            NSMutableArray* HealthBarBars = [NSMutableArray new];
            //Loop through scan chunks
            //for (int i = 0; i < [scanRectangles count]; i++) {
            //    CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
            for (int x = searchStart.x; x < searchEnd.x; x++) {
                for (int y = searchStart.y; y < searchEnd.y; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    SelfHealthBar* HealthBarBar = SelfChampionManager::detectSelfHealthBarAtPixel(image, pixel, x, y);
                    if (HealthBarBar != nil) {
                        //NSLog(@"Found self health bar");
                        //Add extra rectangle to scan
                        //CGRect rect = CGRectMake(HealthBarBar->topLeft.x-5, HealthBarBar->topLeft.y-5, HealthBarBar->bottomRight.x - HealthBarBar->topLeft.x + 10, HealthBarBar->bottomRight.y - HealthBarBar->topLeft.y + 10);
                        //rect = CGRectIntegral(rect);
                        //rect = fitRectangleInRectangle(rect, leagueWindowRect);
                        //combineRectangles(scanRectangles, rect);
                        [HealthBarBars addObject: [NSValue valueWithPointer:HealthBarBar]];
                        x = searchEnd.x;
                        y = searchEnd.y;
                    }
                }
            }
            //}
            //NSLog(@"health bars: %lu", (unsigned long)HealthBarBars.count);
            HealthBarBars = SelfChampionManager::validateSelfHealthBars(image, HealthBarBars);
            if (getTimeInMilliseconds(mach_absolute_time() - startTime) > longAlert) {
                NSLog(@"Process self health bar Processing detection time(ms): %d", getTimeInMilliseconds(mach_absolute_time() - startTime));
            }
            dispatch_async(aiThread, ^(void) {
                @autoreleasepool {
                    if ([HealthBarBars count] > 0) {
                        if (selfHealthBar != NULL) delete selfHealthBar;
                        selfHealthBarVisible = true;
                        selfHealthBar = (SelfHealthBar*)[[HealthBarBars firstObject] pointerValue];
                    } else {
                        selfHealthBarVisible = false;
                    }
                }
            });
        }
    });
    
}














