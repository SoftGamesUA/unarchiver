//
//  QuickMessage.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 06.11.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickMessage : UIView
{
    UILabel * _label;
}
- (void)showWithText:(NSString *) text;

@end
