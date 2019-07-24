//
//  ImageEditorViewController.m
//  EditPhotoDemo
//
//  Created by damai on 2019/7/12.
//  Copyright © 2019 xingliang. All rights reserved.
//

#import "ImageEditorViewController.h"
#import "SelectView.h"
#import "THEmoticonView.h"
#import "UIView+Frame.h"

#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenwidth (kScreenBounds.size.width)
#define kScreenheight (kScreenBounds.size.height)

@interface ImageEditorViewController ()<THTextViewDelegate>{
    
}
@property (weak, nonatomic) IBOutlet UIButton *textBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (nonatomic, strong) NSMutableArray<THEmoticonView *> *textViews;


@property (nonatomic, assign) NSInteger   index;
@property (nonatomic, strong) UIView *workingView;;          //工作区
@end

@implementation ImageEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textViews = [NSMutableArray array];
    self.imageV.image = self.image;
    self.index = 0;
    self.workingView = [[UIView alloc] initWithFrame:[self.view convertRect:self.imageV.frame fromView:self.imageV.superview]];
    self.workingView.clipsToBounds = YES;
    [self.view addSubview:self.workingView];
    
    self.bottomView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    [self.view bringSubviewToFront:self.bottomView];
    [self.view bringSubviewToFront:self.textBtn];
    [self.view bringSubviewToFront:self.doneBtn];
    
    self.workingView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Action:)];
    [self.workingView addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeText:) name:@"kTextViewActiveViewDidTapNotification" object:nil];
    
}
- (void)changeText:(NSNotification *)note{
    
    THEmoticonView *moticonView = note.object;

    SelectView *view = [[NSBundle mainBundle]loadNibNamed:@"SelectView" owner:self options:nil].firstObject;
    [view showWithText:moticonView.titleStr Color:moticonView.textColor Block:^(UITextView *textV) {
        if (textV.text.length==0) {
            return ;
        }
        for ( int i = 0;i<self.workingView.subviews.count;i++ ) {
   
            THEmoticonView *object = self.workingView.subviews[i];
            if (object.indexTag ==moticonView.indexTag) {
                
                object.fontSize =  object.fontSize>11? object.fontSize:11;
                textV.font = [UIFont systemFontOfSize:object.fontSize];
                UITextView *viewTemp = [[UITextView alloc]initWithFrame:CGRectMake(10, 0, kScreenwidth-20-50, kScreenheight)];
                viewTemp.text = textV.text;
                viewTemp.font = [UIFont systemFontOfSize:object.fontSize];
                [viewTemp sizeToFit];
               CGRect frame = textV.frame ;
                frame.size.width = viewTemp.frame.size.width;
                frame.size.height = viewTemp.frame.size.height;
                textV.frame = frame;
                
                UIImage *image = [self imageForView:textV];
                UIButton *btn = [[UIButton alloc]init];
                [btn setTitle:textV.text forState:UIControlStateNormal ] ;
                [btn setImage:image forState:UIControlStateNormal];
                btn.frame = CGRectMake(object.frame.origin.x, object.frame.origin.y, image.size.width, image.size.height);
                THEmoticonView *view1 = [[THEmoticonView alloc] initWithButton:btn];
                view1.delegate = self;
                view1.textColor = textV.textColor;
                view1.titleStr = textV.text;
                view1.transform = object.transform;
                view1.center = object.center;
                view1.orignalFontSize = object.fontSize;
                view1.indexTag = object.indexTag;
                [object removeFromSuperview];
                [self.textViews removeObject:object];
                [self.workingView addSubview:view1];
                [self.textViews addObject:view1];
                [THEmoticonView setActiveEmoticonView:view1];
                
            }
        }
    }];
}

- (void)Action:(UITapGestureRecognizer *)tap{
    
     [THEmoticonView setActiveEmoticonView:nil];
}


- (IBAction)addTextAction:(id)sender {
    
    SelectView *view = [[NSBundle mainBundle]loadNibNamed:@"SelectView" owner:self options:nil].firstObject;
    [view showWithText:@""  Color:[UIColor blackColor] Block:^(UITextView *textV) {
        if (textV.text.length==0) {
            return ;
        }
        UITextView *viewTemp = [[UITextView alloc]initWithFrame:CGRectMake(10, 0, kScreenwidth-20-50, kScreenheight)];
        viewTemp.text = textV.text;
        viewTemp.font = [UIFont systemFontOfSize:16];
        [viewTemp sizeToFit];
        CGRect frame = textV.frame ;
        frame.size.width = viewTemp.frame.size.width;
        frame.size.height = viewTemp.frame.size.height;
        textV.frame = frame;
        UIImage *image = [self imageForView:textV];
        UIButton *btn = [[UIButton alloc]init];
        [btn setTitle:textV.text forState:UIControlStateNormal ] ;
        [btn setImage:image forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        THEmoticonView *view = [[THEmoticonView alloc] initWithButton:btn];
        view.center = CGPointMake(self.workingView.width/2, self.workingView.height/2);
        view.indexTag = self.index;
        view.titleStr = textV.text;
        view.textColor = textV.textColor;
        view.textImage = image;
        view.delegate = self;
        view.orignalFontSize = 16;
        self.index++;
        [self.workingView addSubview:view];
        [self.textViews addObject:view];
        [THEmoticonView setActiveEmoticonView:view];
        
    }];
}
-(UIImage *)imageForView:(UIView *)view{
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    }else{
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (IBAction)doneAction:(id)sender {
    
    [THEmoticonView setActiveEmoticonView:nil];
    if (self.imageBlock) {
        self.imageBlock(self.textViews,self.workingView);
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)filterTextViewEditTexTag:(THEmoticonView *)sender{
    
    for ( int i = 0;i<self.workingView.subviews.count;i++ ) {
        THEmoticonView *object = self.workingView.subviews[i];
        if (object.indexTag ==sender.indexTag) {
            UIButton *btn = [[UIButton alloc]init];
           
            UITextView *viewTemp = [[UITextView alloc]initWithFrame:CGRectMake(10, 0, kScreenwidth-20-50, kScreenheight)];
            viewTemp.text = sender.titleStr;
            viewTemp.font = [UIFont systemFontOfSize:sender.fontSize];
            [viewTemp sizeToFit];
            CGRect frame = sender.frame;
            frame.origin.y = sender.frame.origin.y+sender.frame.size.height/2;
            frame.size.width = viewTemp.frame.size.width;
            frame.size.height = viewTemp.frame.size.height;
            btn.frame = frame;
            [btn setImage:sender.textImage forState:UIControlStateNormal];
            THEmoticonView *view = [[THEmoticonView alloc] initWithButton:btn];
            view.transform = object.transform;
            self.index++;
            view.textColor = sender.textColor;
            view.titleStr = sender.titleStr;
            view.indexTag = self.index;
            view.delegate = self;
            view.orignalFontSize = object.fontSize;
            [self.workingView addSubview:view];
             [self.textViews addObject:view];
            [THEmoticonView setActiveEmoticonView:view];
        }
    }
}
-(void)setImage:(UIImage *)image{
    _image = image;
}
@end
