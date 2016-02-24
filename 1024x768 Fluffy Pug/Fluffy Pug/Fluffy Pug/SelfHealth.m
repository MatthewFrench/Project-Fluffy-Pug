//
//  SelfHealth.m
//  Fluffy Pug
//
//  Created by Matthew French on 9/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "SelfHealth.h"
#import "Utility.h"

@implementation SelfHealth
- (instancetype)init
{
    self = [super init];
    if (self) {
        //Position topLeft, topRight, bottomLeft, bottomRight, characterCenter;
        detectedLeftSide = false;
        detectedRightSide = false;
        health = 0;
    }
    return self;
}
@end
