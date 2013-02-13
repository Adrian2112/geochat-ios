//
//  LoginViewController.m
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import "GCLoginViewController.h"
#import "GCAppDelegate.h"
#import "AFJSONRequestOperation.h"

@interface GCLoginViewController ()

- (IBAction)loginButtonTapped:(UIButton *)sender;

@end

@implementation GCLoginViewController

@synthesize foursquare_api = _foursquare_api;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        GCAppDelegate *appDelegate = GC_APP_DELEGATE();
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
    // save access token for the next time
    [GC_APP_DELEGATE() saveValue:foursquare.accessToken withKey:@"accessToken"];
    NSLog(@"%@", foursquare.accessToken);
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/register/%@", FULL_HOST, foursquare.accessToken]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        GCAppDelegate *appDelegate = GC_APP_DELEGATE();
        
        [appDelegate saveValue:JSON[@"name"] withKey:@"name"];
        [appDelegate saveValue:JSON[@"photo"] withKey:@"photo"];
        NSLog(@"%@", (NSDictionary *)JSON);
        
        
        // redirect to places viewcontroller
        appDelegate.window.rootViewController = appDelegate.navigationController;
    
        [self.view removeFromSuperview];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"Error registering user: %@", error);
    }];
    [operation start];
}

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, errorInfo);
}

@end
