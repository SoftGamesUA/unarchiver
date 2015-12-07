//
//  FileVC.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 11.02.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "FileVC.h"

#import "PopoverBgViews.h"
#import "FileCell.h"
#import "ODRefreshControl.h"
#import "HelpVC.h"

static NSString * passwordMissionKey = @"passwordMission";

enum
{
    PASSWORD_ZIP,
    PASSWORD_UNZIP,
};

@interface FileVC ()

@property (nonatomic, retain) UIPopoverController * popoverControllerDelete;
@property (nonatomic, retain) UIPopoverController * popoverControllerAdd;
@property (nonatomic, retain) UIPopoverController * popoverControllerCCP;
@property (nonatomic, retain) UIPopoverController * popoverControllerBreadcrumbs;
@property (nonatomic, retain) UIPopoverController * popoverControllerShare;
@property (nonatomic, retain) UIPopoverController * popoverControllerArchive;
@property (nonatomic, retain) UIPopoverController * popoverControllerImagePicker;

@property (nonatomic, retain) UIActionSheet * actionSheetDelete;
@property (nonatomic, retain) UIActionSheet * actionSheetAdd;
@property (nonatomic, retain) UIActionSheet * actionSheetCCP;
@property (nonatomic, retain) UIActionSheet * actionSheetShare;
@property (nonatomic, retain) UIActionSheet * actionSheetArchive;

@property (nonatomic, retain) ModalView * renameModalView;
@property (nonatomic, retain) ModalView * passwordModalView;
@property (nonatomic, retain) ModalView * addFileModalView;
@property (nonatomic, retain) ModalView * pasteQuestionModalView;

@property (nonatomic, assign) int progressActionCounter;

@end

@implementation FileVC

#pragma mark - init

- (void) initTable
{
    UIImageView * bgView = [[UIImageView alloc] initWithFrame:contentView.bounds];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIImage * bgImg = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"tableBg" ofType:@"png"]];
    bgView.image = bgImg;
    [contentView addSubview:bgView];
    [bgView release];
    [bgImg release];
    
    CGRect tableFrame = contentView.bounds;
    tableFrame.size.height -= (cellHeight / 1.5);
    _tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.allowsMultipleSelection = true;
    _tableView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:_tableView];
    
    ODRefreshControl * refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [refreshControl release];
    
    tableFrame.origin.y = tableFrame.origin.y + tableFrame.size.height;
    tableFrame.size.height = (cellHeight / 1.5);
    _freeSpaceLabel = [[UILabel alloc] initWithFrame:tableFrame];
    _freeSpaceLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _freeSpaceLabel.backgroundColor = [UIColor clearColor];
    _freeSpaceLabel.textAlignment = UITextAlignmentCenter;
    [contentView addSubview:_freeSpaceLabel];
}

- (void)initAddFilesBtnsView
{
    int gap = 5;
    UIImage * btnBg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"newBtnBg" ofType:@"png"]];
    UIImage * btnBgPush = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"newBtnBgPush" ofType:@"png"]];
    
    CGRect btnFrame = CGRectZero;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)   btnFrame = CGRectMake(0, 0, btnBg.size.width, btnBg.size.height);
    else btnFrame = CGRectMake(0, 0, btnBg.size.width / 1.5, btnBg.size.height / 1.5);
    
    UIButton * newDocBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [newDocBtn addTarget:self action:@selector(newDocBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImage * newDocBtnImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"txtIcon" ofType:@"png"]];
    UIImage * newDocBtnImagePush = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"txtIconPush" ofType:@"png"]];
    newDocBtn.frame = btnFrame;
    [newDocBtn setBackgroundImage:btnBg forState:UIControlStateNormal];
    [newDocBtn setBackgroundImage:btnBgPush forState:UIControlStateHighlighted];
    [newDocBtn setImage:newDocBtnImage forState:UIControlStateNormal];
    [newDocBtn setImage:newDocBtnImagePush forState:UIControlStateHighlighted];
    [newDocBtnImage release];
    [newDocBtnImagePush release];
    
    btnFrame.origin.x += btnFrame.size.width + gap;
    UIButton * newImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [newImgBtn addTarget:self action:@selector(newImgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImage * newImgBtnImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"imageIcon" ofType:@"png"]];
    UIImage * newImgBtnImagePush = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"imageIconPush" ofType:@"png"]];
    newImgBtn.frame = btnFrame;
    [newImgBtn setBackgroundImage:btnBg forState:UIControlStateNormal];
    [newImgBtn setBackgroundImage:btnBgPush forState:UIControlStateHighlighted];
    [newImgBtn setImage:newImgBtnImage forState:UIControlStateNormal];
    [newImgBtn setImage:newImgBtnImagePush forState:UIControlStateHighlighted];
    [newImgBtnImage release];
    [newImgBtnImagePush release];
    
    btnFrame.origin.x += btnFrame.size.width + gap;
    UIButton * newPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [newPhotoBtn addTarget:self action:@selector(newPhotoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImage * newPhotoBtnImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photoIcon" ofType:@"png"]];
    UIImage * newPhotoBtnImagePush = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photoIconPush" ofType:@"png"]];
    newPhotoBtn.frame = btnFrame;
    [newPhotoBtn setBackgroundImage:btnBg forState:UIControlStateNormal];
    [newPhotoBtn setBackgroundImage:btnBgPush forState:UIControlStateHighlighted];
    [newPhotoBtn setImage:newPhotoBtnImage forState:UIControlStateNormal];
    [newPhotoBtn setImage:newPhotoBtnImagePush forState:UIControlStateHighlighted];
    [newPhotoBtnImage release];
    [newPhotoBtnImagePush release];
    
    /*btnFrame.origin.x += btnFrame.size.width + gap;
    UIButton *newVoiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [newVoiceBtn addTarget:self action:@selector(newVoiceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImage * newVoiceBtnImage = [UIImage imageNamed:@"voiceIcon"];
    UIImage * newVoiceBtnImagePush = [UIImage imageNamed:@"voiceIconPush"];
    [newVoiceBtn setBackgroundImage:btnBg forState:UIControlStateNormal];
    newVoiceBtn.frame = btnFrame;
    [newVoiceBtn setBackgroundImage:btnBgPush forState:UIControlStateHighlighted];
    [newVoiceBtn setImage:newVoiceBtnImage forState:UIControlStateNormal];
    [newVoiceBtn setImage:newVoiceBtnImagePush forState:UIControlStateHighlighted];*/
    
    CGRect newBtnsFrame;
    newBtnsFrame.size.height = btnFrame.size.height;
    newBtnsFrame.size.width = 3 * btnFrame.size.width + gap * 2;
    _addFilesBtnsView = [[UIView alloc] initWithFrame:newBtnsFrame];
    [_addFilesBtnsView addSubview:newDocBtn];
    [_addFilesBtnsView addSubview:newPhotoBtn];
    [_addFilesBtnsView addSubview:newImgBtn];
    //[_addFilesBtnsView addSubview:newVoiceBtn];
    
    [btnBg release];
    [btnBgPush release];
}

- (void) initEmptyFolderView
{
    [_emptyFolderView removeFromSuperview];
    [_emptyFolderView release];
    _emptyFolderView = [[UIScrollView alloc] initWithFrame:_tableView.frame];
    _emptyFolderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    /*_emptyFolderView.contentInset = UIEdgeInsetsMake(1, 0, 1, 0);
    _emptyFolderView.contentSize = _emptyFolderView.frame.size;
    ODRefreshControl * refreshControl = [[ODRefreshControl alloc] initInScrollView:_emptyFolderView];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [refreshControl release];*/
    
    UIImage * img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"folderBgImage" ofType:@"png"]];
    UIImageView *folderImageView = [[UIImageView alloc] initWithImage:img];
    [img release];
    
    CGRect folderImageFrame = CGRectZero;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        folderImageFrame.size = CGSizeMake(200, 200);
        folderImageFrame.origin = CGPointMake(_emptyFolderView.frame.size.width / 2 - folderImageFrame.size.width / 2, 200);
            
        folderImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    else
    {
        folderImageFrame.size = CGSizeMake(100, 100);
        folderImageFrame.origin.x = _emptyFolderView.frame.size.width / 2 - folderImageFrame.size.width / 2;
        folderImageFrame.origin.y = _emptyFolderView.frame.size.height / 5;
            
        folderImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
        
    folderImageView.frame = folderImageFrame;
    folderImageView.contentMode = UIViewContentModeScaleToFill;
    [_emptyFolderView addSubview:folderImageView];
        
    CGRect labelFrame = CGRectZero;
    labelFrame.origin = CGPointMake(10, 0);
    labelFrame.size = CGSizeMake(folderImageFrame.size.width - 20, folderImageFrame.size.height);
    [_emptyFolderLabel release];
    _emptyFolderLabel = [[UILabel alloc] initWithFrame:labelFrame];
    _emptyFolderLabel.backgroundColor = [UIColor clearColor];
    _emptyFolderLabel.textColor = [UIColor whiteColor];
    _emptyFolderLabel.textAlignment = UITextAlignmentCenter;
    _emptyFolderLabel.adjustsFontSizeToFitWidth = true;
    [folderImageView addSubview:_emptyFolderLabel];
    [folderImageView release];
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        labelFrame.origin = CGPointMake(0, folderImageFrame.origin.y + folderImageFrame.size.height + 50);
    }
    else
    {
        labelFrame.origin = CGPointMake(0, (_emptyFolderView.frame.size.height / 3) * 2);
    }
    labelFrame.size = CGSizeMake(_emptyFolderView.frame.size.width, 30);
    UILabel * subLabel = [[UILabel alloc] initWithFrame:labelFrame];
    subLabel.backgroundColor = [UIColor clearColor];
    subLabel.text = NSLocalizedString(@"No files. Add new", nil);
    subLabel.textAlignment = UITextAlignmentCenter;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        subLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    else
    {
        subLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    [_emptyFolderView addSubview:subLabel];
    [subLabel release];
            
    if (!_addFilesBtnsView)  [self initAddFilesBtnsView];
    CGRect newBtnsFrame = _addFilesBtnsView.frame;
    newBtnsFrame.origin.x = _emptyFolderView.frame.size.width / 2 - newBtnsFrame.size.width / 2;
    newBtnsFrame.origin.y = labelFrame.origin.y + labelFrame.size.height + _emptyFolderView.frame.size.height / 20;
        
    _addFilesBtnsView.frame = newBtnsFrame;        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
        _addFilesBtnsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    else
        _addFilesBtnsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleHeight |     UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
    [_emptyFolderView addSubview:_addFilesBtnsView];
    [contentView addSubview:_emptyFolderView];
}

