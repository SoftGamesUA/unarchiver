//
//  Unarchiver.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 29.02.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "Unarchiver.h"

#import <UnrarKit/UnrarKit.h>

@interface Unarchiver ()

@property (nonatomic, retain) NSString * pathToUnZip;
@property (nonatomic, retain) FileObject * zipFile;

@end

@implementation Unarchiver

- (bool) zip:(NSSet *)files zipPath:(NSString *)zipPath password:(NSString *)password
{
    if (!zipPath || !files) return false;
    if ([files count] == 0) return false;
    
	ZipArchive *zip = [[ZipArchive alloc] init];
    zip.delegate = self;
    
    if (password)
    {
        if (![zip CreateZipFile2:zipPath Password:password]) return false;
    }
    else
    {
        if (![zip CreateZipFile2:zipPath]) return false;
    }
    
    for (FileObject * file in files)
    {
        if (file.isFolder) [zip addFolderToZip:file.path pathPrefix:file.displayName];
        else [zip addFileToZip:file.path newname:file.displayName];
    }
    [zip release];

    return true;
}

- (bool) unZip:(FileObject *)zipFile to:(NSString *)pathToUnZip password:(NSString *)password
{
    if (!zipFile || !pathToUnZip) return false;
    
    ZipArchive * zip = [[ZipArchive alloc] init];
    zip.delegate = self;
    
    bool succes;
    
    if (password)   succes = [zip UnzipOpenFile: zipFile.path Password:password];
    else            succes = [zip UnzipOpenFile: zipFile.path];
    
    if (succes)
    {
        self.pathToUnZip = pathToUnZip;
        self.zipFile = zipFile;
        
        succes = [zip UnzipFileTo:pathToUnZip overWrite:false];
	}
    
    [zip UnzipCloseFile];
    [zip release];
    
    return succes;
}

- (bool) unRar:(FileObject *)rar to:(NSString *)pathToUnRar
{
    return [self unRar:rar to:pathToUnRar password:nil];
}

- (bool) unRar:(FileObject *)rar to:(NSString *)pathToUnRar password:(NSString *)password
{
	if (!rar || !pathToUnRar) return false;
    NSError *error;
    
    URKArchive * unrar = [[URKArchive alloc] initWithPath:rar.path error:&error];
    NSArray *files = [unrar listFilenames:&error];
    if (!files)
    {
        [unrar release];
        return false;
    }
    
    BOOL isDir = true;
    NSFileManager * fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:pathToUnRar isDirectory:&isDir])	
        [fm createDirectoryAtPath:pathToUnRar withIntermediateDirectories:true attributes:nil error:nil];

	for (NSString * fileName in files)
	{
        NSMutableArray *fileNameComponents = (NSMutableArray*)[fileName componentsSeparatedByString:@"/"];
		if ([fileNameComponents count] > 1) 
		{
			NSString *directoryName = [NSString stringWithFormat:@"%@/%@", pathToUnRar, [fileName stringByDeletingLastPathComponent]];
			
  			if(![fm fileExistsAtPath:directoryName isDirectory:&isDir])	
                [fm createDirectoryAtPath:directoryName withIntermediateDirectories:true attributes:nil error:nil];
					
        }
				
        NSData *data = [[unrar extractDataFromFile:fileName progress:^(CGFloat percentDecompressed) {
            //Can we show the progress from unrar files ))
        } error:&error] retain];
        //[[unrar extractDataFromFile:fileName error:&error] retain];
        
		[data writeToFile:[NSString stringWithFormat:@"%@/%@", pathToUnRar, fileName] atomically:YES];
        [data release];
    }
			
    [unrar release];
    return true;
}

- (void)ErrorMessage:(NSString *)msg
{
    if ([msg isEqualToString:@"Failed to reading zip file"])
    {
        [[NSFileManager defaultManager] removeItemAtPath:_pathToUnZip error:nil];
        if (_delegate && [_delegate respondsToSelector:@selector(unZipError:)])
        {
            [_delegate unZipError:_zipFile];
        }
    }
}

- (void) dealloc
{
    self.pathToUnZip = nil;
    self.zipFile = nil;
    
    [super dealloc];
}

@end
