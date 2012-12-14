//
//  FileViewer.h
//  NewUnarchiver
//
//  Created by Zhenya Koval on 13.12.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicVC.h"
#import <QuickLook/QuickLook.h>

@interface FileViewer : BasicVC <QLPreviewControllerDataSource>

@property (nonatomic, retain) NSURL * URL;

@end
