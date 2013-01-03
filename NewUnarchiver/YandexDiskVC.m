//
//  YandexDiskVC.m
//  NewUnarchiver
//
//  Created by Zhenya Koval on 02.11.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//
#import "config.h"
#import "YandexDiskVC.h"
#import "FolderVC.h"
#import "DataURLConnection.h"

static NSString * yandexToken;

#define API_URL             @"https://webdav.yandex.ru"


@interface YandexDiskVC ()

@property (nonatomic, retain) WebDavClient * wdClient;
@property (nonatomic, retain) NSMutableSet * filesToSend;
@property (nonatomic, retain) NSArray * loadedFileList;
@property (nonatomic, retain) NSString * currentXMLName; // for parscing response from "free space request"

@end

@implementation YandexDiskVC

+ (void) logOut
{
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:YANDEX_TOKEN_KEY];
    yandexToken = nil;
}

- (void) noAuthorization
{
    [appDelegate showQuickMesage:NSLocalizedString(@"Need authorization", nil)];
    [super doneAction:false];
}

- (void) noConnection
{
    toolBar.userInteractionEnabled = false;
    navBar.userInteractionEnabled = false;
    
    NSString * message = [[NSString alloc] initWithFormat:@"%@ disk.yandex.ru", NSLocalizedString(@"Unarchiver could not connect to", nil)];
    [appDelegate showQuickMesage:message];
    [message release];
    
    [appDelegate hideProgressHUD];
    [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:true] afterDelay:1];
}

- (void) getToken
{
    NSString * strURL = [NSString stringWithFormat:@"https://oauth.yandex.ru/authorize?response_type=token&client_id=%@", YANDEX_CLIENT_ID];
    NSURL * url = [NSURL URLWithString:strURL];
    
    [[UIApplication sharedApplication] openURL:url];
}

- (void) finishGettingToken
{
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"link_yandex"];
    yandexToken = [[NSUserDefaults standardUserDefaults] valueForKey:YANDEX_TOKEN_KEY];
    [super reloadFiles];
}

- (WebDavClient*) wdClient
{
    if (!_wdClient)
    {
        NSURL * url = [NSURL URLWithString:API_URL];
        _wdClient = [[WebDavClient alloc] initWithURL:url token:yandexToken];
        _wdClient.delegate = self;
    }
    
    return _wdClient;
}

#pragma mark -
#pragma mark - View lifecycle

- (void) customizeInterface
{
    UIImage * patternImage = [UIImage imageNamed:@"yandexBorder"];
    [self setImageBorder:patternImage];

    [navBar setBackgroundImage:[UIImage imageNamed:@"navBarBG"]];
    [navBar setIconImage:[UIImage imageNamed:@"yandexNavBarIcon"]];
    [navBar setBackButtonImage:[UIImage imageNamed:@"backBtnYandex"]];
    [navBar setViewModeButtonImage:[UIImage imageNamed:@"listBtnYandex"]];
    [navBar setSettingsButtonImage:[UIImage imageNamed:@"settingsBtnYandex"]];
    [navBar setPreviewButtonImage:[UIImage imageNamed:@"previewBtnYandex"]];
    [navBar setLabelTextColor:[UIColor colorWithPatternImage:patternImage]];
    
    [toolBar setImage:[UIImage imageNamed:@"addBtnYandex"] forBtn:ToolBarBtnAdd];
    [toolBar setImage:[UIImage imageNamed:@"shareBtnYandex"] forBtn:ToolBarBtnShare];
    [toolBar setImage:[UIImage imageNamed:@"ccpBtnYandex"] forBtn:ToolBarBtnCCP];
    [toolBar setImage:[UIImage imageNamed:@"archiveBtnYandex"] forBtn:ToolBarBtnArchive];
    [toolBar setImage:[UIImage imageNamed:@"deleteBtnYandex"] forBtn:ToolBarBtnDelete];
    [toolBar setImage:[UIImage imageNamed:@"helpBtnYandex"] forBtn:ToolBarBtnHelp];
    [toolBar setButtonTitleColor:[UIColor colorWithPatternImage:patternImage]];
}

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
    
    if (!yandexToken)
    {
        yandexToken = [[NSUserDefaults standardUserDefaults] valueForKey:YANDEX_TOKEN_KEY];
    }
    
    if (yandexToken)
    {        
        [super reloadFiles];
    }
    else
    {
        [self getToken];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishGettingToken) name:YANDEX_TOKEN_NOTIFICATION object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self removeObservers];
}

- (void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YANDEX_TOKEN_NOTIFICATION object:nil];
}

- (void) clean
{
    [self removeObservers];
    
    [_internetConnection release];
    self.filesToSend = nil;
}

- (void) dealloc
{
    [self clean];
    
    self.wdClient = nil;
    
    [super dealloc];
}

#pragma mark - load files for action

