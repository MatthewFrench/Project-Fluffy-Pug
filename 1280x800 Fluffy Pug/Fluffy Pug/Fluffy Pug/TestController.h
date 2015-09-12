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
    ImageData testAbilitiesActive1280x800Image, testInGameDetection1280x800Image, testItemActives1280x800Image, testLevelUp1280x800Image, testShopAvailable1280x800Image, testShopItems1280x800Image, testShopOpen1280x800Image, testEnemyTower1280x800Image, testLevelUpDot1280x800Image, testUsedPotion1280x800, testOutsideImage1280x800, testHextechGunblade1280x800, testSelfChampion1280x800;
    
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