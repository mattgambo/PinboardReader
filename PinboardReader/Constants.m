//
//  Constants.m
//  PinboardReader
//
//  Created by Matt on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString* const SERVICE_ENDPOINT = @"https://mattgambo:spyfry2@api.pinboard.in/v1/%@";
NSTimeInterval	const SERVICE_TIMEOUT = 15.0;
NSString* const GET_ALL_POSTS = @"posts/all";
NSString* const GET_ALL_TAGS = @"tags/get";
NSString* const GET_POSTS_BY_TAG = @"posts/get?tag=%@";

@end
