//
//  MyDropboxClient.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 17.04.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "MyDropboxClient.h"

#import "DropboxVC.h"
#import "FolderVC.h"
#import "AppDelegate.h"

@interface MyDropboxClient ()

@property (nonatomic, retain)   NSString * path;
@property (nonatomic, retain)   DBMetadata * metadata;
@property (nonatomic, retain)   NSArray * files;


@end

@implementation MyDropboxClient

@synthesize delegate = _delegate;

@synthesize path = _path, metadata = _metadata, files = _files;

- (id) init
{
    self = [super init];
    if (self)
    {
        _makeCopyInfo = [[NSMutableDictionary alloc] init];
        
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLinkNotification) name:dropboxLinkNotification object:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_makeCopyInfo release];
    [_restClient release];
    
    self.path = nil;
    self.metadata = nil;
    self.files = nil;
    
    [super dealloc];
}

- (void) dropboxLinkNotification
{
    if (_restClient)    [_restClient release];
    
    _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    _restClient.delegate = self;
}

#pragma mark - files

- (NSArray *) filePathesFromFolderAndChilds:(NSString *)folderPath
{
    NSMutableArray * files = [NSMutableArray array];
    
    NSArray *filesFromFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath  error:nil];
    if ([filesFromFolder count] == 0) [files addObject:folderPath];
    
    for (NSString *fileName in filesFromFolder)
    {
        NSString * filePath = [folderPath stringByAppendingPathComponent:fileName];
        NSDictionary* properties = [[NSFileManager defaultManager] 
                                    attributesOfItemAtPath:filePath error:nil];
        if ([properties objectForKey:NSFileType] == NSFileTypeDirectory)    
        {
            NSArray *filesFromChildFolder = [self filePathesFromFolderAndChilds:filePath];
            if ([filesFromChildFolder count] == 0) 
                [files addObject:filePath];
            else 
                [files addObjectsFromArray:filesFromChildFolder];
        }
        else 
            [files addObject:filePath];
    }
    
    return [NSArray arrayWithArray:files];
}

#pragma mark - loading files and folders

- (void) loadFilesFromClipBoardTo:(NSString *)path pasteFlag:(PasteFlag)pasteFlag
{
    _loadedFilesCount = _filesToLoadCount =  _metadataToLoadCount = _loadedMetadataCount = 0;
    
    _pasteFlag = pasteFlag;
    self.path = path;
    
    for (NSString * filePath in [ClipboardManager sharedManager].files)
    {
        NSString * newPath = [path stringByAppendingPathComponent:[filePath lastPathComponent]];
        if ([FolderVC isFileExist:newPath])
        {
            if (pasteFlag == PasteFlagSkip)
            {
                if (filePath == [[ClipboardManager sharedManager].files lastObject])    [self finishLoadFile];
                continue;
            }
            else if (pasteFlag == PasteFlagOwerwrite)    [[NSFileManager defaultManager] removeItemAtPath:newPath error:nil];
        }
        _metadataToLoadCount ++;
        [_restClient loadMetadata:filePath];
    }
}

- (void) finishLoadFile
{
    if (_loadedFilesCount >= _filesToLoadCount && _loadedMetadataCount >= _metadataToLoadCount)
    {
        _loadedFilesCount = _filesToLoadCount =  _metadataToLoadCount = _loadedMetadataCount = 0;
        
        if ([ClipboardManager sharedManager].mode == ClipboardModeCut)
        {
            _removingForLoading = true;
            for (NSString *filePath in [ClipboardManager sharedManager].files)  [_restClient deletePath:filePath];
        }
        else 
        {
            [self finishLoadingFilesAndFolders];
        }
    }
}

- (void) finishRemovingFileForLoading
{
    static int deletedFilesCount = 0;
    deletedFilesCount ++;
    
    if (deletedFilesCount >= [[ClipboardManager sharedManager].files count])
    {
        deletedFilesCount  = 0;
        _removingForLoading = false;
        [self finishLoadingFilesAndFolders];
    }
}

