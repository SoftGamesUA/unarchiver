//
//  FileCell.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 25.02.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "FileCell.h"
#import "AppDelegate.h"

@implementation FileCell

@synthesize icon = _icon;
@synthesize fileLabel = _fileLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) 
    {
         int gap = 5;
        
        UIImage * img = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"cellBg" ofType:@"png"]];
        UIImageView * bg = [[UIImageView alloc] initWithImage:img];
        self.backgroundView = bg;
        [bg release];
        [img release];
        
        img = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"selectedCellBg" ofType:@"png"]];
        UIImageView * bgSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectedCellBg.png"]];
        self.selectedBackgroundView = bgSelected;
        [bgSelected release];
        [img release];
        
        img = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"checkboxUNcheked" ofType:@"png"]];
        self.imageView.image = img;
        [img release];

        CGRect iconFrame = CGRectMake(img.size.width * 2, gap, cellHeight - gap * 2, cellHeight - gap * 2);
        _icon = [[UIImageView alloc] initWithFrame:iconFrame];
        [self.contentView addSubview:_icon];
       
        CGRect lbFrame = iconFrame;
        lbFrame.origin.x = iconFrame.origin.x + iconFrame.size.width + gap * 2;
        lbFrame.size.width = self.contentView.frame.size.width - lbFrame.origin.x;
        _fileLabel = [[UILabel alloc] initWithFrame:lbFrame];
        _fileLabel.backgroundColor = [UIColor clearColor];
        _fileLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_fileLabel];
        
   }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIImage * img;
    
    if (selected)
        img = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"checkboxCheked" ofType:@"png"]];
    else
        img = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"checkboxUNcheked" ofType:@"png"]];
    
    self.imageView.image = img;
    [img release];
    
    [super setSelected:selected animated:animated];
}

- (void) dealloc
{
    [_icon release];
    [_fileLabel release];
    
    [super dealloc];
}

@end
