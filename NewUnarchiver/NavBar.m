//
//  NavBar.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 31.01.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "NavBar.h"

#import "PreviewVC.h"
#import "HomeVC.h"
#import "ArchiveVC.h"

#import "PopoverBgViewToolbarDark.h"

@implementation NavBar

- (id)initWithFrame:(CGRect)frame style:(NavBarStyle)style
{
    _style = style;
    
    CGRect iconFrame = CGRectZero, labelFrame = CGRectZero, subLabelFrame = CGRectZero, backBtnFrame = CGRectZero, customBtnFrame = CGRectZero;
    
    int barWidth = frame.size.width;
    int barHeight = frame.size.height;
    int space = 5;
    
    self = [super initWithFrame:frame];
    if (self) 
    {
        _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _imgViewBg = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgViewBg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_imgViewBg];
        
        iconFrame = CGRectMake(space, space, barHeight - space * 2, barHeight - space * 2);
        _imgViewIcon = [[UIImageView alloc] initWithFrame:iconFrame];
        [self addSubview:_imgViewIcon];
        
        customBtnFrame = CGRectMake(barWidth - barHeight + space, space, barHeight - space * 2, barHeight - space * 2);
        _btnCustom = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _btnCustom.frame = customBtnFrame;
        _btnCustom.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;   
        [_btnCustom addTarget:self action:@selector(customBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnCustom];
        
        if (_style == NavBarStyleSimple) 
        {
            labelFrame = CGRectMake(barWidth/4, barHeight/4, barWidth/2, barHeight/2);
            _label = [[UILabel alloc] initWithFrame:labelFrame];
            _label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleLeftMargin;
            _label.backgroundColor = [UIColor clearColor];
            _label.textAlignment = UITextAlignmentCenter;
            [self addSubview:_label];
        } 
        else if (_style == NavBarStyleHome) 
        {
            labelFrame.origin = CGPointMake(iconFrame.origin.x + iconFrame.size.width + space * 2, space);
            labelFrame.size = CGSizeMake(barWidth - labelFrame.origin.x - barWidth + customBtnFrame.origin.x, barHeight/2);
            _label = [[UILabel alloc] initWithFrame:labelFrame];
            _label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;      
            _label.backgroundColor = [UIColor clearColor];
            _label.textAlignment = UITextAlignmentLeft;
            _label.font = [_label.font fontWithSize:15];
            [self addSubview:_label];
            
            subLabelFrame.origin = CGPointMake(labelFrame.origin.x, barHeight/2);
            subLabelFrame.size = labelFrame.size;
            _subLabel = [[UILabel alloc] initWithFrame:subLabelFrame];
            _subLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;      
            _subLabel.backgroundColor = [UIColor clearColor];
            _subLabel.textColor = [UIColor grayColor];
            _subLabel.textAlignment = UITextAlignmentLeft;
            _subLabel.font = [_subLabel.font fontWithSize:12];
            [self addSubview:_subLabel];
        }
        else if (_style == NavBarStyleFolder) 
        {
            backBtnFrame = CGRectMake(iconFrame.origin.x + iconFrame.size.width + space, space, 
                                     barHeight - space * 2, barHeight - space * 2);
            _btnBack = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
            _btnBack.frame = backBtnFrame;
            [_btnBack setBackgroundImage:[UIImage imageNamed:@"backBtnNormal.png"] forState:UIControlStateSelected];
            [_btnBack setBackgroundImage:[UIImage imageNamed:@"backBtnNormal.png"] forState:UIControlStateHighlighted];
            [_btnBack addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_btnBack];
           
            labelFrame.origin = CGPointMake(backBtnFrame.origin.x + backBtnFrame.size.width + space * 2, space);
            labelFrame.size = CGSizeMake(barWidth - labelFrame.origin.x - barWidth + customBtnFrame.origin.x, barHeight/2);
            _label = [[UILabel alloc] initWithFrame:labelFrame];
            _label.autoresizingMask = UIViewAutoresizingFlexibleWidth;      
            _label.backgroundColor = [UIColor clearColor];
            _label.textAlignment = UITextAlignmentLeft;
            _label.font = [_label.font fontWithSize:15];
            [self addSubview:_label];
            
            subLabelFrame.origin = CGPointMake(labelFrame.origin.x, barHeight/2);
            subLabelFrame.size = labelFrame.size;
            _subLabel = [[UILabel alloc] initWithFrame:subLabelFrame];
            _subLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;      
            _subLabel.backgroundColor = [UIColor clearColor];
            _subLabel.textColor = [UIColor grayColor];
            _subLabel.textAlignment = UITextAlignmentLeft;
            _subLabel.font = [_subLabel.font fontWithSize:12];
            [self addSubview:_subLabel];
        }
    }
    return self;
}

