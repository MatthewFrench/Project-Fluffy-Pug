//
//  TurretManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/12/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "EnemyTowerManager.h"

//static int Debug_Draw_Red = 255, Debug_Draw_Green = 0, Debug_Draw_Blue = 255;
//static int Health_Bar_Width = 126, Health_Bar_Height = 8;

ImageData EnemyTowerManager::topLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Tower Health Bar/Top Left Corner" ofType:@"png"]);

ImageData EnemyTowerManager::bottomLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Tower Health Bar/Bottom Left Corner" ofType:@"png"]);
ImageData EnemyTowerManager::bottomRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Tower Health Bar/Bottom Right Corner" ofType:@"png"]);
ImageData EnemyTowerManager::topRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Tower Health Bar/Top Right Corner" ofType:@"png"]);
ImageData EnemyTowerManager::healthSegmentImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Tower Health Bar/Health Segment" ofType:@"png"]);

EnemyTowerManager::EnemyTowerManager () {
   /*
    towerBars = [NSMutableArray new];
    topRightDetect = [NSMutableArray new];
    topLeftDetect = [NSMutableArray new];
    bottomRightDetect = [NSMutableArray new];
    bottomLeftDetect = [NSMutableArray new];
    

    
    needsFullScreenUpdate = true;
    fullScreenUpdateTime = clock();
    lastUpdateTime = clock();
    */
}


Tower* EnemyTowerManager::detectTowerBarAtPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
    Tower* tower = nil;
    //Look top left corner
    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topLeftImageData, 0.7) >=  0.7) {
        int barTopLeftX = x + 3;
        int barTopLeftY = y + 3;
        tower = [Tower new];
        tower->topLeft.x = barTopLeftX;
        tower->topLeft.y = barTopLeftY;
        tower->bottomLeft.x = barTopLeftX;
        tower->bottomLeft.y = barTopLeftY + 8;
        tower->topRight.x = barTopLeftX + 126;
        tower->topRight.y = barTopLeftY;
        tower->bottomRight.x = barTopLeftX + 126;
        tower->bottomRight.y = barTopLeftY + 8;
        tower->detectedTopLeft = true;
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomLeftImageData, 0.7) >=  0.7) { // Look for bottom left corner
        int barTopLeftX = x + 3;
        int barTopLeftY = y - 7;
        tower = [Tower new];
        tower->topLeft.x = barTopLeftX;
        tower->topLeft.y = barTopLeftY;
        tower->bottomLeft.x = barTopLeftX;
        tower->bottomLeft.y = barTopLeftY + 8;
        tower->topRight.x = barTopLeftX + 126;
        tower->topRight.y = barTopLeftY;
        tower->bottomRight.x = barTopLeftX + 126;
        tower->bottomRight.y = barTopLeftY + 8;
        tower->detectedBottomLeft = true;
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topRightImageData, 0.7) >=  0.7) { // Look for top right corner
        int barTopLeftX = x - 126 + 1;
        int barTopLeftY = y + 3;
        tower = [Tower new];
        tower->topLeft.x = barTopLeftX;
        tower->topLeft.y = barTopLeftY;
        tower->bottomLeft.x = barTopLeftX;
        tower->bottomLeft.y = barTopLeftY + 8;
        tower->topRight.x = barTopLeftX + 126;
        tower->topRight.y = barTopLeftY;
        tower->bottomRight.x = barTopLeftX + 126;
        tower->bottomRight.y = barTopLeftY + 8;
        tower->detectedTopRight = true;
    } else if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomRightImageData, 0.7) >=  0.7) { // Look for bottom right corner
        int barTopLeftX = x - 126 + 1;
        int barTopLeftY = y - 7;
        tower = [Tower new];
        tower->topLeft.x = barTopLeftX;
        tower->topLeft.y = barTopLeftY;
        tower->bottomLeft.x = barTopLeftX;
        tower->bottomLeft.y = barTopLeftY + 8;
        tower->topRight.x = barTopLeftX + 126;
        tower->topRight.y = barTopLeftY;
        tower->bottomRight.x = barTopLeftX + 126;
        tower->bottomRight.y = barTopLeftY + 8;
        tower->detectedBottomRight = true;
    }
    //if (x == 364 + 101 + 2 && y == 310 - 3) {
    //    NSLog(@"Top Right corner test: %f", getImageAtPixelPercentageOptimizedExact(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topRightImageData, 0.5));
    //}
    return tower;
}

