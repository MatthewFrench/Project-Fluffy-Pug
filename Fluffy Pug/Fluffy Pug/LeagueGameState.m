//
//  LeagueGameState.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "LeagueGameState.h"

struct Pixel {
    unsigned char r, g, b;
    BOOL exist;
};

struct Position {
    int x, y;
};

struct MinionBar {
    struct Position topLeft, topRight, bottomLeft, bottomRight;
    float health;
};

@interface LeagueGameState () {
    int leaguePID;
    CGRect leagueSize;
    const unsigned char *imageData;
    int imageByteLength;
}
@end
@implementation LeagueGameState
@synthesize leaguePID, leagueSize;
-(id)init {
    if ( self = [super init] ) {
        leaguePID = -1;
    }
    return self;
}

//854784 * 4
//3419136

- (void) processImage:(CGImageRef)image {
    NSMutableArray* minionBars = [NSMutableArray new];
    
    NSMutableArray* topLeftAllyMinionCorners = [NSMutableArray new];
    NSMutableArray* bottomLeftAllyMinionCorners = [NSMutableArray new];
    
    NSData *data = (NSData *)CFBridgingRelease(CGDataProviderCopyData(CGImageGetDataProvider(image)));
    imageData = (const unsigned char *)[data bytes];
    imageByteLength = (int)[data length];
    
    //Print top left pixel
    //struct Pixel tl = [self getPixel:0 y:0];
    //NSLog(@"Color: %d %d %d", tl.r, tl.g, tl.b);
    
    //193
    //136
    //68
    
    // Note: this assumes 32bit RGBA
    for (int x = 0; x < leagueSize.size.width; x++) {
        for (int y = 0; y < leagueSize.size.height; y++) {
            struct Pixel pixel = [self getPixel:x y:y];
            if (pixel.exist) {
                //Lets look for ally minion health bars
                //Border color is 5, 5, 5
                //Blue 1 = 81, 162, 230
                //Blue 2 = 68, 136, 193
                //Blue 3 = 53, 107, 151
                //Blue 4 = 40, 80, 114
                //Height of bar is 6
                //Width of bar is 64
                
                if ([self isColor:pixel r:5 g:5 b:5 tolerance:20]) { //Possible border
                    //Check if top left border
                    if ([self detectAllyMinionTopLeftBar:x y:y]) {
                        //NSLog(@"Found top left border");
                        //Found a possible top left border
                        struct Position p;
                        p.x = x;
                        p.y = y;
                        [topLeftAllyMinionCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(struct Position)]];
                    }
                    //Check if bottom left border
                    if ([self detectAllyMinionBottomLeftBar:x y:y]) {
                        //NSLog(@"Found bottom left border");
                        //Found a possible bottom left border
                        struct Position p;
                        p.x = x;
                        p.y = y;
                        [bottomLeftAllyMinionCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(struct Position)]];
                    }
                }
            }
        }
    }
    
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
                struct MinionBar mb = [self makeMinionBar:p bottomLeft:p2 topRight:[self makePosition:p.x+63 y:p.y] bottomRight:[self makePosition:p.x+63 y:p.y+5] health:100.0];
                [minionBars addObject:[NSValue valueWithBytes:&mb objCType:@encode(struct MinionBar)]];
                [bottomLeftAllyMinionCorners removeObjectAtIndex:j];
                foundBottomCorner = true;
                break;
            }
        }
        if (!foundBottomCorner) {
            int borderCount = 0;
            //Top
            for (int x = p.x; x < p.x + 64; x++) {
                struct Pixel pixel = [self getPixel:x y:p.y];
                if (pixel.exist && pixel.r == 5 && pixel.b == 5 && pixel.g == 5) {
                    borderCount++;
                }
            }
            //Bottom
            for (int x = p.x; x < p.x + 64; x++) {
                struct Pixel pixel = [self getPixel:x y:p.y+5];
                if (pixel.exist && pixel.r == 5 && pixel.b == 5 && pixel.g == 5) {
                    borderCount++;
                }
            }
            //Left
            for (int y = p.y; y < p.y + 6; y++) {
                struct Pixel pixel = [self getPixel:p.x y:y];
                if (pixel.exist && pixel.r == 5 && pixel.b == 5 && pixel.g == 5) {
                    borderCount++;
                }
            }
            //Right
            for (int y = p.y; y < p.y + 6; y++) {
                struct Pixel pixel = [self getPixel:p.x y:y+63];
                if (pixel.exist && pixel.r == 5 && pixel.b == 5 && pixel.g == 5) {
                    borderCount++;
                }
            }
            if (borderCount >= 30) {
                struct MinionBar mb = [self makeMinionBar:p bottomLeft:[self makePosition:p.x y:p.y+5] topRight:[self makePosition:p.x+63 y:p.y] bottomRight:[self makePosition:p.x+63 y:p.y+5] health:100.0];
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
        for (int x = p.x; x < p.x + 64; x++) {
            struct Pixel pixel = [self getPixel:x y:p.y];
            if (pixel.exist && pixel.r == 5 && pixel.b == 5 && pixel.g == 5) {
                borderCount++;
            }
        }
        //Bottom
        for (int x = p.x; x < p.x + 64; x++) {
            struct Pixel pixel = [self getPixel:x y:p.y+5];
            if (pixel.exist && pixel.r == 5 && pixel.b == 5 && pixel.g == 5) {
                borderCount++;
            }
        }
        //Left
        for (int y = p.y; y < p.y + 6; y++) {
            struct Pixel pixel = [self getPixel:p.x y:y];
            if (pixel.exist && pixel.r == 5 && pixel.b == 5 && pixel.g == 5) {
                borderCount++;
            }
        }
        //Right
        for (int y = p.y; y < p.y + 6; y++) {
            struct Pixel pixel = [self getPixel:p.x y:y+63];
            if (pixel.exist && pixel.r == 5 && pixel.b == 5 && pixel.g == 5) {
                borderCount++;
            }
        }
        if (borderCount >= 30) {
            struct MinionBar mb = [self makeMinionBar:p bottomLeft:[self makePosition:p.x y:p.y+5] topRight:[self makePosition:p.x+63 y:p.y] bottomRight:[self makePosition:p.x+63 y:p.y+5] health:100.0];
            [minionBars addObject:[NSValue valueWithBytes:&mb objCType:@encode(struct MinionBar)]];
        }
    }
    
    for (int i = 0; i < [minionBars count]; i++) {
        struct MinionBar minion;
        NSValue* value = [minionBars objectAtIndex:i];
        [value getValue:&minion];
        int count = 0;
        //Blue 1 = 81, 162, 230
        for (int x = 0; x < 63; x++) {
            struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+1;
            if (![self isColor:[self getPixel:b1.x y:b1.y] r:81 g:162 b:230 tolerance:20]) {
                if (x > count) {count = x;}
                break;
            }
        }
        //Blue 2 = 68, 136, 193
        for (int x = 0; x < 63; x++) {
            struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+2;
            if (![self isColor:[self getPixel:b1.x y:b1.y] r:68 g:136 b:193 tolerance:20]) {
                if (x > count) {count = x;}
                break;
            }
        }
        //Blue 3 = 53, 107, 151
        for (int x = minion.topLeft.x + 1; x < 63; x++) {
            struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+3;
            if (![self isColor:[self getPixel:b1.x y:b1.y] r:53 g:107 b:151 tolerance:20]) {
                if (x > count) {count = x;}
                break;
            }
        }
        //Blue 4 = 40, 80, 114
        for (int x = minion.topLeft.x + 1; x < 63; x++) {
            struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+4;
            if (![self isColor:[self getPixel:b1.x y:b1.y] r:40 g:80 b:114 tolerance:20]) {
                if (x > count) {count = x;}
                break;
            }
        }
        minion.health = (float)count/62.0;
        value = [NSValue valueWithBytes:&minion objCType:@encode(struct MinionBar)];
        [minionBars replaceObjectAtIndex:i withObject:value];
    }
    
    
    
    if ([minionBars count] > 0) {
        for (int i = 0; i < 10; i++) {
            NSLog(@" ");
        }
        NSLog(@"Detected ally minions: %lu", (unsigned long)[minionBars count]);
        for (int i = 0; i < [minionBars count]; i++) {
            struct MinionBar minion;
            [[minionBars objectAtIndex:i] getValue:&minion];
            NSLog(@"Minion %d health: %f", i+1, minion.health*100);
        }
    }
}
- (BOOL) detectAllyMinionTopLeftBar:(int)x y:(int)y {
    struct Pixel rightPixel = [self getPixel:x+1 y:y];
    struct Pixel bottomPixel = [self getPixel:x y:y+1];
    struct Pixel bottomRightPixel = [self getPixel:x+1 y:y+1];
    if (rightPixel.exist && [self isColor:rightPixel r:5 g:5 b:5 tolerance:20] &&
        bottomPixel.exist && [self isColor:bottomPixel r:5 g:5 b:5 tolerance:20] &&
        bottomRightPixel.exist && [self isColor:bottomRightPixel r:81 g:162 b:230 tolerance:20]) {
        //Found a possible top left border
        return true;
    }
    return false;
}

