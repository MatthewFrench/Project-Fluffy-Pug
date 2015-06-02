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
}

void EnemyChampionManager::debugDraw() {
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
    }
}
void EnemyChampionManager::prepareForPixelProcessing() {
    [championBars removeAllObjects];
    [topRightDetect removeAllObjects];
    [topLeftDetect removeAllObjects];
    [bottomRightDetect removeAllObjects];
    [bottomLeftDetect removeAllObjects];
}

void EnemyChampionManager::processPixel(uint8_t *pixel, int x, int y) {
    
    //Detect top left bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topLeftImageData, 5)) {
        Position p;p.x=x;p.y=y;
        topLeftQueue.enqueue(p);
    }
    //Detect bottom left bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomLeftImageData, 5)) {
        Position p;p.x=x;p.y=y;
        bottomLeftQueue.enqueue(p);
    }
    //Detect top right bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight,topRightImageData, 5)) {
        Position p;p.x=x;p.y=y;
        topRightQueue.enqueue(p);
    }
    //Detect bottom right bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight,bottomRightImageData, 5)) {
        Position p;p.x=x;p.y=y;
        bottomRightQueue.enqueue(p);
    }
}

void EnemyChampionManager::postPixelProcessing() {
    Position p;
    while(topLeftQueue.try_dequeue(p)) {
        [topLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
    }
    while(bottomLeftQueue.try_dequeue(p)) {
        [bottomLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
    }
    while(topRightQueue.try_dequeue(p)) {
        [topRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
    }
    while(bottomRightQueue.try_dequeue(p)) {
        [bottomRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
    }
    
    //Empty queue into corner array
    /*
     Position p;
     while(topLeftQueue.try_dequeue(p)) {
     [topLeftCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
     }
     while(bottomLeftQueue.try_dequeue(p)) {
     [bottomLeftCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
     }
     
     for (int i = 0; i < [topLeftCorners count]; i++) {
     struct Position p;
     [[topLeftCorners objectAtIndex:i] getValue:&p];
     //First check if there's an  bottom corner, that will be sufficient enough to confirm
     int bottomCornerX = p.x;
     int bottomCornerY = p.y+5;
     bool foundBottomCorner = false;
     for (int j = 0; j < [bottomLeftCorners count]; j++) {
     struct Position p2;
     [[bottomLeftCorners objectAtIndex:j] getValue:&p2];
     if (p2.x == bottomCornerX && p2.y == bottomCornerY) {
     //Found a match
     struct ChampionBar mb = makeChampionBar(p, p2, makePosition(p.x+63,p.y), makePosition(p.x+63,p.y+5), 100.0);
     [championBars addObject:[NSValue valueWithBytes:&mb objCType:@encode(struct ChampionBar)]];
     [bottomLeftCorners removeObjectAtIndex:j];
     foundBottomCorner = true;
     break;
     }
     }
     if (!foundBottomCorner) {
     int borderCount = 0;
     //Top
     for (int x = p.x; x < p.x + 64 && borderCount < 30; x++) {
     struct Pixel pixel = getPixel(imageData, x, p.y);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     //Bottom
     for (int x = p.x; x < p.x + 64 && borderCount < 30; x++) {
     struct Pixel pixel = getPixel(imageData, x, p.y+5);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     //Left
     for (int y = p.y; y < p.y + 6 && borderCount < 30; y++) {
     struct Pixel pixel = getPixel(imageData, p.x, y);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     //Right
     for (int y = p.y; y < p.y + 6 && borderCount < 30; y++) {
     struct Pixel pixel = getPixel(imageData, p.x, y+63);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     if (borderCount >= 30) {
     struct ChampionBar mb = makeChampionBar(p, makePosition(p.x,p.y+5), makePosition(p.x+63,p.y), makePosition(p.x+63,p.y+5), 100.0);
     [championBars addObject:[NSValue valueWithBytes:&mb objCType:@encode(struct ChampionBar)]];
     }
     }
     }
     //Now verify bottom left
     for (int i = 0; i < [bottomLeftCorners count]; i++) {
     struct Position p;
     [[bottomLeftCorners objectAtIndex:i] getValue:&p];
     p.y -= 5;
     int borderCount = 0;
     //Top
     for (int x = p.x; x < p.x + 64 && borderCount < 30; x++) {
     struct Pixel pixel = getPixel(imageData, x, p.y);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     //Bottom
     for (int x = p.x; x < p.x + 64 && borderCount < 30; x++) {
     struct Pixel pixel = getPixel(imageData, x, p.y+5);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     //Left
     for (int y = p.y; y < p.y + 6 && borderCount < 30; y++) {
     struct Pixel pixel = getPixel(imageData, p.x, y);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     //Right
     for (int y = p.y; y < p.y + 6 && borderCount < 30; y++) {
     struct Pixel pixel = getPixel(imageData, p.x, y+63);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     if (borderCount >= 30) {
     struct ChampionBar mb = makeChampionBar(p, makePosition(p.x,p.y+5), makePosition(p.x+63,p.y), makePosition(p.x+63,p.y+5), 100.0);
     [championBars addObject:[NSValue valueWithBytes:&mb objCType:@encode(struct ChampionBar)]];
     }
     }
     
     //Calculate health of minion
     for (int i = 0; i < [championBars count]; i++) {
     struct ChampionBar minion;
     NSValue* value = [championBars objectAtIndex:i];
     [value getValue:&minion];
     int count = 0;
     //Blue 1 = 81, 162, 230
     for (int x = 0; x < 63; x++) {
     struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+1;
     if (!isPixelColor(getPixel(imageData, b1.x, b1.y), Bar_Color_1_Red, Bar_Color_1_Green, Bar_Color_1_Blue, 1)) {
     if (x > count) {count = x;}
     break;
     }
     }
     //Blue 2 = 68, 136, 193
     for (int x = 0; x < 63; x++) {
     struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+2;
     if (!isPixelColor(getPixel(imageData, b1.x, b1.y), Bar_Color_2_Red, Bar_Color_2_Green, Bar_Color_2_Blue, 1)) {
     if (x > count) {count = x;}
     break;
     }
     }
     //Blue 3 = 53, 107, 151
     for (int x = minion.topLeft.x + 1; x < 63; x++) {
     struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+3;
     if (!isPixelColor(getPixel(imageData, b1.x, b1.y), Bar_Color_3_Red, Bar_Color_3_Green, Bar_Color_3_Blue, 1)) {
     if (x > count) {count = x;}
     break;
     }
     }
     //Blue 4 = 40, 80, 114
     for (int x = minion.topLeft.x + 1; x < 63; x++) {
     struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+4;
     if (!isPixelColor(getPixel(imageData, b1.x, b1.y), Bar_Color_4_Red, Bar_Color_4_Green, Bar_Color_4_Blue, 1)) {
     if (x > count) {count = x;}
     break;
     }
     }
     minion.health = (float)count/62.0;
     value = [NSValue valueWithBytes:&minion objCType:@encode(struct ChampionBar)];
     [championBars replaceObjectAtIndex:i withObject:value];
     }*/
}

void EnemyChampionManager::setImageData(ImageData data) {
    imageData = data;
}