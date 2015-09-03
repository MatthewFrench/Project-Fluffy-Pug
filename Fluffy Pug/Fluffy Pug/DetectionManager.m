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


DetectionManager::DetectionManager() {
    allyMinions = [NSMutableArray new];
    enemyMinions = [NSMutableArray new];
    allyChampions = [NSMutableArray new];
    enemyChampions = [NSMutableArray new];
    selfChampions = [NSMutableArray new];
    enemyTowers = [NSMutableArray new];
    buyableItems = [NSMutableArray new];
}
void DetectionManager::processDetection(ImageData image) {
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    processAllyMinionDetection(image, dispatchGroup);
    processEnemyMinionDetection(image, dispatchGroup);
    processAllyChampionDetection(image, dispatchGroup);
    processEnemyChampionDetection(image, dispatchGroup);
    processEnemyTowerDetection(image, dispatchGroup);
    processSelfChampionDetection(image, dispatchGroup);
    processSelfHealthBarDetection(image, dispatchGroup);
    processSpellLevelUps(image, dispatchGroup);
    
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
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
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (levelUp != NULL) {
                spell1LevelUpAvailable = true;
                spell1LevelUp = levelUp;
            } else {
                spell1LevelUpAvailable = false;
            }
        });
    });
    
    //Search for second level up
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (levelUp != NULL) {
                spell2LevelUpAvailable = true;
                spell2LevelUp = levelUp;
            } else {
                spell2LevelUpAvailable = false;
            }
        });
    });
    
    //Search for third level up
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (levelUp != NULL) {
                spell3LevelUpAvailable = true;
                spell3LevelUp = levelUp;
            } else {
                spell3LevelUpAvailable = false;
            }
        });
    });
    
    //Search for fourth level up
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (levelUp != NULL) {
                spell4LevelUpAvailable = true;
                spell4LevelUp = levelUp;
            } else {
                spell4LevelUpAvailable = false;
            }
        });
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
    //A full screen scan happens every 0.81666666666667 seconds
    
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
    for (int i = 0; i < [allyMinions count]; i++) {
        MinionBar* minion = (MinionBar*)[[allyMinions objectAtIndex:i] pointerValue];
        CGRect rect = CGRectMake(minion->topLeft.x - allyMinionFrameMove,
                                 minion->topLeft.y - allyMinionFrameMove,
                                 minion->bottomRight.x - minion->topLeft.x + allyMinionFrameMove,
                                 minion->bottomRight.y - minion->topLeft.y + allyMinionFrameMove);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [allyMinions removeAllObjects];
            [allyMinions addObjectsFromArray:minionBars];
        });
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
    //A full screen scan happens every 0.81666666666667 seconds
    
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
    for (int i = 0; i < [enemyMinions count]; i++) {
        MinionBar* minion = (MinionBar*)[[enemyMinions objectAtIndex:i] pointerValue];
        CGRect rect = CGRectMake(minion->topLeft.x - enemyMinionFrameMove,
                                 minion->topLeft.y - enemyMinionFrameMove,
                                 minion->bottomRight.x - minion->topLeft.x + enemyMinionFrameMove,
                                 minion->bottomRight.y - minion->topLeft.y + enemyMinionFrameMove);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [enemyMinions removeAllObjects];
            [enemyMinions addObjectsFromArray:minionBars];
        });
    });
}

const int enemyChampionScanChunksX = 16; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int enemyChampionScanChunksY = 16;
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
    for (int i = 0; i < [enemyChampions count]; i++) {
        ChampionBar* Champion = (ChampionBar*)[[enemyChampions objectAtIndex:i] pointerValue];
        CGRect rect = CGRectMake(Champion->topLeft.x - enemyChampionFrameMove,
                                 Champion->topLeft.y - enemyChampionFrameMove,
                                 Champion->bottomRight.x - Champion->topLeft.x + enemyChampionFrameMove,
                                 Champion->bottomRight.y - Champion->topLeft.y + enemyChampionFrameMove);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [enemyChampions removeAllObjects];
            [enemyChampions addObjectsFromArray:ChampionBars];
        });
    });
}

const int allyChampionScanChunksX = 16; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int allyChampionScanChunksY = 16;
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
    for (int i = 0; i < [allyChampions count]; i++) {
        ChampionBar* Champion = (ChampionBar*)[[allyChampions objectAtIndex:i] pointerValue];
        CGRect rect = CGRectMake(Champion->topLeft.x - allyChampionFrameMove,
                                 Champion->topLeft.y - allyChampionFrameMove,
                                 Champion->bottomRight.x - Champion->topLeft.x + allyChampionFrameMove,
                                 Champion->bottomRight.y - Champion->topLeft.y + allyChampionFrameMove);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [allyChampions removeAllObjects];
            [allyChampions addObjectsFromArray:ChampionBars];
        });
    });
}

