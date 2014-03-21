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

//#define IDpaymant @"unarchiverdropbox"

@interface HomeVC()
@property (nonatomic, retain) ModalView * purchaseDropboxModalView;
@end

@implementation HomeVC

@synthesize purchaseDropboxModalView = _purchaseDropboxModalView;

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
    UIImage * patternImage = [UIImage imageNamed:@"homeBorder"];
    [self setImageBorder:patternImage];
    
    [navBar setBackgroundImage:[UIImage imageNamed:@"navBarBG"]];
    [navBar setIconImage:[UIImage imageNamed:@"homeNavBarIcon"]];
    [navBar setViewModeButtonImage:[UIImage imageNamed:@"listBtnFolder"]];
    [navBar setSettingsButtonImage:[UIImage imageNamed:@"settingsBtnFolder"]];
    [navBar setLabelTextColor:[UIColor colorWithPatternImage:patternImage]];
    [navBar setLabelText:[NSString stringWithFormat:NSLocalizedString(@"UnArchiver %@",nil),@"(3.0)"]];
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
    
    //[[StoreKitBindingiOS sharedManager] setDelegate:self];
    //[[StoreKitBindingiOS sharedManager] requestProductData:IDpaymant];
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
            //if ([self isDropboxPurchased])
            {
                DropboxVC *vc = [[DropboxVC alloc] init];
                vc.isMaster = self.isMaster;
                vc.rootFolder = [FileObject folderWithPath:@"/"];
                vc.rootFolder.displayName = @"Dropbox";
                [self.navigationController pushViewController:vc animated:true];
                [vc release];
            }
            //else
            {
                //[self.purchaseDropboxModalView show];
            }
        }

#endif

#ifdef BOX_UNARCHIVER
    
        if (indexPath.row == BOX_UNARCHIVER)
        {
            BoxVC *vc = [[BoxVC alloc] init];
            vc.isMaster = self.isMaster;
            vc.rootFolder = [FileObject folderWithID:@"0" displayName:@"Box"];
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
        }

#endif

#ifdef YANDEX_UNARCHIVER
    
        if (indexPath.row == YANDEX_UNARCHIVER)
        {
            YandexDiskVC *vc = [[YandexDiskVC alloc] init];
            vc.isMaster = self.isMaster;
            vc.rootFolder = [FileObject folderWithPath:@"/"];
            vc.rootFolder.displayName = NSLocalizedString(@"Yandex", nil);
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
        }

#endif

#ifdef GOOGLE_UNARCHIVER
    
        if (indexPath.row == GOOGLE_UNARCHIVER)
        {
            GoogleDriveVC *vc = [[GoogleDriveVC alloc] init];
            vc.isMaster = self.isMaster;
            vc.rootFolder = [FileObject folderWithID:@"root" displayName:@"Google"];
              [self.navigationController pushViewController:vc animated:true];
            [vc release];
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

/*#pragma mark - Store Kit

- (bool) isDropboxPurchased
{
    NSString * db = [[NSUserDefaults standardUserDefaults] objectForKey:@"dropbox"];
    return db != nil;
}

- (void) purchaseDropbox
{
    [[NSUserDefaults standardUserDefaults] setObject:@"SPASIBO ZHITELAM DONBASSA!!!" forKey:@"dropbox"];
}

-(void)storeKit:(StoreKitBindingiOS*)_storeKit getProducts:(NSString*)products
{
    if ([products isEqualToString:@""]) [_appDelegate hideProgressHUD];
}

-(void)storeKit:(StoreKitBindingiOS*)_storeKit productPurchased:(NSString*)product
{
    [_appDelegate hideProgressHUD];
    
    [self purchaseDropbox];
    [self tableView:_tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:DropboxRow inSection:0]];
}

-(void)storeKit:(StoreKitBindingiOS*)_storeKit productCanceled:(NSString*)product
{
    [_appDelegate hideProgressHUD];
}

-(void)storeKit:(StoreKitBindingiOS*)_storeKit failWithError:(NSError*)error
{
    [_appDelegate hideProgressHUD];
}

- (void) btnRestoreClick
{
    [_appDelegate showProgressHUDWithText:NSLocalizedString(@"Loading", nil)];
    
    [self.purchaseDropboxModalView hide];
    [[StoreKitBindingiOS sharedManager] restoreCompletedTransactions];
}

- (void) btnBuyClick
{
    [_appDelegate showProgressHUDWithText:NSLocalizedString(@"Loading", nil)];
    
    [self.purchaseDropboxModalView hide];
    [[StoreKitBindingiOS sharedManager] purchaseProduct:IDpaymant quantity:1];
}

- (ModalView *) purchaseDropboxModalView
{
    if (!_purchaseDropboxModalView)
    {
        _purchaseDropboxModalView = [[ModalView alloc] initWithStyle:ModalViewStyleCustom btnTitles: nil];
        _purchaseDropboxModalView.titleLabel.text = NSLocalizedString(@"Purchase Dropbox support. (BUY)", nil);
        _purchaseDropboxModalView.delegate = self;
        
        CGRect btnFrame;
        btnFrame.size = CGSizeMake(_purchaseDropboxModalView.contentView.frame.size.width / 3,
                                   _purchaseDropboxModalView.contentView.frame.size.height / 4);
        btnFrame.origin = CGPointMake(_purchaseDropboxModalView.contentView.frame.size.width / 2 - btnFrame.size.width - 5,
                                      _purchaseDropboxModalView.contentView.frame.size.height / 2 - btnFrame.size.height / 2.5);
        
        UIButton * btnBuy = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBuy.frame = btnFrame;
        [btnBuy setTitle: NSLocalizedString(@"Buy", nil) forState:UIControlStateNormal];
        [btnBuy setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnBuy addTarget:self action:@selector(btnBuyClick) forControlEvents:UIControlEventTouchUpInside];
        [btnBuy setBackgroundImage:[[UIImage imageNamed:@"whiteBtn"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                          forState:UIControlStateNormal];
        [btnBuy setBackgroundImage:[[UIImage imageNamed:@"whiteBtnPush"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                          forState:UIControlStateHighlighted];
        [_purchaseDropboxModalView.contentView addSubview:btnBuy];
        
        UIButton * btnRestore = [UIButton buttonWithType:UIButtonTypeCustom];
        btnFrame.origin.x =_purchaseDropboxModalView.contentView.frame.size.width / 2 + 5;
        btnRestore.frame = btnFrame;
        [btnRestore setTitle: NSLocalizedString(@"Restore", nil) forState:UIControlStateNormal];
        [btnRestore setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnRestore addTarget:self action:@selector(btnRestoreClick) forControlEvents:UIControlEventTouchUpInside];
        [btnRestore setBackgroundImage:[[UIImage imageNamed:@"whiteBtn"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
        [btnRestore setBackgroundImage:[[UIImage imageNamed:@"whiteBtnPush"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateHighlighted];
        [_purchaseDropboxModalView.contentView addSubview:btnRestore];
    }
    
    return _purchaseDropboxModalView;
}*/

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
