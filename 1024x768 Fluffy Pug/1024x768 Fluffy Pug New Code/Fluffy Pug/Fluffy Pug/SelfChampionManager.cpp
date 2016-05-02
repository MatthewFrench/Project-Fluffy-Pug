//
//  SelfChampionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#include "SelfChampionManager.h"

ImageData SelfChampionManager::topLeftImageData = loadImage("Resources/Self Health Bar/Top Left Corner.png");

ImageData SelfChampionManager::bottomLeftImageData = loadImage("Resources/Self Health Bar/Bottom Left Corner.png");
ImageData SelfChampionManager::bottomRightImageData = loadImage("Resources/Self Health Bar/Bottom Right Corner.png");
ImageData SelfChampionManager::topRightImageData = loadImage("Resources/Self Health Bar/Top Right Corner.png");
ImageData SelfChampionManager::healthSegmentImageData = loadImage("Resources/Self Health Bar/Health Segment.png");
ImageData SelfChampionManager::bottomBarLeftSideImageData = loadImage("Resources/Self Health Bar/Bottom Bar Left Side.png");
ImageData SelfChampionManager::bottomBarRightSideImageData = loadImage("Resources/Self Health Bar/Bottom Bar Right Side.png");
ImageData SelfChampionManager::bottomBarAverageHealthColorImageData = loadImage("Resources/Self Health Bar/Bottom Bar Average Health Color.png");

SelfChampionManager::SelfChampionManager () {}

const float SelfHealthBarMaxPercent = 0.75;
const int SelfHealthBarHeight = 12;
const int SelfHealthBarWidth = 293;
SelfHealth* SelfChampionManager::detectSelfHealthBarAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y) {
    SelfHealth* healthBar = NULL;
    
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &bottomBarLeftSideImageData, SelfHealthBarMaxPercent) >=  SelfHealthBarMaxPercent) {
        int barTopLeftX = x + 15;
        int barTopLeftY = y + 3;
        healthBar = new SelfHealth();
        healthBar->topLeft.x = barTopLeftX;
        healthBar->topLeft.y = barTopLeftY;
        healthBar->bottomLeft.x = barTopLeftX;
        healthBar->bottomLeft.y = barTopLeftY + SelfHealthBarHeight;
        healthBar->topRight.x = barTopLeftX + SelfHealthBarWidth;
        healthBar->topRight.y = barTopLeftY;
        healthBar->bottomRight.x = barTopLeftX + SelfHealthBarWidth;
        healthBar->bottomRight.y = barTopLeftY + SelfHealthBarHeight;
        healthBar->detectedLeftSide = true;
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &bottomBarRightSideImageData, SelfHealthBarMaxPercent) >=  SelfHealthBarMaxPercent) {
        int barTopLeftX = x - SelfHealthBarWidth;
        int barTopLeftY = y + 3;
        healthBar = new SelfHealth();
        healthBar->topLeft.x = barTopLeftX;
        healthBar->topLeft.y = barTopLeftY;
        healthBar->bottomLeft.x = barTopLeftX;
        healthBar->bottomLeft.y = barTopLeftY + SelfHealthBarHeight;
        healthBar->topRight.x = barTopLeftX + SelfHealthBarWidth;
        healthBar->topRight.y = barTopLeftY;
        healthBar->bottomRight.x = barTopLeftX + SelfHealthBarWidth;
        healthBar->bottomRight.y = barTopLeftY + SelfHealthBarHeight;
        healthBar->detectedRightSide = true;
    }
    
    return healthBar;
}

