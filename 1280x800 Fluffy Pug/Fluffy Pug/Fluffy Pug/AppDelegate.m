//
//  AppDelegate.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

dispatch_source_t CreateDispatchTimer(uint64_t intervalNanoseconds,
                                      uint64_t leewayNanoseconds,
                                      dispatch_queue_t queue,
                                      dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), intervalNanoseconds, leewayNanoseconds);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    uiUpdateTime = mach_absolute_time();
    aiThread = dispatch_get_main_queue();
    //dispatch_queue_create("AI Thread", DISPATCH_QUEUE_CONCURRENT);
    detectionThread = dispatch_get_main_queue();
    //dispatch_queue_create("Detection Thread", DISPATCH_QUEUE_CONCURRENT);
    GlobalSelf = self;
    saveTestScreenshot = false;
    
    [_window orderFront: nil];
    [_window2 setLevel: NSNormalWindowLevel];
    [NSApp activateIgnoringOtherApps:YES];
    
    
    [[NSProcessInfo processInfo] disableAutomaticTermination:@"Good Reason"];
    
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)]) {
        self->_activity = [[NSProcessInfo processInfo] beginActivityWithOptions:0x00FFFFFF reason:@"receiving messages"];
    }
    
    leagueGameState = new LeagueGameState(aiThread, detectionThread);
    testController = new TestController(processedImage, unprocessedImage, targetImage, foundImage, logText);
    leagueDetector = new LeagueDetector();
    autoQueueManager = new AutoQueueManager(leagueGameState);
    
    basicAI = new BasicAI(leagueGameState);
    
    //[self updateLeagueWindowStatus];
    //lastTime = clock();
    
    CGDirectDisplayID display_id;
    display_id = CGMainDisplayID();
    
    CGDisplayModeRef mode = CGDisplayCopyDisplayMode(display_id);
    
    size_t pixelWidth = CGDisplayModeGetPixelWidth(mode);
    size_t pixelHeight = CGDisplayModeGetPixelHeight(mode);
    
    CGDisplayModeRelease(mode);
    
    //stream = CGDisplayStreamCreate(display_id, pixelWidth, pixelHeight, 'BGRA', NULL, handleStream);
    stream = CGDisplayStreamCreateWithDispatchQueue(display_id, pixelWidth, pixelHeight, 'BGRA',
                                                    (__bridge CFDictionaryRef)(@{(__bridge NSString *)kCGDisplayStreamQueueDepth : @1,  (__bridge NSString *)kCGDisplayStreamShowCursor: @NO})
                                                    , detectionThread, handleStream);
    
    lastTime = mach_absolute_time();
    CGDisplayStreamStart(stream);
    
    /*
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0/1000.0
                                             target:self
                                           selector:@selector(logic)
                                           userInfo:nil
                                            repeats:YES];
     */
    
    
    timer = CreateDispatchTimer(NSEC_PER_SEC/120, //30ull * NSEC_PER_SEC
                                0, //1ull * NSEC_PER_SEC
                                aiThread,
                                ^{ [self logic]; });
    
    //sleep(1);
    
    //CGDisplayStreamStop(stream);
    
    
    //printf("Done!\n");
    
    
    
    /*
    // Create a capture session
    mSession = [[AVCaptureSession alloc] init];
    
    // Set the session preset as you wish
    mSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    // If you're on a multi-display system and you want to capture a secondary display,
    // you can call CGGetActiveDisplayList() to get the list of all active displays.
    // For this example, we just specify the main display.
    // To capture both a main and secondary display at the same time, use two active
    // capture sessions, one for each display. On Mac OS X, AVCaptureMovieFileOutput
    // only supports writing to a single video track.
    CGDirectDisplayID displayId = kCGDirectMainDisplay;
    
    // Create a ScreenInput with the display and add it to the session
    input = [[AVCaptureScreenInput alloc] initWithDisplayID:displayId];
    input.minFrameDuration = CMTimeMake(1, 60);
    input.capturesCursor = false;
    
    //if (!input) {
    //    [mSession release];
    //    mSession = nil;
    //    return;
    //}
    if ([mSession canAddInput:input]) {
        [mSession addInput:input];
    } else {
        NSLog(@"Couldn't add screen capture input");
    }
    
    // **********************Add output here
    //dispatch_queue_t _videoDataOutputQueue;
    //_videoDataOutputQueue = dispatch_queue_create( "com.apple.sample.capturepipeline.video", DISPATCH_QUEUE_SERIAL );
    //dispatch_set_target_queue( _videoDataOutputQueue, dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0 ) );
    
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    videoOut.videoSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    
    dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_SERIAL);
    [videoOut setSampleBufferDelegate:self queue:queue];
    
    // RosyWriter records videos and we prefer not to have any dropped frames in the video recording.
    // By setting alwaysDiscardsLateVideoFrames to NO we ensure that minor fluctuations in system load or in our processing time for a given frame won't cause framedrops.
    // We do however need to ensure that on average we can process frames in realtime.
    // If we were doing preview only we would probably want to set alwaysDiscardsLateVideoFrames to YES.
    videoOut.alwaysDiscardsLateVideoFrames = YES;
    
    if ( [mSession canAddOutput:videoOut] ) {
        [mSession addOutput:videoOut];
    } else {NSLog(@"Couldn't add output video");}
    
    
    // Start running the session
    [mSession startRunning];
    
    chosenFPS = 60;
     */
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    CGDisplayStreamStop(stream);
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}
- (IBAction) openViewWindow:(id)sender {
    [_window2 orderFront: nil];
}
- (IBAction) getScreenshot:(id)sender {
    saveTestScreenshot = true;
}
- (IBAction) testPlayButton:(id)sender {
    testController->testPlayButton();
}
- (IBAction) testSelfDetection:(id)sender {
    testController->testSelfDetection();
}
- (IBAction) testEnemyChampDetection:(id)sender {
    testController->testEnemyChampionDetection();
}
- (IBAction) testAllyChampDetection:(id)sender {
    testController->testAllyChampionDetection();
}

