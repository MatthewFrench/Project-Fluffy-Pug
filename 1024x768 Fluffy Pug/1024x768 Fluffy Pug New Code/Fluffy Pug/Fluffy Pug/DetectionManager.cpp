//
//  DetectionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 9/1/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#include "DetectionManager.h"
#include "SelfChampionManager.h"
#include "AllyChampionManager.h"
#include "EnemyChampionManager.h"
#include "EnemyMinionManager.h"
#include "AllyMinionManager.h"
#include "EnemyTowerManager.h"
#include "AbilityManager.h"
#include "ItemManager.h"
#include "ShopManager.h"
#include "MapManager.h"
#include "SurrenderManager.h"
//#include <omp.h>

DetectionManager::DetectionManager() {
    allyMinions = new std::vector<Minion*>();
    enemyMinions = new std::vector<Minion*>();
    allyChampions = new std::vector<Champion*>();
    enemyChampions = new std::vector<Champion*>();
    selfChampions = new std::vector<Champion*>();
    enemyTowers = new std::vector<Tower*>();
    buyableItems = new std::vector<GenericObject*>();
    spell1LevelDots = new std::vector<GenericObject*>();
    spell2LevelDots = new std::vector<GenericObject*>();
    spell3LevelDots = new std::vector<GenericObject*>();
    spell4LevelDots = new std::vector<GenericObject*>();
    
    
     average = 0;
     averageAmount = 0;
}

void DetectionManager::processDetection(ImageData *image) {
    int threads = 4;
    
    dispatch_queue_t queue[4];
    for (int i = 0 ; i < threads; i++) {
        queue[i] = dispatch_queue_create("Threads", DISPATCH_QUEUE_CONCURRENT);
    }
    
    
    double simulation_time = read_timer();
    
//preprocess
    shopTopLeftCorner = NULL;
    shopTopLeftCornerShown = false;
    allyMinions->clear();
    enemyMinions->clear();
    allyChampions->clear();
    enemyChampions->clear();
    selfChampions->clear();
    enemyTowers->clear();
    buyableItems->clear();
    spell1LevelDots->clear();
    spell2LevelDots->clear();
    spell3LevelDots->clear();
    spell4LevelDots->clear();
    
    dispatch_group_t dispatchGroup = dispatch_group_create();
    

////#pragma omp parallel num_threads(128)
    
    
    for (int threadNum = 0; threadNum < threads; threadNum++)
    {
        
        dispatch_group_async(dispatchGroup, queue[threadNum], ^{
    
    int perThread = (image->imageWidth * image->imageHeight) / threads;// / omp_get_num_threads();
        int start = threadNum * perThread;
        int end = (threadNum + 1) * perThread;

        int x = start % (image->imageWidth);
        int y = start / (image->imageWidth);

        uint8_t* pixel = getPixel2(image, x, y);

        Minion* minionBar;
        Champion* championBar;
        Tower* towerBar;
        GenericObject* topLeftCorner;

        for (int xy = start; xy < end; ++xy) {
            if (x >= image->imageWidth) {
                x = 0;
                y++;
            }

            //Ally minion detection
            minionBar = AllyMinionManager::detectMinionBarAtPixel(image, pixel, x, y);
            if (minionBar != NULL) {
                //#pragma omp critical (addAllyMinion)
                allyMinions->push_back(minionBar);
            }
            //Enemy minion detection
            minionBar = EnemyMinionManager::detectMinionBarAtPixel(image, pixel, x, y);
            if (minionBar != NULL) {
                //#pragma omp critical (addEnemyMinion)
                enemyMinions->push_back(minionBar);
            }
            //Enemy champion detection
            championBar = EnemyChampionManager::detectChampionBarAtPixel(image, pixel, x, y);
            if (championBar != NULL) {
                //#pragma omp critical (addEnemyChampion)
                enemyChampions->push_back(championBar);
            }
            //Ally champion detection
            championBar = AllyChampionManager::detectChampionBarAtPixel(image, pixel, x, y);
            if (championBar != NULL) {
                //#pragma omp critical (addAllyChampion)
                allyChampions->push_back(championBar);
            }
            //Enemy tower detection
            towerBar = EnemyTowerManager::detectTowerBarAtPixel(image, pixel, x, y);
            if (towerBar != NULL) {
                //#pragma omp critical (addEnemyTower)
                enemyTowers->push_back(towerBar);
            }
            //Self champion detection
            championBar = SelfChampionManager::detectChampionBarAtPixel(image, pixel, x, y);
            if (championBar != NULL) {
                //#pragma omp critical (addSelfChampion)
                selfChampions->push_back(championBar);
            }
            //Shop window detection
            if (shopTopLeftCorner == NULL) {
                topLeftCorner = ShopManager::detectShopTopLeftCorner(image, pixel, x, y);
                if (topLeftCorner != NULL) {
                    shopTopLeftCorner = topLeftCorner;
                    shopTopLeftCornerShown = true;
                }
            }

            x++;
            pixel += 4;
        }
        });
    }
    
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER);

        //Super specific or small search area so don't group
    processSpellLevelDots(image);
    processSpellLevelUps(image);
    processSelfHealthBarDetection(image);
    processItemActives(image);
    processShopAvailable(image);
    processSurrender(image);
    processSpellActives(image);
    processSummonerSpellActives(image);
    processTrinketActive(image);
    processUsedPotion(image);

    processMap(image);
    processMapShopAndLocation(image);

    processShopBottomLeftCorner(image);
    processShopBuyableItems(image);

    AllyMinionManager::validateMinionBars(image, allyMinions);
    EnemyMinionManager::validateMinionBars(image, enemyMinions);
    EnemyChampionManager::validateChampionBars(image, enemyChampions);
    AllyChampionManager::validateChampionBars(image, allyChampions);
    EnemyTowerManager::validateTowerBars(image, enemyTowers);
    SelfChampionManager::validateChampionBars(image, selfChampions);
    
    simulation_time = read_timer() - simulation_time;
    average += simulation_time;
    averageAmount++;
    printf("Detection time: %g\n", average / averageAmount);
}

