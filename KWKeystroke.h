#import <Cocoa/Cocoa.h>

@class KWKeyStroke;

@interface KWKeystroke : NSObject
{
    uint16_t _keyCode;
    uint32_t _modifiers;
    NSString *_charactersIgnoringModifiers;
}

@property (nonatomic) uint16_t keyCode;
@property (nonatomic) uint32_t modifiers;
@property (nonatomic, copy) NSString *charactersIgnoringModifiers;

- (id)initWithKeyCode:(uint16_t)keyCode modifiers:(uint32_t)modifiers charactersIgnoringModifiers:(NSString *)charactersIgnoringModifiers;

-(BOOL) isCommand;

-(NSString*) convertToString;

@end

