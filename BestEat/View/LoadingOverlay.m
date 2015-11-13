//
//  LoadingOverlay.m
//  BestEat
//
//  Created by Syren, Franck on 11/11/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "LoadingOverlay.h"

@interface LoadingOverlay()

@property(nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation LoadingOverlay


+ (LoadingOverlay *)sharedInstance {
    static LoadingOverlay *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LoadingOverlay alloc] init];
    });
    return instance;
    
}


-(id)init {
    
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.8f];
        
        self.activityView = [[UIActivityIndicatorView alloc]
                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.activityView];
    }
    return self;
}

+(void)showInView:(UIView *)view {
    
    LoadingOverlay *instance= [LoadingOverlay sharedInstance];
    instance.frame = CGRectMake(0, 0, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds));

    instance.activityView.center = view.center;
    [instance.activityView startAnimating];
    instance.alpha = 0.0f;
    [view addSubview:instance];
    [UIView animateWithDuration:0.25f
                     animations:^{
                         instance.alpha = 1.0f;
                     }
     ];
}
+(void)hide {
    LoadingOverlay *instance= [LoadingOverlay sharedInstance];

    [UIView animateWithDuration:0.25f
                     animations:^{
                         instance.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [instance.activityView stopAnimating];
                         [instance removeFromSuperview];
                     }
     ];


}

@end
