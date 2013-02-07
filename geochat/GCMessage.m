//
//  GCMessage.m
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import "GCMessage.h"

@implementation GCMessage

@synthesize message = _message;
@synthesize user = _user;
@synthesize created_at = _created_at;

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    
    if (self) {
        self.message = dictionary[@"message"];
        self.user = dictionary[@"user"];
        self.created_at = [self dateFromString:dictionary[@"created_at"]];
    }
    return self;
}

-(id)initWithMessage:(NSString *)message user:(NSString *)user{
    self = [super init];
    
    if (self) {
        self.message = message;
        self.user = user;
        self.created_at = [NSDate date];
    }
    return self;
    
}

-(NSDictionary *)toDictionary{
    return @{@"user": self.user, @"message": self.message };
}

-(NSDate *)dateFromString:(NSString *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] ];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];

    return [dateFormatter dateFromString:date];

}


@end
