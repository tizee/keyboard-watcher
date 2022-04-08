#import "KWController.h"
#import <AppKit/AppKit.h>

static NSString* kKWSupplementalAlertText = @"\n\nPlease check the Input Monitoring menu within the Security & Privacy System Preferences pane. This will grant this program access to the Accessibility API in order to broadcast your keyboard inputs.\n\nIf your version of macOS doesn't have an Input Monitoring menu or if this program isn't listed, please add it to the Accessibility menu instead. If the program is already listed under the Accessibility menu, please remove it and try again.\n";

@implementation KWController

-(id) init {
  if (!(self = [super init])) {
    return nil;
  }
  keyboardTap = [KWKeyboardTap new];
  keyboardTap.delegate = self;
  return self;
}

- (void)openPrefsPane:(id)sender {
    NSString *text = @"tell application \"System Preferences\" \n reveal anchor \"Privacy_Accessibility\" of pane id \"com.apple.preference.security\" \n activate \n end tell";
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:text];
    [script executeAndReturnError:nil];
    [script release];
}

-(void) installTap:(id)sender {
    /* NSLog(@"installTap"); */
    NSError* error = nil;
    if (![keyboardTap installTapWithError:&error]) {
        NSAlert *alert = [[NSAlert new] autorelease];
        [alert addButtonWithTitle:@"Close"];
        [alert addButtonWithTitle:@"Open System Preferences"];
        alert.messageText = @"Additional Permissions Required";
        alert.informativeText = [error.localizedDescription stringByAppendingString:kKWSupplementalAlertText];
        alert.alertStyle = NSAlertStyleCritical;

        switch ([alert runModal]) {
            case NSAlertFirstButtonReturn:
                            NSLog(@"First btn");
                [NSApp terminate:nil];
                break;
            case NSAlertSecondButtonReturn: {
                                  NSLog(@"Second btn");
                [self openPrefsPane:nil];
                [NSApp terminate:nil];
                break;
        }
    }
  }
}

-(void) dealloc {
  [keyboardTap removeTap];
  [keyboardTap release];
  [super dealloc];
}

-(void) keyboardTap:(KWKeyboardTap*)tap noteKeystroke:(KWKeystroke*)keystroke {
	NSString* charString = [keystroke convertToString];
  NSLog(@"%@",charString);
}

-(void) keyboardTap:(KWKeyboardTap*)tap noteFlagsChanged:(uint32_t)flags {
  // do nothing
}

@end

// vim: ft=objcpp
