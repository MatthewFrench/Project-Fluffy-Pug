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
    int imageWidth; int imageHeight;
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

struct ChampionBar {
    struct Position topLeft, topRight, bottomLeft, bottomRight;
    float health;
};

 Position makePosition(int x, int y);
int getRandomInteger(int minimum, int maximum);
 MinionBar makeMinionBar( Position topLeft,  Position bottomLeft,  Position topRight,  Position bottomRight, float health);
 Pixel getPixel( ImageData imageData, int x, int y);
void setPixel( ImageData imageData, int x, int y, int r, int g, int b);
void drawRect( ImageData imageData, int left, int top, int width, int height, int r, int g, int b);
BOOL isPixelColor( Pixel pixel, unsigned char r, unsigned char g, unsigned char b, int tolerance);
BOOL isPixelPreciseColor( Pixel pixel, unsigned char r, unsigned char g, unsigned char b);
BOOL isColor(uint8_t *pixel, unsigned char r, unsigned char g, unsigned char b, int tolerance);
BOOL isColor2(uint8_t *pixel, uint8_t *pixel2, int tolerance);
 ImageData makeImageData(uint8_t * data, int imageWidth, int imageHeight);
ImageData makeImageDataFrom(NSString* path);

#endif /* defined(__Fluffy_Pug__Utility__) */
