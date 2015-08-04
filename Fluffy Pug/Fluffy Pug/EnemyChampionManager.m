//
//  EnemyChampionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "EnemyChampionManager.h"

static int Debug_Draw_Red = 255, Debug_Draw_Green = 0, Debug_Draw_Blue = 255;
static int Health_Bar_Width = 104, Health_Bar_Height = 9;

EnemyChampionManager::EnemyChampionManager () {
    championBars = [NSMutableArray new];
    topRightDetect = [NSMutableArray new];
    topLeftDetect = [NSMutableArray new];
    bottomRightDetect = [NSMutableArray new];
    bottomLeftDetect = [NSMutableArray new];
    
    topLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Top Left Corner" ofType:@"png"]);
    
    bottomLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Bottom Left Corner" ofType:@"png"]);
    bottomRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Bottom Right Corner" ofType:@"png"]);
    topRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Top Right Corner" ofType:@"png"]);
    healthSegmentImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Health Segment" ofType:@"png"]);
    
    needsFullScreenUpdate = true;
    fullScreenUpdateTime = clock();
    lastUpdateTime = clock();
}

void EnemyChampionManager::debugDraw(ImageData imageData) {
    for (int i = 0; i < [championBars count]; i++) {
        ChampionBar mb;
        [[championBars objectAtIndex:i] getValue:&mb];
        drawRect(imageData, mb.topLeft.x, mb.topLeft.y, Health_Bar_Width, Health_Bar_Height, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
    }
}
void EnemyChampionManager::processImage(ImageData imageData) {
    double delta = (clock() - lastUpdateTime)/CLOCKS_PER_SEC;
    lastUpdateTime = clock();
    double lastFullScreenUpdate = (clock() - fullScreenUpdateTime)/CLOCKS_PER_SEC;
    if (lastFullScreenUpdate >= 0.92) { //It's been a whole half second, scan the screen
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
        scanSection(imageData, 0, 0, imageData.imageWidth, imageData.imageHeight);
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
            scanSection(imageData, xStart, yStart, xEnd, yEnd);
        }
    }
    [championBars removeAllObjects];
    //Take the scanned corners and get champion data
    processChampionsLocations();
    processChampionsHealth(imageData);
}
void EnemyChampionManager::scanSection(ImageData imageData, int xStart, int yStart, int xEnd, int yEnd) {
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = getPixel2(imageData, xStart, y);
        
        for (int x = xStart; x < xEnd; x++) {
            processPixel(imageData, pixel, x, y);
            
            pixel += 4;
        }
    }
}
void EnemyChampionManager::processChampionsLocations() {
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
void EnemyChampionManager::processChampionsHealth(ImageData imageData) {
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
        
        [championBars replaceObjectAtIndex:i withObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
    }
}

ChampionBar EnemyChampionManager::getNearestChampion(int x, int y) {
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
ChampionBar EnemyChampionManager::getLowestHealthChampion(int x, int y) {
    ChampionBar closest;
    for (int i = 0; i < [championBars count]; i++) {
        ChampionBar cb;
        [[championBars objectAtIndex:i] getValue:&cb];
        
        if (i == 0) {
            closest = cb;
        } else if (closest.health > cb.health) {
            closest = cb;
        } else if (closest.health == cb.health && hypot(closest.characterCenter.x - x, closest.characterCenter.y - y) > hypot(cb.characterCenter.x - x, cb.characterCenter.y - y)) {
            closest = cb;
        }
    }
    return closest;
}



void EnemyChampionManager::processPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
    //Detect top left bar
    if (detectImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topLeftImageData, 0.7)) {
        Position p;p.x=x;p.y=y;
        //Add if not detected
        if (!containsPosition(topLeftDetect, p)) {
            //NSLog(@"Found top left %d %d", p.x, p.y);
            [topLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect bottom left bar
    if (detectImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomLeftImageData, 0.7)) {
        Position p;p.x=x;p.y=y;
        if (!containsPosition(bottomLeftDetect, p)) {
            //NSLog(@"Found bottom left %d %d", p.x, p.y);
            [bottomLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect top right bar
    if (detectImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight,topRightImageData, 0.7)) {
        Position p;p.x=x+1;p.y=y;
        if (!containsPosition(topRightDetect, p)) {
            //NSLog(@"Found top right %d %d", p.x, p.y);
            [topRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect bottom right bar
    if (detectImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight,bottomRightImageData, 0.7)) {
        Position p;p.x=x-2;p.y=y;
        if (!containsPosition(bottomRightDetect, p)) {
            //NSLog(@"Found bottom right %d %d", p.x, p.y);
            [bottomRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
}
bool EnemyChampionManager::containsPosition(NSMutableArray* array, Position p) {
    for (int i = 0; i < [array count]; i++) {
        Position p2;
        [[array objectAtIndex:i] getValue:&p2];
        if (p2.x == p.x && p2.y == p.y) {
            return true;
        }
    }
    return false;
}
void EnemyChampionManager::processTopLeftDetect() {
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
            //NSLog(@"Discovered enemy championw ith corners: %d", corners);
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

void EnemyChampionManager::processBottomRightDetect() {
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
            //NSLog(@"Discovered enemy championw ith corners: %d", corners);
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

void EnemyChampionManager::processBottomLeftDetect() {
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
                //NSLog(@"Top right");
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
                //NSLog(@"Top left");
                break;
            }
        }
        //Remove bottom right corner
        for (int i = 0; i < [bottomRightDetect count]; i++) {
            Position p2;
            [[bottomRightDetect objectAtIndex:i] getValue:&p2];
            //NSLog(@"%d", p2.y - p.y);
            if (p2.x-p.x > Health_Bar_Width - 10 && p2.x-p.x < Health_Bar_Width+10 && p2.y == p.y) {//Approx
                [bottomRightDetect removeObjectAtIndex:i];
                corners++;
                //NSLog(@"Bottom right");
                break;
            }
        }
        //Now add champion bar
        if (corners > 0) {
            //NSLog(@"Discovered enemy championw ith corners: %d", corners);
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
void EnemyChampionManager::processTopRightDetect() {
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
            //NSLog(@"Discovered enemy championw ith corners: %d", corners);
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