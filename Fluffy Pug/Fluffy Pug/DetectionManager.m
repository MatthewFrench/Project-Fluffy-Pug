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
    allyMinionTime = mach_absolute_time();
}
void DetectionManager::processDetection(ImageData image) {
    processAllyMinionDetection(image);
}
const int allyMinionFullScanSeconds = 1.0;
void DetectionManager::processAllyMinionDetection(ImageData image) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        if (getTimeInMilliseconds(mach_absolute_time() - allyMinionTime) >= allyMinionFullScanSeconds) {
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
            
        }
    });
}













