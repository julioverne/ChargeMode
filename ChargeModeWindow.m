#import <objc/runtime.h>
#import "ChargeMode.h"

@implementation ChargeModeWindow
- (BOOL)_shouldCreateContextAsSecure
{
	return YES;
}
@end