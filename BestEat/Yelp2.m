//
//  Yelp2.m
//  BestEat
//
//  Created by Syren, Franck on 11/5/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "Yelp2.h"
#import "NSURLRequest+OAuth.h"
#import "Constants.h"

static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";
static NSString * const kBusinessPath      = @"/v2/business/";
static NSString * const kSearchLimit       = @"5";

@interface Yelp2()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic) dispatch_queue_t callbackQueue;

/** The timeout interval for NSURLRequest. The default value is 60 sec. */
@property(nonatomic,assign) NSTimeInterval timeoutInterval;


@end

@implementation Yelp2

#pragma -

+ (Yelp2 *)sharedInstance {
    static Yelp2 *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Yelp2 alloc] init];
    });
    return instance;
    
}

- (id)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 10;
        _callbackQueue = dispatch_get_main_queue();
        _timeoutInterval = 60.0;
    }
    return self;
}

- (NSOperation *)sendRequestWithPath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                            callback:(YelpCallback)callback {
    
    NSURLRequest *request = [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:parameters];
    
    YelpCallback block = ^(NSDictionary *result, NSError *error) {
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
    YelpOperation *operation = [[YelpOperation alloc] initWithRequest:request
                                                             callback:block
                                                        callbackQueue:self.callbackQueue];
    [self.operationQueue addOperation:operation];
//    [self.operationQueue waitUntilAllOperationsAreFinished];
    return operation;
}



+ (NSOperation *)queryBusinessInfoForTerm:(NSString *)term location:(NSString *)location completionHandler:(YelpCallback)completionHandler {

    return [Yelp2 queryBusinessInfoForTerm:term location:location limit:@(DEFAULT_SEARCH_LIMIT) completionHandler:completionHandler];
}

+ (NSOperation *)queryBusinessInfoForTerm:(NSString *)term location:(NSString *)location limit:(NSNumber *)limit completionHandler:(YelpCallback)completionHandler {
    
    NSDictionary *params = @{
                             @"term": term,
                             @"location": location,
                             @"limit": limit
                             };
    
    return [[Yelp2 sharedInstance] sendRequestWithPath:kSearchPath parameters:params callback:completionHandler];
}




@end
