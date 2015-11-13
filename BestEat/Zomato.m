//
//  Yelp2.m
//  BestEat
//
//  Created by Syren, Franck on 11/5/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "Zomato.h"
#import "NSURLRequest+OAuth.h"

static NSString * const kZomatoAPIHost           = @"https://developers.zomato.com/api";
static NSString * const kZomatoSearchPath        = @"/v2.1/search";
static NSString * const kZomatoCitiesPath        = @"/v2.1/cities";
static NSString * const kZomatoApiKey            = @"7e3f76f19e5c45ae083bfb57d50d991e";

@interface Zomato()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic) dispatch_queue_t callbackQueue;

/** The timeout interval for NSURLRequest. The default value is 60 sec. */
@property(nonatomic,assign) NSTimeInterval timeoutInterval;


@end

@implementation Zomato

#pragma -

+ (Zomato *)sharedInstance {
    static Zomato *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Zomato alloc] init];
    });
    return instance;
    
}

- (id)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 7;
        _callbackQueue = dispatch_get_main_queue();
        _timeoutInterval = 60.0;
    }
    return self;
}

- (NSOperation *)sendRequestWithPath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                            callback:(ZomatoCallback)callback {
    NSURLComponents *components = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"%@%@", kZomatoAPIHost, path]];
    NSMutableArray *queryItems = [NSMutableArray arrayWithCapacity:parameters.allKeys.count];
    for (NSString *key in parameters) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:parameters[key]]];
    }
    components.queryItems = queryItems;
    NSURL *url = components.URL;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:kZomatoApiKey forHTTPHeaderField:@"user_key"];    
    
    
    ZomatoCallback block = ^(NSDictionary *result, NSError *error) {
        //        if ([result isKindOfClass:[NSError class]]) {
        //            NSError *error = (NSError *)result;
        //            BOOL notAuthorizedError = ([error.domain isEqualToString:kFoursquare2ErrorDomain]
        //                                       && error.code == Foursquare2ErrorUnauthorized);
        //            if (notAuthorizedError && [self.class isAuthorized]) {
        //                [Foursquare2.class removeAccessToken];
        //                dispatch_async(dispatch_get_main_queue(), ^{
        //                    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        //                    [center postNotificationName:kFoursquare2DidRemoveAccessTokenNotification object:self];
        //                });
        //            }
        //        }
        if (callback) {
            callback(result, error);
        }
    };
    ZomatoOperation *operation = [[ZomatoOperation alloc] initWithRequest:request
                                                             callback:block
                                                        callbackQueue:self.callbackQueue];
    [self.operationQueue addOperation:operation];
    return operation;
}



+ (NSOperation *)queryBusinessInfoForTerm:(NSString *)term location:(CLLocationCoordinate2D)location completionHandler:(ZomatoCallback)completionHandler {

    NSDictionary *params = @{
                             @"lat": @(location.latitude).stringValue,
                             @"lon": @(location.longitude).stringValue,
                             };
    return [[Zomato sharedInstance] sendRequestWithPath:kZomatoCitiesPath parameters:params callback:^(NSDictionary *result, NSError *error) {
        
        NSArray *citySuggestions = [result valueForKey:@"location_suggestions"];
        if (citySuggestions == nil || citySuggestions.count == 0) {
            NSLog(@"ZOMATO cannot retrieve city for coord (%f, %f)", location.latitude, location.longitude);
            completionHandler(nil, [NSError errorWithDomain:@"Zomato.NoCityFound" code:0 userInfo:nil]);
            return;
        }
        NSDictionary *city = citySuggestions[0];
        NSDictionary *parameters = @{
                                 @"q": term,
                                 @"entity_id": ((NSNumber *)[city valueForKey:@"id"]).stringValue,
                                 @"entity_type": @"city",
                                 @"count": @(DEFAULT_SEARCH_LIMIT).stringValue
                                 };
        
        [[Zomato sharedInstance] sendRequestWithPath:kZomatoSearchPath parameters:parameters callback:completionHandler];

    }];
    
}




@end
