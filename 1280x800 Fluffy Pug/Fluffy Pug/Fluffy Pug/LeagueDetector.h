//
//  LeagueDetector.hpp
//  Fluffy Pug
//
//  Created by Matthew French on 7/31/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import <Cocoa/Cocoa.h>

class LeagueDetector {
    
public:
    LeagueDetector();
    void detectLeagueWindow();
    
    int leaguePID = -1;
    float xOrigin;
    float yOrigin;
    float width;
    float height;
};