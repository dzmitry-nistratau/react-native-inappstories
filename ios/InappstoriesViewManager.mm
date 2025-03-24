#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>
#import "React/RCTBridge.h"
#import "Inappstories.h"

@interface RCT_EXTERN_MODULE(InappstoriesViewManager, RCTViewManager)
RCT_EXTERN_METHOD(load:(nonnull NSNumber *)reactTag
                  color:(nullable NSString *)color)

RCT_EXPORT_VIEW_PROPERTY(initialTag, NSNumber)

@end
