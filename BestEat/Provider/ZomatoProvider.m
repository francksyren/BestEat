//
//  ZomatoProvider.m
//  BestEat
//
//  Created by Syren, Franck on 11/11/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "ZomatoProvider.h"
#import "Zomato.h"

@implementation ZomatoProvider

-(BEVendorName)type {
    return BEVendorZomato;
}


-(void)searchWithQuery:(NSString *)query andLocation:(CLPlacemark *)placemark completionHandler:(SearchProviderCallback)completionHandler {
 
    [self.places removeAllObjects];
    self.finished = NO;
    
    self.operation = [Zomato queryBusinessInfoForTerm:query
                                                         location:placemark.location.coordinate
                                                completionHandler:^(NSDictionary *result, NSError *error) {
                                                    if (error != nil) {
                                                        NSLog(@"error with Zomato request %@", error);
                                                    }
                                                    else {
                                                        NSArray *restaurants = result[@"restaurants"];
                                                        [restaurants enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                            
                                                            NSDictionary *restaurant = [obj valueForKey:@"restaurant"];
                                                            [self.places addObject:restaurant];
                                                        }];
                                                    }
                                                    completionHandler(self.places, error);
                                                    
                                                }];
}

-(void)searchWithName:(NSString *)name andLocation:(CLLocationCoordinate2D)coordinate completionHandler:(SearchProviderCallback)completionHandler {
    
    [Zomato queryBusinessInfoForTerm:name
                            location:coordinate
                   completionHandler:^(NSDictionary *result, NSError *error) {
                       if (error != nil) {
                           NSLog(@"error with Zomato request %@", error);
                           completionHandler(nil, error);
                           return;
                       }
                       NSArray *restaurants = result[@"restaurants"];
                       if (restaurants && restaurants.count > 0) {
                           NSDictionary *restaurant = [restaurants[0] valueForKey:@"restaurant"];
                           completionHandler(@[restaurant], error);
                       }
                       
                       
                   }];
}

-(CLLocationCoordinate2D)extractLocation:(NSDictionary *)entry {
    NSNumber *lat = [entry valueForKeyPath:@"location.latitude"];
    NSNumber *lng = [entry valueForKeyPath:@"location.longitude"];
    return CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
}


@end
