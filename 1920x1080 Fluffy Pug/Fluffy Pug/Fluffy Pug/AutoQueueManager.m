//
//  AutoQueueManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/13/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "AutoQueueManager.h"

AutoQueueManager::AutoQueueManager(LeagueGameState* gameState) {
    leagueGameState = gameState;
    
    step1_PlayButton = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(1) Play Button" ofType:@"png"]);
    step2_PVPMode = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(2) PVP Mode" ofType:@"png"]);
    step3_ClassicMode = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(3) Classic Mode" ofType:@"png"]);
    step4_SummonersRiftMode = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(4) Summoner's Rift Mode" ofType:@"png"]);
    step5_BlindPickMode = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(5) Blind Pick Mode" ofType:@"png"]);
    step6_SoloButton = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(6) Solo Button" ofType:@"png"]);
    step7_AcceptButton = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(7) Accept Button" ofType:@"png"]);
    step8_RandomChampionButton = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(8) Random Champion Button" ofType:@"png"]);
    step9_LockInButton = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(9) Lock In Button" ofType:@"png"]);
    step10_ChooseSkinButton = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(10) Choose Skin Button" ofType:@"png"]);
    step11_EndGameContinueButton = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(11) End Game Continue Button" ofType:@"png"]);
    step12_HomeButton = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(12) Home Button" ofType:@"png"]);
    step13_ReconnectButton = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/(13) Reconnect Button" ofType:@"png"]);
    reportedButton = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/Reported Button" ofType:@"png"]);
    
    //testImage1 = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/TestGame1" ofType:@"png"]);
    //testImage2 = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/TestGame2" ofType:@"png"]);
    
    //lastScreenScan = clock();
    //lastEndGameScan = clock();
    
    actionClick = mach_absolute_time();
    lastHomeButtonClick = mach_absolute_time();
    
    currentAwakeTime = mach_absolute_time();
    currentSleepTime  = mach_absolute_time();
    currentPlayTime  = mach_absolute_time();
    currentBreakTime  = mach_absolute_time();
    busySleeping = false;
    busyTakingBreak = false;
    
    
    reset(false);
}
void AutoQueueManager::reset(bool keepPlayButton) {
    if (!keepPlayButton) {
        foundPlayButton = false;
        detectionPlayButtonReferenceLocation.x = -1;
    }
    foundAcceptButton = false, foundRandomChampionButton = false, foundLockInButton = false, foundChooseSkinButton = false, foundReconnectButton = false, foundHomeButton = false, foundEndGameButton = false, foundNormalBlindPickButton = false, foundReportedButton = false;
    scanForPlayButton = false, scanForAcceptButton = false, scanForRandomChampionButton = false, scanForLockInButton = false, scanForChooseSkinButton = false, scanForReconnectButton = false, scanForHomeButton = false, scanForEndGameButton = false, scanForNormalBlindPick = false, scanForReportedButton = true;
    
    currentStep = STEP_1;
    scanForPlayButton = true;
    reportedScanCurrentChunkX = 0;
    reportedScanCurrentChunkY = 0;
    actionClick = mach_absolute_time();
    lastHomeButtonClick = mach_absolute_time();
    scanReportedLastTime = mach_absolute_time();
}
void AutoQueueManager::processLogic() {
    
    if (!busySleeping) {
        if (getTimeInMilliseconds(mach_absolute_time() - currentAwakeTime) >= awakeTime) {
            //We've been away for too long, tired, need to sleep
            busySleeping = true;
            currentSleepTime = mach_absolute_time();
        }
        if (!busyTakingBreak && getTimeInMilliseconds(mach_absolute_time() - currentPlayTime) >= playTime) {
            //We've played for too long, time to take a break, pee
            busyTakingBreak = true;
            currentBreakTime = mach_absolute_time();
        }
        if (busyTakingBreak && getTimeInMilliseconds(mach_absolute_time() - currentBreakTime) >= breakTime) {
            //Done with break, lets get back to playing
            busyTakingBreak = false;
            currentPlayTime = mach_absolute_time();
        }
    } else {
        if (getTimeInMilliseconds(mach_absolute_time() - currentSleepTime) >= sleepTime) {
            //Refreshed, lets play again
            currentAwakeTime = mach_absolute_time();
            currentSleepTime  = mach_absolute_time();
            currentPlayTime  = mach_absolute_time();
            currentBreakTime  = mach_absolute_time();
            busySleeping = false;
            busyTakingBreak = false;
        }
    }
    
    if (leagueGameState->leaguePID == -1 && (busySleeping || busyTakingBreak) && (currentStep == STEP_1 || currentStep == STEP_2 || currentStep == STEP_3 || currentStep == STEP_4 || currentStep == STEP_5)) {
        //Sleep or take a break
        return;
    }
    
    
    
    if (foundPlayButton && currentStep != STEP_1 && currentStep != STEP_2) {
        reset(true);
    }
    
    if (leagueGameState->leaguePID != -1) {
        currentStep = STEP_11;
    } else if (currentStep == STEP_11) currentStep = STEP_12;
    
    if (getTimeInMilliseconds(mach_absolute_time() - actionClick) >= 1000) {
        if (foundReportedButton) {
            tapMouseLeft(reportedButtonLocation.x+10, reportedButtonLocation.y+10);
            actionClick = mach_absolute_time();
            foundReportedButton = false;
        }
        
        switch (currentStep) {
            case STEP_1: {
                if (foundPlayButton)  {
                    currentStep = STEP_2;
                    clickLocation(playButtonLocation.x, playButtonLocation.y);
                    actionClick = mach_absolute_time();
                }
            }break;
            case STEP_2: {
                //Click PVP mode
                if (!foundPlayButton) { //Do next step cause no play button visible
                    currentStep = STEP_3;
                    clickLocation(playButtonLocation.x -230, playButtonLocation.y +75);
                    actionClick = mach_absolute_time();
                }
            }break;
            case STEP_3: {
                //Click Classic mode - Now it's One for ALl mode
                currentStep = STEP_4;
                clickLocation(playButtonLocation.x -70, playButtonLocation.y +105 + 20 * 3);
                actionClick = mach_absolute_time();
            }break;
            case STEP_4: {
                //Click Summoner's Rift mode
                currentStep = STEP_5;
                clickLocation(playButtonLocation.x +100, playButtonLocation.y +110);
                scanForNormalBlindPick = true;
                foundNormalBlindPickButton = false;
                actionClick = mach_absolute_time();
            }break;
            case STEP_5: {
                scanForNormalBlindPick = false;
                currentStep = STEP_6;
                clickLocation(playButtonLocation.x +100 + 150, playButtonLocation.y +110);
                actionClick = mach_absolute_time();
                
                
                //Click Blind Pick mode
                /*
                 if (foundNormalBlindPickButton) {
                 clickLocation(normalBlindPickLocation.x + 5, normalBlindPickLocation.y + 5);
                 scanForNormalBlindPick = false;
                 currentStep = STEP_6;
                 actionClick = mach_absolute_time();
                 }*/
                //clickLocation(playButtonLocation.x +300, playButtonLocation.y +180);
            }break;
            case STEP_6: {
                //Click Solo Button
                currentStep = STEP_7;
                clickLocation(playButtonLocation.x +100, playButtonLocation.y +550);
                scanForAcceptButton = true;
                actionClick = mach_absolute_time();
            }break;
            case STEP_7: {
                if (foundAcceptButton) {
                    //Click accept button
                    currentStep = STEP_8;
                    clickLocation(acceptButtonLocation.x, acceptButtonLocation.y);
                    scanForRandomChampionButton = true;
                    actionClick = mach_absolute_time();
                }
            }break;
            case STEP_8: {
                
                if (foundAcceptButton) {
                    //Wait for accept button to disappear
                    //NSLog(@"Clicking accept button");
                    clickLocation(acceptButtonLocation.x, acceptButtonLocation.y);
                    actionClick = mach_absolute_time();
                    break;
                }
                if (foundRandomChampionButton) {
                    //Click random champion button
                    currentStep = STEP_9;
                    //NSLog(@"Clicking random champion button %d, %d", randomChampionButtonLocation.x, randomChampionButtonLocation.y);
                    clickLocation(randomChampionButtonLocation.x, randomChampionButtonLocation.y);
                    scanForRandomChampionButton = false;
                    scanForLockInButton = true;
                    actionClick = mach_absolute_time();
                }
            }break;
            case STEP_9: {
                if (foundAcceptButton) {
                    //Go back to step 7 because someone queue dodged
                    currentStep = STEP_7;
                    break;
                }
                if (foundLockInButton) {
                    //Click lock in button
                    clickLocation(lockInButtonLocation.x, lockInButtonLocation.y);
                    currentStep = STEP_10;
                    scanForReconnectButton = true;
                    scanForChooseSkinButton = true;
                    scanForLockInButton = false;
                    actionClick = mach_absolute_time();
                }
            }break;
            case STEP_10: {
                if (foundAcceptButton) {
                    //Go back to step 7 because someone queue dodged
                    currentStep = STEP_7;
                    break;
                }
                if (foundReconnectButton) {
                    clickLocation(reconnectButtonLocation.x, reconnectButtonLocation.y);
                    actionClick = mach_absolute_time();
                    break;
                }
                if (foundChooseSkinButton) {
                    clickLocation(chooseSkinButtonLocation.x, chooseSkinButtonLocation.y);
                    actionClick = mach_absolute_time();
                } else {
                    //Entering Game
                    currentStep = STEP_11;
                    scanForChooseSkinButton = false;
                    scanForLockInButton = false;
                    scanForAcceptButton = false;
                    scanForHomeButton = true;
                    scanForReportedButton = false;
                }
            }break;
                
            case STEP_11: {
                if (foundEndGameButton) {
                    clickLocation(endGameButtonLocation.x, endGameButtonLocation.y);
                    currentStep = STEP_12;
                    scanForHomeButton = true;
                    foundHomeButton = false;
                    actionClick = mach_absolute_time();
                    scanForReportedButton = true;
                    //NSLog(@"Finished step 11, moving to step 12.");
                }
            }break;
            case STEP_12: {
                //NSLog(@"Waiting on step 12");
                //Wait 10 seconds
                if (foundHomeButton && getTimeInMilliseconds(mach_absolute_time() - lastHomeButtonClick) >= 10000) {
                    lastHomeButtonClick = mach_absolute_time();
                    //Wait 2 seconds initially
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC * 2), dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        //Move mouse to button
                        moveMouse(homeButtonLocation.x + 10, homeButtonLocation.y+10);
                        //Wait one second
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            //Move mous e slightly to highlight button
                            moveMouse(homeButtonLocation.x + 15, homeButtonLocation.y+15);
                            //Wait one second
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                //Hold down left button
                                tapMouseLeft(homeButtonLocation.x + 10, homeButtonLocation.y+10);
                                //Wait half second
                                //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC / 2), dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // one second
                                    //Release mouse button
                                    //releaseMouseLeft(homeButtonLocation.x + 10, homeButtonLocation.y+10);
                                    //reset(false);
                                //});
                            });
                        });
                    });
                }
            }break;
        }
    }
}
void AutoQueueManager::clickLocation(int x, int y) {
    doubleTapMouseLeft(x + 10, y+10);
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC / 2000.0), dispatch_get_main_queue(), ^{ // one
    //    floatTapMouseLeft(x + 10, y+10);
    //});
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC / 2000.0), dispatch_get_main_queue(), ^{ // one
    dispatch_async(dispatch_get_main_queue(), ^{
        moveMouse(0, 0);
    });
}
void AutoQueueManager::processEndGameDetection(ImageData data) {
    foundEndGameButton = false;
    //if (scanForEndGameButton) {
    ////NSLog(@"Searching for end game");
    float returnPercentage = 0.0;
    Position returnPosition;
    int xStart = data.imageWidth/2 - 200;
    int yStart = data.imageHeight * 0.68125 - 200;
    int xEnd = data.imageWidth/2 + 200;
    int yEnd = data.imageHeight * 0.68125 + 200;
    detectExactImageToImage(step11_EndGameContinueButton, data, xStart, yStart, xEnd, yEnd, returnPercentage, returnPosition, 0.5, true);
    ////NSLog(@"percentage returned: %f", returnPercentage);
    if (returnPercentage >= 0.6) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ////NSLog(@"Found end game");
            foundEndGameButton = true;
            endGameButtonLocation = returnPosition;
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            foundEndGameButton = false;
        });
    }
    
    //}
}
bool AutoQueueManager::processDetection(ImageData data, const CGRect* rects, size_t num_rects) {
    
    if (leagueGameState->leaguePID == -1 && (busySleeping || busyTakingBreak) && (currentStep == STEP_1 || currentStep == STEP_2 || currentStep == STEP_3 || currentStep == STEP_4 || currentStep == STEP_5)) {
        //Sleep or take a break
        return false;
    }
    
    /*
     dispatch_group_t dispatchGroup = dispatch_group_create();
     
     
     dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
     dispatch_group_async(dispatchGroup, queue, ^{
     float returnPercentage3 = 0.0;
     Position returnPosition3;
     int xStart2 = 0;
     int yStart2 = 0;
     int xEnd2 = data.imageWidth;
     int yEnd2 = data.imageHeight;
     CGRect search2 = CGRectMake(xStart2, yStart2, xEnd2 - xStart2, yEnd2-yStart2);
     size_t intersectRectsNum2;
     CGRect* intersectSearch2 = getIntersectionRectangles(search2, rects, num_rects, intersectRectsNum2);
     
     detectExactImageToImageToRectangles(testImage1, data, intersectSearch2, intersectRectsNum2, returnPercentage3, returnPosition3, 0.9, true);
     
     if (returnPercentage3 > 0.9) {
     clickLocation(returnPosition3.x, returnPosition3.y);
     }
     });
     
     queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
     dispatch_group_async(dispatchGroup, queue, ^{
     float returnPercentage3 = 0.0;
     Position returnPosition3;
     int xStart2 = 0;
     int yStart2 = 0;
     int xEnd2 = data.imageWidth;
     int yEnd2 = data.imageHeight;
     CGRect search2 = CGRectMake(xStart2, yStart2, xEnd2 - xStart2, yEnd2-yStart2);
     size_t intersectRectsNum2;
     CGRect* intersectSearch2 = getIntersectionRectangles(search2, rects, num_rects, intersectRectsNum2);
     
     detectExactImageToImageToRectangles(testImage2, data, intersectSearch2, intersectRectsNum2, returnPercentage3, returnPosition3, 0.9, true);
     ////NSLog(@"Test image 1: %f", returnPercentage3);
     if (returnPercentage3 > 0.9) {
     clickLocation(returnPosition3.x, returnPosition3.y);
     }
     });
     dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER);
     //To speed up the search we will use the CGRectIntersection function, cut down on the search area
     //We will also make each detection run on a separate thread for extra speeds
     */
    
    
    __block volatile bool fireLogic = false;
    
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    if (scanForPlayButton) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_group_async(dispatchGroup, queue, ^{
            
            
            float returnPercentage = 0.0;
            Position returnPosition;
            int xStart = 300;
            int yStart = 0;
            int xEnd = data.imageWidth - 400;
            int yEnd = 250;
            CGRect search = CGRectMake(xStart, yStart, xEnd - xStart, yEnd-yStart);
            //size_t intersectRectsNum;
            //CGRect* intersectSearch = getIntersectionRectangles(search, rects, num_rects, intersectRectsNum);
            
            detectExactImageToImageToRectangle(step1_PlayButton, data, search, returnPercentage, returnPosition, 0.83, true);
            //detectExactImageToImageToRectangles(step1_PlayButton, data, intersectSearch, intersectRectsNum, returnPercentage, returnPosition, 0.83, true);
            
            ////NSLog(@"Play button percentage: %f", returnPercentage);
            
            if (returnPercentage >= 0.3) {
                detectionPlayButtonReferenceLocation = returnPosition;
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundPlayButton = true;
                    playButtonLocation = returnPosition;
                });
                fireLogic = true;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundPlayButton = false;
                });
            }
            
        });
    }
    
    
    
    
    if (scanForReportedButton && !foundReportedButton) {
        int scanChunksX = 30;
        int scanChunksY = 30;
        float leagueGameWidth = data.imageWidth;
        float leagueGameHeight = data.imageHeight;
        CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
        
        int scanStartX = 0; int scanStartY = 0;
        int scanEndX = leagueGameWidth; int scanEndY = leagueGameHeight;
        int scanWidth = (scanEndX - scanStartX) / scanChunksX;
        int scanHeight = (scanEndY - scanStartY) / scanChunksY;
        
        int framesPassed = (getTimeInMilliseconds(mach_absolute_time() - scanReportedLastTime)) / 16;
        if (framesPassed <= 0) framesPassed = 1;
        if (framesPassed > scanChunksX * scanChunksY) framesPassed = scanChunksX * scanChunksY;
        if (framesPassed > 15) framesPassed = 15;
        
        NSMutableArray* scanRectangles = [NSMutableArray new];
        //Increase the scan chunk by 1
        for (int i = 0; i < framesPassed; i++) {
            reportedScanCurrentChunkX += 1;
            if (reportedScanCurrentChunkX >= scanChunksX) {
                reportedScanCurrentChunkX = 0;
                reportedScanCurrentChunkY++;
            }
            if (reportedScanCurrentChunkY >= scanChunksY) {
                reportedScanCurrentChunkY = 0;
            }
            //Add chunk to scan
            CGRect scanRect = CGRectMake( scanWidth * reportedScanCurrentChunkX + scanStartX ,
                                         scanHeight * reportedScanCurrentChunkY + scanStartY ,
                                         scanWidth ,
                                         scanHeight );
            scanRect = CGRectIntegral(scanRect);
            scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
            combineRectangles(scanRectangles, scanRect);
        }
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        foundReportedButton = false;
        dispatch_group_async(dispatchGroup, queue, ^{
            
            //int xStart = detectionPlayButtonReferenceLocation.x-120;
            //int yStart = detectionPlayButtonReferenceLocation.y+300;
            //int xEnd = detectionPlayButtonReferenceLocation.x+180;
            //int yEnd = detectionPlayButtonReferenceLocation.y+450;
            //int xStart = 0;
            //int yStart = 0;
            //int xEnd = data.imageWidth;
            //int yEnd = data.imageHeight;
            
            //Loop through scan chunks
            for (int i = 0; i < [scanRectangles count]; i++) {
                CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
                for (int x = rect.origin.x; x < rect.origin.x + rect.size.width; x++) {
                    for (int y = rect.origin.y; y < rect.origin.y + rect.size.height; y++) {
                        if (x + reportedButton.imageWidth < data.imageWidth && y + reportedButton.imageHeight < data.imageHeight &&
                            x + reportedButton.imageWidth >= 0 && y + reportedButton.imageHeight >= 0) {
                            if (getImageAtPixelPercentageOptimizedExact(getPixel2(data, x, y), x, y, data.imageWidth, data.imageHeight, reportedButton, 0.40) >=  0.7) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    foundReportedButton = true;
                                    reportedButtonLocation.x = x+50;
                                    reportedButtonLocation.y = y+10;
                                });
                                fireLogic = true;
                                x = rect.origin.x + rect.size.width;
                                y = rect.origin.y + rect.size.height;
                                i = (int)[scanRectangles count];
                            }
                        }
                    }
                }
            }
            
        });
    }
    
    
    
    
    if (scanForAcceptButton) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        foundAcceptButton = false;
        dispatch_group_async(dispatchGroup, queue, ^{
            
            int padding = 150;
            
            int xStart = detectionPlayButtonReferenceLocation.x-130 - padding;
            int yStart = detectionPlayButtonReferenceLocation.y+330 - padding;
            int xEnd = detectionPlayButtonReferenceLocation.x-120 + padding;
            int yEnd = detectionPlayButtonReferenceLocation.y+340 + padding;
            //int xStart = 0;
            //int yStart = 0;
            //int xEnd = data.imageWidth;
            //int yEnd = data.imageHeight;
            float p = 0.0;
            for (int x = xStart; x < xEnd; x++) {
                for (int y = yStart; y < yEnd; y++) {
                    if (x + step7_AcceptButton.imageWidth < data.imageWidth && y + step7_AcceptButton.imageHeight < data.imageHeight &&
                        x + step7_AcceptButton.imageWidth >= 0 && y + step7_AcceptButton.imageHeight >= 0) {
                        if ((p=getImageAtPixelPercentageOptimizedExact(getPixel2(data, x, y), x, y, data.imageWidth, data.imageHeight, step7_AcceptButton, 0.30)) >=  0.8) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                foundAcceptButton = true;
                                acceptButtonLocation.x = x+50;
                                acceptButtonLocation.y = y+10;
                            });
                            fireLogic = true;
                            x = xEnd;
                            y = yEnd;
                        }
                    }
                }
            }
            
        });
    }
    if (scanForRandomChampionButton) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        foundRandomChampionButton = false;
        dispatch_group_async(dispatchGroup, queue, ^{
            
            //int xStart = detectionPlayButtonReferenceLocation.x-120;
            //int yStart = detectionPlayButtonReferenceLocation.y+120;
            //int xEnd = detectionPlayButtonReferenceLocation.x+120;
            //int yEnd = detectionPlayButtonReferenceLocation.y+470;
            int xStart = 0;
            int yStart = 0;
            int xEnd = data.imageWidth;
            int yEnd = data.imageHeight;
            
            for (int x = xStart; x < xEnd; x++) {
                for (int y = yStart; y < yEnd; y++) {
                    if (getImageAtPixelPercentageOptimizedExact(getPixel2(data, x, y), x, y, data.imageWidth, data.imageHeight, step8_RandomChampionButton, 0.7) >=  0.7) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            foundRandomChampionButton = true;
                            randomChampionButtonLocation.x = x+15;
                            randomChampionButtonLocation.y = y;
                            //NSLog(@"Found random button at %d, %d", x, y);
                        });
                        fireLogic = true;
                        x = xEnd;
                        y = yEnd;
                    }
                }
            }
            
        });
        /*
         
         dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
         dispatch_group_async(dispatchGroup, queue, ^{
         
         float returnPercentage = 0.0;
         Position returnPosition;
         int xStart = detectionPlayButtonReferenceLocation.x-400;
         int yStart = detectionPlayButtonReferenceLocation.y;
         int xEnd = detectionPlayButtonReferenceLocation.x+400;
         int yEnd = detectionPlayButtonReferenceLocation.y+600;
         
         
         CGRect search = CGRectMake(xStart, yStart, xEnd - xStart, yEnd-yStart);
         size_t intersectRectsNum;
         CGRect* intersectSearch = getIntersectionRectangles(search, rects, num_rects, intersectRectsNum);
         
         detectExactImageToImageToRectangles(step8_RandomChampionButton, data, intersectSearch, intersectRectsNum, returnPercentage, returnPosition, 0.83, true);
         
         if (returnPercentage >= 0.3) {
         dispatch_async(dispatch_get_main_queue(), ^{
         foundRandomChampionButton = true;
         randomChampionButtonLocation = returnPosition;
         });
         fireLogic = true;
         } else {
         dispatch_async(dispatch_get_main_queue(), ^{
         foundRandomChampionButton = false;
         });
         }
         
         });*/
    }
    if (scanForLockInButton) {
        foundLockInButton = false;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_group_async(dispatchGroup, queue, ^{
            int xStart = 0;
            int yStart = 0;
            int xEnd = data.imageWidth;
            int yEnd = data.imageHeight;
            
            for (int x = xStart; x < xEnd; x++) {
                for (int y = yStart; y < yEnd; y++) {
                    if (getImageAtPixelPercentageOptimizedExact(getPixel2(data, x, y), x, y, data.imageWidth, data.imageHeight, step9_LockInButton, 0.45) >=  0.45) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            foundLockInButton = true;
                            lockInButtonLocation.x = x;
                            lockInButtonLocation.y = y;
                            //NSLog(@"Found lock in button at %d, %d", x, y);
                        });
                        fireLogic = true;
                        x = xEnd;
                        y = yEnd;
                    }
                }
            }
            /*
             float returnPercentage = 0.0;
             Position returnPosition;
             int xStart = detectionPlayButtonReferenceLocation.x-400;
             int yStart = detectionPlayButtonReferenceLocation.y;
             int xEnd = detectionPlayButtonReferenceLocation.x+500;
             int yEnd = detectionPlayButtonReferenceLocation.y+600;
             
             
             CGRect search = CGRectMake(xStart, yStart, xEnd - xStart, yEnd-yStart);
             size_t intersectRectsNum;
             CGRect* intersectSearch = getIntersectionRectangles(search, rects, num_rects, intersectRectsNum);
             
             detectExactImageToImageToRectangles(step9_LockInButton, data, intersectSearch, intersectRectsNum, returnPercentage, returnPosition, 0.83, true);
             
             if (returnPercentage >= 0.3) {
             dispatch_async(dispatch_get_main_queue(), ^{
             foundLockInButton = true;
             lockInButtonLocation = returnPosition;
             });
             fireLogic = true;
             } else {
             dispatch_async(dispatch_get_main_queue(), ^{
             foundLockInButton = false;
             });
             }*/
            
        });
    }
    if (scanForChooseSkinButton) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_group_async(dispatchGroup, queue, ^{
            
            float returnPercentage = 0.0;
            Position returnPosition;
            int xStart = detectionPlayButtonReferenceLocation.x-400;
            int yStart = detectionPlayButtonReferenceLocation.y;
            int xEnd = detectionPlayButtonReferenceLocation.x+500;
            int yEnd = detectionPlayButtonReferenceLocation.y+600;
            
            
            CGRect search = CGRectMake(xStart, yStart, xEnd - xStart, yEnd-yStart);
            size_t intersectRectsNum;
            CGRect* intersectSearch = getIntersectionRectangles(search, rects, num_rects, intersectRectsNum);
            
            detectExactImageToImageToRectangles(step10_ChooseSkinButton, data, intersectSearch, intersectRectsNum, returnPercentage, returnPosition, 0.83, true);
            
            if (returnPercentage >= 0.3) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundChooseSkinButton = true;
                    chooseSkinButtonLocation = returnPosition;
                });
                fireLogic = true;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundChooseSkinButton = false;
                });
            }
            
        });
    }
    if (scanForReconnectButton) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_group_async(dispatchGroup, queue, ^{
            
            float returnPercentage = 0.0;
            Position returnPosition;
            int xStart = detectionPlayButtonReferenceLocation.x-100;
            int yStart = detectionPlayButtonReferenceLocation.y+100;
            int xEnd = detectionPlayButtonReferenceLocation.x+200;
            int yEnd = detectionPlayButtonReferenceLocation.y+450;
            
            
            CGRect search = CGRectMake(xStart, yStart, xEnd - xStart, yEnd-yStart);
            size_t intersectRectsNum;
            CGRect* intersectSearch = getIntersectionRectangles(search, rects, num_rects, intersectRectsNum);
            
            detectExactImageToImageToRectangles(step13_ReconnectButton, data, intersectSearch, intersectRectsNum, returnPercentage, returnPosition, 0.83, true);
            
            free(intersectSearch);
            
            if (returnPercentage >= 0.3) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundReconnectButton = true;
                    reconnectButtonLocation = returnPosition;
                });
                fireLogic = true;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundReconnectButton = false;
                });
            }
            
        });
    }
    if (scanForHomeButton) {
        //foundHomeButton = false;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_group_async(dispatchGroup, queue, ^{
            
            //NSLog(@"Searching for home button");
            
            //float returnPercentage = 0.0;
            //Position returnPosition;
            //int xStart = detectionPlayButtonReferenceLocation.x;
            //int yStart = detectionPlayButtonReferenceLocation.y+450;
            //int xEnd = detectionPlayButtonReferenceLocation.x+500;
            //int yEnd = detectionPlayButtonReferenceLocation.y+625;
            int xStart = 0;
            int yStart = 0;
            int xEnd = data.imageWidth;
            int yEnd = data.imageHeight;
            //if (detectionPlayButtonReferenceLocation.x == -1) {
            //    xStart = 0;
            //    yStart = 0;
            //    xEnd = data.imageWidth;
            //    yEnd = data.imageHeight;
            //}
            
            
            for (int x = xStart; x < xEnd; x++) {
                for (int y = yStart; y < yEnd; y++) {
                    if (getImageAtPixelPercentageOptimizedExact(getPixel2(data, x, y), x, y, data.imageWidth, data.imageHeight, step12_HomeButton, 0.45) >=  0.45) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            foundHomeButton = true;
                            homeButtonLocation.x = x;
                            homeButtonLocation.y = y;
                            //NSLog(@"Found home button at %d, %d", x, y);
                        });
                        fireLogic = true;
                        x = xEnd;
                        y = yEnd;
                    }
                }
            }
            /*
             CGRect search = CGRectMake(xStart, yStart, xEnd - xStart, yEnd-yStart);
             size_t intersectRectsNum;
             CGRect* intersectSearch = getIntersectionRectangles(search, rects, num_rects, intersectRectsNum);
             */
            //detectExactImageToImageToRectangles(step12_HomeButton, data, intersectSearch, intersectRectsNum, returnPercentage, returnPosition, 0.4, true);
            ////NSLog(@"Home button: %f", returnPercentage);
            //free(intersectSearch);
            /*
             if (returnPercentage >= 0.4) {
             dispatch_async(dispatch_get_main_queue(), ^{
             //NSLog(@"Found home button at %d, %d", returnPosition.x, returnPosition.y);
             foundHomeButton = true;
             homeButtonLocation = returnPosition;
             });
             fireLogic = true;
             } else {
             dispatch_async(dispatch_get_main_queue(), ^{
             foundHomeButton = false;
             });
             }
             */
        });
    }
    if (scanForNormalBlindPick) {
        /*
         const int scanChunksX = 5; //36 frames until full scan. Full scan at 60fps is 0.6 seconds.
         const int scanChunksY = 24;
         
         float leagueGameWidth = data.imageWidth;
         float leagueGameHeight = data.imageHeight;
         CGRect leagueWindowRect = CGRectMake(0, 0, leagueGameWidth, leagueGameHeight);
         
         
         
         int scanStartX = 0; int scanStartY = 0;
         int scanEndX = leagueGameWidth; int scanEndY = leagueGameHeight;
         int scanWidth = (scanEndX - scanStartX) / scanChunksX;
         int scanHeight = (scanEndY - scanStartY) / scanChunksY;
         
         int framesPassed = 1;//(getTimeInMilliseconds(mach_absolute_time() - processAllyChampionLastTime)) / 16;
         //if (framesPassed <= 0) framesPassed = 1;
         //if (framesPassed > allyChampionScanChunksX * allyChampionScanChunksY) framesPassed = allyChampionScanChunksX * allyChampionScanChunksY;
         
         NSMutableArray* scanRectangles = [NSMutableArray new];
         //Increase the scan chunk by 1
         for (int i = 0; i < framesPassed; i++) {
         step5ScanCurrentChunkX += 1;
         if (step5ScanCurrentChunkX >= scanChunksX) {
         step5ScanCurrentChunkX = 0;
         step5ScanCurrentChunkY++;
         }
         if (step5ScanCurrentChunkY >= scanChunksY) {
         step5ScanCurrentChunkY = 0;
         }
         //Add chunk to scan
         CGRect scanRect = CGRectMake( scanWidth * step5ScanCurrentChunkX + scanStartX ,
         scanHeight * step5ScanCurrentChunkY + scanStartY ,
         scanWidth ,
         scanHeight );
         scanRect = CGRectIntegral(scanRect);
         scanRect = fitRectangleInRectangle(scanRect, leagueWindowRect);
         combineRectangles(scanRectangles, scanRect);
         }
         */
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_group_async(dispatchGroup, queue, ^{
            
            //Loop through scan chunks
            //for (int i = 0; i < [scanRectangles count]; i++) {
            //CGRect rect = [[scanRectangles objectAtIndex:i] rectValue];
            CGRect rect = CGRectMake(0, 0, data.imageWidth, data.imageHeight);
            for (int x = rect.origin.x; x < rect.origin.x + rect.size.width; x++) {
                for (int y = rect.origin.y; y < rect.origin.y + rect.size.height; y++) {
                    uint8* pixel = getPixel2(data, x, y);
                    if (getImageAtPixelPercentageOptimizedExact(pixel, x, y, data.imageWidth, data.imageHeight, step5_BlindPickMode, 0.8) >=  0.8) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            foundNormalBlindPickButton = true;
                            normalBlindPickLocation.x = x;
                            normalBlindPickLocation.y = y;
                        });
                        fireLogic = true;
                        x = rect.origin.x + rect.size.width;
                        y = rect.origin.y + rect.size.height;
                        //i = (int)[scanRectangles count];
                    }
                }
            }
            //}
        });
    }
    
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER);
    
    return fireLogic;
    
    
    /*
     ImageData imageData = data;
     if ((clock() - lastScreenScan)/CLOCKS_PER_SEC >= 0.5) {
     lastScreenScan = clock();
     bool match = false;
     Position clickLocation;
     //location.x = 0; location.y = 0;
     int xStart = 300;
     int yStart = 0;
     int xEnd = imageData.imageWidth - 400;
     int yEnd = 250;
     //NSLog(@"%d %d", imageData.imageWidth, imageData.imageHeight);
     ////NSLog(@"%d,%d to %d, %d", xStart, yStart, xEnd, yEnd);
     float returnPercentage = 0.0;
     Position returnPosition;
     
     detectExactImageToImage(step1_PlayButton, imageData, xStart, yStart, xEnd, yEnd, returnPercentage, returnPosition, 0.83, true);
     
     if (returnPercentage >= 0.3) {
     //NSLog(@"Found play button");
     playButtonLocation = returnPosition;
     clickLocation = playButtonLocation;
     match = true;
     currentStep = STEP_1;
     } else {
     //NSLog(@"Did not find play button");
     }
     
     xStart = 0;
     yStart = 0;
     xEnd = imageData.imageWidth;
     yEnd = imageData.imageHeight;
     
     switch (currentStep) {
     case STEP_1: {
     if (match)  {
     currentStep = STEP_2;
     //NSLog(@"Clicked play button");
     }
     }break;
     case STEP_2: {
     //Use relative location from play button
     clickLocation.x = playButtonLocation.x -230;
     clickLocation.y = playButtonLocation.y +75;
     match = true;
     currentStep = STEP_3;
     if (match) {
     //NSLog(@"Clicked PVP mode");
     } else {//NSLog(@"PVP not detected, switching to next");}
     
     // match = detectRelativeImageInImage(step2_PVPMode, data, location, 0.65);
     // location.x += 191; location.y += 76;
     
     }break;
     case STEP_3: {
     clickLocation.x = playButtonLocation.x -70;
     clickLocation.y = playButtonLocation.y +105;
     match = true;
     //match = detectRelativeImageInImage(step3_ClassicMode, data, location, 0.65);
     //location.x += 352; location.y += 114;
     currentStep = STEP_4;
     if (match) {//NSLog(@"Clicked classic mode");} else {//NSLog(@"Classic not detected,switching to next");}
     }break;
     case STEP_4: {
     clickLocation.x = playButtonLocation.x +100;
     clickLocation.y = playButtonLocation.y +110;
     match = true;
     //match = detectRelativeImageInImage(step4_SummonersRiftMode, data, location, 0.7);
     //location.x += 510; location.y += 116;
     currentStep = STEP_5;
     if (match) {//NSLog(@"Clicked Summoners Rift Mode");} else {//NSLog(@"Rift mode not detected, switching to next");}
     }break;
     case STEP_5: {
     clickLocation.x = playButtonLocation.x +300;
     clickLocation.y = playButtonLocation.y +180;
     match = true;
     //match = detectRelativeImageInImage(step5_BlindPickMode, data, location, 0.7);
     //location.x += 675; location.y += 114;
     currentStep = STEP_6;
     if (match) {//NSLog(@"Clicked blind pick");} else {//NSLog(@"Blind pick not detected, switching to next");}
     }break;
     case STEP_6: {
     clickLocation.x = playButtonLocation.x +100;
     clickLocation.y = playButtonLocation.y +550;
     match = true;
     //match = detectRelativeImageInImage(step6_SoloButton, data, location, 0.85);
     //location.x += 19; location.y += 76;
     if (match) currentStep = STEP_7;
     if (match) {//NSLog(@"Clicked solo button");}
     }break;
     case STEP_7: {
     detectExactImageToImage(step7_AcceptButton, imageData, playButtonLocation.x-100, playButtonLocation.y+100, playButtonLocation.x+100, playButtonLocation.y+450, returnPercentage, returnPosition, 0.83, TRUE);
     if (returnPercentage >= 0.3) {
     match = true;
     clickLocation = returnPosition;
     }
     if (match) currentStep = STEP_8;
     if (match) {//NSLog(@"Clicked accept button");}
     }break;
     case STEP_8: {
     xStart = playButtonLocation.x-400;
     yStart = playButtonLocation.y;
     xEnd = playButtonLocation.x+400;
     yEnd = playButtonLocation.y+600;
     detectExactImageToImage(step8_RandomChampionButton, imageData, xStart, yStart, xEnd, yEnd, returnPercentage, returnPosition, 0.83, true);
     if (returnPercentage >= 0.3) {
     clickLocation = returnPosition;
     match = true;
     }
     if (match) {
     currentStep = STEP_9;
     if (match) {//NSLog(@"Clicked random champion");}
     } else {
     detectExactImageToImage(step7_AcceptButton, imageData, playButtonLocation.x-100, playButtonLocation.y+100, playButtonLocation.x+100, playButtonLocation.y+450, returnPercentage, returnPosition, 0.83, true);
     if (returnPercentage >= 0.3) {
     //Someone queue dodged
     match = true;
     clickLocation = returnPosition;
     currentStep = STEP_8;
     if (match) {//NSLog(@"Clicked accept button");}
     }
     }
     }break;
     case STEP_9: {
     xStart = playButtonLocation.x-400;
     yStart = playButtonLocation.y;
     xEnd = playButtonLocation.x+500;
     yEnd = playButtonLocation.y+600;
     detectExactImageToImage(step9_LockInButton, imageData, xStart, yStart, xEnd, yEnd, returnPercentage, returnPosition, 0.83, true);
     if (returnPercentage >= 0.3) {
     clickLocation = returnPosition;
     match = true;
     }
     if (match) {
     currentStep = STEP_10;
     if (match) {//NSLog(@"Clicked lock in button");}
     } else {
     detectExactImageToImage(step7_AcceptButton, imageData, playButtonLocation.x-100, playButtonLocation.y+100, playButtonLocation.x+100, playButtonLocation.y+450, returnPercentage, returnPosition, 0.83, true);
     if (returnPercentage >= 0.3) {
     //Someone queue dodged
     match = true;
     clickLocation = returnPosition;
     currentStep = STEP_8;
     if (match) {//NSLog(@"Clicked accept button");}
     }
     }
     }break;
     case STEP_10: {
     xStart = playButtonLocation.x-400;
     yStart = playButtonLocation.y;
     xEnd = playButtonLocation.x+500;
     yEnd = playButtonLocation.y+600;
     detectExactImageToImage(step10_ChooseSkinButton, imageData, xStart, yStart, xEnd, yEnd, returnPercentage, returnPosition, 0.83, true);
     if (returnPercentage >= 0.3) {
     returnPosition.x += 5; returnPosition.y += 156;
     clickLocation = returnPosition;
     match = true;
     }
     if (match) {//NSLog(@"Clicked skin change button");}
     if (!match) currentStep = STEP_12;
     //Check for accept button
     detectExactImageToImage(step7_AcceptButton, imageData, playButtonLocation.x-100, playButtonLocation.y+100, playButtonLocation.x+100, playButtonLocation.y+450, returnPercentage, returnPosition, 0.83, true);
     if (returnPercentage >= 0.3) {
     //Someone queue dodged
     match = true;
     clickLocation = returnPosition;
     currentStep = STEP_8;
     if (match) {//NSLog(@"Clicked accept button");}
     } else {
     //Check for reconnect button
     detectExactImageToImage(step13_ReconnectButton, imageData, playButtonLocation.x-100, playButtonLocation.y+100, playButtonLocation.x+200, playButtonLocation.y+450, returnPercentage, returnPosition, 0.83, true);
     if (returnPercentage >= 0.3) {
     match = true;
     clickLocation = returnPosition;
     //Reconnecting screen
     if (match) {//NSLog(@"Clicked reconnect button");}
     }
     }
     }break;
     case STEP_12: {
     xStart = playButtonLocation.x;
     yStart = playButtonLocation.y+450;
     xEnd = playButtonLocation.x+500;
     yEnd = playButtonLocation.y+625;
     if (playButtonLocation.x == -1) {
     xStart = 0;
     yStart = 0;
     xEnd = imageData.imageWidth;
     yEnd = imageData.imageHeight;
     }
     detectExactImageToImage(step12_HomeButton, imageData, xStart, yStart, xEnd, yEnd, returnPercentage, returnPosition, 0.83, true);
     if (returnPercentage >= 0.3) {
     clickLocation = returnPosition;
     match = true;
     }
     if (match) currentStep = STEP_1;
     if (match) {//NSLog(@"Clicked home button");}
     }break;
     }
     if (match) {
     //NSLog(@"Clicked location %d %d", clickLocation.x + 10, clickLocation.y+10);
     floatTapMouseLeft(clickLocation.x + 10, clickLocation.y+10);
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC / 60.0), dispatch_get_main_queue(), ^{ // one
     floatTapMouseLeft(clickLocation.x + 10, clickLocation.y+10);
     });
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC / 5.0), dispatch_get_main_queue(), ^{ // one
     moveMouse(0, 0);
     });
     //tapMouseLeft(location.x + 10, location.y+10);
     }
     }
     */
}
/*
 void AutoQueueManager::checkForEndGame(ImageData data) {
 imageData = data;
 
 if ((clock() - lastEndGameScan)/CLOCKS_PER_SEC >= 1.0) {
 //NSLog(@"Checking for end game button");
 lastEndGameScan = clock();
 
 int xStart = imageData.imageWidth/2 - 150;
 int yStart = imageData.imageHeight * 0.68125 - 100;
 int xEnd = imageData.imageWidth/2 + 150;
 int yEnd = imageData.imageHeight * 0.68125 + 100;
 float returnPercentage;
 Position returnPosition;
 detectExactImageToImage(step11_EndGameContinueButton, imageData, xStart, yStart, xEnd, yEnd, returnPercentage, returnPosition, 0.65, true);
 if (returnPercentage >= 0.65) {
 floatTapMouseLeft(returnPosition.x + 5, returnPosition.y+5);
 moveMouse(returnPosition.x + 5, returnPosition.y+5);
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC / 60.0), dispatch_get_main_queue(), ^{ // one
 floatTapMouseLeft(returnPosition.x + 5, returnPosition.y+5);
 });
 //NSLog(@"Clicked end game button");
 }
 currentStep = STEP_12;
 }
 }*/