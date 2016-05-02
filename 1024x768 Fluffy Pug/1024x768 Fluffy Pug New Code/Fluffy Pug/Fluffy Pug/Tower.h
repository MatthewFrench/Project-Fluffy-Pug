//
//  Tower.h
//  Fluffy Pug
//
//  Created by Matthew French on 9/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#include "Position.h"

class Tower {
public:
    Tower();
    Position topLeft, topRight, bottomLeft, bottomRight, towerCenter;
    bool detectedTopLeft, detectedBottomLeft, detectedTopRight, detectedBottomRight;
    float health;
    float lowestPercentageMatch;
};