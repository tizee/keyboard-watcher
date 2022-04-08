#import "KWKeystroke.h"
#import "KWKeystrokeTransformer.h"

@implementation KWKeystroke

@synthesize keyCode = _keyCode, modifiers = _modifiers, charactersIgnoringModifiers = _charactersIgnoringModifiers;

- (id)initWithKeyCode:(uint16_t)keyCode modifiers:(uint32_t)modifiers charactersIgnoringModifiers:(NSString *)charactersIgnoringModifiers {
	if (!(self = [super init]))
		return nil;

	_keyCode = keyCode;
	_modifiers = modifiers;
	_charactersIgnoringModifiers = [charactersIgnoringModifiers copy];

	return self;
}

- (void)dealloc {
	[_charactersIgnoringModifiers release];
	_charactersIgnoringModifiers = nil;
	[super dealloc];
}

-(BOOL) isCommand
{
	return (_modifiers & (NSEventModifierFlagOption |NSEventModifierFlagControl | NSEventModifierFlagCommand)) != 0;
}

-(NSString*) convertToString
{
	return [[KWKeystrokeTransformer sharedTransformer] transformedValue:self];
}

@end
