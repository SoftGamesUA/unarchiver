//
//  CameraItem.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 19.07.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraItem;
@protocol CameraItemDelegate <NSObject>
@optional
- (void) cameraItemDidTouch:(CameraItem *)item;
- (void) cameraItemCheckBoxDidTouch:(CameraItem *)item;
@end

@interface CameraItem : UIImageView
{
    UIImageView * _checkBox;
    UIImage * _checkBoxChecked, * _checkBoxUnchecked;
}

@property (nonatomic, assign) id <CameraItemDelegate> delegate;
@property (nonatomic, assign) bool selected;

@end
