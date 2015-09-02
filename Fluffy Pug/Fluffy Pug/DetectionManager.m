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
    processAllyMinionDetection(image);
}
//Make it scan a chunk each frame
const int allyMinionScanChunksX = 6; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
const int allyMinionScanChunksY = 6;
void DetectionManager::processAllyMinionDetection(ImageData image) {
    
    //Why not scan certain sections in intervals?
    //I know it takes about 80 ms for a full scan.
    //I want to keep it to 1 ms scan time per frame.
    //So I need to split the screen into 49 sections and scan one section each frame. Plus where minions already are.
    //A full screen scan happens every 0.81666666666667 seconds
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //Make an array of rectangles for all the ally minions
        //Add scan chunk to array
        //While adding to array, make it remove overlapping parts of rectangles
        //Loop through array, loop through pixels in array and scan each pixel
        //Add new minions to array.
        /*
        if (getTimeInMilliseconds(mach_absolute_time() - allyMinionTime) >= allyMinionPatialScanMilliseconds) {
            allyMinionTime = mach_absolute_time();
            
            //Full screen scan
            NSMutableArray* minionBars = [NSMutableArray new];
            for (int x = 0; x < image.imageWidth; x++) {
                for (int y = 0; y < image.imageHeight; y++) {
                    uint8* pixel = getPixel2(image, x, y);
                    MinionBar* minionBar = AllyMinionManager::detectMinionBarAtPixel(image, pixel, x, y);
                    if (minionBar != nil) {
                        [minionBars addObject: [NSValue valueWithPointer:minionBar]];
                    }
                }
            }
            minionBars = AllyMinionManager::validateMinionBars(image, minionBars);
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [allyMinions removeAllObjects];
                [allyMinions addObjectsFromArray:minionBars];
            });
        } else {
            //Do partial scan
            
        }*/
    });
}













