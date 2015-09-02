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
    testEnemyTower1280x800Image = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Test Images/Test Enemy Tower Detection 1280x800" ofType:@"png"]);
    testLevelUpDot1280x800Image = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Test Images/Test Level Up Dot 1280x800" ofType:@"png"]);
    testUsedPotion1280x800 = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Test Images/Test Used Potion 1280x800" ofType:@"png"]);
    testOutsideImage1280x800 = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Test Images/Test Outside Image 1280x800" ofType:@"png"]);
    
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
    testImage = testOutsideImage1280x800;
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
    NSLog(@"Preprocessed minions: %lu", (unsigned long)[minionBars count]);
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

void TestController::testEnemyTowerDetection() {
    testImage = testEnemyTower1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    
    
    
    
    //[targetImageView setImage:getImageFromBGRABuffer(SelfChampionManager::topRightImageData.imageData, SelfChampionManager::topRightImageData.imageWidth, SelfChampionManager::topRightImageData.imageHeight)];
    log(@"Testing Enemy Tower Detection...");
    NSMutableArray* towerBars = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            TowerBar* towerBar = EnemyTowerManager::detectTowerBarAtPixel(testImage, pixel, x, y);
            if (towerBar != nil) {
                [towerBars addObject: [NSValue valueWithPointer:towerBar]];
            }
        }
    }
    towerBars = EnemyTowerManager::validateTowerBars(testImage, towerBars);
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected enemy towers: %lu in milliseconds: %d", [towerBars count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in towerBars) {
                TowerBar* tower = (TowerBar*)[val pointerValue];
                if (x >= tower->topLeft.x && x <= tower->bottomRight.x && y >= tower->topLeft.y && y <= tower->bottomRight.y) {
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
    for (NSValue* val in towerBars) {
        TowerBar* tower = (TowerBar*)[val pointerValue];
        log([NSString stringWithFormat:@"Enemy Tower: %d, %d with health: %f", tower->topLeft.x, tower->topLeft.y, tower->health ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([towerBars count] > 0) {
        TowerBar * tower = (TowerBar*)[[towerBars objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, tower->topLeft.x, tower->topLeft.y, tower->bottomRight.x - tower->topLeft.x, tower->bottomRight.y - tower->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, tower->bottomRight.x - tower->topLeft.x, tower->bottomRight.y - tower->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(EnemyTowerManager::healthSegmentImageData.imageData, EnemyTowerManager::healthSegmentImageData.imageWidth, EnemyTowerManager::healthSegmentImageData.imageHeight)];
}
void TestController::testLevelUpDetection() {
    testImage = testShopAvailable1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(AbilityManager::levelUpImageData.imageData, AbilityManager::levelUpImageData.imageWidth, AbilityManager::levelUpImageData.imageHeight)];
    log(@"Testing Level Up Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = AbilityManager::detectLevelUpAtPixel(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected level ups: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Level Up: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(AbilityManager::levelUpImageData.imageData, AbilityManager::levelUpImageData.imageWidth, AbilityManager::levelUpImageData.imageHeight)];
}
void TestController::testLevelDotDetection() {
    testImage = testLevelUpDot1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(AbilityManager::levelDotImageData.imageData, AbilityManager::levelDotImageData.imageWidth, AbilityManager::levelDotImageData.imageHeight)];
    log(@"Testing Level Dot Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = AbilityManager::detectLevelDotAtPixel(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected level dots: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Level Dot: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(AbilityManager::levelDotImageData.imageData, AbilityManager::levelDotImageData.imageWidth, AbilityManager::levelDotImageData.imageHeight)];
}
void TestController::testEnabledAbilityDetection() {
    testImage = testLevelUpDot1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(AbilityManager::abilityEnabledImageData.imageData, AbilityManager::abilityEnabledImageData.imageWidth, AbilityManager::abilityEnabledImageData.imageHeight)];
    log(@"Testing Enabled Ability Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = AbilityManager::detectEnabledAbilityAtPixel(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected enabled abilities: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Enabled ability: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(AbilityManager::abilityEnabledImageData.imageData, AbilityManager::abilityEnabledImageData.imageWidth, AbilityManager::abilityEnabledImageData.imageHeight)];
}
void TestController::testEnabledSummonerSpellDetection() {
    testImage = testAbilitiesActive1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(AbilityManager::enabledSummonerSpellImageData.imageData, AbilityManager::enabledSummonerSpellImageData.imageWidth, AbilityManager::enabledSummonerSpellImageData.imageHeight)];
    log(@"Testing Enabled Summoner Spell Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = AbilityManager::detectEnabledSummonerSpellAtPixel(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected enabled summoner spells: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Enabled summoner spell: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(AbilityManager::enabledSummonerSpellImageData.imageData, AbilityManager::enabledSummonerSpellImageData.imageWidth, AbilityManager::enabledSummonerSpellImageData.imageHeight)];
}

void TestController::testTrinketActiveDetection() {
    testImage = testAbilitiesActive1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(ItemManager::trinketItemImageData.imageData, ItemManager::trinketItemImageData.imageWidth, ItemManager::trinketItemImageData.imageHeight)];
    log(@"Testing Trinket Active Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = ItemManager::detectTrinketActiveAtPixel(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected active trinkets: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Trinket active: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(ItemManager::trinketItemImageData.imageData, ItemManager::trinketItemImageData.imageWidth, ItemManager::trinketItemImageData.imageHeight)];
}
void TestController::testItemActiveDetection() {
    testImage = testItemActives1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(ItemManager::itemImageData.imageData, ItemManager::itemImageData.imageWidth, ItemManager::itemImageData.imageHeight)];
    log(@"Testing Item Active Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = ItemManager::detectItemActiveAtPixel(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected active items: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Item active: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(ItemManager::itemImageData.imageData, ItemManager::itemImageData.imageWidth, ItemManager::itemImageData.imageHeight)];
}
void TestController::testPotionActiveDetection() {
    testImage = testItemActives1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(ItemManager::potionImageData.imageData, ItemManager::potionImageData.imageWidth, ItemManager::potionImageData.imageHeight)];
    log(@"Testing Potion Active Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = ItemManager::detectPotionActiveAtPixel(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected active potions: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Potion active: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(ItemManager::potionImageData.imageData, ItemManager::potionImageData.imageWidth, ItemManager::potionImageData.imageHeight)];
}
void TestController::testUsedPotionActiveDetection() {
    testImage = testUsedPotion1280x800;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(ItemManager::usedPotionImageData.imageData, ItemManager::usedPotionImageData.imageWidth, ItemManager::usedPotionImageData.imageHeight)];
    log(@"Testing Used Potions Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = ItemManager::detectUsedPotionAtPixel(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected used potions: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Used potion: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(ItemManager::usedPotionImageData.imageData, ItemManager::usedPotionImageData.imageWidth, ItemManager::usedPotionImageData.imageHeight)];
}

void TestController::testShopAvailable() {
    testImage = testShopAvailable1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(ShopManager::shopAvailableImageData.imageData, ShopManager::shopAvailableImageData.imageWidth, ShopManager::shopAvailableImageData.imageHeight)];
    log(@"Testing Shop Available Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = ShopManager::detectShopAvailable(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected shop available: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Shop available: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(ShopManager::shopAvailableImageData.imageData, ShopManager::shopAvailableImageData.imageWidth, ShopManager::shopAvailableImageData.imageHeight)];
}
void TestController::testShopTopLeftCorner() {
    testImage = testShopOpen1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(ShopManager::shopTopLeftCornerImageData.imageData, ShopManager::shopTopLeftCornerImageData.imageWidth, ShopManager::shopTopLeftCornerImageData.imageHeight)];
    log(@"Testing Shop Top Left Corner Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = ShopManager::detectShopTopLeftCorner(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected shop top left corner: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Shop top left corner: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(ShopManager::shopTopLeftCornerImageData.imageData, ShopManager::shopTopLeftCornerImageData.imageWidth, ShopManager::shopTopLeftCornerImageData.imageHeight)];
}
void TestController::testShopBottomLeftCorner() {
    testImage = testShopOpen1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(ShopManager::shopBottomLeftCornerImageData.imageData, ShopManager::shopBottomLeftCornerImageData.imageWidth, ShopManager::shopBottomLeftCornerImageData.imageHeight)];
    log(@"Testing Shop Bottom Left Corner Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = ShopManager::detectShopBottomLeftCorner(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected shop bottom left corner: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Shop bottom left corner: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(ShopManager::shopBottomLeftCornerImageData.imageData, ShopManager::shopBottomLeftCornerImageData.imageWidth, ShopManager::shopBottomLeftCornerImageData.imageHeight)];
}
void TestController::testShopBuyableItems() {
    testImage = testShopItems1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(ShopManager::shopBuyableItemTopLeftCornerImageData.imageData, ShopManager::shopBuyableItemTopLeftCornerImageData.imageWidth, ShopManager::shopBuyableItemTopLeftCornerImageData.imageHeight)];
    log(@"Testing Shop Buyable Item Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = ShopManager::detectBuyableItems(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected shop buyable items: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Shop buyable item: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(ShopManager::shopBuyableItemTopLeftCornerImageData.imageData, ShopManager::shopBuyableItemTopLeftCornerImageData.imageWidth, ShopManager::shopBuyableItemTopLeftCornerImageData.imageHeight)];
}

void TestController::testMapDetection() {
    testImage = testInGameDetection1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(MapManager::mapTopLeftCornerImageData.imageData, MapManager::mapTopLeftCornerImageData.imageWidth, MapManager::mapTopLeftCornerImageData.imageHeight)];
    log(@"Testing Map Top Left Corner Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = MapManager::detectMap(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Detected maps: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Map: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(MapManager::mapTopLeftCornerImageData.imageData, MapManager::mapTopLeftCornerImageData.imageWidth, MapManager::mapTopLeftCornerImageData.imageHeight)];
}
void TestController::testMapShopDetection() {
    testImage = testInGameDetection1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(MapManager::shopIconImageData.imageData, MapManager::shopIconImageData.imageWidth, MapManager::shopIconImageData.imageHeight)];
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = MapManager::detectShop(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Shops: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Shop: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(MapManager::shopIconImageData.imageData, MapManager::shopIconImageData.imageWidth, MapManager::shopIconImageData.imageHeight)];
}
void TestController::testMapLocationDetection() {
    testImage = testInGameDetection1280x800Image;
    NSImage* nsimage = getImageFromBGRABufferImageData(&testImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [unprocessedImageView setImage: nsimage];
    });
    
    
    [targetImageView setImage:getImageFromBGRABuffer(MapManager::locationTopLeftCornerImageData.imageData, MapManager::locationTopLeftCornerImageData.imageWidth, MapManager::locationTopLeftCornerImageData.imageHeight)];
    log(@"Testing Map Location Detection...");
    NSMutableArray* levelups = [NSMutableArray new];
    uint64 startTime = mach_absolute_time();
    
    for (int x = 0; x < testImage.imageWidth; x++) {
        for (int y = 0; y < testImage.imageHeight; y++) {
            uint8* pixel = getPixel2(testImage, x, y);
            GenericObject* levelup = MapManager::detectLocation(testImage, pixel, x, y);
            if (levelup != nil) {
                [levelups addObject: [NSValue valueWithPointer:levelup]];
            }
        }
    }
    uint64 endTime = mach_absolute_time();
    log([NSString stringWithFormat:@"Results -- Map locations: %lu in milliseconds: %d", [levelups count], getTimeInMilliseconds(endTime-startTime)]);
    
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
            for (NSValue* val in levelups) {
                GenericObject* levelup = (GenericObject*)[val pointerValue];
                if (x >= levelup->topLeft.x && x <= levelup->bottomRight.x && y >= levelup->topLeft.y && y <= levelup->bottomRight.y) {
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
    for (NSValue* val in levelups) {
        GenericObject* levelup = (GenericObject*)[val pointerValue];
        log([NSString stringWithFormat:@"Map Location: %d, %d", levelup->topLeft.x, levelup->topLeft.y ]);
    }
    [processedImageView setImage: getImageFromBGRABuffer(imageData.imageData, imageData.imageWidth, imageData.imageHeight)];
    
    if ([levelups count] > 0) {
        GenericObject * levelup = (GenericObject*)[[levelups objectAtIndex:0] pointerValue];
        uint8* image2 = copyImageBufferSection(testImage.imageData, testImage.imageWidth, testImage.imageHeight, levelup->topLeft.x, levelup->topLeft.y, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y);
        [foundImageView setImage: getImageFromBGRABuffer(image2, levelup->bottomRight.x - levelup->topLeft.x, levelup->bottomRight.y - levelup->topLeft.y)];
    }
    
    [targetImageView setImage:getImageFromBGRABuffer(MapManager::locationTopLeftCornerImageData.imageData, MapManager::locationTopLeftCornerImageData.imageWidth, MapManager::locationTopLeftCornerImageData.imageHeight)];
}


void TestController::log(NSString* string) {
    [[logText textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", string]]];
    [logText scrollRangeToVisible: NSMakeRange(logText.string.length, 0)];
}
