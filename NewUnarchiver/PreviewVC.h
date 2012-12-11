//
//  PreviewVC.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 13.03.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasicVC.h"
#import <QuickLook/QuickLook.h>

@interface PreviewVC : BasicVC <QLPreviewControllerDataSource>
{
    QLPreviewController * _previewer;
    NSURL * _fileToPreview;
}

@end