#pragma mark - load & unload

- (id)init
{
    self = [super initWithNavBarStyle:NavBarStyleFolder toolbar:true];
    if (self) 
    {

    }
    return self;
}

 - (void)viewDidLoad
 {
     [super viewDidLoad];
     
     self.navigationController.navigationBarHidden = true;
     
     _unarchiver = [[Unarchiver alloc] init];
     _unarchiver.delegate = self;
     
     [self initTable];
     [toolBar setEnabled:true forBtn:ToolBarBtnAdd];
     [toolBar setEnabled:true forBtn:ToolBarBtnHelp];
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
     {
         [navBar setCustomButtonType:NavBarCustomButtonTypePreview];
     }
     
     _breadcrumbs = [[NSMutableArray alloc] init];
     _selectedFiles = [[NSMutableSet alloc] init];
     _cellsToMove = [[NSMutableSet alloc] init];
     
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
     {
         UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]	initWithTarget:self action:@selector(handlePanGesture:)];
         [self.view addGestureRecognizer:panGesture];
         [panGesture release];
     }
     
     UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]	initWithTarget:self action:@selector(handleTapGesture:)];
     tapGesture.cancelsTouchesInView = false;
     [self.view addGestureRecognizer:tapGesture];
     [tapGesture release];
     
     self.progressActionCounter = 0;
     
     _currentFolder = [self.rootFolder retain];
     [_breadcrumbs addObject:self.currentFolder];
     [self updateNavBar];
}

- (void)viewDidUnload
{
    [self cleanFileVC];

    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self removeObserversInFileVC];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipBoardChangeNotification:) name:clipboardDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(folderChangeNotification:) name:FOLDER_DID_CHANGE_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dragFilesNotification:) name:DRAG_FILES_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyNotification:) name:COPY_NOTIFICATION object:nil];
        
        if ([self canWorkWithArchives])
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zipNotification:) name:ZIP_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unZipNotification:) name:UNZIP_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unRarNotification:) name:UNRAR_NOTIFICATION object:nil];
        }
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self removeObserversInFileVC];
}

- (void) removeObserversInFileVC
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:clipboardDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FOLDER_DID_CHANGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DRAG_FILES_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:COPY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ZIP_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UNZIP_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UNRAR_NOTIFICATION object:nil];
}

- (void) cleanFileVC
{
    [self removeObserversInFileVC];
    
    [_tableView release];
    [_popoverContentAdd release];
    [_popoverContentCCP release];
    [_popoverContentDelete release];
    [_popoverContentBreadcrumbs release];
    [_selectedFiles release];
    [_emptyFolderView release];
    [_emptyFolderLabel release];
    [_addFilesBtnsView release];
    [_cellsToMove release];
    [_breadcrumbsScroll release];
    [_hideBreadcrumbsCtrl release];
    [_breadcrumbs release];
    [_unarchiver release];
    
    self.currentFileList = nil;
    self.rootFolder = nil;
    self.currentFolder = nil;
    self.popoverControllerAdd = nil;
    self.popoverControllerCCP = nil;
    self.popoverControllerDelete = nil;
    self.popoverControllerShare = nil;
    self.popoverControllerBreadcrumbs = nil;
    self.popoverControllerArchive = nil;
    self.popoverControllerImagePicker = nil;
    self.actionSheetAdd = nil;
    self.actionSheetCCP = nil;
    self.actionSheetArchive = nil;
    self.actionSheetDelete = nil;
    self.actionSheetShare = nil;
    self.renameModalView = nil;
    self.passwordModalView = nil;
    self.pasteQuestionModalView = nil;
    self.addFileModalView = nil;
}

- (void) dealloc
{
    [self cleanFileVC];
    
    [super dealloc];
}

#pragma mark -
#pragma mark files

- (NSString *) duplicateName:(NSString *)name copy:(bool)copy
{   
    if (copy)
    {
        name = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Copy of File", nil), name];
        if (![self isFileNameInCurrentFolder:name])
        {
            return name;
        }
    }
    
    NSString * extension = [name pathExtension];
    name = [name stringByDeletingPathExtension];
    
    for (int i = 1; i < 100; i++)
    {
        NSString * newName = [NSString stringWithFormat:@"%@ %i", name, i];
        if (![extension isEqualToString:@""])
        {
            newName = [newName stringByAppendingPathExtension:extension];
        }
        
        if (![self isFileNameInCurrentFolder:newName])
        {
            return newName;
        }
    }
    
    return name;
}

- (bool) isFileNameInCurrentFolder:(NSString *)name
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayName == %@", name];
    NSArray * array = [self.currentFileList filteredArrayUsingPredicate:predicate];
    
    return ([array count] > 0);
}

- (NSString *)stringFromFileSize:(long long )size
{
	if (size < 1023)
    {
        return([NSString stringWithFormat:@"%lli bytes", size]);
    }
	double dSize = size / 1024;
	if (dSize < 1023)
    {
        return([NSString stringWithFormat:@"%.2lf KB", dSize]);
	}
    dSize = dSize / 1024;
	if (dSize < 1023)
    {
        return([NSString stringWithFormat:@"%.2lf MB", dSize]);
    }
	dSize = dSize / 1024;
	
	return([NSString stringWithFormat:@"%.2lf GB", dSize]);
}

- (void) reloadFiles
{
    self.currentFileList = [self filesFromCurrentFolderWithProgress];
    if (self.currentFileList == nil)
    {
        return;
    }
    
    [self updateNavBar];
    [appDelegate hideProgressHUD];
    
    [_selectedFiles removeAllObjects];
    [self selectedFilesDidModify];
    
    if ([self.currentFileList count])
    {
        _emptyFolderView.hidden = true;
        _tableView.hidden = false;
        [_tableView reloadData];
    }
    else
    {
        [self initEmptyFolderView];
        _emptyFolderLabel.text = self.currentFolder.displayName;
        _tableView.hidden = true;
        _emptyFolderView.hidden = false;
    }
    
    _freeSpaceLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Free", nil), [self stringFromFileSize:[self freeSpace]]];
}

- (void) updateNavBar
{
    [navBar setLabelText:self.currentFolder.displayName];
    
    NSString * breadcrumbsPath = @"";
    for (FileObject * file in _breadcrumbs)
    {
        breadcrumbsPath = [breadcrumbsPath stringByAppendingPathComponent:file.displayName];
    }
    [navBar setSubLabelText:breadcrumbsPath];
}

- (UIImage *) iconForFile:(FileObject *)file
{
    NSString * extFile = [[file.displayName pathExtension] lowercaseString];
    if ([extFile length] == 0)
    {
        return [UIImage imageNamed:@"defaultIcon"];
    }
    
    UIImage * icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@Icon", extFile]];
    if (icon)
    {
        return icon;
    }
    
    return [UIImage imageNamed:@"defaultIcon"];
}

- (void)copySelectedFilesToClipboard
{
    [[ClipboardManager sharedManager] copyFiles:_selectedFiles source:[self fileSource] sourceFolder:self.currentFolder];
    [ClipboardManager sharedManager].userInfo = [self clipboardUserInfo];
    [ClipboardManager sharedManager].sourceDelegate = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:COPY_NOTIFICATION object:self];
}

- (void)cutSelectedFilesToClipboard
{
    [[ClipboardManager sharedManager] cutFiles:_selectedFiles source:[self fileSource] sourceFolder:self.currentFolder];
    [ClipboardManager sharedManager].userInfo = [self clipboardUserInfo];
    [ClipboardManager sharedManager].sourceDelegate = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:COPY_NOTIFICATION object:self];
}

- (void) prepareToPasteFromClipBoard
{
    @autoreleasepool
    {
        bool pasteToSource = [[ClipboardManager sharedManager].sourceFolder isEqual:self.currentFolder];
        
        //перемещать в тоже место нельзя
        if ([ClipboardManager sharedManager].mode == ClipboardModeCut && pasteToSource) return; 
        
        // проверка наличия конфликтов при вставке файлов
        NSMutableSet * existedFiles = [[NSMutableSet alloc] init];
        for (FileObject * file in [ClipboardManager sharedManager].files)
        {
            NSString * newName = file.displayName;
            if ([self isFileNameInCurrentFolder:newName])
            {
                if (pasteToSource)
                {
                    newName = [self duplicateName:newName copy:true];
                }
                else
                {
                    [existedFiles addObject:file];
                }
            }
            file.pasteName = newName;
        }
 
        //если файлы уже есть, задаем вопрос
        if ([existedFiles count] > 0)
        {
            self.pasteQuestionModalView.textView.text = @"";
            for (FileObject * file in existedFiles)
            {
                NSString * newString = [NSString stringWithFormat:@"%@\n", file.displayName];
                self.pasteQuestionModalView.textView.text = [self.pasteQuestionModalView.textView.text stringByAppendingString:newString];
            }
            self.pasteQuestionModalView.userInfo = existedFiles;
            [self.pasteQuestionModalView show];
        } 
        else
        {
            [self pasteFromClipBoardWithProgress:false];
        }
        
        [existedFiles release];
    }
}

