//
//  AppDelegate.h
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCLoginViewController;
@class GCNavigationController;

@interface GCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) GCLoginViewController *loginViewController;
@property (strong, nonatomic) GCNavigationController *navigationController;

@end
