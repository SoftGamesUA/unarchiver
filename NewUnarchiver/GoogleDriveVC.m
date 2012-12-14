//
//  GoogleDriveVC.m
//  NewUnarchiver
//
//  Created by Zhenya Koval on 21.11.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "GoogleDriveVC.h"
#import "FolderVC.h"

#import "GTLDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import <MobileCoreServices/MobileCoreServices.h>

static GTLServiceDrive * googleDriveService = nil;

static NSString *const kKeychainItemName = @"Unarchiver: Google Drive";
static NSString *const kClientId = @"939292452411.apps.googleusercontent.com";
static NSString *const kClientSecret = @"KizndeLqnz04PqMZHIXIqNU6";

typedef void (^UploadBlock)(bool);
typedef void (^LoadFileToCacheBlock)(NSString *);

@interface GoogleDriveVC ()

@property (nonatomic, retain) GTLDriveFileList * googleFileList;

@end

@implementation GoogleDriveVC

- (void) noAuthorization
{
    [appDelegate showQuickMesage:NSLocalizedString(@"Need authorization", nil)];
    [super doneAction:false];
}

- (void) noConnection
{
    toolBar.userInteractionEnabled = false;
    navBar.userInteractionEnabled = false;
    
    NSString * message = [[NSString alloc] initWithFormat:@"%@ drive.google.com", NSLocalizedString(@"Unarchiver could not connect to", nil)];
    [appDelegate showQuickMesage:message];
    [message release];
    
    [appDelegate hideProgressHUD];
    [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:true] afterDelay:1];
}

- (GTLServiceDrive *)driveService
{
    if (!googleDriveService)
    {
        googleDriveService = [[GTLServiceDrive alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        googleDriveService.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        googleDriveService.retryEnabled = YES;
    }
    return googleDriveService;
}

- (void) startAuthorization
{
    SEL finishedSelector = @selector(viewController:finishedWithAuth:error:);
    GTMOAuth2ViewControllerTouch *authViewController =
    [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                               clientID:kClientId
                                           clientSecret:kClientSecret
                                       keychainItemName:kKeychainItemName
                                               delegate:self
                                       finishedSelector:finishedSelector];
    [appDelegate.window.rootViewController presentModalViewController:authViewController animated:YES];

}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    [appDelegate.window.rootViewController dismissModalViewControllerAnimated:YES];
    
    if (!error && auth)
    {
        [self finishAuthorization:auth];
    }
}

- (void)finishAuthorization:(GTMOAuth2Authentication *)auth
{
    [[self driveService] setAuthorizer:auth];
    _isAuthorized = true;
    
    [super reloadFiles];
}

- (NSString *)MIMETypeForPath:(NSString *)path
{
    CFStringRef pathExtension = (CFStringRef)[path pathExtension];
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);    
    NSString * mimeType = (NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    CFRelease(type);

    return [mimeType autorelease];
}

- (NSString *)pathExtensionForMIMEType:(NSString *)mimeType
{
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (CFStringRef)mimeType, NULL);
    NSString * extension = (NSString *)UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
    
    return [extension autorelease];
}

- (NSString *)MIMETypeGoogleDocType:(NSString *)type
{
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"application/vnd.openxmlformats-officedocument.wordprocessingml.document", @"application/vnd.google-apps.document",
                          @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", @"application/vnd.google-apps.spreadsheet",
                          @"image/png", @"application/vnd.google-apps.drawing",
                          @"application/vnd.openxmlformats-officedocument.presentationml.presentation", @"application/vnd.google-apps.presentation",nil];
    
    NSString * MIMEType = [dic objectForKey:type];
    if (!MIMEType)
    {
        MIMEType = @"application/pdf";
    }
    
    return MIMEType;
}

#pragma mark - View lifecycle

- (void) customizeInterface
{
    UIImage * patternImage = [UIImage imageNamed:@"googleBorder"];
    [self setImageBorder:patternImage];
    
    [navBar setBackgroundImage:[UIImage imageNamed:@"navBarBG"]];
    [navBar setIconImage:[UIImage imageNamed:@"googleNavBarIcon"]];
    [navBar setBackButtonImage:[UIImage imageNamed:@"backBtnGoogle"]];
    [navBar setViewModeButtonImage:[UIImage imageNamed:@"listBtnGoogle"]];
    [navBar setSettingsButtonImage:[UIImage imageNamed:@"settingsBtnGoogle"]];
    [navBar setPreviewButtonImage:[UIImage imageNamed:@"previewBtnGoogle"]];
    [navBar setLabelTextColor:[UIColor colorWithPatternImage:patternImage]];
    
    [toolBar setImage:[UIImage imageNamed:@"addBtnGoogle"] forBtn:ToolBarBtnAdd];
    [toolBar setImage:[UIImage imageNamed:@"shareBtnGoogle"] forBtn:ToolBarBtnShare];
    [toolBar setImage:[UIImage imageNamed:@"ccpBtnGoogle"] forBtn:ToolBarBtnCCP];
    [toolBar setImage:[UIImage imageNamed:@"archiveBtnGoogle"] forBtn:ToolBarBtnArchive];
    [toolBar setImage:[UIImage imageNamed:@"deleteBtnGoogle"] forBtn:ToolBarBtnDelete];
    [toolBar setImage:[UIImage imageNamed:@"helpBtnGoogle"] forBtn:ToolBarBtnHelp];
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
    
    _isAuthorized = false;
    GTMOAuth2Authentication * auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientId
                                                      clientSecret:kClientSecret];
    
    if ([auth canAuthorize])
    {
        [self finishAuthorization:auth];
    }
    else
    {
        [self startAuthorization];
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
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self removeObservers];
}

