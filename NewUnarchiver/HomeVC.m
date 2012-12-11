//
//  HomeVC.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 03.03.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "HomeVC.h"
#import "FolderVC.h"
#import "DropboxVC.h"
#import "BoxVC.h"
#import "CameraVC.h"
#import "YandexDiskVC.h"
#import "GoogleDriveVC.h"
#import "XFolderVC.h"

#import "PTPasscodeViewController.h"

#define IDpaymant @"unarchiverdropbox"

enum Sec0TableRows
{
    FilesRow        = 0,
    XFilesRow       = 1,
    InboxRow        = 2,
    DropboxRow      = 3,
    BoxnetRow       = 4,
    YandexRow       = 5,
    GoogleRow       = 6,
    FTPRow          = -1,
    Sec0RowCount    = 7,
};

enum Sec1TableRows
{
    CameraRow       = 0,
    MusicRow        = -1,
    VideoRow        = -1,
    Sec1RowCount    = 1,
};

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
    [self setImageBorder:[UIImage imageNamed:@"folderBorder"]];
    
    [navBar setBackgroundImage:[UIImage imageNamed:@"navBarBG"]];
    [navBar setIconImage:[UIImage imageNamed:@"homeNavBarIcon"]];
    [navBar setViewModeButtonImage:[UIImage imageNamed:@"listBtnFolder"]];
    [navBar setSettingsButtonImage:[UIImage imageNamed:@"settingsBtnFolder"]];
    [navBar setLabelTextColor:[UIColor orangeColor]];
    [navBar setLabelText:@"UnArchiver (2.0)"];
    [navBar setSubLabelText:NSLocalizedString(@"Home", nil)];
    
    [toolBar setImage:[UIImage imageNamed:@"addBtnFolder"] forBtn:ToolBarBtnAdd];
    [toolBar setImage:[UIImage imageNamed:@"shareBtnFolder"] forBtn:ToolBarBtnShare];
    [toolBar setImage:[UIImage imageNamed:@"ccpBtnFolder"] forBtn:ToolBarBtnCCP];
    [toolBar setImage:[UIImage imageNamed:@"archiveBtnFolder"] forBtn:ToolBarBtnArchive];
    [toolBar setImage:[UIImage imageNamed:@"deleteBtnFolder"] forBtn:ToolBarBtnDelete];
    [toolBar setImage:[UIImage imageNamed:@"helpBtnFolder"] forBtn:ToolBarBtnHelp];
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_tableView reloadData];
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
    if (section == 0) return Sec0RowCount;
    else if (section == 1) return Sec1RowCount;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
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
    
    UIImage *icon, *iconPush;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == FilesRow) 
        {
            cell.textLabel.text = NSLocalizedString(@"My Files", nil);
            icon = [UIImage imageNamed:@"folderNavBarIcon"];
            iconPush = [UIImage imageNamed:@"folderIconPush"];
        }
        if (indexPath.row == XFilesRow)
        {
            cell.textLabel.text = NSLocalizedString(@"XFolder", nil);
            icon = [UIImage imageNamed:@"folderNavBarIcon"];
            iconPush = [UIImage imageNamed:@"folderIconPush"];
        }
        else if (indexPath.row == InboxRow)
        {
            cell.textLabel.text = NSLocalizedString(@"Inbox", nil);
            icon = [UIImage imageNamed:@"folderNavBarIcon"];
            iconPush = [UIImage imageNamed:@"folderIcon"];
        }
        else if (indexPath.row == DropboxRow) 
        {
            cell.textLabel.text = NSLocalizedString(@"Dropbox", nil);
            icon = [UIImage imageNamed:@"dropboxNavBarIcon"];
            iconPush = [UIImage imageNamed:@"dropboxIconPush"];
        }
        else if (indexPath.row == BoxnetRow) 
        {
            cell.textLabel.text = NSLocalizedString(@"Box", nil);
            icon = [UIImage imageNamed:@"boxnetNavBarIcon"];
            iconPush = [UIImage imageNamed:@"boxnetIconPush"];
        }
        else if (indexPath.row == YandexRow)
        {
            cell.textLabel.text = NSLocalizedString(@"Yandex Disk", nil);
            icon = [UIImage imageNamed:@"yandexNavBarIcon"];
            iconPush = [UIImage imageNamed:@"yandexIconPush"];
        }
        else if (indexPath.row == GoogleRow)
        {
            cell.textLabel.text = NSLocalizedString(@"Google Drive", nil);
            icon = [UIImage imageNamed:@"googleNavBarIcon"];
            iconPush = [UIImage imageNamed:@"googleIconPush"];
        }
        else if (indexPath.row == FTPRow)
        {
            cell.textLabel.text = NSLocalizedString(@"My FTP", nil);
            icon = [UIImage imageNamed:@"folderNavBarIcon"];
            iconPush = [UIImage imageNamed:@"folderIcon"];
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == CameraRow) 
        {
            cell.textLabel.text = NSLocalizedString(@"Camera Roll", nil);
            icon = [UIImage imageNamed:@"cameraNavBarIcon"];
            iconPush = [UIImage imageNamed:@"photoIconPush"];
        }
        else if (indexPath.row == MusicRow)
        {
            cell.textLabel.text = NSLocalizedString(@"Music", nil);
            icon = [UIImage imageNamed:@"photoIcon"];
            iconPush = [UIImage imageNamed:@"photoIconPush"];
        }
        else if (indexPath.row == VideoRow) 
        {
            cell.textLabel.text = NSLocalizedString(@"Video", nil);
            icon = [UIImage imageNamed:@"photoIcon"];
            iconPush = [UIImage imageNamed:@"photoIconPush"];
        }
    }
    
    cell.imageView.image = icon;
    //cell.imageView.highlightedImage = iconPush;
    
    UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"folderAccessoryBtn"]];
    cell.accessoryView = accessoryView;
    [accessoryView release];
    
    return cell;	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == FilesRow)
        {
            FolderVC *vc = [[FolderVC alloc] init];
            vc.isMaster = self.isMaster;
            vc.rootFolder = appDelegate.documents;
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
        }
        if (indexPath.row == XFilesRow)
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
        else if (indexPath.row == InboxRow)
        {
            FolderVC *vc = [[FolderVC alloc] init];
            vc.isMaster = self.isMaster;
            vc.rootFolder = appDelegate.inbox;
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
        }
        else if (indexPath.row == DropboxRow) 
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
        else if (indexPath.row == BoxnetRow) 
        {
            BoxVC *vc = [[BoxVC alloc] init];
            vc.isMaster = self.isMaster;
            vc.rootFolder = [FileObject folderWithID:@"0" displayName:@"Box"];
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
        }
        else if (indexPath.row == YandexRow)
        {
            YandexDiskVC *vc = [[YandexDiskVC alloc] init];
            vc.isMaster = self.isMaster;
            vc.rootFolder = [FileObject folderWithPath:@"/"];
            vc.rootFolder.displayName = NSLocalizedString(@"Yandex", nil);
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
        }
        else if (indexPath.row == GoogleRow)
        {
            GoogleDriveVC *vc = [[GoogleDriveVC alloc] init];
            vc.isMaster = self.isMaster;
            vc.rootFolder = [FileObject folderWithID:@"root" displayName:@"Google"];
              [self.navigationController pushViewController:vc animated:true];
            [vc release];
        }
        else if (indexPath.row == FTPRow)
        {

        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == CameraRow) 
        {
            CameraVC *vc = [[CameraVC alloc] init];
            vc.isMaster = self.isMaster;
            [self.navigationController pushViewController:vc animated:true];
            [vc release];
        }
        else if (indexPath.row == MusicRow)
        {

        }
        else if (indexPath.row == VideoRow) 
        {

        }
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
    [_tableView reloadData];
}

- (void) goToXFolder
{
    XFolderVC *vc = [[XFolderVC alloc] init];
    vc.isMaster = self.isMaster;
    vc.rootFolder = appDelegate.xFolder;
    [self.navigationController pushViewController:vc animated:true];
    [vc release];
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
