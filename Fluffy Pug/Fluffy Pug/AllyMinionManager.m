//
//  AllyMinionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "AllyMinionManager.h"

//@implementation AllyMinionManager
//@synthesize minionBars, blackBorderLock, topLeftAllyMinionCorners, bottomLeftAllyMinionCorners;

//static inline BOOL detectAllyMinionTopLeftBar(struct ImageData imageData, int x , int y);
//static inline BOOL detectAllyMinionBottomLeftBar(struct ImageData imageData, int x, int y);
/*
 
 - (void)addLeftCorner:(struct Position)p top:(BOOL)top {
 if (top) {
 [blackBorderLock lock];
 [topLeftAllyMinionCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(struct Position)]];
 [blackBorderLock unlock];
 } else {
 [blackBorderLock lock];
 [bottomLeftAllyMinionCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(struct Position)]];
 [blackBorderLock unlock];
 }
 }
 */
void AllyMinionManager::debugDraw() {
    for (int i = 0; i < [minionBars count]; i++) {
        struct MinionBar mb;
        [[minionBars objectAtIndex:i] getValue:&mb];
        drawRect(imageData, mb.topLeft.x + 32, mb.topLeft.y + 3, 64, 6, 0, 255, 0);
    }
    //for (int i = 0; i < [possibleBlackBorders count]; i++) {
    //    struct Position p;
    //    [[possibleBlackBorders objectAtIndex:i] getValue:&p];
    //
    //    //highlight them
    //    drawRect(imageData, p.x, p.y, 2, 2, 0, 255, 0);
    //}
}
void AllyMinionManager::prepareForPixelProcessing() {
    [minionBars removeAllObjects];
    [topLeftAllyMinionCorners removeAllObjects];
    [bottomLeftAllyMinionCorners removeAllObjects];
}

