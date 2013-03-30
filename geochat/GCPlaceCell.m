//
//  GCPlaceCell.m
//  geochat
//
//  Created by Adrian Gzz on 12/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import "GCPlaceCell.h"
#import "NSString+FontAwesome.h"
#import <QuartzCore/QuartzCore.h>

@interface GCPlaceCell()
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *usersLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation GCPlaceCell

@synthesize name = _name;
@synthesize distance = _distance;
@synthesize users = _users;
@synthesize image = _image;
@synthesize usersLabel = _usersLabel;
@synthesize distanceLabel = _distanceLabel;
@synthesize backgroundView = _backgroundView_;

-(void) layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor colorWithRed:215/255.0f green:215/255.0f blue:215/255.0f alpha:1.0f];
    
    // Add a bottomBorder.
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.backgroundView.frame.origin.y + self.backgroundView.frame.size.height - 4, self.backgroundView.frame.size.width, 2.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:109/255.0f green:109/255.0f blue:109/255.0f alpha:1.0f].CGColor;
    [self.backgroundView.layer addSublayer:bottomBorder];
    
    self.backgroundView.layer.cornerRadius = 2;
    self.backgroundView.layer.masksToBounds = YES;
}

-(void) setUsers:(NSNumber *)users{
    _users = users;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[self fontawesomeAttibutedStringWithIcon:@"icon-user" string:[NSString stringWithFormat:@"%@", _users]]];
    
    if ([_users compare:@0] == NSOrderedDescending) {
        UIColor *color = [UIColor colorWithRed:0/255.0f green:175/255.0f blue:82/255.0f alpha:1.0f];
        [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [attributedString.string length])];
        [attributedString addAttribute:NSStrokeColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [attributedString.string length])];
    }
    
    self.usersLabel.attributedText = attributedString;
}

-(void) setDistance:(NSString *)distance{
    _distance = distance;
    self.distanceLabel.text = [NSString stringWithFormat:@"%@m", _distance];
}

-(NSAttributedString *) fontawesomeAttibutedStringWithIcon:(NSString *)icon string:(NSString *)string{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForIconIdentifier:icon], string]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(1, [attributedString.string length] - 1)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontAwesomeFamilyName size:14] range:NSMakeRange(0, 1)];
    return attributedString;
}

@end
