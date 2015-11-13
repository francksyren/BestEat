//
//  LocationSearchViewController.h
//  BestEat
//
//  Created by Syren, Franck on 11/9/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@class LocationSearchViewController;

@protocol LocationSearchViewDelegate

-(void)locationSearchViewDidSelectCurrentLocation:(id)view;
-(void)locationSearchView:(id)view didSelectLocation:(CLLocationCoordinate2D)coordinate andName:(NSString *)name;

@end

@interface LocationSearchViewController : UIViewController

@property (nonatomic, strong) NSString *address;
@property (nonatomic, weak) id<LocationSearchViewDelegate> delegate;

@end
