//
//  ViewController.m
//  BestEat
//
//  Created by Syren, Franck on 11/4/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "ViewController.h"
#import "PlaceDetailViewController.h"
#import "PlaceViewCell.h"
#import "PreviewPlaceViewController.h"
#import "LocationSearchViewController.h"
#import "LoadingOverlay.h"
#import "CLPlacemark+Address.h"


@interface ViewController () <CLLocationManagerDelegate, UISearchBarDelegate,
                UIViewControllerPreviewingDelegate,
                LocationSearchViewDelegate,
                SearchDelegate>
{
    NSTimer *searchDelayer; // this will be a weak ref, but adding "[searchDelayer invalidate], searchDelayer=nil;" to dealloc wouldn't hurt
    BOOL _isLoading;

}

@property(nonatomic, strong) UITableView *resultTableView;

@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) UISearchBar *locationBar;

@property(nonatomic, weak) NSDictionary *datasource;


@property(nonatomic, strong) NSArray *venues;


@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLLocation *userCurrentLocation;
@property (strong, nonatomic) CLPlacemark *placemark;
@property (strong, nonatomic) CLPlacemark *userCurrentPlacemark;

@property(strong, nonatomic) LocationSearchViewController *locationSearchViewController;

@property(strong, nonatomic) Search *search;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initInterface];
    
    self.locationSearchViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"locationSearchController"];
    self.locationSearchViewController.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    if ([CLLocationManager locationServicesEnabled]) {
        
        [self.locationManager startUpdatingLocation];
    }
    _isLoading = NO;
    [self addObserver:self forKeyPath:@"placemark" options:0 context:nil];
    
    
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.resultTableView];
    }
    
    self.search = [[Search alloc] init];
    self.search.delegate = self;
    
//    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
//    NSDictionary *lastSearchResults = [userInfo objectForKey:@"lastSearch"];
//    if (lastSearchResults != nil) {
//        self.datasource = lastSearchResults;
//        [self.resultTableView reloadData];
//    }

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void) initInterface {
    self.automaticallyAdjustsScrollViewInsets = NO;

    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 48)];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    _searchBar.placeholder = @"Search for a place";
    [self.view addSubview:_searchBar];
    
    _locationBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 48, self.view.bounds.size.width, 48)];
    _locationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_locationBar setImage:[UIImage imageNamed:@"location_icon_small.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    _locationBar.placeholder = @"Address, ...";
    _locationBar.delegate = self;
    [self.view addSubview:_locationBar];
    
    
    UITableViewController *tableViewController = [UITableViewController new];

    self.resultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 96, self.view.bounds.size.width, self.view.bounds.size.height - 96)
                                                        style:UITableViewStylePlain];
    self.resultTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.resultTableView.delegate = self;
    self.resultTableView.dataSource = self;
    
    tableViewController.view = self.resultTableView;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor purpleColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(willRefresh:) forControlEvents:UIControlEventValueChanged];

    tableViewController.refreshControl = refreshControl;
    
    [self.view addSubview:self.resultTableView];


}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}


-(void)triggerRefresh:(NSTimer *)timer {
    NSDictionary *userInfo = timer.userInfo;
    NSString *searchText = [userInfo valueForKey:@"query"];
    if (searchText == nil || [searchText isEqualToString:@""] || searchText.length < 3) {
        self.datasource = nil;
        [self.resultTableView reloadData];
    }
//    else {
//        [self loadData:searchText];
//    }
    
}

-(void) willRefresh:(id)sender {
    
    [self loadData:_searchBar.text];
    [sender endRefreshing];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"placemark"]) {

        // load suggestion
        if (self.datasource == nil) {
            NSString *query = @"";
            
            NSDate *now = [NSDate date];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitHour  | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:now];
            NSInteger hour = [dateComponents hour];
            if (hour > 4 && hour < 11) {
                // the guy is looking for coffee/breakfast
                query = @"Breakfast";
            }
            else if (hour >= 11 && hour < 15) {
                // the guy is looking for lunch
                query = @"Lunch";
            }
            else if (hour >= 15 && hour < 18) {
                // the guy is looking for coffee/tea or icecream (sunny weekend)
                query = @"Coffee";
            }
            else if (hour >= 18 && hour < 23) {
                // the guy is looking for dinner
                query = @"Dinner";
            }
            else if (hour >= 23 && hour < 3) {
                // the guy is looking for an open fast-food restaurant
                query = @"Burger";
            }
            else {
                // the guy should be sleeping
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"It's late..." message:@"Shouldn't you be sleeping at this time?" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            
            [_searchBar setText:query];
            [self loadData:query];
        }
    }
}