void AllyMinionManager::postPixelProcessing() {
    //Empty queue into corner array
    Position p;
    while(topLeftAllyMinionQueue.try_dequeue(p)) {
        [topLeftAllyMinionCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
    }
    while(bottomLeftAllyMinionQueue.try_dequeue(p)) {
        [bottomLeftAllyMinionCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
    }
    
    for (int i = 0; i < [topLeftAllyMinionCorners count]; i++) {
        struct Position p;
        [[topLeftAllyMinionCorners objectAtIndex:i] getValue:&p];
        //First check if there's an ally bottom corner, that will be sufficient enough to confirm
        int bottomCornerX = p.x;
        int bottomCornerY = p.y+5;
        bool foundBottomCorner = false;
        for (int j = 0; j < [bottomLeftAllyMinionCorners count]; j++) {
            struct Position p2;
            [[bottomLeftAllyMinionCorners objectAtIndex:j] getValue:&p2];
            if (p2.x == bottomCornerX && p2.y == bottomCornerY) {
                //Found a match
                struct MinionBar mb = makeMinionBar(p, p2, makePosition(p.x+63,p.y), makePosition(p.x+63,p.y+5), 100.0);
                [minionBars addObject:[NSValue valueWithBytes:&mb objCType:@encode(struct MinionBar)]];
                [bottomLeftAllyMinionCorners removeObjectAtIndex:j];
                foundBottomCorner = true;
                break;
            }
        }
        if (!foundBottomCorner) {
            int borderCount = 0;
            //Top
            for (int x = p.x; x < p.x + 64 && borderCount < 30; x++) {
                struct Pixel pixel = getPixel(imageData, x, p.y);
                if (isPreciseColor(pixel, 0, 0, 0)) {
                    borderCount++;
                }
            }
            //Bottom
            for (int x = p.x; x < p.x + 64 && borderCount < 30; x++) {
                struct Pixel pixel = getPixel(imageData, x, p.y+5);
                if (isPreciseColor(pixel, 0, 0, 0)) {
                    borderCount++;
                }
            }
            //Left
            for (int y = p.y; y < p.y + 6 && borderCount < 30; y++) {
                struct Pixel pixel = getPixel(imageData, p.x, y);
                if (isPreciseColor(pixel, 0, 0, 0)) {
                    borderCount++;
                }
            }
            //Right
            for (int y = p.y; y < p.y + 6 && borderCount < 30; y++) {
                struct Pixel pixel = getPixel(imageData, p.x, y+63);
                if (isPreciseColor(pixel, 0, 0, 0)) {
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
    for (int i = 0; i < [bottomLeftAllyMinionCorners count]; i++) {
        struct Position p;
        [[bottomLeftAllyMinionCorners objectAtIndex:i] getValue:&p];
        p.y -= 5;
        int borderCount = 0;
        //Top
        for (int x = p.x; x < p.x + 64 && borderCount < 30; x++) {
            struct Pixel pixel = getPixel(imageData, x, p.y);
            if (isPreciseColor(pixel, 0, 0, 0)) {
                borderCount++;
            }
        }
        //Bottom
        for (int x = p.x; x < p.x + 64 && borderCount < 30; x++) {
            struct Pixel pixel = getPixel(imageData, x, p.y+5);
            if (isPreciseColor(pixel, 0, 0, 0)) {
                borderCount++;
            }
        }
        //Left
        for (int y = p.y; y < p.y + 6 && borderCount < 30; y++) {
            struct Pixel pixel = getPixel(imageData, p.x, y);
            if (isPreciseColor(pixel, 0, 0, 0)) {
                borderCount++;
            }
        }
        //Right
        for (int y = p.y; y < p.y + 6 && borderCount < 30; y++) {
            struct Pixel pixel = getPixel(imageData, p.x, y+63);
            if (isPreciseColor(pixel, 0, 0, 0)) {
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
            if (!isColor(getPixel(imageData, b1.x, b1.y), 81, 162, 230, 1)) {
                if (x > count) {count = x;}
                break;
            }
        }
        //Blue 2 = 68, 136, 193
        for (int x = 0; x < 63; x++) {
            struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+2;
            if (!isColor(getPixel(imageData, b1.x, b1.y), 68, 136, 193, 1)) {
                if (x > count) {count = x;}
                break;
            }
        }
        //Blue 3 = 53, 107, 151
        for (int x = minion.topLeft.x + 1; x < 63; x++) {
            struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+3;
            if (!isColor(getPixel(imageData, b1.x, b1.y), 53, 107, 151, 1)) {
                if (x > count) {count = x;}
                break;
            }
        }
        //Blue 4 = 40, 80, 114
        for (int x = minion.topLeft.x + 1; x < 63; x++) {
            struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+4;
            if (!isColor(getPixel(imageData, b1.x, b1.y), 40, 80, 114, 1)) {
                if (x > count) {count = x;}
                break;
            }
        }
        minion.health = (float)count/62.0;
        value = [NSValue valueWithBytes:&minion objCType:@encode(struct MinionBar)];
        [minionBars replaceObjectAtIndex:i withObject:value];
    }
}

/*
 static inline BOOL detectAllyMinionTopLeftBar(struct ImageData imageData, int x , int y) {
 struct Pixel bottomRightPixel = getPixel(imageData, x+1, y+1);
 if (bottomRightPixel.exist && isColor(bottomRightPixel, 81, 162, 230, 1)) {
 struct Pixel rightPixel = getPixel(imageData, x+1, y);
 if (rightPixel.exist && isPreciseColor(rightPixel, 0, 0, 0)) {
 struct Pixel bottomPixel = getPixel(imageData, x, y+1);
 if (bottomPixel.exist && isPreciseColor(bottomPixel, 0, 0, 0)) {
 //Found a possible top left border
 return true;
 }
 }
 }
 
 return false;
 }
 
 static inline BOOL detectAllyMinionBottomLeftBar(struct ImageData imageData, int x, int y) {
 struct Pixel topRightPixel = getPixel(imageData, x+1, y-1);
 if (topRightPixel.exist && isColor(topRightPixel, 40, 80, 114, 1)) {
 struct Pixel rightPixel = getPixel(imageData, x+1, y);
 if (rightPixel.exist && isPreciseColor(rightPixel, 0, 0, 0)) {
 struct Pixel topPixel = getPixel(imageData, x, y-1);
 if (
 topPixel.exist && isPreciseColor(topPixel, 0, 0, 0)) {
 //Found a possible bottom left border
 return true;
 }
 }
 }
 return false;
 }*/

AllyMinionManager::AllyMinionManager () {
    minionBars = [NSMutableArray new];
    topLeftAllyMinionCorners = [NSMutableArray new];
    bottomLeftAllyMinionCorners = [NSMutableArray new];
}

void AllyMinionManager::setImageData(ImageData data) {
    imageData = data;
}

void AllyMinionManager::processPixel(uint8_t *pixel, int x, int y) {
    //Assume multithreaded
    
    if (pixel[0] == 0) {
        if (pixel[1] == 0) {
            if (pixel[2] == 0) {
                //Check if top left border
                if (x < imageData.imageWidth-1) {
                    
                    uint8_t *rightPixel = pixel + 4;
                    if (rightPixel[0] == 0) {
                        if (rightPixel[1] == 0) {
                            if (rightPixel[2] == 0) {
                                
                                if (y < imageData.imageHeight-1) { //Check for top left bar
                                    
                                    //Check bottom right pixel
                                    uint8_t *bottomRightPixel = pixel + (imageData.imageWidth + 1)*4;
                                    if (bottomRightPixel[0] == 230) {
                                        if (bottomRightPixel[1] == 162) {
                                            if (bottomRightPixel[2] == 81) {
                                                uint8_t *bottomPixel = pixel + (imageData.imageWidth)*4;
                                                if (bottomPixel[0] == 0 && bottomPixel[1] == 0 && bottomPixel[2] == 0) {
                                                    
                                                    Position p;p.x=x;p.y=y;
                                                    topLeftAllyMinionQueue.enqueue(p);
                                                    
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                
                                if (y > 0) { //Check for bottom left bar
                                    
                                    
                                    //Check top right pixel
                                    uint8_t *topRightPixel = pixel + (-imageData.imageWidth + 1)*4;
                                    if (topRightPixel[0] == 114) {
                                        if (topRightPixel[1] == 80) {
                                            if (topRightPixel[2] == 40) {
                                                uint8_t *topPixel = pixel - (imageData.imageWidth)*4;
                                                if (topPixel[0] == 0 && topPixel[1] == 0 && topPixel[2] == 0) {
                                                    
                                                    Position p;p.x=x;p.y=y;
                                                    bottomLeftAllyMinionQueue.enqueue(p);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


//@end
