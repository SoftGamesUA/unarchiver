
//
//  DropboxVC.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 31.01.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "DropboxVC.h"
#import "FolderVC.h"

#define DB_APP_KEY        @"ra7x44hqlg08zmy"
#define DB_APP_SECRET     @"s1dvgoi05pkhsxf"

@interface DropboxVC ()

@property (nonatomic, retain) DBAccountInfo * accauntInfo;
@property (nonatomic, retain) DBMetadata * loadedMetadata;
@property (nonatomic, retain) NSMutableSet * filesToSend;
@property (nonatomic, retain) DBRestClient * restClient;

@end

@implementation DropboxVC

- (void) dropboxLinkNotification
{
    self.restClient = nil;    
    [super reloadFiles];
}

- (void) noAuthorization
{
    [appDelegate showQuickMesage:NSLocalizedString(@"Need authorization", nil)];
    [super doneAction:false];
}

- (void) noConnection
{
    [self removeObservers];
    
    toolBar.userInteractionEnabled = false;
    navBar.userInteractionEnabled = false;
    
    NSString * message = [[NSString alloc] initWithFormat:@"%@ dropbox.com", NSLocalizedString(@"Unarchiver could not connect to", nil)];
    [appDelegate showQuickMesage:message];
    [message release];
    
    [appDelegate hideProgressHUD];
    [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:true] afterDelay:1];
}

- (DBRestClient *) restClient
{
    if (!_restClient)
    {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    
    return _restClient;
}

#pragma mark - View lifecycle

- (void) customizeInterface
{
    UIImage * patternImage = [UIImage imageNamed:@"dropboxBorder"];
    [self setImageBorder:patternImage];
    
    [navBar setBackgroundImage:[UIImage imageNamed:@"navBarBG"]];
    [navBar setIconImage:[UIImage imageNamed:@"dropboxNavBarIcon"]];
    [navBar setBackButtonImage:[UIImage imageNamed:@"backBtnDropbox"]];
    [navBar setViewModeButtonImage:[UIImage imageNamed:@"listBtnDropbox"]];
    [navBar setSettingsButtonImage:[UIImage imageNamed:@"settingsBtnDropbox"]];
    [navBar setPreviewButtonImage:[UIImage imageNamed:@"previewBtnDropbox"]];
    [navBar setLabelTextColor:[UIColor colorWithPatternImage:patternImage]];
    
    [toolBar setImage:[UIImage imageNamed:@"addBtnDropbox"] forBtn:ToolBarBtnAdd];
    [toolBar setImage:[UIImage imageNamed:@"shareBtnDropbox"] forBtn:ToolBarBtnShare];
    [toolBar setImage:[UIImage imageNamed:@"ccpBtnDropBox"] forBtn:ToolBarBtnCCP];
    [toolBar setImage:[UIImage imageNamed:@"archiveBtnDropbox"] forBtn:ToolBarBtnArchive];
    [toolBar setImage:[UIImage imageNamed:@"deleteBtnDropbox"] forBtn:ToolBarBtnDelete];
    [toolBar setImage:[UIImage imageNamed:@"helpBtnDropbox"] forBtn:ToolBarBtnHelp];
    [toolBar setButtonTitleColor:[UIColor colorWithPatternImage:patternImage]];
}

- (id)init
{
    self = [super init];
    if (self)
    {        
        if (![DBSession sharedSession])
        {
            DBSession * session = [[DBSession alloc] initWithAppKey:DB_APP_KEY appSecret:DB_APP_SECRET root:kDBRootDropbox];
            [DBSession setSharedSession:session];
            [session release];
        }
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    [self customizeInterface];
    
    _internetConnection = [[Reachability reachabilityForInternetConnection] retain];
	[_internetConnection startNotifier];
    if ([_internetConnection currentReachabilityStatus] == NotReachable)
    {
        [self noConnection];
        return;
    }
    
    if ([[DBSession sharedSession] isLinked])
    {
        [super reloadFiles];
    }
    else
    {
        [[DBSession sharedSession] link];
    }
}

- (void) viewDidUnload
{
    [self clean];
    
    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    [self removeObservers];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLinkNotification) name:DB_LINK_NOTIFICATION object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self removeObservers];
}

