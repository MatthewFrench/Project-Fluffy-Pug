//
//  ItemManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "ItemManager.h"

ItemManager::ItemManager() {
    
    trinketItemImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Item Bar/Trinket Active" ofType:@"png"]);
    itemImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Item Bar/Usable Item" ofType:@"png"]);
    
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
}

void ItemManager::processImage(ImageData data) {
    imageData = data;
    
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
        detectItems();
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

void ItemManager::detectItems() {
    
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
}