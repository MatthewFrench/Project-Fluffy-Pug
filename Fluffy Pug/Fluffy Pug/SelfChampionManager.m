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
SelfHealthBar* SelfChampionManager::detectSelfHealthBarAtPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
    SelfHealthBar* healthBar = nil;
    
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomBarLeftSideImageData, 0.95) >=  0.95) {
        int barTopLeftX = x + 15;
        int barTopLeftY = y + 2;
        healthBar = new SelfHealthBar();
        healthBar->topLeft.x = barTopLeftX;
        healthBar->topLeft.y = barTopLeftY;
        healthBar->bottomLeft.x = barTopLeftX;
        healthBar->bottomLeft.y = barTopLeftY + 12;
        healthBar->topRight.x = barTopLeftX + 306;
        healthBar->topRight.y = barTopLeftY;
        healthBar->bottomRight.x = barTopLeftX + 306;
        healthBar->bottomRight.y = barTopLeftY + 12;
        healthBar->detectedLeftSide = true;
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomBarRightSideImageData, 0.95) >=  0.95) {
        int barTopLeftX = x - 306;
        int barTopLeftY = y + 2;
        healthBar = new SelfHealthBar();
        healthBar->topLeft.x = barTopLeftX;
        healthBar->topLeft.y = barTopLeftY;
        healthBar->bottomLeft.x = barTopLeftX;
        healthBar->bottomLeft.y = barTopLeftY + 12;
        healthBar->topRight.x = barTopLeftX + 306;
        healthBar->topRight.y = barTopLeftY;
        healthBar->bottomRight.x = barTopLeftX + 306;
        healthBar->bottomRight.y = barTopLeftY + 12;
        healthBar->detectedRightSide = true;
    }
    
    return healthBar;
}


ChampionBar* SelfChampionManager::detectChampionBarAtPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
    ChampionBar* champ = nil;
    //Look top left corner
    
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topLeftImageData, 0.95) >=  0.95) {
        int barTopLeftX = x + 3;
        int barTopLeftY = y + 3;
        champ = new ChampionBar();
        champ->topLeft.x = barTopLeftX;
        champ->topLeft.y = barTopLeftY;
        champ->bottomLeft.x = barTopLeftX;
        champ->bottomLeft.y = barTopLeftY + 9;
        champ->topRight.x = barTopLeftX + 104;
        champ->topRight.y = barTopLeftY;
        champ->bottomRight.x = barTopLeftX + 104;
        champ->bottomRight.y = barTopLeftY + 9;
        champ->detectedTopLeft = true;
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomLeftImageData, 0.95) >=  0.95) { // Look for bottom left corner
        champ = new ChampionBar();
        int barTopLeftX = x + 3;
        int barTopLeftY = y - 8;
        champ = new ChampionBar();
        champ->topLeft.x = barTopLeftX;
        champ->topLeft.y = barTopLeftY;
        champ->bottomLeft.x = barTopLeftX;
        champ->bottomLeft.y = barTopLeftY + 9;
        champ->topRight.x = barTopLeftX + 104;
        champ->topRight.y = barTopLeftY;
        champ->bottomRight.x = barTopLeftX + 104;
        champ->bottomRight.y = barTopLeftY + 9;
        champ->detectedBottomLeft = true;
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topRightImageData, 0.95) >=  0.95) { // Look for top right corner
        champ = new ChampionBar();
        int barTopLeftX = x - 101 - 2;
        int barTopLeftY = y + 3;
        champ = new ChampionBar();
        champ->topLeft.x = barTopLeftX;
        champ->topLeft.y = barTopLeftY;
        champ->bottomLeft.x = barTopLeftX;
        champ->bottomLeft.y = barTopLeftY + 9;
        champ->topRight.x = barTopLeftX + 104;
        champ->topRight.y = barTopLeftY;
        champ->bottomRight.x = barTopLeftX + 104;
        champ->bottomRight.y = barTopLeftY + 9;
        champ->detectedTopRight = true;
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomRightImageData, 0.95) >=  0.95) { // Look for bottom right corner
        champ = new ChampionBar();
        int barTopLeftX = x - 101 - 2;
        int barTopLeftY = y - 8;
        champ = new ChampionBar();
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
        ChampionBar* champ = (ChampionBar*)[[detectedChampionBars lastObject] pointerValue];
        [detectedChampionBars removeLastObject];
        int detectedCorners = 1;
        for (int i = 0; i < [detectedChampionBars count]; i++) {
            ChampionBar * champ2 = (ChampionBar*)[[detectedChampionBars objectAtIndex:i] pointerValue];
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
            [championBars addObject: [NSValue valueWithPointer:champ]];
        }
    }
    
    //Detect health
    for (int i = 0; i < [championBars count]; i++) {
        ChampionBar* champ = (ChampionBar*)[[championBars objectAtIndex:i] pointerValue];
        champ->health = 0;
        for (int x = 103; x >= 0; x--) {
            if ( getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, champ->topLeft.x + x, champ->topLeft.y), champ->topLeft.x + x, champ->topLeft.y, imageData.imageWidth, imageData.imageHeight, healthSegmentImageData, 0.9) >=  0.9) {
                champ->health = (float)x / 103.0 * 100;
                break;
            }
        }
    }
    
    return championBars;
}

