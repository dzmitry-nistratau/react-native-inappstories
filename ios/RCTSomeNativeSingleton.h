//
//  RCTSomeNativeSingleton.h
//  Pods
//
//  Created by Dzmitry Nistratau on 26/03/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCTSomeNativeSingletonDelegate <NSObject>
- (void)someDelegateFunction;
@end

@interface RCTSomeNativeSingleton : NSObject

@property (nonatomic, weak, nullable) id<RCTSomeNativeSingletonDelegate> delegate;

+ (instancetype)shared;
- (void)someNativeFunction:(void (^)(void))completion;
+ (NSString *)debugInfo;

@end

NS_ASSUME_NONNULL_END
