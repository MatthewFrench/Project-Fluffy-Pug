//
//  AppDelegate.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LeagueGameState.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSTextField* statusText, *fpsText, *allyMinionText;
    NSTimer* timer;
    LeagueGameState* leagueGameState;
}
@property (weak) IBOutlet NSWindow *window;

@end