- (void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DB_LINK_NOTIFICATION object:nil];
}

- (void) clean
{
    [self removeObservers];
    
    [_internetConnection release];
    
    self.filesToSend = nil;
    self.accauntInfo = nil;
    self.loadedMetadata = nil;
}

- (void) dealloc
{
    [self clean];
    
    self.restClient = nil;
    
    [super dealloc];
}

#pragma mark - load files for action

- (void) open:(FileObject *)file cellRect:(CGRect)cellRect
{
    NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:file.displayName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathInCache])
    {
        [super open:[FileObject fileWithPath:pathInCache] cellRect:cellRect];
    }
    else
    {
        _loadForOpen = true;
        openFileCellRect = cellRect;
        [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
        [self.restClient loadFile:file.path intoPath:pathInCache];
    }
}

- (void) saveToCameraRoll:(FileObject *)file
{
    NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:file.displayName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathInCache])
    {
        [super saveToCameraRoll:[FileObject fileWithPath:pathInCache]];
    }
    else
    {
        _loadForSave = true;
        [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
        [self.restClient loadFile:file.path intoPath:pathInCache];
    }
}

- (void) sendMail:(NSArray *)files
{
    _loadForSend = false;
    _filesToLoadCount = 0;
    self.filesToSend = [NSMutableSet set];
    
    for (FileObject * file in files)
    {
        if (file.isFolder)
        {
            continue;
        }
        
        NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:file.displayName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathInCache])
        {
            [_filesToSend addObject:[FileObject fileWithPath:pathInCache]];
        }
        else
        {
            _loadForSend = true;
            _filesToLoadCount ++;
            [appDelegate showProgressHUDWithText: NSLocalizedString(@"Downloading", nil)];
            [self.restClient loadFile:file.path intoPath:pathInCache];
        }
    }
    
    if (_filesToLoadCount == 0)
    {
        [super sendMail:_filesToSend];
    }
}

- (void) preview:(FileObject *)file
{
    if (!file.isFolder)
    {
        NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:file.displayName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathInCache])
        {
            [super preview:[FileObject fileWithPath:pathInCache]];
        }
        else
        {
            _loadForPreview = true;
            [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
            [self.restClient loadFile:file.path intoPath:pathInCache];
        }
    }
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
    if (_loadForOpen)
    {
        _loadForOpen = false;
        [appDelegate hideProgressHUD];
        [super open:[FileObject fileWithPath:destPath] cellRect:openFileCellRect];
        return;
    }
    else if (_loadForSave)
    {
        _loadForSave = false;
        [appDelegate hideProgressHUD];
        [super saveToCameraRoll:[FileObject fileWithPath:destPath]];
        return;
    }
    else if (_loadForPreview)
    {
        _loadForPreview = false;
        [appDelegate hideProgressHUD];
        [super preview:[FileObject fileWithPath:destPath]];
        return;
    }
    else if (_loadForSend)
    {
        static int loadedFilesCount = 0;
        loadedFilesCount ++;
        [_filesToSend addObject:[FileObject fileWithPath:destPath]];
        
        if (loadedFilesCount >= _filesToLoadCount)
        {
            _loadForSend = false;
            [appDelegate hideProgressHUD];
            loadedFilesCount = _filesToLoadCount = 0;
            
            [super sendMail:_filesToSend];
        }
        return;
    }
    else
    {
        if(_loadToCache)
        {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"displayName == %@", [destPath lastPathComponent]];
            NSSet * result = [[ClipboardManager sharedManager].files filteredSetUsingPredicate:predicate];
            
            if ([result count] != 1)
            {
                [[ClipboardManager sharedManager].destDelegate file:nil didPasteToCache:nil];
            }
            else
            {
                [[ClipboardManager sharedManager].destDelegate file:[result anyObject] didPasteToCache:destPath];
            }
        }
        else
        {
            [[ClipboardManager sharedManager].destDelegate fileDidPasteToFolder:true];
        }
    }
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
    if (_loadForOpen || _loadForPreview || _loadForPreview)
    {
        _loadForOpen = false;
        _loadForPreview = false;
        _loadForSend = false;
        [appDelegate hideProgressHUD];
    }
    else
    {
        if(_loadToCache)
        {
            [[ClipboardManager sharedManager].destDelegate file:nil didPasteToCache:nil];
        }
        else
        {
            [[ClipboardManager sharedManager].destDelegate fileDidPasteToFolder:false];
        }
    }
}


