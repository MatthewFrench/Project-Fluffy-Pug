//
//  Champion.h
//  Fluffy Pug
//
//  Created by Matthew French on 9/10/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Position.hpp"

@interface Champion : NSObject {
@public
    Position topLeft, topRight, bottomLeft, bottomRight, characterCenter;
    bool detectedTopLeft, detectedBottomLeft, detectedTopRight, detectedBottomRight;
    float health;
}
@end