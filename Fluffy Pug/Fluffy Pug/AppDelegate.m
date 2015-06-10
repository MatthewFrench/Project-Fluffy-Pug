//
//  AppDelegate.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "AppDelegate.h"

@interface WindowListApplierData : NSObject
{
}

@property (strong, nonatomic) NSMutableArray * outputArray;
@property int order;

@end

@implementation WindowListApplierData

-(instancetype)initWindowListData:(NSMutableArray *)array
{
    self = [super init];
    
    self.outputArray = array;
    self.order = 0;
    
    return self;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [_window2 orderFront: nil];
    [_window orderFront: nil];
    [NSApp activateIgnoringOtherApps:YES];
    
    // Insert code here to initialize your application
    //timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 //2000.0
    //                                         target:self
    //                                       selector:@selector(timerLogic)
    //                                       userInfo:nil
    //                                        repeats:YES];
    
    [fpsTextField setFocusRingType:NSFocusRingTypeNone];
    
    leagueGameState = new LeagueGameState();
    
    [self updateWindowList];
    lastTime = CACurrentMediaTime();
    
    
    
    
    
    
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
    
    //**********************Add output here
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
}




- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    //NSLog(@"Captures output from sample buffer");
    //CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription( sampleBuffer );
    /*
     if ( self.outputVideoFormatDescription == nil ) {
     // Don't render the first sample buffer.
     // This gives us one frame interval (33ms at 30fps) for setupVideoPipelineWithInputFormatDescription: to complete.
     // Ideally this would be done asynchronously to ensure frames don't back up on slower devices.
     [self setupVideoPipelineWithInputFormatDescription:formatDescription];
     }
     else {*/
    [self renderVideoSampleBuffer:sampleBuffer];
    //}
}

- (void)renderVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef sourcePixelBuffer = CMSampleBufferGetImageBuffer( sampleBuffer );
    
    //const int kBytesPerPixel = 4;
    
    CVPixelBufferLockBaseAddress( sourcePixelBuffer, 0 );
    
    int bufferWidth = (int)CVPixelBufferGetWidth( sourcePixelBuffer );
    int bufferHeight = (int)CVPixelBufferGetHeight( sourcePixelBuffer );
    //size_t bytesPerRow = CVPixelBufferGetBytesPerRow( sourcePixelBuffer );
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress( sourcePixelBuffer );
    
    
    
    
    struct ImageData imageData = makeImageData(baseAddress, bufferWidth, bufferHeight);
    
    
    leagueGameState->processImage(imageData);
    
    //Display minions
    [allyMinionText setStringValue:[NSString stringWithFormat:@"%lu minions", (unsigned long)leagueGameState->allyMinionManager->minionBars.count]];
    
    [enemyMinionText setStringValue:[NSString stringWithFormat:@"%lu minions", (unsigned long)leagueGameState->enemyMinionManager->minionBars.count]];
    
    [enemyChampionText setStringValue:[NSString stringWithFormat:@"%lu champions", (unsigned long)leagueGameState->enemyChampionManager->championBars.count]];
    
    [allyChampionText setStringValue:[NSString stringWithFormat:@"%lu champions", (unsigned long)leagueGameState->allyChampionManager->championBars.count]];
    
    [selfChampionText setStringValue:[NSString stringWithFormat:@"%lu champions", (unsigned long)leagueGameState->selfChampionManager->championBars.count]];
    
    
    if ([debugCheckbox state] == NSOnState) {
        //White it out
        for (int i = 0; i < bufferWidth*bufferHeight*4; i+=4) {
            baseAddress[i] = 0;
            baseAddress[i+1] = 0;
            baseAddress[i+2] = 0;
        }
        leagueGameState->debugDraw();
        CIImage *ciImage = [CIImage imageWithCVImageBuffer:sourcePixelBuffer];
        // Create a bitmap rep from the image...
        NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCIImage:ciImage];
        // Create an NSImage and add the bitmap rep to it...
        NSImage *image = [[NSImage alloc] init];
        [image addRepresentation:bitmapRep];
        // Set the output view to the new NSImage.
        [imageView setImage:image];
    }
    
    CVPixelBufferUnlockBaseAddress( sourcePixelBuffer, 0 );
    
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
    if (CACurrentMediaTime() - lastTime > 3) //10 seconds
    {
        float time = CACurrentMediaTime() - lastTime;
        [fpsText setStringValue:[NSString stringWithFormat:@"Elapsed Time: %f ms, %f fps", time * 1000 / loopsTaken, (1000.0)/(time * 1000.0 / loopsTaken)]];
        lastTime = CACurrentMediaTime();
        loopsTaken = 0;
        [self updateWindowList];
        if (leagueGameState->leaguePID == -1) {
            [statusText setStringValue:@"No League Instance Found"];
        }
    }
    else
    {
        loopsTaken++;
    }
    
}


















- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

CFTimeInterval lastTime;
int loopsTaken = 0;

- (void)timerLogic {
    //Profile code? See how fast it's running?
    if (CACurrentMediaTime() - lastTime > 3) //10 seconds
    {
        float time = CACurrentMediaTime() - lastTime;
        [fpsText setStringValue:[NSString stringWithFormat:@"Elapsed Time: %f ms, %f fps", time * 1000 / loopsTaken, (1000.0)/(time * 1000.0 / loopsTaken)]];
        lastTime = CACurrentMediaTime();
        loopsTaken = 0;
        [self updateWindowList];
        if (leagueGameState->leaguePID == -1) {
            [statusText setStringValue:@"No League Instance Found"];
        }
    }
    else
    {
        loopsTaken++;
    }
    if (leagueGameState->leaguePID != -1) {
        CGImageRef image = [self createSingleWindowShot:leagueGameState->leaguePID andBounds:leagueGameState->leagueSize];
        if (image == NULL) {
            leagueGameState->leaguePID = -1;
            return;
        }
        //[self setOutputImage:image];
        //[leagueGameState processImage:image];
        CGImageRelease(image);
        
        //Display minions
        [allyMinionText setStringValue:[NSString stringWithFormat:@"%lu minions", (unsigned long)leagueGameState->allyMinionManager->minionBars.count]];
        
    }
}

-(void)updateWindowList
{
    // Ask the window server for the list of windows.
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
    
    // Copy the returned list, further pruned, to another list. This also adds some bookkeeping
    // information to the list as well as
    NSMutableArray * prunedWindowList = [NSMutableArray array];
    WindowListApplierData *windowListData = [[WindowListApplierData alloc] initWindowListData:prunedWindowList];
    
    CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &WindowListApplierFunction, (__bridge void *)(windowListData));
    CFRelease(windowList);
    
    //for (int i = 0; i < [prunedWindowList count]; i++) {
    //    NSLog(@"Data at %d is %@", i, [prunedWindowList objectAtIndex:i]);
    //}
    leagueGameState->leaguePID = -1;
    if ([prunedWindowList count] > 0) {
        NSDictionary* info = [prunedWindowList firstObject];
        NSNumber *pid = info[kAppPIDKey];
        leagueGameState->leaguePID = [pid intValue];
        NSNumber* xOrigin = info[kWindowOriginXKey];
        NSNumber* yOrigin = info[kWindowOriginYKey];
        NSNumber* width = info[kWindowWidthKey];
        NSNumber* height = info[kWindowHeightKey];
        leagueGameState->leagueSize = CGRectMake([xOrigin floatValue], [yOrigin floatValue], [width floatValue], [height floatValue]);
        //NSLog(@"Width: %f, height: %f", [width floatValue], [height floatValue]);
        //NSLog(@"Found league instance: %@", info);
        [statusText setStringValue:[NSString stringWithFormat:@"Running on League Instance (%f, %f)", leagueGameState->leagueSize.size.width, leagueGameState->leagueSize.size.height]];
    } else {
        [statusText setStringValue:@"No League Instance Found"];
    }
}
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
}


#pragma mark Window List & Window Image Methods

