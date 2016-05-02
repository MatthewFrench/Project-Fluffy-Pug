//
//  ItemManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#include "SurrenderManager.h"

ImageData SurrenderManager::surrenderImageData = loadImage("Resources/Surrender/Surrender.png");

GenericObject* SurrenderManager::detectSurrenderAtPixel(ImageData* imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = NULL;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &surrenderImageData, 0.7) >=  0.7) {
        object = new GenericObject();
        object->topLeft.x = x;
        object->topLeft.y = y;
        object->bottomLeft.x = x;
        object->bottomLeft.y = y + surrenderImageData.imageHeight;
        object->topRight.x = x + surrenderImageData.imageWidth;
        object->topRight.y = y;
        object->bottomRight.x = x + surrenderImageData.imageWidth;
        object->bottomRight.y = y + surrenderImageData.imageHeight;
        object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
        object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
    }
    
    return object;
}