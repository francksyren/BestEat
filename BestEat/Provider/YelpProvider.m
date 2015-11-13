//
//  YelpProvider.m
//  BestEat
//
//  Created by Syren, Franck on 11/11/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "YelpProvider.h"
#import "Yelp2.h"
#import "CLPlacemark+Address.h"

@implementation YelpProvider


-(BEVendorName)type {
    return BEVendorYelp;
}

/**
 * @override
 */
-(void)searchWithQuery:(NSString *)query andLocation:(CLPlacemark *)placemark completionHandler:(SearchProviderCallback)completionHandler {

    [self.places removeAllObjects];
    self.finished = NO;
    
    
    NSLog(@"query %@ - and address: %@", query, placemark.longFormattedAddress);

    self.operation = [Yelp2 queryBusinessInfoForTerm:query location:placemark.longFormattedAddress completionHandler:^(NSDictionary *result, NSError *error) {
        
        NSArray *businessArray = result[@"businesses"];
        [businessArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [self.places addObject:obj];
        }];
        
        completionHandler(self.places, error);
    }];
}

-(void)searchWithName:(NSString *)name andLocation:(CLLocationCoordinate2D)coordinate completionHandler:(SearchProviderCallback)completionHandler {

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]
                   completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {

                       NSLog(@"name %@ - and address: %@", name, placemarks[0].longFormattedAddress);
                       [Yelp2 queryBusinessInfoForTerm:name location:placemarks[0].longFormattedAddress limit:@(1) completionHandler:^(NSDictionary *result, NSError *yerror) {
                           
                           if (yerror != nil) {
                               return;
                           }
                           NSArray *businessArray = result[@"businesses"];
                           completionHandler(@[businessArray[0]], yerror);
                           
                           
                       }];

                       
                   }];
    
}


-(NSInteger)extracStreetNumber:(NSDictionary *)entry {
    NSArray<NSString *> *address = [entry valueForKeyPath:@"location.address"];
    if (address == nil || address.count == 0) {
        return 0;
    }
    
    return [[address[0] componentsSeparatedByString:@" "] objectAtIndex:0].integerValue;
}


-(CLLocationCoordinate2D)extractLocation:(NSDictionary *)entry {
    NSNumber *lat = [entry valueForKeyPath:@"location.coordinate.latitude"];
    NSNumber *lng = [entry valueForKeyPath:@"location.coordinate.longitude"];
    return CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
}

@end
