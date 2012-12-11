//
//  BasicVC.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 16.07.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "BasicVC.h"

#import "AppDelegate.h"
#import "ClipboardManager.h"

#import "PreviewVC.h"

@interface BasicVC ()

@end

@implementation BasicVC

@synthesize isMaster = _isMaster;

- (void) setImageBorder:(UIImage *)img
{
    imgViewTop.image = img;
    imgViewBottom.image = img;
}

- (void) initBorders
{
    imgViewTop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, borderHeight)];
    imgViewTop.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:imgViewTop];
    
    imgViewBottom = [[UIImageView alloc] initWithFrame:
                      CGRectMake(0, self.view.frame.size.height - borderHeight, self.view.frame.size.width, borderHeight)];
    imgViewBottom.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;;
    [self.view addSubview:imgViewBottom];
}

- (void) initNavBar:(NavBarStyle)navBarStyle
{
    CGRect navBarFrame = CGRectZero;
    navBarFrame.origin.y = borderHeight;
    navBarFrame.origin.x = 0;
    navBarFrame.size.height = navBarHeight;
    navBarFrame.size.width = self.view.frame.size.width;
    navBar = [[NavBar alloc] initWithFrame:navBarFrame style:navBarStyle];
    navBar.delegate = self;
    if (_isMaster)
    {
        [navBar setCustomButtonType:NavBarCustomButtonTypeSettings];
    }
    else
    {
        [navBar setCustomButtonType:NavBarCustomButtonTypeViewMode];
    }
    [self.view addSubview:navBar];
}

- (void) initToolBar
{
    CGRect toolBarFrame = navBar.frame;
    toolBarFrame.size.height = toolBarHeight;
    toolBarFrame.origin.y = self.view.frame.size.height - borderHeight - toolBarHeight;
    
    toolBar = [[ToolBar alloc] initWithFrame:toolBarFrame];
    toolBar.delegate = self;
    [self.view addSubview:toolBar];
}

- (id) initWithNavBarStyle:(NavBarStyle)navBarStyle toolbar:(bool)toolbar
{
    self = [super init];
    if (self) 
    {
        _needToolbar = toolbar;
        _navBarStyle = navBarStyle;
        
        isPreviewShownOnPhone = false;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
       
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self initBorders];    
    [self initNavBar:_navBarStyle];
    
    if(_needToolbar)
    {
        [self initToolBar];
    }

    CGRect contentFrame;
    contentFrame.origin = CGPointMake(0, navBar.frame.origin.y + navBarHeight);
    contentFrame.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - navBarHeight - toolBarHeight - borderHeight * 2);
    contentView = [[UIView alloc] initWithFrame:contentFrame];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:contentView];
}

- (void) viewDidUnload
{
    [self cleanBasicVC];
    
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [toolBar sizeToFit];
}

- (void) cleanBasicVC
{   
    [imgViewTop release];
    [imgViewBottom release];
    [toolBar release];
    [navBar release];
    
    [contentView release];
    [_previewOnPhone release];
}

- (void) dealloc
{
    [self cleanBasicVC];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Preview on Phone

- (bool) canPreviewFile
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return (appDelegate.detailViewMode == DetailViewModePreview && !appDelegate.splitVC.isDetailHidden);
    }

return _previewOnPhone != nil;
}

- (void) previewButtonClick
{
    if (_previewOnPhone)
    {
        [self disablePreviewOnPhone];
    }
    else
    {
        [self enablePreviewOnPhone];
    }
}

- (void) enablePreviewOnPhone
{
    int move = 40;
    isPreviewShownOnPhone = false;
    
    CGRect viewFrame = contentView.frame;
    viewFrame.origin.x = self.view.frame.size.width;
    viewFrame.size.height += toolBarHeight;
    _previewOnPhone = [[PreviewVC alloc] init];
    _previewOnPhone.view.frame = viewFrame;
    [self.view addSubview:_previewOnPhone.view];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    
    viewFrame = contentView.frame;
    viewFrame.origin.x -= move;
    viewFrame.size.height += toolBarHeight;
    contentView.frame = viewFrame;
    
    viewFrame = _previewOnPhone.view.frame;
    viewFrame.origin.x -= move;
    _previewOnPhone.view.frame = viewFrame;
    
    viewFrame = toolBar.frame;
    viewFrame.origin.y = self.view.frame.size.height;
    toolBar.frame = viewFrame;
    
    [UIView commitAnimations];
}

- (void) disablePreviewOnPhone
{
    isPreviewShownOnPhone = false;
    int move = contentView.frame.origin.x;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDidStopSelector:@selector(disablePreviewOnPhoneFinish)];
    [UIView setAnimationDelegate:self];
    
    CGRect viewFrame = contentView.frame;
    viewFrame.origin.x -= move;
    viewFrame.size.height -= toolBarHeight;
    contentView.frame = viewFrame;
    
    viewFrame = toolBar.frame;
    viewFrame.origin.y = contentView.frame.origin.y + contentView.frame.size.height;
    toolBar.frame = viewFrame;
    
    viewFrame = _previewOnPhone.view.frame;
    viewFrame.origin.x = self.view.frame.size.width;
    _previewOnPhone.view.frame = viewFrame;
    
    [UIView commitAnimations];
}

- (void) disablePreviewOnPhoneFinish
{
    [_previewOnPhone.view removeFromSuperview];
    [_previewOnPhone release];
    _previewOnPhone = nil;
}

- (void) showPreviewOnPhone
{
    isPreviewShownOnPhone = true;
    int move = _previewOnPhone.view.frame.origin.x;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    
    CGRect viewFrame = contentView.frame;
    viewFrame.origin.x -= move;
     contentView.frame = viewFrame;
    
    viewFrame = _previewOnPhone.view.frame;
    viewFrame.origin.x -= move;
    _previewOnPhone.view.frame = viewFrame;
    
    
    [UIView commitAnimations];
}

- (void) hidePreviewOnPhone
{
    isPreviewShownOnPhone = false;
    int move = contentView.frame.origin.x + 40;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    
    CGRect viewFrame = contentView.frame;
    viewFrame.origin.x -= move;
    contentView.frame = viewFrame;
    
    viewFrame = _previewOnPhone.view.frame;
    viewFrame.origin.x = self.view.frame.size.width - 40;
    _previewOnPhone.view.frame = viewFrame;
    
    [UIView commitAnimations];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (_previewOnPhone && !isPreviewShownOnPhone)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        
        CGRect viewFrame = _previewOnPhone.view.frame;
        viewFrame.origin.x = self.view.frame.size.width - toolBar.frame.size.width;
        _previewOnPhone.view.frame = viewFrame;
        
        [UIView commitAnimations];
    }
    
    [toolBar sizeToFit];
}

@end
