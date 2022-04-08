#import "KWKeyboardTap.h"

static NSString* bundleName = @"keyboard-watcher";

// Extension (Private)
// doc: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html

// an extension for class KWKeyboardTap that declare private methods:
// - _noteKeyEvent
// - _noteFlagsChanged
@interface KWKeyboardTap (Private)

-(void) _noteKeyEvent:(CGEventRef)eventRef;
-(void) _noteFlagsChanged:(CGEventRef)event;

@end

/**
- CGEventType: Constants that specify the different types of input events.

 link: https://developer.apple.com/documentation/coregraphics/cgeventtype?language=objc

- CGEventTapProxy: Defines an opaque type that represents state within the client application that’s associated with an event tap.

- CGEventRef: Defines an opaque type that represents a low-level hardware event.

link: https://developer.apple.com/documentation/coregraphics/cgeventref?language=objc
**/

// callback for tap event
// return only KeyDown or Flags Changed low-level hardware event type
CGEventRef eventTapCallback(
   CGEventTapProxy proxy,
   CGEventType type,
   CGEventRef event,
   void *vp)
{
    KWKeyboardTap* keyTap = (KWKeyboardTap*)vp;
    switch (type)
    {
        case kCGEventKeyDown:
            [keyTap _noteKeyEvent:event];
            break;
        case kCGEventFlagsChanged:
            [keyTap _noteFlagsChanged:event];
            break;
        default:
            break;
    }
    // return NULL; // for listening mode
    return event;
}

@implementation KWKeyboardTap

// use @synthesize explicitly tell the compile to generate code with
// the conventional name "_delegate" instead of "delegate" for the property
// https://stackoverflow.com/questions/7987060/what-is-the-meaning-of-id
@synthesize delegate = _delegate;

// class init method
-(id) init
{
  // return NULL if NSObject init failed
	if (!(self = [super init]))
		return nil;
  printf("init KWKeyboardTap successfully\n");

	return self;
}

- (void)dealloc {
    printf("dealloc KWKeyboardTap successfully\n");
    if (tapInstalled) {
        [self removeTap];
    }

    [super dealloc];
}

// error handling method
-(NSError*) constructErrorWithDescription:(NSString*)description {
  // NSBundle.mainBundle.bundleIdentifier
    return [NSError errorWithDomain:bundleName
                               code:0
                           userInfo:@{
                                      NSLocalizedDescriptionKey: NSLocalizedString(description, nil)
                                      }];
}

