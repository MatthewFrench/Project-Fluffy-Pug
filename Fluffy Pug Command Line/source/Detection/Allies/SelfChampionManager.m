//
//  SelfChampionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "SelfChampionManager.h"

//static int Debug_Draw_Red = 0, Debug_Draw_Green = 255, Debug_Draw_Blue = 255;
//static int Health_Bar_Width = 104, Health_Bar_Height = 9;

ImageData SelfChampionManager::topLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Self Health Bar/Top Left Corner" ofType:@"png"]);

ImageData SelfChampionManager::bottomLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Self Health Bar/Bottom Left Corner" ofType:@"png"]);
ImageData SelfChampionManager::bottomRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Self Health Bar/Bottom Right Corner" ofType:@"png"]);
ImageData SelfChampionManager::topRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Self Health Bar/Top Right Corner" ofType:@"png"]);
ImageData SelfChampionManager::healthSegmentImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Self Health Bar/Health Segment" ofType:@"png"]);
ImageData SelfChampionManager::bottomBarLeftSideImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Self Health Bar/Bottom Bar Left Side" ofType:@"png"]);
ImageData SelfChampionManager::bottomBarRightSideImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Self Health Bar/Bottom Bar Right Side" ofType:@"png"]);
ImageData SelfChampionManager::bottomBarAverageHealthColorImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Self Health Bar/Bottom Bar Average Health Color" ofType:@"png"]);

SelfChampionManager::SelfChampionManager () {
    //championBars = [NSMutableArray new];
    //topRightDetect = [NSMutableArray new];
    //topLeftDetect = [NSMutableArray new];
    //bottomRightDetect = [NSMutableArray new];
    //bottomLeftDetect = [NSMutableArray new];
    
    //needsFullScreenUpdate = true;
    //fullScreenUpdateTime = clock();
    //lastUpdateTime = clock();
}
/*
 Image locations relative to top left:
 Top Left: 0, 0
 Bottom left: 0, 11
 Top Right: 106, 0
 Bottom Right: 106, 11
 
 Health Bar Exact Location Relative to Images:
 Top Left: 3, 3
 Bottom left: 3, 12
 Top Right: 107, 3
 Bottom Right: 107, 12
 
 */
const float SelfHealthBarMaxPercent = 0.75;
const int SelfHealthBarHeight = 12;
const int SelfHealthBarWidth = 293;
SelfHealth* SelfChampionManager::detectSelfHealthBarAtPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
    SelfHealth* healthBar = nil;
    
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomBarLeftSideImageData, SelfHealthBarMaxPercent) >=  SelfHealthBarMaxPercent) {
        int barTopLeftX = x + 15;
        int barTopLeftY = y + 3;
        healthBar = [SelfHealth new];
        healthBar->topLeft.x = barTopLeftX;
        healthBar->topLeft.y = barTopLeftY;
        healthBar->bottomLeft.x = barTopLeftX;
        healthBar->bottomLeft.y = barTopLeftY + SelfHealthBarHeight;
        healthBar->topRight.x = barTopLeftX + SelfHealthBarWidth;
        healthBar->topRight.y = barTopLeftY;
        healthBar->bottomRight.x = barTopLeftX + SelfHealthBarWidth;
        healthBar->bottomRight.y = barTopLeftY + SelfHealthBarHeight;
        healthBar->detectedLeftSide = true;
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomBarRightSideImageData, SelfHealthBarMaxPercent) >=  SelfHealthBarMaxPercent) {
        int barTopLeftX = x - SelfHealthBarWidth;
        int barTopLeftY = y + 3;
        healthBar = [SelfHealth new];
        healthBar->topLeft.x = barTopLeftX;
        healthBar->topLeft.y = barTopLeftY;
        healthBar->bottomLeft.x = barTopLeftX;
        healthBar->bottomLeft.y = barTopLeftY + SelfHealthBarHeight;
        healthBar->topRight.x = barTopLeftX + SelfHealthBarWidth;
        healthBar->topRight.y = barTopLeftY;
        healthBar->bottomRight.x = barTopLeftX + SelfHealthBarWidth;
        healthBar->bottomRight.y = barTopLeftY + SelfHealthBarHeight;
        healthBar->detectedRightSide = true;
    }
    
    return healthBar;
}