- (void) prepareToRename
{
    if ([_selectedFiles count] != 1)
    {
        NSLog(@"FileVC: Couldn't rename: selected files count != 1");
        return;
    }
    
    FileObject * file = [_selectedFiles anyObject];
    self.renameModalView.textFieldDefaultValue = [file.displayName stringByDeletingPathExtension];
    [self.renameModalView show];
}

#pragma mark - call file methods with progress hud

- (NSArray *) filesFromCurrentFolderWithProgress
{
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Loading", nil)];
    
    return [self filesFromCurrentFolder];
}

- (void) deleteSelectedFilesWithProgress
{
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Removing", nil)];
    
    self.progressActionCounter += [_selectedFiles count];

    for (FileObject * file in _selectedFiles)
    {
        [self remove:file];
    }
}

- (void) pasteFromClipBoardWithProgress:(bool)overWrite
{
    if ([[ClipboardManager sharedManager].files count] == 0)
    {
        NSLog(@"FileVC: No files to paste");
        return;
    }
    
    if ([ClipboardManager sharedManager].source != [self fileSource]) [ClipboardManager sharedManager].mode = ClipboardModeCopy;
    if ([ClipboardManager sharedManager].mode == ClipboardModeCopy)
    {
        [appDelegate showProgressHUDWithText:NSLocalizedString(@"Сopying", nil)];
    }
    else if ([ClipboardManager sharedManager].mode == ClipboardModeCut)
    {
        [appDelegate showProgressHUDWithText:NSLocalizedString(@"Moving", nil)];
    }
    
    self.progressActionCounter += [[ClipboardManager sharedManager].files count];
    
    for (FileObject * file in [ClipboardManager sharedManager].files)
    {
        [self paste:file overWrite:overWrite];
    }
}

- (void) renameFileWithProgress:(FileObject *)file newName:(NSString *)newName
{
    self.progressActionCounter ++;
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Renaming", nil)];
    
    [self rename:file newName:newName];
}

- (void) newFolderWithProgress:(NSString *)name
{
    self.progressActionCounter ++;
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Creating", nil)];
    
    [self newFolder:name];
}

- (void) newFileWithProgress:(NSString *)name content:(NSData *)content
{
    self.progressActionCounter ++;
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Creating", nil)];
    
    [self newFile:name content:content];
}

- (void) newDocBtnClick:(UIButton *)sender
{
    if (_addFileModalView && _addFileModalView.isShow)
    {
        [_addFileModalView hide];
    }
    
    NSString * newName = [NSString stringWithFormat:@"%@.txt", NSLocalizedString(@"text", nil)];
    if ([self  isFileNameInCurrentFolder:newName])
    {
        newName = [self duplicateName:newName copy:false];
    }
    
    [self newFileWithProgress:newName content:[@" " dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) newImgBtnClick:(UIButton *)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CGRect frame = [_addFilesBtnsView convertRect:sender.frame toView:self.view];
        self.popoverControllerImagePicker = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [self.popoverControllerImagePicker presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
    }
    else
    {
        [appDelegate.window.rootViewController presentModalViewController:imagePicker animated:true];
    }
    
    [imagePicker release];
}

- (void) newPhotoBtnClick:(UIButton *)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
    
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CGRect frame = [_addFilesBtnsView convertRect:sender.frame toView:self.view];
        self.popoverControllerImagePicker = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [self.popoverControllerImagePicker presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
    }
    else
    {
        [appDelegate.window.rootViewController presentModalViewController:imagePicker animated:true];
    }
    
    [imagePicker release];
}

- (void) newVoiceBtnClick:(UIButton *)sender
{
    if (_addFileModalView && _addFileModalView.isShow) [_addFileModalView hide];
}

- (void) imagePickerController: (UIImagePickerController*) picker didFinishPickingMediaWithInfo: (NSDictionary*) info
{
   	UIImage * img = [info objectForKey:UIImagePickerControllerOriginalImage];
	NSData * imageData = UIImageJPEGRepresentation(img, 0);
    
    NSString * newName;
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera || picker.sourceType ==  UIImagePickerControllerSourceTypeSavedPhotosAlbum)
    {
        newName = [NSString stringWithFormat:@"%@.jpg", NSLocalizedString(@"photo", nil)];
    }
    else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        newName = [NSString stringWithFormat:@"%@.jpg", NSLocalizedString(@"image", nil)];
    }
    
    if ([self  isFileNameInCurrentFolder:newName])
    {
        newName = [self duplicateName:newName copy:false];
    }
    
    [self newFileWithProgress:newName content:imageData];
    
    if (_addFileModalView && _addFileModalView.isShow)
    {
        [_addFileModalView hide];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.popoverControllerImagePicker dismissPopoverAnimated:true];
    }
    else
    {
        [appDelegate.window.rootViewController dismissModalViewControllerAnimated:true];
    }
}

#pragma mark - done action

- (void) doneAction:(bool)folderModify
{
    static bool wasModify = false;
    if (folderModify)
    {
        wasModify = true;
    }
    
    self.progressActionCounter --;
    if (self.progressActionCounter == 0)
    {    
        if (wasModify)
        {
            [self reloadFiles];
        
            NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.currentFolder, FOLDER_KEY, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:FOLDER_DID_CHANGE_NOTIFICATION object:self userInfo:dict];
            [dict release];
            
            wasModify = false;
        }
        else
        {
            [appDelegate hideProgressHUD];
        }
    }
}

- (void) finishPaste:(bool)success
{
    static bool wasSuccess = false;
    if (success)
    {
        wasSuccess = true;
    }

    static bool wasFail = false;
    if (!success)
    {
        wasFail = true;
    }
    
    self.progressActionCounter --;
    if (self.progressActionCounter == 0)
    {
        if (wasFail)
        {
            [appDelegate showQuickMesage:NSLocalizedString(@"Failed to copy some files", nil)];
            wasFail = false;
        }
        
        if (wasSuccess)
        {
            [self reloadFiles];
     
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.currentFolder, FOLDER_KEY, nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:FOLDER_DID_CHANGE_NOTIFICATION object:self userInfo:dict];
                [dict release];
     
                if([ClipboardManager sharedManager].mode == ClipboardModeCut)
                {
                    dict = [[NSDictionary alloc] initWithObjectsAndKeys:[ClipboardManager sharedManager].sourceFolder, FOLDER_KEY, nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:FOLDER_DID_CHANGE_NOTIFICATION object:self userInfo:dict];
                    [dict release];
                }
            }
            if([ClipboardManager sharedManager].mode == ClipboardModeCut)
            {
                [[ClipboardManager sharedManager] clear];
            }
            
            wasSuccess = false;
        }
        else
        {
            [appDelegate hideProgressHUD];
        }
    }
}

#pragma mark - actions with files

- (void) open:(FileObject *)file cellRect:(CGRect)cellRect
{
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Opening", nil)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        UIDocumentInteractionController * interactionController = [UIDocumentInteractionController interactionControllerWithURL:
                                                               [NSURL fileURLWithPath:file.path]];
        interactionController.delegate = self;
        [interactionController retain];
                
        dispatch_async(dispatch_get_main_queue(), ^
        {
            bool success = [interactionController presentOptionsMenuFromRect:cellRect inView:self.view animated:YES];
                                
            if (!success)
            {
                [appDelegate showQuickMesage:NSLocalizedString(@"Could not open file", nil)];
            }
                
            [appDelegate hideProgressHUD];
                
        });
    });
}

- (bool) canSaveToCameraRoll
{
    return ([_selectedFiles count] == 1 && [AppDelegate isImage:[_selectedFiles anyObject]]);
}

- (void) saveToCameraRoll:(FileObject *)file
{
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Saving", nil)];
    
    UIImage * image = [[UIImage alloc] initWithContentsOfFile:file.path];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    [image release];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [appDelegate hideProgressHUD];
    
    if (error)
    {
        [appDelegate showQuickMesage:NSLocalizedString(@"Could not save image", nil)];
    }
    else
    {
        [appDelegate showQuickMesage:NSLocalizedString(@"Image was saved to Camera Roll", nil)];
    }
}

- (bool) canSendMail
{
    bool areSelectedFiles = false;
    for (FileObject * file in _selectedFiles)
    {
        if (!file.isFolder)
        {
            areSelectedFiles = true;
            break;
        }
    }
    
    return (areSelectedFiles && [MFMailComposeViewController canSendMail]);
}

-(void)sendMail:(NSSet *)files
{
    if (![MFMailComposeViewController canSendMail])
    {
        return;
    }
    
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Loading", nil)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        MFMailComposeViewController * mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController setSubject:NSLocalizedString(@"Send file", nil)];
    
        for (FileObject * file in files)
        {
            if (file.isFolder) continue;
            
            NSData * myData = [[NSData alloc] initWithContentsOfFile:file.path];
            [mailViewController addAttachmentData:myData mimeType:@"application/zip" fileName:file.displayName];
            [myData release];
        }
    
        mailViewController.mailComposeDelegate = self;
            
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [appDelegate.window.rootViewController presentModalViewController:mailViewController animated:YES];
            [mailViewController release];
            [appDelegate hideProgressHUD];
        });
    });
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[appDelegate.window.rootViewController dismissModalViewControllerAnimated:YES];
}

- (void) preview:(FileObject *)file
{
    NSDictionary * info = [[NSDictionary alloc] initWithObjectsAndKeys:file, FILE_KEY, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PREVIEW_FILE_NOTIFICATION object:self userInfo:info];
    [info release];
}

#pragma mark - archives

