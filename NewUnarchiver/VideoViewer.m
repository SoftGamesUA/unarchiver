//
//  VideoViewer.m
//  NewUnarchiver
//
//  Created by Zhenya Koval on 13.12.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "VideoViewer.h"

@interface VideoViewer ()

@end

@implementation VideoViewer

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
    
    
    NSString *embedHTML = @"<html><head></head>\
    <body style=\"margin:0\">\
    <embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
    width=\"%0.0f\" height=\"%0.0f\"></embed>\
    </body></html>";
    NSString * html = [NSString stringWithFormat:embedHTML, _URLString, 250.0, 250.0];
    
    videoView = [[UIWebView alloc] init];
    videoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [videoView loadHTMLString:html baseURL:nil];
    [self.view addSubview:videoView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    videoView.frame = CGRectMake(self.view.frame.size.width / 2 - 125, self.view.frame.size.height / 2 - 125, 250, 250);
}

- (void) dealloc
{
    [super dealloc];
    
    [_URLString release];
    [videoView release];
}

- (void) backButtonClick
{
    [self.navigationController popViewControllerAnimated:true];
}

@end
