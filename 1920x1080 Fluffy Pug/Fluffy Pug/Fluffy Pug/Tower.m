//
//  Tower.m
//  Fluffy Pug
//
//  Created by Matthew French on 9/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "Tower.h"
#import "Utility.h"

@implementation Tower
- (instancetype)init
{
    self = [super init];
    if (self) {
        //Position topLeft, topRight, bottomLeft, bottomRight, characterCenter;
        detectedTopLeft = false;
        detectedBottomLeft = false;
        detectedTopRight = false;
        detectedBottomRight = false;
        health = 0;
    }
    return self;
}
@end
