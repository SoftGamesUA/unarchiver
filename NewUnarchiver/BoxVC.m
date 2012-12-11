
//
//  BoxVC.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 22.10.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "BoxVC.h"
#import "FolderVC.h"

#import "BoxAPIKey.h"
#import "BoxFolder.h"
#import "BoxDeleteOperation.h"
#import "BoxCreateFolderOperation.h"
#import "BoxRenameOperation.h"
#import "BoxUploadOperation.h"
#import "BoxLoginViewController.h"
#import "BoxDownloadOperation.h"
#import "BoxCopyOperation.h"
#import "BoxMoveOperation.h"
#import "BoxLoginViewController.h"
#import "BoxNetworkOperationManager.h"

#import "DataURLConnection.h"

typedef void(^BoxGetFolderByPathCompletionHandler)(BoxFolder * folder);
typedef void(^BoxDeleteCompletionHandler)();

@interface BoxVC () <BoxLoginViewControllerDelegate>

@property (nonatomic, retain) BoxFolder * loadedBoxFolder;

@property (nonatomic, retain) NSString * currentXMLName; // for parscing response from "free space request"

@end

@implementation BoxVC

- (void) noAuthorization
{
    [appDelegate showQuickMesage:NSLocalizedString(@"Need authorization", nil)];
    [super doneAction:false];
}

- (void) noConnection
{
    toolBar.userInteractionEnabled = false;
    navBar.userInteractionEnabled = false;
    
    NSString * message = [[NSString alloc] initWithFormat:@"%@ box.com", NSLocalizedString(@"Unarchiver could not connect to", nil)];
    [appDelegate showQuickMesage:message];
    [message release];
    
    [appDelegate hideProgressHUD];
    [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:true] afterDelay:1];
}

- (NSString *) typeOf:(FileObject *) file
{
    if (file.isFolder)
    {
        return @"folder";
    }
    
    return @"file";
}

#pragma mark - BoxLoginDelegate Methods

- (void)boxLoginViewController:(BoxLoginViewController *)boxLoginViewController didFinishWithResult:(LoginResult)result
{
    boxLoginViewController.navigationItem.leftBarButtonItem = nil;
    [appDelegate.window.rootViewController dismissModalViewControllerAnimated:YES];

    if (result == LoginSuccess)
    {
        [super reloadFiles];
    }
}

#pragma mark - View lifecycle

