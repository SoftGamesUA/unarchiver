//
//  HelpVC.h
//  NewUnarchiver
//
//  Created by Zhenya Koval on 13.12.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicVC.h"

@interface HelpVC : BasicVC <UITableViewDataSource, UITableViewDelegate>
{
    UITableView * _tableView;
}
@end
