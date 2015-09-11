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
#import "LeagueGameState.h"

const int STEP_1=0, STEP_2=1, STEP_3=2, STEP_4=3, STEP_5=4, STEP_6=5, STEP_7=6, STEP_8=7, STEP_9=8
, STEP_10=9, STEP_11=10, STEP_12=11;

class AutoQueueManager {
    LeagueGameState* leagueGameState;
    
    //Image data to scan for
    ImageData step1_PlayButton, step2_PVPMode, step3_ClassicMode, step4_SummonersRiftMode, step5_BlindPickMode, step6_SoloButton, step7_AcceptButton, step8_RandomChampionButton, step9_LockInButton, step10_ChooseSkinButton, step11_EndGameContinueButton, step12_HomeButton, step13_ReconnectButton;//, testImage1, testImage2;
    
    //Variables shared between logic and detection theads
    //Tells detection what to look for when the screen changes
    volatile Boolean scanForPlayButton, scanForAcceptButton, scanForRandomChampionButton, scanForLockInButton, scanForChooseSkinButton, scanForReconnectButton, scanForHomeButton, scanForEndGameButton, scanForNormalBlindPick;
    
    //When the detection finds the button, it tells the Logic using these Logic thread variables
    Position playButtonLocation, acceptButtonLocation, randomChampionButtonLocation, lockInButtonLocation, chooseSkinButtonLocation, reconnectButtonLocation, homeButtonLocation, endGameButtonLocation, normalBlindPickLocation;
    Boolean foundPlayButton, foundAcceptButton, foundRandomChampionButton, foundLockInButton, foundChooseSkinButton, foundReconnectButton, foundHomeButton, foundEndGameButton, foundNormalBlindPickButton;
    
    //This is the current step the logic is on
    int currentStep;
    
    //For detection only, allows the scanning to trim search area
    Position detectionPlayButtonReferenceLocation;
    
    //double lastScreenScan, lastEndGameScan;
    //Position playButtonLocation;
    int step5ScanCurrentChunkX, step5ScanCurrentChunkY;

public:
    
    AutoQueueManager(LeagueGameState* gameState);
    bool processDetection(ImageData data, const CGRect* rects, size_t num_rects);
    void processLogic();
    void reset(bool keepPlayButton);
    void clickLocation(int x, int y);
    //void checkForEndGame(ImageData data);
};