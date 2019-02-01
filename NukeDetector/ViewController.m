//
//  ViewController.m
//  NukeDetector
//
//  Created by GuanZhenwei on 2018/5/28.
//  Copyright © 2018年 GuanZhenwei. All rights reserved.
//

// (🍌和🍎)
// 目前这里使用的是外勤365的图片训练得到的分类器，大小100kb左右。7个分类，6000+张图片。

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
//#import "Nudity.h"
#import "ImageClassifier.h"

#define kImageSize 299.0f

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerController *_imagePickerController;
}

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@property (strong, nonatomic) UIImageView *imgView;

@end

@implementation ViewController
- (IBAction)getPhoto:(id)sender
{
    // 创建一个警告控制器
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选取图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    // 设置警告响应事件
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 设置照片来源为相机
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        // 设置进入相机时使用前置或后置摄像头
        _imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        
        // 展示选取照片控制器
        [self presentViewController:_imagePickerController animated:YES completion:^{}];
    }];
    UIAlertAction *photosAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

        [self presentViewController:_imagePickerController animated:YES completion:^{}];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // 添加警告按钮
        [alert addAction:cameraAction];
    }
    [alert addAction:photosAction];
    [alert addAction:cancelAction];
    // 展示警告控制器
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // setup
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    _imagePickerController.allowsEditing = YES;
    
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 100, kImageSize, kImageSize)];
    [self.view addSubview:self.imgView];
}

// caution: Very likely a distortion here!
- (UIImage *)normalizedImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(CGSizeMake(kImageSize, kImageSize));
    [image drawInRect:CGRectMake(0, 0, kImageSize, kImageSize)];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (CVPixelBufferRef)pixelBufferFromImage:(UIImage *)image
{
    CGImageRef cgRef = image.CGImage;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    // nukeD model要求kImageSize*kImageSize的输入！
    CGFloat frameWidth = kImageSize;
    CGFloat frameHeight = kImageSize;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGAffineTransform flipVertical = CGAffineTransformMake( 1, 0, 0, -1, 0, CGImageGetHeight(cgRef));
    CGContextConcatCTM(context, flipVertical);
    CGAffineTransform flipHorizontal = CGAffineTransformMake( -1.0, 0.0, 0.0, 1.0, CGImageGetWidth(cgRef), 0.0);
    CGContextConcatCTM(context, flipHorizontal);
    
    //CGContextConcatCTM(context, CGAffineTransformIdentity);
    
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       cgRef);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image)
    {
        ImageClassifier *model = [[ImageClassifier alloc] init];
        UIImage *normalizedImg = [self normalizedImage:image];
        self.imgView.image = normalizedImg;
        CVPixelBufferRef pbR = [self pixelBufferFromImage:normalizedImg];
        CVPixelBufferRetain(pbR);
        ImageClassifierOutput *outPut = [model predictionFromImage:pbR error:NULL];
        NSDictionary *resultProb = outPut.classLabelProbs;
        NSLog(@"%@",resultProb);
        
        NSString *maxProbClass;
        float maxProb = 0;
        for (NSString *className in resultProb)
        {
            float prob = [resultProb[className] doubleValue];
            if (prob > maxProb)
            {
                maxProb = prob;
                maxProbClass = className;
            }
        }
        
        if (maxProb > 0.7)
        {
            self.resultLabel.text = [NSString stringWithFormat:@"照片鉴定结果为%@，可信度达到%.2f%%", maxProbClass, maxProb*100];
        }
        else
        {
            self.resultLabel.text = @"很抱歉，我们不认识这个图片";
        }
    
        /* these are nuke detector logics! we need new ones!!!
        // refresh Label with result.
        if ([outPut.classLabel isEqualToString:@"SFW"])
        {
            // 结果为nsnumber，稍作处理一下！
            NSInteger resultValue = [resultProb[@"SFW"] doubleValue]*10000;
            float resultFloat = resultValue/100.0f;
            // 非裸露
            self.resultLabel.text = [NSString stringWithFormat:@"鉴定结果为正常，可信度达到%.2f%%", resultFloat];
        }
        else if ([outPut.classLabel isEqualToString:@"NSFW"])
        {
            // 结果为nsnumber，稍作处理一下！
            NSInteger resultValue = [resultProb[@"NSFW"] doubleValue]*10000;
            float resultFloat = resultValue/100.0f;
            // 裸露
            self.resultLabel.text = [NSString stringWithFormat:@"照片鉴定结果为黄图，可信度达到%.2f%%", resultFloat];
        }
        else
        {
            self.resultLabel.text = @"照片鉴定失败，出现未知错误";
        }
         */
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