void DetectionManager::processAllyMinionDetection(ImageData *image, int x, int y, uint8_t* pixel) {
    Minion* minionBar = AllyMinionManager::detectMinionBarAtPixel(image, pixel, x, y);
    if (minionBar != NULL) {
    //#pragma omp critical (addAllyMinion)
        allyMinions->push_back(minionBar);
    }
}

void DetectionManager::processEnemyMinionDetection(ImageData *image, int x, int y, uint8_t* pixel) {
    Minion* minionBar = EnemyMinionManager::detectMinionBarAtPixel(image, pixel, x, y);
    if (minionBar != NULL) {
    //#pragma omp critical (addEnemyMinion)
        enemyMinions->push_back(minionBar);
    }
}

void DetectionManager::processEnemyChampionDetection(ImageData *image, int x, int y, uint8_t* pixel) {
    Champion* championBar = EnemyChampionManager::detectChampionBarAtPixel(image, pixel, x, y);
    if (championBar != NULL) {
    //#pragma omp critical (addEnemyChampion)
        enemyChampions->push_back(championBar);
    }
}

void DetectionManager::processAllyChampionDetection(ImageData *image, int x, int y, uint8_t* pixel) {
    Champion* championBar = AllyChampionManager::detectChampionBarAtPixel(image, pixel, x, y);
    if (championBar != NULL) {
    //#pragma omp critical (addAllyChampion)
        allyChampions->push_back(championBar);
    }
}


void DetectionManager::processEnemyTowerDetection(ImageData *image, int x, int y, uint8_t* pixel) {
    Tower* towerBar = EnemyTowerManager::detectTowerBarAtPixel(image, pixel, x, y);
    if (towerBar != NULL) {
    //#pragma omp critical (addEnemyTower)
        enemyTowers->push_back(towerBar);
    }
}

