//
//  CameraVC.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 16.07.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "CameraVC.h"

#import "FolderVC.h"
#import "PopoverBgViews.h"
#import "UIImage+Resize.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define COLUMN_COUNT 3
#define TRANSPARENT_BORDER_SIZE 2
#define THUMBNAIL_SIZE 100

static ALAssetsLibrary * alLibrary = nil;

@interface CameraVC ()

@property (nonatomic, retain) UIPopoverController * popoverControllerCCP;
@property (nonatomic, retain) UIActionSheet * actionSheetCCP;

@end

@implementation CameraVC

@synthesize popoverControllerCCP = _popoverControllerCCP;
@synthesize actionSheetCCP = _actionSheetCCP;

#pragma mark - init

- (ALAssetsLibrary * ) alLibrary
{
    if (!alLibrary)
    {
        alLibrary = [[ALAssetsLibrary alloc] init];
    }
    return alLibrary;
}


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
    
    _items = [[NSMutableArray alloc] init];
    _selectedItems = [[NSMutableArray alloc] init];
    _assets = [[NSMutableArray alloc] init];
    _itemsToMove = [[NSMutableArray alloc] init];
    _savePhotoQue = [[NSMutableArray alloc] init];
    _savePhotoCount = 0;
    
    [self customizeInterface];
    [self initScroll];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]	initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.cancelsTouchesInView = false;
    [_scroll addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]	initWithTarget:self action:@selector(handlePanGesture:)];
        [self.view addGestureRecognizer:panGesture];
        [panGesture release];
    }
    
    [self loadItems];
}

- (void)viewDidUnload
{
    [self clean];
    
    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self removeObservers];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeItems) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipboardDidChange:) name:clipboardDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alAssetsLibraryChanged) name:ALAssetsLibraryChangedNotification object:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dragFilesNotification:) name:DRAG_FILES_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyNotification:) name:COPY_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeItems) name:CHANGE_SPLIT_POSITION_NOTIFICATION object:nil];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self removeObservers];
}

- (void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:clipboardDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DRAG_FILES_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:COPY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_SPLIT_POSITION_NOTIFICATION object:nil];
}


- (void) clean
{
    [self removeObservers];
    
    [_items release];
    [_selectedItems release];
    [_popoverContentCCP release];
    [_popoverControllerImagePicker release];
    [_scroll release];
    [_assets release];
    [_itemsToMove release];
    [_savePhotoQue release];
    
    self.popoverControllerCCP = nil;
    self.actionSheetCCP = nil;
}

- (void) dealloc
{
    [self clean];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)  customizeInterface
{
    UIImage * patternImage = [UIImage imageNamed:@"cameraBorder"];
    [self setImageBorder:patternImage];
    
    [navBar setBackgroundImage:[UIImage imageNamed:@"navBarBG"]];
    [navBar setIconImage:[UIImage imageNamed:@"cameraNavBarIcon"]];
    [navBar setBackButtonImage:[UIImage imageNamed:@"backBtnCamera"]];
    [navBar setViewModeButtonImage:[UIImage imageNamed:@"listBtnCamera"]];
    [navBar setSettingsButtonImage:[UIImage imageNamed:@"settingsBtnCamera"]];
    [navBar setPreviewButtonImage:[UIImage imageNamed:@"previewBtnCamera"]];
    [navBar setLabelText:NSLocalizedString(@"Camera Roll", nil)];
    [navBar setSubLabelText:NSLocalizedString(@"Camera", nil)];
    [navBar setLabelTextColor:[UIColor colorWithPatternImage:patternImage]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [navBar setCustomButtonType:NavBarCustomButtonTypePreview];
    }
    
    [toolBar setImage:[UIImage imageNamed:@"addBtnCamera"] forBtn:ToolBarBtnAdd];
    [toolBar setImage:[UIImage imageNamed:@"shareBtnCamera"] forBtn:ToolBarBtnShare];
    [toolBar setImage:[UIImage imageNamed:@"ccpBtnCamera"] forBtn:ToolBarBtnCCP];
    [toolBar setImage:[UIImage imageNamed:@"archiveBtnCamera"] forBtn:ToolBarBtnArchive];
    [toolBar setImage:[UIImage imageNamed:@"deleteBtnCamera"] forBtn:ToolBarBtnDelete];
    [toolBar setImage:[UIImage imageNamed:@"helpBtnCamera"] forBtn:ToolBarBtnHelp];
    [toolBar setButtonTitleColor:[UIColor colorWithPatternImage:patternImage]];
    
    bool camera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    [toolBar setEnabled:camera forBtn:ToolBarBtnAdd]; 
}

