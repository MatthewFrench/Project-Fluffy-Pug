//
//  AllyMinionManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#include "Utility.h"
#include <vector>

#ifndef EnemyMinionManager_H
#define EnemyMinionManager_H

class EnemyMinionManager {
public:

    static ImageData topLeftImageData, bottomLeftImageData,
    bottomRightImageData, topRightImageData, healthSegmentImageData;
    
    EnemyMinionManager();
    static void validateMinionBars(ImageData* imageData, std::vector<Minion*>* detectedChampionBars);


    static constexpr float coloredPixelPrecision = 0.96; //0.97
    static constexpr float overalImagePrecision = 0.96; //0.97
    inline static Minion* detectMinionBarAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y) {
        if (isColor3(pixel, 0, 0, 0)) {
            float percent;
        //Look top left corner
            if ((percent = getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &topLeftImageData, coloredPixelPrecision) >=  overalImagePrecision)) {
                int barTopLeftX = x + 1;
                int barTopLeftY = y + 1;
                Minion* minion = new Minion();
                minion->topLeft.x = barTopLeftX;
                minion->topLeft.y = barTopLeftY;
                minion->bottomLeft.x = barTopLeftX;
                minion->bottomLeft.y = barTopLeftY + 4;
                minion->topRight.x = barTopLeftX + 62;
                minion->topRight.y = barTopLeftY;
                minion->bottomRight.x = barTopLeftX + 62;
                minion->bottomRight.y = barTopLeftY + 4;
                minion->health = 0;
                minion->detectedTopLeft = true;
                minion->lowestPercentageMatch = percent;
                return minion;
        } else if ((percent = getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &bottomLeftImageData, coloredPixelPrecision) >=  overalImagePrecision)) { // Look for bottom left corner
            int barTopLeftX = x + 1;
            int barTopLeftY = y - 3;
            Minion* minion = new Minion();
            minion->topLeft.x = barTopLeftX;
            minion->topLeft.y = barTopLeftY;
            minion->bottomLeft.x = barTopLeftX;
            minion->bottomLeft.y = barTopLeftY + 4;
            minion->topRight.x = barTopLeftX + 62;
            minion->topRight.y = barTopLeftY;
            minion->bottomRight.x = barTopLeftX + 62;
            minion->bottomRight.y = barTopLeftY + 4;
            minion->detectedBottomLeft = true;
            minion->health = 0;
                minion->lowestPercentageMatch = percent;
            return minion;
        }
    }
    return NULL;
}
};

#endif