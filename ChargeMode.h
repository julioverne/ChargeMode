#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import <notify.h>
#import <substrate.h>
#import <libactivator/libactivator.h>
#import <CommonCrypto/CommonCrypto.h>

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.chargemode.plist"

@interface ChargeModeWindow : UIWindow
@end

@interface ChargeMode : NSObject
{
	ChargeModeWindow* chargeModeWindow;
	UIView* battDotsView;
	UIViewController* controller;
	UILabel* hourLabel;
}
@property (nonatomic, strong) ChargeModeWindow* chargeModeWindow;
@property (nonatomic, strong) UIView* battDotsView;
@property (nonatomic, strong) UIViewController* controller;
@property (nonatomic, strong) UILabel* hourLabel;

+ (id)sharedInstance;
+ (BOOL)sharedInstanceExist;
- (void)firstload;
@end

