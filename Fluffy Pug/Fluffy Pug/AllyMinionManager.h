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
    //NSLock* blackBorderLock;
    NSMutableArray* topLeftAllyMinionCorners;
    NSMutableArray* bottomLeftAllyMinionCorners;
    struct ImageData imageData;
    
    
    moodycamel::ConcurrentQueue<Position> topLeftAllyMinionQueue, bottomLeftAllyMinionQueue;
    
public:
    NSMutableArray* minionBars;
    AllyMinionManager();
    void processPixel(uint8_t *pixel, int x, int y);
    void setImageData(ImageData data);
    
    void prepareForPixelProcessing();
    void postPixelProcessing();
    void debugDraw();
};

//@property NSMutableArray* minionBars, *topLeftAllyMinionCorners, *bottomLeftAllyMinionCorners;
//@property NSLock* blackBorderLock;

//@end