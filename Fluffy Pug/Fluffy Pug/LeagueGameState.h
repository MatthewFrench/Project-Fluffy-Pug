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
#import "Utility.h"

class LeagueGameState {
public:
    int leaguePID;
    CGRect leagueSize;
    struct ImageData imageData;
    AllyMinionManager* allyMinionManager;
    EnemyMinionManager* enemyMinionManager;
    
    LeagueGameState();
    void processImage(struct ImageData image);
};