//
//  FileObject.m
//  NewUnarchiver
//
//  Created by Zhenya Koval on 22.11.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "FileObject.h"

@implementation FileObject

+ (FileObject *) fileWithPath:(NSString *)path
{
    FileObject * file = [[FileObject alloc] init];
    file.path = path;
    file.displayName = [path lastPathComponent];
    file.isFolder = false;
    
    return [file autorelease];
}

+ (FileObject *) fileWithID:(NSString *)ID displayName:(NSString *)displayName
{
    FileObject * file = [[FileObject alloc] init];
    file.ID = ID;
    file.displayName = displayName;
    file.isFolder = false;
    
    return [file autorelease];
}

+ (FileObject *) folderWithPath:(NSString *)path
{
    FileObject * folder = [FileObject fileWithPath:path];
    folder.isFolder = true;
    
    return folder;
}

+ (FileObject *) folderWithID:(NSString *)ID displayName:(NSString *)displayName
{
    FileObject * folder = [FileObject fileWithID:ID displayName:displayName];
    folder.isFolder = true;
    
    return folder;
}

+ (FileObject *) fileWithFile:(FileObject *) file
{
    FileObject * newFile = [[FileObject alloc] init];
    newFile.ID = [NSString stringWithString:file.ID];
    newFile.path = [NSString stringWithString:file.path];
    newFile.displayName = [NSString stringWithString:file.displayName];
    newFile.isFolder = file.isFolder;
    
    return [newFile autorelease];
}

- (BOOL) isEqual:(FileObject *)fo;
{
    bool equalPath = ((!_path && !fo.path) || [_path isEqualToString:fo.path]);
    bool equalID =  ((!_ID && !fo.ID) || [_ID isEqualToString:fo.ID]);
    
    return equalID && equalPath;
}

- (void) dealloc
{
    self.displayName = nil;
    self.path = nil;
    self.ID = nil;
    
    [super dealloc];
}

@end
