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
@synthesize messageBackground = _messageBackground;

-(void) awakeFromNib{
    self.photo.image = [UIImage imageNamed:@"default_avatar.png"];
}

-(void) layoutSubviews{
    [super layoutSubviews];
    
    CALayer *topLayer = [CALayer layer];
    topLayer.borderColor = [UIColor colorWithRed: 232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0].CGColor;
    topLayer.borderWidth = 1;
    topLayer.frame = CGRectMake(0, 0, self.message.frame.size.width, 1);
    
    [self.message.layer addSublayer:topLayer];
    self.messageBackground.layer.cornerRadius = 8.0;
    self.messageBackground.layer.masksToBounds = YES;
    self.messageBackground.layer.borderColor = [UIColor colorWithRed: 235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0].CGColor;
    self.messageBackground.layer.borderWidth = 1;
    
    self.message.font = [UIFont fontWithName:self.message.font.fontName size:14.0f];
    self.date.font = [UIFont fontWithName:self.date.font.fontName size:10.0f];
    self.user.font = [UIFont fontWithName:self.user.font.fontName size:10.0f];
    
    self.photo.layer.cornerRadius = 3.0;
    self.photo.layer.masksToBounds = YES;
    
}

-(CGFloat)getHeight{
    CGSize constraint = CGSizeMake(self.frame.size.width, 2000.f);
    CGSize size = [self.message.text sizeWithFont:self.message.font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = size.height;
    
    return height + self.date.frame.size.height + 35;
}

@end
