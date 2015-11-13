//
//  YelpOperation.m
//  BestEat
//
//  Created by Syren, Franck on 11/5/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "YelpOperation.h"


@interface YelpOperation ()

@property (nonatomic, copy) YelpCallback callbackBlock;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic) dispatch_queue_t callbackQueue;

@property (nonatomic) BOOL isFinished;
@property (nonatomic) BOOL isExecuting;


@end

@implementation YelpOperation


- (id)initWithRequest:(NSURLRequest *)request
             callback:(YelpCallback)block
        callbackQueue:(dispatch_queue_t)callbackQueue {
    
    self = [super init];
    if (self) {
        self.callbackBlock = block;
        self.request = request;
        self.callbackQueue = callbackQueue;
        
        _isFinished = NO;
        _isExecuting = NO;
    }
    return self;
}

- (void)start {
    
    _isFinished = NO;
    _isExecuting = YES;

    
    if ([self isCancelled]) {
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if ([self isCancelled]) {
            return;
        }
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];

        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (!error && httpResponse.statusCode == 200) {
            
            __block NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];


//            dispatch_async(self.callbackQueue, ^{

                self.callbackBlock(searchResponseJSON, error);
                
//            });

//                NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//                NSArray *businessArray = searchResponseJSON[@"businesses"];
//            
//            
//            if ([businessArray count] > 0) {
//                completionHandler(businessArray, error);
//            }
//            else {
//                completionHandler(nil, error); // No business was found
//            }
        }
        else {
            dispatch_async(self.callbackQueue, ^{
                _isFinished = YES;
                _isExecuting = NO;

                self.callbackBlock(nil, error); // An error happened or the HTTP response is not a 200 OK

            });
        }
        
        _isFinished = YES;
        _isExecuting = NO;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];

    }] resume];
    
    
}

-(BOOL)isExecuting {
    return _isExecuting;
}

-(BOOL)asynchronous {
    return YES;
}

-(BOOL)isFinished {
    return _isFinished;
}


- (BOOL)isConcurrent {
    return YES;
}




@end
