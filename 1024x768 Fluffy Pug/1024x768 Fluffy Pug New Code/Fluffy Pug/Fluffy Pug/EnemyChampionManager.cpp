//
//  EnemyChampionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#include "EnemyChampionManager.h"

//static int Debug_Draw_Red = 255, Debug_Draw_Green = 0, Debug_Draw_Blue = 255;
//static int Health_Bar_Width = 104, Health_Bar_Height = 9;
ImageData EnemyChampionManager::topLeftImageData = loadImage("Resources/Enemy Champion Health Bar/Top Left Corner.png");

ImageData EnemyChampionManager::bottomLeftImageData = loadImage("Resources/Enemy Champion Health Bar/Bottom Left Corner.png");
ImageData EnemyChampionManager::bottomRightImageData = loadImage("Resources/Enemy Champion Health Bar/Bottom Right Corner.png");
ImageData EnemyChampionManager::topRightImageData = loadImage("Resources/Enemy Champion Health Bar/Top Right Corner.png");
ImageData EnemyChampionManager::healthSegmentImageData = loadImage("Resources/Enemy Champion Health Bar/Health Segment.png");

EnemyChampionManager::EnemyChampionManager () {}

//To Validate, at least 2 corners need detected then we detect the health percentage
void EnemyChampionManager::validateChampionBars(ImageData* imageData, std::vector<Champion*>* detectedChampionBars) {
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
            for (int y = 0; y < healthSegmentImageData.imageHeight; y++) {
                if (x + champ->topLeft.x >= 0 && x + champ->topLeft.x < imageData->imageWidth &&
                    y + champ->topLeft.y >= 0 && y + champ->topLeft.y < imageData->imageHeight) {
                uint8_t* healthBarColor = getPixel2(&healthSegmentImageData, 0, y);
                uint8_t*  p = getPixel2(imageData, x + champ->topLeft.x, y + champ->topLeft.y);
                if (getColorPercentage(healthBarColor, p) >= 0.95) {
                    champ->health = (float)x / 103 * 100;
                    y = healthSegmentImageData.imageHeight + 1;
                    x = -1;
                }
                }
            }
        }
    }
}