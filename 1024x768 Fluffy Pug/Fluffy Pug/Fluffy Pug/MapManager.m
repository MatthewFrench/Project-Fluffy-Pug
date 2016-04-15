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
/*
ImageData MapManager::locationTopLeftCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Map/Location Top Left Corner" ofType:@"png"]);
ImageData MapManager::locationBottomLeftCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Map/Location Bottom Left Corner" ofType:@"png"]);
ImageData MapManager::locationTopRightCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Map/Location Top Right Corner" ofType:@"png"]);
ImageData MapManager::locationBottomRightCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Map/Location Bottom Right Corner" ofType:@"png"]);
*/
MapManager::MapManager() {}

GenericObject* MapManager::detectMap(ImageData imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = nil;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, mapTopLeftCornerImageData, 0.7) >=  0.7) {
        object = [GenericObject new];
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
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopIconImageData, 0.0) >=  0.7) {
        object = [GenericObject new];
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
CGPoint getHorizontalWhiteBar(ImageData imageData, int x, int y) {
    int endX = x;
    int startX = x;
    for (int x2 = x+1; x2 < imageData.imageWidth; x2++) {
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
    return CGPointMake(startX, endX);
}
CGPoint getVerticalWhiteBar(ImageData imageData, int x, int y) {
    int endY = y;
    int startY = y;
    for (int y2 = y+1; y2 < imageData.imageHeight; y2++) {
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
    return CGPointMake(startY, endY);
}
int getSizeOfBar(CGPoint bar) {
    return bar.y - bar.x;
}
GenericObject* MapManager::detectLocation(ImageData imageData, uint8_t *pixel, int x, int y) {
    
    
    
    //Instead of looking for the corners as images which is expensive, we can
    //look for the white pixel. If we find a white pixel, find out if the white extends
    //horizontally or vertically for 3 or more pixels. Then when we come to the end we
    //have one of the side lengths. Then search for the other bar on either side of the first
    //bar and get it's length. Now you have it. This should be way cheaper than looking for
    //4 images each time. Cause we're only searching for a single color. Quite a bit of code though.
    GenericObject* object = nil;
    if (isColor3(pixel, 255, 255, 255)) {
        CGPoint horzBar = getHorizontalWhiteBar(imageData, x, y);
        CGPoint vertBar = getVerticalWhiteBar(imageData, x, y);
        if (getSizeOfBar(horzBar) > getSizeOfBar(vertBar)) {
            //We have a horizontal bar
            //Search for vertical bar
            CGPoint topLeftVertBar = getVerticalWhiteBar(imageData, horzBar.x, y - 1);
            CGPoint chosenVertBar = topLeftVertBar;
            CGPoint bottomLeftVertBar = getVerticalWhiteBar(imageData, horzBar.x, y + 1);
            if (getSizeOfBar(bottomLeftVertBar) > getSizeOfBar(chosenVertBar)) chosenVertBar = bottomLeftVertBar;
            CGPoint topRightVertBar = getVerticalWhiteBar(imageData, horzBar.y, y - 1);
            if (getSizeOfBar(topRightVertBar) > getSizeOfBar(chosenVertBar)) chosenVertBar = topRightVertBar;
            CGPoint bottomRightVertBar = getVerticalWhiteBar(imageData, horzBar.y, y + 1);
            if (getSizeOfBar(bottomRightVertBar) > getSizeOfBar(chosenVertBar)) chosenVertBar = bottomRightVertBar;
            
            if (getSizeOfBar(chosenVertBar) > 5 && getSizeOfBar(horzBar) > 5) {
                object = [GenericObject new];
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
            CGPoint topLeftHorzBar = getHorizontalWhiteBar(imageData, x - 1, vertBar.x);
            CGPoint chosenHorzBar = topLeftHorzBar;
            
            CGPoint bottomLeftHorzBar = getHorizontalWhiteBar(imageData, x + 1, vertBar.x);
            if (getSizeOfBar(bottomLeftHorzBar) > getSizeOfBar(chosenHorzBar)) chosenHorzBar = bottomLeftHorzBar;
            CGPoint topRightHorzBar = getHorizontalWhiteBar(imageData, x - 1, vertBar.y);
            if (getSizeOfBar(topRightHorzBar) > getSizeOfBar(chosenHorzBar)) chosenHorzBar = topRightHorzBar;
            CGPoint bottomRightHorzBar = getHorizontalWhiteBar(imageData, x + 1, vertBar.y);
            if (getSizeOfBar(bottomRightHorzBar) > getSizeOfBar(chosenHorzBar)) chosenHorzBar = bottomRightHorzBar;
            
            if (getSizeOfBar(chosenHorzBar) > 5 && getSizeOfBar(horzBar) > 5) {
                object = [GenericObject new];
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
    
    
    
    
    
    
    //We're going to be very lenient here.
    //If we see any corner, we try our best to get the width and height of the location and return it
    //We'll assume the manager will only use one of the locations we return.
    //GenericObject* object = nil;
    
    //Look for top left corner
    /*
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, locationTopLeftCornerImageData, 1.0) >=  1.0) {
        int width = 0;
        for (int x2 = x + 2; x2 < imageData.imageWidth; x2++) {
            if (!isColor3(getPixel2(imageData, x2, y), 255, 255, 255)) {
                width = x2 - x + 1;
                break;
            }
        }
        int height = 0;
        for (int y2 = y + 2; y2 < imageData.imageHeight; y2++) {
            if (!isColor3(getPixel2(imageData, x, y2), 255, 255, 255)) {
                height = y2 - y + 1;
                break;
            }
        }
        int topLeftX = x;
        int topLeftY = y;
        object = [GenericObject new];
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
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, locationBottomLeftCornerImageData, 1.0) >=  1.0) {
        //Look for bottom left corner
        int width = 0;
        for (int x2 = x + 2; x2 < imageData.imageWidth; x2++) {
            if (!isColor3(getPixel2(imageData, x2, y), 255, 255, 255)) {
                width = x2 - x + 1;
                break;
            }
        }
        int height = 0;
        for (int y2 = y + locationBottomLeftCornerImageData.imageHeight - 2; y2 > y - 200; y2--) {
            if (!isColor3(getPixel2(imageData, x, y2), 255, 255, 255)) {
                height = y - y2 + 1;
                break;
            }
        }
        int topLeftX = x;
        int topLeftY = y - height;
        object = [GenericObject new];
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
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, locationTopRightCornerImageData, 1.0) >=  1.0) {
        int width = 0;
        for (int x2 = x + locationTopRightCornerImageData.imageWidth - 2; x2 > x - 200; x2--) {
            if (!isColor3(getPixel2(imageData, x2, y), 255, 255, 255)) {
                width = x - x2 + 1;
                break;
            }
        }
        int height = 0;
        for (int y2 = y + 2; y2 < imageData.imageHeight; y2++) {
            if (!isColor3(getPixel2(imageData, x, y2), 255, 255, 255)) {
                height = y2 - y + 1;
                break;
            }
        }
        int topLeftX = x - width;
        int topLeftY = y;
        object = [GenericObject new];
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
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, locationBottomRightCornerImageData, 1.0) >=  1.0) {
        int width = 0;
        for (int x2 = x + locationTopRightCornerImageData.imageWidth - 2; x2 > x - 200; x2--) {
            if (!isColor3(getPixel2(imageData, x2, y), 255, 255, 255)) {
                width = x - x2 + 1;
                break;
            }
        }
        int height = 0;
        for (int y2 = y + locationBottomLeftCornerImageData.imageHeight - 2; y2 > y - 200; y2--) {
            if (!isColor3(getPixel2(imageData, x, y2), 255, 255, 255)) {
                height = y - y2 + 1;
                break;
            }
        }
        int topLeftX = x - width;
        int topLeftY = y - height;
        object = [GenericObject new];
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
    }*/
    
    return object;
}
/*
 
 GenericObject* MapManager::detectShopAvailable(ImageData imageData, uint8_t *pixel, int x, int y) {
 GenericObject* object = nil;
 if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopAvailableImageData, 0.8) >=  0.8) {
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
 GenericObject* MapManager::detectShopTopLeftCorner(ImageData imageData, uint8_t *pixel, int x, int y) {
 GenericObject* object = nil;
 if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopTopLeftCornerImageData, 0.8) >=  0.8) {
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
 GenericObject* MapManager::detectShopBottomLeftCorner(ImageData imageData, uint8_t *pixel, int x, int y) {
 GenericObject* object = nil;
 if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopBottomLeftCornerImageData, 0.8) >=  0.8) {
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
 }*/