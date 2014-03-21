//
//  ToolBar.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 01.02.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "ToolBar.h"
#import "MGSplitViewController.h"

@implementation ToolBar

- (void)btnClick:(UIButton*)btn;
{
    if ([_delegate respondsToSelector:@selector(clickedBtn:)]) 
    {
        [_delegate clickedBtn:btn.tag];
    }
}

- (UIButton * ) customBtnWithFrame:(CGRect )frame title:(NSString *)title
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:@"" forState:UIControlStateDisabled];
    btn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    btn.titleLabel.adjustsFontSizeToFitWidth = true;
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(frame.size.height / 2, 0, 0, 0)];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIImageView *) initCustomImageViewWithFrame:(CGRect )frame highlightedImage:(UIImage *)highlightedImage
{
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.userInteractionEnabled = true;
    imgView.highlightedImage = highlightedImage;
    [self addSubview:imgView];
    return imgView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) 
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) 
                                                     name:UIDeviceOrientationDidChangeNotification object:nil];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeToFit) name:CHANGE_SPLIT_POSITION_NOTIFICATION object:nil];
        }
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
//        UIImage *imgBg = [UIImage imageNamed:@"toolBarBG"];
//        UIImageView *imgViewBg = [[UIImageView alloc] initWithImage:imgBg];
//        imgViewBg.frame = self.bounds;
//        imgViewBg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _toolBar = [UIToolbar new];
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_toolBar];
        
//        [imgViewBg release];
        
        _btns = [[NSMutableArray alloc] init];
        _imgViews = [[NSMutableArray alloc] init];
        
        
        CGRect btnFrame = CGRectZero;
        btnFrame.size = CGSizeMake(frame.size.width / ToolBarBtnCount, frame.size.height);
        CGRect imgViewFrame = btnFrame;
        imgViewFrame.size.height -= frame.size.height / 3;
        
        UIImageView * imgView = [self initCustomImageViewWithFrame:imgViewFrame highlightedImage:[UIImage imageNamed:@"addBtnDisabled"]];
        [_imgViews addObject:imgView];
        [self addSubview:imgView];
        [imgView release];
        UIButton * btnAdd = [self customBtnWithFrame:btnFrame title:NSLocalizedString(@"Add", nil)];
        btnAdd.frame = btnFrame;
        btnAdd.tag = ToolBarBtnAdd;
        [_btns addObject:btnAdd];
        [self addSubview:btnAdd];
        
        btnFrame.origin.x += btnFrame.size.width;
        imgViewFrame.origin.x += imgViewFrame.size.width;
        imgView = [self initCustomImageViewWithFrame:imgViewFrame highlightedImage:[UIImage imageNamed:@"shareBtnDisabled"]];
        [_imgViews addObject:imgView];
        [self addSubview:imgView];
        [imgView release];
        UIButton * btnShare = [self customBtnWithFrame:btnFrame title:NSLocalizedString(@"Share", nil)];
        btnShare.frame = btnFrame;
        btnShare.tag = ToolBarBtnShare;
        [_btns addObject:btnShare];
        [self addSubview:btnShare];
        
        btnFrame.origin.x += btnFrame.size.width;
        imgViewFrame.origin.x += imgViewFrame.size.width;
        imgView = [self initCustomImageViewWithFrame:imgViewFrame highlightedImage:[UIImage imageNamed:@"ccpBtnDisabled"]];
        [_imgViews addObject:imgView];
        [self addSubview:imgView];
        [imgView release];
        UIButton * btnCCP = [self customBtnWithFrame:btnFrame title:NSLocalizedString(@"Copy", nil)];
        btnCCP.frame = btnFrame;
        btnCCP.tag = ToolBarBtnCCP;
        [_btns addObject:btnCCP];
        [self addSubview:btnCCP];
        
        btnFrame.origin.x += btnFrame.size.width;
        imgViewFrame.origin.x += imgViewFrame.size.width;
        imgView = [self initCustomImageViewWithFrame:imgViewFrame highlightedImage:[UIImage imageNamed:@"archiveBtnDisabled"]];
        [_imgViews addObject:imgView];
        [self addSubview:imgView];
        [imgView release];
        UIButton * btnArchive = [self customBtnWithFrame:btnFrame title:NSLocalizedString(@"Archive", nil)];
        btnArchive.frame = btnFrame;
        btnArchive.tag = ToolBarBtnArchive;
        [_btns addObject:btnArchive];
        [self addSubview:btnArchive];
        
        btnFrame.origin.x += btnFrame.size.width;
        imgViewFrame.origin.x += imgViewFrame.size.width;
        imgView = [self initCustomImageViewWithFrame:imgViewFrame highlightedImage:[UIImage imageNamed:@"deleteBtnDisabled"]];
        [_imgViews addObject:imgView];
        [self addSubview:imgView];
        [imgView release];
        UIButton * btnDelete = [self customBtnWithFrame:btnFrame title:NSLocalizedString(@"Delete", nil)];
        btnDelete.frame = btnFrame;
        btnDelete.tag = ToolBarBtnDelete;
        [_btns addObject:btnDelete];
        [self addSubview:btnDelete];
        
        btnFrame.origin.x += btnFrame.size.width;
        imgViewFrame.origin.x += imgViewFrame.size.width;
        imgView = [self initCustomImageViewWithFrame:imgViewFrame highlightedImage:[UIImage imageNamed:@"helpBtnDisabled"]];
        [_imgViews addObject:imgView];
        [self addSubview:imgView];
        [imgView release];
        UIButton * btnHelp = [self customBtnWithFrame:btnFrame title:NSLocalizedString(@"Help", nil)];
        btnHelp.frame = btnFrame;
        btnHelp.tag = ToolBarBtnHelp;
        [_btns addObject:btnHelp];
        [self addSubview:btnHelp];
           
        for (UIButton *btn in _btns)
        {
            [self setEnabled:false forBtn:btn.tag];
        }
    }
    return self;
}

