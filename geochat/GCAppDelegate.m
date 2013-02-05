//
//  AppDelegate.m
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import "GCAppDelegate.h"

#import "GCLoginViewController.h"
#import "GCNavigationController.h"
#import "GCPlacesViewController.h"

@implementation GCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    GCPlacesViewController *placesViewController = [[GCPlacesViewController alloc] initWithNibName:@"GCPlacesViewController" bundle:nil];
    
    self.navigationController = [[GCNavigationController alloc] initWithRootViewController:placesViewController];
    
    // Override point for customization after application launch.
    self.loginViewController = [[GCLoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    self.window.rootViewController = self.loginViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    GCLoginViewController *loginViewController= (GCLoginViewController *) self.window.rootViewController;
    BZFoursquare *foursquare = loginViewController.foursquare_api;
    return [foursquare handleOpenURL:url];
}


@end
