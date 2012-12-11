//
//  HomeVC.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 03.03.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "ArchiveVC.h"
#import "FolderVC.h"

@implementation ArchiveVC

#pragma mark -
#pragma mark init

- (void) initTable
{
    CGRect tableFrame;
    tableFrame.origin.x = 0;
    tableFrame.origin.y = navBar.frame.origin.y + navBar.frame.size.height;
    tableFrame.size.width = self.view.frame.size.width;
    tableFrame.size.height = self.view.frame.size.height - self.view.frame.size.height / 4.5;
    
    _tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.hidden = true;
    [_tableView setEditing:true animated:false];
    [self.view addSubview:_tableView];

}

- (void) initButtons
{
    CGRect btnFrame;
    int gap = 10;
    btnFrame.origin.x = gap;
    btnFrame.origin.y = _tableView.frame.origin.y + _tableView.frame.size.height + gap;
    btnFrame.size.width = self.view.frame.size.width - gap * 2;
    btnFrame.size.height = (self.view.frame.size.height - btnFrame.origin.y - borderHeight - gap * 3) / 3;
    _btnCreate = [[UIButton alloc] initWithFrame:btnFrame];
    [_btnCreate setTitle:NSLocalizedString(@"Create Archive", nil) forState:UIControlStateNormal];
    _btnCreate.titleLabel.textColor = [UIColor whiteColor];
    [_btnCreate setBackgroundImage:[[UIImage imageNamed:@"NavBarPopoverBtn"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] 
                          forState:UIControlStateNormal];
    [_btnCreate setBackgroundImage:[[UIImage imageNamed:@"NavBarPopoverBtnPush"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] 
                          forState:UIControlStateHighlighted];
    _btnCreate.hidden = true;
    _btnCreate.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_btnCreate addTarget:self action:@selector(btnCreateClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnCreate];
    
    btnFrame.origin.y += btnFrame.size.height + gap;
    _btnCreateWithPassword = [[UIButton alloc] initWithFrame:btnFrame];
    [_btnCreateWithPassword setTitle:NSLocalizedString(@"Create Archive With Password", nil) forState:UIControlStateNormal];
    _btnCreateWithPassword.titleLabel.textColor = [UIColor whiteColor];
    [_btnCreateWithPassword setBackgroundImage:[[UIImage imageNamed:@"NavBarPopoverBtn"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] 
                          forState:UIControlStateNormal];
    [_btnCreateWithPassword setBackgroundImage:[[UIImage imageNamed:@"NavBarPopoverBtnPush"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] 
                          forState:UIControlStateHighlighted];
    _btnCreateWithPassword.hidden = true;
    _btnCreateWithPassword.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_btnCreateWithPassword addTarget:self action:@selector(btnCreateWithPasswordClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnCreateWithPassword];
    
    btnFrame.origin.y += btnFrame.size.height + gap;
    _btnCancel = [[UIButton alloc] initWithFrame:btnFrame];
    [_btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    _btnCancel.titleLabel.textColor = [UIColor whiteColor];
    [_btnCancel setBackgroundImage:[[UIImage imageNamed:@"NavBarPopoverBtn"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                          forState:UIControlStateNormal];
    [_btnCancel setBackgroundImage:[[UIImage imageNamed:@"NavBarPopoverBtnPush"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                          forState:UIControlStateHighlighted];
    _btnCancel.hidden = true;
    _btnCancel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnCancel];
}

- (void) customizeInterface
{
    [self setImageBorder:[UIImage imageNamed:@"folderBorder"]];
    
    [navBar setBackgroundImage:[UIImage imageNamed:@"archiveNavBarBg"]];
    [navBar setIconImage:[UIImage imageNamed:@"archiveNavBarIcon"]];
    [navBar setViewModeButtonImage:[UIImage imageNamed:@"listBtnFolder"]];
    [navBar setLabelTextColor:[UIColor greenColor]];
    [navBar setLabelText:NSLocalizedString(@"Archive", nil)];
    
    CGRect frame = self.view.bounds;
    frame.origin.y = navBar.frame.origin.y + navBar.frame.size.height;
    frame.size.height = frame.size.height - frame.origin.y - borderHeight;
    UIImageView *bg = [[UIImageView alloc] initWithFrame:frame];
    bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bg.image = [UIImage imageNamed:@"archiveBg"];
   
    frame.origin = CGPointMake(bg.frame.size.width / 4, bg.frame.size.height / 5);
    frame.size = CGSizeMake(bg.frame.size.width / 2, bg.frame.size.width / 2);
    UIImageView *archive = [[UIImageView alloc] initWithFrame:frame];
    archive.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    archive.contentMode = UIViewContentModeScaleAspectFit;
    archive.image =[UIImage imageNamed:@"archiveImage"];
    [bg addSubview:archive];
        
    CGRect labelFrame;
    labelFrame.origin.x = 50;
    labelFrame.size.width = bg.bounds.size.width - 100;
    labelFrame.size.height = 25;
    labelFrame.origin.y = frame.origin.y + frame.size.height + labelFrame.size.height * 4;
    _helpLabel = [[UILabel alloc] initWithFrame:labelFrame];
    _helpLabel.contentMode = UIViewContentModeCenter;
    _helpLabel.autoresizingMask = archive.autoresizingMask;
    _helpLabel.backgroundColor = [UIColor clearColor];
    _helpLabel.textColor = [UIColor whiteColor];
    _helpLabel.textAlignment = UITextAlignmentCenter;
    _helpLabel.adjustsFontSizeToFitWidth = true;
    _helpLabel.font = [UIFont boldSystemFontOfSize:25];
    _helpLabel.text = NSLocalizedString(@"Drop files here", nil);
    
    [bg addSubview:_helpLabel];
    [archive release];
    
    [self.view addSubview:bg];
    [bg release];
}

- (void)filesDidDrag:(NSNotification *)notification
{
    NSSet * newFiles = [[ClipboardManager sharedManager] files];
        
    if ([ClipboardManager sharedManager].source == FileSourceFolder)
    {          
        if ([_files count] == 0) 
        {
            if ([newFiles count] == 1)
            {
                FileObject * file = [newFiles anyObject];
                if ([[[file.displayName pathExtension]  lowercaseString] isEqualToString:@"zip"])
                {
                    NSDictionary * info = [NSDictionary dictionaryWithObjectsAndKeys:file, FILE_KEY, nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UNZIP_NOTIFICATION object:self userInfo:info];
                    return;
                }
                else if ([[[file.displayName pathExtension] lowercaseString] isEqualToString:@"rar"])
                {
                    NSDictionary * info = [NSDictionary dictionaryWithObjectsAndKeys:file, FILE_KEY, nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UNRAR_NOTIFICATION object:self userInfo:info];;
                    return;
                }
            }
            
            _tableView.hidden = false;
            _btnCreate.hidden = false;
            _btnCancel.hidden = false;
            _btnCreateWithPassword.hidden = false;
            _helpLabel.hidden =  true;
        }
        
        for (FileObject * file in newFiles)
        {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"displayName == %@", file.displayName];
            NSArray * result = [_files filteredArrayUsingPredicate:predicate];
            if ([result count] == 0)
            {
                [_files addObject:file];
            }
        }
        
        [_tableView reloadData];
    }
    [[ClipboardManager sharedManager] clear];
}

#pragma mark -
#pragma mark buttons

- (void) btnCancelClick
{
    _tableView.hidden = true;
    _btnCreate.hidden = true;
    _btnCancel.hidden = true;
    _btnCreateWithPassword.hidden = true;
    _helpLabel.hidden =  false;
    [_files removeAllObjects];
}

- (void) btnCreateClick
{
    NSDictionary * info = [NSDictionary dictionaryWithObjectsAndKeys:[NSSet setWithArray:_files], FILE_KEY,
                           [NSNumber numberWithBool:false], PASSWORD_KEY, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ZIP_NOTIFICATION object:self userInfo:info];
    
    [self btnCancelClick];
}

- (void) btnCreateWithPasswordClick
{
    NSDictionary * info = [NSDictionary dictionaryWithObjectsAndKeys:[NSSet setWithArray:_files], FILE_KEY,
                           [NSNumber numberWithBool:true], PASSWORD_KEY, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ZIP_NOTIFICATION object:self userInfo:info];
    
    [self btnCancelClick];
}

#pragma mark - View lifecycle

- (id)init
{
    self = [super initWithNavBarStyle:NavBarStyleSimple toolbar:false];
    if (self) 
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = true;
    
    [self customizeInterface];
    [self initTable];
    [self initButtons];
    
    _files = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filesDidDrag:) name:DRAG_FILES_NOTIFICATION object:nil];
}

- (void)viewDidUnload
{
    [self clean];
    
    [super viewDidUnload];
}

- (void) clean
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_tableView release];
    [_files release];
    [_helpLabel release];
    [_btnCancel release];
    [_btnCreate release];
    [_btnCreateWithPassword release];
}

- (void) dealloc
{
    [self clean];
    
    [super dealloc];
}

#pragma mark -
#pragma mark table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_files count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    FileObject * file = [_files objectAtIndex:indexPath.row];
    cell.textLabel.text = file.displayName;
    
    return cell;	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[_files removeObjectAtIndex:indexPath.row];
	[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	if ([_files count] == 0) [self btnCancelClick];
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
