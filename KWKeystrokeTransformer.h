#import <Cocoa/Cocoa.h>


@interface KWKeystrokeTransformer : NSValueTransformer
{
}

+(BOOL) allowsReverseTransformation;
+(Class) transformedValueClass;
+(KWKeystrokeTransformer*) sharedTransformer;

-(id) transformedValue:(id)value;

@end
