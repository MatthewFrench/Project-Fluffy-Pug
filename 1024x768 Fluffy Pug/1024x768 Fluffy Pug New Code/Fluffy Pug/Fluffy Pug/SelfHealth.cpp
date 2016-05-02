//
//  SelfHealth.m
//  Fluffy Pug
//
//  Created by Matthew French on 9/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#include "SelfHealth.h"

SelfHealth::SelfHealth () {
    detectedLeftSide = false;
    detectedRightSide = false;
    health = 0;
    lowestPercentageMatch = 1.0;
}