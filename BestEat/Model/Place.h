//
//  Place.h
//  BestEat
//
//  Created by Syren, Franck on 11/5/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    BEVendorFoursquare,
    BEVendorYelp,
    BEVendorZomato
} BEVendorName;

@interface Place : NSObject

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic) NSInteger streetNumber;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSNumber *distance;
@property(nonatomic, strong) NSDictionary *yelpEntry;
@property(nonatomic, strong) NSDictionary *foursquareEntry;
@property(nonatomic, strong) NSDictionary *zomatoEntry;

@property(nonatomic, strong) UIImage *thumbnail;
@property(nonatomic, strong) UIImage *ratingYelpImage;

@property(nonatomic, readonly) NSString *formattedAddress;

-(id)initWithName:(NSString *)name forVendor:(BEVendorName)vendor withObject:(NSDictionary *)object;
-(void)loadThumbnail:(void(^)(BOOL success))completionHandler;

-(NSDictionary *)getEntryForVendor:(BEVendorName)vendor;
-(void)setEntry:(NSDictionary *)entry forVendor:(BEVendorName)vendor;



@end
