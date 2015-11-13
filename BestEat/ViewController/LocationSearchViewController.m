//
//  LocationSearchViewController.m
//  BestEat
//
//  Created by Syren, Franck on 11/9/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import "LocationSearchViewController.h"

@interface LocationSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NSTimer *searchDelayer;
}

@property(nonatomic,strong) NSMutableArray *datasource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation LocationSearchViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.datasource = [NSMutableArray arrayWithArray:@[@"Near me"]];
        self.searchBar = [[UISearchBar alloc] init];
        self.searchBar.delegate = self;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];


    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissMe)];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];

    navItem.titleView = self.searchBar;
    navItem.rightBarButtonItem = done;
    self.navBar.items = [NSArray arrayWithObject:navItem];

}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.address != nil) {
        [self.searchBar setText:self.address];
        [self placeAutocomplete:self.address];
    }
    [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissMe {
    if ([self.searchBar.text isEqualToString:@""]) {
        [self.delegate locationSearchViewDidSelectCurrentLocation:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"LocationSearchItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.textLabel.text = [self.datasource objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"location_icon_small.png"];
    }
    else {
        GMSPlace *place = [self.datasource objectAtIndex:indexPath.row];
        cell.textLabel.text = place.formattedAddress;
    }
    
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissMe];
    dispatch_async(dispatch_get_main_queue(), ^{

        if (indexPath.row == 0) {
            [self.delegate locationSearchViewDidSelectCurrentLocation:self];
        }
        else {
            GMSPlace *place = [self.datasource objectAtIndex:indexPath.row];
            [self.delegate locationSearchView:self didSelectLocation:place.coordinate andName:place.formattedAddress];
        }
        
    });


}

#pragma mark UISearchBarDelegate

-(void)triggerAutocomplete:(NSTimer *)timer {
    NSDictionary *userInfo = timer.userInfo;
    NSString *searchText = [userInfo valueForKey:@"query"];
    [self placeAutocomplete:searchText];
}

-(void)placeAutocomplete:(NSString *)searchText {
    if (searchText == nil || [searchText isEqualToString:@""] || searchText.length < 3) {
        [self.datasource removeObjectsInRange:NSMakeRange(1, self.datasource.count - 1)];
        [self.tableView reloadData];
        return;
    }
    
    
    [[GMSPlacesClient sharedClient] autocompleteQuery:searchText
                                               bounds:nil
                                               filter:nil
                                             callback:^(NSArray * _Nullable results, NSError * _Nullable error)
     {
         
         if (error != nil) {
             NSLog(@"Autocomplete error %@", [error localizedDescription]);
             return;
         }
         [self.datasource removeObjectsInRange:NSMakeRange(1, self.datasource.count - 1)];
         [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             
             GMSAutocompletePrediction *prediction = obj;
             [[GMSPlacesClient sharedClient] lookUpPlaceID:prediction.placeID
                                                  callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
                                                      
                                                      [self.datasource addObject:place];
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          
                                                          [self.tableView reloadData];
                                                      });
                                                  }];
             if (idx > 5) {
                 *stop = YES;
             }
             
         }];
         
     }];

}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    [searchDelayer invalidate];
    searchDelayer = nil;

    searchDelayer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                     target:self
                                                   selector:@selector(triggerAutocomplete:)
                                                   userInfo:@{@"query":searchText}
                                                    repeats:NO];

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
