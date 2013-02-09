//
//  main.m
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GCAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        // Or use this call to use a specific stylesheet
        [NUISettings initWithStylesheet:@"SkyBlue"];
        
        // If you uncomment this and set the path to your .nss file, you can modify your .nss
        // file at runtime
//        [NUISettings setAutoUpdatePath:@"/Users/adrian/Desktop/geochat/Resources/Blue.NUI"];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([GCAppDelegate class]));
    }
}
