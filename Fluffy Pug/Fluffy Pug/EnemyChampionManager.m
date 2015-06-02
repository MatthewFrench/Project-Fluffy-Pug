//
//  EnemyChampionManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "EnemyChampionManager.h"

/*
 
 Border color 1 is 115, 113, 115
 Border color 2 is 77, 75, 77
 Border color 3 is 3, 3, 3
 
 Bar color 1 is 204, 125, 113
 Bar color 2 is 204, 126, 114
 Bar color 3 is 186, 81, 65
 Bar color 4 is 186, 81, 65
 Bar color 5 is 173, 48, 28
 Bar color 6 is same
 Bar color 7 is same
 Bar color 8 is same
 Bar color 9 is 168, 36, 15
 
 I just need to recognize the top of the bar, most likely will give a good match
 
 Inner health bar is 104 x 9
 
 */
/*
 static int Border_Color_1_Red = 115, Border_Color_1_Green = 113, Border_Color_1_Blue = 115;
 static int Border_Color_2_Red = 77, Border_Color_2_Green = 75, Border_Color_2_Blue = 77;
 static int Border_Color_3_Red = 3, Border_Color_3_Green = 3, Border_Color_3_Blue = 3;
 
 
 static int Bar_Color_1_Red = 204, Bar_Color_1_Green = 125, Bar_Color_1_Blue = 113;
 static int Bar_Color_2_Red = 204, Bar_Color_2_Green = 126, Bar_Color_2_Blue = 114;
 static int Bar_Color_3_Red = 186, Bar_Color_3_Green = 81, Bar_Color_3_Blue = 65;
 static int Bar_Color_4_Red = 186, Bar_Color_4_Green = 81, Bar_Color_4_Blue = 65;
 static int Bar_Color_5_Red = 173, Bar_Color_5_Green = 48, Bar_Color_5_Blue = 28;
 static int Bar_Color_6_Red = 173, Bar_Color_6_Green = 48, Bar_Color_6_Blue = 28;
 static int Bar_Color_7_Red = 173, Bar_Color_7_Green = 48, Bar_Color_7_Blue = 28;
 static int Bar_Color_8_Red = 173, Bar_Color_8_Green = 48, Bar_Color_8_Blue = 28;
 static int Bar_Color_9_Red = 168, Bar_Color_9_Green = 36, Bar_Color_9_Blue = 15;
 
 static int Bar_Inner_Width = 104, Bar_Inner_Height = 9;
 
 const static int Top_Left_Corner_Height = 4, Top_Left_Corner_Width = 4;
 static int Top_Left_Corner_Image[Top_Left_Corner_Height][Top_Left_Corner_Width][3] =
 {
 {{115,113,115},{115,113,115},{115,113,115},{115,113,115}},
 {{115,113,115},{77,75,77},{77,75,77},{77,75,77}},
 {{115,113,115},{77,75,77},{3,3,3},{3,3,3}},
 {{115,113,115},{77,75,77},{3,3,3},{204,125,113}}
 };
 
 const static int Bottom_Left_Corner_Height = 2, Bottom_Left_Corner_Width = 4;
 static int Bottom_Left_Corner_Image[Bottom_Left_Corner_Width][Bottom_Left_Corner_Height][3] =
 {
 {{115,113,115},{115,113,115},{115,113,115},{115,113,115}},
 {{115,113,115},{77,75,77},{77,75,77},{77,75,77}},
 {{115,113,115},{77,75,77},{3,3,3},{3,3,3}},
 {{115,113,115},{77,75,77},{3,3,3},{204,125,113}}
 };
 
 */

static int Debug_Draw_Red = 255, Debug_Draw_Green = 0, Debug_Draw_Blue = 255;

EnemyChampionManager::EnemyChampionManager () {
    championBars = [NSMutableArray new];
    //topLeftCorners = [NSMutableArray new];
    //bottomLeftCorners = [NSMutableArray new];
    topLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Top Left Corner" ofType:@"png"]);
    
    bottomLeftImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Bottom Left Corner" ofType:@"png"]);
    bottomRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Bottom Right Corner" ofType:@"png"]);
    topRightImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Top Right Corner" ofType:@"png"]);
    healthSegmentImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Enemy Champion Health Bar/Health Segment" ofType:@"png"]);
}

void EnemyChampionManager::debugDraw() {
    for (int i = 0; i < [championBars count]; i++) {
        struct ChampionBar mb;
        [[championBars objectAtIndex:i] getValue:&mb];
        drawRect(imageData, mb.topLeft.x, mb.topLeft.y, 104, 9, Debug_Draw_Red, Debug_Draw_Green, Debug_Draw_Blue);
    }
}
void EnemyChampionManager::prepareForPixelProcessing() {
    [championBars removeAllObjects];
    //[topLeftCorners removeAllObjects];
    //[bottomLeftCorners removeAllObjects];
}

