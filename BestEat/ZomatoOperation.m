//
//  YelpOperation.m
//  BestEat
//
//  Created by Syren, Franck on 11/5/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "ZomatoOperation.h"


@interface ZomatoOperation ()

@property (nonatomic, copy) ZomatoCallback callbackBlock;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic) dispatch_queue_t callbackQueue;

@property (nonatomic) BOOL _isFinished;
@property (nonatomic) BOOL _isExecuting;


@end

@implementation ZomatoOperation


- (id)initWithRequest:(NSURLRequest *)request
             callback:(ZomatoCallback)block
        callbackQueue:(dispatch_queue_t)callbackQueue {
    
    self = [super init];
    if (self) {
        self.callbackBlock = block;
        self.request = request;
        self.callbackQueue = callbackQueue;
        
        self._isFinished = NO;
        self._isExecuting = NO;
    }
    return self;
}

- (void)start {
    
    self._isFinished = NO;
    self._isExecuting = YES;

    
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


                self.callbackBlock(searchResponseJSON, error);
                
        }
        else {
            NSLog(@"http response code %li", httpResponse.statusCode);
            dispatch_async(self.callbackQueue, ^{
                self._isFinished = YES;
                self._isExecuting = NO;

                self.callbackBlock(nil, error); // An error happened or the HTTP response is not a 200 OK

            });
        }
        
        self._isFinished = YES;
        self._isExecuting = NO;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];

    }] resume];
    
    
}

-(BOOL)isExecuting {
    return self._isExecuting;
}

-(BOOL)asynchronous {
    return YES;
}

-(BOOL)isFinished {
    return self._isFinished;
}


- (BOOL)isConcurrent {
    return YES;
}




@end