NSString *kAppNameKey = @"applicationName";	// Application Name
NSString *kAppPIDKey = @"applicationPID";	// Application PID
NSString *kWindowOriginXKey = @"windowOriginX";
NSString *kWindowOriginYKey = @"windowOriginY";
NSString *kWindowWidthKey = @"windowWidth";
NSString *kWindowHeightKey = @"windowHeight";
NSString *kWindowIDKey = @"windowID";			// Window ID
NSString *kWindowLevelKey = @"windowLevel";	// Window Level
NSString *kWindowOrderKey = @"windowOrder";	// The overall front-to-back ordering of the windows as returned by the window server

void WindowListApplierFunction(const void *inputDictionary, void *context);
void WindowListApplierFunction(const void *inputDictionary, void *context)
{
    NSDictionary *entry = (__bridge NSDictionary*)inputDictionary;
    WindowListApplierData *data = (__bridge WindowListApplierData*)context;
    
    // The flags that we pass to CGWindowListCopyWindowInfo will automatically filter out most undesirable windows.
    // However, it is possible that we will get back a window that we cannot read from, so we'll filter those out manually.
    int sharingState = [entry[(__bridge id)kCGWindowSharingState] intValue];
    if(sharingState != kCGWindowSharingNone)
    {
        NSMutableDictionary *outputEntry = [NSMutableDictionary dictionary];
        // Grab the application name, but since it's optional we need to check before we can use it.
        NSString *applicationName = entry[(__bridge id)kCGWindowOwnerName];
        if(applicationName != NULL && [applicationName isEqualToString:@"League Of Legends"])
        {
            // PID is required so we assume it's present.
            //NSString *nameAndPID = [NSString stringWithFormat:@"%@ (%@)", applicationName, entry[(id)kCGWindowOwnerPID]];
            
            outputEntry[kAppNameKey] = applicationName;
        }
        else
        {
            return;
            // The application name was not provided, so we use a fake application name to designate this.
            // PID is required so we assume it's present.
            //NSString *nameAndPID = [NSString stringWithFormat:@"((unknown)) (%@)", entry[(id)kCGWindowOwnerPID]];
            //outputEntry[kAppNameKey] = @"unknown";
        }
        
        // Grab the Window Bounds, it's a dictionary in the array, but we want to display it as a string
        CGRect bounds;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)entry[(__bridge id)kCGWindowBounds], &bounds);
        //NSString *originString = [NSString stringWithFormat:@"%.0f/%.0f", bounds.origin.x, bounds.origin.y];
        outputEntry[kWindowOriginXKey] = [NSNumber numberWithInt:bounds.origin.x];
        outputEntry[kWindowOriginYKey] = [NSNumber numberWithInt:bounds.origin.y];
        outputEntry[kAppPIDKey] = entry[(__bridge id)kCGWindowOwnerPID];
        
        //NSString *sizeString = [NSString stringWithFormat:@"%.0f*%.0f", bounds.size.width, bounds.size.height];
        //outputEntry[kWindowSizeKey] = sizeString;
        
        outputEntry[kWindowWidthKey] = [NSNumber numberWithDouble:bounds.size.width];
        outputEntry[kWindowHeightKey] = [NSNumber numberWithDouble:bounds.size.height];
        if (bounds.size.width < 30 || bounds.size.height < 30) {
            return;
        }
        
        // Grab the Window ID & Window Level. Both are required, so just copy from one to the other
        outputEntry[kWindowIDKey] = entry[(__bridge id)kCGWindowNumber];
        outputEntry[kWindowLevelKey] = entry[(__bridge id)kCGWindowLayer];
        
        // Finally, we are passed the windows in order from front to back by the window server
        // Should the user sort the window list we want to retain that order so that screen shots
        // look correct no matter what selection they make, or what order the items are in. We do this
        // by maintaining a window order key that we'll apply later.
        outputEntry[kWindowOrderKey] = @(data.order);
        data.order++;
        
        [data.outputArray addObject:outputEntry];
    }
}


@end
