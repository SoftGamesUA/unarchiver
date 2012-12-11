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
//#import "StoreKitBindingiOS.h"

@interface HomeVC : BasicVC <UITableViewDataSource, UITableViewDelegate/*, ModalViewDelegate, StoreKitBindingDelegate*/>
{
    UITableView * _tableView;
    
    int xFolderPassword;
}

@end