- (void)dealloc
{
    [_imgViewIcon release];
    [_imgViewBg release];
    [_btnBack release];
    [_btnCustom release];
    [_label release];
    [_subLabel release];
    [_btnPreviewMode release];
    [_btnListMode release];
    [_btnArchiveMode release];
    [_popoverController release];
    [_popoverContent release];
    [_viewController release];
    [_btnSettingsImage release];
    [_btnViewModeImage release];
    [_iconImage release];
    [_btnPreviewImage release];
    
    [super dealloc];
}

#pragma mark -
#pragma clicks

- (void) customBtnClick
{
    if (_customBtnType == NavBarCustomButtonTypeViewMode)
    {
        _btnCustom.selected = true;
        
        [self.popoverController presentPopoverFromRect:_btnCustom.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (_customBtnType == NavBarCustomButtonTypePreview)
    {
        if ([_delegate respondsToSelector:@selector(previewButtonClick)])
        {
            [_delegate previewButtonClick];
        }
    }
}

- (void) backBtnClick
{
    if ([_delegate respondsToSelector:@selector(backButtonClick)]) 
    {
        [_delegate backButtonClick];
    }
}

- (void) btnListModeClick
{
    HomeVC *vc = [[HomeVC alloc] init];
    vc.isMaster = false;
    [_appDelegate.detailNC popToRootViewControllerAnimated:false];
    [_appDelegate.detailNC pushViewController:vc animated:true];
    [vc release];
    
    _appDelegate.detailViewMode = DetailViewModeGrid;
}

- (void) btnPreviewModeClick
{
    PreviewVC *vc = [[PreviewVC alloc] init];
    [_appDelegate.detailNC popToRootViewControllerAnimated:false];
    [_appDelegate.detailNC pushViewController:vc animated:true];
    [vc release];
    
    _appDelegate.detailViewMode = DetailViewModePreview;
}

- (void) btnArchiveModeClick
{
    ArchiveVC *vc = [[ArchiveVC alloc] init];
    [_appDelegate.detailNC popToRootViewControllerAnimated:false];
    [_appDelegate.detailNC pushViewController:vc animated:true];
    [vc release];
    
    _appDelegate.detailViewMode = DetailViewModeArchive;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
	if (touch) 
    {
		CGPoint location = [touch locationInView:self];
        if (CGRectContainsPoint(_imgViewIcon.frame, location)) 
        {
            if ([_delegate respondsToSelector:@selector(clickedNavBarIcon:)]) 
            {
                [_delegate clickedNavBarIcon:_imgViewIcon.frame];
            }
        }
    }
}

#pragma mark -
#pragma PopoverContentDelegate

- (NSString *)textForBtnAtIndex:(int)index popoverContent:(PopoverContent *)popoverContent
{
    if (index == 0) return NSLocalizedString(@"Grid View", nil);
    else if (index == 1) return NSLocalizedString(@"Preview", nil);
    else if (index == 2) return NSLocalizedString(@"Archive", nil);
    return nil;
}

- (UIImage *)imageForBtnAtIndex:(int)index popoverContent:(PopoverContent *)popoverContent
{
    if (index == 0) return [UIImage imageNamed:@"listModeIcon"];
    else if (index == 1) return [UIImage imageNamed:@"previewModeIcon"];
    else if (index == 2) return [UIImage imageNamed:@"archiveModeIcon"];
    return nil;
}

- (void)clickedBtnAtIndex:(int)index popoverContent:(PopoverContent *)popoverContent
{
    if (index == 0) [self btnListModeClick];
    else if (index == 1) [self btnPreviewModeClick];
    else if (index == 2) [self btnArchiveModeClick];
    
    [_popoverController dismissPopoverAnimated:true];
}

#pragma mark UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    _btnCustom.selected = false;
    return true;
}

#pragma mark -
#pragma settings

- (void) setIconImage:(UIImage *)iconImage
{
    [_iconImage release];
    _iconImage = [iconImage retain];
    [_imgViewIcon setImage:iconImage];
}

- (void) setLabelTextColor:(UIColor *)color
{
    [_label setTextColor:color];
}

- (void) setLabelText:(NSString *)text
{
    [_label setText:text];
}

- (void) setSubLabelText:(NSString *)text
{
    if (_style == NavBarStyleSimple)   return;
    [_subLabel setText:text];
}

- (void) setBackgroundImage:(UIImage *)image
{
     [_imgViewBg setImage:image];
}

- (void) setBackButtonImage:(UIImage *)image
{
    if (_style != NavBarStyleFolder)   return;
    [_btnBack setBackgroundImage:image forState:UIControlStateNormal];
}

- (void) setCustomButtonType:(NavBarCustomButtonType)type
{
    if (type == NavBarCustomButtonTypeSettings)
    {
        _btnCustom.hidden = true;
        [_btnCustom setBackgroundImage:_btnSettingsImage forState:UIControlStateNormal];
        [_btnCustom setBackgroundImage:[UIImage imageNamed:@"settingsBtnNormal"] forState:UIControlStateSelected];
        [_btnCustom setBackgroundImage:[UIImage imageNamed:@"settingsBtnNormal"] forState:UIControlStateHighlighted];
    }
    else if(type == NavBarCustomButtonTypeViewMode)
    {
        _btnCustom.hidden = false;
        [_btnCustom setBackgroundImage:_btnViewModeImage forState:UIControlStateNormal];
        [_btnCustom setBackgroundImage:[UIImage imageNamed:@"listBtnNormal"] forState:UIControlStateSelected];
        [_btnCustom setBackgroundImage:[UIImage imageNamed:@"listBtnNormal"] forState:UIControlStateHighlighted];
    }
    else if(type == NavBarCustomButtonTypePreview)
    {
        _btnCustom.hidden = false;
        [_btnCustom setBackgroundImage:_btnPreviewImage forState:UIControlStateNormal];
        [_btnCustom setBackgroundImage:[UIImage imageNamed:@"previewBtnNormal"] forState:UIControlStateSelected];
        [_btnCustom setBackgroundImage:[UIImage imageNamed:@"previewBtnNormal"] forState:UIControlStateHighlighted];
    }
    
    _customBtnType = type;
}

- (void) setSettingsButtonImage:(UIImage *)image
{
    [_btnSettingsImage release];
    _btnSettingsImage = [image retain];
    [self setCustomButtonType:_customBtnType];
}

- (void) setViewModeButtonImage:(UIImage *)image
{
    [_btnViewModeImage release];
    _btnViewModeImage = [image retain];
    [self setCustomButtonType:_customBtnType];
}

- (void) setPreviewButtonImage:(UIImage*)image
{
    [_btnPreviewImage release];
    _btnPreviewImage = [image retain];
    [self setCustomButtonType:_customBtnType];
}

- (UIPopoverController *)popoverController
{
    if (!_popoverController)
    {
        UIImage *bgImg = [UIImage imageNamed:@"NavBarPopoverBtn"];
        UIImage *bgImgPush = [UIImage imageNamed:@"NavBarPopoverBtnPush"];
            
        _popoverContent = [[PopoverContent alloc] initWithStyle:PopoverContentStyleVertical];
        _popoverContent.delegate = self;
        [_popoverContent setBtnCount:3];
        [_popoverContent setBtnSize:bgImg.size];
        [_popoverContent setBtnBackgroundImage:bgImg];
        [_popoverContent setBtnBackgroundImagePush:bgImgPush];
        [_popoverContent setTextColor:[UIColor whiteColor]];
        [_popoverContent setHorizontAlingment:UIControlContentHorizontalAlignmentLeft];
        [_popoverContent setup];
            
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:_popoverContent];
         _popoverController.popoverBackgroundViewClass = [PopoverBgViewToolbarDark class];
        _popoverController.delegate = self;
        [_popoverController setPopoverContentSize:_popoverContent.view.frame.size animated:YES];
    }
    
    return _popoverController;
}


@end
