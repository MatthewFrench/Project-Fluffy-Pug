#import <Cocoa/Cocoa.h>
#import "Utility.h"

class DetectionManager {
    
    
    /*
     
     One of my problems is that I'm running the AI on the main thread.
     I'm running detection on a separate thread.
     Detection is sending results to the AI thread but detection needs to get back some of the results.
     Perhaps add a private variable at the start of detection methods that need access?
     */
    
    /*
     
     Detection is taking way too long in some situations. Also the ai loop seems to stutter every now and then.
     
     */
    
    
    
    NSMutableArray  *allyMinions, *enemyMinions,
                    *allyChampions, *enemyChampions,
                    *selfChampions, *enemyTowers;
    bool spell1LevelUpAvailable = false, spell2LevelUpAvailable = false, spell3LevelUpAvailable = false, spell4LevelUpAvailable = false;
    GenericObject* spell1LevelUp=nil, *spell2LevelUp=nil, *spell3LevelUp=nil, *spell4LevelUp=nil;
    NSMutableArray* spell1LevelDots, *spell2LevelDots, *spell3LevelDots, *spell4LevelDots;
    bool spell1LevelDotsVisible = false, spell2LevelDotsVisible = false, spell3LevelDotsVisible = false, spell4LevelDotsVisible = false;
    int currentLevel = 0;
    bool spell1ActiveAvailable = false, spell2ActiveAvailable = false, spell3ActiveAvailable = false, spell4ActiveAvailable = false;
    GenericObject* spell1Active=nil, *spell2Active=nil, *spell3Active=nil, *spell4Active=nil;
    bool summonerSpell1ActiveAvailable = false, summonerSpell2ActiveAvailable = false;
    GenericObject* summonerSpell1Active=nil, *summonerSpell2Active=nil;
    bool trinketActiveAvailable = false;
    GenericObject* trinketActive=nil;
    bool item1ActiveAvailable = false, item2ActiveAvailable = false, item3ActiveAvailable = false, item4ActiveAvailable = false, item5ActiveAvailable = false, item6ActiveAvailable = false;
    GenericObject* item1Active=nil, *item2Active=nil, *item3Active=nil, *item4Active=nil, *item5Active=nil, *item6Active=nil;
    bool potionActiveAvailable = false;
    int potionOnActive;
    GenericObject* potionActive=nil;
    bool potionBeingUsedShown = false;
    GenericObject* potionBeingUsed=nil;
    bool shopAvailableShown = false;
    GenericObject* shopAvailable=nil;
    bool shopTopLeftCornerShown = false;
    GenericObject* shopTopLeftCorner=nil;
    bool shopBottomLeftCornerShown = false;
    GenericObject* shopBottomLeftCorner=nil;
    NSMutableArray* buyableItems;
    bool mapVisible = false;
    GenericObject* map=nil;
    bool mapShopVisible = false;
    GenericObject* mapShop=nil;
    bool mapSelfLocationVisible = false;
    GenericObject* mapSelfLocation=nil;
    bool selfHealthBarVisible = false;
    SelfHealth* selfHealthBar=nil;
    
    int allyMinionScanCurrentChunkX = 0;
    int allyMinionScanCurrentChunkY = 0;
    
    int enemyMinionScanCurrentChunkX = 0;
    int enemyMinionScanCurrentChunkY = 0;
    
    int allyChampionScanCurrentChunkX = 0;
    int allyChampionScanCurrentChunkY = 0;
    
    int enemyChampionScanCurrentChunkX = 0;
    int enemyChampionScanCurrentChunkY = 0;
    
    int enemyTowerScanCurrentChunkX = 0;
    int enemyTowerScanCurrentChunkY = 0;
    
    int selfChampionScanCurrentChunkX = 0;
    int selfChampionScanCurrentChunkY = 0;
    
    //int selfHealthBarScanCurrentChunkX = 0;
    //int selfHealthBarScanCurrentChunkY = 0;
    
    int shopScanCurrentChunkX = 0;
    int shopScanCurrentChunkY = 0;
    
    dispatch_queue_t aiThread;
    dispatch_queue_t detectionThread;
    
    dispatch_queue_t itemActive1Thread, itemActive2Thread, itemActive3Thread, itemActive4Thread, itemActive5Thread, itemActive6Thread;
    dispatch_queue_t mapThread, shopThread, shopAvailableThread, usedPotionThread, trinketActiveThread, spell1ActiveThread, spell2ActiveThread, spell3ActiveThread, spell4ActiveThread, summonerSpell1ActiveThread, summonerSpell2ActiveThread, levelUpDotsThread, spell1LevelUpThread, spell2LevelUpThread, spell3LevelUpThread, spell4LevelUpThread, allyMinionThread, enemyMinionThread, enemyChampionThread, allyChampionThread, enemyTowerThread, selfChampionThread, selfHealthBarThread;
    