- (void) initScroll
{    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:contentView.bounds];
    bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIImage * img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tableBg" ofType:@"png"]];
    bg.image = img;
    [contentView addSubview:bg];
    [bg release];
    [img release];
    
    _scroll = [[UIScrollView alloc] initWithFrame:contentView.bounds];
    _scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scroll.backgroundColor = [UIColor clearColor];
    [contentView addSubview:_scroll];
}

#pragma mark - mail

-(void)sendSelectedImages
{
    if (![MFMailComposeViewController canSendMail]) return;
    
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Loading", nil)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool
        {
            MFMailComposeViewController * mailViewController = [[MFMailComposeViewController alloc] init];
            [mailViewController setSubject:NSLocalizedString(@"Send file", nil)];
    
            NSArray * assets = [self selectedAssets];
            for (ALAsset *asset in assets)
            {	
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                UIImage * img = [[UIImage alloc] initWithCGImage:[rep fullResolutionImage]];
                NSData *data = UIImageJPEGRepresentation(img, 0);
                [mailViewController addAttachmentData:data mimeType:@"application/zip" fileName:@"photo.jpg"];
                [img release];
            }
    
            mailViewController.mailComposeDelegate = self;
        
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [appDelegate.window.rootViewController presentModalViewController:mailViewController animated:YES];
                [mailViewController release];
                [appDelegate hideProgressHUD];
            });
        }
    });
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[appDelegate.window.rootViewController dismissModalViewControllerAnimated:YES];
    [toolBar setSelected:false forBtn:ToolBarBtnShare];
}

#pragma mark - copy & paste

- (NSArray *) selectedAssets
{
    NSMutableArray * assets = [NSMutableArray array];
    for (CameraItem * item in _selectedItems)
    {
        ALAsset * asset = [_assets objectAtIndex:item.tag];
        [assets addObject:asset];
    }
    return assets;
}

- (NSSet *) selectedFiles
{
    NSMutableSet * files = [NSMutableSet set];
    for (int i = 0; i < [_selectedItems count]; i++)
    {
        NSString * name = [NSString stringWithFormat:@"%@ %i.jpg", NSLocalizedString(@"photo", nil), i + 1];
        [files addObject:[FileObject fileWithID:[NSString stringWithFormat:@"%i", i] displayName:name]];
    }
    return files;
}

- (void) copySelectedPhotos
{
    [[ClipboardManager sharedManager] copyFiles:[self selectedFiles] source:FileSourceCamera sourceFolder:nil];
    [ClipboardManager sharedManager].userInfo = [self selectedAssets];
    [ClipboardManager sharedManager].sourceDelegate = self;

    [[NSNotificationCenter defaultCenter] postNotificationName:COPY_NOTIFICATION object:self];
}

- (int) filterClipBoard
{
    //0 - no images
    //1 - all is ok
    //2 - some files will be skipped
    
    int result = 1;
    
    NSMutableSet * onlyImages = [[NSMutableSet alloc] init];
    for (FileObject * file in [ClipboardManager sharedManager].files)
    {
        if ([AppDelegate isImage:file]) [onlyImages addObject:file];
        else result = 2;
    }
    
    if ([onlyImages count] == 0)
    {
        result = 0;
    }
    
    if (result != 0)
    {
        [ClipboardManager sharedManager].files = onlyImages;
    }
    
    [onlyImages release];
    return result;
}

- (void) pasteFromClipBoard
{
    if ([ClipboardManager sharedManager].source == FileSourceCamera)
    {
        return;
    }
    
    int result = [self filterClipBoard];
    if (result != 1)
    {
        [appDelegate showQuickMesage:NSLocalizedString(@"Only images will be copied", nil)];
    }
    
     // елси в буфере обмена нет картинок - на выход
    if (result == 0)
    {
       
        [self finishPastePhoto];
        return;
    }
    
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Сopying", nil)];
    
    for (FileObject * file in [ClipboardManager sharedManager].files)
    {
        if ([ClipboardManager sharedManager].source == FileSourceFolder)
        {
            [self savePhoto:file.path];
        }
        else
        {
            [ClipboardManager sharedManager].destDelegate = self;
            [[ClipboardManager sharedManager].sourceDelegate needPasteToCacheFile:file];
        }
    }
}

