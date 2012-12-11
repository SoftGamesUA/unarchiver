//
//  WebDavClient.m
//  NewUnarchiver
//
//  Created by Zhenya Koval on 30.10.12.
//  Copyright (c) 2012 Zhenya Koval. All rights reserved.
//

#import "WebDavClient.h"
#import "DataURLConnection.h"

@interface WebDavClient ()

@property (nonatomic, retain) NSMutableArray * files;
@property (nonatomic, retain) NSMutableDictionary * currentFile;
@property (nonatomic, retain) NSString * currentKey;

@property (nonatomic, retain) NSError * parserError;

@end

@implementation WebDavClient

- (id) initWithURL:(NSURL *)url
{
    self = [super init];
    if (self)
    {
        self.url = url;
        self.files = [NSMutableArray array];
    }
    
    return self;
}

- (id) initWithURL:(NSURL *)url login:(NSString *)login password:(NSString *)password
{
    self = [self initWithURL:url];
    if (self)
    {
        self.login = login;
        self.password = password;
    }
    
    return self;
}

- (id) initWithURL:(NSURL *)url token:(NSString *)token
{
    self = [self initWithURL:url];
    if (self)
    {
        self.token = token;
    }
    
    return self;
}

- (void) dealloc
{
    self.url = nil;
    self.login = nil;
    self.password = nil;
    self.files = nil;
    self.currentFile = nil;
    self.currentKey = nil;
    
    [super dealloc];
}

#pragma mark - get file list

- (void) getFileListFrom:(NSString *)path
{
    [_files removeAllObjects];
    
    NSURL * url = [_url URLByAppendingPathComponent:path];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PROPFIND"];
    [request setValue:@"1" forHTTPHeaderField:@"Depth"];
    if (_token) [request setValue:_token forHTTPHeaderField:@"Authorization"];
   
    DataURLConnection * loadingFileListConncetion = [[DataURLConnection alloc] initWithRequest:request delegate:self];
    loadingFileListConncetion.type = CONNECTION_TYPE_LOADING_FILE_LIST;
    loadingFileListConncetion.successCode = 207;
    loadingFileListConncetion.successSelector = @selector(webDavClient:didFinishLoadingFileList:);
    loadingFileListConncetion.failSelector = @selector(webDavClient:loadingFileListError:);
    [loadingFileListConncetion start];
    
    [request release];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    NSArray * parts = [[elementName lowercaseString] componentsSeparatedByString:@":"];
    NSString * key = [parts lastObject];
    
    if ([key isEqualToString:@"href"])
    {
        self.currentFile = [NSMutableDictionary dictionary];
        [_currentFile setObject:[NSNumber numberWithBool:false] forKey:WD_IS_FOLDER_KEY];
    }
    else if ([key isEqualToString:@"collection"]) [_currentFile setObject:[NSNumber numberWithBool:true] forKey:WD_IS_FOLDER_KEY];
    
    self.currentKey = key;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSArray * parts = [[elementName lowercaseString] componentsSeparatedByString:@":"];
    NSString * key = [parts lastObject];
    
    if ([key isEqualToString:@"href"])
    {
        [_files addObject:_currentFile];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSString * str = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([self.currentKey isEqualToString:@"href"])
    {
        [_currentFile setObject:str forKey:WD_FILE_PATH_KEY];
    }
    else if ([self.currentKey isEqualToString:@"displayname"])
    {
        [_currentFile setObject:str forKey:WD_FILE_NAME_KEY];
    }
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    self.parserError = validationError;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    self.parserError = parseError;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (!_parserError)
    {
        if (_files && [_files count] > 0)
        {
            [_files removeObjectAtIndex:0];
        }

        [_delegate webDavClient:self didFinishLoadingFileList:_files];
    }
    else
    {
        [_delegate webDavClient:self loadingFileListError:_parserError];
    }
}

#pragma mark - delete

- (void) remove:(NSString *)path
{
    NSURL * url = [_url URLByAppendingPathComponent:path];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    if (_token) [request setValue:_token forHTTPHeaderField:@"Authorization"];
    
    DataURLConnection * removingConncetion = [[DataURLConnection alloc] initWithRequest:request delegate:self];
    removingConncetion.type = CONNECTION_TYPE_REMOVING;
    removingConncetion.successCode = 200;
    removingConncetion.userInfo = path;
    removingConncetion.successSelector = @selector(didFinishRemoving:);
    removingConncetion.failSelector = @selector(webDavClient:removingError:);
    [removingConncetion start];
    
    [request release];
}

#pragma mark - copy & move

- (void) copy:(NSString *) path to:(NSString *) newPath
{
    NSURL * url = [_url URLByAppendingPathComponent:path];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"COPY"];
    if (_token) [request setValue:_token forHTTPHeaderField:@"Authorization"];
    [request setValue:[self encodeString:newPath] forHTTPHeaderField:@"Destination"];
    
    DataURLConnection * copyingConncetion = [[DataURLConnection alloc] initWithRequest:request delegate:self];
    copyingConncetion.type = CONNECTION_TYPE_COPYING;
    copyingConncetion.successCode = 201;
    copyingConncetion.successSelector = @selector(didFinishCopying:);
    copyingConncetion.failSelector = @selector(webDavClient:copyingError:);
    [copyingConncetion start];
    
    [request release];
}

