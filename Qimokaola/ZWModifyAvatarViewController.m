//
//  ZWAvatarViewController.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/19.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWModifyAvatarViewController.h"
#import "ZWAPITool.h"
#import "ZWUserManager.h"
#import "ZWHUDTool.h"
#import "ZWPathTool.h"
#import <UMCommunitySDK/UMComDataRequestManager.h>

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <YYKit/YYKit.h>

@interface ZWModifyAvatarViewController () <UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *avatarView;

@end

@implementation ZWModifyAvatarViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.title = @"头像";
    
    
    UIBarButtonItem *modifyAvatarItem = [[UIBarButtonItem alloc] initWithTitle:@"•••" style:UIBarButtonItemStyleDone target:self action:@selector(showModifyAvatarWay)];
    self.navigationItem.rightBarButtonItem = modifyAvatarItem;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.backgroundColor = defaultBackgroundColor;
    _scrollView.maximumZoomScale = 3;
    _scrollView.minimumZoomScale = 1;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.userInteractionEnabled = YES;
    UITapGestureRecognizer *doubleTapToZoom = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapToZoom.numberOfTapsRequired = 2;
    [_avatarView addGestureRecognizer:doubleTapToZoom];
    [_scrollView addSubview:_avatarView];
    
    [_avatarView setImageURL:[NSURL URLWithString:self.avatarUrl]];
    
    // 监听图片，当设置新的有效图片时处理大小
    @weakify(self)
    [RACObserve(_avatarView, image) subscribeNext:^(YYImage *image) {
        @strongify(self)
        if (image) {
            
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            CGFloat maxHeight = self.scrollView.bounds.size.height;
            CGFloat maxWidth = self.scrollView.bounds.size.width;
            //如果图片尺寸大于view尺寸，按比例缩放
            if (width > maxWidth || height>width){
                CGFloat ratio = height / width;
                CGFloat maxRatio = maxHeight / maxWidth;
                if(ratio < maxRatio){
                    width = maxWidth;
                    height = width*ratio;
                }else{
                    height = maxHeight;
                    width = height / ratio;
                }
            } else {
                CGFloat ratio = height / width;
                width = maxWidth;
                height = width * ratio;
            }
            self.avatarView.frame = CGRectMake((maxWidth-width) / 2, (maxHeight-height) /2, width, height);
            // 使图片得意显示全部
            self.scrollView.contentOffset = CGPointZero;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Common Methods

- (void)showModifyAvatarWay {
    __weak __typeof(self) weakSelf = self;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    if (self.avatarViewType == ZWAvatarViewControllerTypeSelf) {
        UIAlertAction *fromCameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf selectedImage:0];
        }];
        UIAlertAction *fromPickerAction = [UIAlertAction actionWithTitle:@"从相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf selectedImage:1];
        }];
        [alertController addAction:fromCameraAction];
        [alertController addAction:fromPickerAction];
    }
    UIAlertAction *saveToAlbumAction = [UIAlertAction actionWithTitle:@"保存至相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageWriteToSavedPhotosAlbum(weakSelf.avatarView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }];
    [alertController addAction:saveToAlbumAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *result = error ? @"保存失败" : @"已存入手机相册";
    [ZWHUDTool showHUDInView:self.navigationController.view withTitle:result message:nil duration:kShowHUDShort];
}

/**
 *  @author Administrator, 16-07-15 17:07:18
 *
 *  选取图片
 *
 *  @param getImageWay 选取图片方式 0-拍照 1-相册
 */
- (void)selectedImage:(NSInteger)getImageWay {
    
    if (getImageWay == 0 && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [ZWHUDTool showHUDWithTitle:@"出现错误" message:@"未能检测到相机，请重试" duration:kShowHUDMid];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.sourceType = getImageWay == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recongnizer
{
    UIGestureRecognizerState state = recongnizer.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            //以点击点为中心，放大图片
            CGPoint touchPoint=[recongnizer locationInView:recongnizer.view];
            BOOL zoomOut= self.scrollView.zoomScale == self.scrollView.minimumZoomScale;
            CGFloat scale = zoomOut ? self.scrollView.maximumZoomScale : self.scrollView.minimumZoomScale;
            [UIView animateWithDuration:0.3 animations:^{
                self.scrollView.zoomScale = scale;
                if(zoomOut){
                    CGFloat x = touchPoint.x*scale - self.scrollView.bounds.size.width / 2;
                    CGFloat maxX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
                    CGFloat minX = 0;
                    x= x > maxX ? maxX : x;
                    x= x< minX ? minX : x;
                    
                    CGFloat y = touchPoint.y*scale-self.scrollView.bounds.size.height / 2;
                    CGFloat maxY = self.scrollView.contentSize.height-self.scrollView.bounds.size.height;
                    CGFloat minY = 0;
                    y= y > maxY ? maxY : y;
                    y= y < minY ? minY : y;
                    self.scrollView.contentOffset = CGPointMake(x, y);
                }
            }];
            
        }
            break;
        default:break;
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.avatarView;
}

//缩放后让图片显示到屏幕中间
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGSize originalSize=_scrollView.bounds.size;
    CGSize contentSize=_scrollView.contentSize;
    CGFloat offsetX=originalSize.width>contentSize.width?(originalSize.width-contentSize.width)/2:0;
    CGFloat offsetY=originalSize.height>contentSize.height?(originalSize.height-contentSize.height)/2:0;
    self.avatarView.center = CGPointMake(contentSize.width/2+offsetX, contentSize.height/2+offsetY);
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    __weak __typeof(self) weakSelf = self;
    UIImage *selectedImage = [info[UIImagePickerControllerEditedImage] imageByResizeToSize:CGSizeMake(320, 320)];
    // 将所选图片写进文件，以便上传使用
    NSString *avatarFileName = @"avatar.jpeg";
    NSData *imageData = UIImageJPEGRepresentation(selectedImage, 0.3);
    NSString *avatarPath = [[ZWPathTool avatarDirectory] stringByAppendingPathComponent:avatarFileName];
    NSURL *avatarFileURL = [NSURL fileURLWithPath:avatarPath];
    [imageData writeToURL:avatarFileURL atomically:YES];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        MBProgressHUD *hud = [ZWHUDTool excutingHudInView:weakSelf.navigationController.view title:@"正在上传"];
        // 上传图片
        [ZWAPIRequestTool requestUploadAvatarWithParamsters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileURL:avatarFileURL name:@"avatar" fileName:avatarFileName mimeType:@"image/jpeg" error:NULL];
        } result:^(id response, BOOL success) {
            if (success && [[response objectForKey:kHTTPResponseCodeKey] intValue] == 0) {
                // 同步学生圈社区头像
                [[UMComDataRequestManager defaultManager] userUpdateAvatarWithImage:selectedImage completion:^(NSDictionary *responseObject, NSError *error) {
                    
                }];
                weakSelf.avatarView.image = selectedImage;
                [[ZWUserManager sharedInstance] updateAvatarUrl:[[response objectForKey:kHTTPResponseResKey] objectForKey:@"avatar"]];
                if (weakSelf.completion) {
                    weakSelf.completion();
                }
                hud.mode = MBProgressHUDModeCustomView;
                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
                hud.label.text = @"修改成功";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDShort * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES];
                });
            } else {
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"修改失败";
                [hud hideAnimated:YES afterDelay:kShowHUDMid];
            }
        }];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
