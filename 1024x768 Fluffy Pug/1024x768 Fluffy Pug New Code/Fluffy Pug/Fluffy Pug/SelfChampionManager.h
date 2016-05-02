//
//  AllyMinionManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#include "Utility.h"
#include <time.h>
#include <vector>

class SelfChampionManager {
public:
    
    static ImageData topLeftImageData, bottomLeftImageData,
    bottomRightImageData, topRightImageData, healthSegmentImageData, bottomBarLeftSideImageData, bottomBarRightSideImageData,
    bottomBarAverageHealthColorImageData;
    
    SelfChampionManager();
    static void validateChampionBars(ImageData* imageData, std::vector<Champion*>* detectedChampionBars);
    static SelfHealth* detectSelfHealthBarAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y);
    static void validateSelfHealthBars(ImageData* imageData, std::vector<SelfHealth*>* detectedHealthBars);

    static constexpr float coloredPixelPrecision = 0.9; //0.8
    static constexpr float overalImagePrecision = 0.9; //0.8
    inline static Champion* detectChampionBarAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y) {
    float percentage;
    if ((percentage = getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &topLeftImageData, coloredPixelPrecision) >=  overalImagePrecision)) {
        int barTopLeftX = x + 3;
        int barTopLeftY = y + 3;
        Champion* champ = new Champion();
        champ->topLeft.x = barTopLeftX;
        champ->topLeft.y = barTopLeftY;
        champ->bottomLeft.x = barTopLeftX;
        champ->bottomLeft.y = barTopLeftY + 9;
        champ->topRight.x = barTopLeftX + 104;
        champ->topRight.y = barTopLeftY;
        champ->bottomRight.x = barTopLeftX + 104;
        champ->bottomRight.y = barTopLeftY + 9;
        champ->detectedTopLeft = true;
            champ->lowestPercentageMatch = percentage;
        return champ;
    } else if ((percentage = getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &bottomLeftImageData, coloredPixelPrecision) >=  overalImagePrecision)) { // Look for bottom left corner
        int barTopLeftX = x + 3;
        int barTopLeftY = y - 8;
        Champion* champ = new Champion();
        champ->topLeft.x = barTopLeftX;
        champ->topLeft.y = barTopLeftY;
        champ->bottomLeft.x = barTopLeftX;
        champ->bottomLeft.y = barTopLeftY + 9;
        champ->topRight.x = barTopLeftX + 104;
        champ->topRight.y = barTopLeftY;
        champ->bottomRight.x = barTopLeftX + 104;
        champ->bottomRight.y = barTopLeftY + 9;
        champ->detectedBottomLeft = true;
            champ->lowestPercentageMatch = percentage;
        return champ;
    } else if ((percentage = getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &topRightImageData, coloredPixelPrecision) >=  overalImagePrecision)) { // Look for top right corner
        int barTopLeftX = x - 101 - 2;
        int barTopLeftY = y + 3;
        Champion* champ = new Champion();
        champ->topLeft.x = barTopLeftX;
        champ->topLeft.y = barTopLeftY;
        champ->bottomLeft.x = barTopLeftX;
        champ->bottomLeft.y = barTopLeftY + 9;
        champ->topRight.x = barTopLeftX + 104;
        champ->topRight.y = barTopLeftY;
        champ->bottomRight.x = barTopLeftX + 104;
        champ->bottomRight.y = barTopLeftY + 9;
        champ->detectedTopRight = true;
            champ->lowestPercentageMatch = percentage;
        return champ;
    } else if ((percentage = getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &bottomRightImageData, coloredPixelPrecision) >=  overalImagePrecision)) { // Look for bottom right corner
        int barTopLeftX = x - 101 - 2;
        int barTopLeftY = y - 8;
        Champion* champ = new Champion();
        champ->topLeft.x = barTopLeftX;
        champ->topLeft.y = barTopLeftY;
        champ->bottomLeft.x = barTopLeftX;
        champ->bottomLeft.y = barTopLeftY + 9;
        champ->topRight.x = barTopLeftX + 104;
        champ->topRight.y = barTopLeftY;
        champ->bottomRight.x = barTopLeftX + 104;
        champ->bottomRight.y = barTopLeftY + 9;
        champ->detectedBottomRight = true;
            champ->lowestPercentageMatch = percentage;
        return champ;
    }
    return NULL;
}
};