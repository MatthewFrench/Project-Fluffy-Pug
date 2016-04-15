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
#import "EnemyMinionManager.h"
#import "AllyMinionManager.h"
#import "EnemyTowerManager.h"
#import "AbilityManager.h"
#import "ItemManager.h"
#import "ShopManager.h"
#import "MapManager.h"

class TestController {
    ImageData testImage;
    ImageData playButton;
    ImageData testAbilitiesActiveImage, testInGameDetectionImage, testItemActivesImage, testLevelUpImage, testShopAvailableImage, testShopItemsImage, testShopOpenImage, testEnemyTowerImage, testLevelUpDotImage, testUsedPotion, testHextechGunblade, testSelfChampion;
    
    NSImageView* processedImageView, *unprocessedImageView, *targetImageView, *foundImageView;
    NSTextView* logText;
public:
    TestController(NSImageView* processedImageView, NSImageView *unprocessedImageView, NSImageView* targetImageView, NSImageView* foundImage, NSTextView* logText);
    void copyScreenShot(uint8 *baseAddress, int bufferWidth, int bufferHeight);
    void displayPreprocessedScreenShot();
    void testPlayButton();
    void testSelfDetection();
    void testAllyChampionDetection();
    void testEnemyChampionDetection();
    void testEnemyMinionDetection();
    void testAllyMinionDetection();
    void testEnemyTowerDetection();
    void testLevelUpDetection();
    void testLevelDotDetection();
    void testEnabledAbilityDetection();
    void testEnabledSummonerSpellDetection();
    void testTrinketActiveDetection();
    void testItemActiveDetection();
    void testPotionActiveDetection();
    void testUsedPotionActiveDetection();
    void testShopAvailable();
    void testShopTopLeftCorner();
    void testShopBottomLeftCorner();
    void testShopBuyableItems();
    void testMapDetection();
    void testMapShopDetection();
    void testMapLocationDetection();
    void log(NSString* string);
};