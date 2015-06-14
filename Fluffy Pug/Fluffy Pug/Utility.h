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
    struct Position topLeft, topRight, bottomLeft, bottomRight, characterCenter;
    float health;
};

struct ChampionBar {
    struct Position topLeft, topRight, bottomLeft, bottomRight, characterCenter;
    float health;
};

struct TowerBar {
    struct Position topLeft, topRight, bottomLeft, bottomRight, towerCenter;
    float health;
};

inline Position makePosition(int x, int y);
inline int getRandomInteger(int minimum, int maximum);
inline  MinionBar makeMinionBar( Position topLeft,  Position bottomLeft,  Position topRight,  Position bottomRight, float health);
inline  Pixel getPixel( ImageData imageData, int x, int y);
inline  uint8_t* getPixel2( ImageData imageData, int x, int y);
inline void setPixel( ImageData imageData, int x, int y, int r, int g, int b);
inline void drawRect( ImageData imageData, int left, int top, int width, int height, int r, int g, int b);
inline BOOL isPixelColor( Pixel pixel, unsigned char r, unsigned char g, unsigned char b, int tolerance);
inline BOOL isPixelPreciseColor( Pixel pixel, unsigned char r, unsigned char g, unsigned char b);
inline BOOL isColor(uint8_t *pixel, unsigned char r, unsigned char g, unsigned char b, int tolerance);
inline BOOL isColor2(uint8_t *pixel, uint8_t *pixel2, int tolerance);
inline  ImageData makeImageData(uint8_t * data, int imageWidth, int imageHeight);
inline ImageData makeImageDataFrom(NSString* path);
inline BOOL detectImageAtPixel(uint8_t *pixel, int x, int y, int width, int height, ImageData image, int tolerance);
inline void normalizePoint(int &x, int &y, int length);
inline Position detectRelativeImageInImage(ImageData smallImage, ImageData largeImage, double percentageMatch, int xStart, int yStart, int xEnd, int yEnd);
inline double getColorPercentage(uint8_t *pixel, uint8_t *pixel2);
inline double getImageAtPixelPercentage(uint8_t *pixel, int x, int y, int width, int height, ImageData image);


extern inline Position detectRelativeImageInImage(ImageData smallImage, ImageData largeImage, double percentageMatch, int xStart, int yStart, int xEnd, int yEnd) {
    bool found = false;
    double highestPercent = 0.0;
    Position location;
    location.x = -1; location.y = -1;
    
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = getPixel2(largeImage, xStart, y);
        for (int x = xStart; x < xEnd; x++) {
            double percent = getImageAtPixelPercentage(pixel, x, y, largeImage.imageWidth, largeImage.imageHeight, smallImage);
            if (percent > highestPercent) {
                location.x = x; location.y = y;
                highestPercent = percent;
                if (highestPercent > percentageMatch) {
                    found = true;
                }
            } else if (percent < highestPercent) { //Skip ahead if not even a close match
                int skip = floor(smallImage.imageWidth*(1.0-percent)/2);
                x += skip;
                pixel += skip*4;
            }
            pixel += 4;
        }
    }
    NSLog(@"Highest match: %f at position %d %d", highestPercent, location.x, location.y);
    if (found) {
        return location;
    }
    return makePosition(-1,-1);
}

extern inline double getImageAtPixelPercentage(uint8_t *pixel, int x, int y, int width, int height, ImageData image) {
        if (width - x > image.imageWidth &&
            height - y > image.imageHeight) {
            double percentage = 0.0;
            uint8_t *pixel2 = image.imageData;
            for (int y1 = 0; y1 < image.imageHeight; y1++) {
                uint8_t *pixel1 = pixel + (y1 * width)*4;
                for (int x1 = 0; x1 < image.imageWidth; x1++) {
                    if (pixel2[3] != 0) {
                        percentage += getColorPercentage(pixel1, pixel2);
                    } else {
                        percentage += 1.0;
                    }
                    pixel2 += 4;
                    pixel1 += 4;
                }
            }
            return percentage / (image.imageWidth*image.imageHeight);
        }
    return 0.0;
}


extern inline double getColorPercentage(uint8_t *pixel, uint8_t *pixel2) {
    
    double r = 1.0 - ((double)abs(pixel[2] - pixel2[2]) /255.0);
    double g = 1.0 - ((double)abs(pixel[1] - pixel2[1]) /255.0);
    double b = 1.0 - ((double)abs(pixel[0] - pixel2[0]) /255.0);
    
    //NSLog(@"%d %d %d vs %d %d %d, match = %f", pixel[0], pixel[1], pixel[2], pixel2[0], pixel2[1], pixel2[2], (r+g+b)/3.0);
    return r*g*b;
}



