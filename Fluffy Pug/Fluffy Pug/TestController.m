//
//  BasicAI.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "TestController.h"

TestController::TestController(NSImageView* processedImageView, NSImageView *unprocessedImageView, NSImageView* targetImageView, NSImageView* foundImage, NSTextView* logText) {
    this->processedImageView = processedImageView;
    this->unprocessedImageView = unprocessedImageView;
    this->targetImageView = targetImageView;
    this->foundImageView = foundImage;
    this->logText = logText;
    testImage.imageData = NULL;
    playButton = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(1) Play Button" ofType:@"png"]);
    
    //testGame1 = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/TestGame1" ofType:@"png"]);
    //testGame2 = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/TestGame2" ofType:@"png"]);
    
    testAbilitiesActive1280x800Image = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Test Images/Test Abilities Active 1280x800" ofType:@"png"]);
    testInGameDetection1280x800Image = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Test Images/Test In-Game Detection 1280x800" ofType:@"png"]);
    testItemActives1280x800Image = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Test Images/Test Item Actives 1280x800" ofType:@"png"]);
    testLevelUp1280x800Image = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Test Images/Test Level Up 1280x800" ofType:@"png"]);
    testShopAvailable1280x800Image = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Test Images/Test Shop Available 1280x800" ofType:@"png"]);
    testShopItems1280x800Image = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Test Images/Test Shop Items 1280x800" ofType:@"png"]);
    testShopOpen1280x800Image = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Test Images/Test Shop Open 1280x800" ofType:@"png"]);
    
    //[targetImageView setImage:getImageFromBGRABuffer(testGame1.imageData, testGame1.imageWidth, testGame1.imageHeight)];
}
void TestController::copyScreenShot(uint8 *baseAddress, int bufferWidth, int bufferHeight) {
    if (testImage.imageData != NULL) {
        free(testImage.imageData);
    }
    testImage.imageWidth = bufferWidth;
    testImage.imageHeight = bufferHeight;
    testImage.imageData = copyImageBuffer(baseAddress, bufferWidth, bufferHeight);
    //Screenshot copied as BGRA
    
    displayPreprocessedScreenShot();
}
void TestController::displayPreprocessedScreenShot() {
    NSImage* image = getImageFromBGRABuffer(testImage.imageData, testImage.imageWidth, testImage.imageHeight);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: image];
    });
}
void TestController::testPlayButton() {
    [targetImageView setImage:getImageFromBGRABuffer(playButton.imageData, playButton.imageWidth, playButton.imageHeight)];
    log(@"Testing Play Button Detection...");
    uint64 startTime = mach_absolute_time();
    float returnPercentage;
    Position playLocation;
    detectExactImageToImage(playButton, testImage, 0, 0, testImage.imageWidth, testImage.imageHeight, returnPercentage, playLocation, 0.5, true);
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Location: %d, %d with percentage %f%% and took %f seconds", playLocation.x, playLocation.y, returnPercentage*100, getTimeInMilliseconds(endTime-startTime)/1000.0]);
    
    //Highlight the areas of the image that match
    uint8* image = copyImageBuffer(testImage.imageData, testImage.imageWidth, testImage.imageHeight);
    ImageData imageData;
    imageData.imageData = image;
    imageData.imageWidth = testImage.imageWidth;
    imageData.imageHeight = testImage.imageHeight;
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(imageData, x, y);
            if ((x < playLocation.x || x > playLocation.x+playButton.imageWidth) || (y < playLocation.y || y > playLocation.y+playButton.imageHeight)) {
                pixel[0] /= 4;
                pixel[1] /= 4;
                pixel[2] /= 4;
                pixel[3] = 0;
            }
        }
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, playLocation.x, playLocation.y, playButton.imageWidth, playButton.imageHeight);
    [foundImageView setImage: getImageFromBGRABuffer(image2, playButton.imageWidth, playButton.imageHeight)];
}
/*
void TestController::testGameImage1() {
    
    [targetImageView setImage:getImageFromBGRABuffer(testGame1.imageData, testGame1.imageWidth, testGame1.imageHeight)];
    log(@"Testing Game Image 1 Detection...");
    uint64 startTime = mach_absolute_time();
    float returnPercentage;
    Position playLocation;
    detectExactImageToImage(testGame1, testImage, 0, 0, testImage.imageWidth, testImage.imageHeight, returnPercentage, playLocation, 0.5, true);
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Location: %d, %d with percentage %f%% and took %f seconds", playLocation.x, playLocation.y, returnPercentage*100, getTimeInMilliseconds(endTime-startTime)/1000.0]);
    
    //Highlight the areas of the image that match
    uint8* image = copyImageBuffer(testImage.imageData, testImage.imageWidth, testImage.imageHeight);
    ImageData imageData;
    imageData.imageData = image;
    imageData.imageWidth = testImage.imageWidth;
    imageData.imageHeight = testImage.imageHeight;
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(imageData, x, y);
            if ((x < playLocation.x || x > playLocation.x+testGame1.imageWidth) || (y < playLocation.y || y > playLocation.y+testGame1.imageHeight)) {
                pixel[0] /= 4;
                pixel[1] /= 4;
                pixel[2] /= 4;
                pixel[3] = 0;
            }
        }
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, playLocation.x, playLocation.y, testGame1.imageWidth, testGame1.imageHeight);
    [foundImageView setImage: getImageFromBGRABuffer(image2, testGame1.imageWidth, testGame1.imageHeight)];
}
*/

