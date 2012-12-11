//
//  ModalView.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 01.03.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "ModalView.h"

#import "AppDelegate.h"

@implementation UITextField(UITextFieldCatagory)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width - 10, bounds.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width - 10, bounds.size.height);
    return inset;
}

#pragma clang diagnostic pop

@end

@implementation ModalView

@synthesize contentView = _contentView;
@synthesize titleLabel = _titleLabel;
@synthesize delegate = _delegate;
@synthesize textFieldDefaultValue = _textFieldDefaultValue;
@synthesize textField = _textField;
@synthesize textView = _textView;
@synthesize isShow = _isShow;
@synthesize style = _style;
@synthesize btnCount = _btnCount;
@synthesize userInfo = _userInfo;

- (id) initWithStyle:(ModalViewStyle)style btnTitles:(NSString *)btnTitles, ...
{
    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)   _superView = [appDelegate.splitVC.view retain];
    else    _superView = [appDelegate.masterNC.view retain];
    
    self = [super initWithFrame:_superView.bounds];
    if (self) 
    {        
        _btns = [[NSMutableArray alloc] init];
        _style = style;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = _superView.bounds;
        btn.autoresizingMask = self.autoresizingMask;
        [btn setBackgroundImage:[UIImage imageNamed:@"alertBg"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        _contentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alertContentFolder"]];
        _contentView.userInteractionEnabled = true;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |   UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        _contentViewFrame = _contentView.frame;
        
        int horizontBorderSpace;
        int verticalBorderSpace;
        UIFont * titleFont, * messageFont;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            horizontBorderSpace = _contentViewFrame.size.width / 10;
            verticalBorderSpace = _contentViewFrame.size.height / 6;
            
            titleFont = [UIFont fontWithName:@"Helvetica" size:20];
            messageFont = [UIFont fontWithName:@"Helvetica" size:16];
        }
        else 
        {
            horizontBorderSpace = _contentViewFrame.size.width / 20;
            verticalBorderSpace = _contentViewFrame.size.height / 12;
            
            titleFont = [UIFont fontWithName:@"Helvetica" size:14];
            messageFont = [UIFont fontWithName:@"Helvetica" size:12];
            
            _contentViewFrame.size.width = _contentViewFrame.size.width / 2;
            _contentViewFrame.size.height = _contentViewFrame.size.height / 2;
        }
        
        _contentViewFrame.origin.x = _superView.bounds.size.width / 2 - _contentViewFrame.size.width / 2;
        _contentViewFrame.origin.y = _superView.bounds.size.height / 2 - _contentViewFrame.size.height;
        _contentView.frame = _contentViewFrame;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _contentViewFrame.size.width, _contentViewFrame.size.height / 3)];
        _titleLabel.font = titleFont;
        _titleLabel.adjustsFontSizeToFitWidth = true;
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_titleLabel];
        
        if (style == ModalViewStyleTextField)
        {
            CGRect textFieldFrame;
            textFieldFrame.origin = CGPointMake(horizontBorderSpace, _contentViewFrame.size.height / 3);
            textFieldFrame.size = CGSizeMake(_contentViewFrame.size.width - horizontBorderSpace * 2, _contentViewFrame.size.height / 4);
            _textField = [[UITextField alloc] initWithFrame:textFieldFrame];
            [_textField setBackground:[UIImage imageNamed:@"textbox"]];
            _textField.font = messageFont;
            _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            [_contentView addSubview:_textField];
        }
        else if (style == ModalViewStyleTextView) 
        {
            CGRect textViewFrame;
            textViewFrame.size = CGSizeMake(_contentViewFrame.size.width - horizontBorderSpace * 2, _contentViewFrame.size.height / 3);
            textViewFrame.origin = CGPointMake(horizontBorderSpace, _contentViewFrame.size.height / 3.5);
            _textView = [[UITextView alloc] initWithFrame:textViewFrame];
            _textView.editable = false;
            _textView.font = messageFont;
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:_textView.bounds];
            imgView.image = [UIImage imageNamed:@"textbox"];
            [_textView addSubview: imgView];
            [_textView sendSubviewToBack: imgView];
            [imgView release];
            [_contentView addSubview:_textView];
        }
        else if (style == ModalViewStyleMessage)
        {
            CGRect labelFrame;
            labelFrame.size = CGSizeMake(_contentViewFrame.size.width - horizontBorderSpace * 2, _contentViewFrame.size.height / 2);
            labelFrame.origin = CGPointMake(horizontBorderSpace, _contentViewFrame.size.height / 4);
            
            _messageLabel = [[UILabel alloc] initWithFrame:labelFrame];
            _messageLabel.textAlignment = UITextAlignmentCenter;
            _messageLabel.backgroundColor = [UIColor clearColor];
            _messageLabel.lineBreakMode = UILineBreakModeWordWrap;
            _messageLabel.numberOfLines = 3;
            _messageLabel.font = messageFont;
            [_contentView addSubview:_messageLabel];
        }
        
        NSMutableArray * titlesArray = [NSMutableArray array];
        if (btnTitles)
        {
            [titlesArray addObject:btnTitles];
            
            va_list args;
            va_start(args, btnTitles);
        
            NSString * title = va_arg(args, NSString *);
            while(title)
            {
                [titlesArray addObject:title];
                title = va_arg(args, NSString *);
            }
            
             va_end(args);
        }
        _btnCount = [titlesArray count];
        
        int btnSpace = 3;
        CGRect btnFrame;
        btnFrame.size = CGSizeMake(_contentViewFrame.size.width / 4 - btnSpace * 2, _contentViewFrame.size.height / 6);
        btnFrame.origin = CGPointMake(0, _contentViewFrame.size.height - btnFrame.size.height - verticalBorderSpace);
        
        for (int i = 0; i < _btnCount; i++)
        {
            btnFrame.origin.x = (_contentViewFrame.size.width / (_btnCount + 1))  * (i + 1);
            btnFrame.origin.x -= btnFrame.size.width / 2 + btnSpace;
            
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = btnFrame;
            btn.titleLabel.font = messageFont;
            btn.titleLabel.adjustsFontSizeToFitWidth = true;
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitle:[titlesArray objectAtIndex:i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setBackgroundImage:[[UIImage imageNamed:@"whiteBtn"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                           forState:UIControlStateNormal];
            [btn setBackgroundImage:[[UIImage imageNamed:@"whiteBtnPush"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                           forState:UIControlStateHighlighted];
            [_contentView addSubview:btn];
            
            btn.tag = i;
            [_btns addObject:btn];
        }
                
        [self addSubview:_contentView];
    }
    return self;
}

- (void) show
{
    self.frame = _superView.bounds;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) 
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
       
    if (_style == ModalViewStyleTextField) 
    {
        _textField.text = _textFieldDefaultValue;
        [_textField sendActionsForControlEvents:UIControlEventEditingChanged];
        [_textField becomeFirstResponder];
    }
    
    _isShow = true;
    [_superView addSubview:self];
}

- (void) hide
{
    _isShow = false;
    [self removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) cancel
{
    [self hide];
    if ([_delegate respondsToSelector:@selector(didCancelModalView:)])
    {
        [_delegate didCancelModalView:self];
    }
}

- (void) setEnabled:(bool)enabled forBtnAtIndex:(int)index
{
    if (index < 0 || index >= [_btns count]) return;
    
    UIButton *btn = [_btns objectAtIndex:index];
    btn.enabled = enabled;
}
    
- (void)btnClick:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(modalView:clickedBtnAtIndex:)])
    {
        [_delegate modalView:self clickedBtnAtIndex:sender.tag];
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification 
{
	[_superView bringSubviewToFront:self];
}

#pragma mark -
#pragma keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
    float duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    _contentViewFrame = _contentView.frame;
    CGRect _newContentViewFrame = _contentViewFrame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIDeviceOrientationIsPortrait(orientation) ) _newContentViewFrame.origin.y /= 2;
        else    _newContentViewFrame.origin.y = 20;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    
    _contentView.frame = _newContentViewFrame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    float duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    
    _contentView.frame = _contentViewFrame;
    
    [UIView commitAnimations];
}

#pragma mark -

- (void) dealloc
{
    [_titleLabel release];
    [_contentView release];
    [_superView release];
    [_textView release];
    [_textField release];
    [_btns release];
    [_userInfo release];
    [_messageLabel release];
    [super dealloc];
}

@end