- (void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void) clean
{
    [self removeObservers];
    
    [_internetConnection release];
    
    self.googleFileList = nil;
}

- (void) dealloc
{
    [self clean];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - load files for action

- (void) loadFileToCache:(FileObject *)file  overWrite:(bool)overWrite finishBlock:(LoadFileToCacheBlock)finishBlock
{
    NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:file.displayName];    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathInCache])
    {
        if (overWrite)
        {
            [[NSFileManager defaultManager] removeItemAtPath:pathInCache error:nil];
        }
        else
        {
            finishBlock(pathInCache);
            return;
        }
    }
    
    GTMHTTPFetcher * fetcher = [[self driveService].fetcherService fetcherWithURLString:file.path];
    [fetcher beginFetchWithCompletionHandler:^(NSData * data, NSError * error)
    {
        if (error == nil)
        {
            [data writeToFile:pathInCache atomically:true];
            finishBlock(pathInCache);
        }
        else
        {
            finishBlock(nil);
        }
    }];
}

- (void) open:(FileObject *)file cellRect:(CGRect)cellRect
{
    LoadFileToCacheBlock finishBlock = ^(NSString * pathInCache)
    {
        [appDelegate hideProgressHUD];
        if (pathInCache)
        {
            [super open:[FileObject fileWithPath:pathInCache] cellRect:cellRect];
        }
    };
    
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
    [self loadFileToCache:file overWrite:false finishBlock:finishBlock];
}

- (void) saveToCameraRoll:(FileObject *)file
{
    LoadFileToCacheBlock finishBlock = ^(NSString * pathInCache)
    {
        [appDelegate hideProgressHUD];
        if (pathInCache)
        {
            [super saveToCameraRoll:[FileObject fileWithPath:pathInCache]];
        }
    };
    
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
    [self loadFileToCache:file overWrite:false finishBlock:finishBlock];
}

