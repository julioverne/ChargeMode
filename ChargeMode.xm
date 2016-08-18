#import "ChargeMode.h"

static BOOL isIOS9;
static BOOL isLocked;

%group ChargeModeHooks

@implementation ChargeMode
@synthesize chargeModeWindow, battDotsView, controller, hourLabel;
__strong static id _sharedObject;
+ (id)sharedInstance
{
	if (!_sharedObject) {
		_sharedObject = [[self alloc] init];
	}
	return _sharedObject;
}
+ (BOOL)sharedInstanceExist
{
	if (_sharedObject) {
		return YES;
	}
	return NO;
}
- (void)firstload
{
	return;
}
- (ChargeModeWindow*)chargeWindow
{
	return chargeModeWindow;
}
-(id)init
{
	self = [super init];
	if(self != nil) {
		chargeModeWindow = [[ChargeModeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		chargeModeWindow.windowLevel = 9999999999+5;
		[chargeModeWindow setHidden:NO];
		
		chargeModeWindow.layer.masksToBounds = NO;
		chargeModeWindow.backgroundColor = [UIColor blackColor];
		
		UIView *add = (UIView *)chargeModeWindow;
		
		controller = [UIViewController new];
		controller.view.frame = chargeModeWindow.frame;
		controller.view.layer.masksToBounds = YES;
		
		hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 340,75)];
		hourLabel.frame = CGRectMake((chargeModeWindow.frame.size.width/2)-(hourLabel.frame.size.width/2), (chargeModeWindow.frame.size.height/2)-hourLabel.frame.size.height, hourLabel.frame.size.width, hourLabel.frame.size.height);
		//hourLabel.font = [hourLabel.font fontWithSize:60];
		hourLabel.font =  [UIFont fontWithName:@".SFUIDisplay-Ultralight" size:70];
		hourLabel.textColor = [UIColor whiteColor];
		//hourLabel.backgroundColor = [UIColor brownColor];
		[hourLabel setTextAlignment:(NSTextAlignment)UITextAlignmentCenter];
		[controller.view addSubview:hourLabel];
		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(targetClock) userInfo:nil repeats:YES];
		
		int dotSize = 12;
		battDotsView = [UIView new];
		[battDotsView setHidden:NO];
		battDotsView.frame = CGRectMake(hourLabel.frame.origin.x+dotSize*2+(dotSize/2), hourLabel.frame.origin.y + hourLabel.frame.size.height, hourLabel.frame.size.width-dotSize*3, 20);
		battDotsView.layer.masksToBounds = YES;
		//battDotsView.backgroundColor = [UIColor whiteColor];
		[controller.view addSubview:battDotsView];
		
		int dotIndex = 1;
		while(dotIndex < 11)
		{
			UIView* circleView = [[UIView alloc] initWithFrame:CGRectMake(dotIndex*((dotSize*2)), 2,dotSize,dotSize)];
			circleView.tag = dotIndex;
			circleView.alpha = 1.0;
			circleView.layer.cornerRadius = dotSize/2;
			circleView.backgroundColor = [UIColor grayColor];
			[battDotsView addSubview:circleView];
			dotIndex++;
		}
		
		
		[self updateBattDot];
		
		[add addSubview:controller.view];
		[chargeModeWindow makeKeyAndVisible];
		
		[self registerForMusicPlayerNotifications];
		
		UITapGestureRecognizer *TapOpenGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(WindowHide)];
		//TapOpenGesture.numberOfTapsRequired = 1;
		[controller.view addGestureRecognizer:TapOpenGesture];
		
		[self batteryStatus];
	}
	return self;
}
- (void)targetClock
{
	if(chargeModeWindow.hidden) {
		return;
	}
	static __strong NSDateFormatter *dateFormatter;
	if(!dateFormatter) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle: NSDateFormatterShortStyle];
	}
	NSString *currentTime = [dateFormatter stringFromDate: [NSDate date]];
	hourLabel.text = currentTime;
}
- (void)updateBattDot
{
	if(chargeModeWindow.hidden) {
		return;
	}
	int battLevel = ([[UIDevice currentDevice] batteryLevel] * 100)/10;
	int dotIndex = 1;
	while(dotIndex < 11)
	{
		if(UIView* dot = [battDotsView viewWithTag:dotIndex]) {
			dot.backgroundColor = (battLevel<=dotIndex-1)?[UIColor grayColor]:[UIColor colorWithRed:0.30 green:0.85 blue:0.39 alpha:1.0];
		}		
		dotIndex++;
	}
}
- (void)WindowHide
{
	[chargeModeWindow setHidden:YES];
}
- (void)batteryStatus
{
	BOOL showWindow = (([[UIDevice currentDevice] batteryState]==2) && isLocked);
	[chargeModeWindow setHidden:showWindow?NO:YES];
	if(showWindow) {
		[self updateBattDot];
	}
}
- (void)registerForMusicPlayerNotifications
{
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatus) name:UIDeviceBatteryStateDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBattDot) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), lockScreenState, CFSTR("com.apple.springboard.lockstate"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	lockScreenState(NULL, NULL, NULL, NULL, NULL);
}
void lockScreenState(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	@autoreleasepool {
		int token;
		uint64_t state;
		notify_register_check("com.apple.springboard.lockstate", &token);
		notify_get_state(token, &state);
		notify_cancel(token);
		isLocked = (BOOL)state;
		if ([ChargeMode sharedInstanceExist]) {
			if(ChargeMode *wid = [ChargeMode sharedInstance]) {
				[wid batteryStatus];
			}
		}
	}
}
@end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application
{
    %orig;
    [[ChargeMode sharedInstance] firstload];
}
%end

%end


__attribute__((constructor)) static void initialize_ChargeMode()
{
	@autoreleasepool {
		isIOS9 = kCFCoreFoundationVersionNumber>=1240.10?YES:NO;
		//if (ChargeModeEnabled) {
			%init(ChargeModeHooks);
		//}
	}
}