//To Validate, at least 2 corners need detected then we detect the health percentage
NSMutableArray* EnemyTowerManager::validateTowerBars(ImageData imageData, NSMutableArray* detectedTowerBars) {
    NSMutableArray* TowerBars = [NSMutableArray new];
    
    while ([detectedTowerBars count] > 0) {
        Tower* tower = [detectedTowerBars lastObject];
        [detectedTowerBars removeLastObject];
        int detectedCorners = 1;
        for (int i = 0; i < [detectedTowerBars count]; i++) {
            Tower * tower2 = [detectedTowerBars objectAtIndex:i] ;
            if (tower2->topLeft.x == tower->topLeft.x && tower->topLeft.y == tower2-> topLeft.y) {
                [detectedTowerBars removeObjectAtIndex:i];
                i--;
                if (tower2->detectedBottomLeft) tower->detectedBottomLeft = true;
                if (tower2->detectedBottomRight) tower->detectedBottomRight = true;
                if (tower2->detectedTopLeft) tower->detectedTopLeft = true;
                if (tower2->detectedTopRight) tower->detectedTopRight = true;
                detectedCorners++;
            }
        }
        if (detectedCorners > 1) {
            tower->towerCenter.x = tower->topLeft.x+126/2; tower->towerCenter.y = tower->topLeft.y+200;
            [TowerBars addObject: tower];
        }// else {
        //    delete tower;
        //}
    }
    
    //Detect health
    for (int i = 0; i < [TowerBars count]; i++) {
        Tower* tower = [TowerBars objectAtIndex:i];
        tower->health = 0;
        for (int x = 125; x >= 0; x--) {
            for (int y = 0; y < healthSegmentImageData.imageHeight; y++) {
                if (x + tower->topLeft.x >= 0 && x + tower->topLeft.x < imageData.imageWidth &&
                    y + tower->topLeft.y >= 0 && y + tower->topLeft.y < imageData.imageHeight) {
                uint8_t* healthBarColor = getPixel2(healthSegmentImageData, 0, y);
                uint8_t*  p = getPixel2(imageData, x + tower->topLeft.x, y + tower->topLeft.y);
                if (getColorPercentage(healthBarColor, p) >= 0.85) {
                    tower->health = (float)x / 125 * 100;
                    y = healthSegmentImageData.imageHeight + 1;
                    x = -1;
                }
                }
            }
        }
        if (tower->health == 0) {
            [TowerBars removeObjectAtIndex:i];
            i--;
        }
    }
    
    return TowerBars;
}

