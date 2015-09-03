#import <Cocoa/Cocoa.h>
#import "Utility.h"

class DetectionManager {
    NSMutableArray  *allyMinions, *enemyMinions,
                    *allyChampions, *enemyChampions,
                    *selfChampions, *enemyTowers;
    bool spell1LevelUpAvailable = false, spell2LevelUpAvailable = false, spell3LevelUpAvailable = false, spell4LevelUpAvailable = false;
    GenericObject* spell1LevelUp=nil, *spell2LevelUp=nil, *spell3LevelUp=nil, *spell4LevelUp=nil;
    bool spell1ActiveAvailable = false, spell2ActiveAvailable = false, spell3ActiveAvailable = false, spell4ActiveAvailable = false;
    GenericObject* spell1Active=nil, *spell2Active=nil, *spell3Active=nil, *spell4Active=nil;
    bool summonerSpell1ActiveAvailable = false, summonerSpell2ActiveAvailable = false;
    GenericObject* summonerSpell1Active=nil, *summonerSpell2Active=nil, *summonerSpell3Active=nil, *summonerSpell4Active=nil;
    bool trinketActiveAvailable = false;
    GenericObject* trinketActive=nil;
    bool item1ActiveAvailable = false, item2ActiveAvailable = false, item3ActiveAvailable = false, item4ActiveAvailable = false, item5ActiveAvailable = false, item6ActiveAvailable = false;
    GenericObject* item1Active=nil, *item2Active=nil, *item3Active=nil, *item4Active=nil, *item5Active=nil, *item6Active=nil;
    bool potionActiveAvailable = false;
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
    SelfHealthBar* selfHealthBar=nil;
    
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
    
    int selfHealthBarScanCurrentChunkX = 0;
    int selfHealthBarScanCurrentChunkY = 0;
    
public:
    DetectionManager();
    void processDetection(ImageData image);
    void processAllyMinionDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processEnemyMinionDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processAllyChampionDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processEnemyChampionDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processEnemyTowerDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processSelfChampionDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processSelfHealthBarDetection(ImageData image, dispatch_group_t dispatchGroup);
    void processSpellLevelUps(ImageData image, dispatch_group_t dispatchGroup);
    
    NSMutableArray* getAllyMinions();
    NSMutableArray* getEnemyMinions();
    NSMutableArray* getAllyChampions();
    NSMutableArray* getEnemyChampions();
    NSMutableArray* getEnemyTowers();
    NSMutableArray* getSelfChampions();
    bool getSelfHealthBarVisible();
    SelfHealthBar* getSelfHealthBar();
    bool getSpell1LevelUpVisible();
    bool getSpell2LevelUpVisible();
    bool getSpell3LevelUpVisible();
    bool getSpell4LevelUpVisible();
    GenericObject* getSpell1LevelUp();
    GenericObject* getSpell2LevelUp();
    GenericObject* getSpell3LevelUp();
    GenericObject* getSpell4LevelUp();
};