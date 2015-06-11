//
//  AbilityManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

class AbilityManager {
    ImageData imageData, levelUpImageData, levelDotImageData, levelUpDisabledImageData, abilityEnabledImageData, abilityDisabledImageData;
    
    void processPixelLevelUp(uint8_t *pixel, int x, int y);
    bool containsPosition(NSMutableArray* array, Position p);
    void detectLevelUp();
    void detectLevelUpCount();
    void processPixelLevelUpCount(uint8_t *pixel, int x, int y);
    void detectAbilities();
    void processPixelAbilities(uint8_t *pixel, int x, int y);
    
    bool needsFullScreenUpdate;
    
    double fullScreenUpdateTime, lastUpdateTime;
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
    AbilityManager();
    void processImage(ImageData data);
    NSMutableArray* levelUpDetect, *levelUpDisabledDetect, *abilityEnabledDetect, *abilityDisabledDetect;
    bool ability1LevelUpAvailable, ability2LevelUpAvailable, ability3LevelUpAvailable, ability4LevelUpAvailable;
    bool ability1Ready, ability2Ready, ability3Ready, ability4Ready;
    int levelUpCount;
    /*
    NSMutableArray* minionBars, *topRightDetect, *topLeftDetect, *bottomRightDetect, *bottomLeftDetect;
    
    MinionBar getNearestMinion(int x, int y);
    MinionBar getLowestHealthMinion(int x, int y);
    
    void debugDraw();
     */
};