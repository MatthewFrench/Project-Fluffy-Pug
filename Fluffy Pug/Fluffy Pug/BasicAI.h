//
//  BasicAI.h
//  Fluffy Pug
//
//  Created by Matthew French on 6/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InteractiveEvents.h"
#include <time.h>
#include <stdlib.h>

class LeagueGameState;

class BasicAI {
    LeagueGameState* gameState;
    
    double lastMovementClick;
    int lastAction;
    double passiveUseWardTimer;
    double cameraLockTimer;
    double lastShopBuy;
    bool buyingItems;
    
public:
    BasicAI(LeagueGameState* leagueGameState);
    void processAI();
};