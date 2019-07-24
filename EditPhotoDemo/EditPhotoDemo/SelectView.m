
//
//  SelectView.m
//  WisdomPasture
//
//  Created by damai on 2019/5/6.
//  Copyright © 2019年 Apple. All rights reserved.
//

#import "SelectView.h"
#import "ZWTextView.h"
#import "UIView+Frame.h"
#import "TNFilterColorView.h"


#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenwidth (kScreenBounds.size.width)
#define kScreenheight (kScreenBounds.size.height)

@interface SelectView ()<UIGestureRecognizerDelegate,UITextViewDelegate,TNFilterColorViewDelegate>{
    CAShapeLayer *borderLayer ;
    NSTimeInterval timeInterval;
}

@property (nonatomic, strong) NSMutableArray  *mulArr;
@property (weak, nonatomic) IBOutlet UIView *bootmView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;

@property (nonatomic, strong) TNFilterColorView *filterColor;

@property (nonatomic, strong) ZWTextView *inputTextView;
@property (nonatomic, strong) UITextView *showTextView;
@property (nonatomic, assign) CGFloat   height;

@end
@implementation SelectView

-(void)awakeFromNib{
    [super awakeFromNib];
  
    [self setupView];
}

-(void)showWithText:(NSString *)string Color:(UIColor *)textColor Block:(selectBlock)block{
    self.mulArr = [NSMutableArray array];
    self.inputTextView.text = string;
    self.inputTextView.maxNumberOfLines = 2;
    self.showTextView.textColor = textColor;
    self.filterColor.defaultColor = textColor;
    [self.inputTextView becomeFirstResponder];
    self.bottomHeight.constant = kScreenheight-100;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    if (block) {
        self.block = block;
    }
}
-(void)setupView{
    self.height = 0;

    __weak typeof(self) weakSelf = self;
    
    self.frame=[UIScreen mainScreen].bounds;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    self.backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35] ;
    self.backView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Action:)];
    tap.delegate = self;
    [self.backView addGestureRecognizer:tap];
    
    self.bottomHeight.constant = kScreenheight-100;
    self.inputTextView = [[ZWTextView alloc] initWithFrame:CGRectMake(10, 50, kScreenwidth-20,50) TextFont:[UIFont systemFontOfSize:16] MoveStyle:styleMove_Center];
    self.inputTextView.placeholder = @"请输入您要添加的文字";
    self.inputTextView.backgroundColor = [UIColor whiteColor];
    [self.bootmView addSubview:self.inputTextView];
    
    
    self.filterColor = [[TNFilterColorView alloc] initWithFrame:CGRectMake(0, 0, kScreenwidth, 50)];
    self.filterColor.delegate = self;
//    self.filterColor.backgroundColor = self.backgroundColor;
   
    
    
    self.inputTextView.textChangeBlock = ^(NSString *string) {
      
        [weakSelf refreshTextViewFrame: (kScreenheight-100-self.height)-80 String:string];
    };
    self.showTextView = [[UITextView alloc]init];
    self.showTextView.userInteractionEnabled = NO;
    self.showTextView.font = [UIFont systemFontOfSize:16];
    self.showTextView.center = self.backView.center;
    self.showTextView.layoutManager.allowsNonContiguousLayout = NO;
    self.showTextView.backgroundColor = [UIColor clearColor];
    self.showTextView.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
    [self.backView addSubview:self.showTextView];
   
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)name:UIKeyboardDidShowNotification object:nil];
}

-(void)keyboardDidShow:(NSNotification *)aNotification{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    self.height = keyboardRect.size.height;
    self.showTextView.center = CGPointMake(kScreenwidth/2, (kScreenheight-100-self.height)/2);
    self.bottomHeight.constant = kScreenheight-100-self.height;
    [self layoutIfNeeded];
}
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification{
    
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    timeInterval = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];//动画持续时间
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    self.height = keyboardRect.size.height;

    self.showTextView.center = CGPointMake(kScreenwidth/2, (kScreenheight-100-self.height)/2);
    self.bottomHeight.constant = kScreenheight-100-self.height;
    [UIView animateWithDuration:timeInterval animations:^{
         [self layoutIfNeeded];
         [self.bootmView addSubview:self.filterColor];
        self.showTextView.text = self.inputTextView.text;
        [self refreshTextViewFrame: (kScreenheight-100-self.height)-80 String:self.inputTextView.text];
    }];
   
 
}
-(void)refreshTextViewFrame:(CGFloat) heightTemp String:(NSString *)str{
    UITextView *viewTemp = [[UITextView alloc]initWithFrame:CGRectMake(10, 0, kScreenwidth-20, self.backView.frame.size.height-80)];
    viewTemp.text = str;
    viewTemp.font = [UIFont systemFontOfSize:16];
    [viewTemp sizeToFit];
    CGPoint center = CGPointMake(kScreenwidth/2, (kScreenheight-100-self.height)/2);
    CGFloat wide  = viewTemp.width;
    CGFloat height  = viewTemp.height;
    
    if (wide<(kScreenwidth-20)) {
        if (height<heightTemp) {
            self.showTextView.frame = CGRectMake(center.x-wide/2, center.y-height/2, wide, height);
             self.showTextView.text = str;
            [self.showTextView sizeToFit];
            [self addLine];
        }else{
            self.showTextView.frame = CGRectMake(center.x-wide/2, 40, wide, heightTemp);
             NSLog(@"==========OUT");
            self.showTextView.adjustsFontForContentSizeCategory = YES;
            return;
        }
    }else{
        if (height<heightTemp) {
            self.showTextView.frame = CGRectMake(10, center.y-height/2, kScreenwidth-20, height);
             self.showTextView.text = str;
            [self.showTextView sizeToFit];
            [self addLine];
        }else{
           
            self.showTextView.frame = CGRectMake(10, 40, kScreenwidth-20, heightTemp);
            NSLog(@"==========OUT");
             self.showTextView.adjustsFontForContentSizeCategory = YES;
            return;
        }
    }
}
- (void)Action:(UITapGestureRecognizer *)tap{
    [self endEditing:YES];
    [self dismis];
}
- (void)dismis {
    [borderLayer removeFromSuperlayer];
    if (self.block) {
        self.block( self.showTextView);
    }
    [self.backView removeFromSuperview];
    [self.bootmView removeFromSuperview];
    [self removeFromSuperview];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch{
    
    if ([touch.view isEqual:self.backView]) {
        return YES;
    }
    return NO;
}

-(void)addLine{

    if (borderLayer==nil) {
         borderLayer = [CAShapeLayer layer];
    }
    borderLayer.bounds = CGRectMake(0, 0, self.showTextView.width,  self.showTextView.height);
    borderLayer.position = CGPointMake(CGRectGetMidX( self.showTextView.bounds), CGRectGetMidY( self.showTextView.bounds));
    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:6.0].CGPath;
    borderLayer.lineWidth = 1;
    //虚线边框---小边框的长度
    borderLayer.lineDashPattern = @[@4, @2];//前边是虚线的长度，后边是虚线之间空隙的长度
    borderLayer.lineDashPhase = 0.1;
    //实线边框
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = [UIColor redColor].CGColor;
    [self.showTextView.layer addSublayer:borderLayer];
    
}
- (void)filterColorView:(TNFilterColorView *)filterColorView didSelectedColor:(UIColor *)color {

    self.showTextView.textColor = color;
}
@end