extern inline void normalizePoint(int &x, int &y, int length) {
    double h = hypot(x, y);
    if(length != 0 && h != 0){
        x = x * (length/h);
        y = y * (length/h);
    }
}

extern inline BOOL detectImageAtPixel(uint8_t *pixel, int x, int y, int width, int height, ImageData image, int tolerance) {
    if (isColor2(pixel, image.imageData, tolerance) || image.imageData[3] == 0) {
        if (width - x > image.imageWidth &&
            height - y > image.imageHeight) {
            uint8_t *pixel2 = image.imageData;
            for (int y1 = 0; y1 < image.imageHeight; y1++) {
                uint8_t *pixel1 = pixel + (y1 * width)*4;
                for (int x1 = 0; x1 < image.imageWidth; x1++) {
                    if (!isColor2(pixel1, pixel2, tolerance) && pixel2[3] > 0) {
                        return false;
                    }
                    pixel2 += 4;
                    pixel1 += 4;
                }
            }
            return true;
        }
    }
    return false;
}

//Uses insane CPU for whatever reason
extern inline Position makePosition(int x, int y) {
    Position p;
    p.x = x;
    p.y = y;
    return p;
}

extern int getRandomInteger(int minimum, int maximum) {
    return arc4random_uniform((maximum - minimum) + 1) + minimum;
}

extern MinionBar makeMinionBar( Position topLeft,  Position bottomLeft,  Position topRight,  Position bottomRight, float health) {
    MinionBar mb;
    mb.topLeft = topLeft; mb.bottomLeft = bottomLeft; mb.topRight = topRight; mb.bottomRight = bottomRight;
    mb.health = health;
    return mb;
}

extern ImageData makeImageData(uint8_t * data, int width, int height) {
    ImageData imageData;
    imageData.imageData = data;
    imageData.imageByteLength = width*height*4;
    imageData.imageWidth = width;
    imageData.imageHeight = height;
    return imageData;
}

extern ImageData makeImageDataFrom(NSString* path) {
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
    NSBitmapImageRep* raw_img = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    UInt8* data = (UInt8*) calloc (image.size.width* image.size.height*4,sizeof(UInt8));
    UInt8* dataPointer = data;
    UInt8* originalData = [raw_img bitmapData];
    for (int i = 0; i < image.size.width * image.size.height; i++) {
        dataPointer[0] = originalData[2];
        dataPointer[1] = originalData[1];
        dataPointer[2] = originalData[0];
        dataPointer[3] = originalData[3];
        dataPointer += 4;
        originalData += 4;
    }
    ImageData imageData;
    imageData.imageData = data;
    imageData.imageByteLength = image.size.width* image.size.height*4;
    imageData.imageWidth = image.size.width;
    imageData.imageHeight = image.size.height;
    return imageData;
}

extern BOOL isColor2(uint8_t *pixel, uint8_t *pixel2, int tolerance) {
    //if (pixel[3] == 255 || pixel2[3] == 255) return true;
    if (abs(pixel[0] - pixel2[0]) <= tolerance && abs(pixel[1] - pixel2[1]) <= tolerance && abs(pixel[2] - pixel2[2]) <= tolerance) {
        return true;
    }
    return false;
}

extern BOOL isColor(uint8_t *pixel, unsigned char r, unsigned char g, unsigned char b, int tolerance) {
    //if (pixel[3] == 255) return true;
    if (abs(pixel[0] - b) <= tolerance && abs(pixel[1] - g) <= tolerance && abs(pixel[2] - r) <= tolerance) {
        return true;
    }
    return false;
}

extern BOOL isPixelColor( Pixel pixel, unsigned char r, unsigned char g, unsigned char b, int tolerance) {
    if (abs(pixel.r - r) <= tolerance && abs(pixel.g - g) <= tolerance && abs(pixel.b - b) <= tolerance) {
        return true;
    }
    return false;
}

extern BOOL isPixelPreciseColor( Pixel pixel, unsigned char r, unsigned char g, unsigned char b) {
    if (pixel.r == r && pixel.g == g && pixel.b == b) {
        return true;
    }
    return false;
}
extern Pixel getPixel(struct ImageData imageData, int x, int y) {
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

extern uint8_t* getPixel2(struct ImageData imageData, int x, int y) {
    uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + x)*4;
    return pixel;
}


extern void setPixel( ImageData imageData, int x, int y, int r, int g, int b) {
    uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + x)*4;
    if ((y * imageData.imageWidth + x) * 4+3 < imageData.imageByteLength) {
        pixel[2] = r;
        pixel[1] = g;
        pixel[0] = b;
    }
}

extern void drawRect( ImageData imageData, int left, int top, int width, int height, int r, int g, int b) {
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

#endif /* defined(__Fluffy_Pug__Utility__) */