- (void) savePhoto:(NSString *) path;
{   
    [_savePhotoQue addObject:path];
    
    if (_savePhotoCount > 3)
    {
        return;
    }
    else
    {
        [self savePhotoFromQue];
    }
}

- (void) savePhotoFromQue
{
    if ([_savePhotoQue count] == 0)
    {
        return;
    }
    
    _savePhotoCount ++;
    
    NSString * path = [_savePhotoQue objectAtIndex:0];
    UIImage * photo = [[UIImage alloc] initWithContentsOfFile:path];
    UIImageWriteToSavedPhotosAlbum(photo, self, @selector(image:didFinishPasteFromFolder:contextInfo:), nil);
    [_savePhotoQue removeObject:path];
    [photo release];
}

- (void)image:(UIImage *)image didFinishPasteFromFolder:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error)
    {
        UIImage * thumbnail = [self thumbnailFromImage:image];
        [self addItemWithImage:thumbnail];
        [self finishPastePhoto];
    }
    else
    {
        [self finishPastePhoto];
    }
    
    _savePhotoCount --;
    [self savePhotoFromQue];
}

- (void) finishPastePhoto
{
    static int savedPhotoCount = 0;
    
    savedPhotoCount ++;
    if (savedPhotoCount >= [[ClipboardManager sharedManager].files count])
    {
        [appDelegate hideProgressHUD];
        savedPhotoCount = 0;
    }
}

#pragma mark - ClipboardDestinationDelegate

- (void) file:(FileObject *)file didPasteToCache:(NSString *)pathInCache
{
    if (pathInCache)
    {
        [self savePhoto:pathInCache];
    }
    else
    {
        [self finishPastePhoto];
    }
}

#pragma mark - ClipboardSourceDelegate

- (void) needPasteToCacheFile:(FileObject *)file
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool
        {        
            NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:file.displayName];
            [[NSFileManager defaultManager] removeItemAtPath:pathInCache error:nil];
                
            ALAsset * asset = [[ClipboardManager sharedManager].userInfo objectAtIndex:[file.ID intValue]];
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            UIImage * img = [[UIImage alloc] initWithCGImage:[rep fullResolutionImage]];
            NSData *imageData = UIImageJPEGRepresentation(img, 0);
            bool success = [[NSFileManager defaultManager] createFileAtPath:pathInCache contents:imageData attributes:nil];
            [img release];        
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (success)
                {
                    [[ClipboardManager sharedManager].destDelegate file:file didPasteToCache:pathInCache];
                }
                else
                {
                    [[ClipboardManager sharedManager].destDelegate file:file didPasteToCache:nil];
                }
            });
        }
        
    });
}

- (void) needPasteToFolderFile:(FileObject *)file newPath:(NSString *)newPath overWrite:(bool)overWrite
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool
        {
            if (overWrite)
            {
                [[NSFileManager defaultManager] removeItemAtPath:newPath error:nil];
            }
            
            ALAsset * asset = [[ClipboardManager sharedManager].userInfo objectAtIndex:[file.ID intValue]];
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            UIImage * img = [[UIImage alloc] initWithCGImage:[rep fullResolutionImage]];
            NSData *imageData = UIImageJPEGRepresentation(img, 0);
            bool success = [[NSFileManager defaultManager] createFileAtPath:newPath contents:imageData attributes:nil];
            [img release];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[ClipboardManager sharedManager].destDelegate fileDidPasteToFolder:success];
                
            });
        }
    });
}

#pragma mark - load & draw photos

- (void) addItemWithImage:(UIImage *)img
{
    CameraItem * item = [[CameraItem alloc] init];
    
    item.image = img;
    item.delegate = self;
    item.contentMode = UIViewContentModeScaleAspectFill;
    item.tag = [_items count];

    [_scroll addSubview:item];
    [_items addObject:item];
    
    [item release];
    
    [self resizeItems];
}

