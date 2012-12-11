//
//  FileObjecte.h
//  NewUnarchiver
//
//  Created by Zhenya Koval on 22.11.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileObject : NSObject

+ (FileObject *) fileWithPath:(NSString *)path;
+ (FileObject *) fileWithID:(NSString *)ID displayName:(NSString *)displayName;

+ (FileObject *) folderWithPath:(NSString *)path;
+ (FileObject *) folderWithID:(NSString *)ID displayName:(NSString *)displayName;

+ (FileObject *) fileWithFile:(FileObject *) file;

- (BOOL) isEqual:(FileObject *)fo;

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * ID;
@property (nonatomic, assign) bool isFolder;

@property (nonatomic, retain) NSString * pasteName; //used during copying or moving file

@end
