//
//  AppDelegate.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LeagueGameState.h"
#import <time.h>
#import "TestController.h"
#import "LeagueDetector.h"
#include <CoreGraphics/CoreGraphics.h>
#import <IOSurface/IOSurfaceBase.h>
#import <IOKit/IOKitLib.h>
#import <IOSurface/IOSurface.h>
#import "AutoQueueManager.h"
#import "BasicAI.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    @public IBOutlet NSImageView* unprocessedImage, *processedImage, *targetImage, *foundImage;
    IBOutlet NSTextView* logText;
    @public IBOutlet NSTextField *fpsText, *screenAnalyzeText;
    
@public IBOutlet NSTextField *selfCurrentLvlTxt, *enemyTowersTxt, *allyMinionsTxt, *enemyMinionsTxt, *allyChampsTxt, *enemyChampsTxt, *selfChampsTxt, *selfHealthTxt, *mapTxt, *mapLocTxt, *mapShopTxt, *item1Txt, *item2Txt, *item3Txt, *item4Txt, *item5Txt, *item6Txt, *summonerSpell1Txt, *summonerSpell2Txt, *trinketTxt, *usedPotionTxt, *potionActiveTxt, *spell1Txt, *spell2Txt, *spell3Txt, *spell4Txt, *spell1LvlUpTxt, *spell2LvlUpTxt, *spell3LvlUpTxt, *spell4LvlUpTxt, *spell1LvlTxt, *spell2LvlTxt, *spell3LvlTxt, *spell4LvlTxt, *shopAvailableTxt, *shopWindowOpenTxt, *buyableItemsTxt, *statusText;
    
    //NSTimer* timer;
    @public LeagueGameState* leagueGameState;
    @public AutoQueueManager* autoQueueManager;
    //AVCaptureScreenInput *input;
    
    //AVCaptureSession *mSession;
    
    IBOutlet NSImageView* imageView;
    IBOutlet NSButton* debugCheckbox;
    @public IBOutlet NSButton* autoQueueCheckbox, *recordScreenCheckbox, *aiActiveCheckbox;
    //IBOutlet NSTextField* fpsTextField;
    //int chosenFPS;
    
    double lastSaveImage;
    
    @public bool saveTestScreenshot;
    @public TestController* testController;
    LeagueDetector* leagueDetector;
    
    CGDisplayStreamRef stream;
    
    volatile bool runAutoQueue;
    
    @public BasicAI* basicAI;
    
    dispatch_source_t timer;
    
    @public uint64_t uiUpdateTime;
    
    @public dispatch_queue_t aiThread, detectionThread;
    
}
@property (strong) id activity;
@property (weak) IBOutlet NSWindow *window, *window2;

- (IBAction) openViewWindow:(id)sender;
- (IBAction) getScreenshot:(id)sender;
- (IBAction) testPlayButton:(id)sender;
- (IBAction) runAutoQueueButton:(id)sender;

- (IBAction) testSelfDetection:(id)sender;
- (IBAction) testAllyChampDetection:(id)sender;
- (IBAction) testEnemyChampDetection:(id)sender;
- (IBAction) testEnemyMinionDetection:(id)sender;
- (IBAction) testAllyMinionDetection:(id)sender;
- (IBAction) testEnemyTowerDetection:(id)sender;
- (IBAction) testLevelUpDetection:(id)sender;
- (IBAction) testLevelDotDetection:(id)sender;
- (IBAction) testEnabledAbilityDetection:(id)sender;
- (IBAction) testEnabledSummonerSpellDetection:(id)sender;
- (IBAction) testTrinketActiveDetection:(id)sender;
- (IBAction) testItemActivesDetection:(id)sender;
- (IBAction) testPotionActivesDetection:(id)sender;
- (IBAction) testUsedPotionDetection:(id)sender;
- (IBAction) testShopAvailableDetection:(id)sender;
- (IBAction) testShopTopLeftCornerDetection:(id)sender;
- (IBAction) testShopBottomLeftCornerDetection:(id)sender;
- (IBAction) testShopBuyableItemsDetection:(id)sender;
- (IBAction) testMapDetection:(id)sender;
- (IBAction) testMapShopDetection:(id)sender;
- (IBAction) testMapLocation:(id)sender;

@end