/*
void EnemyTowerManager::debugDraw(ImageData imageData) {
    for (int i = 0; i < [towerBars count]; i++) {
        TowerBar mb;
        [[towerBars objectAtIndex:i] getValue:&mb];
        drawRect(imageData, mb.topLeft.x, mb.topLeft.y, Health_Bar_Width, Health_Bar_Height, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
    }
}

void EnemyTowerManager::processImage(ImageData imageData) {
    double delta = (clock() - lastUpdateTime)/CLOCKS_PER_SEC;
    lastUpdateTime = clock();
    double lastFullScreenUpdate = (clock() - fullScreenUpdateTime)/CLOCKS_PER_SEC;
    if (lastFullScreenUpdate >= 0.91) { //It's been a whole half second, scan the screen
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
        //Scan only where we last saw enemy Towers
        for (int i = 0; i < [towerBars count]; i++) {
            TowerBar cb;
            NSValue* value = [towerBars objectAtIndex:i];
            [value getValue:&cb];
            //Assume a certain speed per second for Towers
            int xStart = cb.topLeft.x - delta*TowerSpeed - 5;
            int yStart = cb.topLeft.y - delta*TowerSpeed - 5;
            int xEnd = cb.bottomRight.x + delta*TowerSpeed + 5;
            int yEnd = cb.bottomRight.y + delta*TowerSpeed + 5;
            if (xStart < 0) xStart = 0;
            if (yStart < 0) yStart = 0;
            if (xEnd > imageData.imageWidth) xEnd = imageData.imageWidth;
            if (yEnd > imageData.imageHeight) yEnd = imageData.imageHeight;
            scanSection( imageData, xStart, yStart, xEnd, yEnd);
        }
    }
    [towerBars removeAllObjects];
    //Take the scanned corners and get Tower data
    processTowersLocations();
    processTowersHealth(imageData);
}
void EnemyTowerManager::scanSection(ImageData imageData, int xStart, int yStart, int xEnd, int yEnd) {
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = getPixel2(imageData, xStart, y);
        
        for (int x = xStart; x < xEnd; x++) {
            processPixel( imageData, pixel, x, y);
            
            pixel += 4;
        }
    }
}
void EnemyTowerManager::processTowersLocations() {
    processTopLeftDetect();
    //processTopRightDetect();
    processBottomLeftDetect();
    //processBottomRightDetect();
    //Do center location
    for (int i = 0; i < [towerBars count]; i++) {
        TowerBar cb;
        [[towerBars objectAtIndex:i] getValue:&cb];
        cb.towerCenter = makePosition(cb.topLeft.x+Health_Bar_Width/2, cb.topLeft.y+200);
        [towerBars replaceObjectAtIndex:i withObject:[NSValue valueWithBytes:&cb objCType:@encode(TowerBar)]];
    }
}
void EnemyTowerManager::processTowersHealth(ImageData imageData) {
    for (int i = 0; i < [towerBars count]; i++) {
        TowerBar cb;
        [[towerBars objectAtIndex:i] getValue:&cb];
        cb.health = 0;
        for (int x = Health_Bar_Width; x > 0; x--) {
            
            //Use health segment image and go from up to down
            for (int y = 0; y < healthSegmentImageData.imageHeight; y++) {
                uint8_t *healthPixel = getPixel2(healthSegmentImageData, 0, y);
                
                int pixelX =cb.topLeft.x + x;
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
        
        [towerBars replaceObjectAtIndex:i withObject:[NSValue valueWithBytes:&cb objCType:@encode(TowerBar)]];
    }
}

TowerBar EnemyTowerManager::getNearestTower(int x, int y) {
    TowerBar closest;
    for (int i = 0; i < [towerBars count]; i++) {
        TowerBar cb;
        [[towerBars objectAtIndex:i] getValue:&cb];
        
        if (i == 0) {
            closest = cb;
        } else if (hypot(closest.towerCenter.x - x, closest.towerCenter.y - y) > hypot(cb.towerCenter.x - x, cb.towerCenter.y - y)) {
            closest = cb;
        }
    }
    return closest;
}
TowerBar EnemyTowerManager::getLowestHealthTower(int x, int y) {
    TowerBar closest;
    for (int i = 0; i < [towerBars count]; i++) {
        TowerBar cb;
        [[towerBars objectAtIndex:i] getValue:&cb];
        
        if (i == 0) {
            closest = cb;
        } else if (closest.health > cb.health) {
            closest = cb;
        } else if (closest.health == cb.health && hypot(closest.towerCenter.x - x, closest.towerCenter.y - y) > hypot(cb.towerCenter.x - x, cb.towerCenter.y - y)) {
            closest = cb;
        }
    }
    return closest;
}



void EnemyTowerManager::processPixel(ImageData imageData, uint8_t *pixel, int x, int y) {
    //Detect top left bar
    if (detectImageAtPixelPercentage(pixel, x, y, imageData.imageWidth, imageData.imageHeight, topLeftImageData, 0.7)) {
        Position p;p.x=x+3;p.y=y+3; //We offset it enough to have the position at the bar segment
        //Add if not detected
        if (!containsPosition(topLeftDetect, p)) {
            //NSLog(@"Found top left %d %d", p.x, p.y);
            [topLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect bottom left bar
    if (detectImageAtPixelPercentage( pixel, x, y, imageData.imageWidth, imageData.imageHeight, bottomLeftImageData, 0.7)) {
        Position p;p.x=x+3;p.y=y+2; //Offset it to the pixel right under the bar segment
        if (!containsPosition(bottomLeftDetect, p)) {
            //NSLog(@"Found bottom left %d %d", p.x, p.y);
            [bottomLeftDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect top right bar
    if (detectImageAtPixelPercentage( pixel, x, y, imageData.imageWidth, imageData.imageHeight,topRightImageData, 0.7)) {
        Position p;p.x=x+4;p.y=y+3; //One pixel to the right of the bar segment
        if (!containsPosition(topRightDetect, p)) {
            //NSLog(@"Found top right %d %d", p.x, p.y);
            [topRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    //Detect bottom right bar
    if (detectImageAtPixelPercentage( pixel, x, y, imageData.imageWidth, imageData.imageHeight,bottomRightImageData, 0.7)) {
        Position p;p.x=x+4;p.y=y+2; //One pixel to the right of the thing
        if (!containsPosition(bottomRightDetect, p)) {
            //NSLog(@"Found bottom right %d %d", p.x, p.y);
            [bottomRightDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
}
bool EnemyTowerManager::containsPosition(NSMutableArray* array, Position p) {
    for (int i = 0; i < [array count]; i++) {
        Position p2;
        [[array objectAtIndex:i] getValue:&p2];
        if (p2.x == p.x && p2.y == p.y) {
            return true;
        }
    }
    return false;
}
void EnemyTowerManager::processTopLeftDetect() {
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
        //Now add Tower bar
        if (corners > 0) {
            //NSLog(@"Discovered enemy Towerw ith corners: %d", corners);
            TowerBar cb;
            cb.topLeft = makePosition(p.x, p.y);
            cb.topRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y);
            cb.bottomLeft = makePosition(cb.topLeft.x, cb.topLeft.y + Health_Bar_Height);
            cb.bottomRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y + Health_Bar_Height);
            [towerBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(TowerBar)]];
            //NSLog(@"Found enemy Tower with corners: %d at position: %d, %d", corners, cb.topLeft.x, cb.topLeft.y);
        }
    }
}

void EnemyTowerManager::processBottomRightDetect() {
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
        //Now add Tower bar
        if (corners > 0) {
            //NSLog(@"Discovered enemy Towerw ith corners: %d", corners);
            TowerBar cb;
            cb.bottomRight = makePosition(p.x, p.y);
            cb.topLeft = makePosition(cb.bottomRight.x - Health_Bar_Width, cb.bottomRight.y - Health_Bar_Height);
            cb.topRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y);
            cb.bottomLeft = makePosition(cb.topLeft.x, cb.topLeft.y + Health_Bar_Height);
            [towerBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(TowerBar)]];
            //NSLog(@"Found enemy Tower with corners: %d at position: %d, %d", corners, cb.topLeft.x, cb.topLeft.y);
        }
    }
}

void EnemyTowerManager::processBottomLeftDetect() {
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
        //Now add Tower bar
        if (corners > 0) {
            //NSLog(@"Discovered enemy Towerw ith corners: %d", corners);
            TowerBar cb;
            cb.bottomLeft = makePosition(p.x, p.y);
            cb.topLeft = makePosition(cb.bottomLeft.x, cb.bottomLeft.y - Health_Bar_Height);
            cb.topRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y);
            cb.bottomRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y + Health_Bar_Height);
            [towerBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(TowerBar)]];
            //NSLog(@"Found enemy Tower with corners: %d at position: %d, %d", corners, cb.topLeft.x, cb.topLeft.y);
        }
    }
}
void EnemyTowerManager::processTopRightDetect() {
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
        //Now add Tower bar
        if (corners > 0) {
            //NSLog(@"Discovered enemy Towerw ith corners: %d", corners);
            TowerBar cb;
            cb.topRight = makePosition(p.x, p.y);
            cb.topLeft = makePosition(cb.topRight.x - Health_Bar_Width, cb.topRight.y);
            cb.bottomLeft = makePosition(cb.topLeft.x, cb.topLeft.y + Health_Bar_Height);
            cb.bottomRight = makePosition(cb.topLeft.x + Health_Bar_Width, cb.topLeft.y + Health_Bar_Height);
            [towerBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(TowerBar)]];
            //NSLog(@"Found enemy Tower with corners: %d at position: %d, %d", corners, cb.topLeft.x, cb.topLeft.y);
        }
    }
}*/