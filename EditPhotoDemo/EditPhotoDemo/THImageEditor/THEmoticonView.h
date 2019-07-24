//
//  THEmoticonView.h
//  EditPhotoDemo
//
//  Created by damai on 2019/7/12.
//  Copyright © 2019 xingliang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class THEmoticonView;
@protocol THTextViewDelegate <NSObject>

- (void)filterTextViewEditTexTag:(THEmoticonView *)sender;

@end

@interface THEmoticonView : UIView
@property (nonatomic, assign) CGFloat scale;    //当前缩放比例
@property (nonatomic, assign) CGFloat orignalFontSize;    //初始 字体大小
@property (nonatomic, assign) CGFloat fontSize;    //当前缩放 字体大小

@property (nonatomic, strong) NSString  *titleStr;
@property (nonatomic, strong) UIImage  *textImage;
@property (nonatomic, assign) NSInteger   indexTag;
@property (nonatomic, strong) UIColor  *textColor;      


@property (nonatomic, strong) id<THTextViewDelegate> delegate;

- (instancetype)initWithButton:(UIButton *)btn;

+ (void)setActiveEmoticonView:(THEmoticonView *)view;

@end
