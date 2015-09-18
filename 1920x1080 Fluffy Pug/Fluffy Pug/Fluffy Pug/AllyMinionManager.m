//
//  AllyMinionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "AllyMinionManager.h"

//static int Debug_Draw_Red = 0, Debug_Draw_Green = 255, Debug_Draw_Blue = 0;
//static int Health_Bar_Width = 62, Health_Bar_Height = 4;

ImageData AllyMinionManager::topLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Ally Minion Health Bar/Top Left Corner" ofType:@"png"]);

ImageData AllyMinionManager::bottomLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Ally Minion Health Bar/Bottom Left Corner" ofType:@"png"]);
ImageData AllyMinionManager::bottomRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Ally Minion Health Bar/Bottom Right Corner" ofType:@"png"]);
ImageData AllyMinionManager::topRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Ally Minion Health Bar/Top Right Corner" ofType:@"png"]);
ImageData AllyMinionManager::healthSegmentImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Ally Minion Health Bar/Health Segment" ofType:@"png"]);
ImageData AllyMinionManager::wardImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Ward/Pink Ward" ofType:@"png"]);

AllyMinionManager::AllyMinionManager () {
    /*
     minionBars = [NSMutableArray new];
     topRightDetect = [NSMutableArray new];
     topLeftDetect = [NSMutableArray new];
     bottomRightDetect = [NSMutableArray new];
     bottomLeftDetect = [NSMutableArray new];
     
     needsFullScreenUpdate = true;
     fullScreenUpdateTime = clock();
     lastUpdateTime = clock();
     */
}

const float coloredPixelPrecision = 0.96; //0.97
const float overalImagePrecision = 0.96; //0.97
const float allyMinionHealthMatch = 0.80; //0.87
Minion* AllyMinionManager::detectMinionBarAtPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
    //In the future maybe for precision sake, scan for minions using a cross section of the bar, 1 pixel width top to bottom
    
    Minion* minion = nil;
    //Look top left corner
    if (isColor3(pixel, 0, 0, 0)) {
        if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topLeftImageData, coloredPixelPrecision) >=  overalImagePrecision) {
            int barTopLeftX = x + 1;
            int barTopLeftY = y + 1;
            minion = [Minion new];
            minion->topLeft.x = barTopLeftX;
            minion->topLeft.y = barTopLeftY;
            minion->bottomLeft.x = barTopLeftX;
            minion->bottomLeft.y = barTopLeftY + 4;
            minion->topRight.x = barTopLeftX + 62;
            minion->topRight.y = barTopLeftY;
            minion->bottomRight.x = barTopLeftX + 62;
            minion->bottomRight.y = barTopLeftY + 4;
            minion->health = 0;
            minion->detectedTopLeft = true;
            //NSLog(@"Top left at %d %d", barTopLeftX, barTopLeftY);
        } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomLeftImageData, coloredPixelPrecision) >=  overalImagePrecision) { // Look for bottom left corner
            int barTopLeftX = x + 1;
            int barTopLeftY = y - 3;
            minion = [Minion new];
            minion->topLeft.x = barTopLeftX;
            minion->topLeft.y = barTopLeftY;
            minion->bottomLeft.x = barTopLeftX;
            minion->bottomLeft.y = barTopLeftY + 4;
            minion->topRight.x = barTopLeftX + 62;
            minion->topRight.y = barTopLeftY;
            minion->bottomRight.x = barTopLeftX + 62;
            minion->bottomRight.y = barTopLeftY + 4;
            minion->detectedBottomLeft = true;
            minion->health = 0;
            //NSLog(@"Bottom left at %d %d", barTopLeftX, barTopLeftY);
        }
    }/*
      else {
      //bool detectedCorner = false;
      if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topRightImageData, minionPercentMatch) >=  minionPercentMatch) { // Look for top right corner
      int barTopLeftX = x - 61;
      int barTopLeftY = y + 1;
      minion = [Minion new];
      minion->health = 0;
      minion->topLeft.x = barTopLeftX;
      minion->topLeft.y = barTopLeftY;
      minion->bottomLeft.x = barTopLeftX;
      minion->bottomLeft.y = barTopLeftY + 4;
      minion->topRight.x = barTopLeftX + 62;
      minion->topRight.y = barTopLeftY;
      minion->bottomRight.x = barTopLeftX + 62;
      minion->bottomRight.y = barTopLeftY + 4;
      minion->detectedTopRight = true;
      } else {
      if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomRightImageData, minionPercentMatch) >=  minionPercentMatch) { // Look for bottom right corner
      int barTopLeftX = x - 61;
      int barTopLeftY = y - 3;
      minion = [Minion new];
      minion->health = 0;
      minion->topLeft.x = barTopLeftX;
      minion->topLeft.y = barTopLeftY;
      minion->bottomLeft.x = barTopLeftX;
      minion->bottomLeft.y = barTopLeftY + 4;
      minion->topRight.x = barTopLeftX + 62;
      minion->topRight.y = barTopLeftY;
      minion->bottomRight.x = barTopLeftX + 62;
      minion->bottomRight.y = barTopLeftY + 4;
      minion->detectedBottomRight = true;
      }
      }*/
    
    return minion;
}

