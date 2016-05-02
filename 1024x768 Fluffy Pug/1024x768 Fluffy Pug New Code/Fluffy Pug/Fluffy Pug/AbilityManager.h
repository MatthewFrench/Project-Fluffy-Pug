//
//  AbilityManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#include "Utility.h"
#include <vector>

class AbilityManager {
public:
    static ImageData levelUpImageData, levelDotImageData, levelUpDisabledImageData, abilityEnabledImageData, abilityDisabledImageData, enabledSummonerSpellImageData;
    AbilityManager();
    
    static GenericObject* detectLevelUpAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y);
    static GenericObject* detectLevelDotAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y);
    static GenericObject* detectEnabledAbilityAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y);
    static GenericObject* detectEnabledSummonerSpellAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y);
};