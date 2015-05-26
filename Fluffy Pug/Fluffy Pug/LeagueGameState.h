//
//  LeagueGameState.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeagueGameState : NSObject

@property int leaguePID;
@property CGRect leagueSize;

- (void) processImage:(CGImageRef)image;

@end
