//
//  ItemManagerPBE.h
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Utility.h"
#import <time.h>
#import "InteractiveEvents.h"

class ItemManagerPBE {
    ImageData imageData, trinketItemImageData, itemImageData;
    
    void detectItems();
    
    bool needsFullScreenUpdate;
    
    double fullScreenUpdateTime, lastUpdateTime;
    bool usedItemInFrame;
    double item1Time, item2Time, item3Time, trinketTime, item5Time, item6Time, item7Time;
    /*
     , topLeftImageData, bottomLeftImageData,
     bottomRightImageData, topRightImageData, healthSegmentImageData;
     
     void scanSection(int xStart, int yStart, int xEnd, int yEnd);
     void processMinionsLocations();
     void processMinionsHealth();
     void processPixel(uint8_t *pixel, int x, int y);
     void processTopLeftDetect(); void processBottomLeftDetect(); void processTopRightDetect(); void processBottomRightDetect();
     bool containsPosition(NSMutableArray* array, Position p);
     
     const double minionSpeed = 2000; //100 pixels per second
     */
public:
    ItemManagerPBE();
    void processImage(ImageData data);
    //NSMutableArray* levelUpDetect, *levelUpDisabledDetect, *abilityEnabledDetect, *abilityDisabledDetect;
    bool item1Active, item2Active, item3Active, trinketActive;
    bool item5Active, item6Active, item7Active;
    void useItem1();
    void useItem2();
    void useItem3();
    void useTrinket(int x, int y);
    void useItem5();
    void useItem6();
    void useItem7();
    /*
     NSMutableArray* minionBars, *topRightDetect, *topLeftDetect, *bottomRightDetect, *bottomLeftDetect;
     
     MinionBar getNearestMinion(int x, int y);
     MinionBar getLowestHealthMinion(int x, int y);
     
     void debugDraw();
     */
};