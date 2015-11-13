//
//  LocationUtil.m
//  BestEat
//
//  Created by Syren, Franck on 11/11/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "LocationUtil.h"

#define kDELTA_COORDINATE_SAME      1
#define kDELTA_COORDINATE_CLOSE     50


@implementation LocationUtil

+(LocationDistance)coordinate:(CLLocationCoordinate2D)coordinate1 matches:(CLLocationCoordinate2D)coordinate2 {

    int lat1 = coordinate1.latitude * 1000;
    int lng1 = coordinate1.longitude * 1000;
    int lat2 = coordinate2.latitude * 1000;
    int lng2 = coordinate2.longitude * 1000;
    
    if (abs(lat1 - lat2) <= kDELTA_COORDINATE_SAME && abs(lng1 - lng2) <= kDELTA_COORDINATE_SAME) {
        return LocationDistanceSame;
    }
    else if (abs(lat1 - lat2) <= kDELTA_COORDINATE_CLOSE && abs(lng1 - lng2) <= kDELTA_COORDINATE_CLOSE) {
        return  LocationDistanceClose;
    }
    return LocationDistanceAway;
}

@end