void TestController::testShopAvailable() {
    NSImage* image = getImageFromBGRABufferImageData(&testShopAvailable1280x800Image);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: image];
    });
}
void TestController::testShopOpen() {
    NSImage* image = getImageFromBGRABufferImageData(&testShopOpen1280x800Image);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: image];
    });
}
void TestController::testShopItems() {
    NSImage* image = getImageFromBGRABufferImageData(&testShopItems1280x800Image);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: image];
    });
}
void TestController::testInGameDetection() {
    NSImage* image = getImageFromBGRABufferImageData(&testInGameDetection1280x800Image);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: image];
    });
}
void TestController::testLevelUp() {
    NSImage* image = getImageFromBGRABufferImageData(&testLevelUp1280x800Image);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: image];
    });
}
void TestController::testAbilitiesActive() {
    NSImage* image = getImageFromBGRABufferImageData(&testAbilitiesActive1280x800Image);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: image];
    });
}
void TestController::testItemActives() {
    NSImage* image = getImageFromBGRABufferImageData(&testItemActives1280x800Image);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: image];
    });
}
void TestController::testSelfDetection() {
    testImage = testItemActives1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    
    
    
    
    //[targetImageView setImage:getImageFromBGRABuffer(SelfChampionManager::topRightImageData.imageData, SelfChampionManager::topRightImageData.imageWidth, SelfChampionManager::topRightImageData.imageHeight)];
    log(@"Testing Self Detection...");
    NSMutableArray* championBars = [NSMutableArray new];
    NSMutableArray* selfHealthBars = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            ChampionBar* championBar = SelfChampionManager::detectChampionBarAtPixel(testImage, pixel, x, y);
            if (championBar != nil) {
                [championBars addObject: [NSValue valueWithPointer:championBar]];
            }
            SelfHealthBar* selfHealthBar = SelfChampionManager::detectSelfHealthBarAtPixel(testImage, pixel, x, y);
            if (selfHealthBar != nil) {
                [selfHealthBars addObject: [NSValue valueWithPointer:selfHealthBar]];
            }
        }
    }
    championBars = SelfChampionManager::validateChampionBars(testImage, championBars);
    selfHealthBars = SelfChampionManager::validateSelfHealthBars(testImage, selfHealthBars);
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected self champions: %lu and self health bars: %lu in milliseconds: %d", [championBars count], [selfHealthBars count], getTimeInMilliseconds(endTime-startTime)]);
    
    //Highlight the areas of the image that match
    uint8* image = copyImageBuffer(testImage.imageData, testImage.imageWidth, testImage.imageHeight);
    ImageData imageData;
    imageData.imageData = image;
    imageData.imageWidth = testImage.imageWidth;
    imageData.imageHeight = testImage.imageHeight;
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(imageData, x, y);
            BOOL inChamp = false;
            for (NSValue* val in championBars) {
                ChampionBar* champ = (ChampionBar*)[val pointerValue];
                if (x >= champ->topLeft.x && x <= champ->bottomRight.x && y >= champ->topLeft.y && y <= champ->bottomRight.y) {
                    inChamp = true;
                }
            }
            for (NSValue* val in selfHealthBars) {
                SelfHealthBar* champ = (SelfHealthBar*)[val pointerValue];
                if (x >= champ->topLeft.x && x <= champ->bottomRight.x && y >= champ->topLeft.y && y <= champ->bottomRight.y) {
                    inChamp = true;
                }
            }
            if (inChamp == false) {
                pixel[0] /= 4;
                pixel[1] /= 4;
                pixel[2] /= 4;
                pixel[3] = 0;
            }
        }
    }
    for (NSValue* val in championBars) {
        ChampionBar* champ = (ChampionBar*)[val pointerValue];
        log([NSString stringWithFormat:@"Champion: %d, %d with health: %f", champ->topLeft.x, champ->topLeft.y, champ->health ]);
    }
    for (NSValue* val in selfHealthBars) {
        SelfHealthBar* champ = (SelfHealthBar*)[val pointerValue];
        log([NSString stringWithFormat:@"Self Health Bar: %d, %d with health: %f", champ->topLeft.x, champ->topLeft.y, champ->health ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([championBars count] > 0) {
        ChampionBar * champ = (ChampionBar*)[[championBars objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, champ->topLeft.x, champ->topLeft.y, champ->bottomRight.x - champ->topLeft.x, champ->bottomRight.y - champ->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, champ->bottomRight.x - champ->topLeft.x, champ->bottomRight.y - champ->topLeft.y)];
    }
}


void TestController::testAllyChampionDetection() {
    testImage = testShopAvailable1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    
    
    
    
    //[targetImageView setImage:getImageFromBGRABuffer(SelfChampionManager::topRightImageData.imageData, SelfChampionManager::topRightImageData.imageWidth, SelfChampionManager::topRightImageData.imageHeight)];
    log(@"Testing Ally Detection...");
    NSMutableArray* championBars = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            ChampionBar* championBar = AllyChampionManager::detectChampionBarAtPixel(testImage, pixel, x, y);
            if (championBar != nil) {
                [championBars addObject: [NSValue valueWithPointer:championBar]];
            }
        }
    }
    championBars = AllyChampionManager::validateChampionBars(testImage, championBars);
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected ally champions: %lu in milliseconds: %d", [championBars count], getTimeInMilliseconds(endTime-startTime)]);
    
    //Highlight the areas of the image that match
    uint8* image = copyImageBuffer(testImage.imageData, testImage.imageWidth, testImage.imageHeight);
    ImageData imageData;
    imageData.imageData = image;
    imageData.imageWidth = testImage.imageWidth;
    imageData.imageHeight = testImage.imageHeight;
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(imageData, x, y);
            BOOL inChamp = false;
            for (NSValue* val in championBars) {
                ChampionBar* champ = (ChampionBar*)[val pointerValue];
                if (x >= champ->topLeft.x && x <= champ->bottomRight.x && y >= champ->topLeft.y && y <= champ->bottomRight.y) {
                    inChamp = true;
                }
            }
            if (inChamp == false) {
                pixel[0] /= 4;
                pixel[1] /= 4;
                pixel[2] /= 4;
                pixel[3] = 0;
            }
        }
    }
    for (NSValue* val in championBars) {
        ChampionBar* champ = (ChampionBar*)[val pointerValue];
        log([NSString stringWithFormat:@"Ally Champion: %d, %d with health: %f", champ->topLeft.x, champ->topLeft.y, champ->health ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([championBars count] > 0) {
        ChampionBar * champ = (ChampionBar*)[[championBars objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, champ->topLeft.x, champ->topLeft.y, champ->bottomRight.x - champ->topLeft.x, champ->bottomRight.y - champ->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, champ->bottomRight.x - champ->topLeft.x, champ->bottomRight.y - champ->topLeft.y)];
    }
}

void TestController::testEnemyChampionDetection() {
    testImage = testItemActives1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    
    
    
    
    //[targetImageView setImage:getImageFromBGRABuffer(SelfChampionManager::topRightImageData.imageData, SelfChampionManager::topRightImageData.imageWidth, SelfChampionManager::topRightImageData.imageHeight)];
    log(@"Testing Enemy Detection...");
    NSMutableArray* championBars = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            ChampionBar* championBar = EnemyChampionManager::detectChampionBarAtPixel(testImage, pixel, x, y);
            if (championBar != nil) {
                [championBars addObject: [NSValue valueWithPointer:championBar]];
            }
        }
    }
    championBars = EnemyChampionManager::validateChampionBars(testImage, championBars);
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected enemy champions: %lu in milliseconds: %d", [championBars count], getTimeInMilliseconds(endTime-startTime)]);
    
    //Highlight the areas of the image that match
    uint8* image = copyImageBuffer(testImage.imageData, testImage.imageWidth, testImage.imageHeight);
    ImageData imageData;
    imageData.imageData = image;
    imageData.imageWidth = testImage.imageWidth;
    imageData.imageHeight = testImage.imageHeight;
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(imageData, x, y);
            BOOL inChamp = false;
            for (NSValue* val in championBars) {
                ChampionBar* champ = (ChampionBar*)[val pointerValue];
                if (x >= champ->topLeft.x && x <= champ->bottomRight.x && y >= champ->topLeft.y && y <= champ->bottomRight.y) {
                    inChamp = true;
                }
            }
            if (inChamp == false) {
                pixel[0] /= 4;
                pixel[1] /= 4;
                pixel[2] /= 4;
                pixel[3] = 0;
            }
        }
    }
    for (NSValue* val in championBars) {
        ChampionBar* champ = (ChampionBar*)[val pointerValue];
        log([NSString stringWithFormat:@"Enemy Champion: %d, %d with health: %f", champ->topLeft.x, champ->topLeft.y, champ->health ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([championBars count] > 0) {
        ChampionBar * champ = (ChampionBar*)[[championBars objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, champ->topLeft.x, champ->topLeft.y, champ->bottomRight.x - champ->topLeft.x, champ->bottomRight.y - champ->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, champ->bottomRight.x - champ->topLeft.x, champ->bottomRight.y - champ->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(EnemyChampionManager::healthSegmentImageData.imageData, EnemyChampionManager::healthSegmentImageData.imageWidth, EnemyChampionManager::healthSegmentImageData.imageHeight)];
}

void TestController::testEnemyMinionDetection() {
    testImage = testInGameDetection1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    
    
    
    
    //[targetImageView setImage:getImageFromBGRABuffer(SelfChampionManager::topRightImageData.imageData, SelfChampionManager::topRightImageData.imageWidth, SelfChampionManager::topRightImageData.imageHeight)];
    log(@"Testing Enemy Minion Detection...");
    NSMutableArray* minionBars = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            MinionBar* minionBar = EnemyMinionManager::detectMinionBarAtPixel(testImage, pixel, x, y);
            if (minionBar != nil) {
                [minionBars addObject: [NSValue valueWithPointer:minionBar]];
            }
        }
    }
    minionBars = EnemyMinionManager::validateMinionBars(testImage, minionBars);
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected enemy minions: %lu in milliseconds: %d", [minionBars count], getTimeInMilliseconds(endTime-startTime)]);
    
    //Highlight the areas of the image that match
    uint8* image = copyImageBuffer(testImage.imageData, testImage.imageWidth, testImage.imageHeight);
    ImageData imageData;
    imageData.imageData = image;
    imageData.imageWidth = testImage.imageWidth;
    imageData.imageHeight = testImage.imageHeight;
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(imageData, x, y);
            BOOL inChamp = false;
            for (NSValue* val in minionBars) {
                MinionBar* minion = (MinionBar*)[val pointerValue];
                if (x >= minion->topLeft.x && x <= minion->bottomRight.x && y >= minion->topLeft.y && y <= minion->bottomRight.y) {
                    inChamp = true;
                }
            }
            if (inChamp == false) {
                pixel[0] /= 4;
                pixel[1] /= 4;
                pixel[2] /= 4;
                pixel[3] = 0;
            }
        }
    }
    for (NSValue* val in minionBars) {
        MinionBar* minion = (MinionBar*)[val pointerValue];
        log([NSString stringWithFormat:@"Enemy Minion: %d, %d with health: %f", minion->topLeft.x, minion->topLeft.y, minion->health ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([minionBars count] > 0) {
        MinionBar * minion = (MinionBar*)[[minionBars objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, minion->topLeft.x, minion->topLeft.y, minion->bottomRight.x - minion->topLeft.x, minion->bottomRight.y - minion->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, minion->bottomRight.x - minion->topLeft.x, minion->bottomRight.y - minion->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(EnemyMinionManager::healthSegmentImageData.imageData, EnemyMinionManager::healthSegmentImageData.imageWidth, EnemyMinionManager::healthSegmentImageData.imageHeight)];
}

void TestController::testAllyMinionDetection() {
    testImage = testInGameDetection1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    
    
    
    
    //[targetImageView setImage:getImageFromBGRABuffer(SelfChampionManager::topRightImageData.imageData, SelfChampionManager::topRightImageData.imageWidth, SelfChampionManager::topRightImageData.imageHeight)];
    log(@"Testing Ally Minion Detection...");
    NSMutableArray* minionBars = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            MinionBar* minionBar = AllyMinionManager::detectMinionBarAtPixel(testImage, pixel, x, y);
            if (minionBar != nil) {
                [minionBars addObject: [NSValue valueWithPointer:minionBar]];
            }
        }
    }
    minionBars = AllyMinionManager::validateMinionBars(testImage, minionBars);
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected ally minions: %lu in milliseconds: %d", [minionBars count], getTimeInMilliseconds(endTime-startTime)]);
    
    //Highlight the areas of the image that match
    uint8* image = copyImageBuffer(testImage.imageData, testImage.imageWidth, testImage.imageHeight);
    ImageData imageData;
    imageData.imageData = image;
    imageData.imageWidth = testImage.imageWidth;
    imageData.imageHeight = testImage.imageHeight;
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(imageData, x, y);
            BOOL inChamp = false;
            for (NSValue* val in minionBars) {
                MinionBar* minion = (MinionBar*)[val pointerValue];
                if (x >= minion->topLeft.x && x <= minion->bottomRight.x && y >= minion->topLeft.y && y <= minion->bottomRight.y) {
                    inChamp = true;
                }
            }
            if (inChamp == false) {
                pixel[0] /= 4;
                pixel[1] /= 4;
                pixel[2] /= 4;
                pixel[3] = 0;
            }
        }
    }
    for (NSValue* val in minionBars) {
        MinionBar* minion = (MinionBar*)[val pointerValue];
        log([NSString stringWithFormat:@"Ally Minion: %d, %d with health: %f", minion->topLeft.x, minion->topLeft.y, minion->health ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([minionBars count] > 0) {
        MinionBar * minion = (MinionBar*)[[minionBars objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, minion->topLeft.x, minion->topLeft.y, minion->bottomRight.x - minion->topLeft.x, minion->bottomRight.y - minion->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, minion->bottomRight.x - minion->topLeft.x, minion->bottomRight.y - minion->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(AllyMinionManager::healthSegmentImageData.imageData, AllyMinionManager::healthSegmentImageData.imageWidth, AllyMinionManager::healthSegmentImageData.imageHeight)];
}


void TestController::log(NSString* string) {
    [[logText textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", string]]];
    [logText scrollRangeToVisible: NSMakeRange(logText.string.length, 0)];
}
