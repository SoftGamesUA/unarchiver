//
//  HomeVC.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 03.03.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "config.h"

#import "HomeVC.h"
#import "FolderVC.h"

#ifdef DROPBOX_UNARCHIVER
    #import "DropboxVC.h"
#endif

#ifdef BOX_UNARCHIVER
    #import "BoxVC.h"
#endif

#ifdef CAMERA_UNARCHIVER
    #import "CameraVC.h"
#endif

#ifdef YANDEX_UNARCHIVER
    #import "YandexDiskVC.h"
#endif

#ifdef GOOGLE_UNARCHIVER
    #import "GoogleDriveVC.h"
#endif

#ifdef XFOLDER_UNARCHIVER
    #import "PTPasscodeViewController.h"
#endif

@implementation HomeVC

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

- (NSString *)getVersionNumber
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // example: 1.0.0
    NSNumber *buildNumber = [infoDict objectForKey:@"CFBundleVersion"]; // example: 42
    
    return [NSString stringWithFormat:@"%@ (%@)",appVersion,buildNumber];
}


- (void) customizeInterface
{
    UIImage * patternImage = [UIImage imageNamed:@"homeBorder"];
    [self setImageBorder:patternImage];
    
    [navBar setBackgroundImage:[UIImage imageNamed:@"navBarBG"]];
    [navBar setIconImage:[UIImage imageNamed:@"homeNavBarIcon"]];
    [navBar setViewModeButtonImage:[UIImage imageNamed:@"listBtnFolder"]];
    [navBar setSettingsButtonImage:[UIImage imageNamed:@"settingsBtnFolder"]];
    [navBar setLabelTextColor:[UIColor colorWithPatternImage:patternImage]];
    [navBar setLabelText:[NSString stringWithFormat:NSLocalizedString(@"UnArchiver %@",nil),[self getVersionNumber]]];
    [navBar setSubLabelText:NSLocalizedString(@"Home", nil)];
}

