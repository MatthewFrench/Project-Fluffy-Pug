//
//  LeagueGameState.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AllyMinionManager.h"
#import "EnemyMinionManager.h"
#import "EnemyChampionManager.h"
#import "SelfChampionManager.h"
#import "AllyChampionManager.h"
#import "Utility.h"
#import "AbilityManager.h"
#import "ItemManager.h"
#import "ShopManager.h"
#import "EnemyTowerManager.h"

class LeagueGameState {
public:
    volatile bool autoQueueActive;
    volatile int leaguePID;
    /*volatile*/ CGRect leagueSize;
    
    //struct ImageData imageData;
    
    LeagueGameState();
    void processDetection(struct ImageData image);
    void processLogic();
    void debugDraw(ImageData imageData);
};