#pragma mark - load files & info

- (NSArray *) filesFromCurrentFolder
{    
    if (self.loadedMetadata)
    {
        NSMutableArray * files = [NSMutableArray array];
        
        for (DBMetadata * md in self.loadedMetadata.contents)
        {
            FileObject * file = [FileObject fileWithPath:md.path];
            file.isFolder = md.isDirectory;
            [files addObject:file];
        }
        
        self.loadedMetadata = nil;
        return files;
    }
    else
    {
        [self.restClient loadAccountInfo];
    }
    
    return nil;
}

- (long long) freeSpace
{
    if (_accauntInfo)
    {
        return _accauntInfo.quota.totalBytes - _accauntInfo.quota.totalConsumedBytes;
    }
    
    return 0;
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    self.loadedMetadata = metadata;
    [super reloadFiles];
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
    [self noConnection];
}

- (void)restClient:(DBRestClient *)client loadedAccountInfo:(DBAccountInfo *)info
{
    self.accauntInfo = info;
    [self.restClient loadMetadata:super.currentFolder.path];
}

- (void)restClient:(DBRestClient*)client loadAccountInfoFailedWithError:(NSError*)error
{
    [self noConnection];
}

- (FileSource)fileSource
{
    return FileSourceDropbox;
}

#pragma mark - paste

- (void) paste:(FileObject *)file overWrite:(bool)overWrite
{
    if (![[DBSession sharedSession] isLinked])
    {
        [self noAuthorization];
        return;
    }
    
    NSString * newPath = [super.currentFolder.path stringByAppendingPathComponent:file.pasteName];
    
    if ([super isFileNameInCurrentFolder:file.pasteName])
    {
        if(overWrite)
        {
            _removeForOverwrite = true;
            [self.restClient deletePath:newPath];
        }
        else
        {
            [self finishPaste:true];
        }
    }
    else
    {
        [self pasteToDB:file newPath:newPath];
    }
}

- (void) pasteToDB:(FileObject *)file newPath:(NSString *)newPath
{
    if ([ClipboardManager sharedManager].source == FileSourceFolder)
    {
        if (file.isFolder)
        {
            [super finishPaste:false];
            return;
        }
        
        _uploadNewFile = false;
        [self.restClient uploadFile:@"" toPath:newPath withParentRev:nil fromPath:file.path];
    }
    else if ([ClipboardManager sharedManager].source == FileSourceDropbox)
    {
        if ([ClipboardManager sharedManager].mode == ClipboardModeCopy)
        {
            [self.restClient copyFrom:file.path toPath:newPath];
        }
        else if ([ClipboardManager sharedManager].mode == ClipboardModeCut)
        {
            _moveForRename = false;
            [self.restClient moveFrom:file.path toPath:newPath];
        }
    }
    else
    {
        [ClipboardManager sharedManager].destDelegate = self;
        [[ClipboardManager sharedManager].sourceDelegate needPasteToCacheFile:file];
    }
}

- (void)restClient:(DBRestClient*)client copiedPath:(NSString *)from_path toPath:(NSString *)to_path
{
    [super finishPaste:true];
}

- (void)restClient:(DBRestClient*)client copyPathFailedWithError:(NSError*)error
{
    [super finishPaste:false];
}

- (void)restClient:(DBRestClient*)client movedPath:(NSString *)from_path toPath:(NSString *)to_path
{
    if (_moveForRename)
    {
        [super doneAction:true];
    }
    else
    {
        [super finishPaste:true];
    }
}

