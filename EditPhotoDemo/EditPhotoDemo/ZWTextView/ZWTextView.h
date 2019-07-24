//
//  ZWGTextView.h
//  EditPhotoDemo
//
//  Created by damai on 2019/7/12.
//  Copyright © 2019 xingliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZWTextView : UITextView

typedef enum {
    
    styleMove_Up               = 1<<1,         //向上展开
    styleMove_Down             = 1<<2,         //向下展开
    styleMove_Center           = 1<<3,         //中心保持不变，同时向上下展开
    
}MyTextViewStyle;

/**
 初始化方法(frame高度由font控制)

 @param frame  控件大小
 @param font   字体大小
 @return       TextView
 */
- (instancetype)initWithFrame:(CGRect)frame TextFont:(UIFont *)font MoveStyle:(MyTextViewStyle)style;

/**
 提示文字
 */
@property (nonatomic, strong) NSString *placeholder;

/**
 最大行数(default:5行)
 */
@property (nonatomic, assign) NSInteger maxNumberOfLines;


@property (nonatomic, copy) void (^textChangeBlock)(NSString *string);
@end
