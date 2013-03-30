//
//  GCNavigationController.m
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import "GCNavigationController.h"

@interface GCNavigationController ()

@end

@implementation GCNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // someplace where you create the UINavigationController
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINavigationBar *navBar = [[UINavigationBar alloc] init];
    UIImage *image = [UIImage imageNamed:@"MessageInputBarBackground.png"];
    [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
