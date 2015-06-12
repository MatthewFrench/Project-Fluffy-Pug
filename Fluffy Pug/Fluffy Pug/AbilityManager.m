//
//  AbilityManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/11/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "AbilityManager.h"

AbilityManager::AbilityManager() {
    levelUpDetect = [NSMutableArray new];
    levelUpDisabledDetect = [NSMutableArray new];
    abilityEnabledDetect = [NSMutableArray new];
    abilityDisabledDetect = [NSMutableArray new];
    
    enabledSummonerSpellImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Skill Bar/Enabled Summoner Spell" ofType:@"png"]);
    levelDotImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Skill Bar/Leveled Dot" ofType:@"png"]);
    levelUpImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Skill Bar/Level Up" ofType:@"png"]);
    levelUpDisabledImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Skill Bar/Level Up Disabled" ofType:@"png"]);
    abilityEnabledImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Skill Bar/Enabled Ability" ofType:@"png"]);
    abilityDisabledImageData = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Skill Bar/Disabled Ability" ofType:@"png"]);
    ability1LevelUpAvailable = false;
    ability2LevelUpAvailable = false;
    ability3LevelUpAvailable = false;
    ability4LevelUpAvailable = false;
    ability1Ready = false;
    ability2Ready = false;
    ability3Ready = false;
    ability4Ready = false;
    summonerSpell1Ready = false;
    summonerSpell2Ready = false;
    
    needsFullScreenUpdate = true;
    fullScreenUpdateTime = clock();
    lastUpdateTime = clock();
    
    levelUpCount = 0;
}

void AbilityManager::processImage(ImageData data) {
    imageData = data;
    
    lastUpdateTime = clock();
    double lastFullScreenUpdate = (clock() - fullScreenUpdateTime)/CLOCKS_PER_SEC;
    if (lastFullScreenUpdate >= 2.0) { //It's been a whole second, scan the screen
        fullScreenUpdateTime = clock();
        needsFullScreenUpdate = true;
    }
    
    if (needsFullScreenUpdate) { //Detect level up every second
        detectLevelUp();
        detectLevelUpCount();
    }
    //Now detect ability availability every frame
    detectAbilities();
    detectSummonerSpells();
    
    //if (ability1Ready)  NSLog(@"Q is ready");
    //if (ability2Ready)  NSLog(@"W is ready");
    //if (ability3Ready)  NSLog(@"E is ready");
    //if (ability4Ready)  NSLog(@"R is ready");
}

void AbilityManager::detectLevelUp() {
    [levelUpDetect removeAllObjects];
    [levelUpDisabledDetect removeAllObjects];
    
    //Detect level up icon
    //160 pixels from bottom of screen to 100 pixels from bottom of screen
    //middle of screen -300 and +300
    int yStart = imageData.imageHeight - 160;
    int yEnd = imageData.imageHeight - 100;
    int xStart = imageData.imageWidth/2 - 300;
    int xEnd = imageData.imageWidth/2 + 300;
    
    //yStart = 0; xStart = 0; yEnd = imageData.imageHeight; xEnd = imageData.imageWidth;
    
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
        
        for (int x = xStart; x < xEnd; x++) {
            processPixelLevelUp(pixel, x, y);
            pixel += 4;
        }
    }
    
    if ([levelUpDetect count] == 0) {
        ability1LevelUpAvailable = false;
        ability2LevelUpAvailable = false;
        ability3LevelUpAvailable = false;
        ability4LevelUpAvailable = false;
    }
    
    int abilityCount = 0;
    while ([levelUpDetect count] > 0 || [levelUpDisabledDetect count] > 0) {
        Position p;
        NSMutableArray* arr;
        NSValue* val = NULL;
        //Array 1
        for (int i = 0; i < [levelUpDetect count]; i++) {
            Position p2;
            NSValue* val2 = [levelUpDetect objectAtIndex:i];
            [val2 getValue:&p2];
            if (val == NULL) {
                val = val2;
                p = p2;
                arr = levelUpDetect;
            } else if (p2.x < p.x) {
                val = val2;
                p = p2;
                arr = levelUpDetect;
            }
        }
        //Array 2
        for (int i = 0; i < [levelUpDisabledDetect count]; i++) {
            Position p2;
            NSValue* val2 = [levelUpDisabledDetect objectAtIndex:i];
            [val2 getValue:&p2];
            if (val == NULL) {
                val = val2;
                p = p2;
                arr = levelUpDisabledDetect;
            } else if (p2.x < p.x) {
                val = val2;
                p = p2;
                arr = levelUpDisabledDetect;
            }
        }
        [arr removeObject:val];
        abilityCount++;
        if (abilityCount == 1) {
            ability1LevelUpAvailable = arr == levelUpDetect;
        } else if (abilityCount == 2) {
            ability2LevelUpAvailable = arr == levelUpDetect;
        } else if (abilityCount == 3) {
            ability3LevelUpAvailable = arr == levelUpDetect;
        } else if (abilityCount == 4) {
            ability4LevelUpAvailable = arr == levelUpDetect;
        }
    }
}



