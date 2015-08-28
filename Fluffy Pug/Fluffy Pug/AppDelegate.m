//
//  AppDelegate.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    GlobalSelf = self;
    saveTestScreenshot = false;
    
    [_window orderFront: nil];
    [_window2 setLevel: NSNormalWindowLevel];
    [NSApp activateIgnoringOtherApps:YES];
    
    
    [[NSProcessInfo processInfo] disableAutomaticTermination:@"Good Reason"];
    
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)]) {
        self->_activity = [[NSProcessInfo processInfo] beginActivityWithOptions:0x00FFFFFF reason:@"receiving messages"];
    }
    
    // Insert code here to initialize your application
    //timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 //2000.0
    //                                         target:self
    //                                       selector:@selector(timerLogic)
    //                                       userInfo:nil
    //                                        repeats:YES];
    
    //[fpsTextField setFocusRingType:NSFocusRingTypeNone];
    
    leagueGameState = new LeagueGameState();
    testController = new TestController(processedImage, unprocessedImage, targetImage, foundImage, logText);
    leagueDetector = new LeagueDetector();
    autoQueueManager = new AutoQueueManager(leagueGameState);
    
    basicAI = new BasicAI(leagueGameState);
    
    [self updateLeagueWindowStatus];
    //lastTime = clock();
    
    streamQueue = dispatch_queue_create("herp.derp.mcgerp", NULL);
    
    CGDirectDisplayID display_id;
    display_id = CGMainDisplayID();
    
    CGDisplayModeRef mode = CGDisplayCopyDisplayMode(display_id);
    
    size_t pixelWidth = CGDisplayModeGetPixelWidth(mode);
    size_t pixelHeight = CGDisplayModeGetPixelHeight(mode);
    
    CGDisplayModeRelease(mode);
    
    //stream = CGDisplayStreamCreate(display_id, pixelWidth, pixelHeight, 'BGRA', NULL, handleStream);
    stream = CGDisplayStreamCreateWithDispatchQueue(display_id, pixelWidth, pixelHeight, 'BGRA',
                                                    (__bridge CFDictionaryRef)(@{(__bridge NSString *)kCGDisplayStreamQueueDepth : @8,  (__bridge NSString *)kCGDisplayStreamShowCursor: @NO})
                                                    , streamQueue, handleStream);
    
    lastTime = mach_absolute_time();
    CGDisplayStreamStart(stream);
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0/1000.0
                                             target:self
                                           selector:@selector(logic)
                                           userInfo:nil
                                            repeats:YES];
    
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
- (IBAction) testShopAvailable:(id)sender {
    testController->testShopAvailable();
}
- (IBAction) testShopOpen:(id)sender {
    testController->testShopOpen();
}
- (IBAction) testShopItems:(id)sender {
    testController->testShopItems();
}
- (IBAction) testInGameDetection:(id)sender {
    testController->testInGameDetection();
}
- (IBAction) testLevelUp:(id)sender {
    testController->testLevelUp();
}
- (IBAction) testAbilitiesActive:(id)sender {
    testController->testAbilitiesActive();
}
- (IBAction) testItemActives:(id)sender {
    testController->testItemActives();
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
- (IBAction) runAutoQueueButton:(id)sender {
    if ([GlobalSelf->autoQueueCheckbox state] == NSOnState) {
        autoQueueManager->reset(false);
        runAutoQueue = true;
    } else {
        runAutoQueue = false;
    }
}
- (void) updateLeagueWindowStatus {
    leagueDetector->detectLeagueWindow();
    if (leagueDetector->leaguePID != -1) {
        leagueGameState->leagueSize = CGRectMake(leagueDetector->xOrigin, leagueDetector->yOrigin, leagueDetector->width, leagueDetector->height);
        leagueGameState->leaguePID = leagueDetector->leaguePID;
        //NSLog(@"Width: %f, height: %f", [width floatValue], [height floatValue]);
        //NSLog(@"Found league instance: %@", info);
        [statusText setStringValue:[NSString stringWithFormat:@"Running on League Instance (%f, %f)", leagueGameState->leagueSize.size.width, leagueGameState->leagueSize.size.height]];
    } else {
        [statusText setStringValue:@"No League Instance Found"];
    }
}

uint64_t lastTime = 0;
int loops = 0;
int screenLoops = 0;
AppDelegate *GlobalSelf;

- (void) logic {
    GlobalSelf->leagueGameState->autoQueueActive = [GlobalSelf->autoQueueCheckbox state] == NSOnState;
    //Run auto queue logic and AI logic
    if ([GlobalSelf->aiActiveCheckbox state] == NSOnState && GlobalSelf->leagueGameState->leaguePID != -1) {
        basicAI->processAI();
    }
    if (runAutoQueue && leagueGameState->leaguePID == -1) {
        autoQueueManager->processLogic();
    }
    
    //Profile code
    if (getTimeInMilliseconds(mach_absolute_time() - lastTime) > 500)
    {
        int time = getTimeInMilliseconds(mach_absolute_time() - lastTime);
        [GlobalSelf->fpsText setStringValue:[NSString stringWithFormat:@"Elapsed Time: %f ms, %f fps", time * 1.0 / loops, (1000.0)/(time * 1.0 / loops)]];
        [GlobalSelf->screenAnalyzeText setStringValue:[NSString stringWithFormat:@"Elapsed Time: %f ms, %f fps", time * 1.0 / screenLoops, (1000.0)/(time * 1.0 / screenLoops)]];
        lastTime = mach_absolute_time();
        loops = 0;
        screenLoops = 0;
        [GlobalSelf updateLeagueWindowStatus];
        
        /**** I DONT BELIEVE THIS IS THREAD SAFE ***/
        //Display minions
        [GlobalSelf->allyMinionText setStringValue:[NSString stringWithFormat:@"%lu minions", (unsigned long)GlobalSelf->leagueGameState->allyMinionManager->minionBars.count]];
        
        //[GlobalSelf->enemyMinionText setStringValue:[NSString stringWithFormat:@"%lu minions", (unsigned long)GlobalSelf->leagueGameState->enemyMinionManager->minionBars.count]];
        
        //[GlobalSelf->enemyChampionText setStringValue:[NSString stringWithFormat:@"%lu champions", (unsigned long)GlobalSelf->leagueGameState->enemyChampionManager->championBars.count]];
        
        //[GlobalSelf->allyChampionText setStringValue:[NSString stringWithFormat:@"%lu champions", (unsigned long)GlobalSelf->leagueGameState->allyChampionManager->championBars.count]];
        
        //[GlobalSelf->selfChampionText setStringValue:[NSString stringWithFormat:@"%lu champions", (unsigned long)GlobalSelf->leagueGameState->selfChampionManager->championBars.count]];
    }
    else
    {
        loops++;
    }
}

void (^handleStream)(CGDisplayStreamFrameStatus, uint64_t, IOSurfaceRef, CGDisplayStreamUpdateRef) =  ^(CGDisplayStreamFrameStatus status,
                                                                                                        uint64_t displayTime,
                                                                                                        IOSurfaceRef frameSurface,
                                                                                                        CGDisplayStreamUpdateRef updateRef)
{
    if (status != kCGDisplayStreamFrameStatusFrameComplete) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        screenLoops++;
    });
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
    
    if (GlobalSelf->leagueGameState->leaguePID != -1) {
        GlobalSelf->leagueGameState->processDetection(imageData);
    }
    
    if (GlobalSelf->runAutoQueue && GlobalSelf->leagueGameState->leaguePID == -1) {
        const CGRect * rects;
        
        size_t num_rects;
        
        rects = CGDisplayStreamUpdateGetRects(updateRef, kCGDisplayStreamUpdateDirtyRects, &num_rects);
        bool fireLogic = GlobalSelf->autoQueueManager->processDetection(imageData, rects, num_rects);
        if (fireLogic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [GlobalSelf->timer fire];
            });
        }
    }
    
    
    
    
    
    
    
    if (getTimeInMilliseconds(mach_absolute_time() - GlobalSelf->lastSaveImage) >= 1000 && [GlobalSelf->recordScreenCheckbox state] == NSOnState) {
        GlobalSelf->lastSaveImage = clock();
        
        dispatch_group_t dispatchGroup = dispatch_group_create();
        dispatch_queue_t queue;
        
        NSImage* image = getImageFromBGRABuffer(basePtr, width, height);
        
        NSData *data = [image TIFFRepresentation];
        
        // Add a task to the group
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
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
