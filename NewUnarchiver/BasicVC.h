//
//  BasicVC.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 16.07.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "NavBar.h"
#import "ToolBar.h"
#import "ModalView.h"
#import "StoreKitBindingiOS.h"

@class PreviewVC;
@interface BasicVC : UIViewController <ToolBarBtnDelegate, NavBarDelegate, ModalViewDelegate, StoreKitBindingDelegate>
{
    AppDelegate * appDelegate;
    
    NavBar * navBar;
    ToolBar * toolBar;
    
    bool isPreviewShownOnPhone;
    UIView * contentView;
    
    UIImageView * imgViewTop, * imgViewBottom;
@private
    
    
    
    NavBarStyle _navBarStyle;
    bool _needToolbar;
    
    PreviewVC * _previewOnPhone;
}

@property (nonatomic, retain) ModalView * purchaseDropboxModalView;
@property (nonatomic, assign) bool isMaster;

- (id)initWithNavBarStyle:(NavBarStyle)navBarStyle toolbar:(bool)toolbar;
- (void) setImageBorder:(UIImage *) img;

- (bool) canPreviewFile;
- (void) enablePreviewOnPhone;
- (void) disablePreviewOnPhone;
- (void) showPreviewOnPhone;
- (void) hidePreviewOnPhone;

//FREE VERSION
- (bool) isDropboxPurchased;
@end
