//
//  AllyMinionManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/27/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"
#include "concurrentqueue.h"
#import <time.h>

class SelfChampionManager {
    
    
    //moodycamel::ConcurrentQueue<Position> topLeftQueue, bottomLeftQueue, topRightQueue, bottomRightQueue;
    
    //bool needsFullScreenUpdate;
    
    //double fullScreenUpdateTime, lastUpdateTime;
    
    //void scanSection(ImageData imageData, int xStart, int yStart, int xEnd, int yEnd);
    //void processChampionsLocations();
    //static float detectChampionHealth(ImageData imageData, ChampionBar* championBar);
    
    //static NSMutableArray* detectTopLeftCorners();
    //static NSMutableArray* detectBottomLeftCorners();
    //static NSMutableArray* detectTopRightCorners();
    //static NSMutableArray* detectBottomRightCorners();
    //bool containsPosition(NSMutableArray* array, Position p);
    
    /*
     I bet I can make the entire champion health bar detection self contained.
     Scan 1 pixel, in that pixel if will search for each corner for a health bar match.
     Depending on the corner found, it will search for the other corners at the correct width and height.
     If it matches 2 corners, it will find the health bar there. 
     Once health bar is found it will search for health bar health.
     Then it returns for that pixel.
     */
    
    
    //const double championSpeed = 1000; //100 pixels per second
    
public:
    
    static ImageData topLeftImageData, bottomLeftImageData,
    bottomRightImageData, topRightImageData, healthSegmentImageData, bottomBarLeftSideImageData, bottomBarRightSideImageData,
    bottomBarAverageHealthColorImageData;
    //NSMutableArray* championBars, *topRightDetect, *topLeftDetect, *bottomRightDetect, *bottomLeftDetect;
    
    SelfChampionManager();
    static Champion* detectChampionBarAtPixel(ImageData imageData, uint8_t *pixel, int x, int y);
    static NSMutableArray* validateChampionBars(ImageData imageData, NSMutableArray* detectedChampionBars);
    static SelfHealth* detectSelfHealthBarAtPixel(ImageData imageData, uint8_t *pixel, int x, int y);
    static NSMutableArray* validateSelfHealthBars(ImageData imageData, NSMutableArray* detectedHealthBars);
    //void processImage(ImageData imageData);
    //void debugDraw(ImageData imageData);
};