//
//  QuickMessage.m
//  NewUnarchiver
//
//  Created by Женя Коваль on 06.11.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.

#import "QuickMessage.h"

CGPathRef NewPathWithRoundRect(CGRect rect, CGFloat cornerRadius);

CGPathRef NewPathWithRoundRect(CGRect rect, CGFloat cornerRadius)
{
	//
	// Create the boundary path
	//
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y + rect.size.height - cornerRadius);

	// Top left corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y,
		rect.origin.x + rect.size.width,
		rect.origin.y,
		cornerRadius);

	// Top right corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x + rect.size.width,
		rect.origin.y,
		rect.origin.x + rect.size.width,
		rect.origin.y + rect.size.height,
		cornerRadius);

	// Bottom right corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x + rect.size.width,
		rect.origin.y + rect.size.height,
		rect.origin.x,
		rect.origin.y + rect.size.height,
		cornerRadius);

	// Bottom left corner
	CGPathAddArcToPoint(path, NULL,
		rect.origin.x,
		rect.origin.y + rect.size.height,
		rect.origin.x,
		rect.origin.y,
		cornerRadius);

	// Close the path at the rounded rect
	CGPathCloseSubpath(path);
	
	return path;
}

@implementation QuickMessage

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.opaque = NO;
        self.hidden = true;
        self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        CGRect labelFrame = CGRectMake(10, 10, self.frame.size.width - 20, self.frame.size.height - 20);
        _label = [[UILabel alloc] initWithFrame:labelFrame];
        
        _label.adjustsFontSizeToFitWidth = true;
        _label.textColor = [UIColor whiteColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = UITextAlignmentCenter;
        _label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        _label.autoresizingMask =
		UIViewAutoresizingFlexibleLeftMargin |
		UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleTopMargin |
		UIViewAutoresizingFlexibleBottomMargin;
        
        [self addSubview:_label];
    }
    return self;
}

- (void) showWithText:(NSString *)text
{	
    _label.text = text;
    
    self.alpha = 0;
	self.hidden = false;
    
    [UIView beginAnimations:@"anim" context:nil];
    [UIView setAnimationDuration:1];
    
    self.alpha = 1;
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(hide) withObject:nil afterDelay:2];
}

-(void)hide
{    
    [UIView beginAnimations:@"anim1" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationDidStopSelector:@selector(hideFinish)];
    
    self.alpha = 0;
    
    [UIView commitAnimations];
}

- (void) hideFinish
{
    self.hidden = true;
}

- (void)drawRect:(CGRect)rect
{
	rect.size.height -= 1;
	rect.size.width -= 1;
	
	const CGFloat RECT_PADDING = 0.0;
	rect = CGRectInset(rect, RECT_PADDING, RECT_PADDING);
	
	const CGFloat ROUND_RECT_CORNER_RADIUS = 5.0;
	CGPathRef roundRectPath = NewPathWithRoundRect(rect, ROUND_RECT_CORNER_RADIUS);
	
	CGContextRef context = UIGraphicsGetCurrentContext();

	const CGFloat BACKGROUND_OPACITY = 0.5;
	CGContextSetRGBFillColor(context, 0, 0, 0, BACKGROUND_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextFillPath(context);

	const CGFloat STROKE_OPACITY = 0.25;
	CGContextSetRGBStrokeColor(context, 1, 1, 1, STROKE_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextStrokePath(context);
	
	CGPathRelease(roundRectPath);
}

- (void)dealloc
{
    [_label release];
    
    [super dealloc];
}

@end
