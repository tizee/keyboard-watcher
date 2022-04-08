#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import <CoreGraphics/CoreGraphics.h>

#import "KWController.h"

#define DEBUG 1
#import "utils.h"

NSString* sayHello() {
  return @"Hello world";
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
       /* const void *keys[] = {kAXTrustedCheckOptionPrompt}; */
    /* const void *values[] = {true}; */
    /* CFDictionaryRef options= CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks); */
      // KEY: kAXTrustedCheckOptionPrompt VALUE: ACFBooleanRef indicating whether the user will be informed if the current process is untrusted. This could be used, for example, on application startup to always warn a user if accessibility is not enabled for the current process. Prompting occurs asynchronously and does not affect the return value.
    NSDictionary *options = @{(id)kAXTrustedCheckOptionPrompt: @YES};
BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
      if(accessibilityEnabled){
        NSLog(@"ok");
      }
      /* BOOL shouldKeepRunning = YES; // global */
      NSRunLoop* current=[NSRunLoop currentRunLoop];
      /* printf("%p\n",current); */
      CFRunLoopGetCurrent();
      KWController* controller= [[KWController alloc] init];
      [controller installTap:nil];
      /* CFRunLoopRun(); */
      [current run];
      /* while (shouldKeepRunning && [current runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) { */
      /*   NSLog(@"good"); */
      /*   shouldKeepRunning = NO; */
      /* } */
    }
    return 0;
}
