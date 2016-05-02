//
//  TurretManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 6/12/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#include "Utility.h"
#include <time.h>
#include <vector>

class EnemyTowerManager {
public:
    static ImageData topLeftImageData, bottomLeftImageData,
    bottomRightImageData, topRightImageData, healthSegmentImageData;
    EnemyTowerManager();
    static void validateTowerBars(ImageData* imageData, std::vector<Tower*>* detectedTowerBars);



static constexpr float coloredPixelPrecision = 0.9; //0.7
    static constexpr float overalImagePrecision = 0.9; //0.7
    inline static Tower* detectTowerBarAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y) {
        float percent;
        if ((percent = getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &topLeftImageData, coloredPixelPrecision) >=  overalImagePrecision)) {
            int barTopLeftX = x + 3;
            int barTopLeftY = y + 3;
            Tower* tower = new Tower();
            tower->topLeft.x = barTopLeftX;
            tower->topLeft.y = barTopLeftY;
            tower->bottomLeft.x = barTopLeftX;
            tower->bottomLeft.y = barTopLeftY + 8;
            tower->topRight.x = barTopLeftX + 126;
            tower->topRight.y = barTopLeftY;
            tower->bottomRight.x = barTopLeftX + 126;
            tower->bottomRight.y = barTopLeftY + 8;
            tower->detectedTopLeft = true;
            tower->lowestPercentageMatch = percent;
            return tower;
    } else if ((percent = getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &bottomLeftImageData, coloredPixelPrecision) >=  overalImagePrecision)) { // Look for bottom left corner
        int barTopLeftX = x + 3;
        int barTopLeftY = y - 7;
        Tower* tower = new Tower();
        tower->topLeft.x = barTopLeftX;
        tower->topLeft.y = barTopLeftY;
        tower->bottomLeft.x = barTopLeftX;
        tower->bottomLeft.y = barTopLeftY + 8;
        tower->topRight.x = barTopLeftX + 126;
        tower->topRight.y = barTopLeftY;
        tower->bottomRight.x = barTopLeftX + 126;
        tower->bottomRight.y = barTopLeftY + 8;
        tower->detectedBottomLeft = true;
            tower->lowestPercentageMatch = percent;
        return tower;
    } else if ((percent = getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &topRightImageData, coloredPixelPrecision) >=  overalImagePrecision)) { // Look for top right corner
        int barTopLeftX = x - 126 + 1;
        int barTopLeftY = y + 3;
        Tower* tower = new Tower();
        tower->topLeft.x = barTopLeftX;
        tower->topLeft.y = barTopLeftY;
        tower->bottomLeft.x = barTopLeftX;
        tower->bottomLeft.y = barTopLeftY + 8;
        tower->topRight.x = barTopLeftX + 126;
        tower->topRight.y = barTopLeftY;
        tower->bottomRight.x = barTopLeftX + 126;
        tower->bottomRight.y = barTopLeftY + 8;
        tower->detectedTopRight = true;
            tower->lowestPercentageMatch = percent;
        return tower;
    } else if ((percent = getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &bottomRightImageData, coloredPixelPrecision) >=  overalImagePrecision)) { // Look for bottom right corner
        int barTopLeftX = x - 126 + 1;
        int barTopLeftY = y - 7;
        Tower* tower = new Tower();
        tower->topLeft.x = barTopLeftX;
        tower->topLeft.y = barTopLeftY;
        tower->bottomLeft.x = barTopLeftX;
        tower->bottomLeft.y = barTopLeftY + 8;
        tower->topRight.x = barTopLeftX + 126;
        tower->topRight.y = barTopLeftY;
        tower->bottomRight.x = barTopLeftX + 126;
        tower->bottomRight.y = barTopLeftY + 8;
        tower->detectedBottomRight = true;
            tower->lowestPercentageMatch = percent;
        return tower;
    }
    return NULL;
}
};