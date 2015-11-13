//
//  PlaceViewCell.m
//  BestEat
//
//  Created by Syren, Franck on 11/5/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "PlaceViewCell.h"
#import "UIColorUtils.h"

#define CELL_PADDING            10
#define THUMBNAIL_SIZE          50
#define DISTANCE_LABEL_WIDTH    80

@interface PlaceViewCell()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *ratingYelp;
@property (nonatomic, strong) UILabel *reviewCountYelp;
@property (nonatomic, strong) UILabel *ratingFoursquare;
@property (nonatomic, strong) UILabel *ratingTripadvisor;
@property (nonatomic, strong) UIImageView *ratingYelpImg;
@property (nonatomic, strong) UILabel *ratingFoursquareValue;
@property (nonatomic, strong) UILabel *ratingZomatoValue;
@property (nonatomic, strong) UIImageView *ratingTripadvisorImg;
@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, strong) UILabel *address;
@property (nonatomic, strong) UIImageView *thumbnail;
@end

@implementation PlaceViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.opaque = YES;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_PADDING, 5, THUMBNAIL_SIZE, THUMBNAIL_SIZE)];
        [self addSubview:_thumbnail];
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING + THUMBNAIL_SIZE + CELL_PADDING,
                                                           5,
                                                           self.bounds.size.width - CELL_PADDING - THUMBNAIL_SIZE - CELL_PADDING - DISTANCE_LABEL_WIDTH,
                                                           20)];
        _title.backgroundColor = [UIColor greenColor];
        _title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_title];

        _distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - CELL_PADDING - DISTANCE_LABEL_WIDTH,
                                                           5,
                                                           DISTANCE_LABEL_WIDTH,
                                                           20)];
        _distanceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _distanceLabel.textAlignment = NSTextAlignmentRight;
        _distanceLabel.textColor = [UIColor darkGrayColor];
        _distanceLabel.font = [UIFont systemFontOfSize:12.0f];
        [self addSubview:_distanceLabel];
        
        _ratingYelp = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING, 90, 100, 20)];
        [_ratingYelp setText:@"Yelp"];
        [self addSubview:_ratingYelp];
        _ratingYelpImg = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_PADDING, 110, 90, 20)];
        [_ratingYelpImg setContentMode:UIViewContentModeTopLeft];
        [self addSubview:_ratingYelpImg];
        _reviewCountYelp = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING + 90, 108, 150, 20)];
        _reviewCountYelp.textColor = [UIColor darkGrayColor];
        _reviewCountYelp.font = [UIFont systemFontOfSize:11.0f];
        [self addSubview:_reviewCountYelp];
        
        _ratingFoursquare = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING, 130, 100, 20)];
        [_ratingFoursquare setText:@"Foursquare"];
        [self addSubview:_ratingFoursquare];
        _ratingFoursquareValue = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING, 150, 30, 30)];
        _ratingFoursquareValue.textAlignment = NSTextAlignmentCenter;
        _ratingFoursquareValue.layer.cornerRadius = 5.0f;
        _ratingFoursquareValue.layer.masksToBounds = YES;
        [self addSubview:_ratingFoursquareValue];
        
        _ratingTripadvisor = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING , 180, 100, 20)];
        [_ratingTripadvisor setText:@"Zomato"];
        [self addSubview:_ratingTripadvisor];
        _ratingZomatoValue = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING, 200, 200, 20)];
        [self addSubview:_ratingZomatoValue];
        
        _address = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING, 65, self.frame.size.width - (2 * CELL_PADDING), 20)];
        _address.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:_address];
    }
    return self;
}

+(CGFloat)cellHeight {
    return 220.0f;
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

-(void)setPlace:(Place *)place {

    _place = place;
    
    [_ratingYelpImg setImage:nil];
    [_reviewCountYelp setText:@""];
    [_ratingFoursquareValue setText:@"-"];
    [_ratingFoursquareValue setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
    [_ratingTripadvisorImg setImage:nil];
    [_ratingZomatoValue setText:@""];
    _distanceLabel.text = @"";
    if (place == nil) {
        return;
    }
    
    [_title setText:place.name];
    [_address setText:place.formattedAddress];
    if (place.distance != nil) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.2f kms", (place.distance.doubleValue / 1000.0f) * 100 / 100];
    }
    
    if (place.yelpEntry) {
//        NSNumber *rating = [place.yelpEntry valueForKey:@"rating"];
        [_ratingYelpImg setImage:place.ratingYelpImage];

        NSNumber *count = [place.yelpEntry valueForKey:@"review_count"];
        [_reviewCountYelp setText:[NSString stringWithFormat:@"%@ reviews", count.stringValue]];

    }

    if (place.foursquareEntry) {
        NSNumber *rating = [place.foursquareEntry valueForKey:@"rating"];
        if (rating == nil) {
            [_ratingFoursquareValue setText:@"N/A"];
        }
        else {
            [_ratingFoursquareValue setText:[NSString stringWithFormat:@"%.1f", [rating floatValue]]];
            [_ratingFoursquareValue setBackgroundColor:[UIColor colorWithHexString:[NSString stringWithFormat:@"#%@",[place.foursquareEntry valueForKey:@"ratingColor"]]]];
        }
        
    }
    if (place.zomatoEntry != nil) {
        _ratingZomatoValue.text = [NSString stringWithFormat:@"%@ %@",
                                   [place.zomatoEntry valueForKeyPath:@"user_rating.aggregate_rating"],
                                   [place.zomatoEntry valueForKeyPath:@"user_rating.rating_text"]];
    }
    
    if (place.thumbnail == nil) {
        [place loadThumbnail:^(BOOL success) {
            [_thumbnail setImage:place.thumbnail];
        }];
    }
    else {
        [_thumbnail setImage:place.thumbnail];
    }
    


}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
