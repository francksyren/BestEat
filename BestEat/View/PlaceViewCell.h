//
//  PlaceViewCell.h
//  BestEat
//
//  Created by Syren, Franck on 11/5/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@interface PlaceViewCell : UITableViewCell

@property (nonatomic, weak) Place *place;

+(CGFloat)cellHeight;

@end
