//
//  AppDelegate.h
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//
#define GC_APP_DELEGATE() ((GCAppDelegate *)[[UIApplication sharedApplication] delegate])

#define TEST 0

# if TEST == 1
#define HOST @"localhost"
#define PORT 3000
#define FULL_HOST @"localhost:3000"

# else
#define HOST @"geochatios.jit.su"
#define PORT 80
#define FULL_HOST @"geochatios.jit.su"

# endif

#import <UIKit/UIKit.h>
#import "NUIAppearance.h"

@class GCLoginViewController;
@class GCNavigationController;
@class BZFoursquare;

@interface GCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) GCLoginViewController *loginViewController;
@property (strong, nonatomic) GCNavigationController *navigationController;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *photo;

-(void) saveValue:(NSString *)value withKey:(NSString *)key;
-(BZFoursquare *) getFoursquareClient;
-(void) logout;

@end