void DetectionManager::processSelfChampionDetection(ImageData *image, int x, int y, uint8_t* pixel) {
    Champion* championBar = SelfChampionManager::detectChampionBarAtPixel(image, pixel, x, y);
    if (championBar != NULL) {
    //#pragma omp critical (addSelfChampion)
        selfChampions->push_back(championBar);
    }
}
void DetectionManager::processShop(ImageData *image, int x, int y, uint8_t* pixel) {
//First detect top left corner, but do it as a slow scan

//As soon as top left corner is confirmed, do a full scan for bottom left corner

//As soon as bottom left corner is confirmed, do a full scan for all items between

//Probably the most expensive search if shop is open

    if (shopTopLeftCorner == NULL) {
        uint8_t* pixel = getPixel2(image, x, y);
        GenericObject* topLeftCorner = ShopManager::detectShopTopLeftCorner(image, pixel, x, y);
        if (topLeftCorner != NULL) {
            shopTopLeftCorner = topLeftCorner;
            shopTopLeftCornerShown = true;
        }
    }

}
void DetectionManager::processMap(ImageData *image) {
//First we do an immediate map location search
//If the map is found them we search for shop and self location

    Position searchStart = makePosition(image->imageWidth - 200, image->imageHeight - 201);
    Position searchEnd = makePosition(image->imageWidth - 195, image->imageHeight - 197);

    GenericObject* foundMap = NULL;

    for (int x = searchStart.x; x < searchEnd.x; x++) {
        for (int y = searchStart.y; y < searchEnd.y; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            foundMap = MapManager::detectMap(image, pixel, x, y);
            if (foundMap != NULL) {
                x = searchEnd.x;
                y = searchEnd.y;
            }
        }
    }

    if (foundMap != NULL) {
                    //if (map != NULL) delete map;
        mapVisible = true;
        map = foundMap;
    } else {
        mapVisible = false;
    }
}
void DetectionManager::processMapShopAndLocation(ImageData *image) {

    GenericObject* foundLocation = NULL;
    GenericObject* foundShop = NULL;

    if (map != NULL) {
            //Search for location
        Position searchStart = makePosition(map->topLeft.x, map->topLeft.y);
        Position searchEnd = makePosition(image->imageWidth, image->imageHeight);
        for (int x = searchStart.x; x < searchEnd.x; x++) {
            for (int y = searchStart.y; y < searchEnd.y; y++) {
                uint8_t* pixel = getPixel2(image, x, y);
                foundLocation = MapManager::detectLocation(image, pixel, x, y);
                if (foundLocation != NULL) {
                    x = searchEnd.x;
                    y = searchEnd.y;
                }
            }
        }
            //Search for shop at the bottom left
        searchStart = makePosition(image->imageWidth - 194, image->imageHeight - 34);
        searchEnd = makePosition(image->imageWidth - 186, image->imageHeight - 25);
        for (int x = searchStart.x; x < searchEnd.x; x++) {
            for (int y = searchStart.y; y < searchEnd.y; y++) {
                uint8_t* pixel = getPixel2(image, x, y);
                foundShop = MapManager::detectShop(image, pixel, x, y);
                if (foundShop != NULL) {
                    x = searchEnd.x;
                    y = searchEnd.y;
                }
            }
        }
        if (foundShop == NULL) {
                //Search for shop at top right
            searchStart = makePosition(image->imageWidth - 32, image->imageHeight - 192);
            searchEnd = makePosition(image->imageWidth - 16, image->imageHeight - 181);
            for (int x = searchStart.x; x < searchEnd.x; x++) {
                for (int y = searchStart.y; y < searchEnd.y; y++) {
                    uint8_t* pixel = getPixel2(image, x, y);
                    foundShop = MapManager::detectShop(image, pixel, x, y);
                    if (foundShop != NULL) {
                        x = searchEnd.x;
                        y = searchEnd.y;
                    }
                }
            }
        }
    }

    if (foundLocation != NULL) {
                    //if (mapSelfLocation != NULL) delete mapSelfLocation;
        mapSelfLocationVisible = true;
        mapSelfLocation = foundLocation;
    } else {
        mapSelfLocationVisible = false;
    }
    if (foundShop != NULL) {
                    //if (mapShop != NULL) delete mapShop;
        mapShopVisible = true;
        mapShop = foundShop;
    } else {
        mapShopVisible = false;
        if (mapShop == NULL) {
            mapShop = mapSelfLocation;
        }
    }
}
void DetectionManager::processShopBottomLeftCorner(ImageData *image) {
    float leagueGameWidth = image->imageWidth;
    float leagueGameHeight = image->imageHeight;
    GenericObject* bottomLeftCorner = NULL;
    if (shopTopLeftCorner != NULL) {
        for (int x = shopTopLeftCorner->topLeft.x - 5; x < shopTopLeftCorner->topLeft.x + 5; x++) {
            for (int y = shopTopLeftCorner->topLeft.y + 500; y < leagueGameHeight; y++) {
                uint8_t* pixel = getPixel2(image, x, y);
                bottomLeftCorner = ShopManager::detectShopBottomLeftCorner(image, pixel, x, y);
                if (bottomLeftCorner != NULL) {
                    x = shopTopLeftCorner->topLeft.x + 5;
                    y = leagueGameHeight;
                }
            }
        }
    }
    if (bottomLeftCorner != NULL) {
        shopBottomLeftCornerShown = true;
        shopBottomLeftCorner = bottomLeftCorner;
    } else {
        shopBottomLeftCornerShown = false;
    }

}
void DetectionManager::processShopBuyableItems(ImageData *image) {

    if (shopTopLeftCorner != NULL) {

        if (shopBottomLeftCorner != NULL) {


            Position searchStart = makePosition(shopTopLeftCorner->topLeft.x + 15, shopTopLeftCorner->topLeft.y + 75);
            Position searchEnd = makePosition(shopTopLeftCorner->topLeft.x + 400, shopBottomLeftCorner->topLeft.y - 25 - 60);
            for (int x = searchStart.x; x < searchEnd.x; x++) {
                for (int y = searchStart.y; y < searchEnd.y; y++) {
                    uint8_t* pixel = getPixel2(image, x, y);
                    GenericObject* item = ShopManager::detectBuyableItems(image, pixel, x, y);
                    if (item != NULL) {
                        buyableItems->push_back(item);
                    }
                }
            }
                //Remove duplicate items

            for (int i = 0; i < buyableItems->size(); i++) {
                GenericObject* item = (*buyableItems)[i];
                for (int i2 = 0; i2 < buyableItems->size(); i2++) {
                    if (i != i2) {
                        GenericObject* item2 = (*buyableItems)[i2];
                        if (std::abs(item2->topLeft.x - item->topLeft.x) <= 15.0 && std::abs(item2->topLeft.y - item->topLeft.y) <= 15.0) {
                            buyableItems->erase(buyableItems->begin() + i);
                            i--;
                            break;
                        }
                    }
                }
            }

        }
    }
}
void DetectionManager::processShopAvailable(ImageData *image) {
    Position searchStart = makePosition(629, 739);
    Position searchEnd = makePosition(637, 745);
    GenericObject* shop = NULL;
    for (int x = searchStart.x; x < searchEnd.x; x++) {
        for (int y = searchStart.y; y < searchEnd.y; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            shop = ShopManager::detectShopAvailable(image, pixel, x, y);
            if (shop != NULL) {
                x = searchEnd.x;
                y = searchEnd.y;
            }
        }
    }
    if (shop != NULL) {
        shopAvailableShown = true;
        shopAvailable = shop;
    } else {
        shopAvailableShown = false;
    }
}
void DetectionManager::processUsedPotion(ImageData *image) {
//Potion being used
//from 400, 620
//to 560, 660
    Position searchStart = makePosition(400, 620);
    Position searchEnd = makePosition(560, 660);

    GenericObject* potionUsed = NULL;
    for (int x = searchStart.x; x < searchEnd.x; x++) {
        for (int y = searchStart.y; y < searchEnd.y; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            potionUsed = ItemManager::detectUsedPotionAtPixel(image, pixel, x, y);
            if (potionUsed != NULL) {
                x = searchEnd.x;
                y = searchEnd.y;
            }
        }
    }
    if (potionUsed != NULL) {
        potionBeingUsedShown = true;
        potionBeingUsed = potionUsed;
    } else {
        potionBeingUsedShown = false;
    }
}

