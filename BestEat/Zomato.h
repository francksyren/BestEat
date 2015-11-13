//
//  Yelp2.h
//  BestEat
//
//  Created by Syren, Franck on 11/5/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"
#import "ZomatoOperation.h"

@interface Zomato : NSObject

+(NSOperation *)queryBusinessInfoForTerm:(NSString *)term location:(CLLocationCoordinate2D)location completionHandler:(ZomatoCallback)completionHandler;

@end
