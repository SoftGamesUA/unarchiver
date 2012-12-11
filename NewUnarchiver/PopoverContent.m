//
//  PopoverContent.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 08.02.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "PopoverContent.h"

@implementation PopoverContent

@synthesize delegate = _delegate;
@synthesize btnCount = _btnCount;
@synthesize btnSize = _btnSize;
@synthesize btnImage = _btnImage;
@synthesize btnBackgroundImage = _btnBackgroundImage;
@synthesize btnBackgroundImagePush = _btnBackgroundImagePush;
@synthesize dividerImage = _dividerImage;
@synthesize horizontAlingment = _horizontAlingment;
@synthesize textColor = _textColor;

- (void)btnClick:(UIButton*)btn;
{
    [_delegate clickedBtnAtIndex:[_btns indexOfObject:btn] popoverContent:self];
}

- (id)initWithStyle:(PopoverContentStyle)style
{
    self = [super init];
    if (self) 
    {
        _style = style;
        _btns = [[NSMutableArray alloc] init];
        _horizontAlingment = UIControlContentHorizontalAlignmentCenter;
        _textColor = [UIColor blackColor];
        
        self.view.autoresizingMask = UIViewAutoresizingNone;
    }
    return self;
}

- (void) setup
{
    for (UIView *subView in self.view.subviews) [subView removeFromSuperview];
    [_btns removeAllObjects];
        
    CGRect btnFrame = CGRectZero, dividerFrame = CGRectZero;  
        
    int tab = 0;
    if (_style == PopoverContentStyleBreadcrumbs)
    {
        tab = 10;
        _btnSize.width += tab * _btnCount;
    }
        
    for (int i = 0; i < _btnCount; i++) 
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.contentHorizontalAlignment = _horizontAlingment;
        
        if (_btnBackgroundImage)
            [btn setBackgroundImage:[_btnBackgroundImage stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
        if (_btnBackgroundImagePush) 
            [btn setBackgroundImage:[_btnBackgroundImagePush stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];


        if (_style == PopoverContentStyleHorizont) btnFrame.origin.x = _btnSize.width * i;
        else if (_style == PopoverContentStyleVertical) btnFrame.origin.y = _btnSize.height * i;
        else if (_style == PopoverContentStyleBreadcrumbs)
        {
            if (i != 0)
            {
                btnFrame.origin.x += tab;
                _btnSize.width -= tab;
            }
            btnFrame.origin.y = _btnSize.height * i;
        }
            
        btnFrame.size = _btnSize;
        btn.frame = btnFrame;
            
        if ([_delegate respondsToSelector:@selector(textForBtnAtIndex:popoverContent:)])
        {
            [btn setTitle:[_delegate textForBtnAtIndex:i popoverContent:self] forState:UIControlStateNormal];
            
            UIFont *hevleticaFont = [UIFont fontWithName:@"Helvetica" size:12];
            btn.titleLabel.font = hevleticaFont;
            [btn setTitleColor:_textColor forState:UIControlStateNormal];
            
            if (_style == PopoverContentStyleBreadcrumbs)
                btn.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
            else
                btn.titleLabel.adjustsFontSizeToFitWidth = true;
        }
            
        if ([_delegate respondsToSelector:@selector(clickedBtnAtIndex:popoverContent:)])
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            
        if ([_delegate respondsToSelector:@selector(imageForBtnAtIndex:popoverContent:)]) 
        {
            [btn setImage:[_delegate imageForBtnAtIndex:i popoverContent:self] forState:UIControlStateNormal];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
            
        [self.view addSubview:btn];
        [_btns addObject:btn];
            
        if (_dividerImage && _style == PopoverContentStyleHorizont)
        {
            dividerFrame.origin.x = btnFrame.origin.x + _btnSize.width;
            dividerFrame.origin.y = btnFrame.origin.y;
            dividerFrame.size.height = btnFrame.size.height;
                
            UIImageView *imgViewDivider = [[UIImageView alloc] initWithImage:_dividerImage];
            imgViewDivider.frame = dividerFrame;
            [self.view addSubview:imgViewDivider];
            [imgViewDivider release];
        }
    }
        
    self.view.frame = CGRectMake(0, 0, btnFrame.origin.x + _btnSize.width + dividerFrame.size.width, btnFrame.origin.y + _btnSize.height);
}

- (void) setEnabled:(bool)enabled forButtonAtIndex:(int)index
{
    if (index < 0 || index >= [_btns count])    return;
    UIButton * btn = [_btns objectAtIndex:index];
    [btn setEnabled:enabled];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self clean];
    
    [super viewDidUnload];
}

- (void) clean
{
    self.btnImage = nil;
    self.btnBackgroundImage = nil;
    self.btnBackgroundImagePush = nil;
    self.dividerImage = nil;
    
    [_btns release];
}

- (void) dealloc
{
    [self clean];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
