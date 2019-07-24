//
//  TNFilterColorView.h
//  EditPhotoDemo
//
//  Created by damai on 2019/7/12.
//  Copyright © 2019 xingliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TNFilterColorView;
@protocol TNFilterColorViewDelegate <NSObject>

- (void)filterColorView:(TNFilterColorView *)filterColorView didSelectedColor:(UIColor *)color;

@end

@interface TNFilterColorView : UIView

@property (nonatomic, strong) UIColor *defaultColor;
@property (nonatomic, weak) id<TNFilterColorViewDelegate> delegate;

@end
