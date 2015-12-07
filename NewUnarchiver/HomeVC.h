//
//  HomeVC.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 03.03.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasicVC.h"

//#import "ModalView.h"

@interface HomeVC : BasicVC <UITableViewDataSource, UITableViewDelegate>
{
    UITableView * _tableView;
    
    int xFolderPassword;
}

@end
