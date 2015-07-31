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

@interface AppDelegate : NSObject <NSApplicationDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    @public IBOutlet NSTextField* statusText, *allyMinionText, *enemyMinionText, *enemyChampionText, *selfChampionText, *allyChampionText;
    @public IBOutlet NSImageView* unprocessedImage, *processedImage, *targetImage, *foundImage;
    IBOutlet NSTextView* logText;
    @public IBOutlet NSTextField *fpsText, *screenAnalyzeText;
    NSTimer* timer;
    @public LeagueGameState* leagueGameState;
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
    
}
@property (strong) id activity;
@property (weak) IBOutlet NSWindow *window, *window2;

- (IBAction) openViewWindow:(id)sender;
- (IBAction) getScreenshot:(id)sender;
- (IBAction) testPlayButton:(id)sender;

@end

