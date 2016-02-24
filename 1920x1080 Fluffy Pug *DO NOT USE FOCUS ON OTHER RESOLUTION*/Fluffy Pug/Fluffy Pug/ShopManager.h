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
    static ImageData shopTopLeftCornerImageData, shopAvailableImageData, shopBottomLeftCornerImageData, shopBuyableItemTopLeftCornerImageData, shopBuyableItemBottomLeftCornerImageData, shopBuyableItemTopRightCornerImageData, shopBuyableItemBottomRightCornerImageData;
    ShopManager();
    static GenericObject* detectShopAvailable(ImageData imageData, uint8_t *pixel, int x, int y);
    static GenericObject* detectShopTopLeftCorner(ImageData imageData, uint8_t *pixel, int x, int y);
    static GenericObject* detectShopBottomLeftCorner(ImageData imageData, uint8_t *pixel, int x, int y);
    static GenericObject* detectBuyableItems(ImageData imageData, uint8_t *pixel, int x, int y);
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