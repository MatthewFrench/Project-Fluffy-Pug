//
//  ShopManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 6/12/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Utility.h"
#import <time.h>
#import "InteractiveEvents.h"

class ShopManager {
    
    //void detectItems();
    /*
    bool needsFullScreenUpdate;
    
    double fullScreenUpdateTime;
    double lastShopOpenAttempt, lastShopCloseAttempt;
    Position bottomLeftCornerPosition, topLeftCornerPosition;
    NSMutableArray* buyableItems;
    int emptyItemSlots;
    double lastItemBuyTime;
     */
    //bool usedItemInFrame;
    //double item1Time, item2Time, item3Time, trinketTime, item5Time, item6Time, item7Time;
public:
    static ImageData shopWindowImageData, shopEmptyItemSlotImageData, shopAvailableImageData, shopBottomLeftCornerImageData, shopItemImageData;
    ShopManager();
    /*
    bool shopAvailable, boughtItems, buyingItems;
    bool shopOpen;
    ShopManager();
    void processImage(ImageData imageData);
    void openShop();
    void buyItems();
    void closeShop();
     */
};