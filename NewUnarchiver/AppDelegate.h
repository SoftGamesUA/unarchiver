//
//  AppDelegate.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 28.01.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MGSplitViewController.h"
#import "FileObject.h"
#import "QuickMessage.h"
#import "MBProgressHUD.h"

#define FILE_KEY                        @"FILE_KEY"
#define FOLDER_KEY                      @"FOLDER_KEY"
#define FILE_SOURCE_KEY                 @"FILE_SOURCE_KEY"
#define PASSWORD_KEY                    @"PASSWORD_KEY"
#define COPY_NOTIFICATION               @"COPY_NOTIFICATION"
#define FOLDER_DID_CHANGE_NOTIFICATION  @"FOLDER_DID_CHANGE_NOTIFICATION"
#define ZIP_NOTIFICATION                @"ZIP_NOTIFICATION"
#define UNZIP_NOTIFICATION              @"UNZIP_NOTIFICATION"
#define UNRAR_NOTIFICATION              @"UNRAR_NOTIFICATION"
#define DRAG_FILES_NOTIFICATION         @"DRAG_FILES_NOTIFICATION"
#define PREVIEW_FILE_NOTIFICATION       @"PREVIEW_FILE_NOTIFICATION"

#define DB_LINK_NOTIFICATION            @"DB_LINK_NOTIFICATION"
#define YANDEX_TOKEN_NOTIFICATION       @"YANDEX_TOKEN_NOTIFICATION"
#define YANDEX_TOKEN_KEY                @"YANDEX_TOKEN_KEY"

#define borderHeight 20
static int borderHeightBottom = 2;
#define navBarHeight 44
#define toolBarHeight 50
#define cellHeight 60

typedef enum _DetailViewMode
{
    DetailViewModeGrid = 1,
    DetailViewModePreview,
    DetailViewModeArchive,
}DetailViewMode;

@interface AppDelegate : UIResponder <UIApplicationDelegate, MGSplitViewControllerDelegate>
{
    MBProgressHUD * _progressHUD;
    QuickMessage * _quickMessage;
    NSMutableDictionary * _previousDefaults;
}

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (retain, nonatomic) IBOutlet MGSplitViewController *splitVC;
@property (retain, nonatomic) IBOutlet UINavigationController *masterNC;
@property (retain, nonatomic) IBOutlet UINavigationController *detailNC;

@property (assign, nonatomic) DetailViewMode detailViewMode;

@property (retain, nonatomic) FileObject * cache;
@property (retain, nonatomic) FileObject * inbox;
@property (retain, nonatomic) FileObject * documents;
@property (retain, nonatomic) FileObject * xFolder;

+ (bool) stringIsOK:(NSString*)str;
+ (bool) isImage:(FileObject *)file;
+ (NSString *)uniqString;
+ (NSString *) zipNameForFiles:(NSSet *)files;

- (void) showProgressHUDWithText:(NSString *)text;
- (void) hideProgressHUD;

- (void) showQuickMesage:(NSString *) text;


@end
