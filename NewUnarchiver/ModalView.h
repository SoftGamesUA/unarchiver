//
//  ModalView.h
//  NewUnarchiver
//
//  Created by Женя Коваль on 01.03.12.
//  Copyright (c) 2012 SoftGames. All rights reserved.
//

@class ModalView;

@protocol ModalViewDelegate <NSObject>
@optional
- (void) modalView:(ModalView *)modalView clickedBtnAtIndex:(int)index;
- (void) didCancelModalView:(ModalView *)modalView;
@end

typedef enum _ModalViewStyle
{
    ModalViewStyleCustom,  
    ModalViewStyleTextField,
    ModalViewStyleTextView,
    ModalViewStyleMessage,
} ModalViewStyle;

@interface ModalView : UIView <UITextFieldDelegate>
{
    UIView * _superView;
    NSMutableArray * _btns;
    CGRect _contentViewFrame;
}

@property (nonatomic, assign) id <ModalViewDelegate> delegate;

@property (nonatomic, readonly) int btnCount;
@property (nonatomic, readonly) ModalViewStyle style;

@property (nonatomic, retain) UIImageView * contentView;
@property (nonatomic, retain) UILabel * titleLabel;
@property (nonatomic, retain) NSString * textFieldDefaultValue;
@property (nonatomic, retain) UITextField * textField;
@property (nonatomic, retain) UITextView * textView;
@property (nonatomic, retain) UILabel * messageLabel;

@property (nonatomic, assign) bool isShow;

@property (nonatomic, retain) id userInfo;

- (id) initWithStyle:(ModalViewStyle)style btnTitles:(NSString *)btnTitles, ... NS_REQUIRES_NIL_TERMINATION;
- (void) show;
- (void) hide;
- (void) setEnabled:(bool)enabled forBtnAtIndex:(int)index;

@end
