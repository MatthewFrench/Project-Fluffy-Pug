//
//  LeagueGameState.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "LeagueGameState.h"

@implementation LeagueGameState
@synthesize leaguePID, leagueSize, allyMinionManager;;
-(id)init {
    if ( self = [super init] ) {
        leaguePID = -1;
        allyMinionManager = [AllyMinionManager new];
    }
    return self;
}

- (void) processImage:(struct ImageData)image {
    imageData = image;
    //imageData = makeImageData(image, leagueSize);
    
    [allyMinionManager detectAllyMinions:imageData];
    
    //CFRelease(imageData.rawData);
}

@end