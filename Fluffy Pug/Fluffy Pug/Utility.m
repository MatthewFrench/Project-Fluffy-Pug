//
//  Utility.c
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#include "Utility.h"

//Uses insane CPU for whatever reason
Position makePosition(int x, int y) {
     Position p;
    p.x = x;
    p.y = y;
    return p;
}

int getRandomInteger(int minimum, int maximum) {
    return arc4random_uniform((maximum - minimum) + 1) + minimum;
}

 MinionBar makeMinionBar( Position topLeft,  Position bottomLeft,  Position topRight,  Position bottomRight, float health) {
     MinionBar mb;
    mb.topLeft = topLeft; mb.bottomLeft = bottomLeft; mb.topRight = topRight; mb.bottomRight = bottomRight;
    mb.health = health;
    return mb;
}

 ImageData makeImageData(uint8_t * data, int width, int height) {
    
     ImageData imageData;
    
    //CGDataProviderRef provider = CGImageGetDataProvider(imageRef);
    //imageData.rawData = CGDataProviderCopyData(provider);
    //imageData.imageData = (UInt8 *) CFDataGetBytePtr(imageData.rawData);
    imageData.imageData = data;
    imageData.imageByteLength = width*height*4;//CFDataGetLength(rawData);
    imageData.imageWidth = width;
    imageData.imageHeight = height;
    //imageData.rect = imageSize;
    return imageData;
}

BOOL isColor(uint8_t *pixel, unsigned char r, unsigned char g, unsigned char b, int tolerance) {
    if (abs(pixel[2] - r) <= tolerance && abs(pixel[1] - g) <= tolerance && abs(pixel[0] - b) <= tolerance) {
        return true;
    }
    return false;
}

 BOOL isPixelColor( Pixel pixel, unsigned char r, unsigned char g, unsigned char b, int tolerance) {
    if (abs(pixel.r - r) <= tolerance && abs(pixel.g - g) <= tolerance && abs(pixel.b - b) <= tolerance) {
        return true;
    }
    return false;
}

 BOOL isPixelPreciseColor( Pixel pixel, unsigned char r, unsigned char g, unsigned char b) {
    if (pixel.r == r && pixel.g == g && pixel.b == b) {
        return true;
    }
    return false;
}
Pixel getPixel(struct ImageData imageData, int x, int y) {
    uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + x)*4;
    //int position = (y * imageData.imageWidth + x) * 4;
     Pixel p;
    if ((y * imageData.imageWidth + x) * 4+3 < imageData.imageByteLength) {
        //p.r = imageData.imageData[position + 2];
        //p.g = imageData.imageData[position + 1];
        //p.b = imageData.imageData[position + 0];
        p.r = pixel[2];
        p.g = pixel[1];
        p.b = pixel[0];
        p.exist = true;
    } else {
        p.exist = false;
    }
    return p;
}


 void setPixel( ImageData imageData, int x, int y, int r, int g, int b) {
    uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + x)*4;
    //int position = (y * imageData.imageWidth + x) * 4;
    if ((y * imageData.imageWidth + x) * 4+3 < imageData.imageByteLength) {
        pixel[2] = r;
        pixel[1] = g;
        pixel[0] = b;
        //imageData.imageData[position + 2] = r;
        //imageData.imageData[position + 1] = g;
        //imageData.imageData[position + 0] = b;
    }
}

 void drawRect( ImageData imageData, int left, int top, int width, int height, int r, int g, int b) {
    //Top and bottom
    for (int i = left; i < left+width; i++) {
        setPixel(imageData, i, top, r, g, b);
        setPixel(imageData, i, top+height, r, g, b);
    }
    //Left and right
    for (int i = top+1; i < top+height-1; i++) {
        setPixel(imageData, left, i, r, g, b);
        setPixel(imageData, left+width, i, r, g, b);
    }
}