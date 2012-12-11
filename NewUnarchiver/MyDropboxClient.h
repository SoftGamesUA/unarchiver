//
//  MyDropboxClient.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 17.04.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ClipboardManager.h"
#import <DropboxSDK/DropboxSDK.h>

@protocol MyDropboxClientDelegate <NSObject>
@optional
- (void) filesDidLoadFromDropbox;
- (void) filesDidUploadToDropbox;
- (void) filesDidCopyInDropbox;
- (void) filesDidMoveInDropbox;
@end

@class DropboxVC;

@interface MyDropboxClient : NSObject <DBRestClientDelegate>
{
    DBRestClient * _restClient;

    PasteFlag _pasteFlag;
    
    // download folders and files
    
    NSMutableDictionary * _makeCopyInfo;
    int _filesToLoadCount, _loadedFilesCount, _metadataToLoadCount, _loadedMetadataCount;
    bool _removingForLoading;
    
    //*****************************************
    
    // upload folders and files
    
    int _filesToDeleteCount, _uploadedFilesCount, _filesToUploadCount;
    bool _removingForUploading;
    
    //*****************************************

    // copy folders and files
    
    bool _removingForCopy;
    
    //*****************************************
    
    // move folders and files
    
    bool _removingForMove;
    
    //*****************************************
}

@property (nonatomic, assign) DropboxVC <DBRestClientDelegate> * delegate;

- (void) loadFilesFromClipBoardTo:(NSString *)path pasteFlag:(PasteFlag)pasteFlag;
- (void) upload:(NSArray *)files from:(NSString *)sourcePath to:(DBMetadata *)metadata pasteFlag:(PasteFlag)pasteFlag;
- (void) moveFilesFromClipBoartTo:(DBMetadata *)metadata pasteFlag:(PasteFlag)pasteFlag;
- (void) copyFilesFromClipBoartTo:(DBMetadata *)metadata pasteFlag:(PasteFlag)pasteFlag;
@end