- (void) sendMail:(NSSet *)files
{
    [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
 
    __block int filesToLoadCount = [files count];
    NSMutableSet * loadedFiles = [NSMutableSet set];
    
    for (FileObject * file in files)
    {        
        LoadFileToCacheBlock finishBlock = ^(NSString * pathInCache)
        {
            if (pathInCache)
            {
                [loadedFiles addObject:[FileObject fileWithPath:pathInCache]];
            }
            else
            {
                filesToLoadCount --;
            }
            
            if ([loadedFiles count] == filesToLoadCount)
            {
                [appDelegate hideProgressHUD];
                [super sendMail:loadedFiles];
            }
        };
        
        if (file.isFolder)
        {
            finishBlock(nil);
            continue;
        }
        
        [self loadFileToCache:file overWrite:false finishBlock:finishBlock];
    }
}

- (void) preview:(FileObject *)file
{
    if (!file.isFolder)
    {
        LoadFileToCacheBlock finishBlock = ^(NSString * pathInCache)
        {
            [appDelegate hideProgressHUD];
            if (pathInCache)
            {
                [super preview:[FileObject fileWithPath:pathInCache]];
            }
        };
        
        [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
        [self loadFileToCache:file overWrite:false finishBlock:finishBlock];
    }
}

#pragma mark - FileVC methods

- (NSArray *) filesFromCurrentFolder
{    
    if (!self.googleFileList)
    {
        [self getFreeSpace];
    }
    else
    {
        NSMutableArray * files = [NSMutableArray array];
        for (GTLDriveFile * item in self.googleFileList.items)
        {
            if ([item.labels.trashed boolValue])    continue;
            
            FileObject * file = [[FileObject alloc] init];
            file.ID = item.identifier;
            file.isFolder = [item.mimeType isEqualToString:@"application/vnd.google-apps.folder"];
            
            if (file.isFolder)
            {
                file.displayName = item.title;
            }
            else if (item.downloadUrl)
            {
                file.path = item.downloadUrl;
                file.displayName = item.title;
            }
            else if (item.exportLinks)
            {
                NSString * MIMEType = [self MIMETypeGoogleDocType:item.mimeType];
                NSString * path = [item.exportLinks JSONValueForKey:MIMEType];
                if (!path)
                {
                    continue;
                }
                
                file.path = path;
                NSString * ext = [self pathExtensionForMIMEType:MIMEType];
                file.displayName = [[item.title stringByDeletingPathExtension] stringByAppendingPathExtension:ext];
            }
            else
            {
                continue;
            }
            
            [files addObject:file];
        }
        self.googleFileList = nil;
        return files;
    }
    return nil;
}

- (long long) freeSpace
{
    return _spaceAmount - _spaceUsed;
}

- (id) clipboardUserInfo
{
    return nil;
}

- (FileSource)fileSource
{
    return FileSourceGoogle;
}

- (bool) canWorkWithArchives
{
    return false;
}

- (void) remove:(FileObject *)file
{
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesDeleteWithFileId:file.ID];
    [[self driveService] executeQuery:query completionHandler:^(GTLServiceTicket * ticket, id nilObject, NSError * error)
    {
        [super doneAction:(error == nil)];
    }];
}

- (void) paste:(FileObject *)file overWrite:(bool)overWrite
{
    if (!_isAuthorized)
    {
        [self noAuthorization];
        return;
    }
    
    if ([self isFileNameInCurrentFolder:file.pasteName])
    {
        if (overWrite)
        {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"displayName == %@", file.pasteName];
            NSArray * result = [self.currentFileList filteredArrayUsingPredicate:predicate];
            if ([result count] != 1)
            {
                [super finishPaste:false];
                return;
            }
        
            FileObject * fileToRemove = [result objectAtIndex:0];
            GTLQueryDrive *query = [GTLQueryDrive queryForFilesDeleteWithFileId:fileToRemove.ID];
            [[self driveService] executeQuery:query completionHandler:^(GTLServiceTicket * ticket, id nilObject, NSError * error)
             {
                 if (error == nil)
                 {
                     [self pasteToGoogle:file];
                 }
                 else
                 {
                     [super finishPaste:false];
                 }
             }];
        }
        else
        {
            [super finishPaste:true];
        }

    }
    else
    {
        [self pasteToGoogle:file];
    }

}

- (void) newFolder:(NSString *)name
{
    if (!_isAuthorized)
    {
        [self noAuthorization];
        return;
    }
           
    GTLDriveFile * folderObj = [GTLDriveFile object];
    folderObj.title = name;
    folderObj.mimeType = @"application/vnd.google-apps.folder";
    
    GTLDriveParentReference *parentRef = [GTLDriveParentReference object];
    parentRef.identifier = self.currentFolder.ID;
    folderObj.parents = [NSArray arrayWithObject:parentRef];
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:folderObj uploadParameters:nil];
    [[self driveService] executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile *folderItem, NSError *error)
    {
        [super doneAction:(error == nil)];
    }];
}

- (void) newFile:(NSString *)name content:(NSData *)content
{
    if (!_isAuthorized)
    {
        [self noAuthorization];
        return;
    }
    
    UploadBlock finishBlock = ^(bool success)
    {
        [super finishPaste:success];
    };
    
    NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:name];
    [[NSFileManager defaultManager] removeItemAtPath:pathInCache error:nil];
    [[NSFileManager defaultManager] createFileAtPath:pathInCache contents:content attributes:nil];

    FileObject * newFile = [FileObject fileWithPath:pathInCache];
    newFile.pasteName = name;
    
    [self uploadFile:newFile finishBlock:finishBlock];
}

- (void) rename:(FileObject *)file newName:(NSString *)newName
{
    GTLDriveFile * newFile = [GTLDriveFile object];
    newFile.title = newName;
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesPatchWithObject:newFile fileId:file.ID];
    [[self driveService] executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile *folderItem, NSError *error)
     {
         [super doneAction:(error == nil)];
     }];
}


#pragma mark - get free space

- (void)getFreeSpace
{
    GTLQueryDrive *query = [GTLQueryDrive queryForAboutGet];
    [[self driveService] executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveAbout *about, NSError *error)
    {
        if (error == nil)
        {
            _spaceAmount = [about.quotaBytesTotal longLongValue];
            _spaceUsed = [about.quotaBytesUsed longLongValue];
            
            GTLQueryDrive * query = [GTLQueryDrive queryForFilesList];
            query.q = [NSString stringWithFormat:@"'%@' in parents", super.currentFolder.ID];
            [[self driveService] executeQuery:query completionHandler:^(GTLServiceTicket * ticket, GTLDriveFileList * fileList, NSError * error)
             {
                 if (error == nil)
                 {
                     self.googleFileList = fileList;
                     [super reloadFiles];
                 }
                 else
                 {
                     [self noConnection];
                 }
             }];
        }
        else
        {
            [self noConnection];
        }
        
    }];
    
}

