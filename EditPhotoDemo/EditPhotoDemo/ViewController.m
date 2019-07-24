//
//  ViewController.m
//  EditPhotoDemo
//
//  Created by damai on 2019/7/12.
//  Copyright © 2019 xingliang. All rights reserved.
//

#import "ViewController.h"
#import "ImageEditorViewController.h"
#import "THEmoticonView.h"
#import "UIView+Frame.h"

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    UIImage *imageTemp;
   
}
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageV;

@property (nonatomic, strong) NSArray  *textViews;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)selectImage:(id)sender {
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    if([UIImagePickerController isSourceTypeAvailable:type]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = NO;
        picker.delegate   = self;
        picker.sourceType = type;
        [self presentViewController:picker animated:YES completion:nil];
    }
}
#pragma mark- ImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
   
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    ImageEditorViewController *editor = [[ImageEditorViewController alloc] init];
    editor.image = image;
    imageTemp = image;
    self.imageV.image = image;
    editor.imageBlock = ^(NSArray * _Nonnull textArr, UIView * _Nonnull workView) {
        
        [self dismissViewControllerAnimated:YES completion:^{

            self.textViews = textArr;
            UIImage *image = [self currentImage];
            self.imageV.image = image;
        }];
    };
    [picker pushViewController:editor animated:YES];
}
- (UIImage *)currentImage {
    
    UIImage *image = imageTemp;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.imageV.width, self.imageV.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    for (THEmoticonView *obj in self.textViews) {
        [imageView addSubview:obj];
    }
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, imageView.opaque, 0.0);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