void DetectionManager::processItemActives(ImageData *image) {
    int searchWidth = 6; int searchHeight = 6;
    Position item1Pos = makePosition(632, 672);
    Position item2Pos = makePosition(666, 672);
    Position item3Pos = makePosition(700, 672);
    Position item4Pos = makePosition(632, 705);
    Position item5Pos = makePosition(667, 705);
    Position item6Pos = makePosition(701, 705);

    potionActiveAvailable = false;

    GenericObject* item = NULL;
    GenericObject* potion = NULL;
    for (int x = item1Pos.x; x < item1Pos.x + searchWidth; x++) {
        for (int y = item1Pos.y; y < item1Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            if (item == NULL) {
                item = ItemManager::detectItemActiveAtPixel(image, pixel, x, y);
            }
            if (potion == NULL) {
                potion = ItemManager::detectPotionActiveAtPixel(image, pixel, x, y);
            }
            if (potion != NULL && item != NULL) {
                x = image->imageWidth; y = image->imageHeight;
            }
        }
    }

    if (item != NULL) {
        item1ActiveAvailable = true;
        item1Active = item;
    } else {
        item1ActiveAvailable = false;
    }
    if (potion != NULL) {
        potionActiveAvailable = true;
        potionActive = potion;
        potionOnActive = 1;
    }

    item = NULL;
    potion = NULL;
    for (int x = item2Pos.x; x < item2Pos.x + searchWidth; x++) {
        for (int y = item2Pos.y; y < item2Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            if (item == NULL) {
                item = ItemManager::detectItemActiveAtPixel(image, pixel, x, y);
            }
            if (potion == NULL) {
                potion = ItemManager::detectPotionActiveAtPixel(image, pixel, x, y);
            }
            if (potion != NULL && item != NULL) {
                x = image->imageWidth; y = image->imageHeight;
            }
        }
    }

    if (item != NULL) {
        item2ActiveAvailable = true;
        item2Active = item;
    } else {
        item2ActiveAvailable = false;
    }
    if (potion != NULL) {
        potionActiveAvailable = true;
        potionActive = potion;
        potionOnActive = 2;
    }

    item = NULL;
    potion = NULL;
    for (int x = item3Pos.x; x < item3Pos.x + searchWidth; x++) {
        for (int y = item3Pos.y; y < item3Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            if (item == NULL) {
                item = ItemManager::detectItemActiveAtPixel(image, pixel, x, y);
            }
            if (potion == NULL) {
                potion = ItemManager::detectPotionActiveAtPixel(image, pixel, x, y);
            }
            if (potion != NULL && item != NULL) {
                x = image->imageWidth; y = image->imageHeight;
            }
        }
    }


    if (item != NULL) {
        item3ActiveAvailable = true;
        item3Active = item;
    } else {
        item3ActiveAvailable = false;
    }
    if (potion != NULL) {
        potionActiveAvailable = true;
        potionActive = potion;
        potionOnActive = 3;
    }

    item = NULL;
    potion = NULL;
    for (int x = item4Pos.x; x < item4Pos.x + searchWidth; x++) {
        for (int y = item4Pos.y; y < item4Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            if (item == NULL) {
                item = ItemManager::detectItemActiveAtPixel(image, pixel, x, y);
            }
            if (potion == NULL) {
                potion = ItemManager::detectPotionActiveAtPixel(image, pixel, x, y);
            }
            if (potion != NULL && item != NULL) {
                x = image->imageWidth; y = image->imageHeight;
            }
        }
    }

    if (item != NULL) {
        item4ActiveAvailable = true;
        item4Active = item;
    } else {
        item4ActiveAvailable = false;
    }
    if (potion != NULL) {
        potionActiveAvailable = true;
        potionActive = potion;
        potionOnActive = 4;
    }

    item = NULL;
    potion = NULL;
    for (int x = item5Pos.x; x < item5Pos.x + searchWidth; x++) {
        for (int y = item5Pos.y; y < item5Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            if (item == NULL) {
                item = ItemManager::detectItemActiveAtPixel(image, pixel, x, y);
            }
            if (potion == NULL) {
                potion = ItemManager::detectPotionActiveAtPixel(image, pixel, x, y);
            }
            if (potion != NULL && item != NULL) {
                x = image->imageWidth; y = image->imageHeight;
            }
        }
    }

    if (item != NULL) {
        item5ActiveAvailable = true;
        item5Active = item;
    } else {
        item5ActiveAvailable = false;
    }
    if (potion != NULL) {
        potionActiveAvailable = true;
        potionActive = potion;
        potionOnActive = 5;
    }

    item = NULL;
    potion = NULL;
    for (int x = item6Pos.x; x < item6Pos.x + searchWidth; x++) {
        for (int y = item6Pos.y; y < item6Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            if (item == NULL) {
                item = ItemManager::detectItemActiveAtPixel(image, pixel, x, y);
            }
            if (potion == NULL) {
                potion = ItemManager::detectPotionActiveAtPixel(image, pixel, x, y);
            }
            if (potion != NULL && item != NULL) {
                x = image->imageWidth; y = image->imageHeight;
            }
        }
    }

    if (item != NULL) {
        item6ActiveAvailable = true;
        item6Active = item;
    } else {
        item6ActiveAvailable = false;
    }
    if (potion != NULL) {
        potionActiveAvailable = true;
        potionActive = potion;
        potionOnActive = 6;
    }
}
void DetectionManager::processSurrender(ImageData *image) {

    int searchWidth = 30; int searchHeight = 30;
    Position surrenderPos = makePosition(image->imageWidth - 210, image->imageHeight - 370);

    GenericObject* surrender = NULL;
    for (int x = surrenderPos.x; x < surrenderPos.x + searchWidth; x++) {
        for (int y = surrenderPos.y; y < surrenderPos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            surrender = SurrenderManager::detectSurrenderAtPixel(image, pixel, x, y);
            if (surrender != NULL) {
                x = image->imageWidth;
                y = image->imageHeight;
            }
        }
    }

    if (surrender != NULL) {
        surrenderAvailable = true;
        surrenderActive = surrender;
    } else {
        surrenderAvailable = false;
    }
}
void DetectionManager::processTrinketActive(ImageData *image) {

    int searchWidth = 10; int searchHeight = 10;
    Position trinketPos = makePosition(738, 675);
//Search for trinket to use
    GenericObject* trinket = NULL;
    for (int x = trinketPos.x; x < trinketPos.x + searchWidth; x++) {
        for (int y = trinketPos.y; y < trinketPos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            trinket = ItemManager::detectTrinketActiveAtPixel(image, pixel, x, y);
            if (trinket != NULL) {
                x = image->imageWidth;
                y = image->imageHeight;
            }
        }
    }
    if (trinket != NULL) {
        trinketActiveAvailable = true;
        trinketActive = trinket;
    } else {
        trinketActiveAvailable = false;
    }
}
void DetectionManager::processSpellActives(ImageData *image) {
    int searchWidth = 6; int searchHeight = 6;
    Position level1Pos = makePosition(346, 672);
    Position level2Pos = makePosition(393, 672);
    Position level3Pos = makePosition(440, 672);
    Position level4Pos = makePosition(488, 672);

//Search for first level up

    GenericObject* ability = NULL;
    for (int x = level1Pos.x; x < level1Pos.x + searchWidth; x++) {
        for (int y = level1Pos.y; y < level1Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            ability = AbilityManager::detectEnabledAbilityAtPixel(image, pixel, x, y);
            if (ability != NULL) {
                x = image->imageWidth;
                y = image->imageHeight;
            }
        }
    }
    if (ability != NULL) {
        spell1ActiveAvailable = true;
        spell1Active = ability;
    } else {
        spell1ActiveAvailable = false;
    }

    ability = NULL;
    for (int x = level2Pos.x; x < level2Pos.x + searchWidth; x++) {
        for (int y = level2Pos.y; y < level2Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            ability = AbilityManager::detectEnabledAbilityAtPixel(image, pixel, x, y);
            if (ability != NULL) {
                x = image->imageWidth;
                y = image->imageHeight;
            }
        }
    }
    if (ability != NULL) {
        spell2ActiveAvailable = true;
        spell2Active = ability;
    } else {
        spell2ActiveAvailable = false;
    }

    ability = NULL;
    for (int x = level3Pos.x; x < level3Pos.x + searchWidth; x++) {
        for (int y = level3Pos.y; y < level3Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            ability = AbilityManager::detectEnabledAbilityAtPixel(image, pixel, x, y);
            if (ability != NULL) {
                x = image->imageWidth;
                y = image->imageHeight;
            }
        }
    }

    if (ability != NULL) {
        spell3ActiveAvailable = true;
        spell3Active = ability;
    } else {
        spell3ActiveAvailable = false;
    }

    ability = NULL;
    for (int x = level4Pos.x; x < level4Pos.x + searchWidth; x++) {
        for (int y = level4Pos.y; y < level4Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            ability = AbilityManager::detectEnabledAbilityAtPixel(image, pixel, x, y);
            if (ability != NULL) {
                x = image->imageWidth;
                y = image->imageHeight;
            }
        }
    }

    if (ability != NULL) {
        spell4ActiveAvailable = true;
        spell4Active = ability;
    } else {
        spell4ActiveAvailable = false;
    }
}

