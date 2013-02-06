//
//  LoginViewController.m
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import "GCLoginViewController.h"
#import "GCAppDelegate.h"

@interface GCLoginViewController ()

- (IBAction)loginButtonTapped:(UIButton *)sender;

@end

@implementation GCLoginViewController

@synthesize foursquare_api = _foursquare_api;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        GCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.foursquare_api = [appDelegate getFoursquareClient];
        self.foursquare_api.sessionDelegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)loginButtonTapped:(UIButton *)sender {
    NSLog(@"authorizing");
    [self.foursquare_api startAuthorization];
}

# pragma mark BZFoursquareSessionDelegate

- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
    GCAppDelegate *appDelegate = (GCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // save access token for the next time
    [appDelegate saveAccessToken:foursquare.accessToken];
    
    // redirect to places viewcontroller
    appDelegate.window.rootViewController = appDelegate.navigationController;
    
    [self.view removeFromSuperview];
    
}

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, errorInfo);
}

@end