void AbilityManager::processPixelLevelUp(uint8_t *pixel, int x, int y) {
    //Detect top left bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, levelUpImageData, 10)) {
        Position p;p.x=x;p.y=y;
        //Add if not detected
        if (!containsPosition(levelUpDetect, p)) {
            [levelUpDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, levelUpDisabledImageData, 10)) {
        Position p;p.x=x;p.y=y;
        //Add if not detected
        if (!containsPosition(levelUpDisabledDetect, p)) {
            [levelUpDisabledDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
}

void AbilityManager::processPixelLevelUpCount(uint8_t *pixel, int x, int y) {
    //Detect top left bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, levelDotImageData, 30)) {
        levelUpCount++;
    }
}

void AbilityManager::detectLevelUpCount() {
    levelUpCount = 0;
    
    //Detect level up icon
    //160 pixels from bottom of screen to 100 pixels from bottom of screen
    //middle of screen -300 and +300
    int yStart = imageData.imageHeight - 52;
    int yEnd = imageData.imageHeight - 40;
    int xStart = imageData.imageWidth/2 - 170;
    int xEnd = imageData.imageWidth/2 + 16;
    
    //yStart = 0; xStart = 0; yEnd = imageData.imageHeight; xEnd = imageData.imageWidth;
    
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
        
        for (int x = xStart; x < xEnd; x++) {
            processPixelLevelUpCount(pixel, x, y);
            pixel += 4;
        }
    }
    
    //if (levelUpCount > 0) NSLog(@"Level up count: %d", levelUpCount);
}


void AbilityManager::detectAbilities() {
    [abilityEnabledDetect removeAllObjects];
    [abilityDisabledDetect removeAllObjects];
    
    //Detect level up icon
    //160 pixels from bottom of screen to 100 pixels from bottom of screen
    //middle of screen -300 and +300
    int yStart = imageData.imageHeight - 100;
    int yEnd = imageData.imageHeight;
    int xStart = imageData.imageWidth/2 - 300;
    int xEnd = imageData.imageWidth/2 + 300;
    
    //yStart = 0; xStart = 0; yEnd = imageData.imageHeight; xEnd = imageData.imageWidth;
    
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
        
        for (int x = xStart; x < xEnd; x++) {
            processPixelAbilities(pixel, x, y);
            pixel += 4;
        }
    }
    
    //if ([abilityEnabledDetect count] != 0) {
    //NSLog(@"%d and %d", [abilityEnabledDetect count], [abilityDisabledDetect count]);
    //}
    
    if ([abilityEnabledDetect count] == 0) {
        ability1Ready = false;
        ability2Ready = false;
        ability3Ready = false;
        ability4Ready = false;
    }
    
    int abilityCount = 0;
    while ([abilityEnabledDetect count] > 0 || [abilityDisabledDetect count] > 0) {
        Position p;
        NSMutableArray* arr;
        NSValue* val = NULL;
        //Array 1
        for (int i = 0; i < [abilityEnabledDetect count]; i++) {
            Position p2;
            NSValue* val2 = [abilityEnabledDetect objectAtIndex:i];
            [val2 getValue:&p2];
            if (val == NULL) {
                val = val2;
                p = p2;
                arr = abilityEnabledDetect;
            } else if (p2.x < p.x) {
                val = val2;
                p = p2;
                arr = abilityEnabledDetect;
            }
        }
        //Array 2
        for (int i = 0; i < [abilityDisabledDetect count]; i++) {
            Position p2;
            NSValue* val2 = [abilityDisabledDetect objectAtIndex:i];
            [val2 getValue:&p2];
            if (val == NULL) {
                val = val2;
                p = p2;
                arr = abilityDisabledDetect;
            } else if (p2.x < p.x) {
                val = val2;
                p = p2;
                arr = abilityDisabledDetect;
            }
        }
        [arr removeObject:val];
        abilityCount++;
        if (abilityCount == 1) {
            ability1Ready = arr == abilityEnabledDetect;
        } else if (abilityCount == 2) {
            ability2Ready = arr == abilityEnabledDetect;
        } else if (abilityCount == 3) {
            ability3Ready = arr == abilityEnabledDetect;
        } else if (abilityCount == 4) {
            ability4Ready = arr == abilityEnabledDetect;
        }
    }
}


