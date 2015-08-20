#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>
#import "InteractiveEvents.h"
#import "Utility.h"
#include <time.h>
#include <stdlib.h>

class TestController {
    ImageData testImage;
    ImageData playButton;
    ImageData testGame1, testGame2;
    
    NSImageView* processedImageView, *unprocessedImageView, *targetImageView, *foundImageView;
    NSTextView* logText;
public:
    TestController(NSImageView* processedImageView, NSImageView *unprocessedImageView, NSImageView* targetImageView, NSImageView* foundImage, NSTextView* logText);
    void copyScreenShot(uint8 *baseAddress, int bufferWidth, int bufferHeight);
    void displayPreprocessedScreenShot();
    void testPlayButton();
    void testGameImage1();
    void log(NSString* string);
};