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
    // Insert code here to initialize your application
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 //2000.0
                                             target:self
                                           selector:@selector(timerLogic)
                                           userInfo:nil
                                            repeats:YES];
    leagueGameState = [LeagueGameState new];
    
    [self updateWindowList];
    lastTime = CACurrentMediaTime();
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
        if (leagueGameState.leaguePID == -1) {
            [statusText setStringValue:@"No League Instance Found"];
        }
    }
    else
    {
        loopsTaken++;
    }
    if (leagueGameState.leaguePID != -1) {
        CGImageRef image = [self createSingleWindowShot:leagueGameState.leaguePID andBounds:leagueGameState.leagueSize];
        if (image == NULL) {
            leagueGameState.leaguePID = -1;
            return;
        }
        //[self setOutputImage:image];
        [leagueGameState processImage:image];
        CGImageRelease(image);
        
        //Display minions
        [allyMinionText setStringValue:[NSString stringWithFormat:@"%lu minions", (unsigned long)leagueGameState.allyMinionManager.minionBars.count]];
        
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
    leagueGameState.leaguePID = -1;
    if ([prunedWindowList count] > 0) {
        NSDictionary* info = [prunedWindowList firstObject];
        NSNumber *pid = info[kAppPIDKey];
        leagueGameState.leaguePID = [pid intValue];
        NSNumber* xOrigin = info[kWindowOriginXKey];
        NSNumber* yOrigin = info[kWindowOriginYKey];
        NSNumber* width = info[kWindowWidthKey];
        NSNumber* height = info[kWindowHeightKey];
        leagueGameState.leagueSize = CGRectMake([xOrigin floatValue], [yOrigin floatValue], [width floatValue], [height floatValue]);
        //NSLog(@"Width: %f, height: %f", [width floatValue], [height floatValue]);
        //NSLog(@"Found league instance: %@", info);
        [statusText setStringValue:[NSString stringWithFormat:@"Running on League Instance (%f, %f)", leagueGameState.leagueSize.size.width, leagueGameState.leagueSize.size.height]];
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
    int sharingState = [entry[(id)kCGWindowSharingState] intValue];
    if(sharingState != kCGWindowSharingNone)
    {
        NSMutableDictionary *outputEntry = [NSMutableDictionary dictionary];
        // Grab the application name, but since it's optional we need to check before we can use it.
        NSString *applicationName = entry[(id)kCGWindowOwnerName];
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
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)entry[(id)kCGWindowBounds], &bounds);
        //NSString *originString = [NSString stringWithFormat:@"%.0f/%.0f", bounds.origin.x, bounds.origin.y];
        outputEntry[kWindowOriginXKey] = [NSNumber numberWithInt:bounds.origin.x];
        outputEntry[kWindowOriginYKey] = [NSNumber numberWithInt:bounds.origin.y];
        outputEntry[kAppPIDKey] = entry[(id)kCGWindowOwnerPID];
        
        //NSString *sizeString = [NSString stringWithFormat:@"%.0f*%.0f", bounds.size.width, bounds.size.height];
        //outputEntry[kWindowSizeKey] = sizeString;

        outputEntry[kWindowWidthKey] = [NSNumber numberWithDouble:bounds.size.width];
        outputEntry[kWindowHeightKey] = [NSNumber numberWithDouble:bounds.size.height];
        if (bounds.size.width < 30 || bounds.size.height < 30) {
            return;
        }
        
        // Grab the Window ID & Window Level. Both are required, so just copy from one to the other
        outputEntry[kWindowIDKey] = entry[(id)kCGWindowNumber];
        outputEntry[kWindowLevelKey] = entry[(id)kCGWindowLayer];
        
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