- (void)zip:(NSSet *)files password:(NSString *)password
{
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Creating ZIP", nil)];
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        NSString * zipName = [AppDelegate zipNameForFiles:files];
        if ([self isFileNameInCurrentFolder:zipName])
        {
            zipName = [self duplicateName:zipName copy:false];
        }
        
        NSString * zipPath = [self.currentFolder.path stringByAppendingPathComponent:zipName];
        bool success = [_unarchiver zip:files zipPath:zipPath password:password];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (success)
            {
                [appDelegate showQuickMesage:NSLocalizedString(@"Archiving completed successfully", nil)];
            }
            else
            {
                [appDelegate showQuickMesage:NSLocalizedString(@"Could not create archive", nil)];
            }
                
            [self doneAction:success];
        });
    });
}

- (void) unZip:(FileObject *)zip password:(NSString *)password
{
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"UnZIP", nil)];
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        NSString * unZipFolderName = [zip.displayName stringByDeletingPathExtension];
        if ([self isFileNameInCurrentFolder:unZipFolderName])
        {
            unZipFolderName = [self duplicateName:unZipFolderName copy:false];
        }
        
        NSString * unZipFolderPath = [self.currentFolder.path stringByAppendingPathComponent:unZipFolderName];
        bool success = [_unarchiver unZip:zip to:unZipFolderPath password:password];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (success)
            {
                [appDelegate showQuickMesage:NSLocalizedString(@"Unarchiving completed successfully", nil)];
            }
            else
            {
                [appDelegate showQuickMesage:NSLocalizedString(@"Could not unarchive", nil)];
            }
            
            [self doneAction:success];
        });
    });
}

- (void) unRar:(FileObject *)rar
{
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"UnRAR", nil)];
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        NSString * unRarFolderName = [rar.displayName stringByDeletingPathExtension];
        if ([self isFileNameInCurrentFolder:unRarFolderName])
        {
            unRarFolderName = [self duplicateName:unRarFolderName copy:false];
        }
        
        NSString * unRarFolderPath = [self.currentFolder.path stringByAppendingPathComponent:unRarFolderName];
        bool success = [_unarchiver unRar:rar to:unRarFolderPath];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (success)
            {
                [appDelegate showQuickMesage:NSLocalizedString(@"Unarchiving completed successfully", nil)];
            }
            else
            {
                [appDelegate showQuickMesage:NSLocalizedString(@"Could not unarchive", nil)];
            }
            
            [self doneAction:success];
        });
    });
}

- (void) unZipError:(FileObject *) zip
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:PASSWORD_UNZIP], passwordMissionKey,
                                   zip,  FILE_KEY, nil];
        self.passwordModalView.userInfo = userInfo;
        [self.passwordModalView show];
        [userInfo release];
    });
}

#pragma mark - modal views

- (void) modalView:(ModalView *)modalView clickedBtnAtIndex:(int)index
{
    [modalView hide];
    
    if (modalView == _renameModalView)
    {
        if ([_selectedFiles count] != 1)
        {
            NSLog(@"FileVC: Couldn't rename: selected files count != 1");
            return;
        }
        
        FileObject * file = [_selectedFiles anyObject];
        NSString * newName = _renameModalView.textField.text;
        if (!file.isFolder)
        {
            newName = [newName stringByAppendingPathExtension:[file.displayName pathExtension]];
        }
        [self renameFileWithProgress:file newName:newName];
    }
    else if (modalView == _pasteQuestionModalView)
    {
        bool overWrite = (index == 0);
        bool makeCopy = (index == 1);
        //bool skip = (index == 2);
        
        if (makeCopy)
        {
            NSSet * existedFiles = modalView.userInfo;
            for (FileObject * file in existedFiles)
            {
                file.pasteName = [self duplicateName:file.displayName copy:true];
            }
        }
        
        [self pasteFromClipBoardWithProgress:overWrite];
    }
    else if (modalView == _passwordModalView)
    {       
        NSString * password = _passwordModalView.textField.text;
        
        if ([[_passwordModalView.userInfo objectForKey:passwordMissionKey] intValue] == PASSWORD_UNZIP)
        {
            FileObject * zip = [_passwordModalView.userInfo objectForKey:FILE_KEY];
            [self unZip:zip password:password];
        }
        else if ([[_passwordModalView.userInfo objectForKey:passwordMissionKey] intValue] == PASSWORD_ZIP)
        {
            NSSet * files = [_passwordModalView.userInfo objectForKey:FILE_KEY];
            [self zip:files password:password];
        }
    }
}

- (ModalView *) renameModalView
{
    if (!_renameModalView)
    {
        _renameModalView = [[ModalView alloc] initWithStyle:ModalViewStyleTextField btnTitles:NSLocalizedString(@"OK", nil), nil];
        _renameModalView.titleLabel.text = NSLocalizedString(@"New Name", nil);
        _renameModalView.delegate = self;
        [_renameModalView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    
    return _renameModalView;
}

- (ModalView *) passwordModalView
{
    if (!_passwordModalView)
    {
        _passwordModalView = [[ModalView alloc] initWithStyle:ModalViewStyleTextField btnTitles:NSLocalizedString(@"OK", nil), nil];
        _passwordModalView.titleLabel.text = NSLocalizedString(@"Enter Password", nil);
        _passwordModalView.delegate = self;
        [_passwordModalView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _passwordModalView.textFieldDefaultValue = @"";
    }
    
    return _passwordModalView;
}

- (ModalView *) addFileModalView
{
    if (!_addFileModalView)
    {
        _addFileModalView = [[ModalView alloc] initWithStyle:ModalViewStyleCustom btnTitles:nil];
        _addFileModalView.titleLabel.text = NSLocalizedString(@"New File", nil);
        _addFileModalView.delegate = self;
    }
    
    if (!_addFilesBtnsView)
    {
        [self initAddFilesBtnsView];
    }
    
    if (_addFilesBtnsView.superview != _addFilesBtnsView)
    {
        CGRect newBtnsFrame = _addFilesBtnsView.frame;
        newBtnsFrame.origin.x = _addFileModalView.contentView.frame.size.width / 2 - newBtnsFrame.size.width / 2;
        newBtnsFrame.origin.y = _addFileModalView.contentView.frame.size.height / 2.5;
        _addFilesBtnsView.frame = newBtnsFrame;
        [_addFileModalView.contentView addSubview:_addFilesBtnsView];
    }
    
    return _addFileModalView;
}

- (ModalView*) pasteQuestionModalView
{
    if (!_pasteQuestionModalView)
    {
        _pasteQuestionModalView = [[ModalView alloc] initWithStyle:ModalViewStyleTextView btnTitles:NSLocalizedString(@"Overwrite", nil), NSLocalizedString(@"Copy of File", nil), NSLocalizedString(@"Skip", nil), nil];
        _pasteQuestionModalView.titleLabel.text = NSLocalizedString(@"Some files are already exist!", nil);
        _pasteQuestionModalView.delegate = self;
    }
    
    return _pasteQuestionModalView;
}

#pragma mark -
#pragma mark Table Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentFileList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    FileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[FileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    FileObject * file = [self.currentFileList objectAtIndex:indexPath.row];

    cell.fileLabel.text = file.displayName;
    
    UIImage * icon;
    if (file.isFolder)
    {
        icon = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"folderIcon" ofType:@"png"]];
    }
    else
    {
        icon = [[self iconForFile:file] retain];
    }
    cell.icon.image = icon;
    [icon release];
    
    /*UIButton * accessoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [accessoryBtn addTarget:self action:@selector(accessoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    accessoryBtn.frame = cell.icon.frame;
    
    UIImage * accBtnImg, * accBtnImg1;
    if (file.isFolder)
    {
        accBtnImg = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"folderAccessoryBtn" ofType:@"png"]];
        accBtnImg1 = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"folderAccessoryBtnPush" ofType:@"png"]];
    }
    else
    {
        accBtnImg = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"fileAccessoryBtn" ofType:@"png"]];
        accBtnImg1 = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"fileAccessoryBtnPush" ofType:@"png"]];
    }
    [accessoryBtn setBackgroundImage:accBtnImg forState:UIControlStateNormal];
    [accessoryBtn setBackgroundImage:accBtnImg1 forState:UIControlStateHighlighted];
    [accBtnImg release];
    [accBtnImg1 release];
    cell.accessoryView = accessoryBtn;*/
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    [cell setSelected:false];
    
    return cell;	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileObject * file = [self.currentFileList objectAtIndex:indexPath.row];
    [_selectedFiles addObject:file];
    [self selectedFilesDidModify];
    
    if ([super canPreviewFile])
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            [self showPreviewOnPhone];            
            [navBar setLabelText:file.displayName];
        }
        
        [self preview:file];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileObject * file = [self.currentFileList objectAtIndex:indexPath.row];
    [_selectedFiles removeObject:file];
    [self selectedFilesDidModify];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
    FileObject * file = [self.currentFileList objectAtIndex:indexPath.row];
    
    if (file.isFolder)
    {
        [_breadcrumbs addObject:file];
        self.currentFolder = file;
    }
    else
    {
        NSString * ext = [file.displayName pathExtension];
        if ([[ext lowercaseString] isEqualToString:@"zip"]) [self unZip:file password:nil];
        else if ([[ext lowercaseString] isEqualToString:@"rar"]) [self unRar:file];
        else
        {
            CGRect cellRect = [_tableView convertRect:cell.frame toView:appDelegate.splitVC.view];
            [self open:file cellRect:cellRect];
        }
    }

}