- (void) open:(FileObject *)file cellRect:(CGRect)cellRect
{
    NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:file.path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathInCache])
    {
        [super open:[FileObject fileWithPath:pathInCache] cellRect:cellRect];
    }
    else
    {
        _loadForOpen = true;
        openFileCellRect = cellRect;
        [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
        [self.wdClient download:file.path to:pathInCache];
    }
}

- (void) saveToCameraRoll:(FileObject *)file
{
    NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:file.path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathInCache])
    {
        [super saveToCameraRoll:[FileObject fileWithPath:pathInCache]];
    }
    else
    {
        _loadForSave = true;
        [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
        [self.wdClient download:file.path to:pathInCache];
    }
}

- (void) sendMail:(NSSet *)files
{
    _filesToLoadCount = 0;
    _loadForSend = false;
    self.filesToSend = [NSMutableSet set];
    
    for (FileObject * file in files)
    {
        if (file.isFolder)
        {
            continue;
        }
        
        NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:file.path];
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathInCache])
        {
            [self.filesToSend addObject:[FileObject fileWithPath:pathInCache]];
        }
        else
        {
            _loadForSend = true;
            _filesToLoadCount ++;
            [appDelegate showProgressHUDWithText: NSLocalizedString(@"Downloading", nil)];
            [self.wdClient download:file.path to:pathInCache];
        }
    }
    
    if (_filesToLoadCount == 0)
    {
        [super sendMail:self.filesToSend];
    }
}

- (void) preview:(FileObject *)file
{
    if (!file.isFolder)
    {
        NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:file.path];
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathInCache])
        {
            [super preview:[FileObject fileWithPath:pathInCache]];
        }
        else
        {
            _loadForPreview = true;
            [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
            [self.wdClient download:file.path to:pathInCache];
        }
    }
}

- (void)webDavClient:(WebDavClient *)webDavClient didFinishDownloading:(NSString *)destPath
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
        [self.filesToSend addObject:[FileObject fileWithPath:destPath]];
        
        if (loadedFilesCount >= _filesToLoadCount)
        {
            _loadForSend = false;
            [appDelegate hideProgressHUD];
            loadedFilesCount = _filesToLoadCount = 0;
            
            [super sendMail:self.filesToSend];
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

- (void)webDavClient:(WebDavClient *)webDavClient downloadingError:(NSError *)error
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

#pragma mark - paste

- (void) paste:(FileObject *)file overWrite:(bool)overWrite
{
    if (!yandexToken)
    {
        [self noAuthorization];
        return;
    }
    
    NSString * newPath = [self.currentFolder.path stringByAppendingPathComponent:file.pasteName];
    if ([self isFileNameInCurrentFolder:file.pasteName])
    {
        if (overWrite)
        {
            _removeForOverwrite = true;
            [self.wdClient remove:newPath];
        }
        else
        {
            [self finishPaste:true];
        }
    }
    else
    {
        [self pasteToYandex:file newPath:newPath];
    }
}

- (void) pasteToYandex:(FileObject *)file newPath:(NSString *)newPath
{
    if ([ClipboardManager sharedManager].source == FileSourceFolder)
    {
        if (file.isFolder)
        {
            [super finishPaste:false];
            return;
        }
        
        _uploadNewFile = false;
        [self.wdClient upload:file.path to:newPath];
    }
    else if ([ClipboardManager sharedManager].source == FileSourceYandex)
    {
        if ([ClipboardManager sharedManager].mode == ClipboardModeCopy)
        {
            [self.wdClient copy:file.path to:newPath];
        }
        else if ([ClipboardManager sharedManager].mode == ClipboardModeCut)
        {
            _moveForRename = false;
            [self.wdClient move:file.path to:newPath];
        }
    }
    else
    {
        [ClipboardManager sharedManager].destDelegate = self;
        [[ClipboardManager sharedManager].sourceDelegate needPasteToCacheFile:file];
    }
}

- (void)didFinishCopying:(WebDavClient *)webDavClient
{
    [super finishPaste:true];
}

- (void)webDavClient:(WebDavClient *)webDavClient copyingError:(NSError *)error
{
    [super finishPaste:false];
}

- (void)didFinishMoving:(WebDavClient *)webDavClient
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

- (void)webDavClient:(WebDavClient *)webDavClient movingError:(NSError *)error
{
    if (_moveForRename)
    {
        [super doneAction:false];
    }
    else
    {
        [super finishPaste:true];
    }
}

- (void)didFinishUploading:(WebDavClient *)webDavClient
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

- (void)webDavClient:(WebDavClient *)webDavClient uploadingError:(NSError *)error
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
    [self.wdClient remove:file.path];
}

- (void)webDavClient:(WebDavClient *)webDavClient didFinishRemoving:(NSString *)path
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
            [self pasteToYandex:[result anyObject] newPath:path];
        }
    }
    else
    {
        [super doneAction:true];
    }
}