/*
Event Type Mask:(constants) Specifies an event mask that represents all event types.

link: https://developer.apple.com/documentation/coregraphics/quartz_event_services/event_type_mask?language=objc

- CGEventMaskBit: Generates an event mask for a single type of event.

  link: https://developer.apple.com/documentation/coregraphics/cgeventmaskbit?language=objc

- CGEventTapCreate: Creates an event tap.

  link: https://developer.apple.com/documentation/coregraphics/1454426-cgeventtapcreate?language=objc


*/
// install tap event with a given pointer `error` to NSError*
-(BOOL) installTapWithError:(NSError **)error {
  // return if tap event has already been installed
    if (tapInstalled) {
        return YES;
    }
    /* NSLog(@"installTapWithError init"); */
    
    // We have to try to tap the keydown event independently because CGEventTapCreate will succeed if it can
    // install the event tap for the flags changed event, which apparently doesn't require universal access
    // to be enabled.  Thus, the call would succeed but KeyCastr would be, um, useless.

    /*
    
    CFMachPortRef CGEventTapCreate(CGEventTapLocation tap, CGEventTapPlacement place, CGEventTapOptions options, CGEventMask eventsOfInterest, CGEventTapCallBack callback, void *userInfo);
    1. tap: The location of the new event tap. Pass one of the constants listed in CGEventTapLocation. (only running as the root user could use the constant kCGHIDEventTap)
     CGEventTapLocation: https://developer.apple.com/documentation/coregraphics/cgeventtaplocation?language=objc
     kCGSessionEventTap: Specifies that an event tap is placed at the point where HID system and remote control events enter a login session.

    2. place: The placement of the new event tap in the list of active event taps. Pass one of the constants listed in CGEventTapPlacement. 
    
    CGEventTapPlacement: https://developer.apple.com/documentation/coregraphics/cgeventtapplacement?language=objc
    kCGHeadInsertEventTap: Specifies that a new event tap should be inserted before any pre-existing event taps at the same location.

    3. options: A constant that specifies whether the new event tap is a passive listener or an active filter.
    CGEventTapOptions: https://developer.apple.com/documentation/coregraphics/cgeventtapoptions?language=objc
    kCGEventTapOptionListenOnly:  A passive listener receives events but cannot modify or divert them. 

    4. eventsOfInterest: A bit mask that specifies the set of events to be observed.

      CGEventMask: https://developer.apple.com/documentation/coregraphics/cgeventmask?language=objc

      CGEventMask(kCGEventKeyDown): observe only keydown event

    5. callback: An event tap callback function that you provide. Your callback function is invoked from the run loop to which the event tap is added as a source. The thread safety of the callback is defined by the run loop’s environment.
      
        CGEventTapCallBack: https://developer.apple.com/documentation/coregraphics/cgeventtapcallback?language=objc

      6. refcon: A pointer to user-defined data. This pointer is passed into the callback function specified in the callback parameter.
    
    Return value: A Core Foundation mach port that represents the new event tap, or NULL if the event tap could not be created.

      CFMachPortRef: reference to CFMacnPort object
      https://developer.apple.com/documentation/corefoundation/cfmachportref

      CFMachPort:  a wrapper for a native Mach port (mach_port_t). Mach ports are the native communication channel for the macOS kernel.
      https://developer.apple.com/documentation/corefoundation/cfmachport?language=objc

      To listen for messages you need to create a run loop source with CFMachPortCreateRunLoopSource and add it to a run loop with CFRunLoopAddSource.

    */
    CFMachPortRef tapKeyDown = CGEventTapCreate(
                                         kCGSessionEventTap,
                                         kCGHeadInsertEventTap,
                                         kCGEventTapOptionListenOnly,
                                         /* kCGEventTapOptionDefault, */
                                         CGEventMaskBit(kCGEventKeyDown),
                           /* CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventFlagsChanged), */
                                         eventTapCallback,
                                         self
                                         );
    if (tapKeyDown == NULL) {
        if (error != NULL) {
            *error = [self constructErrorWithDescription:@"Could not create keyDown event tap!"];
        }
        return NO;
    }
    // Release the CFType object
    // so tapKeyDown is useless as it has been
    // released immediately after creation
    // but it could ensure KeyDown event could be observed when combines kCGEventKeyDown and kCGEventFlagsChanged
    CFRelease( tapKeyDown );
    /* NSLog(@"tapKeyDown event creation pass"); */
    
    // listen to KeyDown and Flags change
    // CFMachPortRef
    keyboardTap = CGEventTapCreate(
                           kCGSessionEventTap,
                           kCGHeadInsertEventTap,
                           /* kCGEventTapOptionListenOnly, */
                           kCGEventTapOptionDefault,
                           CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventFlagsChanged),
                           eventTapCallback,
                           self
                           );
    
    if (keyboardTap == NULL) {
        if (error != NULL) {
            *error = [self constructErrorWithDescription:@"Could not create keyDown|flagsChanged event tap!"];
        }
        return NO;
    }
    
    /* NSLog(@"keyboardTap init pass"); */
      /** 
      listen for messages using CFMachPort/CFMachPortRef
      1. create a run loop
      2. add it to a run loop


      CFRunLoopSourceRef CFMachPortCreateRunLoopSource(CFAllocatorRef allocator, CFMachPortRef port, CFIndex order)

      1. CFAllocatorRef: The allocator to use to allocate memory for the new object. Pass NULL or kCFAllocatorDefault to use the current default allocator.
      2. CFMachPortRef: reference
      The Mach port for which to create a CFRunLoopSource object.

      3. CFIndex: A priority index indicating the order in which run loop sources are processed. order is currently ignored by CFMachPort run loop sources. Pass 0 for this value.

      Return value: The new CFRunLoopSource object for port.
        CFRunLoopSourceRef: reference
      **/


    keyboardTapEventSource = CFMachPortCreateRunLoopSource(NULL, keyboardTap, 0);
    // release keyboardTap if source failed to create
    if (keyboardTapEventSource == NULL) {
        CFRelease(keyboardTap);
        if (error != NULL) {
            *error = [self constructErrorWithDescription:@"Could not create run loop source!"];
        }
        return NO;
    }
    
    /* NSLog(@"keyboardTapEventSource init pass"); */
      // CFRunLoopGetCurrent: CFRunLoop for the current thread. Current thread's run loop.
     // https://developer.apple.com/documentation/corefoundation/1542428-cfrunloopgetcurrent?language=objc
    keyboardTapRunLoop = CFRunLoopGetCurrent();
    // release resources and return if failed to get
    if (keyboardTapRunLoop == NULL) {
        CFRelease(keyboardTapEventSource);
        CFRelease(keyboardTap);
        if (error != NULL) {
            *error = [self constructErrorWithDescription:@"Could not get current run loop!"];
        }
        return NO;
    }
    
    // add source to run loop
    CFRunLoopAddSource(keyboardTapRunLoop, keyboardTapEventSource, kCFRunLoopDefaultMode);

    NSLog(@"Add source to CF RunLoop pass");
    tapInstalled = YES;
    
    return YES;
}

