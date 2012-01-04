//
//  GetAllPosts.h
//  PinboardReader
//
//  Created by Matt on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

@interface GetAllPosts : NSObject
{
    NSMutableArray *allPosts;
    Post *post;
}

@property (nonatomic, retain) NSMutableArray *allPosts;
@property (nonatomic, retain) Post *post;

-(BOOL)getAllPostsForUser;

@end