- (void)accessoryBtnClicked:(id)sender
{
    UITableViewCell * cell = (UITableViewCell*)[sender superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    FileObject * file = [self.currentFileList objectAtIndex:indexPath.row];
    
    if (file.isFolder)
    {
        [_breadcrumbs addObject:file];
        self.currentFolder = file;
    }
    else
    {
        NSString * ext = [file.displayName pathExtension];
        if ([[ext lowercaseString] isEqualToString:@"zip"]) [self unZip:file password:nil];
        else if ([[ext lowercaseString] isEqualToString:@"rar"]) [self unRar:file];
        else
        {
            CGRect cellRect = [_tableView convertRect:cell.frame toView:appDelegate.splitVC.view];
            [self open:file cellRect:cellRect];
        }
    }
}

- (void) deselectAllRows
{
    _tableView.allowsMultipleSelection = true;
    for (int i = 0; i < [self.currentFileList count]; i ++)
    {
        [_tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:true];
    }
    
    [_selectedFiles removeAllObjects];
    [self selectedFilesDidModify];
}

#pragma mark -
#pragma mark ToolBarDelegate

- (void) clickedBtn:(ToolBarBtnTag)btnTag
{
    if (btnTag == ToolBarBtnDelete)
    {
        [toolBar setSelected:true forBtn:ToolBarBtnDelete];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)   
        {
            CGRect btnFrame = [toolBar rectForPopoverInView:self.view btn:ToolBarBtnDelete];
            [self.popoverControllerDelete presentPopoverFromRect:btnFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        }
        else
        {
            [self.actionSheetDelete showInView:self.view];
        }
    }
    else if (btnTag == ToolBarBtnAdd)
    {
        [toolBar setSelected:true forBtn:ToolBarBtnAdd];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)   
        {
            CGRect btnFrame = [toolBar rectForPopoverInView:self.view btn:ToolBarBtnAdd];
            [self.popoverControllerAdd presentPopoverFromRect:btnFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        }
        else
        {
            [self.actionSheetAdd showInView:self.view];
        }
    }
    else if (btnTag == ToolBarBtnCCP)
    {
        [toolBar setSelected:true forBtn:ToolBarBtnCCP];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)   
        {
            CGRect btnFrame = [toolBar rectForPopoverInView:self.view btn:ToolBarBtnCCP];
            [self.popoverControllerCCP presentPopoverFromRect:btnFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];   
        }
        else
        {
            [self.actionSheetCCP showInView:self.view];
        }
    }
    else if (btnTag == ToolBarBtnArchive)
    {
        if ([_selectedFiles count] == 1)
        {
            FileObject * file = [_selectedFiles anyObject];
            
            NSString * ext = [file.displayName pathExtension];
            if ([[ext lowercaseString] isEqualToString:@"zip"]) 
            {
                [self unZip:file password:nil];
                return;
            }
            else if ([[ext lowercaseString] isEqualToString:@"rar"]) 
            {
                [self unRar:file];
                return;
            }
        }
        
        [toolBar setSelected:true forBtn:ToolBarBtnArchive];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)   
        {
            CGRect btnFrame = [toolBar rectForPopoverInView:self.view btn:ToolBarBtnArchive];
            [self.popoverControllerArchive presentPopoverFromRect:btnFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];   
        }
        else
        {
            [self.actionSheetArchive showInView:self.view];
        }
    }
    else if (btnTag == ToolBarBtnShare)
    {
        [toolBar setSelected:true forBtn:ToolBarBtnShare];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)   
        {
            CGRect btnFrame = [toolBar rectForPopoverInView:self.view btn:ToolBarBtnShare];
            [self.popoverControllerShare presentPopoverFromRect:btnFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];   
        }
        else
        {
            [self.actionSheetShare showInView:self.view];
        }
    }
    else if (btnTag == ToolBarBtnHelp)
    {
        HelpVC * vc = [[HelpVC alloc] init];
        UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:vc];
        [appDelegate.window.rootViewController presentModalViewController:nc animated:true];
        [vc release];
        [nc release];
    }
}

#pragma mark -
#pragma mark Popovers

- (NSString *)textForBtnAtIndex:(int)index popoverContent:(PopoverContent *)popoverContent
{
     if (popoverContent == _popoverContentDelete)
    {
        if (index == 0) return NSLocalizedString(@"Delete", nil);
    }
    else if (popoverContent == _popoverContentAdd)
    {
        if (index == 0) return NSLocalizedString(@"Folder", nil);
        else if (index == 1) return NSLocalizedString(@"File", nil);
    }
    else if (popoverContent == _popoverContentCCP)
    {
        if (popoverContent.btnCount == 1) return NSLocalizedString(@"Paste", nil);
        else if (popoverContent.btnCount == 2)
        {
            if (index == 0) return NSLocalizedString(@"Copy", nil);
            else if (index == 1) return NSLocalizedString(@"Cut", nil);
        }
        else if (popoverContent.btnCount == 3)
        {
            if (index == 0) return NSLocalizedString(@"Copy", nil);
            else if (index == 1) return NSLocalizedString(@"Cut", nil);
            else if (index == 2)
            {
                if ([[ClipboardManager sharedManager] isFree]) return NSLocalizedString(@"Rename", nil);
                else return NSLocalizedString(@"Paste", nil);
            }
        }
        else if (popoverContent.btnCount == 4)
        {
            if (index == 0) return NSLocalizedString(@"Copy", nil);
            else if (index == 1) return NSLocalizedString(@"Cut", nil);
            else if (index == 2) return NSLocalizedString(@"Paste", nil);
            else if (index == 3) return NSLocalizedString(@"Rename", nil);
        }
    }
    else if(popoverContent == _popoverContentBreadcrumbs)
    {
        if (index == 0) return NSLocalizedString(@"Home", nil);
        else
        {
            FileObject * crumb = [_breadcrumbs objectAtIndex:index - 1];
            return crumb.displayName;
        }
    }
    else if(popoverContent == _popoverContentShare)
    {
        if (index == 0)
        {
            if ([_selectedFiles count] == 1)        return NSLocalizedString(@"Open", nil);
            else if ([self canSendMail])            return NSLocalizedString(@"Mail", nil);
            else if ([self canSaveToCameraRoll])    return NSLocalizedString(@"Save", nil);
        }
        else if (index == 1)
        {
            if ([self canSendMail])    return NSLocalizedString(@"Mail", nil);
            else if ([self canSaveToCameraRoll]) return NSLocalizedString(@"Save", nil);
        }
        else if (index == 2) return NSLocalizedString(@"Save", nil);
    }
    else if(popoverContent == _popoverContentArchive)
    {
        if (index == 0) return NSLocalizedString(@"Archive", nil);
        else if (index == 1) return NSLocalizedString(@"With Password", nil);
    }
    
    return nil;
}

- (UIImage *)imageForBtnAtIndex:(int)index popoverContent:(PopoverContent *)popoverContent
{
    if (popoverContent == _popoverContentBreadcrumbs)
    {
        if (index == 0)
        {
            return [UIImage imageNamed:@"homeNavBarIcon"];
        }
        else
        {
            return navBar.iconImage;
        }
    }
    return nil;
}

- (void)clickedBtnAtIndex:(int)index popoverContent:(PopoverContent *)popoverContent
{
    UIPopoverController *popoverToDismiss;
    
    NSString * title = [self textForBtnAtIndex:index popoverContent:popoverContent];
    
    if (popoverContent == _popoverContentDelete)
    {
        [self deleteSelectedFilesWithProgress];
        popoverToDismiss = _popoverControllerDelete;
    }
    else if (popoverContent == _popoverContentAdd)
    {
        if ([title isEqualToString:NSLocalizedString(@"File", nil)]) [self.addFileModalView show];
        else if ([title isEqualToString:NSLocalizedString(@"Folder", nil)])
        {
            NSString * newName = NSLocalizedString(@"New Folder", nil);
            if ([self isFileNameInCurrentFolder:newName])   newName = [self duplicateName:newName copy:false];
            [self newFolderWithProgress:newName];
        }
        popoverToDismiss = _popoverControllerAdd;
    }
    else if (popoverContent == _popoverContentCCP)
    {       
        if ([title isEqualToString:NSLocalizedString(@"Copy", nil)])        [self copySelectedFilesToClipboard];
        else if ([title isEqualToString:NSLocalizedString(@"Cut", nil)])    [self cutSelectedFilesToClipboard];
        else if ([title isEqualToString:NSLocalizedString(@"Paste", nil)])  [self prepareToPasteFromClipBoard];
        else if ([title isEqualToString:NSLocalizedString(@"Rename", nil)]) [self prepareToRename];
    
        popoverToDismiss = _popoverControllerCCP;
    }
    else if(popoverContent == _popoverContentBreadcrumbs)
    {
        if (index == 0) [self.navigationController popViewControllerAnimated:true];
        else [self didSelectBreadcrumbsWithIndex:index - 1];
        
        popoverToDismiss = _popoverControllerBreadcrumbs;
    }
    else if(popoverContent == _popoverContentShare)
    {
        if ([title isEqualToString:NSLocalizedString(@"Open", nil)])
        {
            if ([_selectedFiles count] != 1)
            {
                NSLog(@"FileVC: Couldn't open: selected files count != 1");
                return;
            }
            
            [self open:[_selectedFiles anyObject] cellRect:[toolBar rectForPopoverInView:self.view btn:ToolBarBtnShare]];
        }
        else if ([title isEqualToString:NSLocalizedString(@"Mail", nil)])
        {
            [self sendMail:_selectedFiles];
        }
        else if ([title isEqualToString:NSLocalizedString(@"Save", nil)])
        {
            if ([_selectedFiles count] != 1)
            {
                NSLog(@"FileVC: Couldn't save to camera roll: selected files count != 1");
                return;
            }
            
            [self saveToCameraRoll:[_selectedFiles anyObject]];
        }
        
        popoverToDismiss = _popoverControllerShare;
    }
    else if(popoverContent == _popoverContentArchive)
    {
        if (index == 0) 
        {
            [self zip:_selectedFiles password:nil];
        }
        if (index == 1)
        {
            NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:PASSWORD_ZIP], passwordMissionKey,
                                       _selectedFiles,  FILE_KEY, nil];
            self.passwordModalView.userInfo = userInfo;
            [self.passwordModalView show];
            [userInfo release];
        }
        popoverToDismiss = _popoverControllerArchive;
    }

    [popoverToDismiss.delegate popoverControllerShouldDismissPopover:popoverToDismiss];
    [popoverToDismiss dismissPopoverAnimated:true];

}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController.contentViewController == _popoverContentDelete)       [toolBar setSelected:false forBtn:ToolBarBtnDelete];
    else if (popoverController.contentViewController == _popoverContentAdd)     [toolBar setSelected:false forBtn:ToolBarBtnAdd];
    else if (popoverController.contentViewController == _popoverContentCCP)     [toolBar setSelected:false forBtn:ToolBarBtnCCP];
    else if (popoverController.contentViewController == _popoverContentShare)   [toolBar setSelected:false forBtn:ToolBarBtnShare];
    else if (popoverController.contentViewController == _popoverContentArchive) [toolBar setSelected:false forBtn:ToolBarBtnArchive];
    return true;
}

