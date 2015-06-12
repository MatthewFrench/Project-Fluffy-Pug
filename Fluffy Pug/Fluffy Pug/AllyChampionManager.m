//
//  AllyChampionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "AllyChampionManager.h"

static int Debug_Draw_Red = 50, Debug_Draw_Green = 150, Debug_Draw_Blue = 150;
static int Health_Bar_Width = 104, Health_Bar_Height = 9;

AllyChampionManager::AllyChampionManager () {
    championBars = [NSMutableArray new];
    topRightDetect = [NSMutableArray new];
    topLeftDetect = [NSMutableArray new];
    bottomRightDetect = [NSMutableArray new];
    bottomLeftDetect = [NSMutableArray new];
    
    topLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Ally Champion Health Bar/Top Left Corner" ofType:@"png"]);
    
    bottomLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Ally Champion Health Bar/Bottom Left Corner" ofType:@"png"]);
    bottomRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Ally Champion Health Bar/Bottom Right Corner" ofType:@"png"]);
    topRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Ally Champion Health Bar/Top Right Corner" ofType:@"png"]);
    healthSegmentImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Ally Champion Health Bar/Health Segment" ofType:@"png"]);
    
    needsFullScreenUpdate = true;
    fullScreenUpdateTime = clock();
    lastUpdateTime = clock();
}

void AllyChampionManager::debugDraw() {
    for (int i = 0; i < [championBars count]; i++) {
        ChampionBar mb;
        [[championBars objectAtIndex:i] getValue:&mb];
        drawRect(imageData, mb.topLeft.x, mb.topLeft.y, 104, 9, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
    }
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
}
void AllyChampionManager::processImage(ImageData data) {
    imageData = data;
    double delta = (clock() - lastUpdateTime)/CLOCKS_PER_SEC;
    lastUpdateTime = clock();
    double lastFullScreenUpdate = (clock() - fullScreenUpdateTime)/CLOCKS_PER_SEC;
    if (lastFullScreenUpdate >= 0.5) { //It's been a whole second, scan the screen
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
        scanSection(0, 0, imageData.imageWidth, imageData.imageHeight);
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
            scanSection(xStart, yStart, xEnd, yEnd);
        }
    }
    [championBars removeAllObjects];
    //Take the scanned corners and get champion data
    processChampionsLocations();
    processChampionsHealth();
}
void AllyChampionManager::scanSection(int xStart, int yStart, int xEnd, int yEnd) {
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = getPixel2(imageData, xStart, y);
        
        for (int x = xStart; x < xEnd; x++) {
            processPixel(pixel, x, y);
            
            pixel += 4;
        }
    }
}
void AllyChampionManager::processChampionsLocations() {
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
}
void AllyChampionManager::processChampionsHealth() {
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
                    if (isColor2(healthPixel, pixel, 20)) {
                        cb.health = (float)x / Health_Bar_Width * 100;
                        x = 0;
                        break;
                    }
                }
            }
            
            
        }
        
        [championBars replaceObjectAtIndex:i withObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
    }
}
ChampionBar AllyChampionManager::getNearestChampion(int x, int y) {
    ChampionBar closest;
    for (int i = 0; i < [championBars count]; i++) {
        ChampionBar cb;
        [[championBars objectAtIndex:i] getValue:&cb];
        
        if (i == 0) {
            closest = cb;
        } else if (hypot(closest.characterCenter.x - x, closest.characterCenter.y - y) > hypot(cb.characterCenter.x - x, cb.characterCenter.y - y)) {
            closest = cb;
        }
    }
    return closest;
}


void AllyChampionManager::processPixel(uint8_t *pixel, int x, int y) {
    //Detect top left bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topLeftImageData, 40)) {
        Position p;p.x=x;p.y=y;
        //Add if not detected
        if (!containsPosition(topLeftDetect, p)) {
            //NSLog(@"Top left: %d %d", p.x, p.y);
            [topLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect bottom left bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomLeftImageData, 40)) {
        Position p;p.x=x;p.y=y;
        if (!containsPosition(bottomLeftDetect, p)) {
            //NSLog(@"Bottom left: %d %d", p.x, p.y);
            [bottomLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect top right bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight,topRightImageData, 40)) {
        Position p;p.x=x;p.y=y;
        if (!containsPosition(topRightDetect, p)) {
            //NSLog(@"Top Right: %d %d", p.x, p.y);
            [topRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect bottom right bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight,bottomRightImageData, 40)) {
        Position p;p.x=x;p.y=y;
        if (!containsPosition(bottomRightDetect, p)) {
            //NSLog(@"Bottom Right: %d %d", p.x, p.y);
            [bottomRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
}
bool AllyChampionManager::containsPosition(NSMutableArray* array, Position p) {
    for (int i = 0; i < [array count]; i++) {
        Position p2;
        [[array objectAtIndex:i] getValue:&p2];
        if (p2.x == p.x && p2.y == p.y) {
            return true;
        }
    }
    return false;
}
void AllyChampionManager::processTopLeftDetect() {
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

void AllyChampionManager::processBottomRightDetect() {
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

void AllyChampionManager::processBottomLeftDetect() {
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
void AllyChampionManager::processTopRightDetect() {
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
}