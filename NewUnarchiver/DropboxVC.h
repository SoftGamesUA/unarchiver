//
//  DropboxVC.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 15.03.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "FileVC.h"
#import <DropboxSDK/DropboxSDK.h>
#import "Reachability.h"

@interface DropboxVC : FileVC <DBRestClientDelegate, DBSessionDelegate>
{
    CGRect openFileCellRect;
    int _filesToLoadCount;
    bool _loadForOpen, _loadForPreview, _loadForSend, _loadForSave, _loadToCache;
    bool _removeForOverwrite;
    bool _uploadNewFile;
    bool _moveForRename;
    
    Reachability * _internetConnection;
}

+ (void) logOut;

@end
