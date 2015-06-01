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
    NSMutableArray* topLeftCorners;
    NSMutableArray* bottomLeftCorners;
    struct ImageData imageData;
    
    
    moodycamel::ConcurrentQueue<Position> topLeftQueue, bottomLeftQueue;
    
public:
    NSMutableArray* championBars;
    EnemyChampionManager();
    void processPixel(uint8_t *pixel, int x, int y);
    void setImageData(ImageData data);
    
    void prepareForPixelProcessing();
    void postPixelProcessing();
    void debugDraw();
};