- (void) loadItems
{    
    [_assets removeAllObjects];
    [_items removeAllObjects];
    [_selectedItems removeAllObjects];
    [self selectedFilesDidModify];
    for (UIView * view in [_scroll subviews])
    {
        [view removeFromSuperview];
    }
    
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Loading", nil)];
    
    [[self alLibrary] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
    {
        [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
        {
            if (asset) 
            {
                @autoreleasepool 
                {
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    UIImage * img = [[UIImage alloc] initWithCGImage:[rep fullResolutionImage]];
                    if (img) 
                    {
                        UIImage * thumbnail = [self thumbnailFromImage:img];
                        [self addItemWithImage:thumbnail];
                        [_assets addObject:asset];
                        [img release];
                    }
                    
                }
            } 
        }];
               
        [appDelegate hideProgressHUD];
    }
    
    
    failureBlock:^(NSError *error) 
    { 
        NSLog(@"load photos fail");
        [appDelegate hideProgressHUD];
    }];
}

- (void) resizeItems
{
    int itemSize = _scroll.frame.size.width / COLUMN_COUNT;
    
    int col = 0, row = 0;
    for (CameraItem * item in _items)
    {
        CGRect frame;
        frame.origin = CGPointMake(col * itemSize, row * itemSize);
        frame.size = CGSizeMake(itemSize, itemSize);
        item.frame = frame;
        
        if (++ col >= COLUMN_COUNT) 
        {
            col = 0;
            row ++;
        }
    }
    _scroll.contentSize = CGSizeMake(_scroll.frame.size.width, itemSize * (row + 1));
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.showsVerticalScrollIndicator = YES;
}

#pragma mark - select items

- (void) deselectAllItems
{
    for (CameraItem * item in _selectedItems)
    {
        item.selected = false;
    }
    [_selectedItems removeAllObjects];
    
    [self selectedFilesDidModify];
}

- (void) cameraItemDidTouch:(CameraItem *)item
{
    [self deselectAllItems];
    [_selectedItems addObject:item];
    item.selected = true;
    [self selectedFilesDidModify];
    
    [self previewItem:item];
}

- (void) cameraItemCheckBoxDidTouch:(CameraItem *)item
{
    item.selected = !item.selected;
    if (item.selected)
    {
        [_selectedItems addObject:item];
    }
    else
    {
        [_selectedItems removeObject:item];
    }
    
    [self selectedFilesDidModify];
    
    [self previewItem:item];
}

- (void) previewItem:(CameraItem *) item
{
    @autoreleasepool
    {
        if ([super canPreviewFile])
        {
            ALAsset * asset = [_assets objectAtIndex:item.tag];
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            UIImage * img = [[UIImage alloc] initWithCGImage:[rep fullResolutionImage]];
            NSData * imageData = UIImageJPEGRepresentation(img, 0);
            [img release];
            
            NSString * name = [NSString stringWithFormat:@"%@.jpg", [AppDelegate uniqString]];
            NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:name];
            [[NSFileManager defaultManager] removeItemAtPath:pathInCache error:nil];
            [[NSFileManager defaultManager] createFileAtPath:pathInCache contents:imageData attributes:nil];
            
            NSDictionary * info = [[NSDictionary alloc] initWithObjectsAndKeys:[FileObject fileWithPath:pathInCache], FILE_KEY, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:PREVIEW_FILE_NOTIFICATION object:self userInfo:info];
            [info release];
            
            if (UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM())
            {
                [super showPreviewOnPhone];
            }
        }
    }
}

#pragma mark - new image

- (void) newImage
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CGRect btnFrame = [toolBar rectForPopoverInView:self.view btn:ToolBarBtnAdd];
        [_popoverControllerImagePicker release];
        _popoverControllerImagePicker = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        _popoverControllerImagePicker.delegate = self;
        [_popoverControllerImagePicker presentPopoverFromRect:btnFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
    }
    else
    {
        [appDelegate.window.rootViewController presentModalViewController:imagePicker animated:true];
    }
    
    [imagePicker release];
}

- (void) imagePickerController: (UIImagePickerController*) picker didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    
    UIImage * thumbnail = [self thumbnailFromImage:img];
    [self addItemWithImage:thumbnail];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)   
    {
        [toolBar setSelected:false forBtn:ToolBarBtnAdd];
        [_popoverControllerImagePicker dismissPopoverAnimated:true];
    }
    else 
    {
        [toolBar setSelected:false forBtn:ToolBarBtnAdd];
        [appDelegate.window.rootViewController dismissModalViewControllerAnimated:true];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [toolBar setSelected:false forBtn:ToolBarBtnAdd];
    [appDelegate.window.rootViewController dismissModalViewControllerAnimated:true];
}

