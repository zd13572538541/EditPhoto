//
//  SelectView.h
//  WisdomPasture
//
//  Created by damai on 2019/5/6.
//  Copyright © 2019年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^selectBlock)(UITextView *textV);

@interface SelectView : UIView
@property (nonatomic, copy) selectBlock block;

//显示
-(void)showWithText:(NSString *)string Color:(UIColor *)textColor Block:(selectBlock)block;


@end
