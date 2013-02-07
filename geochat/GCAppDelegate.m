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
#import "GCConversationViewController.h"
#import "BZFoursquare.h"

@interface GCAppDelegate()

@property (strong, nonatomic) NSString *accessToken;

@end

@implementation GCAppDelegate

@synthesize accessToken = _accessToken;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
//    GCPlacesViewController *placesViewController = [[GCPlacesViewController alloc] initWithNibName:@"GCPlacesViewController" bundle:nil];
    GCPlacesViewController *placesViewController = [[GCPlacesViewController alloc] init];
    
    self.navigationController = [[GCNavigationController alloc] initWithRootViewController:placesViewController];
    
    if ([self readAccessToken]) {
        self.window.rootViewController = self.navigationController;
    } else {
        self.loginViewController = [[GCLoginViewController alloc] initWithNibName:@"GCLoginViewController" bundle:nil];
        self.window.rootViewController = self.loginViewController;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"willEnterForeground"
                                                        object: nil
                                                      userInfo: nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName: @"didEnterBackground"
                                                        object: nil
                                                      userInfo: nil];
}

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
    self.accessToken = accessToken;
    
    [data writeToFile:path atomically:YES];
}

- (NSString *) readAccessToken{
    
    if (!self.accessToken){
        NSString *path = [self getPathForDataStorage];
        
        NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        
        //load from savedStock example int value
        self.accessToken = [savedStock objectForKey:@"accessToken"];
    }
        
    return self.accessToken;
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

# pragma mark get fousquare client

- (BZFoursquare *) getFoursquareClient {
    BZFoursquare *foursquare = [[BZFoursquare alloc] initWithClientID:@"W2XHXBWO2BSTSDJI1QPCZVIYBQFJJDOQUFLKW5TLLN4GRHRM" callbackURL:@"geochat://foursquare"];
    foursquare.version = @"20111119";
    foursquare.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    foursquare.accessToken = self.accessToken;
    return foursquare;
}

@end
