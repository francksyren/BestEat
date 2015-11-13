//
//  Search.m
//  BestEat
//
//  Created by Syren, Franck on 11/6/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "Search.h"
#import "SearchProvider.h"
#import "YelpProvider.h"
#import "FoursquareProvider.h"
#import "ZomatoProvider.h"


@interface Search()

@property (nonatomic, strong) NSMutableDictionary<NSString *,Place *> *places;

@property (nonatomic, strong) NSArray *searchProviders;


@end

@implementation Search


#pragma -

//+ (Search *)sharedInstance {
//    static Search *instance;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[Search alloc] init];
//    });
//    return instance;
//    
//}

-(id)init {

    self = [super init];
    if (self) {
        self.places = [NSMutableDictionary new];
        self.searchProviders = [NSArray arrayWithObjects:
                                [[YelpProvider alloc] init],
                                [[FoursquareProvider alloc] init],
                                [[ZomatoProvider alloc] init],
                                nil];
    }
    return self;
}

-(void)searchWithQuery:(NSString *)query andLocation:(CLPlacemark *)placemark {

    
    [NSTimer scheduledTimerWithTimeInterval:0.5f
                                     target:self
                                   selector:@selector(isSearchFinished:)
                                   userInfo:nil
                                    repeats:YES];
    
    [self cancelAllRequests];
    
    [self.places removeAllObjects];

    [self.searchProviders enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SearchProvider *provider = obj;
        [provider searchWithQuery:query andLocation:placemark completionHandler:^(NSArray<NSDictionary *> *result, NSError *error) {
            if (error != nil) {
            }
            else {
                [self mergePlaces:result fromVendor:provider];
            }
            provider.finished = YES;
            

        }];
    }];
    
    
}


-(void)isSearchFinished:(NSTimer *)timer {

    __block BOOL isFinished = YES;
    [self.searchProviders enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SearchProvider *provider = obj;
        if (provider.finished == NO) {
            *stop = YES;
            isFinished = NO;
        }
    }];
    if (isFinished) {
        [timer invalidate];
        timer = nil;
        
        // 1. update the table
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.delegate search:self didFinishInitialSearch:self.places];
            
        });
        
//        // 2. do some stuff with the result
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkAndUpdatePlaces:self.places];
        });

    }
}

-(void)checkAndUpdatePlaces:(NSDictionary<NSString *, Place *> *)places{
    
    [places enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull k, Place * _Nonnull p, BOOL * _Nonnull stop) {
        
        
        __block NSString *key = k;
        __block Place *place = p;
        [self.searchProviders enumerateObjectsUsingBlock:^(id  _Nonnull object, NSUInteger index, BOOL * _Nonnull stop2) {
            
            SearchProvider *provider = object;
            if ([place getEntryForVendor:provider.type] == nil) {

                [provider searchWithName:key andLocation:place.coordinate completionHandler:^(NSArray *result, NSError *error) {
                    
                    if (result && result.count > 0) {
                        CLLocationCoordinate2D origLocation = place.coordinate;// [place getLocationForVendor:provider.type];
                        CLLocationCoordinate2D targetLocation = [provider extractLocation:result[0]];
                        
                        LocationDistance gap = [LocationUtil coordinate:origLocation matches:targetLocation];
                        if (gap == LocationDistanceSame) {
                            [place setEntry:result[0] forVendor:provider.type];
                            //[self.delegate search:self didFinishFullSearch:YES];
                        }
                        else if (gap == LocationDistanceClose) {
                            // it's not perfectly same but let's check the name anyway
                            BOOL nameMatch = [Search checkName:result[0][@"name"] matches:place.name];
                            if (nameMatch) {
                                [place setEntry:result[0] forVendor:provider.type];
                            }
                            else {
                                NSLog(@"FOUND A PLACE, CLOSE LOCATION, NOT THE RIGHT ONE %@", result);
                            }
                        }
                        else {
                            NSLog(@"FOUND A PLACE BUT NOT THE RIGHT ONE (%f,%f), (%f,%f), %@", origLocation.latitude, origLocation.longitude, targetLocation.latitude, targetLocation.longitude, result);
                        }
                        
                    }
                    
                }];
            }
            
        }];
    }];
}



-(void)cancelAllRequests {
    
    [self.searchProviders enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SearchProvider *provider = obj;
        [provider.operation cancel];
    }];
}

+(BOOL)checkName:(NSString *)name matches:(NSString *)name2 {

    BOOL matches = YES;
    NSRange range = [name rangeOfString:name2 options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
    if (range.location == NSNotFound) {
        NSRange range2 = [name2 rangeOfString:name options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
        if (range2.location == NSNotFound) {
            matches = NO;
        }
    }
    return matches;
        

}

/**
 * Create new Place or add to existing one
 */
-(void)mergePlaces:(NSArray<NSDictionary *> *)places fromVendor:(SearchProvider *)provider {
    
    
    __weak Search *_weakSelf = self;
    [places enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull entry, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *name = [entry valueForKey:provider.nameKey];
        CLLocationCoordinate2D coordinate = [provider extractLocation:entry];
        NSInteger streetNumber = [provider extracStreetNumber:entry];
        
//        NSString *nameInDictionary = [Search isPresentWithName:name inDictionary:self.places];
        NSString *nameInDictionary = [Search isPresentWithCoordinate:coordinate andStreetNumber:streetNumber inDictionary:_weakSelf.places];
        if (nameInDictionary == nil) {
            Place *p = [[Place alloc] initWithName:name forVendor:provider.type withObject:entry];
            [_weakSelf.places setValue:p forKey:name];
        }
        else {
            Place *p = [_weakSelf.places valueForKey:nameInDictionary];
            [p setEntry:entry forVendor:provider.type];
        }
    }];

}

+(NSString *)isPresentWithCoordinate:(CLLocationCoordinate2D)coordinate andStreetNumber:(NSInteger)streetNumber inDictionary:(NSDictionary<NSString *, Place *> *)dict {

    __block NSString *name = nil;
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Place * _Nonnull obj, BOOL * _Nonnull stop) {
        
        CLLocationCoordinate2D targetCoordinate = obj.coordinate;
        if ([LocationUtil coordinate:coordinate matches:targetCoordinate]) {
            if (streetNumber == obj.streetNumber) {
                name = key;
                *stop = YES;
            }
            
        }
    }];
    return name;
}

@end
