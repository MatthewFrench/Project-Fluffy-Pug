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
    
    //double lastMovementClick;
    //int lastAction;
    //double passiveUseWardTimer;
    //double cameraLockTimer;
    //double lastShopBuy;
    
    uint64_t lastLevelUp;
    uint64_t lastShopBuy, lastShopOpenTap, lastShopCloseTap;
    uint64_t lastCameraFocus;
    uint64_t lastPlacedWard;
    
public:
    BasicAI(LeagueGameState* leagueGameState);
    void processAI();
    void handleAbilityLevelUps();
    void handleBuyingItems();
    void handleCameraFocus();
    void handlePlacingWard();
};