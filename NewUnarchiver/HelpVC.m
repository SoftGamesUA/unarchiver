//
//  HelpVC.m
//  NewUnarchiver
//
//  Created by Zhenya Koval on 13.12.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "HelpVC.h"
#import "AppDelegate.h"

#import "FileViewer.h"
#import "VideoViewer.h"

@interface HelpVC ()

@end

@implementation HelpVC

- (void) initTable
{
    CGRect frame = contentView.frame;
    frame.size.height += toolBarHeight;
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:frame];
    bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bg.image = [UIImage imageNamed:@"tableBg"];
    [self.view addSubview:bg];
    [bg release];
    
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    
    [self.view addSubview:_tableView];
}

- (void) customizeInterface
{
    self.navigationController.navigationBarHidden = true;
    
    UIImage * patternImage = [UIImage imageNamed:@"folderBorder"];
    [self setImageBorder:patternImage];
    
    [navBar setBackgroundImage:[UIImage imageNamed:@"navBarBG"]];
    [navBar setIconImage:[UIImage imageNamed:@"helpBtnFolder"]];
    [navBar setLabelTextColor:[UIColor colorWithPatternImage:patternImage]];
    [navBar setLabelText:NSLocalizedString(@"Help", nil)];
    [navBar setSubLabelText:NSLocalizedString(@"Help", nil)];
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

    [self initTable];
    [self customizeInterface];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) backButtonClick
{
    if ([self respondsToSelector:@selector(presentingViewController)])
    {
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [self.parentViewController dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        UIImage *image = [[UIImage imageNamed:@"cellBgHome"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        UIImageView *bg = [[UIImageView alloc] initWithImage:image];
        image = [[UIImage imageNamed:@"cellBgHomePush"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        UIImageView *bgSelected = [[UIImageView alloc] initWithImage:image];
        cell.backgroundView = bg;
        cell.selectedBackgroundView = bgSelected;
        [bg release];
        [bgSelected release];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
        
        cell.imageView.image = navBar.iconImage;
    }
    
    
    NSArray * titles = @[NSLocalizedString(@"What's new?", nil), NSLocalizedString(@"Tutorial", nil), NSLocalizedString(@"FAQ", nil),
    NSLocalizedString(@"Send us feedback", nil), NSLocalizedString(@"About us", nil), NSLocalizedString(@"Other Apps", nil)];
    
    cell.textLabel.text = [titles objectAtIndex:indexPath.section];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            FileViewer * vc = [[FileViewer alloc] init];
            NSString * name = NSLocalizedString(@"What's new?", nil);
            vc.URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"What's new?.pdf" ofType:nil]];
            vc.title = name;
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
            break;
        }
        case 1:
        {            
            VideoViewer * vc = [[VideoViewer alloc] init];
            vc.URLString = @"http://www.youtube.com/watch?v=fVxd9NHQTEU";
            vc.title = NSLocalizedString(@"Tutorial", nil);
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
            break;
        }
        case 2:
        {
            FileViewer * vc = [[FileViewer alloc] init];
            NSString * name = NSLocalizedString(@"FAQ", nil);
            vc.URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"pdf"]];
            vc.title = name;
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
            break;
        }
        case 4:
        {
            FileViewer * vc = [[FileViewer alloc] init];
            NSString * name = NSLocalizedString(@"About us", nil);
            vc.URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"pdf"]];
            vc.title = name;
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
            break;
        }
        default:
            break;
    }
}

@end
