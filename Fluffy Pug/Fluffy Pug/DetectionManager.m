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
    
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER); //We wait for all detection to finish
}
NSMutableArray* DetectionManager::getAllyMinions() {
    return allyMinions;
}
//Make it scan a chunk each frame
const int allyMinionScanChunksX = 8; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int allyMinionScanChunksY = 8;
const float allyMinionFrameMove = 60.0; //Assume minions can move 60 pixels in 1 frames
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
        //NSLog(@"Full screen scan finished");
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
        //uint64_t start = mach_absolute_time();
        
         NSMutableArray* minionBars = [NSMutableArray new];
        //Loop through scan chunks
        //int count = 0;
        for (int i = 0; i < [scanRectangles count]; i++) {
            CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
            //NSLog(@"Scanning rectangle %d out of %lu", i, (unsigned long)[scanRectangles count]);
            //NSLog(@"Rectangle: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
            for (int x = rect.origin.x; x < rect.origin.x + rect.size.width; x++) {
                for (int y = rect.origin.y; y < rect.origin.y + rect.size.height; y++) {
                    //count++;
                    
                    uint8* pixel = getPixel2(image, x, y);
                    MinionBar* minionBar = AllyMinionManager::detectMinionBarAtPixel(image, pixel, x, y);
                    if (minionBar != nil) {
                        [minionBars addObject: [NSValue valueWithPointer:minionBar]];
                        //Add extra rectangle to scan because we don't wanna miss corners by being stingy
                        //CGRect rect2 = CGRectMake(minionBar->topLeft.x, minionBar->topLeft.y, 1, 1);
                        //combineRectangles(scanRectangles, fitRectangleInRectangle(CGRectIntegral(rect2), leagueWindowRect));
                        // rect2 = CGRectMake(minionBar->bottomLeft.x, minionBar->bottomLeft.y, 1, 1);
                        //combineRectangles(scanRectangles, fitRectangleInRectangle(CGRectIntegral(rect2), leagueWindowRect));
                        // rect2 = CGRectMake(minionBar->bottomRight.x, minionBar->bottomRight.y, 1, 1);
                        //combineRectangles(scanRectangles, fitRectangleInRectangle(CGRectIntegral(rect2), leagueWindowRect));
                        // rect2 = CGRectMake(minionBar->topRight.x, minionBar->topRight.y, 1, 1);
                        //combineRectangles(scanRectangles, fitRectangleInRectangle(CGRectIntegral(rect2), leagueWindowRect));
                    }
                }
            }
        }
        //NSLog(@"Scanned percentage of screen: %f took (ms): %d", (count * 100.0 / (leagueGameWidth*leagueGameHeight)), getTimeInMilliseconds(mach_absolute_time() - start));
        minionBars = AllyMinionManager::validateMinionBars(image, minionBars);
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [allyMinions removeAllObjects];
            [allyMinions addObjectsFromArray:minionBars];
        });
    });
}