#pragma mark - paste

- (void) pasteToGoogle:(FileObject *)file
{
    if ([ClipboardManager sharedManager].source == FileSourceFolder)
    {
        if (file.isFolder)
        {
            [super finishPaste:false];
            return;
        }
        
        UploadBlock finishBlock = ^(bool success)
        {
             [super finishPaste:success];
        };
        
        [self uploadFile:file finishBlock:finishBlock];

    }
    else if ([ClipboardManager sharedManager].source == FileSourceGoogle)
    {        
        if ([ClipboardManager sharedManager].mode == ClipboardModeCopy)
        {
            GTLDriveFile * copy = [GTLDriveFile object];
            GTLDriveParentReference * parentRef = [GTLDriveParentReference object];
            parentRef.identifier = self.currentFolder.ID;
            copy.parents = [NSArray arrayWithObject:parentRef];
            copy.title = file.pasteName;
            
            GTLQueryDrive *query = [GTLQueryDrive queryForFilesCopyWithObject:copy fileId:file.ID];
            [[self driveService] executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile *copiedFile, NSError *error)
            {
                [super finishPaste:(error == nil)];
            }];
        }
        else if ([ClipboardManager sharedManager].mode == ClipboardModeCut)
        {
            GTLDriveFile * patchFile = [GTLDriveFile object];
            GTLDriveParentReference * parentRef = [GTLDriveParentReference object];
            parentRef.identifier = self.currentFolder.ID;
            patchFile.parents = [NSArray arrayWithObject:parentRef];
            
            GTLQueryDrive *query = [GTLQueryDrive queryForFilesPatchWithObject:patchFile fileId:file.ID];
            [[self driveService] executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile *folderItem, NSError *error)
             {
                 [super finishPaste:(error == nil)];
             }];
        }
    }
    else
    {
        [ClipboardManager sharedManager].destDelegate = self;
        [[ClipboardManager sharedManager].sourceDelegate needPasteToCacheFile:file];
    }
}

- (void) uploadFile:(FileObject *)file finishBlock:(UploadBlock)finishBlock
{
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:file.path];
    if (fileHandle)
    {
        NSString * MIMEType = [self MIMETypeForPath:file.path];
        GTLUploadParameters * uploadParameters = [GTLUploadParameters uploadParametersWithFileHandle:fileHandle MIMEType:MIMEType];
        GTLDriveFile * newFile = [GTLDriveFile object];
        newFile.title = file.pasteName;
        GTLDriveParentReference * parentRef = [GTLDriveParentReference object];
        parentRef.identifier = self.currentFolder.ID;
        newFile.parents = [NSArray arrayWithObject:parentRef];
        
        GTLQueryDrive * query = [GTLQueryDrive queryForFilesInsertWithObject:newFile uploadParameters:uploadParameters];
        [[self driveService] executeQuery:query completionHandler:^(GTLServiceTicket * ticket, GTLDriveFile * uploadedFile, NSError * error)
         {
             finishBlock(error == nil);
         }];
    }
}

#pragma mark - ClipboardDestinationDelegate

- (void) file:(FileObject *)file didPasteToCache:(NSString *)pathInCache
{     
     if (!pathInCache)
     {
        [super finishPaste:false];
        return;
     }
    
    UploadBlock finishBlock = ^(bool success)
    {
        [super finishPaste:success];
    };
    
    FileObject * newFile = [FileObject fileWithPath:pathInCache];
    newFile.pasteName = file.pasteName;
    [self uploadFile:newFile finishBlock:finishBlock];
}

#pragma mark - ClipboardSourceDelegate

- (void) needPasteToCacheFile:(FileObject *)file
{
    if (file.isFolder)
    {
        [[ClipboardManager sharedManager].destDelegate file:file didPasteToCache:nil];
        return;
    }
    
    LoadFileToCacheBlock finishBlock = ^(NSString * pathInCache)
    {
        if (pathInCache)
        {
             [[ClipboardManager sharedManager].destDelegate file:file didPasteToCache:pathInCache];
        }
    };
    
    [self loadFileToCache:file overWrite:false finishBlock:finishBlock];
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
    
    GTMHTTPFetcher * fetcher = [[self driveService].fetcherService fetcherWithURLString:file.path];
    [fetcher beginFetchWithCompletionHandler:^(NSData * data, NSError * error)
    {
        if (error == nil)
        {
            [data writeToFile:newPath atomically:true];
            [[ClipboardManager sharedManager].destDelegate fileDidPasteToFolder:true];
        }
        else
        {
            [[ClipboardManager sharedManager].destDelegate fileDidPasteToFolder:false];
        }
    }];
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

@end
