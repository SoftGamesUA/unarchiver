//
//  NavBar.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 31.01.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PopoverContent.h"

typedef enum _NavBarStyle
{
    NavBarStyleSimple,            // label
    NavBarStyleHome,              // label + subLabel
    NavBarStyleFolder,            // backBtn + label + sublabel
} NavBarStyle;

typedef enum _NavBarCustomButtonType
{
    NavBarCustomButtonTypeSettings,
    NavBarCustomButtonTypeViewMode,
    NavBarCustomButtonTypePreview,
}NavBarCustomButtonType;

@protocol NavBarDelegate <NSObject>
@optional
- (void) clickedNavBarIcon:(CGRect)iconFrame;
- (void) backButtonClick;
- (void) previewButtonClick;
@end

@interface NavBar : UIView <PopoverContentDelegate, UIPopoverControllerDelegate>
{
    AppDelegate * _appDelegate;
    
    UIImage * _btnSettingsImage, * _btnViewModeImage, * _btnPreviewImage;
    UIImageView * _imgViewIcon, * _imgViewBg;
    UIButton * _btnBack, * _btnCustom, *_btnPreviewMode, * _btnListMode, * _btnArchiveMode;
    UILabel * _label, * _subLabel;
    
    NavBarStyle _style;
    NavBarCustomButtonType _customBtnType;
    
    PopoverContent *_popoverContent;
}

- (id)initWithFrame:(CGRect)frame style:(NavBarStyle)style;

- (void) setLabelText:(NSString *)text;
- (void) setLabelTextColor:(UIColor *)color;
- (void) setSubLabelText:(NSString *)text;
- (void) setBackgroundImage:(UIImage*)image;
- (void) setBackButtonImage:(UIImage*)image;
- (void) setCustomButtonType:(NavBarCustomButtonType)type;
- (void) setSettingsButtonImage:(UIImage*)image;
- (void) setViewModeButtonImage:(UIImage*)image;
- (void) setPreviewButtonImage:(UIImage*)image;

@property (nonatomic, assign) id <NavBarDelegate> delegate;
@property (nonatomic, retain) UIViewController * viewController;
@property (nonatomic, retain) UIPopoverController * popoverController;
@property (nonatomic, retain) UIImage * iconImage;

@end
