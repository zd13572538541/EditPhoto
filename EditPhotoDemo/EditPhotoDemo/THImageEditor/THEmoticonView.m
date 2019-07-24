//
//  THEmoticonView.m
//  EditPhotoDemo
//
//  Created by damai on 2019/7/12.
//  Copyright © 2019 xingliang. All rights reserved.
//

#import "THEmoticonView.h"
#import "UIView+Frame.h"

static const NSUInteger kDeleteBtnSize = 25;

@interface THEmoticonView()
{
    
    UIButton *_deleteButton;    //删除按钮

    CGFloat _arg;       //当前旋转比例
    
    CGPoint _initialPoint; //表情的中心点
    CGFloat _initialScale;  //修改前的缩放比例
    CGFloat _initialArg;    //修改前旋转比例
    
}

@property (nonatomic, strong) CAShapeLayer *dashedBoarder; //边线
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *editPressKey; //编辑
@property (nonatomic, strong) UIImageView *rotatoPressKey;//旋转放大缩小



@end
@implementation THEmoticonView

#pragma mark =================== view 初始化 ====================

- (instancetype)initWithButton:(UIButton *)btn{
    
    self = [super initWithFrame:CGRectMake(btn.frame.origin.x, btn.frame.origin.y, btn.frame.size.width + kDeleteBtnSize*2, btn.frame.size.height+ kDeleteBtnSize*2)];

    
    if (self) {
      
        UIImage *image = btn.imageView.image;
        self.imageView = [[UIImageView alloc]initWithImage:image];
        self.imageView.frame = CGRectMake(kDeleteBtnSize,kDeleteBtnSize, btn.width, btn.height);
        self.imageView.contentMode = UIViewContentModeCenter;
        self.textImage = image;
        self.imageView.center = self.center;
        [self addSubview:self.imageView];

        _deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kDeleteBtnSize, kDeleteBtnSize)];
        [_deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(clickDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        self.editPressKey = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit"]];
        self.editPressKey.frame = CGRectMake(0, 0, kDeleteBtnSize, kDeleteBtnSize);
        self.editPressKey.backgroundColor = [UIColor lightGrayColor];
        self.editPressKey.layer.cornerRadius = CGRectGetWidth(self.editPressKey.frame) / 2.0;
        [self addSubview:self.editPressKey];
        
        self.rotatoPressKey = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rotate"]];
        self.rotatoPressKey.frame = CGRectMake(0, 0, kDeleteBtnSize, kDeleteBtnSize);
        self.rotatoPressKey.contentMode = UIViewContentModeCenter;
        self.rotatoPressKey.backgroundColor = [UIColor lightGrayColor];
        self.rotatoPressKey.layer.cornerRadius = CGRectGetWidth(self.rotatoPressKey.frame) / 2.0;
        [self addSubview:self.rotatoPressKey];
    
        _scale = 1;
        _arg = 0;
        [self initGestures];
    }
    return self;
}
#pragma mark =================== 手势初始化 ====================
- (void)initGestures{
//    self.userInteractionEnabled = YES;
    self.imageView.userInteractionEnabled = YES;
    self.rotatoPressKey.userInteractionEnabled = YES;
    self.editPressKey.userInteractionEnabled = YES;
//    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentTapped:)]];
//
    [self.rotatoPressKey addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scaleBtnDidPan:)]];
    [self.editPressKey addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editText:)]];
    
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentTapped:)]];
    [self.imageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidPan:)]];
   
   
}
#pragma mark =================== 手势事件 ====================
#pragma mark - 复制
- (void)editText:(UITapGestureRecognizer *)sender {
    
    if ([self.delegate respondsToSelector:@selector(filterTextViewEditTexTag:)]) {
        [self.delegate filterTextViewEditTexTag:self];
    }
}
#pragma mark -  点击
- (void)contentTapped:(UITapGestureRecognizer *)sender{
    
    if(!_deleteButton.hidden){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kTextViewActiveViewDidTapNotification" object:self];
    }
    if (_deleteButton.hidden) {
        [[self class] setActiveEmoticonView:self];
    }
}
#pragma mark -  拖动
- (void)imageDidPan:(UIPanGestureRecognizer*)sender
{
    [[self class] setActiveEmoticonView:self];
    
    CGPoint p = [sender translationInView:self.superview];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _initialPoint = self.center;
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
}

