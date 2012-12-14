
//
//  FolderVC.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 31.01.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "FolderVC.h"

@implementation FolderVC

#pragma mark -
#pragma mark - View lifecycle

- (void) customizeInterface
{
    UIImage * patternImage = [UIImage imageNamed:@"folderBorder"];
    [self setImageBorder:patternImage];
    
    [navBar setBackgroundImage:[UIImage imageNamed:@"navBarBG"]];
    [navBar setIconImage:[UIImage imageNamed:@"folderNavBarIcon"]];
    [navBar setBackButtonImage:[UIImage imageNamed:@"backBtnFolder"]];
    [navBar setViewModeButtonImage:[UIImage imageNamed:@"listBtnFolder"]];
    [navBar setSettingsButtonImage:[UIImage imageNamed:@"settingsBtnFolder"]];
    [navBar setPreviewButtonImage:[UIImage imageNamed:@"previewBtnFolder"]];
    [navBar setLabelTextColor:[UIColor colorWithPatternImage:patternImage]];
    
    [toolBar setImage:[UIImage imageNamed:@"addBtnFolder"] forBtn:ToolBarBtnAdd];
    [toolBar setImage:[UIImage imageNamed:@"shareBtnFolder"] forBtn:ToolBarBtnShare];
    [toolBar setImage:[UIImage imageNamed:@"ccpBtnFolder"] forBtn:ToolBarBtnCCP];
    [toolBar setImage:[UIImage imageNamed:@"archiveBtnFolder"] forBtn:ToolBarBtnArchive];
    [toolBar setImage:[UIImage imageNamed:@"deleteBtnFolder"] forBtn:ToolBarBtnDelete];
    [toolBar setImage:[UIImage imageNamed:@"helpBtnFolder"] forBtn:ToolBarBtnHelp];
    [toolBar setButtonTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"folderBorder"]]];
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    [self customizeInterface];
    
    [super reloadFiles];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - files

- (NSArray *) filesFromCurrentFolder
{
    __block NSMutableArray * files = [[NSMutableArray alloc] init];
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        NSMutableArray * fileNames = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:super.currentFolder.path error:nil] mutableCopy];
        
        if ([super.currentFolder isEqual:appDelegate.documents])
        {   
            if ([fileNames containsObject:appDelegate.inbox.displayName])     [fileNames removeObject:appDelegate.inbox.displayName];
            if ([fileNames containsObject:appDelegate.xFolder.displayName])   [fileNames removeObject:appDelegate.xFolder.displayName];
            if ([fileNames containsObject:@"BoxUsernameInfo.bin"])      [fileNames removeObject:@"BoxUsernameInfo.bin"];
        }
            
        for (NSString * name in fileNames)
        {
            NSString * path = [self.currentFolder.path stringByAppendingPathComponent:name];
            FileObject * file = [FileObject fileWithPath:path];
            BOOL isFolder;
            [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isFolder];
            file.isFolder = isFolder;
            [files addObject:file];
        }
            
        [fileNames release];
    });
    
    return [files autorelease];
}

- (long long) freeSpace
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary * dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: nil];
    
    NSNumber * fileSystemFreeSizeInBytes = [dictionary objectForKey: NSFileSystemFreeSize];
    return [fileSystemFreeSizeInBytes longLongValue];
}

- (FileSource)fileSource
{
    return FileSourceFolder;
}

- (bool) canWorkWithArchives
{
    return true;
}

- (void) remove:(FileObject *)file
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        [[NSFileManager defaultManager] removeItemAtPath:file.path error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [super doneAction:true];
            
        });
    });
}

- (void) paste:(FileObject *)file overWrite:(bool)overWrite
{
    NSString * newPath = [super.currentFolder.path stringByAppendingPathComponent:file.pasteName];
    
    if ([ClipboardManager sharedManager].source != FileSourceFolder)
    {
        [ClipboardManager sharedManager].destDelegate = self;
        [[ClipboardManager sharedManager].sourceDelegate needPasteToFolderFile:file newPath:newPath overWrite:overWrite];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        if ([super isFileNameInCurrentFolder:file.pasteName])
        {
            if (overWrite)
            {
                [[NSFileManager defaultManager] removeItemAtPath:newPath error:nil];
            }
            else
            {
                [super finishPaste:true];
                return;
            }
        }
        
        bool success;
        
        if ([ClipboardManager sharedManager].mode == ClipboardModeCopy)
        {
            success = [[NSFileManager defaultManager] copyItemAtPath:file.path toPath:newPath error:nil];
        }
        else if ([ClipboardManager sharedManager].mode == ClipboardModeCut)
        {
            success = [[NSFileManager defaultManager] moveItemAtPath:file.path toPath:newPath error:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [super finishPaste:success];
            
        });
    });
}

- (void) newFolder:(NSString *)name
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        NSString * newPath = [self.currentFolder.path stringByAppendingPathComponent:name];
        bool success = [[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [super doneAction:success];
            
        });
    });
}

- (void) newFile:(NSString *)name content:(NSData *)content
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        NSString * newPath = [self.currentFolder.path stringByAppendingPathComponent:name];
        bool success = [[NSFileManager defaultManager] createFileAtPath:newPath contents:content attributes:nil];
            
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [super doneAction:success];
            
        });
    });
}

- (void) rename:(FileObject *)file newName:(NSString *)newName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        NSString * newPath = [self.currentFolder.path stringByAppendingPathComponent:newName];
        bool success = [[NSFileManager defaultManager] moveItemAtPath:file.path toPath:newPath error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [super doneAction:success];
            
        });
    });
}

#pragma mark - ClipboardDestinationDelegate

- (void) fileDidPasteToFolder:(bool)success
{
    [super finishPaste:success];
}

@end
