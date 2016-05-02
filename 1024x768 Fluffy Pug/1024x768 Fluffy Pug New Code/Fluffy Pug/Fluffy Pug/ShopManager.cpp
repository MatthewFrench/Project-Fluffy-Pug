//
//  ShopManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/12/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#include "ShopManager.h"

//
//  ShopManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

ImageData ShopManager::shopBuyableItemTopLeftCornerImageData = loadImage("Resources/Shop/Buyable Item Top Left Corner.png");
ImageData ShopManager::shopBuyableItemBottomLeftCornerImageData = loadImage("Resources/Shop/Buyable Item Bottom Left Corner.png");
ImageData ShopManager::shopBuyableItemTopRightCornerImageData = loadImage("Resources/Shop/Buyable Item Top Right Corner.png");
ImageData ShopManager::shopBuyableItemBottomRightCornerImageData = loadImage("Resources/Shop/Buyable Item Bottom Right Corner.png");
ImageData ShopManager::shopTopLeftCornerImageData = loadImage("Resources/Shop/Shop Top Left Corner.png");
ImageData ShopManager::shopAvailableImageData = loadImage("Resources/Shop/Shop Available.png");
ImageData ShopManager::shopBottomLeftCornerImageData = loadImage("Resources/Shop/Shop Bottom Left Corner.png");

ShopManager::ShopManager() {}

GenericObject* ShopManager::detectShopAvailable(ImageData* imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = NULL;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &shopAvailableImageData, 0.5) >=  0.5) {
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
GenericObject* ShopManager::detectShopBottomLeftCorner(ImageData* imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = NULL;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &shopBottomLeftCornerImageData, 0.5) >=  0.95) {
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
        //NSLog(@"Detected bottom left corner");
    }
    
    return object;
}
const int ItemWidth = 38;
const int ItemHeight = 38;
const int SearchMargin = 10;
GenericObject* ShopManager::detectBuyableItems(ImageData* imageData, uint8_t *pixel, int x, int y) {
    float precision = 0.8;
    GenericObject* object = NULL;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData->imageWidth, imageData->imageHeight, &shopBuyableItemTopLeftCornerImageData, precision) >=  precision) {
        
        int cornerCount = 1;
        
        for (int i = ItemWidth - SearchMargin - shopBuyableItemTopRightCornerImageData.imageWidth; i <= ItemWidth+SearchMargin - shopBuyableItemTopRightCornerImageData.imageWidth; i++) {
            if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, x+i, y), x+i, y, imageData->imageWidth, imageData->imageHeight, &shopBuyableItemTopRightCornerImageData, precision) >=  precision) {
                cornerCount++;
                break;
            }
        }
        
        
        bool bottomLeftCorner = false;
        for (int i = ItemHeight - SearchMargin - shopBuyableItemBottomLeftCornerImageData.imageHeight; i <= ItemHeight + SearchMargin - shopBuyableItemBottomLeftCornerImageData.imageHeight; i++) {
            if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, x, y+i), x, y+i, imageData->imageWidth, imageData->imageHeight, &shopBuyableItemBottomLeftCornerImageData, precision) >=  precision) {
                bottomLeftCorner = true;
                cornerCount++;
                break;
            }
        }
        
        bool bottomRightCorner = false;
        for (int i = ItemWidth - SearchMargin - shopBuyableItemBottomRightCornerImageData.imageWidth; i <= ItemWidth + SearchMargin - shopBuyableItemBottomRightCornerImageData.imageWidth && !bottomRightCorner; i++) {
            for (int i2 = ItemHeight - SearchMargin - shopBuyableItemBottomRightCornerImageData.imageHeight; i2 <= ItemHeight + SearchMargin - shopBuyableItemBottomRightCornerImageData.imageHeight; i2++) {
                if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, x+i, y+i2), x+i, y+i2, imageData->imageWidth, imageData->imageHeight, &shopBuyableItemBottomRightCornerImageData, precision) >=  precision) {
                    bottomRightCorner = true;
                    cornerCount++;
                    break;
                }
            }
        }
        if (cornerCount < 2) return NULL;
         
        object = new GenericObject();
        object->topLeft.x = x;
        object->topLeft.y = y;
        object->bottomLeft.x = x;
        object->bottomLeft.y = y + ItemHeight;
        object->topRight.x = x + ItemWidth;
        object->topRight.y = y;
        object->bottomRight.x = x + ItemWidth;
        object->bottomRight.y = y + ItemHeight;
        object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
        object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
    }
    
    return object;
}