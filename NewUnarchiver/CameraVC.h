//
//  CameraVC.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 16.07.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasicVC.h"
#import "CameraItem.h"
#import "PopoverContent.h"

#import "ClipboardManager.h"

#import "MessageUI/MessageUI.h"
#import "MessageUI/MFMailComposeViewController.h"

@interface CameraVC : BasicVC <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PopoverContentDelegate, UIPopoverControllerDelegate, UIActionSheetDelegate, CameraItemDelegate, MFMailComposeViewControllerDelegate, ClipboardDestinationDelegate, ClipboardSourceDelegate>
{
    NSMutableArray * _items, * _selectedItems, * _assets;
    UIScrollView * _scroll;
    
    UIPopoverController * _popoverControllerImagePicker;
    PopoverContent * _popoverContentCCP;
    
    int _savePhotoCount;
    NSMutableArray * _savePhotoQue;
    
    //перетягивание
    NSMutableArray * _itemsToMove;
    CGPoint _previousMoveLocation;
}

@end
