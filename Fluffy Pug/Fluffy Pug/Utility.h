//
//  Utility.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#ifndef __Fluffy_Pug__Utility__
#define __Fluffy_Pug__Utility__

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>

struct ImageData {
    //CFDataRef rawData;
    UInt8 * imageData;
    unsigned long imageByteLength;
    CGRect rect;
};

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

struct Position makePosition(int x, int y);
int getRandomInteger(int minimum, int maximum);
struct MinionBar makeMinionBar(struct Position topLeft, struct Position bottomLeft, struct Position topRight, struct Position bottomRight, float health);
struct Pixel getPixel(struct ImageData imageData, int x, int y);
BOOL isColor(struct Pixel pixel, unsigned char r, unsigned char g, unsigned char b, int tolerance);
BOOL isPreciseColor(struct Pixel pixel, unsigned char r, unsigned char g, unsigned char b);
struct ImageData makeImageData(uint8_t * data, CGRect imageSize);

#endif /* defined(__Fluffy_Pug__Utility__) */
