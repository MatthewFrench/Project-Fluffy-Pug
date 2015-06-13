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

class BasicAI;

class LeagueGameState {
public:
    int leaguePID;
    CGRect leagueSize;
    struct ImageData imageData;
    AllyMinionManager* allyMinionManager;
    EnemyMinionManager* enemyMinionManager;
    EnemyChampionManager* enemyChampionManager;
    SelfChampionManager* selfChampionManager;
    AllyChampionManager* allyChampionManager;
    AbilityManager* abilityManager;
    ItemManager* itemManager;
    BasicAI* basicAI;
    ShopManager* shopManager;
    EnemyTowerManager* enemyTowerManager;
    
    LeagueGameState();
    void processImage(struct ImageData image);
    void debugDraw();
};