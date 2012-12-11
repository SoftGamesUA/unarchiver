//
//  PopoverContent.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 08.02.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopoverContentDelegate;

typedef enum _PopoverContentStyle
{
    PopoverContentStyleVertical,
    PopoverContentStyleHorizont,
    PopoverContentStyleBreadcrumbs,
}PopoverContentStyle;

@interface PopoverContent : UIViewController
{
    PopoverContentStyle _style;
    NSMutableArray * _btns;
}

@property (nonatomic, assign) id <PopoverContentDelegate> delegate;

@property (nonatomic, assign) int btnCount;
@property (nonatomic, assign) CGSize btnSize;
@property (nonatomic, retain) UIImage *btnImage;
@property (nonatomic, retain) UIImage *btnBackgroundImage;
@property (nonatomic, retain) UIImage *btnBackgroundImagePush;
@property (nonatomic, retain) UIImage *dividerImage;
@property (nonatomic, retain) UIColor * textColor;                                     
@property (nonatomic, assign) UIControlContentHorizontalAlignment horizontAlingment;   

- (id) initWithStyle:(PopoverContentStyle)style;
- (void) setEnabled:(bool)enabled forButtonAtIndex:(int)index;
- (void) setup;

@end

@protocol PopoverContentDelegate <NSObject>
@optional
- (NSString *)textForBtnAtIndex:(int)index popoverContent:(PopoverContent *)popoverContent;
- (UIImage *)imageForBtnAtIndex:(int)index popoverContent:(PopoverContent *)popoverContent;
- (void)clickedBtnAtIndex:(int)index popoverContent:(PopoverContent *)popoverContent;
@end