- (void)restClient:(DBRestClient*)client movePathFailedWithError:(NSError*)error
{
    if (_moveForRename)
    {
        [super doneAction:false];
    }
    else
    {
        [super finishPaste:false];
    }
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
{
    if (_uploadNewFile)
    {
        [super doneAction:true];
    }
    else
    {
        [super finishPaste:true];
    }
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    if (_uploadNewFile)
    {
        [super doneAction:false];
    }
    else
    {
        [super finishPaste:false];
    }
}

#pragma mark - delete

- (void) remove:(FileObject *)file
{
    _removeForOverwrite = false;
    [self.restClient deletePath:file.path];
}

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path
{
    if (_removeForOverwrite)
    {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"pasteName == %@", [path lastPathComponent]];
        NSSet * result = [[ClipboardManager sharedManager].files filteredSetUsingPredicate:predicate];
        
        if ([result count] != 1)
        {
            [super finishPaste:false];
        }
        else
        {
            [self pasteToDB:[result anyObject] newPath:path];
        }
    }
    else
    {
        [super doneAction:true];
    }
}

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error
{
    if (_removeForOverwrite)
    {
        [super finishPaste:false];
    }
    else
    {
        [super doneAction:false];
    }
}

#pragma mark - new

- (void) newFolder:(NSString *)name
{
    if (![[DBSession sharedSession] isLinked])
    {
        [self noAuthorization];
        return;
    }
    
    NSString * newPath = [self.currentFolder.path stringByAppendingPathComponent:name];
    [self.restClient createFolder:newPath];
}

- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder
{
    [super doneAction:true];
}

- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error
{
    [super doneAction:false];
}

- (void) newFile:(NSString *)name content:(NSData *)content
{
    if (![[DBSession sharedSession] isLinked])
    {
        [self noAuthorization];
        return;
    }
    
    NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:name];
    
    [[NSFileManager defaultManager] removeItemAtPath:pathInCache error:nil];
    [[NSFileManager defaultManager] createFileAtPath:pathInCache contents:content attributes:nil];
    
    _uploadNewFile = true;
    NSString * newPath = [self.currentFolder.path stringByAppendingPathComponent:name];
    [self.restClient uploadFile:@"" toPath:newPath withParentRev:nil fromPath:pathInCache];
}

#pragma mark - rename

- (void) rename:(FileObject *)file newName:(NSString *)newName
{
    _moveForRename = true;
    NSString * newPath = [self.currentFolder.path stringByAppendingPathComponent:newName];
    [self.restClient moveFrom:file.path toPath:newPath];
}

#pragma mark - ClipboardDestinationDelegate

- (void) file:(FileObject *)file didPasteToCache:(NSString *)pathInCache
{
    if (pathInCache)
    {
        NSString * newPath = [self.currentFolder.path stringByAppendingPathComponent:file.pasteName];
        [self.restClient uploadFile:@"" toPath:newPath withParentRev:nil fromPath:pathInCache];
    }
    else
    {
        [super finishPaste:false];
    }
}

#pragma mark - ClipboardSourceDelegate

- (void) needPasteToCacheFile:(FileObject *)file
{
    if (file.isFolder)
    {
        [[ClipboardManager sharedManager].destDelegate file:file didPasteToCache:nil];
        return;
    }
    
    NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:file.displayName];
    [[NSFileManager defaultManager] removeItemAtPath:pathInCache error:nil];
    
    _loadToCache = true;
    [self.restClient loadFile:file.path atRev:nil intoPath:pathInCache];
}

- (void) needPasteToFolderFile:(FileObject *)file newPath:(NSString *)newPath overWrite:(bool)overWrite
{
    if (file.isFolder)
    {
        [[ClipboardManager sharedManager].destDelegate fileDidPasteToFolder:false];
        return;
    }
    
    if (overWrite)
    {
        [[NSFileManager defaultManager] removeItemAtPath:newPath error:nil];
    }
    
    _loadToCache = false;
    [self.restClient loadFile:file.path atRev:nil intoPath:newPath];
}

#pragma mark - reachability

- (void) reachabilityChanged: (NSNotification* )notification
{
	Reachability * reach = [notification object];
	NetworkStatus netStatus = [reach currentReachabilityStatus];
        
    if (netStatus == NotReachable)
    {
        [self noConnection];
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
