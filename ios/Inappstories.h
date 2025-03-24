#import <React/RCTEventEmitter.h>
#import "RCTSomeNativeSingleton.h"

#if RCT_NEW_ARCH_ENABLED
#import "generated/RNInappstoriesSpec/RNInappstoriesSpec.h"

@interface Inappstories : RCTEventEmitter <NativeInappstoriesSpec, RCTSomeNativeSingletonDelegate>
#else
#import <React/RCTBridgeModule.h>

@interface Inappstories : RCTEventEmitter <RCTBridgeModule, RCTSomeNativeSingletonDelegate>
#endif

- (void)someDelegateFunction;

@end