- (void) move:(NSString *) path to:(NSString *) newPath
{
    NSURL * url = [_url URLByAppendingPathComponent:path];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"MOVE"];
    if (_token) [request setValue:_token forHTTPHeaderField:@"Authorization"];
    [request setValue:[self encodeString:newPath] forHTTPHeaderField:@"Destination"];
    
    DataURLConnection * movingConncetion = [[DataURLConnection alloc] initWithRequest:request delegate:self];
    movingConncetion.type = CONNECTION_TYPE_MOVING;
    movingConncetion.successCode = 201;
    movingConncetion.successSelector = @selector(didFinishMoving:);
    movingConncetion.failSelector = @selector(webDavClient:movingError:);
    [movingConncetion start];
    
    [request release];
}

#pragma mark create folder

- (void) createFolder:(NSString *) path
{
    NSURL * url = [_url URLByAppendingPathComponent:path];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"MKCOL"];
    if (_token) [request setValue:_token forHTTPHeaderField:@"Authorization"];
    
    DataURLConnection * creatingFolderConncetion = [[DataURLConnection alloc] initWithRequest:request delegate:self];
    creatingFolderConncetion.type = CONNECTION_TYPE_CREATING_FOLDER;
    creatingFolderConncetion.successCode = 201;
    creatingFolderConncetion.successSelector = @selector(didFinishCreatingFolder:);
    creatingFolderConncetion.failSelector = @selector(webDavClient:creatingFolderError:);
    [creatingFolderConncetion start];
    
    [request release];
}

#pragma mark - upload & download

- (void) upload:(NSString *) path to:(NSString *) newPath
{
    NSURL * url = [_url URLByAppendingPathComponent:newPath];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPBody:[NSData dataWithContentsOfFile:path]];
    [request setHTTPMethod:@"PUT"];
    if (_token) [request setValue:_token forHTTPHeaderField:@"Authorization"];
    NSString * length = [[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] valueForKey:NSFileSize] stringValue];
    [request setValue:length forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"100-continue" forHTTPHeaderField:@"Expect"];
    [request setValue:@"application/binary" forHTTPHeaderField:@"Content-Type"];
    
    DataURLConnection * uploadingConncetion = [[DataURLConnection alloc] initWithRequest:request delegate:self];
    uploadingConncetion.type = CONNECTION_TYPE_UPLOADING;
    uploadingConncetion.successCode = 201;
    uploadingConncetion.successSelector = @selector(didFinishUploading:);
    uploadingConncetion.failSelector = @selector(webDavClient:uploadingError:);
    [uploadingConncetion start];
    
    [request release];
}

