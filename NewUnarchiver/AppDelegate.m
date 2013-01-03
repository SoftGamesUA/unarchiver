//
//  AppDelegate.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 28.01.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "AppDelegate.h"

#import "config.h"
#import "FolderVC.h"
#import "HomeVC.h"
#import "PopoverBgViews.h"

#ifdef DROPBOX_UNARCHIVER
    #import "DropboxVC.h"
    #import <DropboxSDK/DropboxSDK.h>
#endif

#ifdef BOX_UNARCHIVER
    #import "BoxVC.h"
#endif

#ifdef YANDEX_UNARCHIVER
    #import "YandexDiskVC.h"
#endif

#ifdef GOOGLE_UNARCHIVER
    #import "GoogleDriveVC.h"
#endif

@implementation AppDelegate

- (void)dealloc
{
    self.window = nil;
    self.splitVC = nil;
    self.masterNC = nil;
    self.detailNC = nil;

    [_progressHUD release];
    [_quickMessage release];
    [_previousDefaults release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self createInboxIfNeeded];
    [self createCacheIfNeeded];
    [self createXFilesIfNeeded];
 
    [self logOutIfNeeded:false];
    _previousDefaults = [[NSMutableDictionary alloc] init];
    
    _progressHUD = [[MBProgressHUD alloc] initWithWindow:_window];
    [_window addSubview:_progressHUD];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
        [self initPopoverBgViews];
        [_splitVC setDividerStyle: MGSplitViewDividerStyleUnarchiver animated:YES];
        _splitVC.showsMasterInLandscape = YES;
        _splitVC.showsMasterInPortrait = YES;
        [_splitVC toggleMasterView:nil];
    
        HomeVC *vc1 = [[HomeVC alloc] init];
        vc1.isMaster = true;
        HomeVC *vc2 = [[HomeVC alloc] init];
        vc2.isMaster = false;
        [_masterNC pushViewController:vc1 animated:false];
        [_detailNC pushViewController:vc2 animated:false];
        _detailViewMode = DetailViewModeGrid;
        [vc1 release];
        [vc2 release];
        
        _quickMessage = [[QuickMessage alloc] initWithFrame:_splitVC.view.frame];
        [_splitVC.view addSubview:_quickMessage];
        
        _splitVC.showsMasterInLandscape = YES;
        _splitVC.showsMasterInPortrait = YES;

    }
    else
    {
        HomeVC *vc = [[HomeVC alloc] init];
        vc.isMaster = true;
        [_masterNC pushViewController:vc animated:false];
        [vc release];
        
        _quickMessage = [[QuickMessage alloc] initWithFrame:_masterNC.view.frame];
        [_masterNC.view addSubview:_quickMessage];
    }
    
    [_window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    
#ifdef DROPBOX_UNARCHIVER
    
    if ([[DBSession sharedSession] handleOpenURL:url]) 
    {
        if ([[DBSession sharedSession] isLinked]) 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:DB_LINK_NOTIFICATION object:self];
        }
        return true;
    }
    
