//
//  YandexDiskVC.h
//  NewUnarchiver
//
//  Created by Zhenya Koval on 02.11.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "FileVC.h"
#import "WebDavClient.h"
#import "Reachability.h"

@interface YandexDiskVC : FileVC <WebDavClientDelegate, NSXMLParserDelegate>
{    
    CGRect openFileCellRect;
    int _filesToLoadCount;
    bool _loadForOpen, _loadForPreview, _loadForSend, _loadForSave, _loadToCache;
    bool _removeForOverwrite;
    bool _uploadNewFile;
    bool _moveForRename;
    
    long long  _spaceAmount, _spaceUsed;
    
    Reachability * _internetConnection;
}

+ (void) logOut;

@end
