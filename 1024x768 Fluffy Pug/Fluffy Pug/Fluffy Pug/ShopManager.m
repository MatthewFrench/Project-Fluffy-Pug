//
//  ShopManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/12/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "ShopManager.h"

//
//  ShopManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

ImageData ShopManager::shopBuyableItemTopLeftCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Buyable Item Top Left Corner" ofType:@"png"]);
ImageData ShopManager::shopBuyableItemBottomLeftCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Buyable Item Bottom Left Corner" ofType:@"png"]);
ImageData ShopManager::shopBuyableItemTopRightCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Buyable Item Top Right Corner" ofType:@"png"]);
ImageData ShopManager::shopBuyableItemBottomRightCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Buyable Item Bottom Right Corner" ofType:@"png"]);
ImageData ShopManager::shopTopLeftCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Shop Top Left Corner" ofType:@"png"]);
ImageData ShopManager::shopAvailableImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Shop Available" ofType:@"png"]);
ImageData ShopManager::shopBottomLeftCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Shop Bottom Left Corner" ofType:@"png"]);

ShopManager::ShopManager() {
    /*
    fullScreenUpdateTime = clock();
    shopItemImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Item" ofType:@"png"]);
    shopWindowImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Shop Window" ofType:@"png"]);
    shopEmptyItemSlotImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Empty Item Slot" ofType:@"png"]);
    shopAvailableImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Shop Available" ofType:@"png"]);
    shopBottomLeftCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Shop Bottom Left Corner" ofType:@"png"]);
    buyableItems = [NSMutableArray new];
    lastShopOpenAttempt = clock();
    lastShopCloseAttempt = clock();
    lastItemBuyTime = clock();
     */
}
GenericObject* ShopManager::detectShopAvailable(ImageData imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = nil;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopAvailableImageData, 0.5) >=  0.5) {
        object = [GenericObject new];
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
GenericObject* ShopManager::detectShopTopLeftCorner(ImageData imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = nil;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopTopLeftCornerImageData, 0.4) >=  0.8) {
        object = [GenericObject new];
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
GenericObject* ShopManager::detectShopBottomLeftCorner(ImageData imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = nil;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopBottomLeftCornerImageData, 0.5) >=  0.95) {
        object = [GenericObject new];
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
GenericObject* ShopManager::detectBuyableItems(ImageData imageData, uint8_t *pixel, int x, int y) {
    float precision = 0.85;
    GenericObject* object = nil;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopBuyableItemTopLeftCornerImageData, precision) >=  precision) {
        
        int cornerCount = 0;
        
        //Top left corner
        for (int i = 0; i <= 41 - shopBuyableItemTopLeftCornerImageData.imageWidth; i++) {
            if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, x, y+i), x, y+i, imageData.imageWidth, imageData.imageHeight, shopBuyableItemTopLeftCornerImageData, precision) >=  precision) {
                cornerCount++;
                break;
            }
        }
        
        //Top right corner
        for (int i = 0; i <= 41 - shopBuyableItemTopRightCornerImageData.imageWidth; i++) {
            if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, x+i, y), x+i, y, imageData.imageWidth, imageData.imageHeight, shopBuyableItemTopRightCornerImageData, precision) >=  precision) {
                cornerCount++;
                break;
            }
        }
        //if (topRightCorner == false) return nil;
        
        
        bool bottomLeftCorner = false;
        for (int i = 0; i <= 41 - shopBuyableItemBottomLeftCornerImageData.imageHeight; i++) {
            if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, x, y+i), x, y+i, imageData.imageWidth, imageData.imageHeight, shopBuyableItemBottomLeftCornerImageData, precision) >=  precision) {
                bottomLeftCorner = true;
                cornerCount++;
                break;
            }
        }
        //if (bottomLeftCorner == false) return nil;
        
        bool bottomRightCorner = false;
        for (int i = 0; i <= 41 - shopBuyableItemBottomRightCornerImageData.imageWidth; i++) {
            for (int i2 = 0; i2 <= 41 - shopBuyableItemBottomRightCornerImageData.imageHeight; i2++) {
                if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, x+i, y+i2), x+i, y+i2, imageData.imageWidth, imageData.imageHeight, shopBuyableItemBottomRightCornerImageData, precision) >=  precision) {
                    bottomRightCorner = true;
                    cornerCount++;
                    break;
                }
            }
        }
        //if (bottomRightCorner == false) return nil;
        if (cornerCount < 2) return nil;
        
        object = [GenericObject new];
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
}