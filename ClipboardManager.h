//
//  ClipboardManager.h
//  NewUnarchiver
//
//  Created by Zhenya Koval on 08.10.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "FileObject.h"

static NSString * clipboardDidChangeNotification = @"clipBoardChange";

typedef enum _FileSource
{
    FileSourceFolder = 0,
    FileSourceDropbox,
    FileSourceCamera,
    FileSourceBox,
    FileSourceYandex,
    FileSourceGoogle,
}FileSource;

typedef enum _ClipboardMode
{
    ClipboardModeCopy = 0,
    ClipboardModeCut,
}ClipboardMode;

@protocol ClipboardDestinationDelegate <NSObject>
@optional
- (void) file:(FileObject *)file didPasteToCache:(NSString *)pathInCache;
- (void) fileDidPasteToFolder:(bool)success;
@end

@protocol ClipboardSourceDelegate <NSObject>
@optional
- (void) needPasteToCacheFile:(FileObject *)file;
- (void) needPasteToFolderFile:(FileObject *)file newPath:(NSString *)newPath overWrite:(bool)overWrite;
@end

@interface ClipboardManager : NSObject
{
    
}

@property (retain, nonatomic) id <ClipboardSourceDelegate> sourceDelegate;
@property (retain, nonatomic) id <ClipboardDestinationDelegate> destDelegate;

@property (retain, nonatomic) NSMutableSet * files;
@property (assign, nonatomic) FileSource source;
@property (assign, nonatomic) ClipboardMode mode;
@property (retain, nonatomic) FileObject * sourceFolder;

@property (retain, nonatomic) id userInfo;

+ (ClipboardManager *) sharedManager;

- (void) copyFiles:(NSSet *)files source:(FileSource)source sourceFolder:(FileObject *) sourceFolder;
- (void) cutFiles:(NSSet *)files source:(FileSource)source sourceFolder:(FileObject *) sourceFolder;
- (void) clear;
- (bool) isFree;

@end