void EnemyChampionManager::processPixel(uint8_t *pixel, int x, int y) {
    
    //We need to loop through each pixel and check if it's in range
    //Check top left first
    bool detectedTopLeftImage = true;
    uint8_t* pixel1 = pixel;
    //Check to make sure we can fit the entire image in the other image first
    if (imageData.imageWidth - x < topLeftImageData.imageWidth ||
        imageData.imageHeight - y < topLeftImageData.imageHeight) {
        detectedTopLeftImage = false;
    } else {
        uint8_t *pixel2 = topLeftImageData.imageData;
        
        for (int y1 = 0; y1 < topLeftImageData.imageHeight && detectedTopLeftImage; y1++) {
            pixel1 = pixel + (y1 * imageData.imageWidth)*4;
            for (int x1 = 0; x1 < topLeftImageData.imageWidth; x1++) {
                if (!isColor2(pixel1, pixel2, 5)) {
                    detectedTopLeftImage = false;
                    break;
                }
                pixel2 += 4;
                pixel1 += 4;
            }
        }
    }
    
    if (detectedTopLeftImage) {
        Position p;p.x=x;p.y=y;
        topLeftQueue.enqueue(p);
    }
    
    
    //Assume multithreaded
    /*
     if (isColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue, 5)) {
     //Check if top left border
     if (x < imageData.imageWidth-1) {
     
     uint8_t *rightPixel = pixel + 4;
     if (isColor(rightPixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue, 5)) {
     
     if (y < imageData.imageHeight-1) { //Check for top left bar
     
     //Check bottom right pixel
     uint8_t *bottomRightPixel = pixel + (imageData.imageWidth + 1)*4;
     if (isColor(bottomRightPixel, Bar_Color_1_Red, Bar_Color_1_Green, Bar_Color_1_Blue, 2)) {
     uint8_t *bottomPixel = pixel + (imageData.imageWidth)*4;
     if (isColor(bottomPixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue, 5)) {
     
     Position p;p.x=x;p.y=y;
     topLeftQueue.enqueue(p);
     
     }
     }
     }
     }
     
     
     if (y > 0) { //Check for bottom left bar
     
     
     //Check top right pixel
     uint8_t *topRightPixel = pixel + (-imageData.imageWidth + 1)*4;
     if (isColor(topRightPixel, Bar_Color_4_Red, Bar_Color_4_Green, Bar_Color_4_Blue, 2)) {
     uint8_t *topPixel = pixel - (imageData.imageWidth)*4;
     if (isColor(topPixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue, 5)) {
     
     Position p;p.x=x;p.y=y;
     bottomLeftQueue.enqueue(p);
     }
     }
     }
     }
     }*/
}

