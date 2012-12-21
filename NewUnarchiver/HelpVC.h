//
//  HelpVC.h
//  NewUnarchiver
//
//  Created by Zhenya Koval on 13.12.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicVC.h"
#import "PopoverContent.h"

#import "MessageUI/MessageUI.h"
#import "MessageUI/MFMailComposeViewController.h"

@interface HelpVC : BasicVC <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, PopoverContentDelegate, UIActionSheetDelegate>
{
    UITableView * _tableView;
    PopoverContent * _popoverContentFeedback;
}
@end
