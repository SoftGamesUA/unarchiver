//
//  ToolBar.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 01.02.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum ToolBarBtnTag
{
    ToolBarBtnAdd = 0,
    ToolBarBtnShare,
    ToolBarBtnCCP,
    ToolBarBtnArchive,  
    ToolBarBtnDelete,  
    ToolBarBtnHelp, 
    ToolBarBtnCount,
} ToolBarBtnTag;

@protocol ToolBarBtnDelegate <NSObject>
@optional
- (void) clickedBtn:(ToolBarBtnTag)btnTag;
@end

@interface ToolBar : UIView
{
    NSMutableArray *_btns, * _imgViews;
}

@property (nonatomic, assign) id <ToolBarBtnDelegate> delegate;

- (void) setImage:(UIImage *)image forBtn:(ToolBarBtnTag)btnTag;
- (void) setEnabled:(bool)enabled forBtn:(ToolBarBtnTag)btnTag;
- (void) setSelected:(bool)selected forBtn:(ToolBarBtnTag)btnTag;
- (void) setButtonTitleColor:(UIColor *)color;
- (void) sizeToFit;

- (CGRect) rectForPopoverInView:(UIView *)view btn:(ToolBarBtnTag)btnTag;

@end