//To Validate, at least 2 corners need detected then we detect the health percentage
NSMutableArray* AllyMinionManager::validateMinionBars(ImageData imageData, NSMutableArray* detectedMinionBars) {
    //NSLog(@"Detected minions: %lu", (unsigned long)[detectedMinionBars count]);
    NSMutableArray* minionBars = [NSMutableArray new];
    
    while ([detectedMinionBars count] > 0) {
        Minion* minion = [detectedMinionBars lastObject];
        [detectedMinionBars removeLastObject];
        int detectedCorners = 1;
        for (int i = 0; i < [detectedMinionBars count]; i++) {
            Minion * minion2 = [detectedMinionBars objectAtIndex:i];
            if (minion2->topLeft.x == minion->topLeft.x && minion->topLeft.y == minion2-> topLeft.y) {
                [detectedMinionBars removeObjectAtIndex:i];
                i--;
                if (minion2->detectedBottomLeft) minion->detectedBottomLeft = true;
                if (minion2->detectedBottomRight) minion->detectedBottomRight = true;
                if (minion2->detectedTopLeft) minion->detectedTopLeft = true;
                if (minion2->detectedTopRight) minion->detectedTopRight = true;
                if (minion2->health > minion->health) minion->health = minion2->health;
                detectedCorners++;
            }
        }
        //if (detectedCorners > 1) {
        //Don't want phantom bars caused by overlapping bars
        //    if (minion->detectedBottomLeft || minion->detectedTopLeft) {
        minion->characterCenter.x = minion->topLeft.x+30; minion->characterCenter.y = minion->topLeft.y+32;
        [minionBars addObject: minion];
        //    }
        //}
    }
    
    //Detect health
    for (int i = 0; i < [minionBars count]; i++) {
        Minion* minion = [minionBars objectAtIndex:i];
        if (minion->health == 0) {
            for (int x = 61; x >= 0; x--) {
                for (int y = 0; y < healthSegmentImageData.imageHeight; y++) {
                    if (x + minion->topLeft.x >= 0 && x + minion->topLeft.x < imageData.imageWidth &&
                        y + minion->topLeft.y >= 0 && y + minion->topLeft.y < imageData.imageHeight) {
                    uint8_t* healthBarColor = getPixel2(healthSegmentImageData, 0, y);
                    uint8_t*  p = getPixel2(imageData, x + minion->topLeft.x, y + minion->topLeft.y);
                    if (getColorPercentage(healthBarColor, p) >= allyMinionHealthMatch) {
                        minion->health = (float)x / 61 * 100;
                        y = healthSegmentImageData.imageHeight + 1;
                        x = -1;
                    }
                    }
                }
            }
        }
        if (minion->health == 0) { //Not a minion
            [minionBars removeObjectAtIndex:i];
            i--;
            //delete minion;
        }
    }
    
    //Detect if ward
    //Ward is 193, 193, 193
    for (int i = 0; i < [minionBars count]; i++) {
        Minion* minion = [minionBars objectAtIndex:i];
        bool isWard = false;
        for (int x = 61; x >= 0; x--) {
            for (int yOffset = -3; yOffset <= 1; yOffset++) {
                if (x + minion->topLeft.x >= 0 && x + minion->topLeft.x < imageData.imageWidth &&
                    yOffset + minion->topLeft.y >= 0 && yOffset + minion->topLeft.y < imageData.imageHeight) {
                    uint8_t*  p = getPixel2(imageData, x + minion->topLeft.x, yOffset + minion->topLeft.y);
                    if (isColor(p, 220, 220, 220, 45)) {
                        isWard = true;
                        x = -1;
                        yOffset = 4;
                }
            }
            }
        }
        //Detect if pink ward
        if (getImageAtPixelPercentageOptimizedExact(getPixel2(imageData, minion->topLeft.x-1, minion->topLeft.y-1), minion->topLeft.x-1, minion->topLeft.y-1, imageData.imageWidth, imageData.imageHeight, wardImageData, coloredPixelPrecision) >=  overalImagePrecision) {
            isWard = true;
        }
        if (isWard) {
            [minionBars removeObjectAtIndex:i];
            i--;
        }
    }
    
    return minionBars;
}


