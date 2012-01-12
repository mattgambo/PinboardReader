//
//  GetAllPosts.h
//  PinboardReader
//
//  Created by Matt on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Post.h"
#import "Command.h"

@protocol GetAllPostsDelegate <CommandDelegate>

-(void)didGetAllPosts:(NSMutableArray*)allPosts;

@end

@interface GetAllPosts : Command
{
    @private
    id<GetAllPostsDelegate>getAllPostsDelegate;
    
    NSMutableArray *allPosts;
    Post *post;
}

@property (assign) id<GetAllPostsDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *allPosts;
@property (nonatomic, retain) Post *post;

-(BOOL)getAllPostsForUser;

@end
