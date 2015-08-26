#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>
#import "InteractiveEvents.h"
#import "Utility.h"
#include <time.h>
#include <stdlib.h>
#import "SelfChampionManager.h"
#import "AllyChampionManager.h"
#import "EnemyChampionManager.h"

class TestController {
    ImageData testImage;
    ImageData playButton;
    ImageData testAbilitiesActive1280x800Image, testInGameDetection1280x800Image, testItemActives1280x800Image, testLevelUp1280x800Image, testShopAvailable1280x800Image, testShopItems1280x800Image, testShopOpen1280x800Image;
    
    NSImageView* processedImageView, *unprocessedImageView, *targetImageView, *foundImageView;
    NSTextView* logText;
public:
    TestController(NSImageView* processedImageView, NSImageView *unprocessedImageView, NSImageView* targetImageView, NSImageView* foundImage, NSTextView* logText);
    void copyScreenShot(uint8 *baseAddress, int bufferWidth, int bufferHeight);
    void displayPreprocessedScreenShot();
    void testPlayButton();
    void testShopAvailable();
    void testShopOpen();
    void testShopItems();
    void testInGameDetection();
    void testLevelUp();
    void testAbilitiesActive();
    void testItemActives();
    void testSelfDetection();
    void testAllyChampionDetection();
    void testEnemyChampionDetection();
    void log(NSString* string);
};