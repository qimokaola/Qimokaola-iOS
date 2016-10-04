//
//  ZWNewFeedViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/9/5.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWFeedComposeViewController.h"
#import "ZWFeedComposeTextParser.h"
#import "UIView+Extension.h"
#import "WBTextLinePositionModifier.h"
#import "WBStatusHelper.h"
#import "WBEmoticonInputView.h"
#import "ZWHUDTool.h"
#import "UMImagePickerController.h"
#import "UMComAddedImageView.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "IQKeyboardManager.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>

#define kToolBarHeight 46
#define kToolBarSubViewSize 25
#define kToolBarSubViewMargin 25

@interface ZWFeedComposeViewController () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) YYTextView *textView;
@property (nonatomic, strong) UIView *toolbar;
@property (nonatomic, strong) UIButton *toolbarPictureButton;
@property (nonatomic, strong) UISwitch *anonyousSwitch;
@property (nonatomic, strong) UILabel *anonymousLabel;
@property (nonatomic, strong) UMComBriefAddedImageView *addImgView;
@property (nonatomic, strong) NSMutableArray *images;

@end

@implementation ZWFeedComposeViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = universalGrayColor;
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UIBarButtonItem *leftCancleItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(canclePostNewFeed)];
    self.navigationItem.leftBarButtonItem = leftCancleItem;
    UIBarButtonItem *rightPostItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(postNewFeed)];
    self.navigationItem.rightBarButtonItem = rightPostItem;
    
    if (self.composeType == ZWFeedComposeTypeNewFeed) {
        self.title = @"新鲜事";
    } else {
        self.title = @"发评论";
    }
    _images = [NSMutableArray array];
    [self zw_addSubViews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
     [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Loading


#pragma mark - Common Methods

- (void)zw_addSubViews {
    [self initTextView];
    [self initToolBar];
    if (_composeType == ZWFeedComposeTypeNewFeed) {
        [self initPhotoAttachmentView];
    }
}

- (void)initTextView {
    __weak __typeof(self) weakSelf = self;
   
    _textView = [[YYTextView alloc] init];
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.textContainerInset = UIEdgeInsetsMake(12, 16, 12, 16);
    _textView.contentInset  = UIEdgeInsetsMake(64, 0, 0, 0);
    _textView.showsVerticalScrollIndicator = NO;
    _textView.alwaysBounceVertical = YES;
    _textView.allowsCopyAttributedString = NO;
    _textView.font = ZWFont(17);
    // 设置行间距
    CGFloat lineSpacing = 3.f;
    const CFIndex kNumberOfSettings = 3;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing }
    };
    CTParagraphStyleRef theParagraphStyle = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    _textView.typingAttributes = @{NSParagraphStyleAttributeName : (id)theParagraphStyle};
    CFRelease(theParagraphStyle);
    NSString *placeholderPlainText = nil;
    switch (_composeType) {
        case ZWFeedComposeTypeNewFeed: {
            placeholderPlainText = @"分享新鲜事...";
        }
            break;
        case ZWFeedComposeTypeReplyComment:
        case ZWFeedComposeTypeReplyFeed: {
            placeholderPlainText = @"写评论...";
        }
            break;
    }
    if (placeholderPlainText) {
        NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:placeholderPlainText];
        atr.color = UIColorHex(b4b4b4);
        atr.font = [UIFont systemFontOfSize:17];
        _textView.placeholderAttributedText = atr;
    }
    [self.view addSubview:_textView];
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(weakSelf.view);
        make.height.equalTo(weakSelf.view).multipliedBy(0.4);
    }];
    [_textView becomeFirstResponder];
}

- (void)initToolBar {
    __weak __typeof(self) weakSelf = self;
    _toolbar = [[UIView alloc] init];
    _toolbar.backgroundColor = UIColorHex(F9F9F9);
    [self.view addSubview:_toolbar];
    [_toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.textView.mas_bottom);
        make.height.mas_equalTo(kToolBarHeight);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = UIColorHex(BFBFBF);
    [_toolbar addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(weakSelf.toolbar);
        make.height.mas_equalTo(0.5);
    }];
    
    
    if (_composeType == ZWFeedComposeTypeNewFeed) {
        _toolbarPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toolbarPictureButton setBackgroundImage:[UIImage imageNamed:@"compose_toolbar_picture"] forState:UIControlStateNormal];
        [_toolbarPictureButton setBackgroundImage:[UIImage imageNamed:@"compose_toolbar_picture_highlighted"] forState:UIControlStateHighlighted];
        [_toolbarPictureButton addTarget:self action:@selector(showGetPicWay) forControlEvents:UIControlEventTouchUpInside];
        [_toolbar addSubview:_toolbarPictureButton];
        [_toolbarPictureButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kToolBarSubViewSize, kToolBarSubViewSize));
            make.centerY.equalTo(weakSelf.toolbar);
            make.left.equalTo(weakSelf.toolbar).with.offset(kToolBarSubViewMargin);
        }];
    }
    
    
    _anonyousSwitch = [[UISwitch alloc] init];
    _anonyousSwitch.on = YES;
    [_toolbar addSubview:_anonyousSwitch];
    [_anonyousSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.toolbar);
        make.right.equalTo(weakSelf.toolbar).with.offset(- kToolBarSubViewMargin / 2);
    }];
    _anonyousSwitch.transform = CGAffineTransformMakeScale(0.85, 0.85);
    
    _anonymousLabel = [[UILabel alloc] init];
    _anonymousLabel.numberOfLines = 1;
    _anonymousLabel.font = ZWFont(15);
    _anonymousLabel.textColor = [UIColor blackColor];
    _anonymousLabel.text = @"匿名: ";
    [_anonymousLabel sizeToFit];
    [_toolbar addSubview:_anonymousLabel];
    [_anonymousLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.anonyousSwitch.mas_left).with.offset(- 5);
        make.centerY.equalTo(weakSelf.toolbar);
    }];
}