- (UIImage *)thumbnailFromImage:(UIImage *)image
{
    return [image thumbnailImage:THUMBNAIL_SIZE transparentBorder:TRANSPARENT_BORDER_SIZE cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
}

#pragma mark - ToolBarDelegate

- (void) clickedBtn:(ToolBarBtnTag)btnTag
{
    if (btnTag == ToolBarBtnAdd)
    {
        [toolBar setSelected:true forBtn:ToolBarBtnAdd];
        [self newImage];
    }
    if (btnTag == ToolBarBtnShare)
    {
        [toolBar setSelected:true forBtn:ToolBarBtnShare];
        [self sendSelectedImages];
    }
    else if (btnTag == ToolBarBtnCCP)
    {
        [toolBar setSelected:true forBtn:ToolBarBtnCCP];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)   
        {
            CGRect btnFrame = [toolBar rectForPopoverInView:self.view btn:ToolBarBtnCCP];
            [self.popoverControllerCCP presentPopoverFromRect:btnFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];   
        }
        else
        {
            [self.actionSheetCCP showInView:self.view];
        }
    }
}

#pragma mark - NavBarDelegate

- (void) backButtonClick
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && isPreviewShownOnPhone)
    {
        [self hidePreviewOnPhone];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:true];
    }
}

- (void) clickedNavBarIcon:(CGRect)iconFrame
{
    [self backButtonClick];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString * title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (actionSheet == _actionSheetCCP)
    {        
        if ([title isEqualToString:NSLocalizedString(@"Copy", nil)])
        {
            [self copySelectedPhotos];
        }
        else if ([title isEqualToString:NSLocalizedString(@"Paste", nil)])
        {
            [self pasteFromClipBoard];
        }
        
        [toolBar setSelected:false forBtn:ToolBarBtnCCP];
    }
}

- (UIActionSheet *) actionSheetCCP
{
    [_actionSheetCCP release];
    
    _actionSheetCCP = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil 
                                    destructiveButtonTitle:nil otherButtonTitles:nil];
    _actionSheetCCP.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    if ([_selectedItems count] > 0)
    {
        [_actionSheetCCP addButtonWithTitle:NSLocalizedString(@"Copy", nil)];
    }
    if (![[ClipboardManager sharedManager] isFree])
    {
        [_actionSheetCCP addButtonWithTitle:NSLocalizedString(@"Paste", nil)];
    }
    
    [_actionSheetCCP addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    _actionSheetCCP.cancelButtonIndex = _actionSheetCCP.numberOfButtons - 1;
    
    return _actionSheetCCP;
}

#pragma mark - PopoverContentDelegate

- (NSString *)textForBtnAtIndex:(int)index popoverContent:(PopoverContent *)popoverContent
{
   if (popoverContent == _popoverContentCCP)
   {
       if (popoverContent.btnCount == 1) 
       {
           if ([_selectedItems count] > 0) return NSLocalizedString(@"Copy", nil);
           if (![[ClipboardManager sharedManager] isFree]) return NSLocalizedString(@"Paste", nil);
           
       }
        else if (popoverContent.btnCount == 2)
        {
            if (index == 0) return NSLocalizedString(@"Copy", nil);
            else if (index == 1) return NSLocalizedString(@"Paste", nil);
        }
    }
       
    return nil;
}

- (void)clickedBtnAtIndex:(int)index popoverContent:(PopoverContent *)popoverContent
{
    UIPopoverController *popoverToDismiss;
    
    NSString * title = [self textForBtnAtIndex:index popoverContent:popoverContent];
    
    if (popoverContent == _popoverContentCCP)
    {       
        if ([title isEqualToString:NSLocalizedString(@"Copy", nil)])            [self copySelectedPhotos];
        else if ([title isEqualToString:NSLocalizedString(@"Paste", nil)])      [self pasteFromClipBoard];
        
        popoverToDismiss = _popoverControllerCCP;
    }
        
    [popoverToDismiss.delegate popoverControllerShouldDismissPopover:popoverToDismiss];
    [popoverToDismiss dismissPopoverAnimated:true];
    
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController.contentViewController == _popoverContentCCP)
    {
        [toolBar setSelected:false forBtn:ToolBarBtnCCP];
    }
    else if (popoverController == _popoverControllerImagePicker)
    {
        [toolBar setSelected:false forBtn:ToolBarBtnAdd];
    }
    
    return true;
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
    if ([_selectedItems count] > 0) btnCount ++;
    if (![[ClipboardManager sharedManager] isFree]) btnCount ++;
    
    [_popoverContentCCP setBtnCount:btnCount];
    [_popoverContentCCP setup];
    [_popoverControllerCCP setPopoverContentSize:_popoverContentCCP.view.frame.size animated:YES];
    return _popoverControllerCCP;
}

