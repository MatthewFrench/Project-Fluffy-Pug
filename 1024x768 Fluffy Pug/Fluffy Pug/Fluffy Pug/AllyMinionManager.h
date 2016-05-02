//
//  AllyMinionManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

class AllyMinionManager {
    
    
    //moodycamel::ConcurrentQueue<Position> topLeftQueue, bottomLeftQueue, topRightQueue, bottomRightQueue;
    /*
    bool needsFullScreenUpdate;
    
    double fullScreenUpdateTime, lastUpdateTime;
    
    void scanSection(ImageData imageData, int xStart, int yStart, int xEnd, int yEnd);
    void processMinionsLocations(ImageData imageData);
    void processMinionsHealth(ImageData imageData);
    void processPixel(ImageData imageData, uint8_t *pixel, int x, int y);
    void processTopLeftDetect(); void processBottomLeftDetect(); void processTopRightDetect(); void processBottomRightDetect();
    bool containsPosition(NSMutableArray* array, Position p);
    
    const double minionSpeed = 400; //100 pixels per second
    */
public:
    //NSMutableArray* minionBars, *topRightDetect, *topLeftDetect, *bottomRightDetect, *bottomLeftDetect;
    
    AllyMinionManager();
    
    static ImageData topLeftImageData, bottomLeftImageData,
    bottomRightImageData, topRightImageData, healthSegmentImageData, wardImageData;
    
    static Minion* detectMinionBarAtPixel(ImageData imageData, uint8_t *pixel, int x, int y);
    
    static NSMutableArray* validateMinionBars(ImageData imageData, NSMutableArray* detectedChampionBars);
    //void processImage(ImageData data);
    //MinionBar getNearestMinion(int x, int y);
    //MinionBar getFurthestMinion(int x, int y);
    
    //void debugDraw(ImageData imageData);
};