void AbilityManager::processPixelAbilities(uint8_t *pixel, int x, int y) {
    //Detect top left bar
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, abilityEnabledImageData, 40)) {
        Position p;p.x=x;p.y=y;
        //Add if not detected
        if (!containsPosition(abilityEnabledDetect, p)) {
            [abilityEnabledDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
    if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, abilityDisabledImageData, 40)) {
        Position p;p.x=x;p.y=y;
        //Add if not detected
        if (!containsPosition(abilityDisabledDetect, p)) {
            [abilityDisabledDetect addObject:[NSValue valueWithBytes:&p objCType:@encode(Position)]];
        }
    }
}

void AbilityManager::detectSummonerSpells() {
    summonerSpell1Ready = false;
    summonerSpell2Ready = false;

    //First summoner spell is at half width + 32 to +68
    //full height - 80 to -40
    int yStart = imageData.imageHeight - 110;
    int yEnd = imageData.imageHeight - 40;
    int xStart = imageData.imageWidth/2 + 30;
    int xEnd = imageData.imageWidth/2 + 68;
    
    //yStart = 0; xStart = 0; yEnd = imageData.imageHeight; xEnd = imageData.imageWidth;
    
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
        
        for (int x = xStart; x < xEnd; x++) {
            if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, enabledSummonerSpellImageData, 60)) {
                summonerSpell1Ready = true;
            }
            pixel += 4;
        }
    }
    
    //Second summoner spells is at half width + 68 to +107
    //full height -80 to -40
     yStart = imageData.imageHeight - 110;
     yEnd = imageData.imageHeight - 40;
     xStart = imageData.imageWidth/2 + 68;
     xEnd = imageData.imageWidth/2 + 110;
    
    //yStart = 0; xStart = 0; yEnd = imageData.imageHeight; xEnd = imageData.imageWidth;
    
    for (int y = yStart; y < yEnd; y++) {
        uint8_t *pixel = imageData.imageData + (y * imageData.imageWidth + xStart)*4;
        
        for (int x = xStart; x < xEnd; x++) {
            if (detectImageAtPixel(pixel, x, y, imageData.imageWidth, imageData.imageHeight, enabledSummonerSpellImageData, 60)) {
                summonerSpell2Ready = true;
            }
            pixel += 4;
        }
    }
}

bool AbilityManager::containsPosition(NSMutableArray* array, Position p) {
    for (int i = 0; i < [array count]; i++) {
        Position p2;
        [[array objectAtIndex:i] getValue:&p2];
        if (p2.x == p.x && p2.y == p.y) {
            return true;
        }
    }
    return false;
}
