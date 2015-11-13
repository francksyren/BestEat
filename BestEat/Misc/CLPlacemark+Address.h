//
//  CLPlacemark+Address.h
//  BestEat
//
//  Created by Syren, Franck on 11/11/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CLPlacemark (Address)

-(NSString *)longFormattedAddress;

@end
