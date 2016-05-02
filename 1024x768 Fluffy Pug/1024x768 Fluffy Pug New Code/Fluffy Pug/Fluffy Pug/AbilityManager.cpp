//
//  AbilityManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#include "AbilityManager.h"

ImageData AbilityManager::enabledSummonerSpellImageData = loadImage("Resources/Skill Bar/Enabled Summoner Spell.png");
ImageData AbilityManager::levelDotImageData = loadImage("Resources/Skill Bar/Leveled Dot.png");
ImageData AbilityManager::levelUpImageData = loadImage("Resources/Skill Bar/Level Up.png");
ImageData AbilityManager::levelUpDisabledImageData = loadImage("Resources/Skill Bar/Level Up Disabled.png");
ImageData AbilityManager::abilityEnabledImageData = loadImage("Resources/Skill Bar/Enabled Ability.png");
ImageData AbilityManager::abilityDisabledImageData = loadImage("Resources/Skill Bar/Disabled Ability.png");

AbilityManager::AbilityManager() {
}

GenericObject* AbilityManager::detectLevelUpAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = NULL;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &levelUpImageData, 0.25) >=  0.8) {
        object = new GenericObject();
        object->topLeft.x = x;
        object->topLeft.y = y;
        object->bottomLeft.x = x;
        object->bottomLeft.y = y + levelUpImageData.imageHeight;
        object->topRight.x = x + levelUpImageData.imageWidth;
        object->topRight.y = y;
        object->bottomRight.x = x + levelUpImageData.imageWidth;
        object->bottomRight.y = y + levelUpImageData.imageHeight;
        object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
        object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
    }
    
    return object;
}
const float levelDotPrecision = 0.6;
GenericObject* AbilityManager::detectLevelDotAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = NULL;
    
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &levelDotImageData, levelDotPrecision) >=  levelDotPrecision) {
        object = new GenericObject();
        object->topLeft.x = x;
        object->topLeft.y = y;
        object->bottomLeft.x = x;
        object->bottomLeft.y = y + levelDotImageData.imageHeight;
        object->topRight.x = x + levelDotImageData.imageWidth;
        object->topRight.y = y;
        object->bottomRight.x = x + levelDotImageData.imageWidth;
        object->bottomRight.y = y + levelDotImageData.imageHeight;
        object->center.x = object->topLeft.x + 2;
        object->center.y = object->topLeft.y + 3;
    }
    
    return object;
}
const float abilityEnabledPrecision = 0.7;
GenericObject* AbilityManager::detectEnabledAbilityAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = NULL;
    
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &abilityEnabledImageData, abilityEnabledPrecision) >=  abilityEnabledPrecision) {
        object = new GenericObject();
        object->topLeft.x = x;
        object->topLeft.y = y;
        object->bottomLeft.x = x;
        object->bottomLeft.y = y + abilityEnabledImageData.imageHeight;
        object->topRight.x = x + abilityEnabledImageData.imageWidth;
        object->topRight.y = y;
        object->bottomRight.x = x + abilityEnabledImageData.imageWidth;
        object->bottomRight.y = y + abilityEnabledImageData.imageHeight;
        object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
        object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
    }
    
    return object;
}
GenericObject* AbilityManager::detectEnabledSummonerSpellAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = NULL;
    
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &enabledSummonerSpellImageData, 0.9) >=  0.9) {
        object = new GenericObject();
        object->topLeft.x = x;
        object->topLeft.y = y;
        object->bottomLeft.x = x;
        object->bottomLeft.y = y + enabledSummonerSpellImageData.imageHeight;
        object->topRight.x = x + enabledSummonerSpellImageData.imageWidth;
        object->topRight.y = y;
        object->bottomRight.x = x + enabledSummonerSpellImageData.imageWidth;
        object->bottomRight.y = y + enabledSummonerSpellImageData.imageHeight;
        object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
        object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
    }
    
    return object;
}