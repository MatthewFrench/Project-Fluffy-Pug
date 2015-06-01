//
//  EnemyMinionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "EnemyMinionManager.h"

static int Border_Color_Red = 3, Border_Color_Green = 3, Border_Color_Blue = 3;
static int Bar_Color_1_Red = 230, Bar_Color_1_Green = 104, Bar_Color_1_Blue = 104;
static int Bar_Color_2_Red = 193, Bar_Color_2_Green = 87, Bar_Color_2_Blue = 87;
static int Bar_Color_3_Red = 151, Bar_Color_3_Green = 68, Bar_Color_3_Blue = 68;
static int Bar_Color_4_Red = 114, Bar_Color_4_Green = 51, Bar_Color_4_Blue = 51;
static int Debug_Draw_Red = 255, Debug_Draw_Green = 0, Debug_Draw_Blue = 0;

void EnemyMinionManager::debugDraw() {
    for (int i = 0; i < [minionBars count]; i++) {
        struct MinionBar mb;
        [[minionBars objectAtIndex:i] getValue:&mb];
        drawRect(imageData, mb.topLeft.x, mb.topLeft.y, 64, 6, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
    }
}
void EnemyMinionManager::prepareForPixelProcessing() {
    [minionBars removeAllObjects];
    [topLeftMinionCorners removeAllObjects];
    [bottomLeftMinionCorners removeAllObjects];
}

void EnemyMinionManager::postPixelProcessing() {
    //Empty queue into corner array
    Position p;
    while(topLeftMinionQueue.try_dequeue(p)) {
        [topLeftMinionCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
    }
    while(bottomLeftMinionQueue.try_dequeue(p)) {
        [bottomLeftMinionCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
    }
    
    for (int i = 0; i < [topLeftMinionCorners count]; i++) {
        struct Position p;
        [[topLeftMinionCorners objectAtIndex:i] getValue:&p];
        //First check if there's an  bottom corner, that will be sufficient enough to confirm
        int bottomCornerX = p.x;
        int bottomCornerY = p.y+5;
        bool foundBottomCorner = false;
        for (int j = 0; j < [bottomLeftMinionCorners count]; j++) {
            struct Position p2;
            [[bottomLeftMinionCorners objectAtIndex:j] getValue:&p2];
            if (p2.x == bottomCornerX && p2.y == bottomCornerY) {
                //Found a match
                struct MinionBar mb = makeMinionBar(p, p2, makePosition(p.x+63,p.y), makePosition(p.x+63,p.y+5), 100.0);
                [minionBars addObject:[NSValue valueWithBytes:&mb objCType:@encode(struct MinionBar)]];
                [bottomLeftMinionCorners removeObjectAtIndex:j];
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
                struct MinionBar mb = makeMinionBar(p, makePosition(p.x,p.y+5), makePosition(p.x+63,p.y), makePosition(p.x+63,p.y+5), 100.0);
                [minionBars addObject:[NSValue valueWithBytes:&mb objCType:@encode(struct MinionBar)]];
            }
        }
    }
    //Now verify bottom left
    for (int i = 0; i < [bottomLeftMinionCorners count]; i++) {
        struct Position p;
        [[bottomLeftMinionCorners objectAtIndex:i] getValue:&p];
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
            struct MinionBar mb = makeMinionBar(p, makePosition(p.x,p.y+5), makePosition(p.x+63,p.y), makePosition(p.x+63,p.y+5), 100.0);
            [minionBars addObject:[NSValue valueWithBytes:&mb objCType:@encode(struct MinionBar)]];
        }
    }
    
    //Calculate health of minion
    for (int i = 0; i < [minionBars count]; i++) {
        struct MinionBar minion;
        NSValue* value = [minionBars objectAtIndex:i];
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
        value = [NSValue valueWithBytes:&minion objCType:@encode(struct MinionBar)];
        [minionBars replaceObjectAtIndex:i withObject:value];
    }
}

EnemyMinionManager::EnemyMinionManager () {
    minionBars = [NSMutableArray new];
    topLeftMinionCorners = [NSMutableArray new];
    bottomLeftMinionCorners = [NSMutableArray new];
}

void EnemyMinionManager::setImageData(ImageData data) {
    imageData = data;
}

void EnemyMinionManager::processPixel(uint8_t *pixel, int x, int y) {
    //Assume multithreaded
    
    if (isColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue, 5)) {
        //Check if top left border
        if (x < imageData.imageWidth-1) {
            
            uint8_t *rightPixel = pixel + 4;
            if (isColor(rightPixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue, 5)) {
                
                if (y < imageData.imageHeight-1) { //Check for top left bar
                    
                    //Check bottom right pixel
                    uint8_t *bottomRightPixel = pixel + (imageData.imageWidth + 1)*4;
                    if (isColor(bottomRightPixel, Bar_Color_1_Red, Bar_Color_1_Green, Bar_Color_1_Blue, 2)) {
                        uint8_t *bottomPixel = pixel + (imageData.imageWidth)*4;
                        if (isColor(bottomPixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue, 5)) {
                            
                            Position p;p.x=x;p.y=y;
                            topLeftMinionQueue.enqueue(p);
                            
                        }
                    }
                }
            }
            
            
            if (y > 0) { //Check for bottom left bar
                
                
                //Check top right pixel
                uint8_t *topRightPixel = pixel + (-imageData.imageWidth + 1)*4;
                if (isColor(topRightPixel, Bar_Color_4_Red, Bar_Color_4_Green, Bar_Color_4_Blue, 2)) {
                    uint8_t *topPixel = pixel - (imageData.imageWidth)*4;
                    if (isColor(topPixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue, 5)) {
                        
                        Position p;p.x=x;p.y=y;
                        bottomLeftMinionQueue.enqueue(p);
                    }
                }
            }
        }
    }
}