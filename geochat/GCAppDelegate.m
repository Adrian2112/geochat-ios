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
    
    if ([self readAccessToken]) {
        self.window.rootViewController = self.navigationController;
    } else {
        self.loginViewController = [[GCLoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        self.window.rootViewController = self.loginViewController;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

# pragma mark

# pragma mark application opened with urlscheme
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    GCLoginViewController *loginViewController= (GCLoginViewController *) self.window.rootViewController;
    BZFoursquare *foursquare = loginViewController.foursquare_api;
    return [foursquare handleOpenURL:url];
}

# pragma mark store and read data from data.plist

- (void) saveAccessToken:(NSString *)accessToken{
    NSString *path = [self getPathForDataStorage];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    [data setObject:accessToken forKey:@"accessToken"];
    
    [data writeToFile:path atomically:YES];
}

- (NSString *) readAccessToken{
    
    NSString *path = [self getPathForDataStorage];
    
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    //load from savedStock example int value
    NSString *accessToken = [savedStock objectForKey:@"accessToken"];
    
    return accessToken;
}


- (NSString *) getPathForDataStorage{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    
    return path;
}


@end