#pragma mark -  缩放
- (void)scaleBtnDidPan:(UIPanGestureRecognizer*)sender
{
    CGPoint p = [sender translationInView:self.superview];
    
    static CGFloat tmpR = 1; //临时缩放值
    static CGFloat tmpA = 0; //临时旋转值
    if(sender.state == UIGestureRecognizerStateBegan){
        //表情view中的缩放按钮相对与表情view父视图中的位置
        _initialPoint = [self.superview convertPoint:self.rotatoPressKey.center fromView:self.rotatoPressKey.superview];
        
        CGPoint p = CGPointMake(_initialPoint.x - self.center.x, _initialPoint.y - self.center.y);
        //缩放按钮中点与表情view中点的直线距离
        tmpR = sqrt(p.x*p.x + p.y*p.y); //开根号
        //缩放按钮中点与表情view中点连线的斜率角度
        tmpA = atan2(p.y, p.x);//反正切函数
        
        _initialArg = _arg;
        _initialScale = _scale;
    }
    
    p = CGPointMake(_initialPoint.x + p.x - self.center.x, _initialPoint.y + p.y - self.center.y);
    CGFloat R = sqrt(p.x*p.x + p.y*p.y); //拖动后的距离
    CGFloat arg = atan2(p.y, p.x);    // 拖动后的旋转角度
    //旋转角度
    _arg   = _initialArg + arg - tmpA; //原始角度+拖动后的角度 - 拖动前的角度
    //放大缩小的值
    [self setScale:MAX(_initialScale * R / tmpR, 0.2)];
    
     [self setNeedsDisplay];
}
#pragma mark -  删除
- (void)clickDeleteBtn:(UIButton *)sender{
    THEmoticonView *nextTarget = nil;
    
    const NSInteger index = [self.superview.subviews indexOfObject:self];
    
    for(NSInteger i=index+1; i<self.superview.subviews.count; ++i){
        UIView *view = [self.superview.subviews objectAtIndex:i];
        if([view isKindOfClass:[THEmoticonView class]]){
            nextTarget = (THEmoticonView *)view;
            break;
        }
    }
    
    if(nextTarget==nil){
        for(NSInteger i=index-1; i>=0; --i){
            UIView *view = [self.superview.subviews objectAtIndex:i];
            if([view isKindOfClass:[THEmoticonView class]]){
                nextTarget = (THEmoticonView *)view;
                break;
            }
        }
    }
    [[self class] setActiveEmoticonView:nextTarget];
    [self removeFromSuperview];
}
#pragma mark =================== set方法 ====================
-(void)setIndexTag:(NSInteger)indexTag{
    _indexTag = indexTag;
    self.imageView.tag = indexTag;
}

-(void)setTitleStr:(NSString *)titleStr{
    _titleStr = titleStr;
}

- (void)setAvtive:(BOOL)active{
    _deleteButton.hidden = !active;
    self.rotatoPressKey.hidden = !active;
    self.dashedBoarder.hidden = !active;
    self.editPressKey.hidden = !active;
}

- (void)setScale:(CGFloat)scale{
    _scale = scale;
    self.transform = CGAffineTransformIdentity;
    self.imageView.transform = CGAffineTransformMakeScale(_scale, _scale); //缩放
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (self.imageView.width + kDeleteBtnSize*2)) / 2;
    rct.origin.y += (rct.size.height - (self.imageView.height + kDeleteBtnSize*2)) / 2;
    rct.size.width  = self.imageView.width + kDeleteBtnSize*2;
    rct.size.height = self.imageView.height + kDeleteBtnSize*2;
    self.frame = rct;
    self.imageView.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    self.transform = CGAffineTransformMakeRotation(_arg); //旋转
    
    self.fontSize = self.orignalFontSize*scale;
    //    NSLog(@"============ %f",self.fontSize);
}
-(void)setOrignalFontSize:(CGFloat)orignalFontSize{
    _orignalFontSize = orignalFontSize;
    _fontSize = orignalFontSize;
}

+ (void)setActiveEmoticonView:(THEmoticonView*)view
{
    static THEmoticonView *activeView = nil;
    if(view != activeView){
        [activeView setAvtive:NO]; //隐藏上一个表情的线和按钮
        activeView = view;
        //显示当前表情的线和按钮
        [activeView setAvtive:YES];
        //显示在最上层
        [activeView.superview bringSubviewToFront:activeView];
    }
}

#pragma mark =================== 单利初始化 ====================
- (CAShapeLayer *)dashedBoarder {
    if (_dashedBoarder == nil) {
        _dashedBoarder = [CAShapeLayer layer];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = @1.0;
        animation.toValue = @0.3;
        animation.autoreverses = YES;
        animation.duration = 0.5;
        animation.removedOnCompletion = NO;
        animation.repeatCount = MAXFLOAT;
        animation.fillMode = @"forwards";
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [_dashedBoarder addAnimation:animation forKey:@"opacity"];
    }
    return _dashedBoarder;
}
#pragma mark =================== 系统方法 ====================

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.dashedBoarder.bounds = self.imageView.bounds;
    self.dashedBoarder.position = CGPointMake(CGRectGetMidX(self.imageView.bounds), CGRectGetMidY(self.imageView.bounds));
    self.dashedBoarder.path = [UIBezierPath bezierPathWithRect:self.imageView.bounds].CGPath;
    self.dashedBoarder.lineWidth = 1.0;
    self.dashedBoarder.lineCap = @"round";
    self.dashedBoarder.lineDashPattern = @[@4, @2];
    self.dashedBoarder.fillColor = [UIColor clearColor].CGColor;
    self.dashedBoarder.strokeColor = [UIColor redColor].CGColor;
    [self.imageView.layer insertSublayer:self.dashedBoarder atIndex:0];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat ratio = (CGRectGetWidth(self.bounds )-kDeleteBtnSize)/ CGRectGetWidth(self.imageView.frame);
    
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, ratio, ratio);
    self.imageView.center = CGPointMake(CGRectGetWidth(self.bounds )/ 2, CGRectGetHeight(self.bounds) / 2);
    _deleteButton.center = self.imageView.frame.origin;
    self.editPressKey.center = CGPointMake(CGRectGetWidth(self.imageView.frame)+self.imageView.frame.origin.x, self.imageView.frame.origin.y);
    self.rotatoPressKey.center = CGPointMake(CGRectGetWidth(self.imageView.frame)+self.imageView.frame.origin.x, self.imageView.frame.origin.y+CGRectGetHeight(self.imageView.frame));
}
@end
