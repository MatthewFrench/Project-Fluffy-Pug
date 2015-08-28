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
    
    //testImage1 = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/TestGame1" ofType:@"png"]);
    //testImage2 = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/TestGame2" ofType:@"png"]);
    
    //lastScreenScan = clock();
    //lastEndGameScan = clock();
    
    reset(false);
}
void AutoQueueManager::reset(bool keepPlayButton) {
    if (!keepPlayButton) {
        foundPlayButton = false;
        detectionPlayButtonReferenceLocation.x = -1;
    }
    foundAcceptButton = false, foundRandomChampionButton = false, foundLockInButton = false, foundChooseSkinButton = false, foundReconnectButton = false, foundHomeButton = false, foundEndGameButton = false;
    scanForPlayButton = false, scanForAcceptButton = false, scanForRandomChampionButton = false, scanForLockInButton = false, scanForChooseSkinButton = false, scanForReconnectButton = false, scanForHomeButton = false, scanForEndGameButton = false;
    
    currentStep = STEP_1;
    scanForPlayButton = true;
}
void AutoQueueManager::processLogic() {
    
    if (foundPlayButton && currentStep != STEP_1 && currentStep != STEP_2) {
        reset(true);
    }
    
    switch (currentStep) {
        case STEP_1: {
            if (foundPlayButton)  {
                currentStep = STEP_2;
                clickLocation(playButtonLocation.x, playButtonLocation.y);
            }
        }break;
        case STEP_2: {
            //Click PVP mode
            if (!foundPlayButton) { //Do next step cause no play button visible
                currentStep = STEP_3;
                clickLocation(playButtonLocation.x -230, playButtonLocation.y +75);
            }
        }break;
        case STEP_3: {
            //Click Classic mode
            currentStep = STEP_4;
            clickLocation(playButtonLocation.x -70, playButtonLocation.y +105);
        }break;
        case STEP_4: {
            //Click Summoner's Rift mode
            currentStep = STEP_5;
            clickLocation(playButtonLocation.x +100, playButtonLocation.y +110);
        }break;
        case STEP_5: {
            //Click Blind Pick mode
            currentStep = STEP_6;
            clickLocation(playButtonLocation.x +300, playButtonLocation.y +180);
        }break;
        case STEP_6: {
            //Click Solo Button
            currentStep = STEP_7;
            clickLocation(playButtonLocation.x +100, playButtonLocation.y +550);
            scanForAcceptButton = true;
        }break;
        case STEP_7: {
            if (foundAcceptButton) {
                //Click accept button
                currentStep = STEP_8;
                clickLocation(acceptButtonLocation.x, acceptButtonLocation.y);
                scanForRandomChampionButton = true;
            }
        }break;
        case STEP_8: {
            if (foundAcceptButton) {
                //Wait for accept button to disappear
                clickLocation(acceptButtonLocation.x, acceptButtonLocation.y);
                break;
            }
            if (foundRandomChampionButton) {
                //Click random champion button
                currentStep = STEP_9;
                clickLocation(randomChampionButtonLocation.x, randomChampionButtonLocation.y);
                scanForRandomChampionButton = false;
                scanForLockInButton = true;
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
                break;
            }
            if (foundChooseSkinButton) {
                clickLocation(chooseSkinButtonLocation.x, chooseSkinButtonLocation.y);
            } else {
                //Entering Game
                currentStep = STEP_12;
                scanForChooseSkinButton = false;
                scanForLockInButton = false;
                scanForAcceptButton = false;
                scanForHomeButton = true;
            }
        }break;
        case STEP_12: {
            if (foundHomeButton) {
                clickLocation(homeButtonLocation.x, homeButtonLocation.y);
                reset(false);
            }
        }break;
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

bool AutoQueueManager::processDetection(ImageData data, const CGRect* rects, size_t num_rects) {
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
    //NSLog(@"Test image 1: %f", returnPercentage3);
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
            size_t intersectRectsNum;
            CGRect* intersectSearch = getIntersectionRectangles(search, rects, num_rects, intersectRectsNum);
            
            detectExactImageToImageToRectangles(step1_PlayButton, data, intersectSearch, intersectRectsNum, returnPercentage, returnPosition, 0.83, true);
            
            //NSLog(@"Play button percentage: %f", returnPercentage);
            
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
    if (scanForAcceptButton) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_group_async(dispatchGroup, queue, ^{
            
            float returnPercentage = 0.0;
            Position returnPosition;
            int xStart = detectionPlayButtonReferenceLocation.x-100;
            int yStart = detectionPlayButtonReferenceLocation.y+100;
            int xEnd = detectionPlayButtonReferenceLocation.x+100;
            int yEnd = detectionPlayButtonReferenceLocation.y+450;
            
            
            CGRect search = CGRectMake(xStart, yStart, xEnd - xStart, yEnd-yStart);
            size_t intersectRectsNum;
            CGRect* intersectSearch = getIntersectionRectangles(search, rects, num_rects, intersectRectsNum);
            
            detectExactImageToImageToRectangles(step7_AcceptButton, data, intersectSearch, intersectRectsNum, returnPercentage, returnPosition, 0.83, true);
            
            if (returnPercentage >= 0.3) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundAcceptButton = true;
                    acceptButtonLocation = returnPosition;
                });
                fireLogic = true;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundAcceptButton = false;
                });
            }
            
        });
    }
    if (scanForRandomChampionButton) {
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
            
        });
    }
    if (scanForLockInButton) {
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
            }
            
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
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_group_async(dispatchGroup, queue, ^{
            
            float returnPercentage = 0.0;
            Position returnPosition;
            int xStart = detectionPlayButtonReferenceLocation.x;
            int yStart = detectionPlayButtonReferenceLocation.y+450;
            int xEnd = detectionPlayButtonReferenceLocation.x+500;
            int yEnd = detectionPlayButtonReferenceLocation.y+625;
            if (detectionPlayButtonReferenceLocation.x == -1) {
                xStart = 0;
                yStart = 0;
                xEnd = data.imageWidth;
                yEnd = data.imageHeight;
            }
            
            
            CGRect search = CGRectMake(xStart, yStart, xEnd - xStart, yEnd-yStart);
            size_t intersectRectsNum;
            CGRect* intersectSearch = getIntersectionRectangles(search, rects, num_rects, intersectRectsNum);
            
            detectExactImageToImageToRectangles(step12_HomeButton, data, intersectSearch, intersectRectsNum, returnPercentage, returnPosition, 0.83, true);
            
            if (returnPercentage >= 0.3) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundHomeButton = true;
                    homeButtonLocation = returnPosition;
                });
                fireLogic = true;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundHomeButton = false;
                });
            }
            
        });
    }
    if (scanForEndGameButton) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_group_async(dispatchGroup, queue, ^{
            
            float returnPercentage = 0.0;
            Position returnPosition;
            int xStart = data.imageWidth/2 - 150;
            int yStart = data.imageHeight * 0.68125 - 100;
            int xEnd = data.imageWidth/2 + 150;
            int yEnd = data.imageHeight * 0.68125 + 100;
            detectExactImageToImage(step11_EndGameContinueButton, data, xStart, yStart, xEnd, yEnd, returnPercentage, returnPosition, 0.65, true);
            if (returnPercentage >= 0.65) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundEndGameButton = true;
                    endGameButtonLocation = returnPosition;
                });
                fireLogic = true;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundEndGameButton = false;
                });
            }
            
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
     NSLog(@"%d %d", imageData.imageWidth, imageData.imageHeight);
     //NSLog(@"%d,%d to %d, %d", xStart, yStart, xEnd, yEnd);
     float returnPercentage = 0.0;
     Position returnPosition;
     
     detectExactImageToImage(step1_PlayButton, imageData, xStart, yStart, xEnd, yEnd, returnPercentage, returnPosition, 0.83, true);
     
     if (returnPercentage >= 0.3) {
     NSLog(@"Found play button");
     playButtonLocation = returnPosition;
     clickLocation = playButtonLocation;
     match = true;
     currentStep = STEP_1;
     } else {
     NSLog(@"Did not find play button");
     }
     
     xStart = 0;
     yStart = 0;
     xEnd = imageData.imageWidth;
     yEnd = imageData.imageHeight;
     
     switch (currentStep) {
     case STEP_1: {
     if (match)  {
     currentStep = STEP_2;
     NSLog(@"Clicked play button");
     }
     }break;
     case STEP_2: {
     //Use relative location from play button
     clickLocation.x = playButtonLocation.x -230;
     clickLocation.y = playButtonLocation.y +75;
     match = true;
     currentStep = STEP_3;
     if (match) {
     NSLog(@"Clicked PVP mode");
     } else {NSLog(@"PVP not detected, switching to next");}
     
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
     if (match) {NSLog(@"Clicked classic mode");} else {NSLog(@"Classic not detected,switching to next");}
     }break;
     case STEP_4: {
     clickLocation.x = playButtonLocation.x +100;
     clickLocation.y = playButtonLocation.y +110;
     match = true;
     //match = detectRelativeImageInImage(step4_SummonersRiftMode, data, location, 0.7);
     //location.x += 510; location.y += 116;
     currentStep = STEP_5;
     if (match) {NSLog(@"Clicked Summoners Rift Mode");} else {NSLog(@"Rift mode not detected, switching to next");}
     }break;
     case STEP_5: {
     clickLocation.x = playButtonLocation.x +300;
     clickLocation.y = playButtonLocation.y +180;
     match = true;
     //match = detectRelativeImageInImage(step5_BlindPickMode, data, location, 0.7);
     //location.x += 675; location.y += 114;
     currentStep = STEP_6;
     if (match) {NSLog(@"Clicked blind pick");} else {NSLog(@"Blind pick not detected, switching to next");}
     }break;
     case STEP_6: {
     clickLocation.x = playButtonLocation.x +100;
     clickLocation.y = playButtonLocation.y +550;
     match = true;
     //match = detectRelativeImageInImage(step6_SoloButton, data, location, 0.85);
     //location.x += 19; location.y += 76;
     if (match) currentStep = STEP_7;
     if (match) {NSLog(@"Clicked solo button");}
     }break;
     case STEP_7: {
     detectExactImageToImage(step7_AcceptButton, imageData, playButtonLocation.x-100, playButtonLocation.y+100, playButtonLocation.x+100, playButtonLocation.y+450, returnPercentage, returnPosition, 0.83, TRUE);
     if (returnPercentage >= 0.3) {
     match = true;
     clickLocation = returnPosition;
     }
     if (match) currentStep = STEP_8;
     if (match) {NSLog(@"Clicked accept button");}
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
     if (match) {NSLog(@"Clicked random champion");}
     } else {
     detectExactImageToImage(step7_AcceptButton, imageData, playButtonLocation.x-100, playButtonLocation.y+100, playButtonLocation.x+100, playButtonLocation.y+450, returnPercentage, returnPosition, 0.83, true);
     if (returnPercentage >= 0.3) {
     //Someone queue dodged
     match = true;
     clickLocation = returnPosition;
     currentStep = STEP_8;
     if (match) {NSLog(@"Clicked accept button");}
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
     if (match) {NSLog(@"Clicked lock in button");}
     } else {
     detectExactImageToImage(step7_AcceptButton, imageData, playButtonLocation.x-100, playButtonLocation.y+100, playButtonLocation.x+100, playButtonLocation.y+450, returnPercentage, returnPosition, 0.83, true);
     if (returnPercentage >= 0.3) {
     //Someone queue dodged
     match = true;
     clickLocation = returnPosition;
     currentStep = STEP_8;
     if (match) {NSLog(@"Clicked accept button");}
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
     if (match) {NSLog(@"Clicked skin change button");}
     if (!match) currentStep = STEP_12;
     //Check for accept button
     detectExactImageToImage(step7_AcceptButton, imageData, playButtonLocation.x-100, playButtonLocation.y+100, playButtonLocation.x+100, playButtonLocation.y+450, returnPercentage, returnPosition, 0.83, true);
     if (returnPercentage >= 0.3) {
     //Someone queue dodged
     match = true;
     clickLocation = returnPosition;
     currentStep = STEP_8;
     if (match) {NSLog(@"Clicked accept button");}
     } else {
     //Check for reconnect button
     detectExactImageToImage(step13_ReconnectButton, imageData, playButtonLocation.x-100, playButtonLocation.y+100, playButtonLocation.x+200, playButtonLocation.y+450, returnPercentage, returnPosition, 0.83, true);
     if (returnPercentage >= 0.3) {
     match = true;
     clickLocation = returnPosition;
     //Reconnecting screen
     if (match) {NSLog(@"Clicked reconnect button");}
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
     if (match) {NSLog(@"Clicked home button");}
     }break;
     }
     if (match) {
     NSLog(@"Clicked location %d %d", clickLocation.x + 10, clickLocation.y+10);
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
 NSLog(@"Checking for end game button");
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
 NSLog(@"Clicked end game button");
 }
 currentStep = STEP_12;
 }
 }*/