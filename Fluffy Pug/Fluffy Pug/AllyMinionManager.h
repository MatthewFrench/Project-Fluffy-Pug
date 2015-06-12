//
//  AllyMinionManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"
#include "concurrentqueue.h"

class AllyMinionManager {
    ImageData imageData, topLeftImageData, bottomLeftImageData,
    bottomRightImageData, topRightImageData, healthSegmentImageData,  ward, pinkWard;
    
    
    //moodycamel::ConcurrentQueue<Position> topLeftQueue, bottomLeftQueue, topRightQueue, bottomRightQueue;
    
    bool needsFullScreenUpdate;
    
    double fullScreenUpdateTime, lastUpdateTime;
    
    void scanSection(int xStart, int yStart, int xEnd, int yEnd);
    void processMinionsLocations();
    void processMinionsHealth();
    void processPixel(uint8_t *pixel, int x, int y);
    void processTopLeftDetect(); void processBottomLeftDetect(); void processTopRightDetect(); void processBottomRightDetect();
    bool containsPosition(NSMutableArray* array, Position p);
    
    const double minionSpeed = 2000; //100 pixels per second
    
public:
    NSMutableArray* minionBars, *topRightDetect, *topLeftDetect, *bottomRightDetect, *bottomLeftDetect;
    
    AllyMinionManager();
    void processImage(ImageData data);
    MinionBar getNearestMinion(int x, int y);
    MinionBar getFurthestMinion(int x, int y);
    
    void debugDraw();
};