- (void)initPhotoAttachmentView {
    __weak __typeof(self) weakSelf = self;
    _addImgView = [[UMComBriefAddedImageView alloc] init];
    [self.view addSubview:_addImgView];
    [_addImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.toolbar.mas_bottom);
        make.width.equalTo(weakSelf.view);
        make.height.mas_equalTo(90);
    }];
    
    CGFloat g_template_AddImageViewItemSize = 60.f;
    CGFloat g_template_AddImageViewImageSpace = 15.f;
    self.addImgView.itemSize = CGSizeMake(g_template_AddImageViewItemSize, g_template_AddImageViewItemSize);
    self.addImgView.imageSpace = g_template_AddImageViewImageSpace;
    
    self.addImgView.isAddImgViewShow = NO;
    self.addImgView.normalAddImg = [UIImage imageNamed:@"um_com_edit_add"];
    self.addImgView.highlightedAddImg = [UIImage imageNamed:@"um_com_edit_add_click"];
    self.addImgView.deleteImg =  [UIImage imageNamed:@"um_com_edit_delete"];
    [self.addImgView addImages:[NSArray array]];
    
    [self.addImgView setPickerAction:^{
        [weakSelf.textView resignFirstResponder];
        [weakSelf showGetPicWay];
    }];
    self.addImgView.imagesChangeFinish = ^(){
        [weakSelf updateImageAddedImageView];
    };
    self.addImgView.imagesDeleteFinish = ^(NSInteger index){
        [weakSelf.images removeObjectAtIndex:index];
    };
}

- (void)updateImageAddedImageView
{
    [self viewsFrameChange];
}

- (void)showGetPicWay {
    __weak __typeof(self) weakSelf = self;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择图片源" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *fromCameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf takePhoto:nil];
    }];
    UIAlertAction *fromPickerAction = [UIAlertAction actionWithTitle:@"从相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setUpPicker];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:fromCameraAction];
    [alertController addAction:fromPickerAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)takePhoto:(id)sender {
    __weak __typeof(self) weakSelf = self;
    if(self.images.count >= 9){
        [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"最多只能选择九张图片哦" message:nil duration:kShowHUDMid];
        return;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
            [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"本应用无访问照片的权限，如需访问，可在设置中修改" message:nil duration:kShowHUDMid];
            return;
        }
    }else{
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied)
        {
            [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"本应用无访问照片的权限，如需访问，可在设置中修改" message:nil duration:kShowHUDMid];
            return;
        }
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }
}

- (void)setUpPicker
{
    __weak __typeof(self) weakSelf = self;
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied)
    {
        [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"本应用无访问照片的权限，如需访问，可在设置中修改" message:nil duration:kShowHUDMid];
        return;
    }
    if([UMImagePickerController isAccessible])
    {
        UMImagePickerController *imagePickerController = [[UMImagePickerController alloc] initWithBackImage:[UIImage imageNamed:@"um_forum_back_gray"]];
        imagePickerController.minimumNumberOfSelection = 1;
        imagePickerController.maximumNumberOfSelection = 9 - [self.addImgView.arrayImages count];
        
        [imagePickerController setFinishHandle:^(BOOL isCanceled,NSArray *assets){
            if(!isCanceled)
            {
                [self dealWithAssets:assets];
            }
        }];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}

- (void)dealWithAssets:(NSArray *)assets
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray *array = [NSMutableArray array];
        for(ALAsset *asset in assets)
        {
            UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
            if (image) {
                [array addObject:image];
            }
            if ([asset defaultRepresentation]) {
                //这里把图片压缩成fullScreenImage分辨率上传，可以修改为fullResolutionImage使用原图上传
                UIImage *originImage = [UIImage
                                        imageWithCGImage:[asset.defaultRepresentation fullScreenImage]
                                        scale:[asset.defaultRepresentation scale]
                                        orientation:UIImageOrientationUp];
                if (originImage) {
                    [self.images addObject:originImage];
                }
            } else {
                UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
                image = [self compressImage:image];
                if (image) {
                    [self.images addObject:image];
                }
            }
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleOriginImages:array];
        });
    });
}

