//
//  SearchProvider.h
//  BestEat
//
//  Created by Syren, Franck on 11/11/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Search.h"

typedef void(^SearchProviderCallback)(NSArray *result, NSError *error);



@interface SearchProvider : NSObject

-(NSString *)nameKey;
-(BEVendorName)type;
@property(nonatomic,strong) NSMutableArray      *places;
@property(nonatomic,strong) NSOperation         *operation;
@property(nonatomic)        BOOL                finished;

-(void)searchWithName:(NSString *)name andLocation:(CLLocationCoordinate2D)coordinate completionHandler:(SearchProviderCallback)completionHandler;
-(void)searchWithQuery:(NSString *)query andLocation:(CLPlacemark *)placemark completionHandler:(SearchProviderCallback)completionHandler;

-(CLLocationCoordinate2D)extractLocation:(NSDictionary *)entry;

-(NSInteger)extracStreetNumber:(NSDictionary *)entry;

@end