//To Validate, at least 2 sides need detected then we detect the health percentage
NSMutableArray* SelfChampionManager::validateSelfHealthBars(ImageData imageData, NSMutableArray* detectedHealthBars) {
    NSMutableArray* healthBars = [NSMutableArray new];
    
    while ([detectedHealthBars count] > 0) {
        SelfHealthBar* healthBar = (SelfHealthBar*)[[detectedHealthBars lastObject] pointerValue];
        [detectedHealthBars removeLastObject];
        int detectedSides = 1;
        for (int i = 0; i < [detectedHealthBars count]; i++) {
            SelfHealthBar * healthBar2 = (SelfHealthBar*)[[detectedHealthBars objectAtIndex:i] pointerValue];
            if (healthBar2->topLeft.x == healthBar->topLeft.x && healthBar->topLeft.y == healthBar2-> topLeft.y) {
                [detectedHealthBars removeObjectAtIndex:i];
                i--;
                if (healthBar2->detectedLeftSide) healthBar->detectedLeftSide = true;
                if (healthBar2->detectedRightSide) healthBar->detectedRightSide = true;
                detectedSides++;
            }
        }
        if (detectedSides > 1) {
            [healthBars addObject: [NSValue valueWithPointer:healthBar]];
        }
    }
    
    //Detect health
    for (int i = 0; i < [healthBars count]; i++) {
        SelfHealthBar* healthBar = (SelfHealthBar*)[[healthBars objectAtIndex:i] pointerValue];
        healthBar->health = 0;
        uint8_t* healthColorPixel = getPixel2(bottomBarAverageHealthColorImageData, 0, 0);
        for (int x = healthBar->topLeft.x + 305; x >= healthBar->topLeft.x; x--) {
            for (int y = healthBar->topRight.y; y <= healthBar->bottomRight.y; y++) {
                if (getColorPercentage(healthColorPixel, getPixel2(imageData, x, y)) >= 0.55) {
                    healthBar->health = (float)(x - healthBar->topLeft.x) / 305.0 * 100;
                    y = healthBar->bottomRight.y+1;
                    x = healthBar->topLeft.x - 1;
                }
            }
        }
    }
    
    return healthBars;
}

