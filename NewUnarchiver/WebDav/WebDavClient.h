//
//  WebDavClient.h
//  NewUnarchiver
//
//  Created by Zhenya Koval on 30.10.12.
//  Copyright (c) 2012 Zhenya Koval. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WD_FILE_PATH_KEY @"WD_FILE_PATH_KEY"
#define WD_FILE_NAME_KEY @"WD_FILE_NAME_KEY"
#define WD_IS_FOLDER_KEY @"WD_IS_FOLDER_KEY"

@class WebDavClient;

@protocol WebDavClientDelegate <NSObject>

@optional

- (void) webDavClient:(WebDavClient *)webDavClient didFinishLoadingFileList:(NSArray *)files;
- (void) webDavClient:(WebDavClient *)webDavClient loadingFileListError:(NSError *)error;

- (void) webDavClient:(WebDavClient *)webDavClient didFinishRemoving:(NSString*)path;
- (void) webDavClient:(WebDavClient *)webDavClient removingError:(NSError *)error;

- (void) didFinishCopying:(WebDavClient *)webDavClient;
- (void) webDavClient:(WebDavClient *)webDavClient copyingError:(NSError *)error;

- (void) didFinishMoving:(WebDavClient *)webDavClient;
- (void) webDavClient:(WebDavClient *)webDavClient movingError:(NSError *)error;

- (void) didFinishCreatingFolder:(WebDavClient *)webDavClient;
- (void) webDavClient:(WebDavClient *)webDavClient creatingFolderError:(NSError *)error;

- (void) didFinishUploading:(WebDavClient *)webDavClient;
- (void) webDavClient:(WebDavClient *)webDavClient uploadingError:(NSError *)error;

- (void) webDavClient:(WebDavClient *)webDavClient didFinishDownloading:(NSString *)destPath;
- (void) webDavClient:(WebDavClient *)webDavClient downloadingError:(NSError *)error;

- (void) authenticationError:(WebDavClient *)webDavClient;

@end

@interface WebDavClient : NSObject <NSXMLParserDelegate>
{

}

@property (nonatomic, assign) id <WebDavClientDelegate> delegate;

@property (nonatomic, retain) NSURL * url;
@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * token;

- (id) initWithURL:(NSURL *)url login:(NSString *)login password:(NSString *)password;
- (id) initWithURL:(NSURL *)url token:(NSString *)token;

- (void) getFileListFrom:(NSString *) path;
- (void) copy:(NSString *) path to:(NSString *) newPath;
- (void) move:(NSString *) path to:(NSString *) newPath;
- (void) remove:(NSString *) path;
- (void) createFolder:(NSString *) path;
- (void) upload:(NSString *) path to:(NSString *) newPath;
- (void) download:(NSString *) path to:(NSString *) newPath;
@end