Champion* SelfChampionManager::detectChampionBarAtPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
    Champion* champ = nil;
    //Look top left corner
    
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topLeftImageData, 0.85) >=  0.85) {
        int barTopLeftX = x + 3;
        int barTopLeftY = y + 3;
        champ = [Champion new];
        champ->topLeft.x = barTopLeftX;
        champ->topLeft.y = barTopLeftY;
        champ->bottomLeft.x = barTopLeftX;
        champ->bottomLeft.y = barTopLeftY + 9;
        champ->topRight.x = barTopLeftX + 104;
        champ->topRight.y = barTopLeftY;
        champ->bottomRight.x = barTopLeftX + 104;
        champ->bottomRight.y = barTopLeftY + 9;
        champ->detectedTopLeft = true;
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomLeftImageData, 0.85) >=  0.85) { // Look for bottom left corner
        int barTopLeftX = x + 3;
        int barTopLeftY = y - 8;
        champ = [Champion new];
        champ->topLeft.x = barTopLeftX;
        champ->topLeft.y = barTopLeftY;
        champ->bottomLeft.x = barTopLeftX;
        champ->bottomLeft.y = barTopLeftY + 9;
        champ->topRight.x = barTopLeftX + 104;
        champ->topRight.y = barTopLeftY;
        champ->bottomRight.x = barTopLeftX + 104;
        champ->bottomRight.y = barTopLeftY + 9;
        champ->detectedBottomLeft = true;
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topRightImageData, 0.85) >=  0.85) { // Look for top right corner
        int barTopLeftX = x - 101 - 2;
        int barTopLeftY = y + 3;
        champ = [Champion new];
        champ->topLeft.x = barTopLeftX;
        champ->topLeft.y = barTopLeftY;
        champ->bottomLeft.x = barTopLeftX;
        champ->bottomLeft.y = barTopLeftY + 9;
        champ->topRight.x = barTopLeftX + 104;
        champ->topRight.y = barTopLeftY;
        champ->bottomRight.x = barTopLeftX + 104;
        champ->bottomRight.y = barTopLeftY + 9;
        champ->detectedTopRight = true;
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomRightImageData, 0.85) >=  0.85) { // Look for bottom right corner
        int barTopLeftX = x - 101 - 2;
        int barTopLeftY = y - 8;
        champ = [Champion new];
        champ->topLeft.x = barTopLeftX;
        champ->topLeft.y = barTopLeftY;
        champ->bottomLeft.x = barTopLeftX;
        champ->bottomLeft.y = barTopLeftY + 9;
        champ->topRight.x = barTopLeftX + 104;
        champ->topRight.y = barTopLeftY;
        champ->bottomRight.x = barTopLeftX + 104;
        champ->bottomRight.y = barTopLeftY + 9;
        champ->detectedBottomRight = true;
    }
    //if (x == 364 + 101 + 2 && y == 310 - 3) {
    //    NSLog(@"Top Right corner test: %f", getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topRightImageData, 0.5));
    //}
    return champ;
}

