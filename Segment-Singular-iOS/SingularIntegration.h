//
//  SingularIntegation.h
//  Segment-Singular-iOS
//
//  Created by Eyal Rabinovich on 29/05/2019.
//  Copyright © 2019 Singular Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Analytics/SEGIntegration.h>

NS_ASSUME_NONNULL_BEGIN

@interface SingularIntegation : NSObject<SEGIntegration>

- (instancetype)initWithSettings:(NSDictionary *)settings;
+ (void)setSKANOptions:(BOOL)skAdNetworkEnabled isManualSkanConversionManagementMode:(BOOL)manualMode withWaitForTrackingAuthorizationWithTimeoutInterval:(NSNumber* _Nullable)waitTrackingAuthorizationWithTimeoutInterval withConversionValueUpdatedHandler:(void(^_Nullable)(NSInteger))conversionValueUpdatedHandler;

@end

NS_ASSUME_NONNULL_END
