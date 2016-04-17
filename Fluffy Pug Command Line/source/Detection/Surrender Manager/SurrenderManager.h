//
//  ItemManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Utility.h"
#import <time.h>
#import "InteractiveEvents.h"

class SurrenderManager {
public:
    static ImageData surrenderImageData;
    
    static GenericObject* detectSurrenderAtPixel(ImageData imageData, uint8_t *pixel, int x, int y);
};