- (UIPopoverController *)popoverControllerAdd
{
    if (!_popoverControllerAdd)
    {
        _popoverContentAdd = [[PopoverContent alloc] initWithStyle:PopoverContentStyleHorizont];
        _popoverContentAdd.delegate = self;
        [_popoverContentAdd setBtnSize:CGSizeMake(75, 25)];
        [_popoverContentAdd setBtnBackgroundImage:[UIImage imageNamed:@"ToolbarDarkPopoverBtn"]];
        [_popoverContentAdd setBtnBackgroundImagePush:[UIImage imageNamed:@"ToolbarDarkPopoverBtnPush"]];
        [_popoverContentAdd setDividerImage:[UIImage imageNamed:@"ToolbarDarkPopoverDivider"]];
        [_popoverContentAdd setBtnCount:2];
        [_popoverContentAdd setTextColor:[UIColor whiteColor]];
        
        _popoverControllerAdd = [[UIPopoverController alloc] initWithContentViewController:_popoverContentAdd];
        _popoverControllerAdd.delegate = self;
        _popoverControllerAdd.popoverBackgroundViewClass = [PopoverBgViewToolbarDark class];
    }
    
    int btnCount;
    if (_emptyFolderView && !_emptyFolderView.hidden) btnCount = 1;
    else btnCount = 2;
    
    [_popoverContentAdd setBtnCount:btnCount];
    [_popoverContentAdd setup];
    [_popoverControllerAdd setPopoverContentSize:_popoverContentAdd.view.frame.size animated:YES];
    return _popoverControllerAdd;
}

- (UIPopoverController *)popoverControllerCCP
{
    if (!_popoverControllerCCP)
    {
        _popoverContentCCP = [[PopoverContent alloc] initWithStyle:PopoverContentStyleHorizont];
        _popoverContentCCP.delegate = self;
        [_popoverContentCCP setBtnSize:CGSizeMake(75, 25)];
        [_popoverContentCCP setBtnBackgroundImage:[UIImage imageNamed:@"ToolbarDarkPopoverBtn"]];
        [_popoverContentCCP setBtnBackgroundImagePush:[UIImage imageNamed:@"ToolbarDarkPopoverBtnPush"]];
        [_popoverContentCCP setDividerImage:[UIImage imageNamed:@"ToolbarDarkPopoverDivider"]];
        [_popoverContentCCP setTextColor:[UIColor whiteColor]];
        
        _popoverControllerCCP = [[UIPopoverController alloc] initWithContentViewController:_popoverContentCCP];
        _popoverControllerCCP.delegate = self;
        _popoverControllerCCP.popoverBackgroundViewClass = [PopoverBgViewToolbarDark class];
    }
    
    int btnCount = 0;
    if (![[ClipboardManager sharedManager] isFree]) btnCount ++;
    if ([_selectedFiles count] > 0) btnCount += 2;
    if ([_selectedFiles count] == 1) btnCount ++;
    
    [_popoverContentCCP setBtnCount:btnCount];
    [_popoverContentCCP setup];
    [_popoverControllerCCP setPopoverContentSize:_popoverContentCCP.view.frame.size animated:YES];
    return _popoverControllerCCP;
}

- (UIPopoverController *)popoverControllerDelete
{
    if (!_popoverControllerDelete)
    {
        _popoverContentDelete = [[PopoverContent alloc] initWithStyle:PopoverContentStyleHorizont];
        _popoverContentDelete.delegate = self;
        [_popoverContentDelete setBtnCount:1];
        [_popoverContentDelete setBtnSize:CGSizeMake(75, 25)];
        [_popoverContentDelete setBtnBackgroundImage:[UIImage imageNamed:@"ToolbarRedPopoverBtn"]];
        [_popoverContentDelete setBtnBackgroundImagePush:[UIImage imageNamed:@"ToolbarRedPopoverBtnPush"]];
        [_popoverContentDelete setTextColor:[UIColor whiteColor]];
        [_popoverContentDelete setup];
        
        _popoverControllerDelete = [[UIPopoverController alloc] initWithContentViewController:_popoverContentDelete];
        _popoverControllerDelete.delegate = self;
        _popoverControllerDelete.popoverBackgroundViewClass = [PopoverBgViewToolbarRed class];
        [_popoverControllerDelete setPopoverContentSize:_popoverContentDelete.view.frame.size animated:YES];
    }
    return _popoverControllerDelete;
}

- (void)setupPopoverContentBreadcrumbs
{
    if (!_popoverContentBreadcrumbs)
    {       
        _popoverContentBreadcrumbs = [[PopoverContent alloc] initWithStyle:PopoverContentStyleBreadcrumbs];
        _popoverContentBreadcrumbs.delegate = self;
        [_popoverContentBreadcrumbs setBtnSize:CGSizeMake(150, 45)];
        [_popoverContentBreadcrumbs setBtnBackgroundImage:[UIImage imageNamed:@"NavBarPopoverBtn"]];
        [_popoverContentBreadcrumbs setBtnBackgroundImagePush:[UIImage imageNamed:@"NavBarPopoverBtnPush"]];
           [_popoverContentBreadcrumbs setTextColor:[UIColor whiteColor]];
        [_popoverContentBreadcrumbs setHorizontAlingment:UIControlContentHorizontalAlignmentLeft];
    }
    
    [_popoverContentBreadcrumbs setBtnCount:[_breadcrumbs count] + 1];
    [_popoverContentBreadcrumbs setup];
    [_popoverContentBreadcrumbs setEnabled:false forButtonAtIndex:[_breadcrumbs count]];
}

- (UIPopoverController *)popoverControllerBreadcrumbs
{
    [self setupPopoverContentBreadcrumbs];
    
    if (!_popoverControllerBreadcrumbs)
    {
        _popoverControllerBreadcrumbs = [[UIPopoverController alloc] initWithContentViewController:_popoverContentBreadcrumbs];
        _popoverControllerBreadcrumbs.popoverBackgroundViewClass = [PopoverBgViewToolbarDark class];
        _popoverControllerBreadcrumbs.delegate = self;
    }
    
    [_popoverControllerBreadcrumbs setPopoverContentSize:_popoverContentBreadcrumbs.view.frame.size animated:YES];
    
    return _popoverControllerBreadcrumbs;
}

- (UIPopoverController *)popoverControllerShare
{
    if (!_popoverControllerShare)
    {
        _popoverContentShare = [[PopoverContent alloc] initWithStyle:PopoverContentStyleHorizont];
        _popoverContentShare.delegate = self;
        [_popoverContentShare setBtnSize:CGSizeMake(75, 25)];
        [_popoverContentShare setBtnBackgroundImage:[UIImage imageNamed:@"ToolbarDarkPopoverBtn"]];
        [_popoverContentShare setBtnBackgroundImagePush:[UIImage imageNamed:@"ToolbarDarkPopoverBtnPush"]];
        [_popoverContentShare setDividerImage:[UIImage imageNamed:@"ToolbarDarkPopoverDivider"]];
        [_popoverContentShare setTextColor:[UIColor whiteColor]];
        
        _popoverControllerShare = [[UIPopoverController alloc] initWithContentViewController:_popoverContentShare];
        _popoverControllerShare.delegate = self;
        _popoverControllerShare.popoverBackgroundViewClass = [PopoverBgViewToolbarDark class];
    }
    
    int btnCount = 0;
   
    if ([_selectedFiles count] == 1) btnCount ++;
    if ([self canSendMail]) btnCount ++;
    if ([self canSaveToCameraRoll]) btnCount ++;
    
    [_popoverContentShare setBtnCount:btnCount];
    [_popoverContentShare setup];
    [_popoverControllerShare setPopoverContentSize:_popoverContentShare.view.frame.size animated:YES];
    return _popoverControllerShare;
}

- (UIPopoverController *)popoverControllerArchive
{
    if (!_popoverControllerArchive)
    {
        _popoverContentArchive = [[PopoverContent alloc] initWithStyle:PopoverContentStyleHorizont];
        _popoverContentArchive.delegate = self;
        [_popoverContentArchive setBtnCount:2];
        [_popoverContentArchive setBtnSize:CGSizeMake(85, 25)];
        [_popoverContentArchive setBtnBackgroundImage:[UIImage imageNamed:@"ToolbarDarkPopoverBtn"]];
        [_popoverContentArchive setBtnBackgroundImagePush:[UIImage imageNamed:@"ToolbarDarkPopoverBtnPush"]];
        [_popoverContentArchive setTextColor:[UIColor whiteColor]];
        [_popoverContentArchive setup];
        
        _popoverControllerArchive = [[UIPopoverController alloc] initWithContentViewController:_popoverContentArchive];
        _popoverControllerArchive.delegate = self;
        _popoverControllerArchive.popoverBackgroundViewClass = [PopoverBgViewToolbarDark class];
        [_popoverControllerArchive setPopoverContentSize:_popoverContentArchive.view.frame.size animated:YES];
    }
    return _popoverControllerArchive;
}