#pragma mark - notifications

- (void) clipboardDidChange:(NSNotification *)notification
{
    [toolBar setEnabled:![[ClipboardManager sharedManager] isFree] || [_selectedItems count] > 0 forBtn:ToolBarBtnCCP];
}

- (void) selectedFilesDidModify
{
    [toolBar setEnabled:[_selectedItems count] > 0 || (![[ClipboardManager sharedManager] isFree]) forBtn:ToolBarBtnCCP];
    [toolBar setEnabled:[_selectedItems count] > 0 && [MFMailComposeViewController canSendMail] forBtn:ToolBarBtnShare];
}

- (void)dragFilesNotification:(NSNotification *)notification
{
    if (notification.object == self)
    {
        return;
    }
    
    [self pasteFromClipBoard];
}

- (void) copyNotification:(NSNotification *)notification
{
    if (notification.object == self)
    {
        return;
    }
    
    if (![[ClipboardManager sharedManager] isFree])
    {
        [self clickedBtn:ToolBarBtnCCP];
    }
}

- (void) alAssetsLibraryChanged
{
    [_assets removeAllObjects];
    
    [[self alLibrary] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
          {
              if (asset)
              {
                  [_assets addObject:asset];
              }
          }];
     }
     
    failureBlock:^(NSError *error) 
    { 
         NSLog(@"re enumerate assets fail");
    }];
}

#pragma mark - gestures

- (void)handleTapGesture:(UITapGestureRecognizer *)sender 
{
    CGPoint locationInScroll = [sender locationInView:_scroll];
    
    if (sender.state == UIGestureRecognizerStateEnded)
	{
        for (CameraItem * item in _items)
        {
            if (CGRectContainsPoint(item.frame, locationInScroll))
            {
                return;
            }
        }
        
        [self deselectAllItems];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender 
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || appDelegate.splitVC.isDetailHidden)
    {
        return;
    }
    
    CGPoint locationInScroll = [sender locationInView:_scroll];
    
    if (sender.state == UIGestureRecognizerStateBegan)
	{
        bool canDrag = false;
        for (CameraItem * item in _selectedItems)
        {
            if (CGRectContainsPoint(item.frame, locationInScroll))
            {
                canDrag = true;
            }
        }
        if (!canDrag)
        {
            return;
        }
        
        for (CameraItem * item in _selectedItems)
        {
            item.alpha = 0.5;
            [_itemsToMove addObject:item];
                
            CGPoint center = [self.view convertPoint:item.center fromView:_scroll];
            if (!self.isMaster)
            {
                center.x += appDelegate.splitVC.splitPosition;
            }
            item.center = center;
            [appDelegate.splitVC.view addSubview:item];
        }
        _previousMoveLocation = locationInScroll;
    }
    else if (sender.state == UIGestureRecognizerStateChanged  && [_itemsToMove count] > 0)
	{
        for (CameraItem * item in _itemsToMove)
        {
            float deltaX = locationInScroll.x - _previousMoveLocation.x;
            float deltaY = locationInScroll.y - _previousMoveLocation.y;
            CGPoint center = item.center;
            center.x += deltaX;
            center.y += deltaY;
            item.center = center;
        }
        _previousMoveLocation = locationInScroll;
	}
	else if (sender.state == UIGestureRecognizerStateEnded && [_itemsToMove count] > 0)
	{        
        CGPoint locationInView = [sender locationInView:self.view];
        if (!CGRectContainsPoint(self.view.frame, locationInView)) 
        {
            [[ClipboardManager sharedManager] copyFiles:[self selectedFiles] source:FileSourceCamera sourceFolder:nil];
            [ClipboardManager sharedManager].userInfo = [self selectedAssets];
            [ClipboardManager sharedManager].sourceDelegate = self;
            [[NSNotificationCenter defaultCenter] postNotificationName:DRAG_FILES_NOTIFICATION object:self userInfo:nil];
        }
        
        for (CameraItem *item in _itemsToMove)
        {
            item.alpha = 1;
            [_scroll addSubview:item];
        }
        [self resizeItems];
        
        [_itemsToMove removeAllObjects];
    }
}

- (void) enterForeground
{
    [self.navigationController popViewControllerAnimated:false];
}

@end
