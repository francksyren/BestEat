//
//  YelpOperation.h
//  BestEat
//
//  Created by Syren, Franck on 11/5/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ZomatoCallback)(NSDictionary *result, NSError *error);

@interface ZomatoOperation : NSOperation


- (id)initWithRequest:(NSURLRequest *)request
             callback:(ZomatoCallback)block
        callbackQueue:(dispatch_queue_t)callbackQueue;


@end
