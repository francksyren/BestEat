//
//  LocationUtil.h
//  BestEat
//
//  Created by Syren, Franck on 11/11/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

enum {

    LocationDistanceAway = 0,
    LocationDistanceClose = 1,
    LocationDistanceSame = 2
};
typedef NSUInteger LocationDistance;

@interface LocationUtil : NSObject

+(LocationDistance)coordinate:(CLLocationCoordinate2D)coordinate1 matches:(CLLocationCoordinate2D)coordinate2;

@end
