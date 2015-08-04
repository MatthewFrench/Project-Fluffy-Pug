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
#import <time.h>

class AllyChampionManager {
    ImageData topLeftImageData, bottomLeftImageData,
    bottomRightImageData, topRightImageData, healthSegmentImageData;
    
    
    //moodycamel::ConcurrentQueue<Position> topLeftQueue, bottomLeftQueue, topRightQueue, bottomRightQueue;
    
    bool needsFullScreenUpdate;
    
    double fullScreenUpdateTime, lastUpdateTime;
    
    void scanSection(ImageData imageData, int xStart, int yStart, int xEnd, int yEnd);
    void processChampionsLocations();
    void processChampionsHealth(ImageData imageData);
    void processPixel(ImageData imageData, uint8_t *pixel, int x, int y);
    void processTopLeftDetect(); void processBottomLeftDetect(); void processTopRightDetect(); void processBottomRightDetect();
    bool containsPosition(NSMutableArray* array, Position p);
    
    const double championSpeed = 1000; //100 pixels per second
    
public:
    NSMutableArray* championBars, *topRightDetect, *topLeftDetect, *bottomRightDetect, *bottomLeftDetect;
    
    AllyChampionManager();
    void processImage(ImageData data);
    ChampionBar getNearestChampion(int x, int y);
    
    void debugDraw(ImageData imageData);
};