/*
 void AllyMinionManager::debugDraw(ImageData imageData) {
 for (int i = 0; i < [minionBars count]; i++) {
 MinionBar mb;
 [[minionBars objectAtIndex:i] getValue:&mb];
 drawRect(imageData, mb.topLeft.x, mb.topLeft.y, Health_Bar_Width, Health_Bar_Height, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
 }
 }
 void AllyMinionManager::processImage(ImageData imageData) {
 
 double delta = (clock() - lastUpdateTime)/CLOCKS_PER_SEC;
 lastUpdateTime = clock();
 double lastFullScreenUpdate = (clock() - fullScreenUpdateTime)/CLOCKS_PER_SEC;
 if (lastFullScreenUpdate >= 0.95) { //It's been a whole second, scan the screen
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
 //Scan only where we last saw enemy Minions
 for (int i = 0; i < [minionBars count]; i++) {
 MinionBar cb;
 NSValue* value = [minionBars objectAtIndex:i];
 [value getValue:&cb];
 //Assume a certain speed per second for Minions
 int xStart = cb.topLeft.x - delta*minionSpeed - 1;
 int yStart = cb.topLeft.y - delta*minionSpeed - 1;
 int xEnd = cb.bottomRight.x + delta*minionSpeed + 1;
 int yEnd = cb.bottomRight.y + delta*minionSpeed + 1;
 if (xStart < 0) xStart = 0;
 if (yStart < 0) yStart = 0;
 if (xEnd > imageData.imageWidth) xEnd = imageData.imageWidth;
 if (yEnd > imageData.imageHeight) yEnd = imageData.imageHeight;
 scanSection( imageData, xStart, yStart, xEnd, yEnd);
 }
 }
 [minionBars removeAllObjects];
 //Take the scanned corners and get champion data
 processMinionsLocations( imageData);
 processMinionsHealth( imageData);
 }
 void AllyMinionManager::scanSection(ImageData imageData, int xStart, int yStart, int xEnd, int yEnd) {
 for (int y = yStart; y < yEnd; y++) {
 uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
 
 for (int x = xStart; x < xEnd; x++) {
 processPixel( imageData, pixel, x, y);
 
 pixel += 4;
 }
 }
 }
 void AllyMinionManager::processMinionsLocations(ImageData imageData) {
 processTopLeftDetect();
 processTopRightDetect();
 processBottomLeftDetect();
 processBottomRightDetect();
 //Do center location
 for (int i = 0; i < [minionBars count]; i++) {
 MinionBar cb;
 [[minionBars objectAtIndex:i] getValue:&cb];
 cb.characterCenter = makePosition(cb.topLeft.x+30, cb.topLeft.y+32);
 [minionBars replaceObjectAtIndex:i withObject:[NSValue valueWithBytes:&cb objCType:@encode(MinionBar)]];
 }
 //Cut out any minions that are wards
 for (int j = 0; j < [minionBars count]; j++) {
 MinionBar cb;
 [[minionBars objectAtIndex:j] getValue:&cb];
 
 int yStart = cb.topLeft.y - 5;
 int yEnd = cb.bottomRight.y + 5;
 int xStart = cb.topLeft.x - 5;
 int xEnd = cb.bottomRight.x + 5;
 bool isWard = false;
 for (int y = yStart; y < yEnd; y++) {
 uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
 for (int x = xStart; x < xEnd; x++) {
 if (x > 0 && y > 0 && x < imageData.imageWidth && y < imageData.imageHeight) {
 if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, ward, 2) ||
 detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, pinkWard, 2)) {
 isWard = true;
 x = xEnd; y = yEnd;
 }
 }
 pixel += 4;
 }
 }
 
 if (isWard) {
 [minionBars removeObjectAtIndex:j]; j--;
 }
 }
 //NSLog(@"Top left: %lu, top right: %lu, bottom left: %lu, bottom right: %lu", (unsigned long)[topLeftDetect count], (unsigned long)[topRightDetect count], (unsigned long)[bottomLeftDetect count], (unsigned long)[bottomRightDetect count]);
 }
 void AllyMinionManager::processMinionsHealth(ImageData imageData) {
 for (int i = 0; i < [minionBars count]; i++) {
 MinionBar cb;
 [[minionBars objectAtIndex:i] getValue:&cb];
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
 
 [minionBars replaceObjectAtIndex:i withObject:[NSValue valueWithBytes:&cb objCType:@encode(MinionBar)]];
 }
 }
 MinionBar AllyMinionManager::getNearestMinion(int x, int y) {
 MinionBar closest;
 for (int i = 0; i < [minionBars count]; i++) {
 MinionBar cb;
 [[minionBars objectAtIndex:i] getValue:&cb];
 
 if (i == 0) {
 closest = cb;
 } else if (hypot(closest.characterCenter.x - x, closest.characterCenter.y - y) > hypot(cb.characterCenter.x - x, cb.characterCenter.y - y)) {
 closest = cb;
 }
 }
 return closest;
 }
 
 MinionBar AllyMinionManager::getFurthestMinion(int x, int y) {
 MinionBar furthest;
 for (int i = 0; i < [minionBars count]; i++) {
 MinionBar cb;
 [[minionBars objectAtIndex:i] getValue:&cb];
 
 if (i == 0) {
 furthest = cb;
 } else if (hypot(furthest.characterCenter.x - x, furthest.characterCenter.y - y) < hypot(cb.characterCenter.x - x, cb.characterCenter.y - y)) {
 furthest = cb;
 }
 }
 return furthest;
 }
 
 
 void AllyMinionManager::processPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
 //getImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topLeftImageData)
 //Detect top left bar
 //ydouble percentage;
 if (detectImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topLeftImageData, 0.85)) {
 //NSLog(@"Percentage for top left detected: %f", percentage);
 Position p;p.x=x;p.y=y;
 //Add if not detected
 if (!containsPosition(topLeftDetect, p)) {
 [topLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
 }
 }
 //Detect bottom left bar
 if (detectImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomLeftImageData, 0.85)) {
 Position p;p.x=x;p.y=y;
 if (!containsPosition(bottomLeftDetect, p)) {
 [bottomLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
 }
 }
 //Detect top right bar
 if (detectImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topRightImageData, 0.85)) {
 Position p;p.x=x;p.y=y;
 if (!containsPosition(topRightDetect, p)) {
 [topRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
 }
 }
 //Detect bottom right bar
 if (detectImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomRightImageData, 0.85)) {
 Position p;p.x=x;p.y=y;
 if (!containsPosition(bottomRightDetect, p)) {
 [bottomRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
 }
 }
 }
 bool AllyMinionManager::containsPosition(NSMutableArray* array, Position p) {
 for (int i = 0; i < [array count]; i++) {
 Position p2;
 [[array objectAtIndex:i] getValue:&p2];
 if (p2.x == p.x && p2.y == p.y) {
 return true;
 }
 }
 return false;
 }
 
 
 void AllyMinionManager::processTopLeftDetect() {
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
 //NSLog(@"Found ally minion with corners: %d", corners);
 MinionBar cb;
 cb.topLeft = makePosition(p.x + 2, p.y + 2);
 cb.topRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y);
 cb.bottomLeft = makePosition(cb.topLeft.x, cb.topLeft.y + Health_Bar_Height);
 cb.bottomRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y + Health_Bar_Height);
 [minionBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(MinionBar)]];
 }
 }
 }
 
 void AllyMinionManager::processBottomRightDetect() {
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
 //NSLog(@"Found ally minion with corners: %d", corners);
 MinionBar cb;
 cb.bottomRight = makePosition(p.x+1, p.y+1);
 cb.topLeft = makePosition(cb.bottomRight.x - Health_Bar_Width, cb.bottomRight.y - Health_Bar_Height);
 cb.topRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y);
 cb.bottomLeft = makePosition(cb.topLeft.x, cb.topLeft.y + Health_Bar_Height);
 [minionBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(MinionBar)]];
 }
 }
 }
 
 void AllyMinionManager::processBottomLeftDetect() {
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
 if (p2.x-p.x > Health_Bar_Width-10 && p2.x-p.x < Health_Bar_Width+10 && p2.y == p.y) {//Approx
 [bottomRightDetect removeObjectAtIndex:i];
 corners++;
 break;
 }
 }
 //Now add champion bar
 if (corners > 0) {
 //NSLog(@"Found ally minion with corners: %d", corners);
 MinionBar cb;
 cb.bottomLeft = makePosition(p.x + 2, p.y);
 cb.topLeft = makePosition(cb.bottomLeft.x, cb.bottomLeft.y - Health_Bar_Height);
 cb.topRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y);
 cb.bottomRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y + Health_Bar_Height);
 [minionBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(MinionBar)]];
 }
 }
 }
 void AllyMinionManager::processTopRightDetect() {
 while ([topRightDetect count] > 0) {
 int corners = 0;
 Position p;
 [[topRightDetect lastObject] getValue:&p];
 [topRightDetect removeLastObject];
 //Remove top left corner
 for (int i = 0; i < [topLeftDetect count]; i++) {
 Position p2;
 [[topLeftDetect objectAtIndex:i] getValue:&p2];
 if (p2.y == p.y && p2.x-p.x < -Health_Bar_Width-10 && p2.x-p.x > -Health_Bar_Width+10) {//Approx
 [topLeftDetect removeObjectAtIndex:i];
 corners++;
 break;
 }
 }
 //Remove bottom left corner
 for (int i = 0; i < [bottomLeftDetect count]; i++) {
 Position p2;
 [[bottomLeftDetect objectAtIndex:i] getValue:&p2];
 if (p2.x-p.x < -Health_Bar_Width-10 && p2.x-p.x > -Health_Bar_Width+10 && p2.y-p.y > Health_Bar_Height-10 && p2.y-p.y < Health_Bar_Height+10) {//Approx
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
 //NSLog(@"Found ally minion with corners: %d", corners);
 MinionBar cb;
 cb.topRight = makePosition(p.x, p.y + 2);
 cb.topLeft = makePosition(cb.topRight.x - Health_Bar_Width, cb.topRight.y);
 cb.bottomLeft = makePosition(cb.topLeft.x, cb.topLeft.y + Health_Bar_Height);
 cb.bottomRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y + Health_Bar_Height);
 [minionBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(MinionBar)]];
 }
 }
 }*/