void DetectionManager::processSummonerSpellActives(ImageData *image) {
    int searchWidth = 6; int searchHeight = 6;
    Position spell1Pos = makePosition(541, 671);
    Position spell2Pos = makePosition(577, 671);

    GenericObject* ability = NULL;
    for (int x = spell1Pos.x; x < spell1Pos.x + searchWidth; x++) {
        for (int y = spell1Pos.y; y < spell1Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            ability = AbilityManager::detectEnabledSummonerSpellAtPixel(image, pixel, x, y);
            if (ability != NULL) {
                x = image->imageWidth;
                y = image->imageHeight;
            }
        }
    }
    if (ability != NULL) {
        summonerSpell1ActiveAvailable = true;
        summonerSpell1Active = ability;
    } else {
        summonerSpell1ActiveAvailable = false;
    }

    ability = NULL;
    for (int x = spell2Pos.x; x < spell2Pos.x + searchWidth; x++) {
        for (int y = spell2Pos.y; y < spell2Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            ability = AbilityManager::detectEnabledSummonerSpellAtPixel(image, pixel, x, y);
            if (ability != NULL) {
                x = image->imageWidth;
                y = image->imageHeight;
            }
        }
    }

    if (ability != NULL) {
        summonerSpell2ActiveAvailable = true;
        summonerSpell2Active = ability;
    } else {
        summonerSpell2ActiveAvailable = false;
    }

}

