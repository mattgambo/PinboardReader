//
//  Post.h
//  PinboardReader
//
//  Created by Matt on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject
{
    NSString *title;
    NSString *description;
    NSString *date;
    NSArray *tags;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSArray *tags;

@end
