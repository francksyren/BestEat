//
//  FoursquareProvider.m
//  BestEat
//
//  Created by Syren, Franck on 11/11/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "FoursquareProvider.h"
#import "Foursquare2.h"
#import "CLPlacemark+Address.h"

@implementation FoursquareProvider


-(BEVendorName)type {
    return BEVendorFoursquare;
}


-(void)searchWithQuery:(NSString *)query andLocation:(CLPlacemark *)placemark completionHandler:(SearchProviderCallback)completionHandler {
    [self.places removeAllObjects];
    self.finished = NO;
    
    self.operation = [Foursquare2
                                      venueSearchNearByLatitude:@(placemark.location.coordinate.latitude)
                                      longitude:@(placemark.location.coordinate.longitude)
                                      query:query
                                      limit:@(DEFAULT_SEARCH_LIMIT)
                                      intent:intentBrowse
                                      radius:@(10000)
                                      categoryId:nil//@"4d4b7105d754a06374d81259"
                                      callback:^(BOOL success, id result){
                                          if (success) {
                                              NSDictionary *dic = result;
                                              NSArray *groups = [dic valueForKeyPath:@"response.groups"];
                                              NSDictionary *group = groups[0];
                                              NSArray *items = [group valueForKey:@"items"];
                                              
                                              [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                  
                                                  NSDictionary *venue = [obj valueForKey:@"venue"];
                                                  
                                                  // TODO check if weird
                                                  // no category is weird
                                                  if ([venue[@"categories"] count] == 0) {
                                                      return;
                                                  }
                                                  
                                                  [self.places addObject:venue];
                                                  
                                              }];
                                          }
                                          else {
                                              NSLog(@"error with Foursquare request %@",result);
                                              
                                          }
                                          completionHandler(self.places, nil);
                                          
                                      }];
}

-(void)searchWithName:(NSString *)name andLocation:(CLLocationCoordinate2D)coordinate completionHandler:(SearchProviderCallback)completionHandler {
    
    [Foursquare2 venueSearchNearByLatitude:@(coordinate.latitude)
                                 longitude:@(coordinate.longitude)
                                     query:name
                                     limit:@(1)
                                    intent:intentBrowse
                                    radius:@(500)
                                categoryId:nil//@"4d4b7105d754a06374d81259"
                                  callback:^(BOOL success, id result) {
                                      
                                      if (success) {
                                          NSDictionary *dic = result;
                                          NSArray *groups = [dic valueForKeyPath:@"response.groups"];
                                          NSDictionary *group = groups[0];
                                          NSArray *items = [group valueForKey:@"items"];
                                          if (items && items.count > 0) {
                                              NSDictionary *item = items[0];
                                              NSDictionary *venue = [item valueForKey:@"venue"];
                                              NSString *venueName = [venue valueForKey:@"name"];
                                              NSLog(@"%@", venueName);
//                                              if (![[venueName lowercaseString] isEqualToString:[name lowercaseString]]) {
//                                                  NSLog(@"FOURSQUARE found one but name does not match %@ != %@", name, venueName);
//                                                  NSLog(@"FOURSQUARE found one but name does not match (%f,%f) != %@", coordinate.latitude, coordinate.longitude, venue[@"location"]);
//                                                  
//                                              }
                                              completionHandler(@[venue], nil);
                                          }
                                          else {
                                              completionHandler(@[], nil);
                                          }
                                          
                                      }
                                      else {
                                          NSLog(@"error %@", result);
                                      }
                                      
                                  }];
}


-(CLLocationCoordinate2D)extractLocation:(NSDictionary *)entry {
    NSNumber *lat = [entry valueForKeyPath:@"location.lat"];
    NSNumber *lng = [entry valueForKeyPath:@"location.lng"];
    return CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
}


@end