- (BOOL) detectAllyMinionBottomLeftBar:(int)x y:(int)y {
    struct Pixel rightPixel = [self getPixel:x+1 y:y];
    struct Pixel topPixel = [self getPixel:x y:y-1];
    struct Pixel topRightPixel = [self getPixel:x+1 y:y-1];
    if (rightPixel.exist && [self isColor:rightPixel r:5 g:5 b:5 tolerance:20] &&
        topPixel.exist && [self isColor:topPixel r:5 g:5 b:5 tolerance:20] &&
        topRightPixel.exist && [self isColor:topRightPixel r:40 g:80 b:114 tolerance:20]) {
        //Found a possible bottom left border
        return true;
    }
    return false;
}

- (BOOL) isColor:(struct Pixel)pixel r:(unsigned char)r g:(unsigned char)g b:(unsigned char)b tolerance:(int)tolerance {
    if (abs(pixel.r - r) <= tolerance && abs(pixel.g - g) <= tolerance && abs(pixel.b - b) <= tolerance) {
        return true;
    }
    return false;
}

- (struct Pixel) getPixel:(int)x y:(int)y {
    int position = (y * leagueSize.size.width + x) * 4;
    struct Pixel p;
    if (position+3 < imageByteLength) {
        p.r = imageData[position+2];
        p.g = imageData[position+1];
        p.b = imageData[position+0];
        p.exist = true;
    } else {
        p.exist = false;
        //NSLog(@"Pixel does not exist");
    }
    return p;
}

-(struct Position) makePosition:(int)x y:(int)y {
    struct Position p;
    p.x = x;
    p.y = y;
    return p;
}
-(struct MinionBar) makeMinionBar:(struct Position)topLeft bottomLeft:(struct Position)bottomLeft topRight:(struct Position)topRight bottomRight:(struct Position)bottomRight health:(float)health {
    struct MinionBar mb;
    mb.topLeft = topLeft; mb.bottomLeft = bottomLeft; mb.topRight = topRight; mb.bottomRight = bottomRight;
    mb.health = health;
    return mb;
}


@end