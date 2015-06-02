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

class EnemyChampionManager {
    ImageData imageData, topLeftImageData, bottomLeftImageData,
    bottomRightImageData, topRightImageData, healthSegmentImageData;
    
    
    moodycamel::ConcurrentQueue<Position> topLeftQueue, bottomLeftQueue, topRightQueue, bottomRightQueue;
    
public:
    NSMutableArray* championBars, *topRightDetect, *topLeftDetect, *bottomRightDetect, *bottomLeftDetect;
    
    EnemyChampionManager();
    void processPixel(uint8_t *pixel, int x, int y);
    void setImageData(ImageData data);
    
    void prepareForPixelProcessing();
    void postPixelProcessing();
    void debugDraw();
};