#endif
    
    NSString * fullString = [url absoluteString];
    if ([fullString hasPrefix:@"yandex-"] )
    {
        NSArray * components = [fullString componentsSeparatedByString:@"#"];
        NSString * parametersString = [components objectAtIndex:1];
        components = [parametersString componentsSeparatedByString:@"&"];
        NSString * tokenParameter = [components objectAtIndex:0];
        components = [tokenParameter componentsSeparatedByString:@"="];
        NSString * token = [NSString stringWithFormat:@"OAuth %@", [components objectAtIndex:1]];
        
        [[NSUserDefaults standardUserDefaults] setValue:token forKey:YANDEX_TOKEN_KEY];
        [[NSNotificationCenter defaultCenter] postNotificationName:YANDEX_TOKEN_NOTIFICATION object:self];
        
        return true;
    }

    NSString * newPath = [NSString stringWithFormat:@"%@/%@", self.inbox, [[url path]lastPathComponent]];
    [[NSFileManager defaultManager] moveItemAtPath:[url path] toPath:newPath error:nil];  
	[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", self.documents.path, @"Inbox"] error:NULL];
    
    [_masterNC popToRootViewControllerAnimated:false];
    FolderVC *vc = [[FolderVC alloc] init];
    vc.isMaster = true;
    vc.rootFolder = self.inbox;
    [_masterNC pushViewController:vc animated:false];
    [vc release];
    
    return true;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [_previousDefaults removeAllObjects];
    [_previousDefaults addEntriesFromDictionary:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self logOutIfNeeded:true];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - log out

- (void) logOutIfNeeded:(bool)popViewController
{
#ifdef DROPBOX_UNARCHIVER
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"link_dropbox"])
    {
        [DropboxVC logOut];
        
        if (popViewController && [[_previousDefaults objectForKey:@"link_dropbox"] boolValue])
        {
            if ([_masterNC.topViewController isKindOfClass:DropboxVC.class])
            {
                [_masterNC performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:true] afterDelay:1];
            }
            if ([_detailNC.topViewController isKindOfClass:DropboxVC.class])
            {
                [_detailNC performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:true] afterDelay:1];
            }
        }
    }
    
#endif
    
#ifdef BOX_UNARCHIVER
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"link_box"])
    {
        [BoxVC logOut];
        
        if (popViewController && [[_previousDefaults objectForKey:@"link_box"] boolValue])
        {
            if ([_masterNC.topViewController isKindOfClass:BoxVC.class])
            {
                [_masterNC performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:true] afterDelay:1];
            }
            if ([_detailNC.topViewController isKindOfClass:BoxVC.class])
            {
                [_detailNC performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:true] afterDelay:1];
            }
        }
    }
    
#endif
    
#ifdef YANDEX_UNARCHIVER
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"link_yandex"])
    {
        [YandexDiskVC logOut];
        
        if (popViewController && [[_previousDefaults objectForKey:@"link_yandex"] boolValue])
        {
            if ([_masterNC.topViewController isKindOfClass:YandexDiskVC.class])
            {
                [_masterNC performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:true] afterDelay:1];
            }
            if ([_detailNC.topViewController isKindOfClass:YandexDiskVC.class])
            {
                [_detailNC performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:true] afterDelay:1];
            }
        }
    }
    
#endif
    
#ifdef GOOGLE_UNARCHIVER
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"link_google"])
    {
        [GoogleDriveVC logOut];
        
        if (popViewController && [[_previousDefaults objectForKey:@"link_google"] boolValue])
        {
            if ([_masterNC.topViewController isKindOfClass:GoogleDriveVC.class])
            {
                [_masterNC performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:true] afterDelay:1];
            }
            if ([_detailNC.topViewController isKindOfClass:GoogleDriveVC.class])
            {
                [_detailNC performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:true] afterDelay:1];
            }
        }
    }
    
#endif
}

#pragma mark -
#pragma mark popovers

- (void) initPopoverBgViews
{
    // set appearances for popovers
    [MBPopoverBackgroundView initialize];
    
    // for tool bar
    [PopoverBgViewToolbarDark setArrowImageName:@"ToolbarDarkPopoverArrow"];
    [PopoverBgViewToolbarDark setBackgroundImageName:@"ToolbarDarkPopoverBg"];
    [PopoverBgViewToolbarDark setBackgroundImageCapInsets:UIEdgeInsetsMake(10, 20, 20, 20)];
    [PopoverBgViewToolbarDark setContentViewInsets:UIEdgeInsetsMake(3, 5, 18, 5)];
    [PopoverBgViewToolbarDark setBackgroundImageShadowInsets:UIEdgeInsetsMake(0, 4, 15, 4)];
    
    [PopoverBgViewToolbarRed setArrowImageName:@"ToolbarRedPopoverArrow"];
    [PopoverBgViewToolbarRed setBackgroundImageName:@"ToolbarRedPopoverBg"];
    [PopoverBgViewToolbarRed setBackgroundImageCapInsets:UIEdgeInsetsMake(10, 20, 20, 20)];
    [PopoverBgViewToolbarRed setContentViewInsets:UIEdgeInsetsMake(3, 5, 15, 5)];
    [PopoverBgViewToolbarRed setBackgroundImageShadowInsets:UIEdgeInsetsMake(0, 4, 15, 4)];
}