void DetectionManager::processSpellLevelDots(ImageData *image) {
    int searchWidth = 40; int searchHeight = 5;
    Position levelDot1Pos = makePosition(351, 719);
    Position levelDot2Pos = makePosition(398, 719);
    Position levelDot3Pos = makePosition(446, 719);
    Position levelDot4Pos = makePosition(500, 719);

    for (int x = levelDot1Pos.x; x < levelDot1Pos.x + searchWidth; x++) {
        for (int y = levelDot1Pos.y; y < levelDot1Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            GenericObject* leveldot = AbilityManager::detectLevelDotAtPixel(image, pixel, x, y);
            if (leveldot != NULL) {
                spell1LevelDots->push_back(leveldot);
                y = levelDot1Pos.y;
                x += AbilityManager::levelDotImageData.imageWidth;
            }
        }
    }

    for (int x = levelDot2Pos.x; x < levelDot2Pos.x + searchWidth; x++) {
        for (int y = levelDot2Pos.y; y < levelDot2Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            GenericObject* leveldot = AbilityManager::detectLevelDotAtPixel(image, pixel, x, y);
            if (leveldot != NULL) {
                spell2LevelDots->push_back(leveldot);
                y = levelDot2Pos.y;
                x += AbilityManager::levelDotImageData.imageWidth;
            }
        }
    }

    for (int x = levelDot3Pos.x; x < levelDot3Pos.x + searchWidth; x++) {
        for (int y = levelDot3Pos.y; y < levelDot3Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            GenericObject* leveldot = AbilityManager::detectLevelDotAtPixel(image, pixel, x, y);
            if (leveldot != NULL) {
                spell3LevelDots->push_back(leveldot);
                y = levelDot3Pos.y;
                x += AbilityManager::levelDotImageData.imageWidth;
            }
        }
    }

    for (int x = levelDot4Pos.x; x < levelDot4Pos.x + searchWidth; x++) {
        for (int y = levelDot4Pos.y; y < levelDot4Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            GenericObject* leveldot = AbilityManager::detectLevelDotAtPixel(image, pixel, x, y);
            if (leveldot != NULL) {
                spell4LevelDots->push_back(leveldot);
                y = levelDot4Pos.y;
                x += AbilityManager::levelDotImageData.imageWidth;
            }
        }
    }
    currentLevel = (int)(spell1LevelDots->size() + spell2LevelDots->size() + spell3LevelDots->size() + spell4LevelDots->size());
}