const int enemyTowerScanChunksX = 16; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int enemyTowerScanChunksY = 16;
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
    for (int i = 0; i < [enemyTowers count]; i++) {
        TowerBar* Tower = (TowerBar*)[[enemyTowers objectAtIndex:i] pointerValue];
        CGRect rect = CGRectMake(Tower->topLeft.x - enemyTowerFrameMove,
                                 Tower->topLeft.y - enemyTowerFrameMove,
                                 Tower->bottomRight.x - Tower->topLeft.x + enemyTowerFrameMove,
                                 Tower->bottomRight.y - Tower->topLeft.y + enemyTowerFrameMove);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [enemyTowers removeAllObjects];
            [enemyTowers addObjectsFromArray:TowerBars];
        });
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
    for (int i = 0; i < [selfChampions count]; i++) {
        ChampionBar* Champion = (ChampionBar*)[[selfChampions objectAtIndex:i] pointerValue];
        CGRect rect = CGRectMake(Champion->topLeft.x - SelfChampionFrameMove,
                                 Champion->topLeft.y - SelfChampionFrameMove,
                                 Champion->bottomRight.x - Champion->topLeft.x + SelfChampionFrameMove,
                                 Champion->bottomRight.y - Champion->topLeft.y + SelfChampionFrameMove);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [selfChampions removeAllObjects];
            [selfChampions addObjectsFromArray:ChampionBars];
        });
    });
}

const int selfHealthBarScanChunksX = 8; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int selfHealthBarScanChunksY = 8;
void DetectionManager::processSelfHealthBarDetection(ImageData image, dispatch_group_t dispatchGroup) {
    float leagueGameWidth = 750 - 425;
    float leagueGameHeight = 780 - 755;
    CGRect leagueWindowRect = CGRectMake(425, 755, 750 - 425, 780 - 755);
    
    //Increase the scan chunk by 1
    selfHealthBarScanCurrentChunkX += 1;
    if (selfHealthBarScanCurrentChunkX >= selfHealthBarScanChunksX) {
        selfHealthBarScanCurrentChunkX = 0;
        selfHealthBarScanCurrentChunkY++;
    }
    if (selfHealthBarScanCurrentChunkY >= selfHealthBarScanChunksY) {
        selfHealthBarScanCurrentChunkY = 0;
    }
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
        CGRect rect = CGRectMake(selfHealthBar->topLeft.x - 20,
                                 selfHealthBar->topLeft.y - 20,
                                 selfHealthBar->bottomRight.x - selfHealthBar->topLeft.x + 20,
                                 selfHealthBar->bottomRight.y - selfHealthBar->topLeft.y + 20);
        rect = CGRectIntegral(rect);
        rect = fitRectangleInRectangle(rect, leagueWindowRect);
        combineRectangles(scanRectangles, rect);
    }
    
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray* HealthBarBars = [NSMutableArray new];
        //Loop through scan chunks
        for (int i = 0; i < [scanRectangles count]; i++) {
            CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
            for (int x = rect.origin.x; x < rect.origin.x + rect.size.width; x++) {
                for (int y = rect.origin.y; y < rect.origin.y + rect.size.height; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    SelfHealthBar* HealthBarBar = SelfChampionManager::detectSelfHealthBarAtPixel(image, pixel, x, y);
                    if (HealthBarBar != nil) {
                        //Add extra rectangle to scan
                        CGRect rect = CGRectMake(HealthBarBar->topLeft.x-5, HealthBarBar->topLeft.y-5, HealthBarBar->bottomRight.x - HealthBarBar->topLeft.x + 10, HealthBarBar->bottomRight.y - HealthBarBar->topLeft.y + 10);
                        rect = CGRectIntegral(rect);
                        rect = fitRectangleInRectangle(rect, leagueWindowRect);
                        combineRectangles(scanRectangles, rect);
                        [HealthBarBars addObject: [NSValue valueWithPointer:HealthBarBar]];
                    }
                }
            }
        }
        HealthBarBars = SelfChampionManager::validateSelfHealthBars(image, HealthBarBars);
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if ([HealthBarBars count] > 0) {
                selfHealthBarVisible = true;
                selfHealthBar = (SelfHealthBar*)[[HealthBarBars firstObject] pointerValue];
            } else {
                selfHealthBarVisible = false;
            }
        });
    });

}














