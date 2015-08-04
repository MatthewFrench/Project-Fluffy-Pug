//
//  AbilityManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"
#import "InteractiveEvents.h"

class AbilityManager {
    ImageData levelUpImageData, levelDotImageData, levelUpDisabledImageData, abilityEnabledImageData, abilityDisabledImageData, enabledSummonerSpellImageData;
    
    void processPixelLevelUp(ImageData imageData, uint8_t *pixel, int x, int y);
    bool containsPosition(NSMutableArray* array, Position p);
    void detectLevelUp(ImageData imageData);
    void detectLevelUpCount(ImageData imageData);
    void processPixelLevelUpCount(ImageData imageData, uint8_t *pixel, int x, int y);
    void detectAbilities(ImageData imageData);
    void processPixelAbilities(ImageData imageData, uint8_t *pixel, int x, int y);
    void detectSummonerSpells(ImageData imageData);
    
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
    void processImage(ImageData imageData);
    NSMutableArray* levelUpDetect, *levelUpDisabledDetect, *abilityEnabledDetect, *abilityDisabledDetect;
    bool ability1LevelUpAvailable, ability2LevelUpAvailable, ability3LevelUpAvailable, ability4LevelUpAvailable;
    bool ability1Ready, ability2Ready, ability3Ready, ability4Ready;
    int levelUpCount;
    bool summonerSpell1Ready, summonerSpell2Ready;
    
    void useSpell1();
    void useSpell2();
    void useSpell3();
    void useSpell4();
    
    void useSummonerSpell1();
    void useSummonerSpell2();
    /*
     NSMutableArray* minionBars, *topRightDetect, *topLeftDetect, *bottomRightDetect, *bottomLeftDetect;
     
     MinionBar getNearestMinion(int x, int y);
     MinionBar getLowestHealthMinion(int x, int y);
     
     void debugDraw();
     */
};