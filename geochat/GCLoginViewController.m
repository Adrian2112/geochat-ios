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
        self.foursquare_api = [[BZFoursquare alloc] initWithClientID:@"W2XHXBWO2BSTSDJI1QPCZVIYBQFJJDOQUFLKW5TLLN4GRHRM" callbackURL:@"geochat://foursquare"];
        self.foursquare_api.version = @"20111119";
        self.foursquare_api.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
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
    // save access token for the next time
    NSLog(@"%@", foursquare.accessToken);
    
    // redirect to places viewcontroller
    GCAppDelegate *appDelegate = (GCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.window.rootViewController = appDelegate.navigationController;
    
    [self.view removeFromSuperview];
    
}

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, errorInfo);
}

@end