void EnemyChampionManager::postPixelProcessing() {
    Position p;
    while(topLeftQueue.try_dequeue(p)) {
        ChampionBar cb;
        cb.topLeft = p;
        [championBars addObject:[NSValue valueWithBytes:&cb objCType:@encode(ChampionBar)]];
    }
    
    //Empty queue into corner array
    /*
     Position p;
     while(topLeftQueue.try_dequeue(p)) {
     [topLeftCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
     }
     while(bottomLeftQueue.try_dequeue(p)) {
     [bottomLeftCorners addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
     }
     
     for (int i = 0; i < [topLeftCorners count]; i++) {
     struct Position p;
     [[topLeftCorners objectAtIndex:i] getValue:&p];
     //First check if there's an  bottom corner, that will be sufficient enough to confirm
     int bottomCornerX = p.x;
     int bottomCornerY = p.y+5;
     bool foundBottomCorner = false;
     for (int j = 0; j < [bottomLeftCorners count]; j++) {
     struct Position p2;
     [[bottomLeftCorners objectAtIndex:j] getValue:&p2];
     if (p2.x == bottomCornerX && p2.y == bottomCornerY) {
     //Found a match
     struct ChampionBar mb = makeChampionBar(p, p2, makePosition(p.x+63,p.y), makePosition(p.x+63,p.y+5), 100.0);
     [championBars addObject:[NSValue valueWithBytes:&mb objCType:@encode(struct ChampionBar)]];
     [bottomLeftCorners removeObjectAtIndex:j];
     foundBottomCorner = true;
     break;
     }
     }
     if (!foundBottomCorner) {
     int borderCount = 0;
     //Top
     for (int x = p.x; x < p.x + 64 && borderCount < 30; x++) {
     struct Pixel pixel = getPixel(imageData, x, p.y);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     //Bottom
     for (int x = p.x; x < p.x + 64 && borderCount < 30; x++) {
     struct Pixel pixel = getPixel(imageData, x, p.y+5);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     //Left
     for (int y = p.y; y < p.y + 6 && borderCount < 30; y++) {
     struct Pixel pixel = getPixel(imageData, p.x, y);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     //Right
     for (int y = p.y; y < p.y + 6 && borderCount < 30; y++) {
     struct Pixel pixel = getPixel(imageData, p.x, y+63);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     if (borderCount >= 30) {
     struct ChampionBar mb = makeChampionBar(p, makePosition(p.x,p.y+5), makePosition(p.x+63,p.y), makePosition(p.x+63,p.y+5), 100.0);
     [championBars addObject:[NSValue valueWithBytes:&mb objCType:@encode(struct ChampionBar)]];
     }
     }
     }
     //Now verify bottom left
     for (int i = 0; i < [bottomLeftCorners count]; i++) {
     struct Position p;
     [[bottomLeftCorners objectAtIndex:i] getValue:&p];
     p.y -= 5;
     int borderCount = 0;
     //Top
     for (int x = p.x; x < p.x + 64 && borderCount < 30; x++) {
     struct Pixel pixel = getPixel(imageData, x, p.y);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     //Bottom
     for (int x = p.x; x < p.x + 64 && borderCount < 30; x++) {
     struct Pixel pixel = getPixel(imageData, x, p.y+5);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     //Left
     for (int y = p.y; y < p.y + 6 && borderCount < 30; y++) {
     struct Pixel pixel = getPixel(imageData, p.x, y);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     //Right
     for (int y = p.y; y < p.y + 6 && borderCount < 30; y++) {
     struct Pixel pixel = getPixel(imageData, p.x, y+63);
     if (isPixelPreciseColor(pixel, Border_Color_Red, Border_Color_Green, Border_Color_Blue)) {
     borderCount++;
     }
     }
     if (borderCount >= 30) {
     struct ChampionBar mb = makeChampionBar(p, makePosition(p.x,p.y+5), makePosition(p.x+63,p.y), makePosition(p.x+63,p.y+5), 100.0);
     [championBars addObject:[NSValue valueWithBytes:&mb objCType:@encode(struct ChampionBar)]];
     }
     }
     
     //Calculate health of minion
     for (int i = 0; i < [championBars count]; i++) {
     struct ChampionBar minion;
     NSValue* value = [championBars objectAtIndex:i];
     [value getValue:&minion];
     int count = 0;
     //Blue 1 = 81, 162, 230
     for (int x = 0; x < 63; x++) {
     struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+1;
     if (!isPixelColor(getPixel(imageData, b1.x, b1.y), Bar_Color_1_Red, Bar_Color_1_Green, Bar_Color_1_Blue, 1)) {
     if (x > count) {count = x;}
     break;
     }
     }
     //Blue 2 = 68, 136, 193
     for (int x = 0; x < 63; x++) {
     struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+2;
     if (!isPixelColor(getPixel(imageData, b1.x, b1.y), Bar_Color_2_Red, Bar_Color_2_Green, Bar_Color_2_Blue, 1)) {
     if (x > count) {count = x;}
     break;
     }
     }
     //Blue 3 = 53, 107, 151
     for (int x = minion.topLeft.x + 1; x < 63; x++) {
     struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+3;
     if (!isPixelColor(getPixel(imageData, b1.x, b1.y), Bar_Color_3_Red, Bar_Color_3_Green, Bar_Color_3_Blue, 1)) {
     if (x > count) {count = x;}
     break;
     }
     }
     //Blue 4 = 40, 80, 114
     for (int x = minion.topLeft.x + 1; x < 63; x++) {
     struct Position b1; b1.x = x + minion.topLeft.x + 1; b1.y = minion.topLeft.y+4;
     if (!isPixelColor(getPixel(imageData, b1.x, b1.y), Bar_Color_4_Red, Bar_Color_4_Green, Bar_Color_4_Blue, 1)) {
     if (x > count) {count = x;}
     break;
     }
     }
     minion.health = (float)count/62.0;
     value = [NSValue valueWithBytes:&minion objCType:@encode(struct ChampionBar)];
     [championBars replaceObjectAtIndex:i withObject:value];
     }*/
}

void EnemyChampionManager::setImageData(ImageData data) {
    imageData = data;
}