//
//  GCMessageCell.h
//  geochat
//
//  Created by Adrian Gzz on 07/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabel+NUI.h"

@interface GCMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UILabel *user;

-(CGFloat)getHeight;

@end
