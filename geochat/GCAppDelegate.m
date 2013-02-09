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
#import <SDWebImage/UIImageView+WebCache.h>

@interface GCAppDelegate()

@end

@implementation GCAppDelegate

@synthesize accessToken = _accessToken;
@synthesize name = _name;
@synthesize photo = _photo;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [NUIAppearance init];
    GCPlacesViewController *placesViewController = [[GCPlacesViewController alloc] init];
    
    self.navigationController = [[GCNavigationController alloc] initWithRootViewController:placesViewController];
    
    [self initializeVariables];
    
    NSLog(@"%@ %@ %@", self.accessToken, self.name, self.photo);
    
    if (self.accessToken) {
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

-(void)logout{
    [self saveValue:@"" withKey:@"accessToken"];
    
    self.loginViewController = [[GCLoginViewController alloc] initWithNibName:@"GCLoginViewController" bundle:nil];

    [UIView transitionWithView:self.window duration:0.5 options: UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.window.rootViewController = self.loginViewController;
    } completion:nil];
}

# pragma mark application opened with urlscheme
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    GCLoginViewController *loginViewController= (GCLoginViewController *) self.window.rootViewController;
    BZFoursquare *foursquare = loginViewController.foursquare_api;
    return [foursquare handleOpenURL:url];
}

# pragma mark store and read data from data.plist

-(void) saveValue:(NSString *)value withKey:(NSString *)key{
    NSString *path = [self getPathForDataStorage];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    [data setObject:value forKey:key];
    [data writeToFile:path atomically:YES];
    
    if ([key isEqualToString:@"accessToken"]) {
        self.accessToken = value;
    } else if ([key isEqualToString:@"photo"]) {
        self.photo = value;
    } else if ([key isEqualToString:@"name"]){
        self.name = value;
    }
}

- (void) initializeVariables{
    
    NSString *path = [self getPathForDataStorage];
    
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    //load from savedStock example int value
    self.accessToken = [savedStock objectForKey:@"accessToken"];
    if ([self.accessToken isEqualToString:@""]) {
        self.accessToken = nil;
    }
    
    self.name = [savedStock objectForKey:@"name"];
    
    NSString *phot_url = [savedStock objectForKey:@"photo"];
    NSLog(@"%@", phot_url);
    
    self.photo = [savedStock objectForKey:@"photo"];
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
