//
//  Place.m
//  BestEat
//
//  Created by Syren, Franck on 11/5/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "Place.h"
#import "Foursquare2.h"

@interface Place ()
{
    CLLocationCoordinate2D _coordinate;
    BOOL                   _thumbnailLoaded;
    NSString               *_address;
}

@end

@implementation Place

-(id)initWithName:(NSString *)name forVendor:(BEVendorName)vendor withObject:(NSDictionary *)object {

    self = [super init];
    if (self) {
        _thumbnailLoaded = NO;
        self.name = name;
        
        switch (vendor) {
            case BEVendorYelp:
            {
                self.yelpEntry = object;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                    NSURL *url = [NSURL URLWithString:[object valueForKey:@"image_url"]];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    self.thumbnail = [UIImage imageWithData:data];
                });
                _distance = [object valueForKey:@"distance"];
                
                NSDictionary *location = [object valueForKeyPath:@"location.coordinate"];
                NSNumber *latitude = [location valueForKey:@"latitude"];
                NSNumber *longitude = [location valueForKey:@"longitude"];
                _coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
                
                NSDictionary *l = [object valueForKey:@"location"];
                NSArray *aAddr = [l valueForKey:@"address"];
                NSString *sAddr = @"";
                if (aAddr && aAddr.count > 0) {
                    sAddr = [NSString stringWithFormat:@"%@, ", aAddr[0]];
                    _streetNumber = [[sAddr componentsSeparatedByString:@" "] objectAtIndex:0].integerValue;
                }
                _address = [NSString stringWithFormat:@"%@%@, %@ %@",
                                     sAddr,
                                     [l valueForKey:@"city"],
                                     [l valueForKey:@"state_code"],
                                     [l valueForKey:@"postal_code"]];

            }
                break;
            case BEVendorFoursquare:
            {
                self.foursquareEntry = object;
                
                _distance = [object valueForKeyPath:@"location.distance"];
                
                NSNumber *latitude = [object valueForKeyPath:@"location.lat"];
                NSNumber *longitude = [object valueForKeyPath:@"location.lng"];
                _coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
                
                NSDictionary *l = [object valueForKey:@"location"];
                NSString *sAddr = [l valueForKey:@"address"];
                _address = [NSString stringWithFormat:@"%@, %@, %@ %@",
                                     sAddr,
                                     [l valueForKey:@"city"],
                                     [l valueForKey:@"state"],
                                     [l valueForKey:@"postalCode"]];
                NSArray<NSString *> *splitAddress = [sAddr componentsSeparatedByString:@" "];
                if (splitAddress && splitAddress.count > 0) {
                    _streetNumber = splitAddress[0].integerValue;
                }
                
            }
                break;
            case BEVendorZomato:
            {
                self.zomatoEntry = object;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSURL *url = [NSURL URLWithString:[object valueForKey:@"featured_image"]];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    self.thumbnail = [UIImage imageWithData:data];
                });
                NSNumber *latitude = [object valueForKeyPath:@"location.latitude"];
                NSNumber *longitude = [object valueForKeyPath:@"location.longitude"];
                _coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
                _address = [object valueForKeyPath:@"location.address"];
                NSArray<NSString *> *splitAddress = [_address componentsSeparatedByString:@" "];
                if (splitAddress && splitAddress.count > 0) {
                    _streetNumber = splitAddress[0].integerValue;
                }

            }
                break;
            default:
                break;
        }

        
    }
    return self;
}

-(void)setEntry:(NSDictionary *)entry forVendor:(BEVendorName)vendor {

    NSAssert(entry != nil, @"Cannot set an nil entry");
    switch (vendor) {
        case BEVendorYelp:
        {
            self.yelpEntry = entry;
        }
            break;
        case BEVendorFoursquare:
        {
            self.foursquareEntry = entry;
            
        }
            break;
        case BEVendorZomato:
        {
            self.zomatoEntry = entry;
            
        }
            break;
        default:
            break;
    }
}

-(NSDictionary *)getEntryForVendor:(BEVendorName)vendor {
    switch (vendor) {
        case BEVendorYelp:
        {
            return self.yelpEntry;
        }
            break;
        case BEVendorFoursquare:
        {
            return self.foursquareEntry;
            
        }
            break;
        case BEVendorZomato:
        {
            return self.zomatoEntry;
            
        }
            break;
        default:
            break;
    }
}



-(void)loadThumbnail:(void (^)(BOOL))completionHandler{
    
    
    if (_thumbnailLoaded == YES
        || self.thumbnail != nil
        || (self.yelpEntry != nil && [self.yelpEntry valueForKey:@"image_url"] != nil)) {
        return;
    }
    NSString *venueID = [self.foursquareEntry valueForKey:@"id"];
    if (venueID == nil) {
        return;
    }
    NSLog(@"venueID: %@", venueID);
    [Foursquare2 venueGetPhotos:[self.foursquareEntry valueForKey:@"id"] limit:[NSNumber numberWithInt:1] offset:nil callback:^(BOOL success, id result) {
        
        _thumbnailLoaded = YES;
        if (!success) {
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *photos = [result valueForKeyPath:@"response.photos.items"];
            if (photos == nil || photos.count == 0) {
                return;
            }
            NSDictionary *photo = photos[0];
            NSString *path = [NSString stringWithFormat:@"%@%@x%@%@",
                              [photo valueForKey:@"prefix"],
                              [photo valueForKey:@"width"],
                              [photo valueForKey:@"height"],
                              [photo valueForKey:@"suffix"]];
            NSURL *url = [NSURL URLWithString:path];
            NSData *data = [NSData dataWithContentsOfURL:url];
            NSLog(@"Picture URL %@", path);
            self.thumbnail = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(YES);
            });
        });
    }];

}

-(void)setYelpEntry:(NSDictionary *)yelpEntry {
    _yelpEntry = yelpEntry;
    
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[yelpEntry valueForKey:@"rating_img_url"]]];
    self.ratingYelpImage = [UIImage imageWithData:imgData];
    
}


-(CLLocationCoordinate2D)coordinate {

    return _coordinate;
}

-(NSString *)formattedAddress {
    return _address;
}

@end
