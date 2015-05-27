//
//  LeagueGameState.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AllyMinionManager.h"
#import "Utility.h"

@interface LeagueGameState : NSObject {
    int leaguePID;
    CGRect leagueSize;
    struct ImageData imageData;
    AllyMinionManager* allyMinionManager;
}

- (void) processImage:(CGImageRef)image;


@property int leaguePID;
@property CGRect leagueSize;
@property AllyMinionManager* allyMinionManager;

@end