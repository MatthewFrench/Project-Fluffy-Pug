//
//  Utility.c
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#include "Utility.h"

struct Position makePosition(int x, int y) {
    struct Position p;
    p.x = x;
    p.y = y;
    return p;
}

int getRandomInteger(int minimum, int maximum) {
    return arc4random_uniform((maximum - minimum) + 1) + minimum;
}

struct MinionBar makeMinionBar(struct Position topLeft, struct Position bottomLeft, struct Position topRight, struct Position bottomRight, float health) {
    struct MinionBar mb;
    mb.topLeft = topLeft; mb.bottomLeft = bottomLeft; mb.topRight = topRight; mb.bottomRight = bottomRight;
    mb.health = health;
    return mb;
}

struct ImageData makeImageData(CGImageRef imageRef, CGRect imageSize) {
    
    struct ImageData imageData;
    
    CGDataProviderRef provider = CGImageGetDataProvider(imageRef);
    imageData.rawData = CGDataProviderCopyData(provider);
    imageData.imageData = (UInt8 *) CFDataGetBytePtr(imageData.rawData);
    imageData.imageByteLength = imageSize.size.width*imageSize.size.height*4;//CFDataGetLength(rawData);
    imageData.rect = imageSize;
    
    return imageData;
}

inline BOOL isColor(struct Pixel pixel, unsigned char r, unsigned char g, unsigned char b, int tolerance) {
    if (abs(pixel.r - r) <= tolerance && abs(pixel.g - g) <= tolerance && abs(pixel.b - b) <= tolerance) {
        return true;
    }
    return false;
}

inline BOOL isPreciseColor(struct Pixel pixel, unsigned char r, unsigned char g, unsigned char b) {
    if (pixel.r == r && pixel.g == g && pixel.b == b) {
        return true;
    }
    return false;
}

inline struct Pixel getPixel(struct ImageData imageData, int x, int y) {
    int position = (y * imageData.rect.size.width + x) * 4;
    struct Pixel p;
    if (position+3 < imageData.imageByteLength) {
        p.r = imageData.imageData[position+2];
        p.g = imageData.imageData[position+1];
        p.b = imageData.imageData[position+0];
        p.exist = true;
    } else {
        p.exist = false;
        //NSLog(@"Pixel does not exist");
    }
    return p;
}