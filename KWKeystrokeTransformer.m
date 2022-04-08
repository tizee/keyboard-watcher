#import "KWKeystrokeTransformer.h"
#import "KWKeystroke.h"

@interface KWKeystrokeTransformer (Private)

-(NSDictionary*) _specialKeys;

@end


@implementation KWKeystrokeTransformer

static NSString* kCommandKeyString = @"\u2318";
static NSString* kAltKeyString = @"\u2325";
static NSString* kControlKeyString = @"\u2303";
static NSString* kShiftKeyString = @"\u21e7";
static NSString* kLeftTabString = @"\u21e5";

#define UTF8(x) [NSString stringWithUTF8String:x]
#define NSNum(x) [NSNumber numberWithInt:x]

+(BOOL) allowsReverseTransformation
{
	return NO;
}

+(Class) transformedValueClass
{
	return [NSString class];
}

+(KWKeystrokeTransformer*) sharedTransformer
{
	static KWKeystrokeTransformer* xformer = nil;
	if (xformer == nil)
	{
		xformer = [[KWKeystrokeTransformer alloc] init];
	}
	return xformer;
}

-(NSDictionary*) _specialKeys
{
	static NSDictionary *d = nil;
	if (d == nil)
	{
		d = [[NSDictionary alloc] initWithObjectsAndKeys:
			UTF8("\xe2\x87\xa1"), NSNum(126), // up
			UTF8("\xe2\x87\xa3"), NSNum(125), // down
			UTF8("\xe2\x87\xa2"), NSNum(124), // right
			UTF8("\xe2\x87\xa0"), NSNum(123), // left
			UTF8("\xe2\x87\xa5"), NSNum(48), // tab
			UTF8("\xe2\x8e\x8b"), NSNum(53), // escape
			UTF8("\xe2\x8e\x8b"), NSNum(71), // escape
			UTF8("\xe2\x8c\xab"), NSNum(51), // delete
			UTF8("\xe2\x8c\xa6"), NSNum(117), // forward delete
			UTF8("?\xe2\x83\x9d"), NSNum(114), // help
			UTF8("\xe2\x86\x96"), NSNum(115), // home
			UTF8("\xe2\x86\x98"), NSNum(119), // end
			UTF8("\xe2\x87\x9e"), NSNum(116), // pgup
			UTF8("\xe2\x87\x9f"), NSNum(121), // pgdn
			UTF8("\xe2\x86\xa9"), NSNum(36), // return
			UTF8("\xe2\x86\xa9"), NSNum(76), // numpad enter
			UTF8("F1"), NSNum(122), // F1
			UTF8("F2"), NSNum(120), // F2
			UTF8("F3"), NSNum(99),  // F3
			UTF8("F4"), NSNum(118), // F4
			UTF8("F5"), NSNum(96),  // F5
			UTF8("F6"), NSNum(97),  // F6
			UTF8("F7"), NSNum(98),  // F7
			UTF8("F8"), NSNum(100), // F8
			UTF8("F9"), NSNum(101), // F9
			UTF8("F10"), NSNum(109), // F10
			UTF8("F11"), NSNum(103), // F11
			UTF8("F12"), NSNum(111), // F12
			UTF8("F13"), NSNum(105), // F13
			UTF8("F14"), NSNum(107), // F14
			UTF8("F15"), NSNum(113), // F15
			UTF8("F16"), NSNum(106), // F16
			UTF8("F17"), NSNum(64), // F17
			UTF8("F18"), NSNum(79), // F18
			UTF8("F19"), NSNum(80), // F19
			UTF8("F20"), NSNum(90), // F20
			UTF8("\xe2\x90\xa3\xe2\x80\x8b"), NSNum(49), // space
			nil];
	}
	return d;
}

-(id) transformedValue:(id)value
{
	KWKeystroke* keystroke = (KWKeystroke*)value;
	NSMutableString* mutableResponse = [NSMutableString string];

	uint32_t _modifiers = [keystroke modifiers];
	uint16_t _keyCode = [keystroke keyCode];

	BOOL isShifted = NO;
	BOOL needsShiftGlyph = NO;
	BOOL isCommand = NO;

	if (_modifiers & NSEventModifierFlagControl)
	{
		isCommand = YES;
		[mutableResponse appendString:kControlKeyString];
	}
	if (_modifiers & NSEventModifierFlagOption)
	{
		isCommand = YES;
		[mutableResponse appendString:kAltKeyString];
	}
	if (_modifiers & NSEventModifierFlagShift)
	{
		isShifted = YES;
		if (isCommand)
			[mutableResponse appendString:kShiftKeyString];
		else
			needsShiftGlyph = YES;
	}
	if (_modifiers & NSEventModifierFlagCommand)
	{
		if (needsShiftGlyph)
		{
			[mutableResponse appendString:kShiftKeyString];
			needsShiftGlyph = NO;
		}
		isCommand = YES;
		[mutableResponse appendString:kCommandKeyString];
	}

	if (isShifted && !isCommand)
	{
        NSString *tmp = [@(_keyCode) isEqualToNumber:@48] ? kLeftTabString : keystroke.charactersIgnoringModifiers;
		if (tmp) {
			[mutableResponse appendString:tmp];
			return mutableResponse;
		}
	}

	id tmp = [[self _specialKeys] objectForKey:@(_keyCode)];
	if (tmp != nil)
	{
		if (needsShiftGlyph)
			[mutableResponse appendString:kShiftKeyString];
		[mutableResponse appendString:tmp];

		return mutableResponse;
	}

	[mutableResponse appendString:keystroke.charactersIgnoringModifiers];

	// If this is a command string, put it in uppercase.
	if (isCommand)
	{
        mutableResponse = [[[mutableResponse uppercaseString] mutableCopy] autorelease];
	}
	
	return mutableResponse;
}

@end
