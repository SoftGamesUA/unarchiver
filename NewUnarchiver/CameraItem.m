//
//  CameraItem.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 19.07.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import "CameraItem.h"

#define CHECK_BOX_SIZE 25

@implementation CameraItem

@synthesize selected = _selected;
@synthesize delegate = _delegate;

- (id)init
{
    self = [super init];
    if (self) 
    {
        _checkBoxChecked = [[UIImage imageNamed:@"checkboxCheked.png"] retain];
        _checkBoxUnchecked = [[UIImage imageNamed:@"checkboxUNcheked.png"] retain];
        
        _checkBox = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, CHECK_BOX_SIZE, CHECK_BOX_SIZE)];
        [self addSubview:_checkBox];
        self.selected = false;
        
        self.userInteractionEnabled = true;
    }
    return self;
}

- (void) setSelected:(bool)selected
{
    _selected = selected;
    _checkBox.image = selected ? _checkBoxChecked : _checkBoxUnchecked;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_delegate) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint loaction = [touch locationInView:self];
    
    CGRect checkBoxFrame = _checkBox.frame;
    checkBoxFrame.size.width *= 2;
    checkBoxFrame.size.height *= 2;
    if (CGRectContainsPoint(checkBoxFrame, loaction))
    {
        if ([_delegate respondsToSelector:@selector(cameraItemCheckBoxDidTouch:)])
        {
            [_delegate cameraItemCheckBoxDidTouch:self];
        }
    }
    else 
    {
        if ([_delegate respondsToSelector:@selector(cameraItemDidTouch:)])
        {
            [_delegate cameraItemDidTouch:self];
        }
    }
}

- (void) dealloc
{
    [_checkBox release];
    [_checkBoxChecked release];
    [_checkBoxUnchecked release];
    [super dealloc];
}

@end
