//
//  Yelp2.h
//  BestEat
//
//  Created by Syren, Franck on 11/5/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YelpOperation.h"

@interface Yelp2 : NSObject

+(NSOperation *)queryBusinessInfoForTerm:(NSString *)term location:(NSString *)location completionHandler:(YelpCallback)completionHandler;
+(NSOperation *)queryBusinessInfoForTerm:(NSString *)term location:(NSString *)location limit:(NSNumber *)limit completionHandler:(YelpCallback)completionHandler;

@end
