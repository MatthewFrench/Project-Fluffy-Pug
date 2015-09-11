//
//  BasicAI.h
//  Fluffy Pug
//
//  Created by Matthew French on 6/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InteractiveEvents.h"
#import "Utility.h"
#include <time.h>
#include <stdlib.h>

class LeagueGameState;

class BasicAI {
    LeagueGameState* gameState;
    
    uint64_t lastLevelUp;
    uint64_t lastShopBuy, lastShopOpenTap, lastShopCloseTap, lastShopBuying;
    uint64_t lastCameraFocus;
    uint64_t lastPlacedWard;
    uint64_t lastRunAwayClick, lastClickEnemyChamp, lastClickEnemyMinion, lastClickEnemyTower, lastClickAllyChampion, lastClickAllyMinion;
    uint64_t lastMoveMouse;
    uint64_t lastMovementClick;
    uint64_t lastRecallTap;
    uint64_t lastSpell1Use, lastSpell2Use, lastSpell3Use, lastSpell4Use, lastSummonerSpell1Use, lastSummonerSpell2Use;
    uint64_t lastItem1Use, lastItem2Use, lastItem3Use, lastItem4Use, lastItem5Use, lastItem6Use;
    
    int moveToLane;
    uint64_t moveToLanePathSwitch;
    
    bool boughtStarterItems;
    
public:
    BasicAI(LeagueGameState* leagueGameState);
    void processAI();
    void resetAI();
    void handleAbilityLevelUps();
    void handleBuyingItems();
    void handleCameraFocus();
    void handlePlacingWard();
    void handleMovementAndAttacking();
    
    void castSpell1();
    void castSpell2();
    void castSpell3();
    void castSpell4();
    void useTrinket();
    void castSummonerSpell1();
    void castSummonerSpell2();
    void useItem1();
    void useItem2();
    void useItem3();
    void useItem4();
    void useItem5();
    void useItem6();
    void castRecall();
};

Champion* getNearestChampion(NSMutableArray* championBars, int x, int y);
Champion* getLowestHealthChampion(NSMutableArray* championBars, int x, int y);
Minion* getNearestMinion(NSMutableArray* minionBars, int x, int y);
Minion* getLowestHealthMinion(NSMutableArray* minionBars, int x, int y);
Tower* getLowestHealthTower(NSMutableArray* towerBars, int x, int y);
Tower* getNearestTower(NSMutableArray* towerBars, int x, int y);