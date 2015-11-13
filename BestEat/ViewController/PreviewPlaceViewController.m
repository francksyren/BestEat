//
//  PreviewPlaceViewController.m
//  BestEat
//
//  Created by Syren, Franck on 11/9/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "PreviewPlaceViewController.h"

@interface PreviewPlaceViewController () <CLLocationManagerDelegate>
{
    NSMutableArray *previewActions;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property(strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation PreviewPlaceViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.locationManager.delegate = self;

        previewActions = [[NSMutableArray alloc] initWithCapacity:1];
        UIPreviewAction *action = [UIPreviewAction actionWithTitle:@"Show direction" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            
            NSLog(@"show direction");
            [self.locationManager startUpdatingLocation];
        }];
        [previewActions addObject:action];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [self.mapView setRegion:MKCoordinateRegionMake(self.coordinate, MKCoordinateSpanMake(0.01, 0.01)) animated:NO];
    annotation.coordinate = self.coordinate;
    [self.mapView addAnnotation:annotation];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    return previewActions;
}

#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager stopUpdatingLocation];
    CLLocation* location = [locations lastObject];
    
    CLLocationCoordinate2D start = location.coordinate;
    CLLocationCoordinate2D destination = self.coordinate;
    
    NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
                                     start.latitude, start.longitude, destination.latitude, destination.longitude];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"error getting location");
    [self.locationManager stopUpdatingLocation];
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
