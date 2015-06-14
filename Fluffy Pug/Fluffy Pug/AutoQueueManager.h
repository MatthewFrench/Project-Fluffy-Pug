//
//  AutoQueueManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 6/13/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "Utility.h"
#import <time.h>
#import "InteractiveEvents.h"

const int STEP_1=0, STEP_2=1, STEP_3=2, STEP_4=3, STEP_5=4, STEP_6=5, STEP_7=6, STEP_8=7, STEP_9=8
, STEP_10=9, STEP_11=10, STEP_12=11;

class AutoQueueManager {
    ImageData imageData, step1_PlayButton, step2_PVPMode, step3_ClassicMode, step4_SummonersRiftMode, step5_BlindPickMode, step6_SoloButton, step7_AcceptButton, step8_RandomChampionButton, step9_LockInButton, step10_ChooseSkinButton, step11_EndGameContinueButton, step12_HomeButton, step13_ReconnectButton;
    
    double lastScreenScan, lastEndGameScan;
    Position playButtonLocation;
    

public:
    int currentStep;
    
    AutoQueueManager();
    void processImage(ImageData data);
    void checkForEndGame(ImageData data);
};