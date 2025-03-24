#import "Inappstories.h"
#import <React/RCTBridge.h>

@implementation Inappstories
RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents {
  return @[@"someDelegateFunction", @"nativeViewStateChange"];
}

#if RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeInappstoriesSpecJSI>(params);
}
#endif

RCT_EXPORT_METHOD(callSomeNativeFunction:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    NSLog(@"callSomeNativeFunction invoked from JavaScript");
    
    // Get the singleton instance and log it
    RCTSomeNativeSingleton *singleton = [RCTSomeNativeSingleton shared];
    NSLog(@"Got singleton instance: %@", singleton);
    
    @try {
        // Call the method with a simple completion block
        [singleton someNativeFunction:^{
            NSLog(@"Completion block called");
            resolve(@YES);
        }];
    } @catch (NSException *exception) {
        NSLog(@"Exception calling someNativeFunction: %@", exception);
        reject(@"native_error", exception.description, nil);
    }
}

- (void)startObserving {
    [RCTSomeNativeSingleton shared].delegate = self;
}

- (void)stopObserving {
    if ([RCTSomeNativeSingleton shared].delegate == self) {
        [RCTSomeNativeSingleton shared].delegate = nil;
    }
}

// SomeNativeSingleton delegate implementation
- (void)someDelegateFunction {
    // Make sure we're on the main thread when sending events
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendEventWithName:@"someDelegateFunction" body:@{@"type": @"someDelegateFunction"}];
    });
}

- (void)sendEventWithName:(NSString *)name body:(id)body {
    @try {
        NSLog(@"Sending event %@ with body: %@", name, body);
        [super sendEventWithName:name body:body];
    } @catch (NSException *exception) {
        NSLog(@"*** ERROR sending event %@: %@", name, exception);
        NSLog(@"Body was: %@", body);
    }
}

@end