- (void)webDavClient:(WebDavClient *)webDavClient removingError:(NSError *)error
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
    if (!yandexToken)
    {
        [self noAuthorization];
        return;
    }
    
    NSString * newPath = [self.currentFolder.path stringByAppendingPathComponent:name];
    [self.wdClient createFolder:newPath];
}

- (void)didFinishCreatingFolder:(WebDavClient *)webDavClient
{
    [super doneAction:true];
}

- (void)webDavClient:(WebDavClient *)webDavClient creatingFolderError:(NSError *)error
{
    [super doneAction:false];
}

- (void) newFile:(NSString *)name content:(NSData *)content
{
    if (!yandexToken)
    {
        [self noAuthorization];
        return;
    }
    
   NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:name];
    
    [[NSFileManager defaultManager] removeItemAtPath:pathInCache error:nil];
    [[NSFileManager defaultManager] createFileAtPath:pathInCache contents:content attributes:nil];
    
    _uploadNewFile = true;
    NSString * newPath = [self.currentFolder.path stringByAppendingPathComponent:name];
    [self.wdClient upload:pathInCache to:newPath];
}

#pragma mark - rename

- (void) rename:(FileObject *)file newName:(NSString *)newName
{
    _moveForRename = true;
    NSString * newPath = [self.currentFolder.path stringByAppendingPathComponent:newName];
    [self.wdClient move:file.path to:newPath];
}

#pragma mark - ClipboardDestinationDelegate

- (void) file:(FileObject *)file didPasteToCache:(NSString *)pathInCache
{
    if (pathInCache)
    {
        NSString * newPath = [self.currentFolder.path stringByAppendingPathComponent:file.pasteName];
        [self.wdClient upload:pathInCache to:newPath];
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
    [self.wdClient download:file.path to:pathInCache];
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
    [self.wdClient download:file.path to:newPath];
}

#pragma mark - load file list & get free space

- (NSArray *) filesFromCurrentFolder
{
    if (self.loadedFileList)
    {
        NSMutableArray * files = [NSMutableArray array];
        for (NSDictionary * item in self.loadedFileList)
        {
            NSString * path = [item valueForKey:WD_FILE_PATH_KEY];
    
            FileObject * file = [FileObject fileWithPath:path];
            file.isFolder = [[item valueForKey:WD_IS_FOLDER_KEY] boolValue];
            
            [files addObject:file];
        }
        
        self.loadedFileList = nil;
        return files;
    }
    else
    {
        [self getFreeSpace];
    }
    return nil;
}

- (void)webDavClient:(WebDavClient *)webDavClient didFinishLoadingFileList:(NSArray *)files
{
    self.loadedFileList = files;
    [super reloadFiles];
}

- (void)webDavClient:(WebDavClient *)webDavClient loadingFileListError:(NSError *)error
{
    [self noConnection];
}

- (long long) freeSpace
{
    return _spaceAmount - _spaceUsed;
}

- (FileSource)fileSource
{
    return FileSourceYandex;
}

- (void) getFreeSpace
{
    NSURL * url = [[NSURL alloc] initWithString:API_URL];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PROPFIND"];
    [request setValue:@"0" forHTTPHeaderField:@"Depth"];
    [request setValue:yandexToken forHTTPHeaderField:@"Authorization"];
    NSData * data = [@"<D:propfind xmlns:D=\"DAV:\"><D:prop><D:quota-available-bytes/><D:quota-used-bytes/></D:prop></D:propfind>" dataUsingEncoding:NSASCIIStringEncoding];
    [request setHTTPBody:data];
    
    DataURLConnection * loadingFileListConncetion = [[DataURLConnection alloc] initWithRequest:request delegate:self];
    [loadingFileListConncetion start];
    
    [request release];
    [url release];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    NSArray * parts = [[elementName lowercaseString] componentsSeparatedByString:@":"];
    self.currentXMLName = [parts lastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([_currentXMLName isEqualToString:@"quota-available-bytes"])
    {
        _spaceAmount = [string longLongValue];
    }
    else if ([_currentXMLName isEqualToString:@"quota-used-bytes"])
    {
        _spaceUsed = [string longLongValue];
    }
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    [self noConnection];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [self noConnection];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self.wdClient getFileListFrom:super.currentFolder.path];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{    
    DataURLConnection * connectionWithData = (DataURLConnection *)connection;
    connectionWithData.data = [NSMutableData data];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
    DataURLConnection * connectionWithData = (DataURLConnection *)connection;
    [connectionWithData.data appendData:d];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection release];
    
    [self noConnection];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{   
    _spaceUsed = _spaceAmount = 0;
    
    DataURLConnection * connectionWithData = (DataURLConnection *)connection;
    
    NSXMLParser *xmlParser = [[[NSXMLParser alloc] initWithData:connectionWithData.data] autorelease];
    [xmlParser setDelegate:self];
    [xmlParser parse];
    
    [connection release];
}

#pragma mark - reachability

- (void) reachabilityChanged: (NSNotification* )notification
{
	Reachability * curReach = [notification object];
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
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