-(void)loadData:(NSString *)searchText {

    if (_isLoading) {
        return;
    }
    
    if (self.placemark == nil) {
        // try retrieving the location again
        [self.locationManager startUpdatingLocation];
        
        __block NSString *_searchText = searchText;
        [self performSelector:@selector(loadData:) withObject:_searchText afterDelay:1.0f];

        return;
    }
    _isLoading = YES;
    [LoadingOverlay showInView:self.view];

    [self.search searchWithQuery:searchText andLocation:self.placemark];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma CCLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

    if ([CLLocationManager locationServicesEnabled] && (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)) {
        [self.locationManager startUpdatingLocation];
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.locationManager stopUpdatingLocation];
    
    CLLocation* location = [locations lastObject];
    self.location = location;
    self.userCurrentLocation = location;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"reverse geocoding failed %@", error);
            return;
        }
        
        if (placemarks == nil || placemarks.count == 0) {
            NSLog(@"reverse did not find any places");
            return;
        }
        
        self.placemark = [placemarks objectAtIndex:0];
        self.userCurrentPlacemark = [placemarks objectAtIndex:0];
        [self updateLocationBarContent:[NSString stringWithFormat:@"Near me (%@)", self.placemark.longFormattedAddress]];
        
    }];
    
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"cannot retrieve location: %@", error);
    
    // set default location
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:37.5120076 longitude:-122.2970876]
                   completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                       
                       self.placemark = [placemarks objectAtIndex:0];
                       NSString *address = [NSString stringWithFormat:@"%@, %@, %@",
                                            _placemark.name,
                                            _placemark.locality,
                                            _placemark.administrativeArea];
                       [self updateLocationBarContent:address];
                   }];

    
    [self.locationManager stopUpdatingLocation];
}


#pragma UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"%li", self.datasource.allKeys.count);
    return (self.datasource == nil) ? 0 : self.datasource.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"PlaceCellItem";
    
    PlaceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[PlaceViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    NSString *key = [self.datasource allKeys][indexPath.row];
    cell.place = [self.datasource valueForKey:key];
    
    return cell;
}


#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PlaceViewCell cellHeight];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    PlaceDetailViewController *detailController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"placeDetailViewController"];
    NSString *key = [self.datasource.allKeys objectAtIndex:indexPath.row];
    detailController.place = [self.datasource valueForKey:key];
    [self.navigationController pushViewController:detailController animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchBar resignFirstResponder];
}


#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar == _searchBar) {
        
//        [searchDelayer invalidate];
//        searchDelayer = nil;
//        
//        searchDelayer = [NSTimer scheduledTimerWithTimeInterval:1.0f
//                                                         target:self
//                                                       selector:@selector(triggerRefresh:)
//                                                       userInfo:@{@"query":searchText}
//                                                        repeats:NO];
    }
    
    
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if (searchBar == _searchBar) {
        [self loadData:searchBar.text];
    }
}

//-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [Search cancelAllRequests];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.datasource = nil;
//        [self.resultTableView reloadData];        
//    });
//    if (searchBar == _locationBar) {
//        self.locationSearchViewController.address = _locationBar.text;
//        [self.navigationController presentViewController:self.locationSearchViewController animated:YES completion:nil];
//    }
//}


-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (searchBar == _locationBar) {
        self.locationSearchViewController.address = _locationBar.text;
        [self.navigationController presentViewController:self.locationSearchViewController animated:YES completion:nil];
    }
    else {
        if ([searchBar.text isEqualToString:@""]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.datasource = nil;
                [self.resultTableView reloadData];
            });
        }
    }
}



#pragma mark UIViewControllerPreviewingDelegate

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    
    NSIndexPath *indexPath = [self.resultTableView indexPathForRowAtPoint:location];
    PlaceViewCell *cell = [self.resultTableView cellForRowAtIndexPath:indexPath];
    Place *place = cell.place;
    
    PreviewPlaceViewController *previewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"previewPlaceController"];
    
    previewController.coordinate = place.coordinate;
    
    previewingContext.sourceRect = cell.frame;
    return previewController;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    NSLog(@"%@", previewingContext);
    [self showViewController:viewControllerToCommit sender:self];
}




#pragma mark LocationSearchViewDelegate

-(void)locationSearchViewDidSelectCurrentLocation:(id)view {
    
    [_locationBar setText:@"Near me"];
    self.placemark = self.userCurrentPlacemark;
    [self loadData:_searchBar.text];
}

-(void)locationSearchView:(id)view didSelectLocation:(CLLocationCoordinate2D)coordinate andName:(NSString *)name {
    [_locationBar setText:name];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                                longitude:coordinate.longitude]
                   completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                       
                       self.placemark = [placemarks objectAtIndex:0];
                       [self loadData:_searchBar.text];
                   }];
}

#pragma -


-(void)updateLocationBarContent:(NSString *)content {
    [_locationBar setText:content];
}



#pragma mark SearchDelegate

-(void)search:(Search *)search didFinishInitialSearch:(NSDictionary *)result {
    
    self.datasource = result;
    [self.resultTableView reloadData];
    _isLoading = NO;
    [LoadingOverlay hide];

    
}

-(void)search:(Search *)search didFinishFullSearch:(BOOL)success {
    //[self.resultTableView reloadRowsAtIndexPaths:[self.resultTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    
}



@end
