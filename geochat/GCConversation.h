//
//  Conversation.h
//  geochat
//
//  Created by Adrian Gzz on 05/02/13.
//  Copyright (c) 2013 Adrian Gzz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCConversation : NSObject

@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) NSString *draft;

-(id)initWithPlaceId:(NSString *)place_id;

@end
