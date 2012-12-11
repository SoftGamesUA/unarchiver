//
//  ArchiveVC.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 14.03.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasicVC.h"

@interface ArchiveVC : BasicVC <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray * _files;
    UITableView * _tableView;
    UILabel *_helpLabel;
    UIButton * _btnCreate, * _btnCreateWithPassword, * _btnCancel;
}

@end