//To Validate, at least 2 corners need detected then we detect the health percentage
NSMutableArray* SelfChampionManager::validateChampionBars(ImageData imageData, NSMutableArray* detectedChampionBars) {
    NSMutableArray* championBars = [NSMutableArray new];
    
    while ([detectedChampionBars count] > 0) {
        Champion* champ = [detectedChampionBars lastObject];
        [detectedChampionBars removeLastObject];
        int detectedCorners = 1;
        for (int i = 0; i < [detectedChampionBars count]; i++) {
            Champion * champ2 = [detectedChampionBars objectAtIndex:i];
            if (champ2->topLeft.x == champ->topLeft.x && champ->topLeft.y == champ2-> topLeft.y) {
                [detectedChampionBars removeObjectAtIndex:i];
                i--;
                if (champ2->detectedBottomLeft) champ->detectedBottomLeft = true;
                if (champ2->detectedBottomRight) champ->detectedBottomRight = true;
                if (champ2->detectedTopLeft) champ->detectedTopLeft = true;
                if (champ2->detectedTopRight) champ->detectedTopRight = true;
                detectedCorners++;
            }
        }
        if (detectedCorners > 1) {
            champ->characterCenter.x = champ->topLeft.x+66; champ->characterCenter.y = champ->topLeft.y+104;
            [championBars addObject: champ];
        }// else {
        //    delete champ;
        //}
    }
    
    //Detect health
    for (int i = 0; i < [championBars count]; i++) {
        Champion* champ = [championBars objectAtIndex:i];
        champ->health = 0;
        for (int x = 103; x >= 0; x--) {
            if (x + champ->topLeft.x >= 0 && x + champ->topLeft.x < imageData.imageWidth &&
                champ->topLeft.y >= 0 && champ->topLeft.y < imageData.imageHeight) {
                if ( getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, champ->topLeft.x + x, champ->topLeft.y), champ->topLeft.x + x, champ->topLeft.y, imageData.imageWidth, imageData.imageHeight, healthSegmentImageData, 0.9) >=  0.9) {
                    champ->health = (float)x / 103.0 * 100;
                    break;
                }
            }
        }
        
        
        if (champ->health == 0) {
            [championBars removeObjectAtIndex: i];
            i--;
        }
    }
    
    return championBars;
}

//To Validate, at least 2 sides need detected then we detect the health percentage
NSMutableArray* SelfChampionManager::validateSelfHealthBars(ImageData imageData, NSMutableArray* detectedHealthBars) {
    NSMutableArray* healthBars = [NSMutableArray new];
    
    while ([detectedHealthBars count] > 0) {
        SelfHealth* healthBar = [detectedHealthBars lastObject];
        [detectedHealthBars removeLastObject];
        int detectedSides = 1;
        for (int i = 0; i < [detectedHealthBars count]; i++) {
            SelfHealth * healthBar2 = [detectedHealthBars objectAtIndex:i];
            if (healthBar2->topLeft.x == healthBar->topLeft.x && healthBar->topLeft.y == healthBar2-> topLeft.y) {
                [detectedHealthBars removeObjectAtIndex:i];
                i--;
                if (healthBar2->detectedLeftSide) healthBar->detectedLeftSide = true;
                if (healthBar2->detectedRightSide) healthBar->detectedRightSide = true;
                detectedSides++;
            }
        }
        //if (detectedSides > 1) {
        [healthBars addObject: healthBar];
        //}
    }
    
    //Detect health
    for (int i = 0; i < [healthBars count]; i++) {
        SelfHealth* healthBar = [healthBars objectAtIndex:i];
        healthBar->health = 0;
        uint8_t* healthColorPixel = getPixel2(bottomBarAverageHealthColorImageData, 0, 0);
        for (int x = healthBar->topLeft.x + SelfHealthBarWidth - 1; x >= healthBar->topLeft.x; x--) {
            for (int y = healthBar->topRight.y; y < healthBar->bottomRight.y; y++) {
                if (x >= 0 && x < imageData.imageWidth &&
                    y >= 0 && y < imageData.imageHeight) {
                    if (getColorPercentage(healthColorPixel, getPixel2(imageData, x, y)) >= 0.55) {
                        healthBar->health = (float)(x - healthBar->topLeft.x) / (SelfHealthBarWidth - 1.0) * 100.0;
                        y = healthBar->bottomRight.y+1;
                        x = healthBar->topLeft.x - 1;
                    }
                }
            }
        }
    }
    
    return healthBars;
}