- (void) download:(NSString *) path to:(NSString *) newPath
{
    NSURL * url = [_url URLByAppendingPathComponent:path];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    if (_token) [request setValue:_token forHTTPHeaderField:@"Authorization"];
   
    DataURLConnection * downloadingConncetion = [[DataURLConnection alloc] initWithRequest:request delegate:self];
    downloadingConncetion.type = CONNECTION_TYPE_DOWNLOADING;
    downloadingConncetion.userInfo = newPath;
    downloadingConncetion.successCode = 200;
    downloadingConncetion.successSelector = @selector(webDavClient:didFinishDownloading:);
    downloadingConncetion.failSelector = @selector(webDavClient:downloadingError:);
    [downloadingConncetion start];
    
    [request release];
}

#pragma mark - NSURLConnection

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
    int statusCode = [httpResponse statusCode];
    
    DataURLConnection * connectionWithData = (DataURLConnection *)connection;
    if (statusCode == connectionWithData.successCode)
    {
        connectionWithData.data = [NSMutableData data];
    }
    else
    {
        [connection cancel];
        [self connection:connection didFailWithError:[self errorWithCode:statusCode]];
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
    DataURLConnection * connectionWithData = (DataURLConnection *)connection;
    [connectionWithData.data appendData:d];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DataURLConnection * connectionWithData = (DataURLConnection *)connection;
    
    if (_delegate && [_delegate respondsToSelector:connectionWithData.failSelector])
    {
        [_delegate performSelector:connectionWithData.failSelector withObject:self withObject:error];
    }
    
     [connection release];
}

- (void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (_login && !_password)
    {
    
        NSURLCredential *credential = [NSURLCredential credentialWithUser:_login
                                                             password:_password
                                                          persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
    else
    {
        [connection cancel];
        [connection release];
        [_delegate authenticationError:self];
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{    
    DataURLConnection * connectionWithData = (DataURLConnection *)connection;
    
    if (connectionWithData.type == CONNECTION_TYPE_LOADING_FILE_LIST)
    {
        //NSString *responseText = [[NSString alloc] initWithData:connectionWithData.data encoding:NSUTF8StringEncoding];
        
        self.parserError = nil;
        NSXMLParser *xmlParser = [[[NSXMLParser alloc] initWithData:connectionWithData.data] autorelease];
        [xmlParser setDelegate:self];
        [xmlParser parse];
        
        [connection release];
        return;
    }
    
    if (connectionWithData.type == CONNECTION_TYPE_DOWNLOADING)
    {
        NSString * destPath = connectionWithData.userInfo;
        [connectionWithData.data writeToFile:destPath atomically:true];
        if (_delegate && [_delegate respondsToSelector:@selector(webDavClient:didFinishDownloading:)])
        {
            [_delegate webDavClient:self didFinishDownloading:destPath];
        }
        
        [connection release];
        return;
    }
    
    if (connectionWithData.type == CONNECTION_TYPE_REMOVING)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(webDavClient:didFinishRemoving:)])
        {
            NSString * path = connectionWithData.userInfo;
            [_delegate webDavClient:self didFinishRemoving:path];
        }
        
        [connection release];
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:connectionWithData.successSelector])
    {
        [_delegate performSelector:connectionWithData.successSelector withObject:self];
    }
    
    [connection release];
}

#pragma mark -

- (NSError *) errorWithCode:(int) code
{
    NSDictionary * errorInfo
        = [NSDictionary dictionaryWithObject:[NSString stringWithFormat: NSLocalizedString(@"Server returned status code %d",@""), code]
                                      forKey:NSLocalizedDescriptionKey];
    
    return [NSError errorWithDomain:@"WebDav" code:code userInfo:errorInfo];
}

- (NSString *) encodeString:(NSString *) string
{
    return  [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