#pragma mark -

+ (bool) isImage:(FileObject *)file
{
    NSString * ext = [[file.displayName pathExtension] lowercaseString];
    
    if ([ext isEqualToString:@"tiff"] || [ext isEqualToString:@"tif"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"] ||
        [ext isEqualToString:@"png"] || [ext isEqualToString:@"bmp"] || [ext isEqualToString:@"bmpf"] || [ext isEqualToString:@"ico"] ||
        [ext isEqualToString:@"cur"] || [ext isEqualToString:@"xbm"]) 
    {
        return  true;
    }
    
    return false;
}

- (FileObject *) cache
{
    if (!_cache)
    {
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [paths objectAtIndex:0];
        
        _cache = [[FileObject folderWithPath:cachePath] retain];
    }

    return _cache;
}

- (FileObject *) documents
{
    if (!_documents)
    {
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSDocumentDirectory, YES);
        NSString * documentsPath = [paths objectAtIndex:0];
        
        _documents = [[FileObject folderWithPath:documentsPath] retain];
    }
    
    return _documents;
}

- (FileObject *) inbox
{    
    if (!_inbox)
    {
         NSString * inboxPath = [self.documents.path stringByAppendingPathComponent:@"Inbox "];
        _inbox = [[FileObject folderWithPath:inboxPath] retain];
    }
    
    return _inbox;
}

- (FileObject *) xFolder
{    
    if (!_xFolder)
    {
        NSString * xFolderPath = [self.documents.path stringByAppendingPathComponent:@".XFolder"];
        _xFolder = [[FileObject folderWithPath:xFolderPath] retain];
    }
    
    return _xFolder;
}

- (void) createInboxIfNeeded
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.inbox.path])
        [[NSFileManager defaultManager] createDirectoryAtPath:self.inbox.path withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void) createCacheIfNeeded
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.cache.path])
        [[NSFileManager defaultManager] createDirectoryAtPath:self.cache.path withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void) createXFilesIfNeeded
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.xFolder.path])
        [[NSFileManager defaultManager] createDirectoryAtPath:self.xFolder.path withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void) clearCache
{
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.cache.path  error:nil];
    for (NSString * name in files)
    {
        NSString * path = [self.cache.path stringByAppendingPathComponent:name];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

+ (bool) stringIsOK:(NSString*)str
{
	NSString *stringWithoutSpaces = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
	if ([stringWithoutSpaces length] > 0) return true;
	else return false;
}

+ (NSString *) zipNameForFiles:(NSSet *)files
{
    if (!files || [files count] == 0) return nil;
    
    NSString * zipName;
    if ([files count] == 1)
    {
        FileObject * file = [files anyObject];
        zipName = [NSString stringWithFormat:@"%@.zip", [file.displayName stringByDeletingPathExtension]];
    }
    else zipName = [NSString stringWithFormat:@"%@.zip", NSLocalizedString(@"Archive", nil)];
    
    return zipName;
}

+ (NSString *)uniqString
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    
    return [(NSString *)string autorelease];
}

#pragma mark - progress

- (void) showProgressHUDWithText:(NSString *)text
{
    if (!_progressHUD.isShowing)
    {
        [_progressHUD show:true];
    }
    _progressHUD.labelText = text;
}

- (void) hideProgressHUD
{
    [_progressHUD hide:true];
}

- (void) showQuickMesage:(NSString *)text
{
    [_quickMessage.superview bringSubviewToFront:_quickMessage];
    _quickMessage.frame = CGRectMake(0, _quickMessage.superview.bounds.size.height - borderHeight - navBarHeight, _quickMessage.superview.bounds.size.width, navBarHeight);
    [_quickMessage showWithText:text];
}

@end
