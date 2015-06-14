//
//  AutoQueueManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/13/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "AutoQueueManager.h"

AutoQueueManager::AutoQueueManager() {
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
    
    lastScreenScan = clock();
    lastEndGameScan = clock();
    
    currentStep = STEP_1;
}
void AutoQueueManager::processImage(ImageData data) {
    imageData = data;
    
    if ((clock() - lastScreenScan)/CLOCKS_PER_SEC >= 0.5) {
        lastScreenScan = clock();
        bool match = false;
        Position location;
        switch (currentStep) {
            case STEP_1: {
                match = detectRelativeImageInImage(step1_PlayButton, data, location, 0.85);
                if (match)  {
                    currentStep = STEP_2;
                    NSLog(@"Clicked play button");
                }
            }break;
            case STEP_2: {
                match = detectRelativeImageInImage(step2_PVPMode, data, location, 0.89);
                currentStep = STEP_3;
                if (match) {NSLog(@"Clicked PVP mode");}
            }break;
            case STEP_3: {
                match = detectRelativeImageInImage(step3_ClassicMode, data, location, 0.89);
                currentStep = STEP_4;
                if (match) {NSLog(@"Clicked classic mode");}
            }break;
            case STEP_4: {
                match = detectRelativeImageInImage(step4_SummonersRiftMode, data, location, 0.89);
                currentStep = STEP_5;
                if (match) {NSLog(@"Clicked Summoners Rift Mode");}
            }break;
            case STEP_5: {
                match = detectRelativeImageInImage(step5_BlindPickMode, data, location, 0.89);
                currentStep = STEP_6;
                if (match) {NSLog(@"Clicked blind pick");}
            }break;
            case STEP_6: {
                match = detectRelativeImageInImage(step6_SoloButton, data, location, 0.85);
                if (match) currentStep = STEP_7;
                if (match) {NSLog(@"Clicked solo button");}
            }break;
            case STEP_7: {
                match = detectRelativeImageInImage(step7_AcceptButton, data, location, 0.85);
                if (match) currentStep = STEP_8;
                if (match) {NSLog(@"Clicked accept button");}
            }break;
            case STEP_8: {
                match = detectRelativeImageInImage(step8_RandomChampionButton, data, location, 0.85);
                if (match) {
                    currentStep = STEP_9;
                    if (match) {NSLog(@"Clicked random champion");}
                } else if ((match = detectRelativeImageInImage(step7_AcceptButton, data, location, 0.85))) {
                     //Someone queue dodged
                    currentStep = STEP_8;
                    if (match) {NSLog(@"Clicked accept button");}
                }
            }break;
            case STEP_9: {
                match = detectRelativeImageInImage(step9_LockInButton, data, location, 0.85);
                if (match) {
                    currentStep = STEP_10;
                    if (match) {NSLog(@"Clicked lock in button");}
                } else if ((match = detectRelativeImageInImage(step7_AcceptButton, data, location, 0.85))) {
                    //Someone queue dodged
                    currentStep = STEP_8;
                    if (match) {NSLog(@"Clicked accept button");}
                }
            }break;
            case STEP_10: {
                match = detectRelativeImageInImage(step10_ChooseSkinButton, data, location, 0.7);
                location.y += 5;
                location.x += 15;
                if (match) {NSLog(@"Clicked skin change button");}
                if (!match) currentStep = STEP_12;
                if ((match = detectRelativeImageInImage(step7_AcceptButton, data, location, 0.85))) {
                    //Someone queue dodged
                    currentStep = STEP_8;
                    if (match) {NSLog(@"Clicked accept button");}
                } else if ((match = detectRelativeImageInImage(step13_ReconnectButton, data, location, 0.85))) {
                    //Reconnecting screen
                    if (match) {NSLog(@"Clicked reconnect button");}
                }
            }break;
            case STEP_12: {
                match = detectRelativeImageInImage(step12_HomeButton, data, location, 0.85);
                if (match) currentStep = STEP_1;
                if (match) {NSLog(@"Clicked home button");}
            }break;
        }
        if (match) {
            doubleTapMouseLeft(location.x + 10, location.y+10);
            moveMouse(0, 0);
            //tapMouseLeft(location.x + 10, location.y+10);
        }
    }
}
void AutoQueueManager::checkForEndGame(ImageData data) {
    imageData = data;
    
    if ((clock() - lastEndGameScan)/CLOCKS_PER_SEC >= 1.0) {
        lastEndGameScan = clock();
        
        Position location;
        
        if (detectRelativeImageInImage(step11_EndGameContinueButton, data, location, 0.7)) {
            doubleTapMouseLeft(location.x + 5, location.y+5);
            moveMouse(location.x + 5, location.y+5);
            NSLog(@"Clicked end game button");
        }
        currentStep = STEP_12;
    }
}