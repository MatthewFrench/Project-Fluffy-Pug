//
//  TurretManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 6/12/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"
#include "concurrentqueue.h"
#import <time.h>

class EnemyTowerManager {
    ImageData imageData, topLeftImageData, bottomLeftImageData,
    bottomRightImageData, topRightImageData, healthSegmentImageData;
    
    bool needsFullScreenUpdate;
    
    double fullScreenUpdateTime, lastUpdateTime;
    const double TowerSpeed = 600; //100 pixels per second
    
    //moodycamel::ConcurrentQueue<Position> topLeftQueue, bottomLeftQueue, topRightQueue, bottomRightQueue;
    
    void scanSection(int xStart, int yStart, int xEnd, int yEnd);
    void processTowersLocations();
    void processTowersHealth();
    void processPixel(uint8_t *pixel, int x, int y);
    void processTopLeftDetect(); void processBottomLeftDetect(); void processTopRightDetect(); void processBottomRightDetect();
    bool containsPosition(NSMutableArray* array, Position p);
public:
    EnemyTowerManager();
    void debugDraw();
    
    NSMutableArray* towerBars, *topRightDetect, *topLeftDetect, *bottomRightDetect, *bottomLeftDetect;
    void processImage(ImageData data);
    TowerBar getNearestTower(int x, int y);
    TowerBar getLowestHealthTower(int x, int y);
};