/*
void SelfChampionManager::debugDraw(ImageData imageData) {
    for (int i = 0; i < [championBars count]; i++) {
        ChampionBar mb;
        [[championBars objectAtIndex:i] getValue:&mb];
        drawRect(imageData, mb.topLeft.x, mb.topLeft.y, 104, 9, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
    }*/
    /*
     for (int i = 0; i < [topLeftDetect count]; i++) {
     struct Position p;
     [[topLeftDetect objectAtIndex:i] getValue:&p];
     drawRect(imageData, p.x, p.y, 4, 4, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
     }
     for (int i = 0; i < [topRightDetect count]; i++) {
     struct Position p;
     [[topRightDetect objectAtIndex:i] getValue:&p];
     drawRect(imageData, p.x, p.y, 4, 4, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
     }
     for (int i = 0; i < [bottomLeftDetect count]; i++) {
     struct Position p;
     [[bottomLeftDetect objectAtIndex:i] getValue:&p];
     drawRect(imageData, p.x, p.y, 4, 4, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
     }
     for (int i = 0; i < [bottomRightDetect count]; i++) {
     struct Position p;
     [[bottomRightDetect objectAtIndex:i] getValue:&p];
     drawRect(imageData, p.x, p.y, 4, 4, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
     }*/
//}
/*
void SelfChampionManager::processImage(ImageData imageData) {
    double delta = (clock() - lastUpdateTime)/CLOCKS_PER_SEC;
    lastUpdateTime = clock();
    double lastFullScreenUpdate = (clock() - fullScreenUpdateTime)/CLOCKS_PER_SEC;
    if (lastFullScreenUpdate >= 0.94) { //It's been a whole second, scan the screen
        fullScreenUpdateTime = clock();
        needsFullScreenUpdate = true;
    }
    
    //Clear all corners
    [topRightDetect removeAllObjects];
    [topLeftDetect removeAllObjects];
    [bottomRightDetect removeAllObjects];
    [bottomLeftDetect removeAllObjects];
    
    if (needsFullScreenUpdate) { //Scan full screen
        needsFullScreenUpdate = false;
        scanSection( imageData, 0, 0, imageData.imageWidth, imageData.imageHeight);
    } else {
        //Scan only where we last saw enemy champions
        for (int i = 0; i < [championBars count]; i++) {
            ChampionBar cb;
            NSValue* value = [championBars objectAtIndex:i];
            [value getValue:&cb];
            //Assume a certain speed per second for champions
            int xStart = cb.topLeft.x - delta*championSpeed - 5;
            int yStart = cb.topLeft.y - delta*championSpeed - 5;
            int xEnd = cb.bottomRight.x + delta*championSpeed + 5;
            int yEnd = cb.bottomRight.y + delta*championSpeed + 5;
            if (xStart < 0) xStart = 0;
            if (yStart < 0) yStart = 0;
            if (xEnd > imageData.imageWidth) xEnd = imageData.imageWidth;
            if (yEnd > imageData.imageHeight) yEnd = imageData.imageHeight;
            scanSection( imageData, xStart, yStart, xEnd, yEnd);
        }
    }
    [championBars removeAllObjects];
    //Take the scanned corners and get champion data
    processChampionsLocations();
    processChampionsHealth( imageData);
}*/
/*
void SelfChampionManager::scanSection(ImageData imageData, int xStart, int yStart, int xEnd, int yEnd) {
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = getPixel2(imageData, xStart, y);
        
        for (int x = xStart; x < xEnd; x++) {
            processPixel( imageData, pixel, x, y);
            
            pixel += 4;
        }
    }
}*/
/*
void SelfChampionManager::processChampionsLocations() {
    processTopLeftDetect();
    processTopRightDetect();
    processBottomLeftDetect();
    processBottomRightDetect();
    //Do center location
    for (int i = 0; i < [championBars count]; i++) {
        ChampionBar cb;
        [[championBars objectAtIndex:i] getValue:&cb];
        cb.characterCenter = makePosition(cb.topLeft.x+66, cb.topLeft.y+104);
        [championBars replaceObjectAtIndex:i withObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
    }
}*/
/*
void SelfChampionManager::processChampionsHealth(ImageData imageData) {
    for (int i = 0; i < [championBars count]; i++) {
        ChampionBar cb;
        [[championBars objectAtIndex:i] getValue:&cb];
        cb.health = 0;
        for (int x = Health_Bar_Width; x > 0; x--) {
            
            //Use health segment image and go from up to down
            for (int y = 0; y < healthSegmentImageData.imageHeight; y++) {
                uint8_t *healthPixel = getPixel2(healthSegmentImageData, 0, y);
                
                int pixelX =cb.topLeft.x + x - 1;
                int pixelY =cb.topLeft.y + y;
                if (pixelY < imageData.imageHeight && pixelX < imageData.imageWidth && pixelX >= 0 && pixelY >= 0) {
                    uint8_t *pixel = getPixel2(imageData, pixelX, pixelY);
                    if (colorInPercentage(healthPixel, pixel, 0.85)) {
                        cb.health = (float)x / Health_Bar_Width * 100;
                        x = 0;
                        break;
                    }
                }
            }
            
            
        }
        //NSLog(@"Champion health: %f", cb.health);
        [championBars replaceObjectAtIndex:i withObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
    }
}*/


