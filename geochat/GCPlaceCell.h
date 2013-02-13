//
//  GCPlaceCell.h
//  geochat
//
//  Created by Adrian Gzz on 12/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabel+NUI.h"

@interface GCPlaceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) NSNumber *users;
@property (weak, nonatomic) NSString *distance;

@end