- (void) finishLoadingFilesAndFolders
{
    if ([_delegate respondsToSelector:@selector(filesDidLoadFromDropbox)])
    {
        [_delegate filesDidLoadFromDropbox];
    }
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    _loadedMetadataCount ++;
    
    NSString * localPath = [NSString stringWithString:metadata.path];
    if (![[ClipboardManager sharedManager].sourcePath isEqualToString:@"/"])
    {
        NSRange range = NSMakeRange(0, [[ClipboardManager sharedManager].sourcePath length]);
        localPath = [localPath stringByReplacingCharactersInRange:range withString:@""];
    }
    localPath = [localPath substringFromIndex:1];
    NSString * newPath = [_path stringByAppendingPathComponent:localPath];
    NSMutableArray *comps = [NSMutableArray arrayWithArray:[localPath pathComponents]];
    NSString * firstCompPath = [_path stringByAppendingPathComponent:[comps objectAtIndex:0]];
    
    if ([FolderVC isFileExist:firstCompPath] && _pasteFlag == PasteFlagMakeCopy)
    {
        NSString *newFirstCompPath = [_makeCopyInfo objectForKey:firstCompPath];
        if (newFirstCompPath == nil) 
        {
            newFirstCompPath = [FolderVC nextPathForFile:firstCompPath copy:true];
            [_makeCopyInfo setObject:newFirstCompPath forKey:firstCompPath];
                
        }
            
        [comps replaceObjectAtIndex:0 withObject:[newFirstCompPath lastPathComponent]];
        newPath = [_path stringByAppendingPathComponent:[NSString pathWithComponents:comps]];
    }
    
    if (metadata.isDirectory)
    {
        if ([metadata.contents count] == 0) 
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
            [self finishLoadFile];
        }
        else
        {
            for (DBMetadata *md in metadata.contents)   
            {
                _metadataToLoadCount ++;
                [_restClient loadMetadata:md.path];
            }
        }
    }
    else 
    {
        if(![FolderVC isFileExist:[newPath stringByDeletingLastPathComponent]])
            [[NSFileManager defaultManager] createDirectoryAtPath:[newPath stringByDeletingLastPathComponent]
                                      withIntermediateDirectories:true attributes:nil error:nil];
        
        _filesToLoadCount ++;
        [_restClient loadFile:metadata.path intoPath:newPath];
    }
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
    _loadedMetadataCount ++;
    [self finishLoadFile];
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath contentType:(NSString*)contentType metadata:(DBMetadata*)metadata;
{
    _loadedFilesCount ++;
    [self finishLoadFile];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
    _loadedFilesCount ++;
    [self finishLoadFile];
}

#pragma mark - uploading files and folders

- (void) upload:(NSArray *)files from:(NSString *)sourcePath to:(DBMetadata *)metadata pasteFlag:(PasteFlag)pasteFlag;
{
    self.files = files;
    self.path = sourcePath;
    self.metadata = metadata;
    _pasteFlag = pasteFlag;
    
    _filesToDeleteCount = 0;
        
    if (pasteFlag == PasteFlagOwerwrite) 
    {
        _filesToDeleteCount = 0;
        for (NSString * filePath in _files)
        {
            NSString * newPath = [metadata.path stringByAppendingPathComponent:[filePath lastPathComponent]];
            if ([_delegate isFileExist:newPath]) _filesToDeleteCount ++;
        }
        
        _removingForUploading = true;
        for (NSString * filePath in _files)
        {
            NSString * newPath = [metadata.path stringByAppendingPathComponent:[filePath lastPathComponent]];
            if ([_delegate isFileExist:newPath]) [_restClient deletePath:newPath];
        }
    }
    else [self uploadFiles];
}

- (void) uploadFiles
{
    _uploadedFilesCount = 0;
    
    NSMutableArray * parsedFiles = [NSMutableArray array];
    for (NSString * filePath in _files)
    {
        if ([FolderVC isFolder:filePath])   [parsedFiles addObjectsFromArray:[self filePathesFromFolderAndChilds:filePath]];
        else    [parsedFiles addObject:filePath];
    }
    _filesToUploadCount = [parsedFiles count];
    
    for (NSString * filePath in parsedFiles) 
    {
        NSRange range = NSMakeRange(0, [_path length]);
        NSString * localPath = [filePath stringByReplacingCharactersInRange:range withString:@""];
        localPath = [localPath substringFromIndex:1];
        NSMutableArray *comps = [NSMutableArray arrayWithArray:[localPath pathComponents]];
        NSString * firstCompPath = [_metadata.path stringByAppendingPathComponent:[comps objectAtIndex:0]];
        
        NSString * newPath = [_metadata.path stringByAppendingPathComponent:localPath];
        
        if ([_delegate isFileExist:firstCompPath])
        {
            if (_pasteFlag == PasteFlagSkip) 
            {
                [self finishUploadFile];
                continue;
            }
            else if (_pasteFlag == PasteFlagMakeCopy)
            {
                firstCompPath = [_delegate nextPathForFile:firstCompPath copy:true];
                [comps replaceObjectAtIndex:0 withObject:[firstCompPath lastPathComponent]];
                newPath = [_metadata.path stringByAppendingPathComponent:[NSString pathWithComponents:comps]];
            }
        }
        
        if ([FolderVC isFolder:filePath]) [_restClient createFolder:newPath];
        else    [_restClient uploadFile:@"" toPath:newPath withParentRev:nil fromPath:filePath];
    }    
}

- (void) finishUploadingFilesAndFolders
{
    if ([_delegate respondsToSelector:@selector(filesDidUploadToDropbox)])
    {
        [_delegate filesDidUploadToDropbox];
    }
}