- (id)init
{
    self = [super initWithNavBarStyle:NavBarStyleHome toolbar:false];
    if (self) 
    {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = true;

    [self initTable];
    [self customizeInterface];
}

- (void)viewDidUnload
{
    [self clean];
    
    [super viewDidUnload];
}

- (void) clean
{
    [_tableView release];
}

- (void) dealloc
{
    [self clean];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Table Delegate & DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return HOME_SEC_0_ROW_COUNT;
    else if (section == 1) return HOME_SEC_1_ROW_COUNT;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    
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
    }
        
    UIImage *icon;
    
    if (indexPath.section == 0)
    {

#ifdef DOCUMENTS_UNARCHIVER

        if (indexPath.row == DOCUMENTS_UNARCHIVER)
        {
            cell.textLabel.text = NSLocalizedString(@"My Files", nil);
            icon = [UIImage imageNamed:@"folderNavBarIcon"];
        }
        
#endif
        
#ifdef XFOLDER_UNARCHIVER
        
        if (indexPath.row == XFOLDER_UNARCHIVER)
        {
            cell.textLabel.text = NSLocalizedString(@"XFolder", nil);
            icon = [UIImage imageNamed:@"folderNavBarIcon"];
        }

#endif
        
#ifdef INBOX_UNARCHIVER
        
        if (indexPath.row == INBOX_UNARCHIVER)
        {
            cell.textLabel.text = NSLocalizedString(@"Inbox", nil);
            icon = [UIImage imageNamed:@"folderNavBarIcon"];
        }

#endif
        
#ifdef DROPBOX_UNARCHIVER
        
        if (indexPath.row == DROPBOX_UNARCHIVER)
        {
            cell.textLabel.text = NSLocalizedString(@"Dropbox", nil);
            icon = [UIImage imageNamed:@"dropboxNavBarIcon"];
        }
        
#endif

#ifdef BOX_UNARCHIVER
        
        if (indexPath.row == BOX_UNARCHIVER)
        {
            cell.textLabel.text = NSLocalizedString(@"Box", nil);
            icon = [UIImage imageNamed:@"boxnetNavBarIcon"];
        }
#endif

#ifdef YANDEX_UNARCHIVER
        
        if (indexPath.row == YANDEX_UNARCHIVER)
        {
            cell.textLabel.text = NSLocalizedString(@"Yandex Disk", nil);
            icon = [UIImage imageNamed:@"yandexNavBarIcon"];
        }
        
#endif
        
#ifdef GOOGLE_UNARCHIVER
        
        if (indexPath.row == GOOGLE_UNARCHIVER)
        {
            cell.textLabel.text = NSLocalizedString(@"Google Drive", nil);
            icon = [UIImage imageNamed:@"googleNavBarIcon"];
        }
        
#endif
        
    }
    else if (indexPath.section == 1)
    {

#ifdef CAMERA_UNARCHIVER
        
        if (indexPath.row == CAMERA_UNARCHIVER) 
        {
            cell.textLabel.text = NSLocalizedString(@"Camera Roll", nil);
            icon = [UIImage imageNamed:@"cameraNavBarIcon"];
        }

#endif
    
    }
    
    cell.imageView.image = icon;
    
    UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"folderAccessoryBtn"]];
    cell.accessoryView = accessoryView;
    [accessoryView release];
    
    return cell;	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (indexPath.section == 0)
    {
        
#ifdef DOCUMENTS_UNARCHIVER
        
        if (indexPath.row == DOCUMENTS_UNARCHIVER)
        {
            FolderVC *vc = [[FolderVC alloc] init];
            vc.isMaster = self.isMaster;
            vc.rootFolder = appDelegate.documents;
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
        }

#endif

#ifdef XFOLDER_UNARCHIVER

        if (indexPath.row == XFOLDER_UNARCHIVER)
        {
            if ([self isDropboxPurchased])
            {
                PTPasscodeViewController * vc = [[PTPasscodeViewController alloc] initWithDelegate:self];
                vc.modalPresentationStyle = UIModalPresentationFormSheet;
                [appDelegate.window.rootViewController presentModalViewController:vc animated:YES];
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    vc.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                    CGRect frame = vc.view.superview.frame;
                    frame.size = CGSizeMake(kPasscodePanelWidth, kPasscodePanelHeight);
                    vc.view.superview.frame = frame;
                    vc.view.superview.center = CGPointMake(appDelegate.splitVC.view.bounds.size.width / 2, vc.view.superview.center.y);
                }
                [vc release];
            }
            else
            {
                [self.purchaseDropboxModalView show];
            }
        }
        
#endif
        
#ifdef INBOX_UNARCHIVER
        
        if (indexPath.row == INBOX_UNARCHIVER)
        {
            FolderVC *vc = [[FolderVC alloc] init];
            vc.isMaster = self.isMaster;
            vc.rootFolder = appDelegate.inbox;
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
        }
        
#endif
        
#ifdef DROPBOX_UNARCHIVER
        
        if (indexPath.row == DROPBOX_UNARCHIVER)
        {
            if ([self isDropboxPurchased])
            {
                DropboxVC *vc = [[DropboxVC alloc] init];
                vc.isMaster = self.isMaster;
                vc.rootFolder = [FileObject folderWithPath:@"/"];
                vc.rootFolder.displayName = @"Dropbox";
                [self.navigationController pushViewController:vc animated:true];
                [vc release];
            }
            else
            {
                [self.purchaseDropboxModalView show];
            }
        }
        
#endif
        
#ifdef BOX_UNARCHIVER
        
        if (indexPath.row == BOX_UNARCHIVER)
        {if ([self isDropboxPurchased])
        {
            BoxVC *vc = [[BoxVC alloc] init];
            vc.isMaster = self.isMaster;
            vc.rootFolder = [FileObject folderWithID:@"0" displayName:@"Box"];
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
        }
        else
        {
            [self.purchaseDropboxModalView show];
        }
        }
        
#endif
        
