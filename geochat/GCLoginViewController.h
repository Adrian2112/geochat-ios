//
//  LoginViewController.h
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BZFoursquare.h"

@interface GCLoginViewController : UIViewController <BZFoursquareSessionDelegate>

@property(nonatomic,strong) BZFoursquare *foursquare_api;

@end
