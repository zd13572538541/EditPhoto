//
//  ImageEditorViewController.h
//  EditPhotoDemo
//
//  Created by damai on 2019/7/12.
//  Copyright © 2019 xingliang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageEditorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageV;


@property (nonatomic, strong) UIImage  *image;      //


@property (nonatomic, copy) void (^imageBlock)(NSArray *textArr,UIView *workView);
@end

NS_ASSUME_NONNULL_END