#ifdef YANDEX_UNARCHIVER
        
        if (indexPath.row == YANDEX_UNARCHIVER)
        {if ([self isDropboxPurchased])
        {
            YandexDiskVC *vc = [[YandexDiskVC alloc] init];
            vc.isMaster = self.isMaster;
            vc.rootFolder = [FileObject folderWithPath:@"/"];
            vc.rootFolder.displayName = NSLocalizedString(@"Yandex", nil);
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
        }
        else
        {
            [self.purchaseDropboxModalView show];
        }
        }
        
#endif
        
#ifdef GOOGLE_UNARCHIVER
        
        if (indexPath.row == GOOGLE_UNARCHIVER)
        {
            if ([self isDropboxPurchased])
            {
                GoogleDriveVC *vc = [[GoogleDriveVC alloc] init];
                vc.isMaster = self.isMaster;
                vc.rootFolder = [FileObject folderWithID:@"root" displayName:@"Google"];
                [self.navigationController pushViewController:vc animated:true];
                [vc release];
            }
            else
            {
                [self.purchaseDropboxModalView show];
            }
        }
        
#endif
        
    }
    else if (indexPath.section == 1)
    {
        
#ifdef CAMERA_UNARCHIVER
        
        if (indexPath.row == CAMERA_UNARCHIVER)
        {
            CameraVC *vc = [[CameraVC alloc] init];
            vc.isMaster = self.isMaster;
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
        }
        
#endif
        
    }
}

#pragma mark - PTPasscodeViewControllerDelegate

#ifdef XFOLDER_UNARCHIVER

- (void)didShowPasscodePanel:(PTPasscodeViewController *)passcodeViewController panelView:(UIView*)panelView
{
    [passcodeViewController setTitle:@"Set Passcode"];
    
    if([panelView tag] == kPasscodePanelOne) {
        [[passcodeViewController titleLabel] setText:@"Enter a passcode"];
    }
    
    if([panelView tag] == kPasscodePanelTwo) {
        [[passcodeViewController titleLabel] setText:@"Re-enter your passcode"];
    }
}

- (BOOL)shouldChangePasscode:(PTPasscodeViewController *)passcodeViewController panelView:(UIView*)panelView passCode:(NSUInteger)passCode lastNumber:(NSInteger)lastNumber;
{
    // Clear summary text
    [[passcodeViewController summaryLabel] setText:@""];
    
    return TRUE;
}

- (BOOL)didEndPasscodeEditing:(PTPasscodeViewController *)passcodeViewController panelView:(UIView*)panelView passCode:(NSUInteger)passCode
{
    NSNumber * savedPassValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"XFolder pass"];
    int savedPass = [savedPassValue intValue];
    
    if([panelView tag] == kPasscodePanelOne)
    {
        if (savedPassValue == nil)
        {
            xFolderPassword = passCode;
            [passcodeViewController nextPanel];
        }
        else if (savedPass == passCode)
        {
            [appDelegate.window.rootViewController dismissModalViewControllerAnimated:false];
            [self goToXFolder];
        }
        else
        {
            [passcodeViewController clearPanel];
            [[passcodeViewController summaryLabel] setText:@"Passcode did not match. Try again."];
        }
    }
    
    if([panelView tag] == kPasscodePanelTwo)
    {
        if(passCode != xFolderPassword)
        {
            [passcodeViewController prevPanel];
            [[passcodeViewController summaryLabel] setText:@"Passcode did not match. Try again."];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:passCode] forKey:@"XFolder pass"];
            
            [appDelegate.window.rootViewController dismissModalViewControllerAnimated:false];
            [self goToXFolder];
        }
        
    }
    
    return FALSE;
}

- (void)didCancel:(PTPasscodeViewController *)passcodeViewController
{
    [appDelegate.window.rootViewController dismissModalViewControllerAnimated:true];
}

- (void) goToXFolder
{
    FolderVC *vc = [[FolderVC alloc] init];
    vc.isMaster = self.isMaster;
    vc.rootFolder = appDelegate.xFolder;
    [self.navigationController pushViewController:vc animated:true];
    [vc release];
}

#endif

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
