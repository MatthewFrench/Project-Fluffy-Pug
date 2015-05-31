//
//  LeagueGameState.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "LeagueGameState.h"

//@implementation LeagueGameState
//@synthesize leaguePID, leagueSize, allyMinionManager;

LeagueGameState::LeagueGameState() {
    leaguePID = -1;
    allyMinionManager = new AllyMinionManager();
}

void LeagueGameState::processImage(struct ImageData image) {
    imageData = image;
    allyMinionManager->setImageData(imageData);
    allyMinionManager->prepareForPixelProcessing();
    
    int cores = 4;
    int section = imageData.imageHeight/cores;
    if (section < 1) {
        section = 1;
    }
    
    dispatch_apply(cores, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(size_t i) {
        int yStart = section * (int)i;
        int yEnd = yStart + section;
        if (i == cores - 1) {
            yEnd = imageData.imageHeight;
        }
        uint8_t *pixel = imageData.imageData + (yStart * imageData.imageWidth)*4;
        for (int y = yStart; y < yEnd; y++) {
            //for (int y = 0; y < imageData.imageHeight; y++) {
            //uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth)*4;
            for (int x = 0; x < imageData.imageWidth; x++) {
                allyMinionManager->processPixel(pixel, x, y);
                pixel += 4;
            }
        }
    });
    
    allyMinionManager->postPixelProcessing();
}