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
    shopBuyableItemImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Buyable Item" ofType:@"png"]);
    shopUnbuyableItemImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Shop/Unbuyable Item" ofType:@"png"]);
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
                    if (abs(item.y - topShelf.y) <= 20) {
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
    if (lastFullScreenUpdate >= 1.8 || (lastFullScreenUpdate >= 0.5 && buyingItems)) { //It's been a whole second, scan the screen
        fullScreenUpdateTime = clock();
        needsFullScreenUpdate = true;
    }
    
    if (needsFullScreenUpdate) {
        needsFullScreenUpdate = false;
        shopAvailable = false;
        
        //Detect shop available
        int yStart = imageData.imageHeight - 32;
        int yEnd = imageData.imageHeight - 15;
        int xStart = 128;
        int xEnd = 150;
        
        double shopAvailablePercent = 0;
        Position p = detectRelativeImageInImagePercentage(shopAvailableImageData, imageData, 0.85, xStart, yStart, xEnd, yEnd, shopAvailablePercent);
        //NSLog(@"Shop available location: %d, %d", p.x, p.y);
        if (p.x != -1) {
            shopAvailable = true;
        }
        
        shopOpen = false;
        yStart = 0;
        yEnd = 50;
        xStart = 100;
        xEnd = 200;
        
        topLeftCornerPosition = detectRelativeImageInImage(shopWindowImageData, imageData, 0.82, xStart, yStart, xEnd, yEnd);
       // NSLog(@"Shop top left corner: %d, %d", topLeftCornerPosition.x, topLeftCornerPosition.y);
        if (topLeftCornerPosition.x != -1) {
            shopOpen = true;
            //NSLog(@"Shop Open");
            //NSLog(@"Shop top left corner: %d, %d", topLeftCornerPosition.x, topLeftCornerPosition.y);
        }
        
        if (shopOpen && shopAvailable) {
            yStart = imageData.imageHeight-200;
            yEnd = imageData.imageHeight;
            xStart = topLeftCornerPosition.x-30;
            xEnd = topLeftCornerPosition.x+30;
            if (xStart < 0) xStart = 0;
            
            bottomLeftCornerPosition = detectRelativeImageInImage(shopBottomLeftCornerImageData, imageData, 0.5, xStart, yStart, xEnd, yEnd);
            bottomLeftCornerPosition.y += shopBottomLeftCornerImageData.imageHeight;
            
            //Detect empty item slots
            //163, 107
            emptyItemSlots = 0;
            yStart = bottomLeftCornerPosition.y - 70;
            yEnd = bottomLeftCornerPosition.y - 24;
            xStart = bottomLeftCornerPosition.x+15;
            xEnd = bottomLeftCornerPosition.x + 65;
            
            for (int i = 0; i < 6; i++) {
                p = detectRelativeImageInImage(shopEmptyItemSlotImageData, imageData, 0.7, xStart, yStart, xEnd, yEnd);
                if (p.x != -1) {
                    //NSLog(@"Found empty item slot");
                    emptyItemSlots++;
                    xStart = p.x + 40;
                    xEnd = p.x + xStart + 50;
                } else {
                    //NSLog(@"Didn't find empty item slot");
                    xStart += 42; xEnd += 42;
                }
            }
            
            //Detect buyable items
            [buyableItems removeAllObjects];
            yStart = topLeftCornerPosition.y + 150;
            yEnd = bottomLeftCornerPosition.y - 100;
            xStart = topLeftCornerPosition.x+20;
            xEnd = topLeftCornerPosition.x + 400;
            
            //NSLog(@"Start: %d, %d and end %d, %d", xStart, yStart, xEnd, yEnd);
            
            NSMutableArray* unsortedBuyableItems = [NSMutableArray new];
            for (int x = xStart; x < xEnd; x+=shopBuyableItemImageData.imageWidth) {
                for (int y = yStart; y < yEnd; y+=shopBuyableItemImageData.imageHeight) {
                    double p1Percent = 0;
                    Position p1 = detectRelativeImageInImagePercentage(shopBuyableItemImageData, imageData, 0.6, x, y, x+50, y+68, p1Percent);
                    double p2Percent = 0;
                    Position p2 = detectRelativeImageInImagePercentage(shopUnbuyableItemImageData, imageData, 0.6, x, y, x+50, y+68, p2Percent);
                    if (p1Percent > p2Percent) {
                        p = p1;
                    } else {
                        p = p2;
                    }
                    if (p.x != -1) {
                        x = p.x;
                        y = p.y;
                        //NSLog(@"Found buyable item: %d %d", p.x, p.y);
                        [unsortedBuyableItems addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
                    }
                }
            }
            //Sort buyable items along x and y
            while ([unsortedBuyableItems count] > 0) {
                NSValue* unsortedItem = [unsortedBuyableItems lastObject];
                [unsortedBuyableItems removeLastObject];
                Position p;
                [unsortedItem getValue:&p];
                if ([buyableItems count] == 0) {
                    [buyableItems addObject:unsortedItem];
                } else {
                    int placeBeforeIndex = 0;
                    for (int i = 0; i < [buyableItems count]; i++) {
                        NSValue* sortedItem = [buyableItems objectAtIndex:i];
                        Position p2;
                        [sortedItem getValue:&p2];
                        if (abs(p.y-p2.y) > 20 && p.y < p2.y ) {
                            placeBeforeIndex = i;
                            break;
                        } else if (p.x < p2.x && abs(p.y-p2.y) <= 20) {
                            placeBeforeIndex = i;
                            break;
                        }
                    }
                    [buyableItems insertObject:unsortedItem atIndex:placeBeforeIndex];
                }
            }
            
            
            //p = detectRelativeImageInImage(shopItemImageData, imageData, 0.8, xStart, yStart, xEnd, yEnd);
            //NSLog(@"Item Image Detection position: %d %d", p.x, p.y);
            /*
            for (int y = yStart; y < yEnd; y++) {
                uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
                
                for (int x = xStart; x < xEnd; x++) {
                    if (x >= 0 && y >= 0 && x < imageData.imageWidth && y < imageData.imageHeight) {
                        if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, shopItemImageData, 5)) {
                            Position p = makePosition(x, y);
                            [buyableItems addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
                            x += shopItemImageData.imageWidth;
                        }
                    }
                    pixel += 4;
                }
            }*/
            //NSLog(@"Buyable items: %lu", (unsigned long)[buyableItems count]);
        }
        
    }
}