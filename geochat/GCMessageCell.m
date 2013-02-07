//
//  GCMessageCell.m
//  geochat
//
//  Created by Adrian Gzz on 07/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import "GCMessageCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation GCMessageCell

@synthesize photo = _photo;
@synthesize message = _message;
@synthesize date = _date;
@synthesize user = _user;

-(void) awakeFromNib{
    self.photo.image = [UIImage imageNamed:@"default_avatar.png"];
}

-(void) layoutSubviews{
    [super layoutSubviews];
    
    self.message.font = [UIFont systemFontOfSize:14.0f];
    self.date.font = [UIFont systemFontOfSize:11.0f];
    self.user.font = [UIFont boldSystemFontOfSize:11.0f];
    
}

-(CGFloat)getHeight{
    CGSize constraint = CGSizeMake(self.frame.size.width, 2000.f);
    CGSize size = [self.message.text sizeWithFont:self.message.font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = size.height;
    
    return height + self.date.frame.size.height + 16;
}

@end
