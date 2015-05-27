//
//  AllyMinionManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

@interface AllyMinionManager : NSObject {
    NSMutableArray* minionBars;
}

@property NSMutableArray* minionBars;

- (void) detectAllyMinions:(struct ImageData)imageData;

@end