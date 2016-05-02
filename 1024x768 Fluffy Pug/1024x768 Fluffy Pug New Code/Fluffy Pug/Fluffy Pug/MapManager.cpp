//
//  MapManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/12/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#include "MapManager.h"

//
//  MapManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//
ImageData MapManager::shopIconImageData = loadImage("Resources/Map/Shop Icon.png");
ImageData MapManager::mapTopLeftCornerImageData = loadImage("Resources/Map/Map Top Left Corner.png");

MapManager::MapManager() {}

GenericObject* MapManager::detectMap(ImageData* imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = NULL;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &mapTopLeftCornerImageData, 0.7) >=  0.7) {
        object = new GenericObject();
        object->topLeft.x = x;
        object->topLeft.y = y;
        object->bottomLeft.x = x;
        object->bottomLeft.y = y + imageData->imageHeight - y;
        object->topRight.x = x + imageData->imageWidth - x;
        object->topRight.y = y;
        object->bottomRight.x = x + imageData->imageWidth - x;
        object->bottomRight.y = y + imageData->imageHeight - y;
        object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
        object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
    }
    
    return object;
}
GenericObject* MapManager::detectShop(ImageData* imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = NULL;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &shopIconImageData, 0.0) >=  0.7) {
        object = new GenericObject();
        object->topLeft.x = x;
        object->topLeft.y = y;
        object->bottomLeft.x = x;
        object->bottomLeft.y = y + shopIconImageData.imageHeight;
        object->topRight.x = x + shopIconImageData.imageWidth;
        object->topRight.y = y;
        object->bottomRight.x = x + shopIconImageData.imageWidth;
        object->bottomRight.y = y + shopIconImageData.imageHeight;
        object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
        object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
    }
    
    return object;
}
Position getHorizontalWhiteBar(ImageData* imageData, int x, int y) {
    int endX = x;
    int startX = x;
    for (int x2 = x+1; x2 < imageData->imageWidth; x2++) {
        if (isColor3(getPixel2(imageData, x2, y), 255, 255, 255)) {
            endX = x2;
        } else {
            break;
        }
    }
    for (int x2 = x-1; x2 > 0; x2--) {
        if (isColor3(getPixel2(imageData, x2, y), 255, 255, 255)) {
            startX = x2;
        } else {
            break;
        }
    }
    return makePosition(startX, endX);
}
Position getVerticalWhiteBar(ImageData* imageData, int x, int y) {
    int endY = y;
    int startY = y;
    for (int y2 = y+1; y2 < imageData->imageHeight; y2++) {
        if (isColor3(getPixel2(imageData, x, y2), 255, 255, 255)) {
            endY = y2;
        } else {
            break;
        }
    }
    for (int y2 = y-1; y2 > 0; y2--) {
        if (isColor3(getPixel2(imageData, x, y2), 255, 255, 255)) {
            startY = y2;
        } else {
            break;
        }
    }
    return makePosition(startY, endY);
}
int getSizeOfBar(Position bar) {
    return bar.y - bar.x;
}
GenericObject* MapManager::detectLocation(ImageData* imageData, uint8_t *pixel, int x, int y) {
    
    
    
    //Instead of looking for the corners as images which is expensive, we can
    //look for the white pixel. If we find a white pixel, find out if the white extends
    //horizontally or vertically for 3 or more pixels. Then when we come to the end we
    //have one of the side lengths. Then search for the other bar on either side of the first
    //bar and get it's length. Now you have it. This should be way cheaper than looking for
    //4 images each time. Cause we're only searching for a single color. Quite a bit of code though.
    GenericObject* object = NULL;
    if (isColor3(pixel, 255, 255, 255)) {
        Position horzBar = getHorizontalWhiteBar(imageData, x, y);
        Position vertBar = getVerticalWhiteBar(imageData, x, y);
        if (getSizeOfBar(horzBar) > getSizeOfBar(vertBar)) {
            //We have a horizontal bar
            //Search for vertical bar
            Position topLeftVertBar = getVerticalWhiteBar(imageData, horzBar.x, y - 1);
            Position chosenVertBar = topLeftVertBar;
            Position bottomLeftVertBar = getVerticalWhiteBar(imageData, horzBar.x, y + 1);
            if (getSizeOfBar(bottomLeftVertBar) > getSizeOfBar(chosenVertBar)) chosenVertBar = bottomLeftVertBar;
            Position topRightVertBar = getVerticalWhiteBar(imageData, horzBar.y, y - 1);
            if (getSizeOfBar(topRightVertBar) > getSizeOfBar(chosenVertBar)) chosenVertBar = topRightVertBar;
            Position bottomRightVertBar = getVerticalWhiteBar(imageData, horzBar.y, y + 1);
            if (getSizeOfBar(bottomRightVertBar) > getSizeOfBar(chosenVertBar)) chosenVertBar = bottomRightVertBar;
            
            if (getSizeOfBar(chosenVertBar) > 5 && getSizeOfBar(horzBar) > 5) {
                object = new GenericObject();
                int topLeftX = horzBar.x;
                int topLeftY = chosenVertBar.x;
                int width = getSizeOfBar(horzBar);
                int height = getSizeOfBar(chosenVertBar);
                object->topLeft.x = topLeftX;
                object->topLeft.y = topLeftY;
                object->bottomLeft.x = topLeftX;
                object->bottomLeft.y = object->topLeft.y + height;
                object->topRight.x =  object->topLeft.x + width;
                object->topRight.y = topLeftY;
                object->bottomRight.x = object->topRight.x;
                object->bottomRight.y = object->bottomLeft.y;
                object->center.x = ((object->topRight.x - object->topLeft.x) / 2.0 + object->topLeft.x);
                object->center.y = ((object->bottomLeft.y - object->topLeft.y) / 2.0 + object->topLeft.y);
            }
        } else {
            //We have a vertical bar
            //Search for horizontal bar
            Position topLeftHorzBar = getHorizontalWhiteBar(imageData, x - 1, vertBar.x);
            Position chosenHorzBar = topLeftHorzBar;
            
            Position bottomLeftHorzBar = getHorizontalWhiteBar(imageData, x + 1, vertBar.x);
            if (getSizeOfBar(bottomLeftHorzBar) > getSizeOfBar(chosenHorzBar)) chosenHorzBar = bottomLeftHorzBar;
            Position topRightHorzBar = getHorizontalWhiteBar(imageData, x - 1, vertBar.y);
            if (getSizeOfBar(topRightHorzBar) > getSizeOfBar(chosenHorzBar)) chosenHorzBar = topRightHorzBar;
            Position bottomRightHorzBar = getHorizontalWhiteBar(imageData, x + 1, vertBar.y);
            if (getSizeOfBar(bottomRightHorzBar) > getSizeOfBar(chosenHorzBar)) chosenHorzBar = bottomRightHorzBar;
            
            if (getSizeOfBar(chosenHorzBar) > 5 && getSizeOfBar(horzBar) > 5) {
                object = new GenericObject();
                int topLeftX = chosenHorzBar.x;
                int topLeftY = vertBar.x;
                int width = getSizeOfBar(chosenHorzBar);
                int height = getSizeOfBar(vertBar);
                object->topLeft.x = topLeftX;
                object->topLeft.y = topLeftY;
                object->bottomLeft.x = topLeftX;
                object->bottomLeft.y = object->topLeft.y + height;
                object->topRight.x =  object->topLeft.x + width;
                object->topRight.y = topLeftY;
                object->bottomRight.x = object->topRight.x;
                object->bottomRight.y = object->bottomLeft.y;
                object->center.x = ((object->topRight.x - object->topLeft.x) / 2.0 + object->topLeft.x);
                object->center.y = ((object->bottomLeft.y - object->topLeft.y) / 2.0 + object->topLeft.y);
            }
        }
    }
    return object;
}