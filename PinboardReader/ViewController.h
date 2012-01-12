//
//  ViewController.h
//  PinboardReader
//
//  Created by Matt on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetAllPosts.h"

@interface ViewController : UIViewController <GetAllPostsDelegate>
{
    GetAllPosts *cmd;
    IBOutlet UILabel *label;
}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) GetAllPosts *cmd;

-(IBAction)execGetAllPosts;

@end