- (IBAction) testEnemyMinionDetection:(id)sender {
    testController->testEnemyMinionDetection();
}

- (IBAction) testAllyMinionDetection:(id)sender {
    testController->testAllyMinionDetection();
}

- (IBAction) testEnemyTowerDetection:(id)sender {
    testController->testEnemyTowerDetection();
}

- (IBAction) testLevelUpDetection:(id)sender {
    testController->testLevelUpDetection();
}
- (IBAction) testLevelDotDetection:(id)sender {
    testController->testLevelDotDetection();
}
- (IBAction) testEnabledAbilityDetection:(id)sender {
    testController->testEnabledAbilityDetection();
}
- (IBAction) testEnabledSummonerSpellDetection:(id)sender {
    testController->testEnabledSummonerSpellDetection();
}
- (IBAction) testTrinketActiveDetection:(id)sender{
    testController->testTrinketActiveDetection();
}
- (IBAction) testItemActivesDetection:(id)sender{
    testController->testItemActiveDetection();
}
- (IBAction) testPotionActivesDetection:(id)sender{
    testController->testPotionActiveDetection();
}
- (IBAction) testUsedPotionDetection:(id)sender{
    testController->testUsedPotionActiveDetection();
}
- (IBAction) testShopAvailableDetection:(id)sender{
    testController->testShopAvailable();
}
- (IBAction) testShopTopLeftCornerDetection:(id)sender{
    testController->testShopTopLeftCorner();
}
- (IBAction) testShopBottomLeftCornerDetection:(id)sender{
    testController->testShopBottomLeftCorner();
}
- (IBAction) testShopBuyableItemsDetection:(id)sender{
    testController->testShopBuyableItems();
}
- (IBAction) testMapDetection:(id)sender {
    testController->testMapDetection();
}
- (IBAction) testMapShopDetection:(id)sender {
    testController->testMapShopDetection();
}
- (IBAction) testMapLocation:(id)sender {
    testController->testMapLocationDetection();
}

- (IBAction) runAutoQueueButton:(id)sender {
    if ([GlobalSelf->autoQueueCheckbox state] == NSOnState) {
        autoQueueManager->reset(false);
        runAutoQueue = true;
    } else {
        runAutoQueue = false;
    }
}
- (void) updateLeagueWindowStatus {
    @autoreleasepool {
        bool leagueExists = leagueDetector->leaguePID != -1;
    leagueDetector->detectLeagueWindow();
    if (leagueDetector->leaguePID != -1) {
        if (!leagueExists) {
            basicAI->resetAI();
        }
        leagueGameState->leagueSize = CGRectMake(leagueDetector->xOrigin, leagueDetector->yOrigin, leagueDetector->width, leagueDetector->height);
        leagueGameState->leaguePID = leagueDetector->leaguePID;
        //NSLog(@"Width: %f, height: %f", [width floatValue], [height floatValue]);
        //NSLog(@"Found league instance: %@", info);
        float width = leagueGameState->leagueSize.size.width;
        float height = leagueGameState->leagueSize.size.height;
        //dispatch_async(dispatch_get_main_queue(), ^{
            //@autoreleasepool {
            [statusText setStringValue:[NSString stringWithFormat:@"Running on League Instance (%f, %f)", width, height]];
            //}
        //});
    } else {
        leagueGameState->leaguePID = -1;
        //dispatch_async(dispatch_get_main_queue(), ^{
        //    @autoreleasepool {
        [statusText setStringValue:@"No League Instance Found"];
        //    }
        //     });
    }
    }
}

