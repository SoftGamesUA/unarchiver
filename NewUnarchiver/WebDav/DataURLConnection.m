//
//  DataURLConnection.m
//  NewUnarchiver
//
//  Created by Zhenya Koval on 02.11.12.
//  Copyright (c) 2012 Zhenya Koval. All rights reserved.
//

#import "DataURLConnection.h"

@implementation DataURLConnection

@synthesize data = _data, type = _type, userInfo = _userInfo, successCode = _successCode;
@synthesize failSelector, successSelector;

- (void) dealloc
{
    self.data = nil;
    self.userInfo = nil;
    
    [super dealloc];
}

@end
