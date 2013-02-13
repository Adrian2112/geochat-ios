//
//  GCPlacesViewController.m
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GCVenuesViewController.h"
#import "GCAppDelegate.h"
#import "GCConversationViewController.h"
#import <NUI/UIBarButtonItem+NUI.h>
#import "NSString+FontAwesome.h"
#import "FAImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFJSONRequestOperation.h"
#import "GCPlaceCell.h"

@interface GCVenuesViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
    UITableViewController *_tableViewController;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *places;
@property (strong, nonatomic) UITableView *placesTableView;
@property (strong, nonatomic) MKMapView *map;
@property (strong, nonatomic) MKPointAnnotation *point;

@end

@implementation GCVenuesViewController

@synthesize locationManager = _locationManager;
@synthesize places = _places;
@synthesize placesTableView = _placesTableView;
@synthesize map = _map;
@synthesize point = _point;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Near Venues";
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
    self.navigationItem.rightBarButtonItem = logoutButton;
    [NUIRenderer renderBarButtonItem:logoutButton];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = [NSString fontAwesomeIconStringForIconIdentifier:@"icon-arrow-left"];
    [backButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:kFontAwesomeFamilyName size:20.0], UITextAttributeFont,nil] forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = backButton;
    
    // initialize location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
    [self.locationManager startUpdatingLocation];
    
    // initialize map
    self.map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    self.map.scrollEnabled = NO;
    self.map.zoomEnabled = NO;
    self.map.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [self.view addSubview:self.map];
    
    
    // using table view controller inside so we can use the refreshControl attribute
    _tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self addChildViewController:_tableViewController];
    
    _tableViewController.refreshControl = [[UIRefreshControl alloc]init];
    [_tableViewController.refreshControl addTarget:self action:@selector(placesRefresh) forControlEvents:UIControlEventValueChanged];
    
    // hack: if not set to empty, the first time it puts the date it is not placed in the correct position
    _tableViewController.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    
    self.placesTableView = _tableViewController.tableView;
    
    int mapHeight = self.map.frame.size.height;
    self.placesTableView.frame = CGRectMake(0, mapHeight, _tableViewController.view.frame.size.width, _tableViewController.view.frame.size.height - mapHeight);
    
    self.placesTableView.dataSource = self;
    self.placesTableView.delegate = self;
    [self.view addSubview:self.placesTableView];
    
}

-(void) logout:(UIButton *)button{
    NSLog(@"Logout");
    [GC_APP_DELEGATE() logout];
    
    [self.view removeFromSuperview];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GCPlaceCell";
    
    GCPlaceCell *cell = (GCPlaceCell *)[self.placesTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCPlaceCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *place = self.places[indexPath.row];
    
    cell.name.text = place[@"name"];
    cell.distance = place[@"distance"];
    cell.users = place[@"users_in"];
    
    // image
    NSURL *photoURL = [NSURL URLWithString:place[@"image"]];
    
    [cell.image setImageWithURL: photoURL placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    GCConversationViewController *conversationViewController = [[GCConversationViewController alloc] init];
    
    NSDictionary *place = self.places[indexPath.row];
    NSString *place_id = place[@"id"];
    NSString *place_name = place[@"name"];
    
    conversationViewController.place_id = place_id;
    conversationViewController.place_name = place_name;
    
    [self.navigationController pushViewController:conversationViewController animated:YES];
}

# pragma mark - API call for places

- (void) getPlacesFromAPIWithLatLng:(NSString *)latLng{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@/venues/search/%@", FULL_HOST, GC_APP_DELEGATE().accessToken, latLng]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        self.places = JSON;
        [self updateView];
        [_tableViewController.refreshControl endRefreshing];
    } failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"%@", error);
    }];
    [operation start];
}

- (void)updateView {
    if ([self isViewLoaded]) {
        NSIndexPath *indexPath = [self.placesTableView indexPathForSelectedRow];
        [self.placesTableView reloadData];
        if (indexPath) {
            [self.placesTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)location{
    
    CLLocationCoordinate2D currentLocation = ((CLLocation *)[location lastObject]).coordinate;
    
    NSLog(@"%f, %f", currentLocation.latitude, currentLocation.longitude);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation, 1000, 1000);
    self.point = [[MKPointAnnotation alloc] init];
    self.point.coordinate = currentLocation;
    
    [self.map addAnnotation:self.point];
    
    [self.map setRegion:viewRegion animated:YES];
    
    NSString *coordinates = [NSString stringWithFormat:@"%f,%f", currentLocation.latitude, currentLocation.longitude];
    [self getPlacesFromAPIWithLatLng:coordinates];
    [self.locationManager stopUpdatingLocation];
}

# pragma mark - UIRefreshControl

-(void)placesRefresh {
    NSLog(@"refresh");
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
    _tableViewController.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    
    [self.locationManager startUpdatingLocation];
}

@end
