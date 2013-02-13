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
    
    [NUIRenderer renderLabel:self.message];
    [NUIRenderer renderLabel:self.date];
    [NUIRenderer renderLabel:self.user];
    
    self.message.font = [UIFont fontWithName:self.message.font.fontName size:14.0f];
    self.date.font = [UIFont fontWithName:self.date.font.fontName size:11.0f];
    self.user.font = [UIFont fontWithName:self.user.font.fontName size:11.0f];
    
}

-(CGFloat)getHeight{
    CGSize constraint = CGSizeMake(self.frame.size.width, 2000.f);
    CGSize size = [self.message.text sizeWithFont:self.message.font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = size.height;
    
    return height + self.date.frame.size.height + 18;
}

@end
