//
//  HelpView.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 06.04.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "HelpView.h"

@implementation HelpView

- (void) setBgImage
{
    UIImage * img;
    
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
        {
            img = [UIImage imageNamed:@"helpLandscapeIPad"];
        }
        else
        {
            img = [UIImage imageNamed:@"helpLandscapeIPhone"];
        }
    }
    else
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
        {
            img = [UIImage imageNamed:@"helpPortraitIPad"];
        }
        else
        {
            img = [UIImage imageNamed:@"helpPortraitIPhone"];
        }
    }
    
    _bgView.image = img;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) 
                                                     name:UIDeviceOrientationDidChangeNotification object:nil];
        
        _bgView = [[UIImageView alloc] initWithFrame:frame];
        _bgView.autoresizingMask = self.autoresizingMask;
        
        [self setBgImage];
        [self addSubview:_bgView];
        
        int labelWidth = 250;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)   labelWidth *= 2;
        
        
        UIImageView * navImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpNavigation"]];
        navImg.frame = CGRectMake(0, 5, navImg.frame.size.width, navImg.frame.size.height);
        [self addSubview:navImg];
        UILabel *navHelp = [[UILabel alloc] initWithFrame:CGRectMake(60, navImg.frame.origin.y, labelWidth, navImg.frame.size.height)];
        navHelp.backgroundColor = [UIColor clearColor];
        navHelp.textColor = [UIColor whiteColor];
        navHelp.text = NSLocalizedString(@"Navigation", nil);
        navHelp.lineBreakMode = UILineBreakModeWordWrap;
        navHelp.numberOfLines = 2;
        [self addSubview:navHelp];     
        [navHelp release];
        [navImg release];
        
        UIImageView * addImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpAdd"]];
        addImg.frame = CGRectMake(0, 44, 44, 48);
        [self addSubview:addImg];
        UILabel *addHelp = [[UILabel alloc] initWithFrame:CGRectMake(60, addImg.frame.origin.y, labelWidth, addImg.frame.size.height)];
        addHelp.backgroundColor = [UIColor clearColor];
        addHelp.textColor = [UIColor whiteColor];
        addHelp.text = NSLocalizedString(@"Add New File (Text File, Image, Photo), Folder", nil);
        addHelp.lineBreakMode = UILineBreakModeWordWrap;
        addHelp.numberOfLines = 2;
        [self addSubview:addHelp];     
        [addHelp release];
        
        UIImageView * shareImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpShare"]];
        shareImg.frame = CGRectMake(0, addImg.frame.origin.y + addImg.frame.size.height, 44, 48);
        [self addSubview:shareImg];
        UILabel *shareHelp = [[UILabel alloc] initWithFrame:CGRectMake(60, shareImg.frame.origin.y, labelWidth, shareImg.frame.size.height)];
        shareHelp.backgroundColor = [UIColor clearColor];
        shareHelp.textColor = [UIColor whiteColor];
        shareHelp.text = NSLocalizedString(@"Email File or Save to Photos", nil);
        shareHelp.lineBreakMode = UILineBreakModeWordWrap;
        shareHelp.numberOfLines = 2;
        [self addSubview:shareHelp];     
        [shareHelp release];
        [addImg release];
        
        UIImageView * ccpImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpCCP"]];
        ccpImg.frame = CGRectMake(0, shareImg.frame.origin.y + shareImg.frame.size.height, 44, 48);
        [self addSubview:ccpImg];
        UILabel *ccpHelp = [[UILabel alloc] initWithFrame:CGRectMake(60, ccpImg.frame.origin.y, labelWidth, ccpImg.frame.size.height)];
        ccpHelp.backgroundColor = [UIColor clearColor];
        ccpHelp.textColor = [UIColor whiteColor];
        ccpHelp.text = NSLocalizedString(@"Copy, Cut, Paste, or Rename Selected Files", nil);
        ccpHelp.lineBreakMode = UILineBreakModeWordWrap;
        ccpHelp.numberOfLines = 2;
        [self addSubview:ccpHelp];     
        [ccpHelp release];
        [shareImg release];
        
        UIImageView * archiveImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpArchive"]];
        archiveImg.frame = CGRectMake(0, ccpImg.frame.origin.y + ccpImg.frame.size.height, 44, 48);
        [self addSubview:archiveImg];
        UILabel *archiveHelp = [[UILabel alloc] initWithFrame:CGRectMake(60, archiveImg.frame.origin.y, labelWidth, archiveImg.frame.size.height)];
        archiveHelp.backgroundColor = [UIColor clearColor];
        archiveHelp.textColor = [UIColor whiteColor];
        archiveHelp.text = NSLocalizedString(@"Archive or Unarchive Selected Files", nil);
        archiveHelp.lineBreakMode = UILineBreakModeWordWrap;
        archiveHelp.numberOfLines = 2;
        [self addSubview:archiveHelp];     
        [archiveHelp release];
        [ccpImg release];
        
        UIImageView * deleteImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpDelete"]];
        deleteImg.frame = CGRectMake(0, archiveImg.frame.origin.y + archiveImg.frame.size.height, 44, 48);
        [self addSubview:deleteImg];
        UILabel *deleteHelp = [[UILabel alloc] initWithFrame:CGRectMake(60, deleteImg.frame.origin.y, labelWidth, deleteImg.frame.size.height)];
        deleteHelp.backgroundColor = [UIColor clearColor];
        deleteHelp.textColor = [UIColor whiteColor];
        deleteHelp.text = NSLocalizedString(@"Delete Selected Files", nil);
        deleteHelp.lineBreakMode = UILineBreakModeWordWrap;
        deleteHelp.numberOfLines = 2;
        [self addSubview:deleteHelp];     
        [deleteHelp release];
        [archiveImg release];
        [deleteImg release];
        
        UILabel *actionHelp = [[UILabel alloc] init];
        actionHelp.backgroundColor = [UIColor clearColor];
        actionHelp.textColor = [UIColor whiteColor];
        actionHelp.text = NSLocalizedString(@"Make Action With File", nil);
        actionHelp.lineBreakMode = UILineBreakModeWordWrap;
        actionHelp.numberOfLines = 2;
        actionHelp.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;

        UIImageView * actionImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpAction"]];
        actionImg.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:actionImg];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
        {
            UIImageView * dividerImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpDivider"]];
            dividerImg.frame = CGRectMake(frame.size.width / 2 - dividerImg.frame.size.width / 2, frame.size.height - dividerImg.frame.size.height / 2, 
                                          dividerImg.frame.size.width, dividerImg.frame.size.height);
            [self addSubview:dividerImg];
            UILabel *dividerHelp = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width / 2 - labelWidth / 2, 
                                                                             frame.size.height - dividerImg.frame.size.height, labelWidth, 40)];
            dividerHelp.backgroundColor = [UIColor clearColor];
            dividerHelp.textColor = [UIColor whiteColor];
            dividerHelp.text = NSLocalizedString(@"Divider", nil);
            dividerHelp.textAlignment = UITextAlignmentCenter;
            dividerHelp.autoresizingMask = dividerImg.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin  | UIViewAutoresizingFlexibleTopMargin;
            [self addSubview:dividerHelp];     
            [dividerHelp release];
            [dividerImg release];
            
            actionImg.frame = CGRectMake(frame.size.width / 2 - actionImg.frame.size.width + 5, 395, actionImg.frame.size.width, actionImg.frame.size.height);
            actionHelp.frame = CGRectMake(frame.size.width / 2 + 15, actionImg.frame.origin.y, labelWidth, actionImg.frame.size.height);
        }
        else
        {
            actionImg.frame = CGRectMake(frame.size.width - actionImg.frame.size.width, 345, actionImg.frame.size.width, actionImg.frame.size.height);
            actionHelp.frame = CGRectMake(0, actionImg.frame.origin.y, frame.size.width - actionImg.frame.size.width, actionImg.frame.size.height);
            actionHelp.textAlignment = UITextAlignmentRight;
        }
        
        [self addSubview:actionHelp];   
        [self addSubview:actionImg];
        [actionHelp release];
        [actionImg release];
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification 
{ 
    [self setBgImage];
	[self.superview bringSubviewToFront:self];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_bgView release];
    
    [super dealloc];
}

@end
