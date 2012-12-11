//
//  ClipboardManager.m
//  NewUnarchiver
//
//  Created by Zhenya Koval on 08.10.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "ClipboardManager.h"

static ClipboardManager * clipBoardManager = nil;

@implementation ClipboardManager

+ (ClipboardManager *) sharedManager
{
    if (!clipBoardManager)
    {
        clipBoardManager = [[ClipboardManager alloc] init];
    }
    return clipBoardManager;
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _files = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void) copyFiles:(NSSet *)files source:(FileSource)source sourceFolder:(FileObject *) sourceFolder
{
    _mode = ClipboardModeCopy;
    _source = source;

    [_files removeAllObjects];
    [_files unionSet:files];
    self.sourceFolder = sourceFolder;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:clipboardDidChangeNotification object:nil];
}

- (void) cutFiles:(NSSet *)files source:(FileSource)source sourceFolder:(FileObject *) sourceFolder
{
    _mode = ClipboardModeCut;
    _source = source;

    [_files removeAllObjects];
    [_files unionSet:files];
    self.sourceFolder = sourceFolder;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:clipboardDidChangeNotification object:nil];
}

- (void) clear
{
    [_files removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:clipboardDidChangeNotification object:nil];
}

- (bool) isFree
{
    return ([_files count] == 0);
}

- (void) dealloc
{
    [super dealloc];
    
    self.sourceFolder = nil;
    self.files = nil;
    self.sourceDelegate = nil;
    self.destDelegate = nil;
}

@end