#pragma mark - 
#pragma mark ActionSheets

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString * title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (actionSheet == _actionSheetDelete)
    {
        if (buttonIndex == 0) [self deleteSelectedFilesWithProgress];
        [toolBar setSelected:false forBtn:ToolBarBtnDelete];
    }
    else if (actionSheet == _actionSheetAdd)
    {
        if ([title isEqualToString:NSLocalizedString(@"File", nil)]) [self.addFileModalView show];
        else if ([title isEqualToString:NSLocalizedString(@"Folder", nil)])
        {
            NSString * newName = NSLocalizedString(@"New Folder", nil);
            if ([self isFileNameInCurrentFolder:newName])   newName = [self duplicateName:newName copy:false];
            [self newFolderWithProgress:newName];
        }
        [toolBar setSelected:false forBtn:ToolBarBtnAdd];
    }
    else if (actionSheet == _actionSheetCCP)
    {        
        if ([title isEqualToString:NSLocalizedString(@"Copy", nil)])        [self copySelectedFilesToClipboard];
        else if ([title isEqualToString:NSLocalizedString(@"Cut", nil)])    [self cutSelectedFilesToClipboard];
        else if ([title isEqualToString:NSLocalizedString(@"Paste", nil)])  [self prepareToPasteFromClipBoard];
        else if ([title isEqualToString:NSLocalizedString(@"Rename", nil)]) [self prepareToRename];

        [toolBar setSelected:false forBtn:ToolBarBtnCCP];
    }
    else if (actionSheet == _actionSheetShare)
    {
        if ([title isEqualToString:NSLocalizedString(@"Open", nil)])
        {
            if ([_selectedFiles count] != 1)
            {
                NSLog(@"FileVC: Couldn't open: selected files count != 1");
                return;
            }
            [self open:[_selectedFiles anyObject] cellRect:CGRectZero];
        }
        else if ([title isEqualToString:NSLocalizedString(@"Mail", nil)])
        {
            [self sendMail:_selectedFiles];
        }
        else if ([title isEqualToString:NSLocalizedString(@"Save", nil)])
        {
            if ([_selectedFiles count] != 1)
            {
                NSLog(@"FileVC: Couldn't save to camera roll: selected files count != 1");
                return;
            }
            
            [self saveToCameraRoll:[_selectedFiles anyObject]];
        }
        
         [toolBar setSelected:false forBtn:ToolBarBtnShare];
    }
    else if (actionSheet == _actionSheetArchive)
    {
        if (buttonIndex == 0) 
        {
            [self zip:_selectedFiles password:nil];
        }
        if (buttonIndex == 1)
        {
            NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:PASSWORD_ZIP], passwordMissionKey,
                                   _selectedFiles,  FILE_KEY, nil];
            self.passwordModalView.userInfo = userInfo;
            [self.passwordModalView show];
            [userInfo release];
        }
        [toolBar setSelected:false forBtn:ToolBarBtnArchive];
    }
}

- (UIActionSheet *) actionSheetDelete
{
    if (!_actionSheetDelete) 
    {
        _actionSheetDelete = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                           destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:nil, nil];
        _actionSheetDelete.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    }
    
    return _actionSheetDelete;
}

- (UIActionSheet *) actionSheetAdd
{
    [_actionSheetAdd release];
    
    _actionSheetAdd = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil 
                                    destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Folder", nil), nil];
    _actionSheetAdd.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    if (!_emptyFolderView || _emptyFolderView.hidden)     [_actionSheetAdd addButtonWithTitle:NSLocalizedString(@"File", nil)];
    
    [_actionSheetAdd addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    _actionSheetAdd.cancelButtonIndex = _actionSheetAdd.numberOfButtons - 1;
    
    return _actionSheetAdd;
}

- (UIActionSheet *) actionSheetCCP
{
    [_actionSheetCCP release];
    
    _actionSheetCCP = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil 
                                    destructiveButtonTitle:nil otherButtonTitles:nil];
    _actionSheetCCP.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    if ([_selectedFiles count] > 0)
    {
        [_actionSheetCCP addButtonWithTitle:NSLocalizedString(@"Copy", nil)];
        [_actionSheetCCP addButtonWithTitle:NSLocalizedString(@"Cut", nil)];
    }
    if (![[ClipboardManager sharedManager] isFree])    [_actionSheetCCP addButtonWithTitle:NSLocalizedString(@"Paste", nil)];
    if ([_selectedFiles count] == 1)        [_actionSheetCCP addButtonWithTitle:NSLocalizedString(@"Rename", nil)];
    
    [_actionSheetCCP addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    _actionSheetCCP.cancelButtonIndex = _actionSheetCCP.numberOfButtons - 1;
    
    return _actionSheetCCP;
}

- (UIActionSheet *) actionSheetShare
{
    [_actionSheetShare release];
    
    _actionSheetShare = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil 
                                    destructiveButtonTitle:nil otherButtonTitles:nil];
    _actionSheetShare.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    if ([_selectedFiles count] == 1)     [_actionSheetShare addButtonWithTitle:NSLocalizedString(@"Open", nil)];
    if ([self canSendMail])         [_actionSheetShare addButtonWithTitle:NSLocalizedString(@"Mail", nil)];
    if ([self canSaveToCameraRoll]) [_actionSheetShare addButtonWithTitle:NSLocalizedString(@"Save", nil)];
    
    [_actionSheetShare addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    _actionSheetShare.cancelButtonIndex = _actionSheetShare.numberOfButtons - 1;
    
    return _actionSheetShare;
}

- (UIActionSheet *) actionSheetArchive
{
    if (!_actionSheetArchive) 
    {
        _actionSheetArchive = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
        destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Archive", nil), NSLocalizedString(@"With Password", nil), nil];
        _actionSheetArchive.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    }
    
    return _actionSheetArchive;
}

#pragma mark -
#pragma mark NavBarDelegate & Breadcrumbs

- (void) clickedNavBarIcon:(CGRect)iconFrame
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (isPreviewShownOnPhone)
        {
            [self hidePreviewOnPhone];
            [self updateNavBar];
            
            return;
        }
        
        if ([self canPreviewFile])
        {
            [self disablePreviewOnPhone];
        }
        else
        {
            [self showBreadcrumbsOnPhone];
        }
    }
    else
    {
        CGRect frame = [self.view convertRect:iconFrame fromView:navBar];
        [self.popoverControllerBreadcrumbs presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }

}

- (void) backButtonClick
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && isPreviewShownOnPhone)
    {
        [super hidePreviewOnPhone];
        [self updateNavBar];
        return;
    }
    
    if ([_breadcrumbs count] == 1)
    {
        [self.navigationController popViewControllerAnimated:true];
    }
    else
    {
        [_breadcrumbs removeLastObject];
        self.currentFolder = [_breadcrumbs lastObject];
    }
}

- (void) showBreadcrumbsOnPhone
{
    [self setupPopoverContentBreadcrumbs];
    
    CGRect breadcrumbsBounds = _popoverContentBreadcrumbs.view.bounds;
    
    CGRect scrollFrame = breadcrumbsBounds;
    scrollFrame.origin.y = borderHeight;
    scrollFrame.size.height = self.view.bounds.size.height - borderHeight - borderHeightBottom;
    
    float maxScrollWidth = self.view.bounds.size.width - self.view.bounds.size.width / 4;
    if (breadcrumbsBounds.size.width > maxScrollWidth)  scrollFrame.size.width = maxScrollWidth;
    
    scrollFrame.origin.x = -scrollFrame.size.width;
    
    _breadcrumbsScroll = [[UIScrollView alloc] initWithFrame:scrollFrame];
    _breadcrumbsScroll.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _breadcrumbsScroll.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    _breadcrumbsScroll.backgroundColor = [UIColor darkGrayColor];
    _breadcrumbsScroll.contentSize = breadcrumbsBounds.size;
    [_breadcrumbsScroll addSubview:_popoverContentBreadcrumbs.view];
    
    [self.view addSubview:_breadcrumbsScroll];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    
    int move = scrollFrame.size.width;
    
    for (UIView * view in [self.view subviews])
    {
        if (view != imgViewBottom && view != imgViewTop)
        {
            CGRect viewFrame = view.frame;
            viewFrame.origin.x += move;
            view.frame = viewFrame;
        }
    }
    
    [UIView commitAnimations];
    
    CGRect ctrlFrame = self.view.bounds;
    ctrlFrame.origin.x += scrollFrame.size.width;
    _hideBreadcrumbsCtrl = [[UIControl alloc] initWithFrame:ctrlFrame];
    _hideBreadcrumbsCtrl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_hideBreadcrumbsCtrl addTarget:self action:@selector(hideBreadcrumbsOnPhone) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_hideBreadcrumbsCtrl];
}

- (void) hideBreadcrumbsOnPhone
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDidStopSelector:@selector(breadcrumbsDidHide)];
    [UIView setAnimationDelegate:self];
    
    int move = navBar.frame.origin.x;

    for (UIView * view in [self.view subviews]) 
    {
        if (view != imgViewBottom && view != imgViewTop)
        {
            CGRect viewFrame = view.frame;
            viewFrame.origin.x -= move;
            view.frame = viewFrame;
        }
    }
    
    [UIView commitAnimations];
}

- (void) breadcrumbsDidHide
{
    [_hideBreadcrumbsCtrl removeFromSuperview];
    [_breadcrumbsScroll removeFromSuperview];
    [_breadcrumbsScroll release];   _breadcrumbsScroll = nil;
    [_hideBreadcrumbsCtrl release]; _hideBreadcrumbsCtrl = nil;
}

- (void) didSelectBreadcrumbsWithIndex:(int) index
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) [self hideBreadcrumbsOnPhone];
    
    NSMutableArray * newBreadcrumbs = [[NSMutableArray alloc] init];
    for (int i = 0; i <= index; i++) [newBreadcrumbs addObject:[_breadcrumbs objectAtIndex:i]];
    [_breadcrumbs removeAllObjects];
    [_breadcrumbs addObjectsFromArray:newBreadcrumbs];
    [newBreadcrumbs release];
    
    self.currentFolder = [_breadcrumbs lastObject];
}

