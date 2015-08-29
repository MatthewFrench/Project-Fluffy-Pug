//
//  ItemManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "ItemManager.h"

ImageData ItemManager::trinketItemImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Item Bar/Trinket Active" ofType:@"png"]);
ImageData ItemManager::itemImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Item Bar/Usable Item" ofType:@"png"]);
ImageData ItemManager::potionImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Item Bar/Potion" ofType:@"png"]);
ImageData ItemManager::usedPotionImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Item Bar/Used Potion" ofType:@"png"]);
ImageData ItemManager::usedPotionInnerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Item Bar/Used Potion Inner" ofType:@"png"]);

ItemManager::ItemManager() {
    /*
    item1Active = false;
    item2Active = false;
    item3Active = false;
    trinketActive = false;
    item5Active = false;
    item6Active = false;
    item7Active = false;
    
    item1Time = clock();
    item2Time = clock();
    item3Time = clock();
    trinketTime = clock();
    item5Time = clock();
    item6Time = clock();
    item7Time = clock();
    usedItemInFrame = false;
     */
}
GenericObject* ItemManager::detectTrinketActiveAtPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = nil;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, trinketItemImageData, 0.8) >=  0.8) {
        object = new GenericObject();
        object->topLeft.x = x;
        object->topLeft.y = y;
        object->bottomLeft.x = x;
        object->bottomLeft.y = y + trinketItemImageData.imageHeight;
        object->topRight.x = x + trinketItemImageData.imageWidth;
        object->topRight.y = y;
        object->bottomRight.x = x + trinketItemImageData.imageWidth;
        object->bottomRight.y = y + trinketItemImageData.imageHeight;
        object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
        object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
    }
    
    return object;
}
GenericObject* ItemManager::detectItemActiveAtPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = nil;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, itemImageData, 0.8) >=  0.8) {
        object = new GenericObject();
        object->topLeft.x = x;
        object->topLeft.y = y;
        object->bottomLeft.x = x;
        object->bottomLeft.y = y + itemImageData.imageHeight;
        object->topRight.x = x + itemImageData.imageWidth;
        object->topRight.y = y;
        object->bottomRight.x = x + itemImageData.imageWidth;
        object->bottomRight.y = y + itemImageData.imageHeight;
        object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
        object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
    }
    
    return object;
}
GenericObject* ItemManager::detectPotionActiveAtPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = nil;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, potionImageData, 0.8) >=  0.8) {
        object = new GenericObject();
        object->topLeft.x = x;
        object->topLeft.y = y;
        object->bottomLeft.x = x;
        object->bottomLeft.y = y + potionImageData.imageHeight;
        object->topRight.x = x + potionImageData.imageWidth;
        object->topRight.y = y;
        object->bottomRight.x = x + potionImageData.imageWidth;
        object->bottomRight.y = y + potionImageData.imageHeight;
        object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
        object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
    }
    
    return object;
}
GenericObject* ItemManager::detectUsedPotionAtPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
    GenericObject* object = nil;
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, usedPotionImageData, 0.8) >=  0.8) {
        
        //Now test if we have at least 50% of the inside somewhat matching the inner potion
        if (getImageAtPixelPercentageOptimized(getPixel2(imageData, x+1, y+1), x+1, y+1, imageData.imageWidth, imageData.imageHeight, usedPotionInnerImageData, 0.5) >= 0.5) {
        
            object = new GenericObject();
            object->topLeft.x = x;
            object->topLeft.y = y;
            object->bottomLeft.x = x;
            object->bottomLeft.y = y + usedPotionImageData.imageHeight;
            object->topRight.x = x + usedPotionImageData.imageWidth;
            object->topRight.y = y;
            object->bottomRight.x = x + usedPotionImageData.imageWidth;
            object->bottomRight.y = y + usedPotionImageData.imageHeight;
            object->center.x = (object->topRight.x - object->topLeft.x) / 2 + object->topLeft.x;
            object->center.y = (object->bottomLeft.y - object->topLeft.y) / 2 + object->topLeft.y;
        
        }
    }
    
    return object;
}
/*
void ItemManager::processImage(ImageData data) {
    
    lastUpdateTime = clock();
    double lastFullScreenUpdate = (clock() - fullScreenUpdateTime)/CLOCKS_PER_SEC;
    if (lastFullScreenUpdate >= 0.25) { //It's been a whole second, scan the screen
        fullScreenUpdateTime = clock();
        needsFullScreenUpdate = true;
    }
    usedItemInFrame = false;
    item1Active = false;
    item2Active = false;
    item3Active = false;
    trinketActive = false;
    item5Active = false;
    item6Active = false;
    item7Active = false;
    if (needsFullScreenUpdate) {
        detectItems(data);
    }
}

void ItemManager::useItem1() {
    if ((clock() - item1Time)/CLOCKS_PER_SEC >= 3.0 && !usedItemInFrame) {
        item1Time = clock();
        usedItemInFrame = true;
        tapActive1();
    }
}
void ItemManager::useItem2() {
    if ((clock() - item2Time)/CLOCKS_PER_SEC >= 3.0 && !usedItemInFrame) {
        item2Time = clock();
        usedItemInFrame = true;
        tapActive2();
    }
}
void ItemManager::useItem3() {
    if ((clock() - item3Time)/CLOCKS_PER_SEC >= 3.0 && !usedItemInFrame) {
        item3Time = clock();
        usedItemInFrame = true;
        tapActive3();
    }
}
void ItemManager::useTrinket(int x, int y) {
    if ((clock() - trinketTime)/CLOCKS_PER_SEC >= 3.0 && !usedItemInFrame) {
        trinketTime = clock();
        usedItemInFrame = true;
        moveMouse(x, y);
        tapWard();
    }
}
void ItemManager::useItem5() {
    if ((clock() - item5Time)/CLOCKS_PER_SEC >= 3.0 && !usedItemInFrame) {
        item5Time = clock();
        usedItemInFrame = true;
        tapActive5();
    }
}
void ItemManager::useItem6() {
    if ((clock() - item6Time)/CLOCKS_PER_SEC >= 3.0 && !usedItemInFrame) {
        item6Time = clock();
        usedItemInFrame = true;
        tapActive6();
    }
}
void ItemManager::useItem7() {
    if ((clock() - item7Time)/CLOCKS_PER_SEC >= 3.0 && !usedItemInFrame) {
        item7Time = clock();
        usedItemInFrame = true;
        tapActive7();
    }
}

void ItemManager::detectItems(ImageData imageData) {
    
    //Item 1
    int yStart = imageData.imageHeight - 102;
    int yEnd = imageData.imageHeight - 62;
    int xStart = imageData.imageWidth/2 + 124;
    int xEnd = imageData.imageWidth/2 + 160;
    bool isActive = false;
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
        for (int x = xStart; x < xEnd; x++) {
            if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, itemImageData, 10)) {
                isActive = true;
                x = xEnd; y = yEnd;
            }
            pixel += 4;
        }
    }
    if (isActive) item1Active = true;
    
    //Item 2
    xStart = imageData.imageWidth/2 + 160;
    xEnd = imageData.imageWidth/2 + 194;
    isActive = false;
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
        
        for (int x = xStart; x < xEnd; x++) {
            if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, itemImageData, 10)) {
                isActive = true;
                x = xEnd; y = yEnd;
            }
            pixel += 4;
        }
    }
    if (isActive) item2Active = true;
    
    //Item 3
    xStart = imageData.imageWidth/2 + 194;
    xEnd = imageData.imageWidth/2 + 229;
    isActive = false;
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
        
        for (int x = xStart; x < xEnd; x++) {
            if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, itemImageData, 10)) {
                isActive = true;
                x = xEnd; y = yEnd;
            }
            pixel += 4;
        }
    }
    if (isActive) item3Active = true;
    
    //Trinket
    xStart = imageData.imageWidth/2 + 229;
    xEnd = imageData.imageWidth/2 + 270;
    isActive = false;
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
        
        for (int x = xStart; x < xEnd; x++) {
            if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, trinketItemImageData, 60)) {
                isActive = true;
                x = xEnd; y = yEnd;
            }
            pixel += 4;
        }
    }
    if (isActive) trinketActive = true;
    
    //Item 5
    yStart = imageData.imageHeight - 67;
    yEnd = imageData.imageHeight - 30;
    xStart = imageData.imageWidth/2 + 124;
    xEnd = imageData.imageWidth/2 + 160;
    isActive = false;
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
        
        for (int x = xStart; x < xEnd; x++) {
            if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, itemImageData, 10)) {
                isActive = true;
                x = xEnd; y = yEnd;
            }
            pixel += 4;
        }
    }
    if (isActive) item5Active = true;
    //Item 6
    xStart = imageData.imageWidth/2 + 160;
    xEnd = imageData.imageWidth/2 + 194;
    isActive = false;
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
        
        for (int x = xStart; x < xEnd; x++) {
            if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, itemImageData, 10)) {
                isActive = true;
                x = xEnd; y = yEnd;
            }
            pixel += 4;
        }
    }
    if (isActive) item6Active = true;
    //Item 7
    xStart = imageData.imageWidth/2 + 194;
    xEnd = imageData.imageWidth/2 + 229;
    isActive = false;
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
        
        for (int x = xStart; x < xEnd; x++) {
            if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, itemImageData, 10)) {
                isActive = true;
                x = xEnd; y = yEnd;
            }
            pixel += 4;
        }
    }
    if (isActive) item7Active = true;
}*/