//
//  GCPlacesViewController.m
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import "GCPlacesViewController.h"
#import "GCAppDelegate.h"
#import "BZFoursquareRequest.h"
#import "BZFoursquare.h"
#import <CoreLocation/CoreLocation.h>
#import "GCConversationViewController.h"

@interface GCPlacesViewController () <BZFoursquareRequestDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) BZFoursquareRequest *request;
@property (strong, nonatomic) BZFoursquare *foursquare;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *places;

@end

@implementation GCPlacesViewController

@synthesize request = _request;
@synthesize foursquare = _foursquare;
@synthesize locationManager = _locationManager;
@synthesize places = _places;

- (void)viewDidLoad
{
    [super viewDidLoad];

    GCAppDelegate *appDelegate = GC_APP_DELEGATE();
    self.foursquare = [appDelegate getFoursquareClient];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
    
    [self.locationManager startUpdatingLocation];
    
    self.title = @"Venues near you";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"Foursquare request error: %@", error);
}

- (void)updateView {
    if ([self isViewLoaded]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView reloadData];
        if (indexPath) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)location{
    
    CLLocation *lastLocation = [location lastObject];
    NSLog(@"%f, %f", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude);
    NSString *coordinates = [NSString stringWithFormat:@"%f,%f", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude];
    
    coordinates = @"25.644689,-100.285887";
    
    // TODO: delete, this is just for testing
    NSDictionary *parameters = @{@"ll" : coordinates}; //[NSDictionary dictionaryWithObjectsAndKeys:coordinates, @"ll", nil];
    
    [self foursquareRequestWithPath:@"venues/search" HTTPMethod:@"GET" parameters:parameters];
    
    [self.locationManager stopUpdatingLocation];
}

@end
