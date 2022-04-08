#import <Cocoa/Cocoa.h>
#import "KWKeystroke.h"

@class KWKeyboardTap;

// classic Objective-C delegation pattern
// methods used in delegation
// - keyboardTap when keystroked
// - keyboardTap when flags changed
@protocol KWKeyboardTapDelegate

-(void) keyboardTap:(KWKeyboardTap*)keyboardTap noteKeystroke:(KWKeystroke*)keystroke;
-(void) keyboardTap:(KWKeyboardTap*)keyboardTap noteFlagsChanged:(uint32_t)newFlags;

@end

@interface KWKeyboardTap : NSObject {
    id<KWKeyboardTapDelegate> _delegate;
    BOOL tapInstalled;
    CFMachPortRef keyboardTap;
    CFRunLoopRef keyboardTapRunLoop;
    CFRunLoopSourceRef keyboardTapEventSource;
}

// delegate property that performs the assigned task
@property (nonatomic, assign) id<KWKeyboardTapDelegate> delegate;

-(BOOL) installTapWithError:(NSError**)error;
-(void) removeTap;

-(void) noteKeystroke:(KWKeystroke*)keystroke;
-(void) noteFlagsChanged:(uint32_t)newFlags;

@end