void DetectionManager::processSpellLevelUps(ImageData *image) {
    int searchWidth = 10; int searchHeight = 5;
    Position levelUp1Pos = makePosition(349, 634);
    Position levelUp2Pos = makePosition(396, 634);
    Position levelUp3Pos = makePosition(444, 634);
    Position levelUp4Pos = makePosition(490, 634);
    GenericObject* levelUp = NULL;
    for (int x = levelUp1Pos.x; x < levelUp1Pos.x + searchWidth; x++) {
        for (int y = levelUp1Pos.y; y < levelUp1Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            GenericObject* levelup = AbilityManager::detectLevelUpAtPixel(image, pixel, x, y);
            if (levelup != NULL) {
                levelUp = levelup;
                x = image->imageWidth;
                y = image->imageHeight;
            }
        }
    }

    if (levelUp != NULL) {
        spell1LevelUpAvailable = true;
        spell1LevelUp = levelUp;
    } else {
        spell1LevelUpAvailable = false;
    }

    levelUp = NULL;
    for (int x = levelUp2Pos.x; x < levelUp2Pos.x + searchWidth; x++) {
        for (int y = levelUp2Pos.y; y < levelUp2Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            GenericObject* levelup = AbilityManager::detectLevelUpAtPixel(image, pixel, x, y);
            if (levelup != NULL) {
                levelUp = levelup;
                x = image->imageWidth;
                y = image->imageHeight;
            }
        }
    }
    if (levelUp != NULL) {
        spell2LevelUpAvailable = true;
        spell2LevelUp = levelUp;
    } else {
        spell2LevelUpAvailable = false;
    }

    levelUp = NULL;
    for (int x = levelUp3Pos.x; x < levelUp3Pos.x + searchWidth; x++) {
        for (int y = levelUp3Pos.y; y < levelUp3Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            GenericObject* levelup = AbilityManager::detectLevelUpAtPixel(image, pixel, x, y);
            if (levelup != NULL) {
                levelUp = levelup;
                x = image->imageWidth;
                y = image->imageHeight;
            }
        }
    }

    if (levelUp != NULL) {
        spell3LevelUpAvailable = true;
        spell3LevelUp = levelUp;
    } else {
        spell3LevelUpAvailable = false;
    }

    levelUp = NULL;
    for (int x = levelUp4Pos.x; x < levelUp4Pos.x + searchWidth; x++) {
        for (int y = levelUp4Pos.y; y < levelUp4Pos.y + searchHeight; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            GenericObject* levelup = AbilityManager::detectLevelUpAtPixel(image, pixel, x, y);
            if (levelup != NULL) {
                levelUp = levelup;
                x = image->imageWidth;
                y = image->imageHeight;
            }
        }
    }

    if (levelUp != NULL) {
        spell4LevelUpAvailable = true;
        spell4LevelUp = levelUp;
    } else {
        spell4LevelUpAvailable = false;
    }

}

void DetectionManager::processSelfHealthBarDetection(ImageData *image) {
    Position searchStart = makePosition(300, 728);
    Position searchEnd = makePosition(320, 748);
    std::vector<SelfHealth*>* healthBars = new std::vector<SelfHealth*>();

    for (int x = searchStart.x; x < searchEnd.x; x++) {
        for (int y = searchStart.y; y < searchEnd.y; y++) {
            uint8_t* pixel = getPixel2(image, x, y);
            SelfHealth* healthBar = SelfChampionManager::detectSelfHealthBarAtPixel(image, pixel, x, y);
            if (healthBar != NULL) {
                healthBars->push_back(healthBar);
                x = searchEnd.x;
                y = searchEnd.y;
            }
        }
    }
    SelfChampionManager::validateSelfHealthBars(image, healthBars);
    if (healthBars->size() > 0) {
        selfHealthBarVisible = true;
        selfHealthBar = healthBars->front();
    } else {
        selfHealthBarVisible = false;
    }

}





