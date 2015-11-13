//
//  SearchProvider.m
//  BestEat
//
//  Created by Syren, Franck on 11/11/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "SearchProvider.h"

@implementation SearchProvider

-(id)init {
    self = [super init];
    if (self) {
        self.places = [NSMutableArray new];
    }
    return self;
}

-(NSString *)nameKey {
    return @"name";
}

-(NSInteger)extracStreetNumber:(NSDictionary *)entry {
    NSString *address = [entry valueForKeyPath:@"location.address"];
    if (address == nil) {
        return 0;
    }
    return [[address componentsSeparatedByString:@" "] objectAtIndex:0].integerValue;
}

-(BEVendorName)type {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(void)searchWithQuery:(NSString *)query andLocation:(CLPlacemark *)placemark completionHandler:(SearchProviderCallback)completionHandler {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


-(void)searchWithName:(NSString *)name andLocation:(CLLocationCoordinate2D)coordinate completionHandler:(SearchProviderCallback)completionHandler {
//    @throw [NSException exceptionWithName:NSInternalInconsistencyException
//                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
//                                 userInfo:nil];

}

-(CLLocationCoordinate2D)extractLocation:(NSDictionary *)entry {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
