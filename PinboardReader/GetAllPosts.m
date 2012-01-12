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
@synthesize delegate = getAllPostsDelegte;

-(BOOL)getAllPostsForUser
{
    NSString *command = [NSString stringWithFormat:GET_ALL_POSTS];
    return [super send:command withMethod:@"GET" withCommandString:@""];
}

-(void)parseElement:(NSString *)elementName elementValue:(NSMutableString *)elementValue
{
    NSString *strVal = [elementValue copy];
    
    if ([elementName isEqualToString:@"href"])
    {
        post = [[Post alloc] init];
        [self.allPosts addObject:post];
        self.post.link = strVal;
    }
    else if ([elementName isEqualToString:@"description"])
    {
        post = [self.allPosts lastObject];
        self.post.description = strVal;
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self.delegate didGetAllPosts:allPosts];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
