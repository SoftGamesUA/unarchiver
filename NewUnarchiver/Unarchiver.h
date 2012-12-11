//
//  Unarchiver.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 29.02.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "ZipArchive.h"

#import "FileObject.h"

@protocol UnarchiverDelegate <NSObject>
@optional

-(void) unZipError:(FileObject *)zip;

@end

@interface Unarchiver : NSObject <ZipArchiveDelegate>
{

}

@property (nonatomic, assign) id <UnarchiverDelegate> delegate;

- (bool) zip:(NSSet *)files zipPath:(NSString *)zipPath password:(NSString *)password;
- (bool) unZip:(FileObject *)zip to:(NSString *)pathToUnZip password:(NSString *)password;
- (bool) unRar:(FileObject *)rar to:(NSString *)pathToUnRar;

@end
