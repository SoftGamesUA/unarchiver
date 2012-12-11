//
//  SKPluginTransaction.m
//  PrimeInAppTest
//
//  Created by Mike DeSaro on 8/23/10.
//  Copyright 2010 FreedomVOICE. All rights reserved.
//

#import "SKPluginTransaction.h"

#define kArchiveFile @"storeKitReceipts.archive"

@implementation SKPluginTransaction

@synthesize base64EncodedReceipt = _base64EncodedReceipt, productIdentifier = _productIdentifier, quantity = _quantity;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Class methods
+ (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                              error:(NSError **)errorOut
{
    // Search for the path
    NSArray* paths = NSSearchPathForDirectoriesInDomains(
                                                         searchPathDirectory,
                                                         domainMask,
                                                         YES);
    if ([paths count] == 0)
    {
        // *** creation and return of error object omitted for space
        return nil;
    }
    
    // Normally only need the first path
    NSString *resolvedPath = [paths objectAtIndex:0];
    
    if (appendComponent)
    {
        resolvedPath = [resolvedPath
                        stringByAppendingPathComponent:appendComponent];
    }
    
    // Create the path if it doesn't exist
    NSError *error;
    BOOL success = [[NSFileManager defaultManager]
                    createDirectoryAtPath:resolvedPath
                    withIntermediateDirectories:YES
                    attributes:nil
                    error:&error];
    if (!success) 
    {
        if (errorOut)
        {
            *errorOut = error;
        }
        return nil;
    }
    
    // If we've made it this far, we have a success
    if (errorOut)
    {
        *errorOut = nil;
    }
    return resolvedPath;
}

+ (NSString *)applicationSupportDirectory
{
    NSString *executableName =
    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSError *error;
    NSString *result =
    [SKPluginTransaction
     findOrCreateDirectory:NSApplicationSupportDirectory
     inDomain:NSUserDomainMask
     appendPathComponent:executableName
     error:&error];
    if (error)
    {
        NSLog(@"Unable to find or create application support directory:\n%@", error);
    }
    return result;
}

+ (NSString*)documentsPathForFile:(NSString*)filename
{
    /*NSArray **/
    NSString *thePathForSavedFile = [SKPluginTransaction applicationSupportDirectory];//NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    return [thePathForSavedFile stringByAppendingPathComponent:filename];
}


+ (NSMutableArray*)savedTransactions
{
	NSMutableArray *transactions = [[NSKeyedUnarchiver unarchiveObjectWithFile:[SKPluginTransaction documentsPathForFile:kArchiveFile]] mutableCopy];
	if( !transactions )
		transactions = [NSMutableArray arrayWithCapacity:1];
	return transactions;
}


+ (void)saveTransaction:(SKPluginTransaction*)transaction
{
	// grab the transacitons from disk and add this one to it
	NSMutableArray *transactions = [SKPluginTransaction savedTransactions];
	[transactions addObject:transaction];
	
	// save to disk
	NSString *filePath = [self documentsPathForFile:kArchiveFile];
	[NSKeyedArchiver archiveRootObject:transactions toFile:filePath];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSObject

- (void)dealloc
{
	[_base64EncodedReceipt release];
	[_productIdentifier release];
	
	[super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)coder
{
	if( ( self = [self init] ) )
	{
		_base64EncodedReceipt = [[coder decodeObjectForKey:@"base64EncodedReceipt"] retain];
		_productIdentifier = [[coder decodeObjectForKey:@"productIdentifier"] retain];
		_quantity = [coder decodeIntForKey:@"quantity"];
	}
	return self;
}


- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeObject:_base64EncodedReceipt forKey:@"base64EncodedReceipt"];
	[coder encodeObject:_productIdentifier forKey:@"productIdentifier"];
	[coder encodeInt:_quantity forKey:@"quantity"];
}

@end
