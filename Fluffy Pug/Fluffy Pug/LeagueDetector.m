//
//  LeagueDetector.cpp
//  Fluffy Pug
//
//  Created by Matthew French on 7/31/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#include "LeagueDetector.h"

LeagueDetector::LeagueDetector() {
    
}

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

void LeagueDetector::detectLeagueWindow()
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
    leaguePID = -1;
    if ([prunedWindowList count] > 0) {
        NSDictionary* info = [prunedWindowList firstObject];
        NSNumber *pid = info[kAppPIDKey];
        leaguePID = [pid intValue];
        
        NSNumber* xOrigin2 = info[kWindowOriginXKey];
        NSNumber* yOrigin2 = info[kWindowOriginYKey];
        NSNumber* width2 = info[kWindowWidthKey];
        NSNumber* height2 = info[kWindowHeightKey];
        
        xOrigin = [xOrigin2 floatValue];
        yOrigin = [yOrigin2 floatValue];
        width = [width2 floatValue];
        height = [height2 floatValue];
    }
}
