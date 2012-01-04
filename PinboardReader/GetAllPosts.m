//
//  GetAllPosts.m
//  PinboardReader
//
//  Created by Matt on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GetAllPosts.h"
#import "Constants.h"

@implementation GetAllPosts

@synthesize allPosts, post;

-(BOOL)getAllPostsForUser
{
    NSString *command = [NSString stringWithFormat:GET_ALL_POSTS];
}

@end
