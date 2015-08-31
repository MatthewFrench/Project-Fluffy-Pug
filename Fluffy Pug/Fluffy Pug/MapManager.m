//
//  MapManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/12/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "MapManager.h"

//
//  MapManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//
ImageData MapManager::shopIconImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Map/Shop Icon" ofType:@"png"]);
ImageData MapManager::mapTopLeftCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Map/Map Top Left Corner" ofType:@"png"]);
ImageData MapManager::locationTopLeftCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Map/Location Top Left Corner" ofType:@"png"]);
ImageData MapManager::locationBottomLeftCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Map/Location Bottom Left Corner" ofType:@"png"]);
ImageData MapManager::locationTopRightCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Map/Location Top Right Corner" ofType:@"png"]);
ImageData MapManager::locationBottomRightCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Map/Location Bottom Right Corner" ofType:@"png"]);

MapManager::MapManager() {}

GenericObject* MapManager::detectMap(ImageData imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = nil;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, mapTopLeftCornerImageData, 0.8) >=  0.8) {
        object = new GenericObject();
        object->topLeft.x = x;
        object->topLeft.y = y;
        object->bottomLeft.x = x;
        object->bottomLeft.y = y + imageData.imageHeight - y;
        object->topRight.x = x + imageData.imageWidth - x;
        object->topRight.y = y;
        object->bottomRight.x = x + imageData.imageWidth - x;
        object->bottomRight.y = y + imageData.imageHeight - y;
        object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
        object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
    }
    
    return object;
}
GenericObject* MapManager::detectShop(ImageData imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = nil;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopIconImageData, 0.0) >=  0.8) {
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
GenericObject* MapManager::detectLocation(ImageData imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = nil;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, locationTopLeftCornerImageData, 1.0) >=  1.0) {
        bool foundTopRightCorner = false;
        Position topRightCornerPos;
        for (int x2 = x+1; x2 < imageData.imageWidth - locationTopRightCornerImageData.imageWidth; x2++) {
            if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, x2, y), x2, y, imageData.imageWidth, imageData.imageHeight, locationTopRightCornerImageData, 1.0) >=  1.0) {
                foundTopRightCorner = true;
                topRightCornerPos.x = x2;
                topRightCornerPos.y = y;
                x2 = imageData.imageWidth;
            }
        }
        
        if (!foundTopRightCorner) return nil;
        
        bool foundBottomLeftCorner = false;
        Position bottomLeftCornerPos;
        for (int y2 = y+1; y2 < imageData.imageHeight - locationBottomLeftCornerImageData.imageHeight; y2++) {
            if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, x, y2), x, y2, imageData.imageWidth, imageData.imageHeight, locationBottomLeftCornerImageData, 1.0) >=  1.0) {
                foundBottomLeftCorner = true;
                bottomLeftCornerPos.x = x;
                bottomLeftCornerPos.y = y2;
                y2 = imageData.imageHeight;
            }
        }
        if (!foundBottomLeftCorner) return nil;
        
        bool foundBottomRightCorner = false;
        Position bottomRightCornerPos;
        for (int x2 = x+1; x2 < imageData.imageWidth - locationBottomRightCornerImageData.imageWidth; x2++) {
            for (int y2 = y+1; y2 < imageData.imageHeight - locationBottomRightCornerImageData.imageHeight; y2++) {
                if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, x2, y2), x2, y2, imageData.imageWidth, imageData.imageHeight, locationBottomRightCornerImageData, 1.0) >=  1.0) {
                    foundBottomRightCorner = true;
                    bottomRightCornerPos.x = x2;
                    bottomRightCornerPos.y = y2;
                    x2 = imageData.imageWidth;
                    y2 = imageData.imageHeight;
                }
            }
        }
        if (!foundBottomRightCorner) return nil;
        
        object = new GenericObject();
        object->topLeft.x = x;
        object->topLeft.y = y;
        object->bottomLeft.x = x;
        object->bottomLeft.y = bottomLeftCornerPos.y + locationBottomLeftCornerImageData.imageHeight;
        object->topRight.x = topRightCornerPos.x + locationTopRightCornerImageData.imageWidth;
        object->topRight.y = y;
        object->bottomRight.x = bottomRightCornerPos.x + locationBottomRightCornerImageData.imageWidth;
        object->bottomRight.y = bottomRightCornerPos.y + locationBottomRightCornerImageData.imageHeight;
        object->center.x = ((object->topRight.x - object->topLeft.x) / 2.0 + object->topLeft.x);
        object->center.y = ((object->bottomLeft.y - object->topLeft.y) / 2.0 + object->topLeft.y);
    }
    
    return object;
}
/*
 
 GenericObject* MapManager::detectShopAvailable(ImageData imageData, uint8_t *pixel, int x, int y) {
 GenericObject* object = nil;
 if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopAvailableImageData, 0.8) >=  0.8) {
 object = new GenericObject();
 object->topLeft.x = x;
 object->topLeft.y = y;
 object->bottomLeft.x = x;
 object->bottomLeft.y = y + shopAvailableImageData.imageHeight;
 object->topRight.x = x + shopAvailableImageData.imageWidth;
 object->topRight.y = y;
 object->bottomRight.x = x + shopAvailableImageData.imageWidth;
 object->bottomRight.y = y + shopAvailableImageData.imageHeight;
 object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
 object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
 }
 
 return object;
 }
 GenericObject* MapManager::detectShopTopLeftCorner(ImageData imageData, uint8_t *pixel, int x, int y) {
 GenericObject* object = nil;
 if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopTopLeftCornerImageData, 0.8) >=  0.8) {
 object = new GenericObject();
 object->topLeft.x = x;
 object->topLeft.y = y;
 object->bottomLeft.x = x;
 object->bottomLeft.y = y + shopTopLeftCornerImageData.imageHeight;
 object->topRight.x = x + shopTopLeftCornerImageData.imageWidth;
 object->topRight.y = y;
 object->bottomRight.x = x + shopTopLeftCornerImageData.imageWidth;
 object->bottomRight.y = y + shopTopLeftCornerImageData.imageHeight;
 object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
 object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
 }
 
 return object;
 }
 GenericObject* MapManager::detectShopBottomLeftCorner(ImageData imageData, uint8_t *pixel, int x, int y) {
 GenericObject* object = nil;
 if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopBottomLeftCornerImageData, 0.8) >=  0.8) {
 object = new GenericObject();
 object->topLeft.x = x;
 object->topLeft.y = y;
 object->bottomLeft.x = x;
 object->bottomLeft.y = y + shopBottomLeftCornerImageData.imageHeight;
 object->topRight.x = x + shopBottomLeftCornerImageData.imageWidth;
 object->topRight.y = y;
 object->bottomRight.x = x + shopBottomLeftCornerImageData.imageWidth;
 object->bottomRight.y = y + shopBottomLeftCornerImageData.imageHeight;
 object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
 object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
 }
 
 return object;
 }
 GenericObject* MapManager::detectBuyableItems(ImageData imageData, uint8_t *pixel, int x, int y) {
 float precision = 0.85;
 GenericObject* object = nil;
 if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopBuyableItemTopLeftCornerImageData, precision) >=  precision) {
 bool topRightCorner = false;
 for (int i = 0; i <= 41 - shopBuyableItemTopRightCornerImageData.imageWidth; i++) {
 if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, x+i, y), x+i, y, imageData.imageWidth, imageData.imageHeight, shopBuyableItemTopRightCornerImageData, precision) >=  precision) {
 topRightCorner = true;
 break;
 }
 }
 if (topRightCorner == false) return nil;
 
 bool bottomLeftCorner = false;
 for (int i = 0; i <= 41 - shopBuyableItemBottomLeftCornerImageData.imageHeight; i++) {
 if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, x, y+i), x, y+i, imageData.imageWidth, imageData.imageHeight, shopBuyableItemBottomLeftCornerImageData, precision) >=  precision) {
 bottomLeftCorner = true;
 break;
 }
 }
 if (bottomLeftCorner == false) return nil;
 
 bool bottomRightCorner = false;
 for (int i = 0; i <= 41 - shopBuyableItemBottomRightCornerImageData.imageWidth; i++) {
 for (int i2 = 0; i2 <= 41 - shopBuyableItemBottomRightCornerImageData.imageHeight; i2++) {
 if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, x+i, y+i2), x+i, y+i2, imageData.imageWidth, imageData.imageHeight, shopBuyableItemBottomRightCornerImageData, precision) >=  precision) {
 bottomRightCorner = true;
 break;
 }
 }
 }
 if (bottomRightCorner == false) return nil;
 
 object = new GenericObject();
 object->topLeft.x = x;
 object->topLeft.y = y;
 object->bottomLeft.x = x;
 object->bottomLeft.y = y + 40;
 object->topRight.x = x + 40;
 object->topRight.y = y;
 object->bottomRight.x = x + 40;
 object->bottomRight.y = y + 40;
 object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
 object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
 }
 
 return object;
 }*/