//
//  GCPlacesViewController.m
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GCPlacesViewController.h"
#import "GCAppDelegate.h"
#import "BZFoursquareRequest.h"
#import "BZFoursquare.h"
#import "GCConversationViewController.h"
#import <NUI/UIBarButtonItem+NUI.h>
#import "NSString+FontAwesome.h"

@interface GCPlacesViewController () <BZFoursquareRequestDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
    UITableViewController *_tableViewController;
}

@property (strong, nonatomic) BZFoursquareRequest *request;
@property (strong, nonatomic) BZFoursquare *foursquare;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *places;
@property (strong, nonatomic) UITableView *placesTableView;
@property (strong, nonatomic) MKMapView *map;

@end

@implementation GCPlacesViewController

@synthesize request = _request;
@synthesize foursquare = _foursquare;
@synthesize locationManager = _locationManager;
@synthesize places = _places;
@synthesize placesTableView = _placesTableView;

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
    
    
    GCAppDelegate *appDelegate = GC_APP_DELEGATE();
    self.foursquare = [appDelegate getFoursquareClient];
    
    // initialize location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
    [self.locationManager startUpdatingLocation];
    
    // initialize map
    self.map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    self.map.scrollEnabled = NO;
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.places[indexPath.row][@"name"];
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

#pragma mark - FoursquareRequest Delegates

- (void) foursquareRequestWithPath:(NSString *)path HTTPMethod:(NSString *)method parameters:(NSDictionary *)parameters{
    if (self.request) [self.request cancel];
    
    self.request = [self.foursquare requestWithPath:path HTTPMethod:method parameters:parameters delegate:self];
    
    [self.request start];
}

- (void)requestDidStartLoading:(BZFoursquareRequest *)request{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.places = request.response[@"venues"];
    [self updateView];
    [_tableViewController.refreshControl endRefreshing];
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"Foursquare request error: %@", error);
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
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = currentLocation;
    point.title = @"Current Location";
    
    [self.map addAnnotation:point];

    [self.map setRegion:viewRegion animated:YES];
    
    NSString *coordinates = [NSString stringWithFormat:@"%f,%f", currentLocation.latitude, currentLocation.longitude];
    NSDictionary *parameters = @{@"ll" : coordinates};
    [self foursquareRequestWithPath:@"venues/search" HTTPMethod:@"GET" parameters:parameters];
    
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