- (UIImage *)compressImage:(UIImage *)image
{
    UIImage *resultImage  = image;
    if (resultImage.CGImage) {
        NSData *tempImageData = UIImageJPEGRepresentation(resultImage,0.9);
        if (tempImageData) {
            resultImage = [UIImage imageWithData:tempImageData];
        }
    }
    return image;
}

- (void)handleOriginImages:(NSArray *)images{
    
    // [self.images addObjectsFromArray:images];//zhangjunhua_删除，回调前，已经加入
    [self.addImgView addImages:images];
    [self viewsFrameChange];
    
}


-(void)viewsFrameChange
{
    __weak __typeof(self) weakSelf = self;
    _addImgView.hidden = self.images.count <= 0;
    [_addImgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(weakSelf.addImgView.frame.size.height);
    }];
}


- (void)canclePostNewFeed {
    if (_textView.text.length == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"退出此次编辑,内容将丢失!" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakself = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
 @param content Feed的内容
 @param title 标题
 @param location 位置
 @param locationName 地理位置名称
 @param related_uids @用户
 @param topic_ids 话题ID数组
 @param images 图片数组
 @param type 类型（0表示普通，1表示公告，只有管理员才有权限发表公告）
 @param custom 自定义字段
 @param completion 请求回调block，参考 'UMComRequestCompletion'
 @return 返回空
 */
- (void)postNewFeed {
    [_textView resignFirstResponder];
    if (_textView.text.length == 0 || _textView.text.length > 300) {
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"内容长度必须在1-300" message:nil duration:kShowHUDMid];
        return;
    }
    __weak __typeof(self) weakSelf = self;
    NSString *anonyousString = [NSString stringWithFormat:@"{\"a\" : %d}", _anonyousSwitch.on ? 1 : 0];
    MBProgressHUD *hud = [ZWHUDTool excutingHudInView:self.navigationController.view title:@"正在发送"];
    if (_composeType == ZWFeedComposeTypeNewFeed) {
        [UMComDataRequestManager feedCreateWithContent:_textView.text
                                                 title:nil
                                              location:nil
                                          locationName:nil
                                          related_uids:nil
                                             topic_ids:@[_topicID]
                                                images:self.images
                                                  type:@0
                                                custom:anonyousString
                                            completion:^(NSDictionary *responseObject, NSError *error) {
                                                [weakSelf dealWithTheResult:responseObject error:error hud:hud];
                                                
                                            }];
    } else {
        // 回复 Feed 或者回复评论
        [[UMComDataRequestManager defaultManager] commentFeedWithFeedID:_feedID
                                                         commentContent:_textView.text
                                                         replyCommentID:_composeType == ZWFeedComposeTypeReplyComment ? _commentID : nil
                                                            replyUserID:nil
                                                   commentCustomContent:anonyousString
                                                                 images:nil
                                                             completion:^(NSDictionary *responseObject, NSError *error) {
                                                                 [weakSelf dealWithTheResult:responseObject error:error hud:hud];
                                                             }];
    }
}

- (void)dealWithTheResult:(NSDictionary *)responseObject error:(NSError *)error hud:(MBProgressHUD *)hud {
    __weak __typeof(self) weakSelf = self;
    if (responseObject) {
        NSLog(@"%@", responseObject[@"data"]);
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
        hud.square = YES;
        hud.label.text = @"发送成功";
        hud.detailsLabel.text = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDShort * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                if (weakSelf.completion) {
                    weakSelf.completion(responseObject[@"data"]);
                }
            }];
        });
    } else {
        NSLog(@"%@", error);
        hud.mode = MBProgressHUDModeText;
        if (error.code == 20024) {
            hud.label.text = @"短时间内不可多次发送同样内容";
        } else {
            hud.label.text = @"发送失败,请重试";
        }
        hud.detailsLabel.text = nil;
        [hud hideAnimated:YES afterDelay:kShowHUDShort];
    }
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *selectImage = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *tempImage = nil;
    if (selectImage.imageOrientation != UIImageOrientationUp) {
        UIGraphicsBeginImageContext(selectImage.size);
        [selectImage drawInRect:CGRectMake(0, 0, selectImage.size.width, selectImage.size.height)];
        tempImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }else{
        tempImage = selectImage;
    }
    if (self.images.count < 9) {
        [self.images addObject:tempImage];
        [self handleOriginImages:@[tempImage]];
    }
}

#pragma mark - UITextViewDelegate

//- (void)textViewDidChange:(UITextView *)textView {
//    //[textView scrollToBottom];
//}


@end
