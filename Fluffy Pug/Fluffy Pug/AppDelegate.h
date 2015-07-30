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

@interface AppDelegate : NSObject <NSApplicationDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    IBOutlet NSTextField* statusText, *fpsText, *allyMinionText, *enemyMinionText, *enemyChampionText, *selfChampionText, *allyChampionText;
    IBOutlet NSImageView* unprocessedImage, *processedImage, *targetImage, *foundImage;
    IBOutlet NSTextView* logText;
    NSTimer* timer;
    LeagueGameState* leagueGameState;
    AVCaptureScreenInput *input;
    
    AVCaptureSession *mSession;
    
    IBOutlet NSImageView* imageView;
    IBOutlet NSButton* debugCheckbox;
    IBOutlet NSButton* autoQueueCheckbox, *recordScreenCheckbox, *aiActiveCheckbox;
    IBOutlet NSTextField* fpsTextField;
    int chosenFPS;
    
    double lastSaveImage;
    
    bool saveTestScreenshot;
    TestController* testController;
}
@property (strong) id activity;
@property (weak) IBOutlet NSWindow *window, *window2;

- (IBAction) openViewWindow:(id)sender;
- (IBAction) getScreenshot:(id)sender;
- (IBAction) testPlayButton:(id)sender;

@end

