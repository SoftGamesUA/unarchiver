//
//  HomeVC.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 03.03.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "PreviewVC.h"

@interface PreviewVC ()
- (void) previewFile:(NSString *)filePath;
@end

@implementation PreviewVC

#pragma mark -

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller 
{
	return 1;
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)previewController previewItemAtIndex:(NSInteger)index 
{
    return _fileToPreview;
}

- (void) previewFile:(NSString *)filePath
{
    [_fileToPreview release];
    _fileToPreview = [[NSURL alloc] initFileURLWithPath:filePath];
    
    [_previewer release];
    _previewer = nil;
    
    _previewer = [[QLPreviewController alloc] init];
    [_previewer setDataSource:self];
    [_previewer setCurrentPreviewItemIndex:0];
    CGRect frame = self.view.bounds;
    frame.origin.y = navBar.frame.origin.y + navBar.frame.size.height;
    frame.size.height = frame.size.height - frame.origin.y - borderHeight;
    _previewer.view.frame = frame;
    [self.view addSubview:_previewer.view];

}

- (void)fileDidSelect:(NSNotification *)notification
{
    FileObject * file = [notification.userInfo objectForKey:FILE_KEY];
    [self previewFile:file.path];
}


#pragma mark -
#pragma mark init

- (id)init
{
    self = [super initWithNavBarStyle:NavBarStyleSimple toolbar:false];
    if (self) 
    {
        
    }
    return self;
}

- (void) customizeInterface
{   
    UIImage * patternImage = [UIImage imageNamed:@"folderBorder"];
    [self setImageBorder:patternImage];
    
    [navBar setBackgroundImage:[UIImage imageNamed:@"navBarBG"]];
    [navBar setIconImage:[UIImage imageNamed:@"previewModeIcon"]];
    [navBar setViewModeButtonImage:[UIImage imageNamed:@"listBtnFolder"]];
    [navBar setLabelTextColor:[UIColor colorWithPatternImage:patternImage]];
    [navBar setLabelText:NSLocalizedString(@"Preview", nil)];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [super viewDidLoad];
        [self customizeInterface];
    }
    
    self.navigationController.navigationBarHidden = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDidSelect:) name:PREVIEW_FILE_NOTIFICATION object:nil];
}

- (void)viewDidUnload
{
    [self clean];
    [super viewDidUnload];
}

- (void) dealloc
{
    [self clean];
    [super dealloc];
}

- (void) clean
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_fileToPreview release];
    [_previewer release];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
