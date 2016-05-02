//
//  GenericObject.h
//  Fluffy Pug
//
//  Created by Matthew French on 9/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#include "Position.h"

class GenericObject {
public:
    GenericObject();
    Position topLeft, topRight, bottomLeft, bottomRight, center;
    float lowestPercentageMatch;
};