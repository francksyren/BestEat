//
//  PlaceDetailViewController.m
//  BestEat
//
//  Created by Syren, Franck on 11/6/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "PlaceDetailViewController.h"

#define FOURSQUARE_BASE_URL @"https://foursquare.com/v/"

@interface PlaceDetailViewController ()

@end

@implementation PlaceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Open in Yelp" forState:UIControlStateNormal];
    [button sizeToFit];
    button.frame = CGRectMake(10, 80, CGRectGetWidth(button.frame), CGRectGetHeight(button.frame));
    [button addTarget:self action:@selector(didPressOpenInYelp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button2 setTitle:@"Open in Foursquare" forState:UIControlStateNormal];
    [button2 sizeToFit];
    button2.frame = CGRectMake(10, 150, CGRectGetWidth(button2.frame), CGRectGetHeight(button2.frame));
    [button2 addTarget:self action:@selector(didPressOpenInFoursquare) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button3 setTitle:@"Open in Zomato" forState:UIControlStateNormal];
    [button3 sizeToFit];
    button3.frame = CGRectMake(10, 220, CGRectGetWidth(button3.frame), CGRectGetHeight(button3.frame));
    [button3 addTarget:self action:@selector(didPressOpenInZomato) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = self.place.name;
}


-(void)didPressOpenInYelp {

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.place.yelpEntry valueForKey:@"url"]]];
}

-(void)didPressOpenInFoursquare {
    NSString *venueID = [self.place.foursquareEntry valueForKey:@"id"];
    if (venueID == nil) {
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@", FOURSQUARE_BASE_URL, venueID];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
}
-(void)didPressOpenInZomato {
    NSString *url = [self.place.zomatoEntry valueForKey:@"url"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
