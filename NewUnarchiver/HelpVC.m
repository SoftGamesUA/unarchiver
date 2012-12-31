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

#import "PopoverBgViewToolbarDark.h"

@interface HelpVC ()

@property (nonatomic, retain) UIPopoverController * popoverControllerFeedback;
@property (nonatomic, retain) UIActionSheet * actionSheetFeedback;

@end

@implementation HelpVC

- (void) like
{
    //NSString * URL;
    //[[UIApplication sharedApplication] openURL: URL];
}

- (void) otherApps
{
    NSString * URL = @"https://itunes.apple.com/artist/softgames/id371925181";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
}

#pragma mark - init

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

- (void) clickedNavBarIcon:(CGRect)iconFrame
{
    [self backButtonClick];
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
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
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
        case 3:
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                CGRect frame = [_tableView rectForRowAtIndexPath:indexPath];
                frame.origin.y += frame.size.height / 2;
                [self.popoverControllerFeedback presentPopoverFromRect:frame inView:_tableView permittedArrowDirections:UIPopoverArrowDirectionDown animated:true];
            }
            else
            {
                [self.actionSheetFeedback showInView:self.view];  
            }
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
        case 5:
        {
            [self otherApps];
        }
            
        default:
            break;
    }
}

#pragma mark - popover

- (UIPopoverController *)popoverControllerFeedback
{
    if (!_popoverControllerFeedback)
    {
        _popoverContentFeedback = [[PopoverContent alloc] initWithStyle:PopoverContentStyleVertical];
        _popoverContentFeedback.delegate = self;
        [_popoverContentFeedback setBtnSize:CGSizeMake(150, 50)];
        [_popoverContentFeedback setBtnBackgroundImage:[UIImage imageNamed:@"NavBarPopoverBtn"]];
        [_popoverContentFeedback setBtnBackgroundImagePush:[UIImage imageNamed:@"NavBarPopoverBtnPush"]];
        [_popoverContentFeedback setTextColor:[UIColor whiteColor]];
        
        _popoverControllerFeedback = [[UIPopoverController alloc] initWithContentViewController:_popoverContentFeedback];
        _popoverControllerFeedback.popoverBackgroundViewClass = [PopoverBgViewToolbarDark class];
    }
    
    int btnCount = 1;
    
    if ([MFMailComposeViewController canSendMail]) btnCount += 2;
    
    [_popoverContentFeedback setBtnCount:btnCount];
    [_popoverContentFeedback setup];
    [_popoverControllerFeedback setPopoverContentSize:_popoverContentFeedback.view.frame.size animated:YES];
    return _popoverControllerFeedback;
}

- (NSString *) textForBtnAtIndex:(int)index popoverContent:(PopoverContent *)popoverContent
{
    if (popoverContent.btnCount == 1)
    {
        return NSLocalizedString(@"I like CloudFiles", nil);
    }
    else
    {
        if (index == 0)
        {
            return NSLocalizedString(@"Report a problem", nil);
        }
        else if (index == 1)
        {
            return NSLocalizedString(@"Suggest a feature", nil);
        }
        else if (index == 2)
        {
            return NSLocalizedString(@"I like CloudFiles", nil);
        }
    }
    
    return nil;
}

- (void) clickedBtnAtIndex:(int)index popoverContent:(PopoverContent *)popoverContent
{
    if (popoverContent.btnCount == 1)
    {
        [self like];
    }
    else
    {
        if (index == 0)
        {
            [self sendMailWithTitle:NSLocalizedString(@"Report a problem", nil)];
        }
        else if (index == 1)
        {
            [self sendMailWithTitle:NSLocalizedString(@"Suggest a feature", nil)];
        }
        else if (index == 2)
        {
            [self like];
        }
    }

    [_popoverControllerFeedback dismissPopoverAnimated:true];
}

#pragma mark - action sheet

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.numberOfButtons == 1)
    {
        [self like];
    }
    else
    {
        if (buttonIndex == 0)
        {
            [self sendMailWithTitle:NSLocalizedString(@"Report a problem", nil)];
        }
        else if (buttonIndex == 1)
        {
            [self sendMailWithTitle:NSLocalizedString(@"Suggest a feature", nil)];
        }
        else if (buttonIndex == 2)
        {
            [self like];
        }
    }

}


- (UIActionSheet *) actionSheetFeedback
{
    [_actionSheetFeedback release];
    
    _actionSheetFeedback = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil
                                      destructiveButtonTitle:nil otherButtonTitles:nil];
    _actionSheetFeedback.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    if ([MFMailComposeViewController canSendMail])
    {
        [_actionSheetFeedback addButtonWithTitle:NSLocalizedString(@"Report a problem", nil)];
        [_actionSheetFeedback addButtonWithTitle:NSLocalizedString(@"Suggest a feature", nil)];
    }
    
    [_actionSheetFeedback addButtonWithTitle:NSLocalizedString(@"I like Unarchiver", nil)];
    [_actionSheetFeedback addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    
    _actionSheetFeedback.cancelButtonIndex = _actionSheetFeedback.numberOfButtons - 1;
    
    return _actionSheetFeedback;
}

#pragma mark - mail

-(void)sendMailWithTitle:(NSString *) title
{
    if (![MFMailComposeViewController canSendMail])
    {
        return;
    }
    
    MFMailComposeViewController * mailViewController = [[MFMailComposeViewController alloc] init];
    [mailViewController setSubject:title];
    [mailViewController setToRecipients:@[@"mail@softgames.biz"]];
    mailViewController.mailComposeDelegate = self;
    
    [self presentModalViewController:mailViewController animated:YES];
    [mailViewController release];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