    //Detection thread only variables:
    //GenericObject* mapDetectionObject=nil, *shopTopLeftCornerDetectionObject=nil;
    //NSMutableArray* allyMinionsDetectionObject, *enemyMinionsDetectionObject, *selfChampionsDetectionObject, *enemyTowersDetectionObject, *allyChampionsDetectionObject, *enemyChampionsDetectionObject;
    
    //bool scanningScreen = false;
    
public:
    DetectionManager(dispatch_queue_t _aiThread, dispatch_queue_t _detectionThread);
    void processDetection(ImageData image);
    void processAllyMinionDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processEnemyMinionDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processAllyChampionDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processEnemyChampionDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processEnemyTowerDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processSelfChampionDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processSelfHealthBarDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processSpellLevelUps(ImageData image, dispatch_group_t dispatchGroup);
    void processSpellLevelDots(ImageData image, dispatch_group_t dispatchGroup);
    void processSpellActives(ImageData image, dispatch_group_t dispatchGroup);
    void processSummonerSpellActives(ImageData image, dispatch_group_t dispatchGroup);
    void processTrinketActive(ImageData image, dispatch_group_t dispatchGroup);
    void processItemActives(ImageData image, dispatch_group_t dispatchGroup);
    void processUsedPotion(ImageData image, dispatch_group_t dispatchGroup);
    void processShopAvailable(ImageData image, dispatch_group_t dispatchGroup);
    void processShop(ImageData image, dispatch_group_t dispatchGroup);
    void processMap(ImageData image, dispatch_group_t dispatchGroup);
    
    NSMutableArray* getAllyMinions();
    NSMutableArray* getEnemyMinions();
    NSMutableArray* getAllyChampions();
    NSMutableArray* getEnemyChampions();
    NSMutableArray* getEnemyTowers();
    NSMutableArray* getSelfChampions();
    bool getSelfHealthBarVisible();
    SelfHealth* getSelfHealthBar();
    bool getSpell1LevelUpVisible();
    bool getSpell2LevelUpVisible();
    bool getSpell3LevelUpVisible();
    bool getSpell4LevelUpVisible();
    GenericObject* getSpell1LevelUp();
    GenericObject* getSpell2LevelUp();
    GenericObject* getSpell3LevelUp();
    GenericObject* getSpell4LevelUp();
    NSMutableArray* getSpell1LevelDots();
    NSMutableArray* getSpell2LevelDots();
    NSMutableArray* getSpell3LevelDots();
    NSMutableArray* getSpell4LevelDots();
    int getCurrentLevel();
    bool getSpell1Available();
    bool getSpell2Available();
    bool getSpell3Available();
    bool getSpell4Available();
    GenericObject* getSpell1();
    GenericObject* getSpell2();
    GenericObject* getSpell3();
    GenericObject* getSpell4();
    bool getSummonerSpell1Available();
    bool getSummonerSpell2Available();
    GenericObject* getSummonerSpell1();
    GenericObject* getSummonerSpell2();
    bool getTrinketActiveAvailable();
    GenericObject* getTrinketActive();
    bool getItem1ActiveAvailable();
    bool getItem2ActiveAvailable();
    bool getItem3ActiveAvailable();
    bool getItem4ActiveAvailable();
    bool getItem5ActiveAvailable();
    bool getItem6ActiveAvailable();
    GenericObject* getItem1Active();
    GenericObject* getItem2Active();
    GenericObject* getItem3Active();
    GenericObject* getItem4Active();
    GenericObject* getItem5Active();
    GenericObject* getItem6Active();
    bool getPotionActiveAvailable();
    GenericObject* getPotionActive();
    bool getPotionBeingUsedVisible();
    GenericObject* getPotionBeingUsed();
    bool getShopAvailable();
    GenericObject* getShopAvailableObject();
    bool getShopTopLeftCornerVisible();
    GenericObject* getShopTopLeftCorner();
    bool getShopBottomLeftCornerVisible();
    GenericObject* getShopBottomleftCorner();
    NSMutableArray* getBuyableItems();
    bool getMapVisible();
    GenericObject* getMap();
    bool getMapShopVisible();
    GenericObject* getMapShop();
    bool getMapLocationVisible();
    GenericObject* getMapLocation();
};