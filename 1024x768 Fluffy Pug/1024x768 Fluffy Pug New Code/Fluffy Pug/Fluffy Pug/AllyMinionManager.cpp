//
//  AllyMinionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#include "AllyMinionManager.h"

ImageData AllyMinionManager::wardImageData = loadImage("Resources/Ward/Pink Ward.png");

ImageData AllyMinionManager::topLeftImageData = loadImage("Resources/Ally Minion Health Bar/Top Left Corner.png");

ImageData AllyMinionManager::bottomLeftImageData = loadImage("Resources/Ally Minion Health Bar/Bottom Left Corner.png");
ImageData AllyMinionManager::bottomRightImageData = loadImage("Resources/Ally Minion Health Bar/Bottom Right Corner.png");
ImageData AllyMinionManager::topRightImageData = loadImage("Resources/Ally Minion Health Bar/Top Right Corner.png");
ImageData AllyMinionManager::healthSegmentImageData = loadImage("Resources/Ally Minion Health Bar/Health Segment.png");

AllyMinionManager::AllyMinionManager () {}

//To Validate, at least 2 corners need detected then we detect the health percentage

void AllyMinionManager::validateMinionBars(ImageData* imageData, std::vector<Minion*>* detectedMinionBars) {
      const float coloredPixelPrecision = 0.96; //0.97
    const float overalImagePrecision = 0.96; //0.97
        const float allyMinionHealthMatch = 0.80; //0.87
    
    //Remove duplicates
    for (int i = 0; i < detectedMinionBars->size(); i++) {
        Minion* minion = (*detectedMinionBars)[i];
        int detectedCorners = 1;
        for (int j = 0; j < detectedMinionBars->size(); j++) {
            if (j != i) {
                Minion* minion2 = (*detectedMinionBars)[j];
                if (minion2->topLeft.x == minion->topLeft.x && minion->topLeft.y == minion2-> topLeft.y) {
                    detectedMinionBars->erase(detectedMinionBars->begin() + j);
                    j--;
                    if (minion2->detectedBottomLeft) minion->detectedBottomLeft = true;
                    if (minion2->detectedBottomRight) minion->detectedBottomRight = true;
                    if (minion2->detectedTopLeft) minion->detectedTopLeft = true;
                    if (minion2->detectedTopRight) minion->detectedTopRight = true;
                    if (minion2->health > minion->health) minion->health = minion2->health;
                    if (minion2->lowestPercentageMatch < minion->lowestPercentageMatch) minion->lowestPercentageMatch = minion2->lowestPercentageMatch;
                    detectedCorners++;
                }
            }
        }
        if (detectedCorners < 2) {
            detectedMinionBars->erase(detectedMinionBars->begin() + i);
            i--;
        }
        minion->characterCenter.x = minion->topLeft.x+30; minion->characterCenter.y = minion->topLeft.y+32;
    }

    //Detect health
    for (int i = 0; i < detectedMinionBars->size(); i++) {
        Minion* minion = (*detectedMinionBars)[i];
        if (minion->health == 0) {
            for (int x = 61; x >= 0; x--) {
                for (int y = 0; y < healthSegmentImageData.imageHeight; y++) {
                    if (x + minion->topLeft.x >= 0 && x + minion->topLeft.x < imageData->imageWidth &&
                        y + minion->topLeft.y >= 0 && y + minion->topLeft.y < imageData->imageHeight) {
                        uint8_t* healthBarColor = getPixel2(&healthSegmentImageData, 0, y);
                        uint8_t* p = getPixel2(imageData, x + minion->topLeft.x, y + minion->topLeft.y);
                        if (getColorPercentage(healthBarColor, p) >= allyMinionHealthMatch) {
                            minion->health = (float)x / 61 * 100;
                            y = healthSegmentImageData.imageHeight + 1;
                            x = -1;
                        }
                    }
                }
            }
        }
        if (minion->health == 0) { //Not a minion
            detectedMinionBars->erase(detectedMinionBars->begin() + i);
            i--;
        }
    }
        
    //Detect if ward
    //Ward is 193, 193, 193
    for (int i = 0; i < detectedMinionBars->size(); i++) {
        Minion* minion = (*detectedMinionBars)[i];
        bool isWard = false;
        for (int x = 61; x >= 0; x--) {
            for (int yOffset = -3; yOffset <= 1; yOffset++) {
                if (x + minion->topLeft.x >= 0 && x + minion->topLeft.x < imageData->imageWidth &&
                    yOffset + minion->topLeft.y >= 0 && yOffset + minion->topLeft.y < imageData->imageHeight) {
                    uint8_t*  p = getPixel2(imageData, x + minion->topLeft.x, yOffset + minion->topLeft.y);
                    if (isColor(p, 220, 220, 220, 45)) {
                        isWard = true;
                        x = -1;
                        yOffset = 4;
                }
            }
            }
        }
        //Detect if pink ward
        if (minion->topLeft.x-1 >= 0 && minion->topLeft.x-1 + wardImageData.imageWidth < imageData->imageWidth &&
            minion->topLeft.y-1 >= 0 && minion->topLeft.y-1 + wardImageData.imageHeight < imageData->imageHeight) {
        if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, minion->topLeft.x-1, minion->topLeft.y-1), minion->topLeft.x-1, minion->topLeft.y-1, imageData->imageWidth, imageData->imageHeight, &wardImageData, coloredPixelPrecision) >=  overalImagePrecision) {
            isWard = true;
        }
        }
        if (isWard) {
            detectedMinionBars->erase(detectedMinionBars->begin() + i);
            i--;
        }
    }
}