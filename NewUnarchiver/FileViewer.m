//
//  FileViewerr.m
//  NewUnarchiver
//
//  Created by Zhenya Koval on 13.12.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "FileViewer.h"

@interface FileViewer ()

@end

@implementation FileViewer

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
	return 1;
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)previewController previewItemAtIndex:(NSInteger)index
{
    return _URL;
}

- (void) customizeInterface
{
    self.navigationController.navigationBarHidden = true;
    
    UIImage * patternImage = [UIImage imageNamed:@"folderBorder"];
    [self setImageBorder:patternImage];
    
    [navBar setBackgroundImage:[UIImage imageNamed:@"navBarBG"]];
    [navBar setIconImage:[UIImage imageNamed:@"helpBtnFolder"]];
    [navBar setLabelTextColor:[UIColor colorWithPatternImage:patternImage]];
    [navBar setLabelText:self.title];
    [navBar setSubLabelText:[NSString stringWithFormat:@"%@/%@", NSLocalizedString(@"Help", nil), self.title]];
    [navBar setBackButtonImage:[UIImage imageNamed:@"backBtnFolder"]];
}

- (id)init
{
    self = [super initWithNavBarStyle:NavBarStyleFolder toolbar:false];
    if (self)
    {
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self customizeInterface];
    
    QLPreviewController * previewer = [[QLPreviewController alloc] init];
    [self addChildViewController:previewer];
    [previewer setDataSource:self];
    [previewer setCurrentPreviewItemIndex:0];
    CGRect frame = contentView.frame;
    frame.size.height += toolBarHeight;
    previewer.view.frame = frame;
    [self.view addSubview:previewer.view];
    [previewer release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) dealloc
{
    self.URL = nil;
    
    [super dealloc];
}

- (void) backButtonClick
{
    [self.navigationController popViewControllerAnimated:true];
}

@end