- (void) sizeToFit
{
    int buttonWidth = self.frame.size.width / ToolBarBtnCount;
    
    for (int i = 0; i < ToolBarBtnCount; i++)
    {
        UIButton * some_btn = [_btns objectAtIndex:i];
        CGRect frame = some_btn.frame;
        frame.origin.x = buttonWidth * i;
        frame.size.width = buttonWidth;
        some_btn.frame = frame;
        
        UIImageView * imgView = [_imgViews objectAtIndex:i];
        frame = imgView.frame;
        frame.origin.x = buttonWidth * i;
        frame.size.width = buttonWidth;
        imgView.frame = frame;
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_btns release];

    [super dealloc];
}

- (void) setImage:(UIImage *)image forBtn:(ToolBarBtnTag)btnTag
{
    if (btnTag >= ToolBarBtnCount) return;
    
    UIImageView * imgView = [_imgViews objectAtIndex:btnTag];
    [imgView setImage:image];
}

- (void) setEnabled:(bool)enabled forBtn:(ToolBarBtnTag)btnTag
{
    if (btnTag >= ToolBarBtnCount) return;
    
    UIButton * some_btn = [_btns objectAtIndex:btnTag];
    [some_btn setEnabled:enabled];
    
    UIImageView * imgView = [_imgViews objectAtIndex:btnTag];
    imgView.highlighted = !enabled;
}

- (void) setSelected:(bool)selected forBtn:(ToolBarBtnTag)btnTag
{
    /*if (btnTag >= ToolBarBtnCount) return;
    
    UIButton * some_btn = [_btns objectAtIndex:btnTag];
    [some_btn setSelected:enabled]; */
}

- (void) setButtonTitleColor:(UIColor *)color
{
    for (UIButton * btn in _btns)
    {
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    UIButton * btnHelp = [_btns objectAtIndex:ToolBarBtnHelp];
    btnHelp.hidden = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

- (CGRect) rectForPopoverInView:(UIView *)view btn:(ToolBarBtnTag)btnTag
{
    UIButton * btn = [_btns objectAtIndex:btnTag];
    CGRect rect = [self convertRect:btn.frame toView:view];
    rect.origin.y += 15; //тень под поповером
    return rect;
}

@end
