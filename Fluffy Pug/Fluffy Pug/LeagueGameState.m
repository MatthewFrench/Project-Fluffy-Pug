//
//  LeagueGameState.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "LeagueGameState.h"

LeagueGameState::LeagueGameState(dispatch_queue_t _aiThread, dispatch_queue_t _detectionThread) {
    autoQueueActive = false;
    leaguePID = -1;

    detectionManager = new DetectionManager(_aiThread, _detectionThread);
}
void LeagueGameState::processLogic() {
    
}

void LeagueGameState::processDetection(ImageData image) {
    //if (leaguePID != -1) {
        detectionManager->processDetection(image);
    //}
}
void LeagueGameState::debugDraw(ImageData imageData) {
}