//
//  AllyMinionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "AllyMinionManager.h"

@implementation AllyMinionManager
@synthesize minionBars;

BOOL detectAllyMinionTopLeftBar(struct ImageData imageData, int x , int y);
BOOL detectAllyMinionBottomLeftBar(struct ImageData imageData, int x, int y);

-(id)init {
    if ( self = [super init] ) {
        minionBars = [NSMutableArray new];
    }
    return self;
}

- (void) detectAllyMinions:(struct ImageData)imageData {
    // create a group
    dispatch_group_t group = dispatch_group_create();
    
    [minionBars removeAllObjects];
    
    NSMutableArray* topLeftAllyMinionCorners = [NSMutableArray new];
    NSMutableArray* bottomLeftAllyMinionCorners = [NSMutableArray new];
    
    //Lets look for ally minion health bars
    //Border color is 5, 5, 5
    //Blue 1 = 81, 162, 230
    //Blue 2 = 68, 136, 193
    //Blue 3 = 53, 107, 151
    //Blue 4 = 40, 80, 114
    //Height of bar is 6
    //Width of bar is 64
    
    
    // Note: this assumes 32bit RGBA
    NSLock *arrayLock = [[NSLock alloc] init];
    NSLock *arrayLock2 = [[NSLock alloc] init];

    int cores = 4;
    int section = imageData.rect.size.width/cores;
    for (int i = 0; i < cores; i++) {
        int xStart = section * i;
        int xEnd = xStart + section;
        if (i == cores - 1) {
            xEnd = imageData.rect.size.width;
        }
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (int x = xStart; x < xEnd; x++) {
                for (int y = 0; y < imageData.rect.size.height; y++) {
                    
                    struct Pixel pixel = getPixel(imageData, x, y);
                    
                    if (pixel.exist) {
                        if (isPreciseColor(pixel, 0, 0, 0)) { //Possible border
                            //Check if top left border
                            if (detectAllyMinionTopLeftBar(imageData, x, y)) {
                                struct Position p;
                                p.x = x;
                                p.y = y;
                                [arrayLock lock];
                                [topLeftAllyMinionCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(struct Position)]];
                                [arrayLock unlock];
                            }
                            //Check if bottom left border
                            if (detectAllyMinionBottomLeftBar(imageData, x, y)) {
                                struct Position p;
                                p.x = x;
                                p.y = y;
                                [arrayLock2 lock];
                                    [bottomLeftAllyMinionCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(struct Position)]];
                                [arrayLock2 unlock];
                            }
                        }
                    }
                }
            }
            dispatch_group_leave(group);
        });
        
    }
    
    //dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    //    NSLog(@"finally!");
    //});
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    //Lets verify the corners, we need a little more data to prove that we have minions there
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

inline BOOL detectAllyMinionTopLeftBar(struct ImageData imageData, int x , int y) {
    struct Pixel rightPixel = getPixel(imageData, x+1, y);
    struct Pixel bottomPixel = getPixel(imageData, x, y+1);
    struct Pixel bottomRightPixel = getPixel(imageData, x+1, y+1);
    if (rightPixel.exist && isPreciseColor(rightPixel, 0, 0, 0) &&
        bottomPixel.exist && isPreciseColor(bottomPixel, 0, 0, 0) &&
        bottomRightPixel.exist && isColor(bottomRightPixel, 81, 162, 230, 1)) {
        //Found a possible top left border
        return true;
    }
    return false;
}

inline BOOL detectAllyMinionBottomLeftBar(struct ImageData imageData, int x, int y) {
    struct Pixel rightPixel = getPixel(imageData, x+1, y);
    struct Pixel topPixel = getPixel(imageData, x, y-1);
    struct Pixel topRightPixel = getPixel(imageData, x+1, y-1);
    if (rightPixel.exist && isPreciseColor(rightPixel, 0, 0, 0) &&
        topPixel.exist && isPreciseColor(topPixel, 0, 0, 0) &&
        topRightPixel.exist && isColor(topRightPixel, 40, 80, 114, 1)) {
        //Found a possible bottom left border
        return true;
    }
    return false;
}

@end