/*
void SelfChampionManager::processPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
    //Detect top left bar
    if (detectImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topLeftImageData, 0.7)) {
        Position p;p.x=x;p.y=y;
        //Add if not detected
        if (!containsPosition(topLeftDetect, p)) {
            //NSLog(@"Top left: %d %d", p.x, p.y);
            [topLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect bottom left bar
    if (detectImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomLeftImageData, 0.7)) {
        Position p;p.x=x;p.y=y;
        if (!containsPosition(bottomLeftDetect, p)) {
            //NSLog(@"Bottom left: %d %d", p.x, p.y);
            [bottomLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect top right bar
    if (detectImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight,topRightImageData, 0.7)) {
        Position p;p.x=x;p.y=y;
        if (!containsPosition(topRightDetect, p)) {
            //NSLog(@"Top Right: %d %d", p.x, p.y);
            [topRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect bottom right bar
    if (detectImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight,bottomRightImageData, 0.7)) {
        Position p;p.x=x;p.y=y+1;
        if (!containsPosition(bottomRightDetect, p)) {
            //NSLog(@"Bottom Right: %d %d", p.x, p.y);
            [bottomRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
}*/
/*
bool SelfChampionManager::containsPosition(NSMutableArray* array, Position p) {
    for (int i = 0; i < [array count]; i++) {
        Position p2;
        [[array objectAtIndex:i] getValue:&p2];
        if (p2.x == p.x && p2.y == p.y) {
            return true;
        }
    }
    return false;
}*/
/*
void SelfChampionManager::processTopLeftDetect() {
    while ([topLeftDetect count] > 0) {
        int corners = 0;
        Position p;
        [[topLeftDetect lastObject] getValue:&p];
        [topLeftDetect removeLastObject];
        //Remove top right corner
        for (int i = 0; i < [topRightDetect count]; i++) {
            Position p2;
            [[topRightDetect objectAtIndex:i] getValue:&p2];
            if (p2.y == p.y && p2.x-p.x > Health_Bar_Width-10 && p2.x-p.x < Health_Bar_Width+10) {//Approx
                [topRightDetect removeObjectAtIndex:i];
                corners++;
                break;
            }
        }
        //Remove bottom left corner
        for (int i = 0; i < [bottomLeftDetect count]; i++) {
            Position p2;
            [[bottomLeftDetect objectAtIndex:i] getValue:&p2];
            if (p2.x == p.x && p2.y-p.y > Health_Bar_Height-10 && p2.y-p.y < Health_Bar_Height+10) {//Approx
                [bottomLeftDetect removeObjectAtIndex:i];
                corners++;
                break;
            }
        }
        //Remove bottom right corner
        for (int i = 0; i < [bottomRightDetect count]; i++) {
            Position p2;
            [[bottomRightDetect objectAtIndex:i] getValue:&p2];
            if (p2.x-p.x > Health_Bar_Width-10 && p2.x-p.x < Health_Bar_Width+10 && p2.y-p.y > Health_Bar_Height-10 && p2.y-p.y < Health_Bar_Height+10) {//Approx
                [bottomRightDetect removeObjectAtIndex:i];
                corners++;
                break;
            }
        }
        //Now add champion bar
        if (corners > 0) {
            ChampionBar cb;
            cb.topLeft = makePosition(p.x + 3, p.y + 3);
            cb.topRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y);
            cb.bottomLeft = makePosition(cb.topLeft.x, cb.topLeft.y + Health_Bar_Height);
            cb.bottomRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y + Health_Bar_Height);
            [championBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
            //NSLog(@"Found enemy champion with corners: %d at position: %d, %d", corners, cb.topLeft.x, cb.topLeft.y);
        }
    }
}

void SelfChampionManager::processBottomRightDetect() {
    while ([bottomRightDetect count] > 0) {
        int corners = 0;
        Position p;
        [[bottomRightDetect lastObject] getValue:&p];
        [bottomRightDetect removeLastObject];
        //Remove top right corner
        for (int i = 0; i < [topRightDetect count]; i++) {
            Position p2;
            [[topRightDetect objectAtIndex:i] getValue:&p2];
            if (p2.x == p.x && p.y-p2.y > Health_Bar_Height-10 && p.y-p2.y < Health_Bar_Height+10) {//Approx
                [topRightDetect removeObjectAtIndex:i];
                corners++;
                break;
            }
        }
        //Remove bottom left corner
        for (int i = 0; i < [bottomLeftDetect count]; i++) {
            Position p2;
            [[bottomLeftDetect objectAtIndex:i] getValue:&p2];
            if (p2.y == p.y && p.x-p2.x > Health_Bar_Width-10 && p.x-p2.x < Health_Bar_Width+10) {//Approx
                [bottomLeftDetect removeObjectAtIndex:i];
                corners++;
                break;
            }
        }
        //Remove top left corner
        for (int i = 0; i < [topLeftDetect count]; i++) {
            Position p2;
            [[topLeftDetect objectAtIndex:i] getValue:&p2];
            if (p.x-p2.x > Health_Bar_Width-10 && p.x-p2.x < Health_Bar_Width+10 && p.y-p2.y > Health_Bar_Height-10 && p.y-p2.y < Health_Bar_Height+10) {//Approx
                [topLeftDetect removeObjectAtIndex:i];
                corners++;
                break;
            }
        }
        //Now add champion bar
        if (corners > 0) {
            ChampionBar cb;
            cb.bottomRight = makePosition(p.x + 1, p.y + 1);
            cb.topLeft = makePosition(cb.bottomRight.x - Health_Bar_Width, cb.bottomRight.y - Health_Bar_Height);
            cb.topRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y);
            cb.bottomLeft = makePosition(cb.topLeft.x, cb.topLeft.y + Health_Bar_Height);
            [championBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
            //NSLog(@"Found enemy champion with corners: %d at position: %d, %d", corners, cb.topLeft.x, cb.topLeft.y);
        }
    }
}

void SelfChampionManager::processBottomLeftDetect() {
    while ([bottomLeftDetect count] > 0) {
        int corners = 0;
        Position p;
        [[bottomLeftDetect lastObject] getValue:&p];
        [bottomLeftDetect removeLastObject];
        //Remove top right corner
        for (int i = 0; i < [topRightDetect count]; i++) {
            Position p2;
            [[topRightDetect objectAtIndex:i] getValue:&p2];
            if (p.y-p2.y > Health_Bar_Height-10 && p.y-p2.y < Health_Bar_Height+10 && p2.x-p.x > Health_Bar_Width-10 && p2.x-p.x < Health_Bar_Width+10) {//Approx
                [topRightDetect removeObjectAtIndex:i];
                corners++;
                break;
            }
        }
        //Remove bottom left corner
        for (int i = 0; i < [topLeftDetect count]; i++) {
            Position p2;
            [[topLeftDetect objectAtIndex:i] getValue:&p2];
            if (p2.x == p.x && p.y-p2.y > Health_Bar_Height-10 && p.y-p2.y < Health_Bar_Height+10) {//Approx
                [topLeftDetect removeObjectAtIndex:i];
                corners++;
                break;
            }
        }
        //Remove bottom right corner
        for (int i = 0; i < [bottomRightDetect count]; i++) {
            Position p2;
            [[bottomRightDetect objectAtIndex:i] getValue:&p2];
            if (p2.x-p.x > Health_Bar_Width - 10 && p2.x-p.x < Health_Bar_Width+10 && p2.y == p.y) {//Approx
                [bottomRightDetect removeObjectAtIndex:i];
                corners++;
                break;
            }
        }
        //Now add champion bar
        if (corners > 0) {
            ChampionBar cb;
            cb.bottomLeft = makePosition(p.x + 3, p.y + 1);
            cb.topLeft = makePosition(cb.bottomLeft.x, cb.bottomLeft.y - Health_Bar_Height);
            cb.topRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y);
            cb.bottomRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y + Health_Bar_Height);
            [championBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
            //NSLog(@"Found enemy champion with corners: %d at position: %d, %d", corners, cb.topLeft.x, cb.topLeft.y);
        }
    }
}
void SelfChampionManager::processTopRightDetect() {
    while ([topRightDetect count] > 0) {
        int corners = 0;
        Position p;
        [[topRightDetect lastObject] getValue:&p];
        [topRightDetect removeLastObject];
        //Remove top left corner
        for (int i = 0; i < [topLeftDetect count]; i++) {
            Position p2;
            [[topLeftDetect objectAtIndex:i] getValue:&p2];
            if (p2.y == p.y && p2.x-p.x < -(Health_Bar_Width-10) && p2.x-p.x > -(Health_Bar_Width+10)) {//Approx
                [topLeftDetect removeObjectAtIndex:i];
                corners++;
                break;
            }
        }
        //Remove bottom left corner
        for (int i = 0; i < [bottomLeftDetect count]; i++) {
            Position p2;
            [[bottomLeftDetect objectAtIndex:i] getValue:&p2];
            if (p2.x-p.x < -(Health_Bar_Width-10) && p2.x-p.x > -(Health_Bar_Width+10) && p2.y-p.y > Health_Bar_Height-10 && p2.y-p.y < Health_Bar_Height+10) {//Approx
                [bottomLeftDetect removeObjectAtIndex:i];
                corners++;
                break;
            }
        }
        //Remove bottom right corner
        for (int i = 0; i < [bottomRightDetect count]; i++) {
            Position p2;
            [[bottomRightDetect objectAtIndex:i] getValue:&p2];
            if (p2.x == p.x && p2.y-p.y > Health_Bar_Height-10 && p2.y-p.y < Health_Bar_Height+10) {//Approx
                [bottomRightDetect removeObjectAtIndex:i];
                corners++;
                break;
            }
        }
        //Now add champion bar
        if (corners > 0) {
            ChampionBar cb;
            cb.topRight = makePosition(p.x+1, p.y + 3);
            cb.topLeft = makePosition(cb.topRight.x - Health_Bar_Width, cb.topRight.y);
            cb.bottomLeft = makePosition(cb.topLeft.x, cb.topLeft.y + Health_Bar_Height);
            cb.bottomRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y + Health_Bar_Height);
            [championBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
            //NSLog(@"Found enemy champion with corners: %d at position: %d, %d", corners, cb.topLeft.x, cb.topLeft.y);
        }
    }
}*/