//To Validate, at least 2 corners need detected then we detect the health percentage
void SelfChampionManager::validateChampionBars(ImageData* imageData, std::vector<Champion*>* detectedChampionBars) {
    //Remove duplicates
    for (int i = 0; i < detectedChampionBars->size(); i++) {
        Champion* champ = (*detectedChampionBars)[i];
        int detectedCorners = 1;
        for (int j = 0; j < detectedChampionBars->size(); j++) {
            if (j != i) {
                Champion* champ2 = (*detectedChampionBars)[j];
                if (champ2->topLeft.x == champ->topLeft.x && champ->topLeft.y == champ2-> topLeft.y) {
                    detectedChampionBars->erase(detectedChampionBars->begin() + j);
                    j--;
                    if (champ2->detectedBottomLeft) champ->detectedBottomLeft = true;
                    if (champ2->detectedBottomRight) champ->detectedBottomRight = true;
                    if (champ2->detectedTopLeft) champ->detectedTopLeft = true;
                    if (champ2->detectedTopRight) champ->detectedTopRight = true;
                    if (champ2->lowestPercentageMatch < champ->lowestPercentageMatch) champ->lowestPercentageMatch = champ2->lowestPercentageMatch;

                    detectedCorners++;
                }
            }
        }
        if (detectedCorners < 2) {
            detectedChampionBars->erase(detectedChampionBars->begin() + i);
            i--;
        }
        champ->characterCenter.x = champ->topLeft.x+66; champ->characterCenter.y = champ->topLeft.y+104;
    }
    
    //Detect health
    for (int i = 0; i < detectedChampionBars->size(); i++) {
        Champion* champ = (*detectedChampionBars)[i];
        champ->health = 0;
        for (int x = 103; x >= 0; x--) {
            if (x + champ->topLeft.x >= 0 && x + champ->topLeft.x < imageData->imageWidth &&
                champ->topLeft.y >= 0 && champ->topLeft.y < imageData->imageHeight) {
                if ( getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, champ->topLeft.x + x, champ->topLeft.y), champ->topLeft.x + x, champ->topLeft.y, imageData->imageWidth, imageData->imageHeight, &healthSegmentImageData, 0.9) >=  0.9) {
                    champ->health = (float)x / 103.0 * 100;
                    break;
                }
            }
        }
        
        
        if (champ->health == 0) {
            detectedChampionBars->erase(detectedChampionBars->begin() + i);
            i--;
        }
    }
}

//To Validate, at least 2 sides need detected then we detect the health percentage
void SelfChampionManager::validateSelfHealthBars(ImageData* imageData, std::vector<SelfHealth*>* detectedHealthBars) {

    //Remove duplicates
    for (int i = 0; i < detectedHealthBars->size(); i++) {
        SelfHealth* healthBar = (*detectedHealthBars)[i];
        int detectedCorners = 1;
        for (int j = 0; j < detectedHealthBars->size(); j++) {
            if (j != i) {
                SelfHealth* healthBar2 = (*detectedHealthBars)[j];
                if (healthBar2->topLeft.x == healthBar->topLeft.x && healthBar->topLeft.y == healthBar2-> topLeft.y) {
                    detectedHealthBars->erase(detectedHealthBars->begin() + j);
                    j--;
                    if (healthBar2->detectedLeftSide) healthBar->detectedLeftSide = true;
                    if (healthBar2->detectedRightSide) healthBar->detectedRightSide = true;

                    detectedCorners++;
                }
            }
        }
        if (detectedCorners < 2) {
            detectedHealthBars->erase(detectedHealthBars->begin() + i);
            i--;
        }
        healthBar->characterCenter.x = healthBar->topLeft.x+66; healthBar->characterCenter.y = healthBar->topLeft.y+104;
    }
    
    //Detect health
    for (int i = 0; i < detectedHealthBars->size(); i++) {
        SelfHealth* healthBar = (*detectedHealthBars)[i];
        healthBar->health = 0;
        uint8_t* healthColorPixel = getPixel2(&bottomBarAverageHealthColorImageData, 0, 0);
        for (int x = healthBar->topLeft.x + SelfHealthBarWidth - 1; x >= healthBar->topLeft.x; x--) {
            for (int y = healthBar->topRight.y; y < healthBar->bottomRight.y; y++) {
                if (x >= 0 && x < imageData->imageWidth &&
                    y >= 0 && y < imageData->imageHeight) {
                    if (getColorPercentage(healthColorPixel, getPixel2(imageData, x, y)) >= 0.55) {
                        healthBar->health = (float)(x - healthBar->topLeft.x) / (SelfHealthBarWidth - 1.0) * 100.0;
                        y = healthBar->bottomRight.y+1;
                        x = healthBar->topLeft.x - 1;
                    }
                }
            }
        }
    }
}