uint64_t lastTime = 0;
int loops = 0;
int screenLoops = 0;
AppDelegate *GlobalSelf;

- (void) logic {
    //@autoreleasepool {
    
    GlobalSelf->leagueGameState->autoQueueActive = [GlobalSelf->autoQueueCheckbox state] == NSOnState;
    //Run auto queue logic and AI logic
    if ([GlobalSelf->aiActiveCheckbox state] == NSOnState && GlobalSelf->leagueGameState->leaguePID != -1) {
        basicAI->processAI();
    }
    if (runAutoQueue) { // && leagueGameState->leaguePID == -1
        autoQueueManager->processLogic();
    }
    
    //Profile code
    if (getTimeInMilliseconds(mach_absolute_time() - lastTime) >= 500)
    {
        int time = getTimeInMilliseconds(mach_absolute_time() - lastTime);
        int l = loops;
        int sl = screenLoops;
        //dispatch_async(dispatch_get_main_queue(), ^{
        //    @autoreleasepool {
            [GlobalSelf->fpsText setStringValue:[NSString stringWithFormat:@"Elapsed Time: %f ms, %f fps", time * 1.0 / l, (1000.0)/(time * 1.0 / l)]];
            [GlobalSelf->screenAnalyzeText setStringValue:[NSString stringWithFormat:@"Elapsed Time: %f ms, %f fps", time * 1.0 / sl, (1000.0)/(time * 1.0 / sl)]];
        
        //
        
        //    }
        //});
        lastTime = mach_absolute_time();
        loops = 0;
        screenLoops = 0;
        [GlobalSelf updateLeagueWindowStatus];
        
        
        //Set the auto queue status
        NSString* text = @"";
        text = [NSString stringWithFormat:@"%@\nAuto Queue Status: ", text];
        text = [NSString stringWithFormat:@"%@\nTaking Break: %@", text, autoQueueManager->busyTakingBreak?@"True":@"False"];
        text = [NSString stringWithFormat:@"%@\nSleeping: %@", text, autoQueueManager->busySleeping?@"True":@"False"];
        text = [NSString stringWithFormat:@"%@\nSet Sleep Time: %d minutes", text, autoQueueManager->sleepTime / 1000 / 60];
        text = [NSString stringWithFormat:@"%@\nSet Awake Time: %d minutes", text, autoQueueManager->awakeTime / 1000 / 60];
        text = [NSString stringWithFormat:@"%@\nSet Break Time: %d minutes", text, autoQueueManager->breakTime / 1000 / 60];
        text = [NSString stringWithFormat:@"%@\nSet Play Time: %d minutes", text, autoQueueManager->playTime / 1000 / 60];
        if (autoQueueManager->busySleeping) {
            text = [NSString stringWithFormat:@"%@\nSleep time left: %d minutes", text, (getTimeInMilliseconds(mach_absolute_time()-autoQueueManager->currentSleepTime)-autoQueueManager->sleepTime) / 1000 / 60];
        } else if (autoQueueManager->busyTakingBreak) {
            text = [NSString stringWithFormat:@"%@\nBreak time left: %d minutes", text, (getTimeInMilliseconds(mach_absolute_time()-autoQueueManager->currentBreakTime)-autoQueueManager->breakTime) / 1000 / 60];
            text = [NSString stringWithFormat:@"%@\nAwake time left: %d minutes", text, (getTimeInMilliseconds(mach_absolute_time()-autoQueueManager->currentAwakeTime)-autoQueueManager->awakeTime) / 1000 / 60];
        } else {
            text = [NSString stringWithFormat:@"%@\nPlay time left: %d minutes", text, (getTimeInMilliseconds(mach_absolute_time()-autoQueueManager->currentPlayTime)-autoQueueManager->playTime) / 1000 / 60];
            text = [NSString stringWithFormat:@"%@\nAwake time left: %d minutes", text, (getTimeInMilliseconds(mach_absolute_time()-autoQueueManager->currentAwakeTime)-autoQueueManager->awakeTime) / 1000 / 60];
        }
        [autoQueueStatus setString:text];
    }
    else
    {
        loops++;
    }
    
    //Fire logic after detection is finished for higher response times
    if (getTimeInMilliseconds(mach_absolute_time() - GlobalSelf->uiUpdateTime) >= 500) {
        GlobalSelf->uiUpdateTime = mach_absolute_time();
        int allyMinionCount = (int)GlobalSelf->leagueGameState->detectionManager->getAllyMinions().count;
        int enemyMinionCount = (int)GlobalSelf->leagueGameState->detectionManager->getEnemyMinions().count;
        int enemyChampCount = (int)GlobalSelf->leagueGameState->detectionManager->getEnemyChampions().count;
        int allyChampCount = (int)GlobalSelf->leagueGameState->detectionManager->getAllyChampions().count;
        int selfChampCount = (int)GlobalSelf->leagueGameState->detectionManager->getSelfChampions().count;
        int currentLevel = GlobalSelf->leagueGameState->detectionManager->getCurrentLevel();
        int enemyTowerCount = (int)GlobalSelf->leagueGameState->detectionManager->getEnemyTowers().count;
        bool selfHealth = GlobalSelf->leagueGameState->detectionManager->getSelfHealthBarVisible();
        bool mapShown = GlobalSelf->leagueGameState->detectionManager->getMapVisible();
        bool mapLocationShown = GlobalSelf->leagueGameState->detectionManager->getMapLocationVisible();
        bool mapShopShown = GlobalSelf->leagueGameState->detectionManager->getMapShopVisible();
        bool item1Shown = GlobalSelf->leagueGameState->detectionManager->getItem1ActiveAvailable();
        bool item2Shown = GlobalSelf->leagueGameState->detectionManager->getItem2ActiveAvailable();
        bool item3Shown = GlobalSelf->leagueGameState->detectionManager->getItem3ActiveAvailable();
        bool item4Shown = GlobalSelf->leagueGameState->detectionManager->getItem4ActiveAvailable();
        bool item5Shown = GlobalSelf->leagueGameState->detectionManager->getItem5ActiveAvailable();
        bool item6Shown = GlobalSelf->leagueGameState->detectionManager->getItem6ActiveAvailable();
        bool summoner1Shown = GlobalSelf->leagueGameState->detectionManager->getSummonerSpell1Available();
        bool summoner2Shown = GlobalSelf->leagueGameState->detectionManager->getSummonerSpell2Available();
        bool trinketShown = GlobalSelf->leagueGameState->detectionManager->getTrinketActiveAvailable();
        bool potionUsed = GlobalSelf->leagueGameState->detectionManager->getPotionBeingUsedVisible();
        bool potionShown = GlobalSelf->leagueGameState->detectionManager->getPotionActiveAvailable();
        bool spell1Shown = GlobalSelf->leagueGameState->detectionManager->getSpell1Available();
        bool spell2Shown = GlobalSelf->leagueGameState->detectionManager->getSpell2Available();
        bool spell3Shown = GlobalSelf->leagueGameState->detectionManager->getSpell3Available();
        bool spell4Shown = GlobalSelf->leagueGameState->detectionManager->getSpell4Available();
        bool spell1LvlUp = GlobalSelf->leagueGameState->detectionManager->getSpell1LevelUpVisible();
        bool spell2LvlUp = GlobalSelf->leagueGameState->detectionManager->getSpell2LevelUpVisible();
        bool spell3LvlUp = GlobalSelf->leagueGameState->detectionManager->getSpell3LevelUpVisible();
        bool spell4LvlUp = GlobalSelf->leagueGameState->detectionManager->getSpell4LevelUpVisible();
        int spell1Lvl = (int)GlobalSelf->leagueGameState->detectionManager->getSpell1LevelDots().count;
        int spell2Lvl = (int)GlobalSelf->leagueGameState->detectionManager->getSpell2LevelDots().count;
        int spell3Lvl = (int)GlobalSelf->leagueGameState->detectionManager->getSpell3LevelDots().count;
        int spell4Lvl = (int)GlobalSelf->leagueGameState->detectionManager->getSpell4LevelDots().count;
        bool shopAvailable = GlobalSelf->leagueGameState->detectionManager->getShopAvailable();
        bool shopWindowOpen = (GlobalSelf->leagueGameState->detectionManager->getShopTopLeftCornerVisible() && GlobalSelf->leagueGameState->detectionManager->getShopBottomLeftCornerVisible());
        int buyableItems = (int)GlobalSelf->leagueGameState->detectionManager->getBuyableItems().count;
        
        //dispatch_async(dispatch_get_main_queue(), ^{
        //    @autoreleasepool {
            [GlobalSelf->allyMinionsTxt setStringValue:[NSString stringWithFormat:@"%lu minions", (unsigned long)allyMinionCount]];
            [GlobalSelf->enemyMinionsTxt setStringValue:[NSString stringWithFormat:@"%lu minions", (unsigned long)enemyMinionCount]];
            [GlobalSelf->enemyChampsTxt setStringValue:[NSString stringWithFormat:@"%lu champs", (unsigned long)enemyChampCount]];
            [GlobalSelf->allyChampsTxt setStringValue:[NSString stringWithFormat:@"%lu champs", (unsigned long)allyChampCount]];
            [GlobalSelf->selfChampsTxt setStringValue:[NSString stringWithFormat:@"%lu champs", (unsigned long)selfChampCount]];
            [GlobalSelf->selfCurrentLvlTxt setStringValue:[NSString stringWithFormat:@"%lu", (unsigned long)currentLevel]];
            [GlobalSelf->enemyTowersTxt setStringValue:[NSString stringWithFormat:@"%lu towers", (unsigned long)enemyTowerCount]];
            [GlobalSelf->selfHealthTxt setStringValue:[NSString stringWithFormat:@"%@", selfHealth?@"true":@"false"]];
            [GlobalSelf->mapTxt setStringValue:[NSString stringWithFormat:@"%@", mapShown?@"true":@"false"]];
            [GlobalSelf->mapLocTxt setStringValue:[NSString stringWithFormat:@"%@", mapLocationShown?@"true":@"false"]];
            [GlobalSelf->mapShopTxt setStringValue:[NSString stringWithFormat:@"%@", mapShopShown?@"true":@"false"]];
            [GlobalSelf->item1Txt setStringValue:[NSString stringWithFormat:@"%@", item1Shown?@"true":@"false"]];
            [GlobalSelf->item2Txt setStringValue:[NSString stringWithFormat:@"%@", item2Shown?@"true":@"false"]];
            [GlobalSelf->item3Txt setStringValue:[NSString stringWithFormat:@"%@", item3Shown?@"true":@"false"]];
            [GlobalSelf->item4Txt setStringValue:[NSString stringWithFormat:@"%@", item4Shown?@"true":@"false"]];
            [GlobalSelf->item5Txt setStringValue:[NSString stringWithFormat:@"%@", item5Shown?@"true":@"false"]];
            [GlobalSelf->item6Txt setStringValue:[NSString stringWithFormat:@"%@", item6Shown?@"true":@"false"]];
            [GlobalSelf->summonerSpell1Txt setStringValue:[NSString stringWithFormat:@"%@", summoner1Shown?@"true":@"false"]];
            [GlobalSelf->summonerSpell2Txt setStringValue:[NSString stringWithFormat:@"%@", summoner2Shown?@"true":@"false"]];
            [GlobalSelf->trinketTxt setStringValue:[NSString stringWithFormat:@"%@", trinketShown?@"true":@"false"]];
            [GlobalSelf->usedPotionTxt setStringValue:[NSString stringWithFormat:@"%@", potionUsed?@"true":@"false"]];
            [GlobalSelf->potionActiveTxt setStringValue:[NSString stringWithFormat:@"%@", potionShown?@"true":@"false"]];
            [GlobalSelf->spell1Txt setStringValue:[NSString stringWithFormat:@"%@", spell1Shown?@"true":@"false"]];
            [GlobalSelf->spell2Txt setStringValue:[NSString stringWithFormat:@"%@", spell2Shown?@"true":@"false"]];
            [GlobalSelf->spell3Txt setStringValue:[NSString stringWithFormat:@"%@", spell3Shown?@"true":@"false"]];
            [GlobalSelf->spell4Txt setStringValue:[NSString stringWithFormat:@"%@", spell4Shown?@"true":@"false"]];
            [GlobalSelf->spell1LvlUpTxt setStringValue:[NSString stringWithFormat:@"%@", spell1LvlUp?@"true":@"false"]];
            [GlobalSelf->spell2LvlUpTxt setStringValue:[NSString stringWithFormat:@"%@", spell2LvlUp?@"true":@"false"]];
            [GlobalSelf->spell3LvlUpTxt setStringValue:[NSString stringWithFormat:@"%@", spell3LvlUp?@"true":@"false"]];
            [GlobalSelf->spell4LvlUpTxt setStringValue:[NSString stringWithFormat:@"%@", spell4LvlUp?@"true":@"false"]];
            [GlobalSelf->spell1LvlTxt setStringValue:[NSString stringWithFormat:@"%lu", (unsigned long)spell1Lvl]];
            [GlobalSelf->spell2LvlTxt setStringValue:[NSString stringWithFormat:@"%lu", (unsigned long)spell2Lvl]];
            [GlobalSelf->spell3LvlTxt setStringValue:[NSString stringWithFormat:@"%lu", (unsigned long)spell3Lvl]];
            [GlobalSelf->spell4LvlTxt setStringValue:[NSString stringWithFormat:@"%lu", (unsigned long)spell4Lvl]];
            [GlobalSelf->shopAvailableTxt setStringValue:[NSString stringWithFormat:@"%@", shopAvailable?@"true":@"false"]];
            [GlobalSelf->shopWindowOpenTxt setStringValue:[NSString stringWithFormat:@"%@", shopWindowOpen?@"true":@"false"]];
            [GlobalSelf->buyableItemsTxt setStringValue:[NSString stringWithFormat:@"%lu", (unsigned long)buyableItems]];
            }
            //[[GlobalSelf.window contentView] setNeedsDisplay:true];
        //});
    //}
        
    //}
}

