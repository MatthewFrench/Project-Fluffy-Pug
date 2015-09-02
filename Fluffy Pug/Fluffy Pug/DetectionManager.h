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
    
public:
    DetectionManager();
    void processDetection(ImageData image);
    void processAllyMinionDetection(ImageData image, dispatch_group_t dispatchGroup);
    
    NSMutableArray* getAllyMinions();
};