// free resources if the tap listener has been installed
-(void) removeTap {
    if (!tapInstalled) {
        return;
    }
    /* NSLog(@"remove Tap"); */
    
    CFRunLoopRemoveSource(keyboardTapRunLoop, keyboardTapEventSource, kCFRunLoopDefaultMode);
    CFRelease(keyboardTapRunLoop);
    CFRelease(keyboardTapEventSource);
    CFRelease(keyboardTap);

    tapInstalled = NO;
}


// handle low-level flags change event
// we only care about combination of
// 1. Shift
// 2. Command
// 3. Control
// 4. Alternate
-(void) _noteFlagsChanged:(CGEventRef)event
{
	uint32_t modifiers = 0;
	CGEventFlags f = CGEventGetFlags( event );

	if (f & kCGEventFlagMaskShift)
		modifiers |= NSEventModifierFlagShift;
	
	if (f & kCGEventFlagMaskCommand)
		modifiers |= NSEventModifierFlagCommand;

	if (f & kCGEventFlagMaskControl)
		modifiers |= NSEventModifierFlagControl;
	
	if (f & kCGEventFlagMaskAlternate)
		modifiers |= NSEventModifierFlagOption;

  // invoke noteFlagsChanged method with constructed modifiers
	[self noteFlagsChanged:modifiers];
}

-(void) _noteKeyEvent:(CGEventRef)eventRef
{
  // use ARC for handling memory
    @autoreleasepool {
      // create NSEvent based on Core Graphics type of event for KWKeystroke
        NSEvent *event = [NSEvent eventWithCGEvent:eventRef];
        // transform keyCode into humam-reable format
        // marked as autorelease, release message is delayed
        // to send until pool is released 
        KWKeystroke* keystroke = [[[KWKeystroke alloc] initWithKeyCode:event.keyCode
                                                             modifiers:event.modifierFlags
                                           charactersIgnoringModifiers:event.charactersIgnoringModifiers] autorelease];
       // dispatch keystroke event
        [self noteKeystroke:keystroke];
        // release keystroke
    }
}

-(void) noteKeystroke:(KWKeystroke*)keystroke
{
  // invoke delegation implementation
    [_delegate keyboardTap:self noteKeystroke:keystroke];
}

-(void) noteFlagsChanged:(uint32_t)newFlags
{
  // invoke delegation implementation
    [_delegate keyboardTap:self noteFlagsChanged:newFlags];
}

@end
