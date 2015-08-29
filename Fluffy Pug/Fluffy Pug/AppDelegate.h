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
    @public IBOutlet NSTextField* statusText, *allyMinionText, *enemyMinionText, *enemyChampionText, *selfChampionText, *allyChampionText;
    @public IBOutlet NSImageView* unprocessedImage, *processedImage, *targetImage, *foundImage;
    IBOutlet NSTextView* logText;
    @public IBOutlet NSTextField *fpsText, *screenAnalyzeText;
    NSTimer* timer;
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
    
    dispatch_queue_t streamQueue;
    CGDisplayStreamRef stream;
    
    volatile bool runAutoQueue;
    
    @public BasicAI* basicAI;
    
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

@end

