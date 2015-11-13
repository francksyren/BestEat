//
//  CLPlacemark+Address.m
//  BestEat
//
//  Created by Syren, Franck on 11/11/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "CLPlacemark+Address.h"

@implementation CLPlacemark (Address)

-(NSString *)longFormattedAddress {

    NSString *address = [NSString stringWithFormat:@"%@, %@, %@ %@, %@", self.name, self.locality, self.administrativeArea, self.postalCode, self.country];
    return address;
}

@end
