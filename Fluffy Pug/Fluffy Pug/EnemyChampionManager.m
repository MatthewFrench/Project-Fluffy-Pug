//
//  EnemyChampionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "EnemyChampionManager.h"

static int Debug_Draw_Red = 255, Debug_Draw_Green = 0, Debug_Draw_Blue = 255;

EnemyChampionManager::EnemyChampionManager () {
    championBars = [NSMutableArray new];
    topRightDetect = [NSMutableArray new];
    topLeftDetect = [NSMutableArray new];
    bottomRightDetect = [NSMutableArray new];
    bottomLeftDetect = [NSMutableArray new];
    
    topLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Top Left Corner" ofType:@"png"]);
    
    bottomLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Bottom Left Corner" ofType:@"png"]);
    bottomRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Bottom Right Corner" ofType:@"png"]);
    topRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Top Right Corner" ofType:@"png"]);
    healthSegmentImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Health Segment" ofType:@"png"]);
    
    needsFullScreenUpdate = true;
    fullScreenUpdateTime = clock();
    lastUpdateTime = clock();
}

void EnemyChampionManager::debugDraw() {
    for (int i = 0; i < [championBars count]; i++) {
        ChampionBar mb;
        [[championBars objectAtIndex:i] getValue:&mb];
        drawRect(imageData, mb.topLeft.x, mb.topLeft.y, 104, 9, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
    }
    /*
    for (int i = 0; i < [topLeftDetect count]; i++) {
        struct Position p;
        [[topLeftDetect objectAtIndex:i] getValue:&p];
        drawRect(imageData, p.x, p.y, 4, 4, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
    }
    for (int i = 0; i < [topRightDetect count]; i++) {
        struct Position p;
        [[topRightDetect objectAtIndex:i] getValue:&p];
        drawRect(imageData, p.x, p.y, 4, 4, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
    }
    for (int i = 0; i < [bottomLeftDetect count]; i++) {
        struct Position p;
        [[bottomLeftDetect objectAtIndex:i] getValue:&p];
        drawRect(imageData, p.x, p.y, 4, 4, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
    }
    for (int i = 0; i < [bottomRightDetect count]; i++) {
        struct Position p;
        [[bottomRightDetect objectAtIndex:i] getValue:&p];
        drawRect(imageData, p.x, p.y, 4, 4, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
    }*/
}
void EnemyChampionManager::processImage(ImageData data) {
    imageData = data;
    double delta = (clock() - lastUpdateTime)/CLOCKS_PER_SEC;
    lastUpdateTime = clock();
    double lastFullScreenUpdate = (clock() - fullScreenUpdateTime)/CLOCKS_PER_SEC;
    if (lastFullScreenUpdate >= 1.0) { //It's been a whole second, scan the screen
        fullScreenUpdateTime = clock();
        needsFullScreenUpdate = true;
    }
    
    //Clear all corners
    [topRightDetect removeAllObjects];
    [topLeftDetect removeAllObjects];
    [bottomRightDetect removeAllObjects];
    [bottomLeftDetect removeAllObjects];
    
    if (needsFullScreenUpdate) { //Scan full screen
        needsFullScreenUpdate = false;
        scanSection(0, 0, imageData.imageWidth, imageData.imageHeight);
    } else {
        //Scan only where we last saw enemy champions
        for (int i = 0; i < [championBars count]; i++) {
            ChampionBar cb;
            NSValue* value = [championBars objectAtIndex:i];
            [value getValue:&cb];
            //Assume a certain speed per second for champions
            int xStart = cb.topLeft.x - delta*championSpeed - 5;
            int yStart = cb.topLeft.y - delta*championSpeed - 5;
            int xEnd = cb.bottomRight.x + delta*championSpeed + 5;
            int yEnd = cb.bottomRight.y + delta*championSpeed + 5;
            if (xStart < 0) xStart = 0;
            if (yStart < 0) yStart = 0;
            if (xEnd > imageData.imageWidth) xEnd = imageData.imageWidth;
            if (yEnd > imageData.imageHeight) yEnd = imageData.imageHeight;
            scanSection(xStart, yStart, xEnd, yEnd);
        }
    }
    [championBars removeAllObjects];
    //Take the scanned corners and get champion data
    processChampionsLocations();
    processChampionsHealth();
}
void EnemyChampionManager::scanSection(int xStart, int yStart, int xEnd, int yEnd) {
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = getPixel2(imageData, xStart, y);
        
        for (int x = xStart; x < xEnd; x++) {
            processPixel(pixel, x, y);
            
            pixel += 4;
        }
    }
}
void EnemyChampionManager::processChampionsLocations() {
    processTopLeftDetect();
    processTopRightDetect();
    processBottomLeftDetect();
    processBottomRightDetect();
}
void EnemyChampionManager::processChampionsHealth() {
    for (int i = 0; i < [championBars count]; i++) {
        ChampionBar cb;
        [[championBars objectAtIndex:i] getValue:&cb];
        cb.health = 0;
        for (int x = 104; x > 0; x--) {
            if (cb.bottomLeft.y-1 < imageData.imageHeight && cb.bottomLeft.x+1 + x < imageData.imageWidth) {
                uint8_t *pixel = getPixel2(imageData, cb.bottomLeft.x+1 + x, cb.bottomLeft.y-1);
            if (isColor(pixel, 168, 48, 16, 20)) {
                cb.health = (float)x / 104.0;
                break;
            }
            }
        }
        
        [championBars replaceObjectAtIndex:i withObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
    }
}



void EnemyChampionManager::processPixel(uint8_t *pixel, int x, int y) {
    //Detect top left bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topLeftImageData, 5)) {
        Position p;p.x=x;p.y=y;
        //Add if not detected
        if (!containsPosition(topLeftDetect, p)) {
            [topLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect bottom left bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomLeftImageData, 2)) {
        Position p;p.x=x;p.y=y;
        if (!containsPosition(bottomLeftDetect, p)) {
            [bottomLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect top right bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight,topRightImageData, 5)) {
        Position p;p.x=x;p.y=y;
        if (!containsPosition(topRightDetect, p)) {
            [topRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect bottom right bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight,bottomRightImageData, 2)) {
        Position p;p.x=x;p.y=y;
        if (!containsPosition(bottomRightDetect, p)) {
            [bottomRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
}
bool EnemyChampionManager::containsPosition(NSMutableArray* array, Position p) {
    for (int i = 0; i < [array count]; i++) {
        Position p2;
        [[array objectAtIndex:i] getValue:&p2];
        if (p2.x == p.x && p2.y == p.y) {
            return true;
        }
    }
    return false;
}
void EnemyChampionManager::processTopLeftDetect() {
    while ([topLeftDetect count] > 0) {
        Position p;
        [[topLeftDetect lastObject] getValue:&p];
        [topLeftDetect removeLastObject];
        //Remove top right corner
        for (int i = 0; i < [topRightDetect count]; i++) {
            Position p2;
            [[topRightDetect objectAtIndex:i] getValue:&p2];
            if (p2.y == p.y && p2.x-p.x > 100 && p2.x-p.x < 115) {//Approx
                [topRightDetect removeObjectAtIndex:i];
                break;
            }
        }
        //Remove bottom left corner
        for (int i = 0; i < [bottomLeftDetect count]; i++) {
            Position p2;
            [[bottomLeftDetect objectAtIndex:i] getValue:&p2];
            if (p2.x == p.x && p2.y-p.y > 10 && p2.y-p.y < 22) {//Approx
                [bottomLeftDetect removeObjectAtIndex:i];
                break;
            }
        }
        //Remove bottom right corner
        for (int i = 0; i < [bottomRightDetect count]; i++) {
            Position p2;
            [[bottomRightDetect objectAtIndex:i] getValue:&p2];
            if (p2.x-p.x > 100 && p2.x-p.x < 115 && p2.y-p.y > 10 && p2.y-p.y < 22) {//Approx
                [bottomRightDetect removeObjectAtIndex:i];
                break;
            }
        }
        //Now add champion bar
        ChampionBar cb;
        cb.topLeft = makePosition(p.x + 3, p.y + 3);
        cb.topRight = makePosition(cb.topLeft.x, cb.topLeft.y + 104);
        cb.bottomLeft = makePosition(cb.topLeft.x + 9, cb.topLeft.y);
        cb.bottomRight = makePosition(cb.topLeft.x + 9, cb.topLeft.y + 104);
        [championBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
    }
}

void EnemyChampionManager::processBottomRightDetect() {
    while ([bottomRightDetect count] > 0) {
        Position p;
        [[bottomRightDetect lastObject] getValue:&p];
        [bottomRightDetect removeLastObject];
        //Remove top right corner
        for (int i = 0; i < [topRightDetect count]; i++) {
            Position p2;
            [[topRightDetect objectAtIndex:i] getValue:&p2];
            if (p2.x == p.x && p.y-p2.y > 10 && p.y-p2.y < 22) {//Approx
                [topRightDetect removeObjectAtIndex:i];
                break;
            }
        }
        //Remove bottom left corner
        for (int i = 0; i < [bottomLeftDetect count]; i++) {
            Position p2;
            [[bottomLeftDetect objectAtIndex:i] getValue:&p2];
            if (p2.y == p.y && p.x-p2.x > 100 && p.x-p2.x < 115) {//Approx
                [bottomLeftDetect removeObjectAtIndex:i];
                break;
            }
        }
        //Remove top left corner
        for (int i = 0; i < [topLeftDetect count]; i++) {
            Position p2;
            [[topLeftDetect objectAtIndex:i] getValue:&p2];
            if (p.x-p2.x > 100 && p.x-p2.x < 115 && p.y-p2.y > 10 && p.y-p2.y < 22) {//Approx
                [topLeftDetect removeObjectAtIndex:i];
                break;
            }
        }
        //Now add champion bar
        ChampionBar cb;
        cb.bottomRight = makePosition(p.x+1, p.y+1);
        cb.topLeft = makePosition(cb.bottomRight.x - 104, cb.bottomRight.y - 9);
        cb.topRight = makePosition(cb.topLeft.x, cb.topLeft.y + 104);
        cb.bottomLeft = makePosition(cb.topLeft.x + 9, cb.topLeft.y);
        [championBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
    }
}

void EnemyChampionManager::processBottomLeftDetect() {
    while ([bottomLeftDetect count] > 0) {
        Position p;
        [[bottomLeftDetect lastObject] getValue:&p];
        [bottomLeftDetect removeLastObject];
        //Remove top right corner
        for (int i = 0; i < [topRightDetect count]; i++) {
            Position p2;
            [[topRightDetect objectAtIndex:i] getValue:&p2];
            if (p.y-p2.y > 10 && p.y-p2.y < 22 && p2.x-p.x > 100 && p2.x-p.x < 115) {//Approx
                [topRightDetect removeObjectAtIndex:i];
                break;
            }
        }
        //Remove bottom left corner
        for (int i = 0; i < [topLeftDetect count]; i++) {
            Position p2;
            [[topLeftDetect objectAtIndex:i] getValue:&p2];
            if (p2.x == p.x && p.y-p2.y > 10 && p.y-p2.y < 22) {//Approx
                [topLeftDetect removeObjectAtIndex:i];
                break;
            }
        }
        //Remove bottom right corner
        for (int i = 0; i < [bottomRightDetect count]; i++) {
            Position p2;
            [[bottomRightDetect objectAtIndex:i] getValue:&p2];
            if (p2.x-p.x > 100 && p2.x-p.x < 115 && p2.y == p.y) {//Approx
                [bottomRightDetect removeObjectAtIndex:i];
                break;
            }
        }
        //Now add champion bar
        ChampionBar cb;
        cb.bottomLeft = makePosition(p.x + 3, p.y);
        cb.topLeft = makePosition(cb.bottomLeft.x, cb.bottomLeft.y - 104);
        cb.topRight = makePosition(cb.topLeft.x, cb.topLeft.y + 104);
        cb.bottomRight = makePosition(cb.topLeft.x + 9, cb.topLeft.y + 104);
        [championBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
    }
}
void EnemyChampionManager::processTopRightDetect() {
    while ([topRightDetect count] > 0) {
        Position p;
        [[topRightDetect lastObject] getValue:&p];
        [topRightDetect removeLastObject];
        //Remove top left corner
        for (int i = 0; i < [topLeftDetect count]; i++) {
            Position p2;
            [[topLeftDetect objectAtIndex:i] getValue:&p2];
            if (p2.y == p.y && p2.x-p.x < -100 && p2.x-p.x > -115) {//Approx
                [topLeftDetect removeObjectAtIndex:i];
                break;
            }
        }
        //Remove bottom left corner
        for (int i = 0; i < [bottomLeftDetect count]; i++) {
            Position p2;
            [[bottomLeftDetect objectAtIndex:i] getValue:&p2];
            if (p2.x-p.x < -100 && p2.x-p.x > -115 && p2.y-p.y > 10 && p2.y-p.y < 22) {//Approx
                [bottomLeftDetect removeObjectAtIndex:i];
                break;
            }
        }
        //Remove bottom right corner
        for (int i = 0; i < [bottomRightDetect count]; i++) {
            Position p2;
            [[bottomRightDetect objectAtIndex:i] getValue:&p2];
            if (p2.x == p.x && p2.y-p.y > 10 && p2.y-p.y < 22) {//Approx
                [bottomRightDetect removeObjectAtIndex:i];
                break;
            }
        }
        //Now add champion bar
        ChampionBar cb;
        cb.topRight = makePosition(p.x, p.y + 3);
        cb.topLeft = makePosition(cb.topRight.x - 104, cb.topRight.y);
        cb.bottomLeft = makePosition(cb.topLeft.x + 9, cb.topLeft.y);
        cb.bottomRight = makePosition(cb.topLeft.x + 9, cb.topLeft.y + 104);
        [championBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
    }
}