void (^handleStream)(CGDisplayStreamFrameStatus, uint64_t, IOSurfaceRef, CGDisplayStreamUpdateRef) =  ^(CGDisplayStreamFrameStatus status,
                                                                                                        uint64_t displayTime,
                                                                                                        IOSurfaceRef frameSurface,
                                                                                                        CGDisplayStreamUpdateRef updateRef)
{
    @autoreleasepool {
    if (status != kCGDisplayStreamFrameStatusFrameComplete) return;
    
    //dispatch_async(GlobalSelf->aiThread, ^{
        screenLoops++;
    //});
    uint32_t aseed;
    IOSurfaceLock(frameSurface, kIOSurfaceLockReadOnly, &aseed);
    uint32_t width = (uint32_t)IOSurfaceGetWidth(frameSurface);
    uint32_t height = (uint32_t)IOSurfaceGetHeight(frameSurface);
    uint8_t * basePtr = (uint8_t*)IOSurfaceGetBaseAddress(frameSurface);
    
    //NSLog(@"Width: %d, Height: %d, bytesPerRow: %d, Plane Count: %zu", width, height, bytesPerRow, planeCount);
    
    //uint8_t * newPtr = copyImageBufferFromBGRAtoRGBA(basePtr, width, height);
    
    //NSImage* image = getImageFromBGRABuffer(basePtr, width, height);
    
    /*
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, basePtr, (width * height * 4), NULL);
    CGImageRef cgImage=CGImageCreate(width, height, 8,
                                     8*4, bytesPerRow,
                                     CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst |kCGBitmapByteOrder32Little,
                                     provider, NULL,
                                     YES, kCGRenderingIntentDefault);
    
    NSImage* image = [[NSImage alloc] initWithCGImage:cgImage size:NSMakeSize(width, height)];
     */
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    [GlobalSelf.unprocessedImage setImage: image];
        //free(newPtr);
    //});
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    GlobalSelf->leagueGameState->leagueSize.size.width = width;
    GlobalSelf->leagueGameState->leagueSize.size.height = height;
    
    
    if (GlobalSelf->saveTestScreenshot) {
        GlobalSelf->saveTestScreenshot = false;
       GlobalSelf-> testController->copyScreenShot(basePtr, width, height);
    }
    
    struct ImageData imageData = makeImageData(basePtr, width, height);
    
    
    //GlobalSelf->leagueGameState->processImage(imageData);
    
    //if (GlobalSelf->leagueGameState->leaguePID != -1) {
        GlobalSelf->leagueGameState->processDetection(imageData);
    //}
    
    if (GlobalSelf->runAutoQueue && GlobalSelf->leagueGameState->leaguePID == -1) {
        const CGRect * rects;
        
        size_t num_rects;
        
        rects = CGDisplayStreamUpdateGetRects(updateRef, kCGDisplayStreamUpdateDirtyRects, &num_rects);
        GlobalSelf->autoQueueManager->processDetection(imageData, rects, num_rects);
        //if (fireLogic) {
        //    dispatch_async(dispatch_get_main_queue(), ^{
        //        [GlobalSelf logic];
                //[GlobalSelf->timer fire];
        //    });
        //}
    } else if (GlobalSelf->runAutoQueue && GlobalSelf->leagueGameState->leaguePID != -1) {
        GlobalSelf->autoQueueManager->processEndGameDetection(imageData);
    }
    
    //dispatch_async(GlobalSelf->aiThread, ^{
    //    @autoreleasepool {
            [GlobalSelf logic];
    //    }
    //});
    
    
    
    if (getTimeInMilliseconds(mach_absolute_time() - GlobalSelf->lastSaveImage) >= 1000 && [GlobalSelf->recordScreenCheckbox state] == NSOnState) {
        GlobalSelf->lastSaveImage = clock();
        
        dispatch_group_t dispatchGroup = dispatch_group_create();
        dispatch_queue_t queue;
        
        NSImage* image = getImageFromBGRABuffer(basePtr, width, height);
        
        NSData *data = [image TIFFRepresentation];
        
        // Add a task to the group
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_group_async(dispatchGroup, queue, ^{
            @autoreleasepool {
            NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
            [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            
            NSString* path = [NSString stringWithFormat:@"%@/AI Record",NSHomeDirectory()];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            
            
            bool wrote = [data writeToFile: [NSString stringWithFormat:@"%@/%@.png",path,[DateFormatter stringFromDate:[NSDate date]]] atomically: NO];
            if (!wrote) {
                NSLog(@"Couldn't save image");
            }
            }
        });
    }

    
    
    
    
    
    
    
    
    
    
    
    
    IOSurfaceUnlock(frameSurface, kIOSurfaceLockReadOnly, &aseed);
    
    
    //printf("handleStream called!\n");
    /*
    if(displayTime - last_time < 500000000)
        return;
    
    last_time = displayTime;
     */
    /*
     kCGDisplayStreamFrameStatusFrameComplete,
     kCGDisplayStreamFrameStatusFrameIdle,
     kCGDisplayStreamFrameStatusFrameBlank,
     kCGDisplayStreamFrameStatusStopped,
     */
    
    //printf("\tstatus: ");
    /*
    switch(status)
    {
        case kCGDisplayStreamFrameStatusFrameComplete:
            //printf("Complete\n");
            break;
            
        case kCGDisplayStreamFrameStatusFrameIdle:
            printf("Idle\n");
            break;
            
        case kCGDisplayStreamFrameStatusFrameBlank:
            printf("Blank\n");
            break;
            
        case kCGDisplayStreamFrameStatusStopped:
            printf("Stopped\n");
            break;
    }
    */
    /*
    printf("\ttime: %lld\n", displayTime);
    
    const CGRect * rects;
    
    size_t num_rects;
    
    rects = CGDisplayStreamUpdateGetRects(updateRef, kCGDisplayStreamUpdateDirtyRects, &num_rects);
    
    printf("\trectangles: %zd\n", num_rects);
    
    CGRect uRect;
    
    uRect = *rects;
    for (size_t i = 0; i < num_rects; i++)
    {
        printf("\t\t(%f,%f),(%f,%f)\n\n",
               (rects+i)->origin.x,
               (rects+i)->origin.y,
               (rects+i)->origin.x + (rects+i)->size.width,
               (rects+i)->origin.y + (rects+i)->size.height);
        
        uRect = CGRectUnion(uRect, *(rects+i));
    }
    
    printf("\t\tUnion: (%f,%f),(%f,%f)\n\n",
           uRect.origin.x,
           uRect.origin.y,
           uRect.origin.x + uRect.size.width,
           uRect.origin.y + uRect.size.height);
    */
    }
};


/*
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    //NSLog(@"Captures output from sample buffer");
    //CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription( sampleBuffer );

    [self renderVideoSampleBuffer:sampleBuffer];
    //}
}*/
/*
- (void)renderVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    leagueGameState->autoQueueActive = [autoQueueCheckbox state] == NSOnState;
    
    CVPixelBufferRef sourcePixelBuffer = CMSampleBufferGetImageBuffer( sampleBuffer );
    
    //const int kBytesPerPixel = 4;
    
    CVPixelBufferLockBaseAddress( sourcePixelBuffer, 0 );
    
    int bufferWidth = (int)CVPixelBufferGetWidth( sourcePixelBuffer );
    int bufferHeight = (int)CVPixelBufferGetHeight( sourcePixelBuffer );
    
    leagueGameState->leagueSize.size.width = bufferWidth;
    leagueGameState->leagueSize.size.height = bufferHeight;
    
    //size_t bytesPerRow = CVPixelBufferGetBytesPerRow( sourcePixelBuffer );
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress( sourcePixelBuffer );
    
    
    if (saveTestScreenshot) {
        saveTestScreenshot = false;
        testController->copyScreenShot(baseAddress, bufferWidth, bufferHeight);
    }
    
    struct ImageData imageData = makeImageData(baseAddress, bufferWidth, bufferHeight);
    
    
    leagueGameState->processImage(imageData);
    
    if ([aiActiveCheckbox state] == NSOnState && leagueGameState->leaguePID != -1) {
        leagueGameState->processAI();
    }
    
    
    if ((clock() - lastSaveImage)/CLOCKS_PER_SEC >= 1.0 && [recordScreenCheckbox state] == NSOnState) {
        lastSaveImage = clock();
        
        dispatch_group_t dispatchGroup = dispatch_group_create();
        dispatch_queue_t queue;
        
        
        CIImage *ciImage = [CIImage imageWithCVImageBuffer:sourcePixelBuffer];
        
        // Create a bitmap rep from the image...
        NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCIImage:ciImage];
        
        NSData *data = [bitmapRep representationUsingType: NSPNGFileType properties: nil];
        
        // Add a task to the group
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_group_async(dispatchGroup, queue, ^{
            NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
            [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            
            NSString* path = [NSString stringWithFormat:@"%@/AI Record",NSHomeDirectory()];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            
            
            bool wrote = [data writeToFile: [NSString stringWithFormat:@"%@/%@.png",path,[DateFormatter stringFromDate:[NSDate date]]] atomically: NO];
            if (!wrote) {
                NSLog(@"Couldn't save image");
            }
            
        });
    }
    
    if ([debugCheckbox state] == NSOnState) {
        //White it out
        for (int i = 0; i < bufferWidth*bufferHeight*4; i+=4) {
            baseAddress[i] = 0;
            baseAddress[i+1] = 0;
            baseAddress[i+2] = 0;
        }
        leagueGameState->debugDraw();
        
        CVPixelBufferUnlockBaseAddress( sourcePixelBuffer, 0 );
        CIImage *ciImage = [CIImage imageWithCVImageBuffer:sourcePixelBuffer];
        // Create a bitmap rep from the image...
        NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCIImage:ciImage];
        // Create an NSImage and add the bitmap rep to it...
        NSImage *image = [[NSImage alloc] init];
        [image addRepresentation:bitmapRep];
        // Set the output view to the new NSImage.
        [imageView setImage:image];
    } else {
        CVPixelBufferUnlockBaseAddress( sourcePixelBuffer, 0 );
    }
    
    //CVPixelBufferUnlockBaseAddress( sourcePixelBuffer, 0 );
    dispatch_async(dispatch_get_main_queue(), ^{
        //Display minions
        [allyMinionText setStringValue:[NSString stringWithFormat:@"%lu minions", (unsigned long)leagueGameState->allyMinionManager->minionBars.count]];
        
        [enemyMinionText setStringValue:[NSString stringWithFormat:@"%lu minions", (unsigned long)leagueGameState->enemyMinionManager->minionBars.count]];
        
        [enemyChampionText setStringValue:[NSString stringWithFormat:@"%lu champions", (unsigned long)leagueGameState->enemyChampionManager->championBars.count]];
        
        [allyChampionText setStringValue:[NSString stringWithFormat:@"%lu champions", (unsigned long)leagueGameState->allyChampionManager->championBars.count]];
        
        [selfChampionText setStringValue:[NSString stringWithFormat:@"%lu champions", (unsigned long)leagueGameState->selfChampionManager->championBars.count]];
        
        //Read FPS
        NSString* fps = [fpsTextField stringValue];
        int newFps = [fps intValue];
        if (newFps == 0) {
            [fpsTextField setStringValue:[NSString stringWithFormat:@"%d",chosenFPS]];
            newFps = chosenFPS;
        }
        if (chosenFPS != newFps) {
            chosenFPS = newFps;
            input.minFrameDuration = CMTimeMake(1, chosenFPS);
        }
        
        //Profile code? See how fast it's running?
        if ((clock() - lastTime)/CLOCKS_PER_SEC > 0.5)
        {
            float time = (clock() - lastTime)/CLOCKS_PER_SEC;
            [fpsText setStringValue:[NSString stringWithFormat:@"Elapsed Time: %f ms, %f fps", time * 1000 / loopsTaken, (1000.0)/(time * 1000.0 / loopsTaken)]];
            lastTime = clock();
            loopsTaken = 0;
            [self updateLeagueWindowStatus];
            
            [_window update];
            [_window setViewsNeedDisplay:TRUE];
            
        }
        else
        {
            loopsTaken++;
        }
    });
}

*/
















/*
CFTimeInterval lastTime;
int loopsTaken = 0;
*/

/*
 -(void)setOutputImage:(CGImageRef)cgImage
 {
 if(cgImage != NULL)
 {
 // Create a bitmap rep from the image...
 NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
 // Create an NSImage and add the bitmap rep to it...
 NSImage *image = [[NSImage alloc] init];
 [image addRepresentation:bitmapRep];
 // Set the output view to the new NSImage.
 [outputView setImage:image];
 }
 }*/
/*
 -(void)createScreenShot
 {
 CGImageRef screenShot = CGWindowListCreateImage(CGRectInfinite, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
 //[self setOutputImage:screenShot];
 CGImageRelease(screenShot);
 }
 
 -(CGImageRef)createSingleWindowShot:(CGWindowID)windowID andBounds:(CGRect)imageBounds
 {
 //CGRect imageBounds = CGRectInfinite;
 CGWindowListOption singleWindowListOptions = kCGWindowListOptionAll;
 CGWindowImageOption imageOptions = kCGWindowImageDefault;
 
 CGImageRef windowImage = CGWindowListCreateImage(imageBounds, singleWindowListOptions, windowID, imageOptions);
 return windowImage;
 }*/




@end
