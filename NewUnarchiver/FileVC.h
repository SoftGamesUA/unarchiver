//
//  FileVC.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 11.02.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "FileObject.h"

#import "BasicVC.h"
#import "PopoverContent.h"
#import "ModalView.h"
#import "Unarchiver.h"
#import "ClipboardManager.h"

#import "MessageUI/MessageUI.h"
#import "MessageUI/MFMailComposeViewController.h"

@interface FileVC : BasicVC <ModalViewDelegate, UIDocumentInteractionControllerDelegate, UITableViewDataSource, UITableViewDelegate,  UIImagePickerControllerDelegate, PopoverContentDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UnarchiverDelegate, MFMailComposeViewControllerDelegate, ClipboardDestinationDelegate, ClipboardSourceDelegate>
{
    
@private
    Unarchiver * _unarchiver;
    
    UITableView * _tableView;
    UIView * _emptyFolderView, * _addFilesBtnsView;
    UILabel * _freeSpaceLabel, * _emptyFolderLabel;
    
    NSMutableSet * _selectedFiles;
    
    PopoverContent * _popoverContentDelete, * _popoverContentAdd, * _popoverContentCCP, * _popoverContentBreadcrumbs, * _popoverContentShare, * _popoverContentArchive;
    
    //перетягивание
    NSMutableSet * _cellsToMove;
    CGPoint _previousMoveLocation;
    
    //хлебные крошки
    NSMutableArray * _breadcrumbs;
    UIScrollView * _breadcrumbsScroll;
    UIControl * _hideBreadcrumbsCtrl;
}

@property (nonatomic, retain) FileObject * currentFolder;
@property (nonatomic, retain) FileObject * rootFolder;
@property (nonatomic, retain) NSArray * currentFileList;

- (void) reloadFiles;
- (void) finishPaste:(bool)success;
- (void) doneAction:(bool)folderModify;
- (bool) isFileNameInCurrentFolder:(NSString *)name;

//dropbox & box.net call methods after loading files to cache
- (void) open:(FileObject *)file cellRect:(CGRect)cellRect;
- (void) saveToCameraRoll:(FileObject *)file;
- (void) preview:(FileObject *)file;
- (void) sendMail:(NSSet *)files;

//"virtual" methods
- (NSArray *) filesFromCurrentFolder;
- (long long) freeSpace;
- (bool) canWorkWithArchives;
- (id) clipboardUserInfo;
- (FileSource) fileSource;
- (void) remove:(FileObject *)file;
- (void) paste:(FileObject *)file overWrite:(bool)overWrite;
- (void) rename:(FileObject *)file newName:(NSString *)newName;
- (void) newFolder:(NSString *)name;
- (void) newFile:(NSString *)name content:(NSData*)content;

@end    