int DetectionManager::getPotionActiveItemSlot() {
    return potionOnActive;
}
bool DetectionManager::getSurrenderAvailable() {
    return surrenderAvailable;
}
GenericObject* DetectionManager::getSurrender() {
    return surrenderActive;
}
std::vector<Minion*>* DetectionManager::getAllyMinions() {
    return allyMinions;
}
std::vector<Minion*>* DetectionManager::getEnemyMinions() {
    return enemyMinions;
}
std::vector<Champion*>* DetectionManager::getAllyChampions() {
    return allyChampions;
}
std::vector<Champion*>* DetectionManager::getEnemyChampions() {
    return enemyChampions;
}
std::vector<Tower*>* DetectionManager::getEnemyTowers() {
    return enemyTowers;
}
std::vector<Champion*>* DetectionManager::getSelfChampions() {
    return selfChampions;
}
bool DetectionManager::getSelfHealthBarVisible() {
    return selfHealthBarVisible;
}
SelfHealth* DetectionManager::getSelfHealthBar() {
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
std::vector<GenericObject*>* DetectionManager::getSpell1LevelDots() {
    return spell1LevelDots;
}
std::vector<GenericObject*>* DetectionManager::getSpell2LevelDots() {
    return spell2LevelDots;
}
std::vector<GenericObject*>* DetectionManager::getSpell3LevelDots() {
    return spell3LevelDots;
}
std::vector<GenericObject*>* DetectionManager::getSpell4LevelDots() {
    return spell4LevelDots;
}
int DetectionManager::getCurrentLevel() {
    return currentLevel;
}
bool DetectionManager::getSpell1Available() {
    return spell1ActiveAvailable;
}
bool DetectionManager::getSpell2Available() {
    return spell2ActiveAvailable;
}
bool DetectionManager::getSpell3Available() {
    return spell3ActiveAvailable;
}
bool DetectionManager::getSpell4Available() {
    return spell4ActiveAvailable;
}
GenericObject* DetectionManager::getSpell1() {
    return spell1Active;
}
GenericObject* DetectionManager::getSpell2() {
    return spell2Active;
}
GenericObject* DetectionManager::getSpell3() {
    return spell3Active;
}
GenericObject* DetectionManager::getSpell4() {
    return spell4Active;
}
bool DetectionManager::getSummonerSpell1Available() {
    return summonerSpell1ActiveAvailable;
}
bool DetectionManager::getSummonerSpell2Available() {
    return summonerSpell2ActiveAvailable;
}
GenericObject* DetectionManager::getSummonerSpell1() {
    return summonerSpell1Active;
}
GenericObject* DetectionManager::getSummonerSpell2() {
    return summonerSpell2Active;
}
bool DetectionManager::getTrinketActiveAvailable() {
    return trinketActiveAvailable;
}
GenericObject* DetectionManager::getTrinketActive() {
    return trinketActive;
}
bool DetectionManager::getItem1ActiveAvailable() {
    return item1ActiveAvailable;
}
bool DetectionManager::getItem2ActiveAvailable() {
    return item2ActiveAvailable;
}
bool DetectionManager::getItem3ActiveAvailable() {
    return item3ActiveAvailable;
}
bool DetectionManager::getItem4ActiveAvailable() {
    return item4ActiveAvailable;
}
bool DetectionManager::getItem5ActiveAvailable() {
    return item5ActiveAvailable;
}
bool DetectionManager::getItem6ActiveAvailable() {
    return item6ActiveAvailable;
}
GenericObject* DetectionManager::getItem1Active() {
    return item1Active;
}
GenericObject* DetectionManager::getItem2Active() {
    return item2Active;
}
GenericObject* DetectionManager::getItem3Active() {
    return item3Active;
}
GenericObject* DetectionManager::getItem4Active() {
    return item4Active;
}
GenericObject* DetectionManager::getItem5Active() {
    return item5Active;
}
GenericObject* DetectionManager::getItem6Active() {
    return item6Active;
}
bool DetectionManager::getPotionActiveAvailable() {
    return potionActiveAvailable;
}
GenericObject* DetectionManager::getPotionActive() {
    return potionActive;
}
bool DetectionManager::getPotionBeingUsedVisible() {
    return potionBeingUsedShown;
}
GenericObject* DetectionManager::getPotionBeingUsed() {
    return potionBeingUsed;
}
bool DetectionManager::getShopAvailable() {
    return shopAvailableShown;
}
GenericObject* DetectionManager::getShopAvailableObject() {
    return shopAvailable;
}
bool DetectionManager::getShopTopLeftCornerVisible() {
    return shopTopLeftCornerShown;
}
GenericObject* DetectionManager::getShopTopLeftCorner() {
    return shopTopLeftCorner;
}
bool DetectionManager::getShopBottomLeftCornerVisible() {
    return shopBottomLeftCornerShown;
}
GenericObject* DetectionManager::getShopBottomleftCorner() {
    return shopBottomLeftCorner;
}
std::vector<GenericObject*>* DetectionManager::getBuyableItems() {
    return buyableItems;
}
bool DetectionManager::getMapVisible() {
    return mapVisible;
}
GenericObject* DetectionManager::getMap() {
    return map;
}
bool DetectionManager::getMapShopVisible() {
    return mapShopVisible;
}
GenericObject* DetectionManager::getMapShop() {
    return mapShop;
}
bool DetectionManager::getMapLocationVisible() {
    return mapSelfLocationVisible;
}
GenericObject* DetectionManager::getMapLocation() {
    return mapSelfLocation;
}