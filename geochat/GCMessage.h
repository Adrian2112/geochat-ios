//
//  GCMessage.h
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCMessage : NSObject

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSDate *created_at;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
