//
//  SelfHealth.h
//  Fluffy Pug
//
//  Created by Matthew French on 9/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#include "Position.h"

class SelfHealth {
public:
    SelfHealth();
    Position topLeft, topRight, bottomLeft, bottomRight, characterCenter;
    bool detectedLeftSide, detectedRightSide;
    float health;
    float lowestPercentageMatch;
};