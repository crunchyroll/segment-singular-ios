//
//  SingularIntegation.m
//  Segment-Singular-iOS
//
//  Created by Eyal Rabinovich on 29/05/2019.
//  Copyright © 2019 Singular Labs. All rights reserved.
//

#import "SingularIntegration.h"
#import <Analytics/SEGAnalyticsConfiguration.h>
#import <Analytics/SEGAnalytics.h>
#import <Singular/Singular.h>
#import <Singular/SingularConfig.h>

#define SEGMENT_WRAPPER_NAME @"Segment"
#define SEGMENT_WRAPPER_VERSION @"1.2.0"

#define SEGMENT_REVENUE_KEY @"revenue"
#define SEGMENT_CURRENCY_KEY @"currency"
#define DEFAULT_CURRENCY @"USD"

@implementation SingularIntegation

static bool isSKANEnabled = NO;
static bool isManualMode = NO;
static void(^conversionValueUpdatedCallback)(NSInteger);
static int waitForTrackingAuthorizationWithTimeoutInterval = 0;
static bool isInitialized = NO;

- (instancetype)initWithSettings:(NSDictionary *)settings {
    self = [super init];
    if (!self) {
        return self;
    }
    
    [Singular setWrapperName:SEGMENT_WRAPPER_NAME andVersion:SEGMENT_WRAPPER_VERSION];
    
    NSString* apiKey = [settings objectForKey:@"apiKey"];
    NSString* secret = [settings objectForKey:@"secret"];
    
    if (!apiKey || !secret){
        return nil;
    }
    
    SingularConfig* config = [[SingularConfig alloc] initWithApiKey:apiKey andSecret:secret];
    
    config.skAdNetworkEnabled = isSKANEnabled;
    config.manualSkanConversionManagement = isManualMode;
    config.conversionValueUpdatedCallback = conversionValueUpdatedCallback;
    config.waitForTrackingAuthorizationWithTimeoutInterval = waitForTrackingAuthorizationWithTimeoutInterval;
    
    [Singular start:config];
    
    isInitialized = YES;
    
    return self;
}

- (void)track:(SEGTrackPayload *)payload {
    
    if([[payload properties] objectForKey:SEGMENT_REVENUE_KEY] ||
       [[[payload properties] objectForKey:SEGMENT_REVENUE_KEY] doubleValue] != 0) {
        double revenue = [[[payload properties] objectForKey:SEGMENT_REVENUE_KEY] doubleValue];
        NSString* currency = DEFAULT_CURRENCY;
        
        if([[payload properties] objectForKey:SEGMENT_CURRENCY_KEY] &&
           [[[payload properties] objectForKey:SEGMENT_CURRENCY_KEY] length] > 0){
            currency = [[payload properties] objectForKey:SEGMENT_CURRENCY_KEY];
        }
        
        [Singular customRevenue:[payload event] currency:currency amount:revenue];
    } else {
        [Singular event:[payload event]];
    }
}

- (void)identify:(SEGIdentifyPayload *)payload {
    if([payload userId] && [[payload userId] length] > 0){
        [Singular setCustomUserId:[payload userId]];
    }
}

- (void)reset {
    [Singular unsetCustomUserId];
}

+ (void)setSKANOptions:(BOOL)skAdNetworkEnabled isManualSkanConversionManagementMode:(BOOL)manualMode withWaitForTrackingAuthorizationWithTimeoutInterval:(NSNumber* _Nullable)waitTrackingAuthorizationWithTimeoutInterval withConversionValueUpdatedHandler:(void(^_Nullable)(NSInteger))conversionValueUpdatedHandler {
    if (isInitialized) {
        NSLog(@"Singular Warning: setSKANOptions should be called before init");
    }

    isSKANEnabled = skAdNetworkEnabled;
    isManualMode = manualMode;
    conversionValueUpdatedCallback = conversionValueUpdatedHandler;
    waitForTrackingAuthorizationWithTimeoutInterval = waitTrackingAuthorizationWithTimeoutInterval ? [waitTrackingAuthorizationWithTimeoutInterval intValue] : 0;
}

@end