- (void) finishUploadFile
{
    _uploadedFilesCount ++;
    if (_uploadedFilesCount >= _filesToUploadCount)
    {
        if ([ClipboardManager sharedManager].mode == ClipboardModeCut && ![_path isEqualToString:[AppDelegate cacheDirectory]])
        {
            for (NSString *filePath in _files)
            {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }

        _uploadedFilesCount = _filesToUploadCount = 0;
        
        [self finishUploadingFilesAndFolders];
    }
}

- (void) finishRemovingFileForUploading
{
    static int deletedFilesCount = 0;
    deletedFilesCount ++;
    
    if (deletedFilesCount >= [_files count])
    {
        deletedFilesCount  = 0;
        _removingForUploading = false;
        [self uploadFiles];
    }
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
{
    [self finishUploadFile];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    [self finishUploadFile];;
}

- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder
{
    [self finishUploadFile];
}

- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error
{
    [self finishUploadFile];
}

#pragma mark - copy

- (void) finishCopyFile
{
    static int copiedFilesCount = 0;
    copiedFilesCount ++;
    
    if (copiedFilesCount >= [[ClipboardManager sharedManager].files count])
    {
        _removingForCopy = false;
        
        if ([_delegate respondsToSelector:@selector(filesDidCopyInDropbox)])
        {
            [_delegate filesDidCopyInDropbox];
        }
    }
}

- (void) finishRemovingFileForCopy:(NSString *)path
{
    NSString * filePath = [[ClipboardManager sharedManager].sourcePath stringByAppendingPathComponent:[path lastPathComponent]];
    [_restClient copyFrom:filePath toPath:path];
}

- (void) copyFilesFromClipBoartTo:(DBMetadata *)metadata pasteFlag:(PasteFlag)pasteFlag
{
    self.metadata = metadata;
    
    for (NSString * filePath in [ClipboardManager sharedManager].files)
    {
        NSString * newPath = [metadata.path stringByAppendingPathComponent:[filePath lastPathComponent]];;
        if ([_delegate isFileExist:newPath])
        {
            if (pasteFlag == PasteFlagOwerwrite) 
            {
                _removingForCopy = true;
                [_restClient deletePath:newPath];
                continue;
            }
            else if (pasteFlag == PasteFlagMakeCopy)   newPath = [_delegate nextPathForFile:newPath copy:true];
            else if (pasteFlag == PasteFlagSkip) 
            {
                [self finishCopyFile];
                continue;
            }
        }
        
        [_restClient copyFrom:filePath toPath:newPath];
    }
}

- (void)restClient:(DBRestClient*)client copiedPath:(NSString *)from_path toPath:(NSString *)to_path
{
    [self finishCopyFile];
}

- (void)restClient:(DBRestClient*)client copyPathFailedWithError:(NSError*)error
{
    [self finishCopyFile];
}

#pragma mark - move

- (void) finishMoveFile
{
    static int movedFilesCount = 0;
    movedFilesCount ++;
    
    if (movedFilesCount >= [[ClipboardManager sharedManager].files count])
    {
        _removingForMove = false;

        if ([_delegate respondsToSelector:@selector(filesDidMoveInDropbox)])
        {
            [_delegate filesDidMoveInDropbox];
        }
    }
}

- (void) finishRemovingFileForMove:(NSString *)path
{
    NSString * filePath = [[ClipboardManager sharedManager].sourcePath stringByAppendingPathComponent:[path lastPathComponent]];
    [_restClient moveFrom:filePath toPath:path];
    
}

- (void) moveFilesFromClipBoartTo:(DBMetadata *)metadata pasteFlag:(PasteFlag)pasteFlag
{
    self.metadata = metadata;
    
    for (NSString * filePath in [ClipboardManager sharedManager].files)
    {
        NSString * newPath = [metadata.path stringByAppendingPathComponent:[filePath lastPathComponent]];;
        if ([_delegate isFileExist:newPath])
        {
            if (pasteFlag == PasteFlagOwerwrite) 
            {
                _removingForMove = true;
                [_restClient deletePath:newPath];
                continue;
            }
            else if (pasteFlag == PasteFlagMakeCopy)   newPath = [_delegate nextPathForFile:newPath copy:true];
            else if (pasteFlag == PasteFlagSkip) 
            {
                [self finishMoveFile];
                continue;
            }
        }
        
        [_restClient moveFrom:filePath toPath:newPath];
    }
}

- (void)restClient:(DBRestClient*)client movedPath:(NSString *)from_path toPath:(NSString *)to_path
{
    [self finishMoveFile];
}

- (void)restClient:(DBRestClient*)client movePathFailedWithError:(NSError*)error
{
    [self finishMoveFile];
}

#pragma mark - 

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path
{
    if (_removingForLoading)    [self finishRemovingFileForLoading];
    else if (_removingForUploading)    [self finishRemovingFileForUploading];
    else if (_removingForCopy)    [self finishRemovingFileForCopy:path];
    else if (_removingForMove)    [self finishRemovingFileForMove:path];
}

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error
{
     if (_removingForLoading)    [self finishRemovingFileForLoading];
     else if (_removingForUploading)    [self finishRemovingFileForUploading];
     else if (_removingForCopy)    [self finishRemovingFileForCopy:[error.userInfo objectForKey:@"path"]];
     else if (_removingForMove)    [self finishRemovingFileForMove:[error.userInfo objectForKey:@"path"]];
}

@end
