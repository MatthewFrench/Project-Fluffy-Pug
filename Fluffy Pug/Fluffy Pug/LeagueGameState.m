//
//  LeagueGameState.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "LeagueGameState.h"

LeagueGameState::LeagueGameState() {
    leaguePID = -1;
    allyMinionManager = new AllyMinionManager();
    enemyMinionManager = new EnemyMinionManager();
    enemyChampionManager = new EnemyChampionManager();
}

void LeagueGameState::processImage(struct ImageData image) {
    imageData = image;
    
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    // Add a task to the group
    dispatch_group_async(dispatchGroup, queue, ^{
        allyMinionManager->processImage(image);
    });
    dispatch_group_async(dispatchGroup, queue, ^{
        enemyMinionManager->processImage(image);
    });
    dispatch_group_async(dispatchGroup, queue, ^{
        enemyChampionManager->processImage(image);
    });

    // wait on the group to block the current thread.
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER);
    
    
    //allyMinionManager->setImageData(imageData);
    //allyMinionManager->prepareForPixelProcessing();
    //allyMinionManager->processImage(image);
    
    //enemyMinionManager->setImageData(imageData);
    //enemyMinionManager->prepareForPixelProcessing();
    //enemyMinionManager->processImage(image);
    
    //enemyChampionManager->processImage(image);
    
    //enemyChampionManager->setImageData(imageData);
    //enemyChampionManager->prepareForPixelProcessing();
    /*
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
            for (int x = 0; x < imageData.imageWidth; x++) {
                allyMinionManager->processPixel(pixel, x, y);
                //enemyMinionManager->processPixel(pixel, x, y);
                //enemyChampionManager->processPixel(pixel, x, y);
                pixel += 4;
            }
        }
    });*/
    
    //allyMinionManager->postPixelProcessing();
    //enemyMinionManager->postPixelProcessing();
    //enemyChampionManager->postPixelProcessing();
}
void LeagueGameState::debugDraw() {
    allyMinionManager->debugDraw();
    enemyMinionManager->debugDraw();
    enemyChampionManager->debugDraw();
}