//
//  YelpOperation.h
//  BestEat
//
//  Created by Syren, Franck on 11/5/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^YelpCallback)(NSDictionary *result, NSError *error);

@interface YelpOperation : NSOperation


- (id)initWithRequest:(NSURLRequest *)request
             callback:(YelpCallback)block
        callbackQueue:(dispatch_queue_t)callbackQueue;


@end
