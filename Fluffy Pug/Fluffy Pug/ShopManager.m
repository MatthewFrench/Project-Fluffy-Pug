//
//  ShopManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/12/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "ShopManager.h"

//
//  ShopManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "ShopManager.h"

ShopManager::ShopManager() {
    fullScreenUpdateTime = clock();
    shopItemImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Item" ofType:@"png"]);
    shopWindowImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Shop Window" ofType:@"png"]);
    shopEmptyItemSlotImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Empty Item Slot" ofType:@"png"]);
    shopAvailableImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Shop Available" ofType:@"png"]);
    shopBottomLeftCornerImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Shop Bottom Left Corner" ofType:@"png"]);
    buyableItems = [NSMutableArray new];
    lastShopOpenAttempt = clock();
    lastShopCloseAttempt = clock();
    lastItemBuyTime = clock();
}

void ShopManager::openShop() {
    if (!shopOpen && ((clock() - lastShopOpenAttempt)/CLOCKS_PER_SEC >= 5.0)) {
        lastShopOpenAttempt = clock();
        boughtItems = false;
        tapShop();
    }
    if (!shopAvailable) {
        boughtItems = true;
    }
}
void ShopManager::closeShop() {
    if (shopOpen && ((clock() - lastShopCloseAttempt)/CLOCKS_PER_SEC >= 5.0)) {
        lastShopCloseAttempt = clock();
        tapShop();
    }
    if (!shopAvailable) {
        boughtItems = true;
    }
}

void ShopManager::buyItems() {
    if (!shopAvailable) {
        boughtItems = true;
    }
    if (shopOpen && (clock() - lastItemBuyTime)/CLOCKS_PER_SEC >= 5.0) {
        int buyCount = 0;
        lastItemBuyTime = clock();
        if ([buyableItems count] == 0) {
            boughtItems = true;
        } else {
            //Buy items
            Position topShelf;
            [[buyableItems firstObject] getValue:&topShelf];
            if (emptyItemSlots == 6) { //No items so buy from top shelf
                for (int i = 0; i < [buyableItems count]; i++) {
                    Position item;
                    [[buyableItems objectAtIndex:i] getValue:&item];
                    if (item.y == topShelf.y) {
                        buyCount++;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * buyCount * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            lastItemBuyTime = clock();
                            doubleTapMouseLeft(item.x+20, item.y+15);
                        });
                        //doubleTapMouseLeft(item.x+2, item.y+10);
                    }
                }
            }
            if (emptyItemSlots != 0) {
                //Remove top self items
                for (int i = 0; i < [buyableItems count]; i++) {
                    Position item;
                    [[buyableItems objectAtIndex:i] getValue:&item];
                    if (item.y == topShelf.y) {
                        [buyableItems removeObjectAtIndex:i];
                        i--;
                    }
                }
                //Buy other items
                int start = 0+(5-emptyItemSlots);
                if (start < 0 || start > [buyableItems count]) start = 0;
                for (int i = start; i < [buyableItems count]; i++) {
                    Position item;
                    [[buyableItems objectAtIndex:i] getValue:&item];
                    buyCount++;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * buyCount * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        lastItemBuyTime = clock();
                        doubleTapMouseLeft(item.x+20, item.y+15);
                    });
                }
            } else { //Buy all items
                for (int i = 0; i < [buyableItems count]; i++) {
                    Position item;
                    [[buyableItems objectAtIndex:i] getValue:&item];
                    buyCount++;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * buyCount * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        lastItemBuyTime = clock();
                        doubleTapMouseLeft(item.x+20, item.y+15);
                    });
                }
            }
            buyCount++;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * buyCount * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                lastItemBuyTime = clock();
                boughtItems = true;
            });
        }
    }
}

void ShopManager::processImage(ImageData data) {
    imageData = data;
    
    double lastFullScreenUpdate = (clock() - fullScreenUpdateTime)/CLOCKS_PER_SEC;
    if (lastFullScreenUpdate >= 0.25) { //It's been a whole second, scan the screen
        fullScreenUpdateTime = clock();
        needsFullScreenUpdate = true;
    }
    
    if (needsFullScreenUpdate) {
        shopAvailable = false;
        
        //Detect shop available
        int yStart = imageData.imageHeight - 30;
        int yEnd = imageData.imageHeight;
        int xStart = imageData.imageWidth/2 +124;
        int xEnd = imageData.imageWidth/2 + 210;
        for (int y = yStart; y < yEnd; y++) {
            uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
            
            for (int x = xStart; x < xEnd; x++) {
                if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopAvailableImageData, 2)) {
                    shopAvailable = true;
                    x = xEnd; y = yEnd;
                }
                pixel += 4;
            }
        }
        
        
        if (shopAvailable) {
            shopOpen = false;
            yStart = 0;
            yEnd = imageData.imageHeight;
            xStart = 0;
            xEnd = imageData.imageWidth;
            for (int y = yStart; y < yEnd; y++) {
                uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
                
                for (int x = xStart; x < xEnd; x++) {
                    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopWindowImageData, 30)) {
                        shopOpen = true;
                        topLeftCornerPosition = makePosition(x, y);
                        x = xEnd; y = yEnd;
                    }
                    pixel += 4;
                }
            }
        }
        if (shopOpen && shopAvailable) {
            for (int y = yStart; y < yEnd; y++) {
                uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
                
                for (int x = xStart; x < xEnd; x++) {
                    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopBottomLeftCornerImageData, 30)) {
                        bottomLeftCornerPosition = makePosition(x, y + shopBottomLeftCornerImageData.imageHeight);
                        x = xEnd; y = yEnd;
                    }
                    pixel += 4;
                }
            }
            //Detect empty item slots
            //163, 107
            emptyItemSlots = 0;
            yStart = bottomLeftCornerPosition.y - 107;
            yEnd = bottomLeftCornerPosition.y - 2;
            xStart = bottomLeftCornerPosition.x+2;
            xEnd = bottomLeftCornerPosition.x + 163;
            for (int y = yStart; y < yEnd; y++) {
                uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
                
                for (int x = xStart; x < xEnd; x++) {
                    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopEmptyItemSlotImageData, 25)) {
                        emptyItemSlots++;
                    }
                    pixel += 4;
                }
            }
            //Detect buyable items
            [buyableItems removeAllObjects];
            yStart = topLeftCornerPosition.y + 100;
            yEnd = topLeftCornerPosition.y + 600;
            xStart = topLeftCornerPosition.x;
            xEnd = topLeftCornerPosition.x + 400;
            for (int y = yStart; y < yEnd; y++) {
                uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
                
                for (int x = xStart; x < xEnd; x++) {
                    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopItemImageData, 40)) {
                        Position p = makePosition(x, y);
                        [buyableItems addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
                    }
                    pixel += 4;
                }
            }
        }
        
    }
}