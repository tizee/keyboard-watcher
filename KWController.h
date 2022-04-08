#import "KWKeyboardTap.h"
#import "KWKeystroke.h"

@class KWController;

@interface KWController : NSObject <KWKeyboardTapDelegate>
{
    KWKeyboardTap* keyboardTap;
}

-(void) keyboardTap:(KWKeyboardTap*)tap noteKeystroke:(KWKeystroke*)keystroke;
-(void) keyboardTap:(KWKeyboardTap*)tap noteFlagsChanged:(uint32_t)flags;

-(void) installTap:(id)sender;

@end
// vim: ft=objcpp