- (void) customizeInterface
{
    UIImage * patternImage = [UIImage imageNamed:@"boxnetBorder"];
    [self setImageBorder:patternImage];
    
    [navBar setBackgroundImage:[UIImage imageNamed:@"navBarBG"]];
    [navBar setIconImage:[UIImage imageNamed:@"boxnetNavBarIcon"]];
    [navBar setBackButtonImage:[UIImage imageNamed:@"backBtnBoxnet"]];
    [navBar setViewModeButtonImage:[UIImage imageNamed:@"listBtnBoxnet"]];
    [navBar setSettingsButtonImage:[UIImage imageNamed:@"settingsBtnBoxnet"]];
    [navBar setPreviewButtonImage:[UIImage imageNamed:@"previewBtnBoxnet"]];
    [navBar setLabelTextColor:[UIColor colorWithPatternImage:patternImage]];
    
    [toolBar setImage:[UIImage imageNamed:@"addBtnBoxnet"] forBtn:ToolBarBtnAdd];
    [toolBar setImage:[UIImage imageNamed:@"shareBtnBoxnet"] forBtn:ToolBarBtnShare];
    [toolBar setImage:[UIImage imageNamed:@"ccpBtnBoxnet"] forBtn:ToolBarBtnCCP];
    [toolBar setImage:[UIImage imageNamed:@"archiveBtnBoxnet"] forBtn:ToolBarBtnArchive];
    [toolBar setImage:[UIImage imageNamed:@"deleteBtnBoxnet"] forBtn:ToolBarBtnDelete];
    [toolBar setImage:[UIImage imageNamed:@"helpBtnBoxnet"] forBtn:ToolBarBtnHelp];
    [toolBar setButtonTitleColor:[UIColor colorWithPatternImage:patternImage]];
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
    
    if ([BoxLoginViewController userSignedIn])
    {
        [super reloadFiles];
    }
    else
    {
        BoxLoginViewController * vc = [BoxLoginViewController loginViewControllerWithNavBar:YES];
        vc.boxLoginDelegate = self;
        
        [appDelegate.window.rootViewController presentModalViewController:vc animated:true];
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
    
    self.currentFolder = nil;
    self.currentXMLName = nil;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
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
        BoxOperationCompletionHandler finishBlock = ^(BoxOperation * op, BoxOperationResponse response)
        {
            [appDelegate hideProgressHUD];
            if (response == BoxOperationResponseSuccessful)
            {
                [super open:[FileObject fileWithPath:pathInCache] cellRect:cellRect];
            }
        };
        
        [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
        
        BoxDownloadOperation * downloadOp = [BoxDownloadOperation operationForFileID:file.ID toPath:pathInCache];
        [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:downloadOp onCompletetion:finishBlock];
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
        BoxOperationCompletionHandler finishBlock = ^(BoxOperation * op, BoxOperationResponse response)
        {
            [appDelegate hideProgressHUD];
            if (response == BoxOperationResponseSuccessful)
            {
                [super saveToCameraRoll:[FileObject fileWithPath:pathInCache]];
            }
        };
        
        [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
        
        BoxDownloadOperation * downloadOp = [BoxDownloadOperation operationForFileID:file.ID toPath:pathInCache];
        [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:downloadOp onCompletetion:finishBlock];
    }
}

- (void) sendMail:(NSSet *)files
{
    __block int filesToSendCount = 0;
    NSMutableSet * loadedFiles = [NSMutableSet set];
    
    for (FileObject * file in files)
    {
        if (file.isFolder) continue;
        
        filesToSendCount++;
        
        NSString * pathInCache = [appDelegate.cache.path stringByAppendingPathComponent:file.displayName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathInCache])
        {
            [loadedFiles addObject:[FileObject fileWithPath:pathInCache]];
        }
        else
        {            
            BoxOperationCompletionHandler finishBlock = ^(BoxOperation * op, BoxOperationResponse response)
            {
                if (response == BoxOperationResponseSuccessful)
                {
                    [loadedFiles addObject:[FileObject fileWithPath:pathInCache]];
                }
                else
                {
                    filesToSendCount --;
                }
                
                if ([loadedFiles count] == filesToSendCount)
                {
                    [appDelegate hideProgressHUD];
                    [super sendMail:loadedFiles];
                }
            };

            [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
            
            BoxDownloadOperation * downloadOp = [BoxDownloadOperation operationForFileID:file.ID toPath:pathInCache];
            [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:downloadOp onCompletetion:finishBlock];
        }
    }
    
    if ([loadedFiles count] == filesToSendCount)
    {
        [super sendMail:loadedFiles];
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
            BoxOperationCompletionHandler finishBlock = ^(BoxOperation * op, BoxOperationResponse response)
            {
                [appDelegate hideProgressHUD];
                if (response == BoxOperationResponseSuccessful)
                {
                    [super preview:[FileObject fileWithPath:pathInCache]];
                }
            };
            
            [appDelegate showProgressHUDWithText:NSLocalizedString(@"Downloading", nil)];
            
            BoxDownloadOperation * downloadOp = [BoxDownloadOperation operationForFileID:file.ID toPath:pathInCache];
            [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:downloadOp onCompletetion:finishBlock];
        }
    }
}

#pragma mark - FileVC methods

- (NSArray *) filesFromCurrentFolder
{
    if (!_loadedBoxFolder)
    {
        [self getFreeSpace];
    }
    else
    {
        NSMutableArray * files = [NSMutableArray array];
        for (BoxObject * object in _loadedBoxFolder.objectsInFolder)
        {
            FileObject * file = [FileObject fileWithID:object.objectId displayName:object.objectName];
            file.isFolder = [object.objectType isEqualToString:@"folder"];
            [files addObject:file];
        }
        self.loadedBoxFolder = nil;
        return files;
    }
    return nil;
}

- (long long) freeSpace
{
    return _spaceAmount - _spaceUsed;
}

- (FileSource)fileSource
{
    return FileSourceBox;
}

- (bool) canWorkWithArchives
{
    return false;
}

- (void) remove:(FileObject *)file
{    
    BoxOperationCompletionHandler finishBlock = ^(BoxOperation * op, BoxOperationResponse response)
    {
        [super doneAction:(response == BoxOperationResponseSuccessful)];
    };
    
    BoxDeleteOperation * deleteOperation = [BoxDeleteOperation operationForTargetId:file.ID targetType:[self typeOf:file]];
    [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:deleteOperation onCompletetion:finishBlock];
}

- (void) paste:(FileObject *)file overWrite:(bool)overWrite
{
    if (![BoxLoginViewController userSignedIn])
    {
        [self noAuthorization];
        return;
    }
        
    if ([self isFileNameInCurrentFolder:file.pasteName])
    {
        if (overWrite)
        {
            BoxOperationCompletionHandler finishBlock = ^(BoxOperation * op, BoxOperationResponse response)
            {
                if (response == BoxOperationResponseSuccessful)
                {
                    [self pasteToBox:file];
                }
                else
                {
                    [super finishPaste:false];
                }
            
            };
        
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayName == %@", file.pasteName];
            NSArray * result = [self.currentFileList filteredArrayUsingPredicate:predicate];
            if ([result count] != 1)
            {
                [super finishPaste:false];
                return;
            }   
        
            FileObject * fileToRemove = [result objectAtIndex:0];
            BoxDeleteOperation * deleteOperation = [BoxDeleteOperation operationForTargetId:fileToRemove.ID targetType:[self typeOf:file]];
            [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:deleteOperation onCompletetion:finishBlock];
        }
        else
        {
            [self finishPaste:true];
        }
    }
    else
    {
        [self pasteToBox:file];
    }
}

- (void) newFolder:(NSString *)name
{
    if (![BoxLoginViewController userSignedIn])
    {
        [self noAuthorization];
        return;
    }
    
    BoxOperationCompletionHandler finishBlock = ^(BoxOperation * op, BoxOperationResponse response)
    {
        [super doneAction:(response == BoxOperationResponseSuccessful)];
    };
    
    BoxCreateFolderOperation * createFolderOp = [BoxCreateFolderOperation operationForFolderName:name parentID:self.currentFolder.ID share:NO];
    [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:createFolderOp onCompletetion:finishBlock];
}

- (void) newFile:(NSString *)name content:(NSData *)content
{
    if (![BoxLoginViewController userSignedIn])
    {
        [self noAuthorization];
        return;
    }
    
    BoxOperationCompletionHandler finishBlock = ^(BoxOperation * op, BoxOperationResponse response)
    {
        [super doneAction:(response == BoxOperationResponseSuccessful)];
    };
        
    BoxUploadOperation * uploadOperation = [BoxUploadOperation operationForUser:[BoxLoginViewController currentUser] targetFolderId:self.currentFolder.ID data:content fileName:name contentType:[name pathExtension] shouldShare:NO message:nil emails:nil];
    
    [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:uploadOperation onCompletetion:finishBlock];
}

- (void) rename:(FileObject *)file newName:(NSString *)newName
{
    BoxOperationCompletionHandler finishBlock = ^(BoxOperation * op, BoxOperationResponse response)
    {
        [super doneAction:(response == BoxOperationResponseSuccessful)];
    };
    
    BoxRenameOperation * renameOp = [BoxRenameOperation operationForTargetID:file.ID targetType:[self typeOf:file] destinationName:newName];
    [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:renameOp onCompletetion:finishBlock];
}


#pragma mark - paste

- (void) pasteToBox:(FileObject *)file
{
    if ([ClipboardManager sharedManager].source == FileSourceFolder)
    {
        if (file.isFolder)
        {
            [super finishPaste:false];
            return;
        }
        
        BoxOperationCompletionHandler finishUploadBlock = ^(BoxOperation * op, BoxOperationResponse response)
        {
            [super finishPaste:(response == BoxOperationResponseSuccessful)];
        };
        
        NSData * content = [NSData dataWithContentsOfFile:file.path];
        BoxUploadOperation * uploadOperation = [BoxUploadOperation operationForUser:[BoxLoginViewController currentUser] targetFolderId:self.currentFolder.ID data:content fileName:file.pasteName contentType:[file.displayName pathExtension] shouldShare:NO message:nil emails:nil];
        [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:uploadOperation onCompletetion:finishUploadBlock];
    }
    else if ([ClipboardManager sharedManager].source == FileSourceBox)
    {
        BoxOperationCompletionHandler finishPasteBlock = ^(BoxOperation * op, BoxOperationResponse response)
        {
            [super finishPaste:true];//(response == BoxOperationResponseSuccessful)];
        };
                    
        BoxOperation * op;
        if ([ClipboardManager sharedManager].mode == ClipboardModeCopy)
        {
            op = [BoxCopyOperation operationForTargetId:file.ID targetType:[self typeOf:file] destinationId:self.currentFolder.ID authToken:[BoxLoginViewController currentUser].authToken delegate:nil];
        }
        else if ([ClipboardManager sharedManager].mode == ClipboardModeCut)
        {
            op = [BoxMoveOperation operationForItemID:file.ID itemType:[self typeOf:file] destinationFolderID:self.currentFolder.ID];
        }
        [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:op onCompletetion:finishPasteBlock];
    }
    else
    {
        [ClipboardManager sharedManager].destDelegate = self;
        [[ClipboardManager sharedManager].sourceDelegate needPasteToCacheFile:file];
    }
}

#pragma mark - ClipboardDestinationDelegate

- (void) file:(FileObject *)file didPasteToCache:(NSString *)pathInCache
{
    BoxOperationCompletionHandler finishUploadBlock = ^(BoxOperation * op, BoxOperationResponse response)
    {
        [super finishPaste:(response == BoxOperationResponseSuccessful)];
    };
    
    if (pathInCache)
    {
        NSData * content = [NSData dataWithContentsOfFile:pathInCache];
        BoxUploadOperation * uploadOperation = [BoxUploadOperation operationForUser:[BoxLoginViewController currentUser] targetFolderId:self.currentFolder.ID data:content fileName:file.pasteName contentType:[file.displayName pathExtension] shouldShare:NO message:nil emails:nil];
        [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:uploadOperation onCompletetion:finishUploadBlock];
    }
    else [self finishPaste:false];
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
    
    BoxOperationCompletionHandler finishBlock = ^(BoxOperation * op, BoxOperationResponse response)
    {
        [[ClipboardManager sharedManager].destDelegate file:file didPasteToCache:pathInCache];
    };
    
    BoxDownloadOperation * downloadOp = [BoxDownloadOperation operationForFileID:file.ID toPath:pathInCache];
    [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:downloadOp onCompletetion:finishBlock];
}

- (void) needPasteToFolderFile:(FileObject *)file newPath:(NSString *)newPath overWrite:(bool)overWrite
{
    if (file.isFolder)
    {
        [[ClipboardManager sharedManager].destDelegate fileDidPasteToFolder:false];
        return;
    }
    
    BoxOperationCompletionHandler finishBlock = ^(BoxOperation * op, BoxOperationResponse response)
    {
        [[ClipboardManager sharedManager].destDelegate fileDidPasteToFolder:(response == BoxOperationResponseSuccessful)];
    };
    
    if (overWrite)
    {
        [[NSFileManager defaultManager] removeItemAtPath:newPath error:nil];
    }
    
    BoxDownloadOperation * downloadOp = [BoxDownloadOperation operationForFileID:file.ID toPath:newPath];
    [[BoxNetworkOperationManager sharedBoxOperationManager] sendRequest:downloadOp onCompletetion:finishBlock];
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

#pragma mark - get free space

- (void) getFreeSpace
{
    NSString * str = [[NSString alloc] initWithFormat:@"https://www.box.net/api/1.0/rest?action=get_account_info&api_key=%@&auth_token=%@", BOX_API_KEY, [BoxLoginViewController currentUser].authToken];
    NSURL * url = [[NSURL alloc] initWithString:str];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    DataURLConnection * loadingFileListConncetion = [[DataURLConnection alloc] initWithRequest:request delegate:self];
    [loadingFileListConncetion start];
    
    [url release];
    [request release];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    self.currentXMLName = [elementName lowercaseString];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([_currentXMLName isEqualToString:@"space_amount"])
    {
        _spaceAmount = [string longLongValue];
    }
    else if ([_currentXMLName isEqualToString:@"space_used"])
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
    BoxGetFolderCompletionHandler finishBlock = ^(BoxFolder* folder, BoxFolderDownloadResponseType response)
    {
        if (folder)
        {
            self.loadedBoxFolder = folder;
            [super reloadFiles];
        }
        else
        {
            [self noConnection];
        }
    };
    
    [[BoxNetworkOperationManager sharedBoxOperationManager] getBoxFolderForID:super.currentFolder.ID onCompletion:finishBlock];
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

@end
