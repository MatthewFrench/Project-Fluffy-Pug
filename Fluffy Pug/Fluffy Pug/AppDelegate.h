//
//  AppDelegate.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LeagueGameState.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    IBOutlet NSTextField* statusText, *fpsText, *allyMinionText, *enemyMinionText, *enemyChampionText, *selfChampionText, *allyChampionText;
    NSTimer* timer;
    LeagueGameState* leagueGameState;
    AVCaptureScreenInput *input;
    
    AVCaptureSession *mSession;
    
    IBOutlet NSImageView* imageView;
    IBOutlet NSButton* debugCheckbox;
    IBOutlet NSTextField* fpsTextField;
    int chosenFPS;
}
@property (weak) IBOutlet NSWindow *window, *window2;

@end