#pragma mark -
#pragma mark gestures

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self.view];
    if (!CGRectContainsPoint(_tableView.frame, location)) return;
    
    CGPoint locationInTable = [sender locationInView:_tableView];
        
    if (sender.state == UIGestureRecognizerStateEnded)
	{
        int locationY = locationInTable.y + _tableView.contentOffset.y;
		int rowIndex = locationY / cellHeight;
        
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:0]];
        CGPoint locationInCell = [sender locationInView:cell];
        if (CGRectContainsPoint(cell.accessoryView.frame, locationInCell))  return;
        
        if (rowIndex < 0 || rowIndex >= [self.currentFileList count] || locationInTable.x > 50)   [self deselectAllRows];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender 
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || appDelegate.splitVC.isDetailHidden)    return;
    
    CGPoint locationInTable = [sender locationInView:_tableView];
    
    if (sender.state == UIGestureRecognizerStateBegan)
	{
        CGPoint location = [sender locationInView:self.view];
        if (!CGRectContainsPoint(_tableView.frame, location)) return;
        
        int locationY = locationInTable.y + _tableView.contentOffset.y;
		int rowIndex = locationY / cellHeight;
		if (rowIndex < 0 || rowIndex >= [self.currentFileList count]) return;
        
        NSUInteger indexes[2] = {0, rowIndex};
		NSIndexPath * indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
		UITableViewCell * touchCell = [_tableView cellForRowAtIndexPath:indexPath];
        if (!touchCell.selected) return;
        
        for (int i = 0; i < [self.currentFileList count]; i++)
        {
            NSUInteger indexes[2] = {0, i};
            NSIndexPath * indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
            FileCell * cell = (FileCell *)[_tableView cellForRowAtIndexPath:indexPath];
            if (cell.selected)  
            {
                FileCell * copyCell = [[FileCell alloc] initWithFrame:cell.frame];
                copyCell.fileLabel.text = cell.fileLabel.text;
                copyCell.icon.image = cell.icon.image;
                copyCell.alpha = 0.5;
                
                CGPoint center = [self.view convertPoint:cell.center fromView:_tableView];
                if (!self.isMaster) center.x = appDelegate.splitVC.splitPosition + copyCell.frame.size.width/2;
                copyCell.center = center;
                
                [_cellsToMove addObject:copyCell];
                [appDelegate.splitVC.view addSubview:copyCell];
                [copyCell release];
            }
        }
        _previousMoveLocation = locationInTable;
    }
    else if (sender.state == UIGestureRecognizerStateChanged  && [_cellsToMove count] > 0)
	{
        for (UITableViewCell *cell in _cellsToMove)
        {
            float deltaX = locationInTable.x - _previousMoveLocation.x;
            float deltaY = locationInTable.y - _previousMoveLocation.y;
            CGPoint center = cell.center;
            center.x += deltaX;
            center.y += deltaY;
            cell.center = center;
            if(!cell.selected) cell.selected = true;
        }
        _previousMoveLocation = locationInTable;
	}
	else if (sender.state == UIGestureRecognizerStateEnded && [_cellsToMove count] > 0)
	{        
        CGPoint locationInView = [sender locationInView:self.view];
        if (!CGRectContainsPoint(self.view.frame, locationInView)) 
        {
            [[ClipboardManager sharedManager] copyFiles:_selectedFiles source:[self fileSource] sourceFolder:self.currentFolder];
            [ClipboardManager sharedManager].userInfo = [self clipboardUserInfo];
            [ClipboardManager sharedManager].sourceDelegate = self;

            [[NSNotificationCenter defaultCenter] postNotificationName:DRAG_FILES_NOTIFICATION object:self userInfo:nil];
        }
        
        for (UITableViewCell *cell in _cellsToMove)     [cell removeFromSuperview];
        [_cellsToMove removeAllObjects];
    }
}

#pragma mark - setters & getters

- (void)setCurrentFolder:(FileObject *)currentFolder
{
    if (![_currentFolder isEqual:currentFolder])
    {
		[_currentFolder release];
        _currentFolder = [currentFolder retain];
        
        if (_currentFolder) [self reloadFiles];
	}
}

- (void) setProgressActionCounter:(int)progressActionCounter
{
    _progressActionCounter = progressActionCounter;
    if (_progressActionCounter < 0) _progressActionCounter = 0;
}

#pragma mark - 
#pragma mark orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIPopoverController *popoverToDismiss;
    
        if (_popoverControllerDelete && _popoverControllerDelete.isPopoverVisible)  popoverToDismiss = _popoverControllerDelete;
        else if (_popoverControllerAdd && _popoverControllerAdd.isPopoverVisible)   popoverToDismiss = _popoverControllerAdd;
        else if (_popoverControllerCCP &&_popoverControllerCCP.isPopoverVisible)    popoverToDismiss = _popoverControllerCCP;
        else if (navBar.popoverController.isPopoverVisible)                         popoverToDismiss = navBar.popoverController;
        else return;
    
        [popoverToDismiss.delegate popoverControllerShouldDismissPopover:popoverToDismiss];
        [popoverToDismiss dismissPopoverAnimated:true];
    }
}

#pragma mark -
#pragma mark UIDocumentInteractionController

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return appDelegate.splitVC;
    }
    
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return appDelegate.splitVC.view;
    }
    
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return appDelegate.splitVC.view.frame;
    }
    
    return self.view.frame;
}

#pragma mark - 
#pragma mark notify

- (void) folderChangeNotification:(NSNotification *)notification
{
    if (notification.object == self)
    {
        return;
    }
    
    FileObject * folder = [notification.userInfo objectForKey:FOLDER_KEY];
    if ([folder isEqual:self.currentFolder])
    {
        [self reloadFiles];
    }
}

- (void)dragFilesNotification:(NSNotification *)notification
{
    if (notification.object == self)
    {
        return;
    }
    
    [self prepareToPasteFromClipBoard];
}

- (void) copyNotification:(NSNotification *)notification
{
    if (notification.object == self) return;
    if (![[ClipboardManager sharedManager] isFree]) [self clickedBtn:ToolBarBtnCCP];
}

- (void) clipBoardChangeNotification:(NSNotification *)notification
{
    [toolBar setEnabled:![[ClipboardManager sharedManager] isFree] || [_selectedFiles count] > 0 forBtn:ToolBarBtnCCP];

}

- (void) selectedFilesDidModify
{
    [toolBar setEnabled:[_selectedFiles count] > 0 forBtn:ToolBarBtnDelete];
    [toolBar setEnabled:[_selectedFiles count] > 0 && [self canWorkWithArchives] forBtn:ToolBarBtnArchive];
    [toolBar setEnabled:[_selectedFiles count] > 0 || (![[ClipboardManager sharedManager] isFree]) forBtn:ToolBarBtnCCP];
    
    [toolBar setEnabled:[self canSaveToCameraRoll] || [self canSendMail] || [_selectedFiles count] == 1 forBtn:ToolBarBtnShare];
}

- (void) enterForeground
{
    [toolBar setEnabled:[self canSaveToCameraRoll] || [self canSendMail] || [_selectedFiles count] == 1 forBtn:ToolBarBtnShare];
}

- (void)textFieldDidChange:(UITextField *)sender
{
    if (sender == _renameModalView.textField)
    {
        FileObject * file = [_selectedFiles anyObject];
        NSString * newName = _renameModalView.textField.text;
        if (!file.isFolder)   newName = [newName stringByAppendingPathExtension:[file.displayName pathExtension]];
        
        bool enabled = (![self isFileNameInCurrentFolder:newName] && [AppDelegate stringIsOK:sender.text]);
        [_renameModalView setEnabled:enabled forBtnAtIndex:0];
    }
    else if (sender == _passwordModalView.textField) [_passwordModalView setEnabled:[AppDelegate stringIsOK:sender.text] forBtnAtIndex:0];
}

- (void) zipNotification:(NSNotification *)notification
{
    NSSet * files = [notification.userInfo objectForKey:FILE_KEY];
    bool needPassword = [[notification.userInfo objectForKey:PASSWORD_KEY] boolValue];
    
    if (needPassword)
    {
        NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithInt:PASSWORD_ZIP], passwordMissionKey,
                                   files,  FILE_KEY, nil];
        self.passwordModalView.userInfo = userInfo;
        [self.passwordModalView show];
        [userInfo release];
    }
    else 
    {
        [self zip:files password:nil];
    }
}

- (void) unZipNotification:(NSNotification *)notification
{
    FileObject * zip = [notification.userInfo objectForKey:FILE_KEY];
    [self unZip:zip password:nil];
}
- (void) unRarNotification:(NSNotification *)notification
{
    FileObject * rar = [notification.userInfo objectForKey:FILE_KEY];
    [self unRar:rar];
}

- (void) handleRefresh:(UIRefreshControl *)sender
{
    [sender endRefreshing];
    [self reloadFiles];
}

#pragma mark - "virtual" methods

- (NSArray *) filesFromCurrentFolder
{
    return nil;
}

- (long long) freeSpace
{
    return 0;
}

- (FileSource)fileSource
{
    return -1;
}

- (bool) canWorkWithArchives
{
    return false;
}

- (void) remove:(FileObject *)file
{
    
}

- (void) paste:(FileObject *)file overWrite:(bool)overWrite
{
    
}

- (void) newFolder:(NSString *)name
{
    
}

- (void) newFile:(NSString *)name content:(NSData *)content
{
    
}

- (void) rename:(FileObject *)file newName:(NSString *)newName
{
    
}

- (id) clipboardUserInfo
{
    return nil;
}

@end
