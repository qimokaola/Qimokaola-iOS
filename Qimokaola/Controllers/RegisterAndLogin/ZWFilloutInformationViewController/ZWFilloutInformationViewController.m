//
//  ZWFilloutInformationViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/7/14.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWFilloutInformationViewController.h"
#import "ZWSelectSchoolViewController.h"
#import "UIColor+Extension.h"
#import "ZWBindAccountViewController.h"
#import "ZWHUDTool.h"
#import "ZWPathTool.h"
#import "ZWAPIRequestTool.h"
#import "ZWUserManager.h"
#import "ZWTabBarController.h"

#import "Masonry.h"
#import "ReactiveCocoa.h"
#import <YYKit/YYKit.h>

@interface ZWFilloutInformationViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

//头像
@property (nonatomic, strong) UIImageView *avatarImageView;
//昵称
@property (nonatomic, strong) UITextField *nicknameField;
//昵称框下划线
@property (nonatomic, strong) UIView *nicknameLine;
//选择学校
@property (nonatomic, strong) UIButton *selectSchoolBtn;
//选择学校下划线
@property (nonatomic, strong) UIView *selectSchoolLine;
//性别男 按钮
@property (nonatomic, strong) UIButton *maleBtn;
//性别女 按钮
@property (nonatomic, strong) UIButton *femaleBtn;
//性别男 标签
@property (nonatomic, strong) UILabel *maleLabel;
//性别女 标签
@property (nonatomic, strong) UILabel *femaleLabel;
//竖直分隔线
@property (nonatomic, strong) UIView *verticalLine;
//性别下划线
@property (nonatomic, strong) UIView *gendarLine;
//下一步 按钮
@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@property (nonatomic, assign) BOOL isAvatarSelected;
@property (nonatomic, assign) BOOL isSchoolSelected;
@property (nonatomic, copy) NSString *collegeID;
@property (nonatomic, strong) NSString *collegeName;
@property (nonatomic, copy) NSString *academyID;
@property (nonatomic, strong) NSString *academyName;
@property (nonatomic, strong) NSNumber *enterYear;

@end

@implementation ZWFilloutInformationViewController

- (AFHTTPSessionManager *)manager {
    if (_manager == nil) {
        _manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    return _manager;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", self.registerParam);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.isAvatarSelected = self.isSchoolSelected = NO;
    
    [self createSubViews];
    
    @weakify(self)
    [[self.selectSchoolBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        ZWSelectSchoolViewController *selectSchool = [[ZWSelectSchoolViewController alloc] init];
        selectSchool.completionBlock = ^(NSDictionary *result) {
            NSDictionary *school = [result objectForKey:@"school"];
            NSDictionary *academy = [result objectForKey:@"academy"];
            self.enterYear = [result objectForKey:@"enterYear"];
            
            self.collegeID = [school objectForKey:@"id"];
            self.collegeName = [school objectForKey:@"name"];
            self.academyID = [academy objectForKey:@"id"];
            self.academyName = [academy objectForKey:@"name"];
            
            self.selectSchoolBtn.titleLabel.font = ZWFont(15);
            
            [self.selectSchoolBtn setTitle:[NSString stringWithFormat:@"%@-%@-%@", [school objectForKey:@"name"], [academy objectForKey:@"name"], self.enterYear.stringValue] forState:UIControlStateNormal];
            [self.selectSchoolBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.isSchoolSelected = YES;
        };
        [self.navigationController pushViewController:selectSchool animated:YES];
    }];
    
    [self.avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickAvatarImage)]];
    
    [[self.maleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
        @strongify(self)
        btn.enabled = NO;
        self.femaleBtn.enabled = YES;
    }];
    
    [[self.femaleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
        @strongify(self)
        btn.enabled = NO;
        self.maleBtn.enabled = YES;
    }];
    
    RAC(self.nextBtn, enabled) = [RACSignal combineLatest:@[
                                                            RACObserve(self, isAvatarSelected),
                                                            RACObserve(self, isSchoolSelected),
                                                            RACObserve(self.nicknameField, text),
                                                            RACObserve(self.maleBtn, enabled),
                                                            RACObserve(self.femaleBtn, enabled)
                                                            ]
                                                   reduce:^id(NSNumber *avatarSelected,
                                                              NSNumber *schoolSelected,
                                                              NSString *text,
                                                              NSNumber *maleBtnEnabled,
                                                              NSNumber *femaleBtnEnabled){
                                                       
                                                       return @(text.length > 0 && [schoolSelected boolValue] && ([maleBtnEnabled boolValue] != [femaleBtnEnabled boolValue]) && [avatarSelected boolValue]);
                                                   }];

    __block MBProgressHUD *hud;
    [[[self.nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^RACStream *(id value) {
        @strongify(self)
        hud = [ZWHUDTool excutingHudInView:self.navigationController.view title:nil];
        return [self checkNicknameValidSignal];
    }] subscribeNext:^(NSDictionary *result) {
        if ([[result objectForKey:kHTTPResponseResKey] allKeys].count == 0) {
            [hud hideAnimated:YES];
            [self registerUser];
        } else {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"该昵称已存在，请换一个";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDShort * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                [self.nicknameField becomeFirstResponder];
            });
        }
    } error:^(NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"出现错误, 请重试";
        [hud hideAnimated:YES afterDelay:kShowHUDShort];
    }];
}

- (RACSignal *)checkNicknameValidSignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [ZWAPIRequestTool reuqestInfoByName:self.nicknameField.text result:^(id response, BOOL success) {
            if (success) {
                [subscriber sendNext:response];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:response];
            }
        }];
        return nil;
    }];
}

- (void)registerUser {
    MBProgressHUD *hud = [ZWHUDTool excutingHudInView:self.navigationController.view title:@"检查用户信息"];
    @weakify(self)
    [[self registerSignal] subscribeNext:^(NSDictionary *result) {
        [hud hideAnimated:YES];
        @strongify(self)
        int resultCode = [[result objectForKey:kHTTPResponseCodeKey] intValue];
        if (resultCode == 0) {
            NSLog(@"注册成功 上传头像图片");
            NSLog(@"%@", result);
            ZWUser *user = [ZWUser modelWithDictionary:[result objectForKey:kHTTPResponseResKey]];
            [ZWUserManager sharedInstance].loginUser = user;
            [self handleUploadAvatarImage];
        } else {
            [ZWHUDTool showHUDInView:self.navigationController.view withTitle:[result objectForKey:kHTTPResponseInfoKey] message:nil duration:kShowHUDShort];
        }
    } error:^(NSError *error) {
        [hud hideAnimated:YES];
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"出现错误，请重试" message:nil duration:kShowHUDShort];
    }];
}

/**
 *  @author Administrator, 16-09-02 23:09:36
 *
 *  注册完后上传用户图像
 */
- (void)handleUploadAvatarImage {
    //__weak __typeof(self) weakSelf = self;
    MBProgressHUD *hud = [ZWHUDTool excutingHudInView:self.navigationController.view title:@"正在准备用户信息"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDMid * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [ZWAPIRequestTool requestUploadAvatarWithParamsters:@{} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSString *fileName = @"avatar.jpeg";
            NSString *avatarPath = [[ZWPathTool avatarDirectory] stringByAppendingPathComponent:fileName];
            NSURL *avatarFileURL = [NSURL fileURLWithPath:avatarPath];
            [formData appendPartWithFileURL:avatarFileURL name:@"avatar" fileName:fileName mimeType:@"image/jpeg" error:NULL];
        } result:^(id response, BOOL success) {
            NSLog(@"%@", response);
            
            if (success) {
                hud.mode = MBProgressHUDModeCustomView;
                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
                hud.square = YES;
                hud.label.text = @"注册成功";
                
                ZWUser *user = [ZWUserManager sharedInstance].loginUser;
                user.avatar_url = [[response objectForKey:kHTTPResponseResKey] objectForKey:@"avatar"];
                NSLog(@"%@", user.avatar_url);
                [ZWUserManager sharedInstance].loginUser = user;
            } else {
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"上传头像出错, 您可以稍后再次上传";
            }
            
            // 发送用户登录成功通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoginSuccessNotification object:nil];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDShort * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                
                // 根据根视图类型决定跳转类型
                if (![[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[ZWTabBarController class]]) {
                    // 若根视图的类型不为 ZWTabBarController ，表明当前位于登录注册视图，则需切换根视图至 ZWTabBarController 显示业务界面
                    ZWTabBarController *tabrBarController = [[ZWTabBarController alloc] init];
                    [UIApplication sharedApplication].keyWindow.rootViewController = tabrBarController;
                } else {
                    // 根视图的类型为 ZWTabBarController, 则只需 dismiss 此 Controller
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            });
            
        }];
    });
}


- (RACSignal *)registerSignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.registerParam];
        NSString *nickname = self.nicknameField.text;
        NSString *gender = self.maleBtn.enabled ? @"女" : @"男";
        [params addEntriesFromDictionary:@{
                                           @"nick": nickname,
                                           @"gender": gender,
                                           @"schoolId" : self.collegeID,
                                           @"academyId": self.academyID,
                                           @"enterYear": self.enterYear
                                           }];
        [params addEntriesFromDictionary:@{
                                           @"schoolUn": @"",
                                           @"schoolPw": @"",
                                           @"version": @1
                                           }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.manager POST:[ZWAPITool registerAPI]
                    parameters:params
                      progress:nil
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                           
                           [subscriber sendNext:responseObject];
                           [subscriber sendCompleted];
                           
                       }
                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                           [subscriber sendError:error];
                           
                       }];
            
        });
        return nil;
    }];
}


- (void)createSubViews {
    
    __weak __typeof(self) weakSelf = self;
    
    CGFloat margin = 10.f;
    CGFloat midMargin = 20.f;
    CGFloat larginMargin = 30.f;
    
    CGFloat commonHeight = 30.f;
    CGFloat smallHeight = 20.f;
    CGFloat lineHeightOrWidth = .5f;
    
    CGFloat cornerRadius = 5.f;
    
    CGFloat avatarSizeRate = .28f;
    
    UIFont *commonFont = ZWFont(17);
    
    
    
    //创建视图并添加至父控件
    self.avatarImageView = ({
        UIImageView *avatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"select_avatar"]];
        avatar.contentMode = UIViewContentModeScaleToFill;
        avatar.layer.cornerRadius = cornerRadius;
        avatar.layer.masksToBounds = YES;
        avatar.userInteractionEnabled = YES;
        avatar.layer.borderColor = RGB(240., 240., 240.).CGColor;
        avatar.layer.borderWidth = 1.f;
        [self.view addSubview:avatar];
        
        avatar;
    });
    
    self.nicknameField = ({
        UITextField *field = [[UITextField alloc] init];
        field.borderStyle = UITextBorderStyleNone;
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        field.font = commonFont;
        field.placeholder = @"输入昵称";
        
        [self.view addSubview:field];
        
        field;
    });
    
    self.nicknameLine = ({
        UIView *view = [self commonLine];
        [self.view addSubview:view];
        
        view;
    });
    
    self.selectSchoolBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.titleLabel.font = commonFont;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn setTitle:@"选择学校，学院" forState:UIControlStateNormal];
        [btn setTitleColor:RGBA(0., 0., 25., 0.22) forState:UIControlStateNormal];
        [self.view addSubview:btn];
        
        btn;
    });
    
    self.selectSchoolLine = ({
        UIView *view = [self commonLine];
        [self.view addSubview:view];
        
        view;
    });
    
    self.maleLabel = ({
        UILabel *label = [self commonLabel];
        label.text = @"男";
        
        [self.view addSubview:label];
        
        label;
    });
    
    self.maleBtn = ({
        UIButton *btn = [self commonBtn];
        [self.view addSubview:btn];
        
        btn;
    });
    
    self.verticalLine = ({
        UIView *view = [self commonLine];
        [self.view addSubview:view];
        
        view;
    });
    
    self.femaleLabel = ({
        UILabel *label = [self commonLabel];
        label.text = @"女";
        [self.view addSubview:label];
        
        label;
    });
    
    self.femaleBtn = ({
        UIButton *btn = [self commonBtn];
        [self.view addSubview:btn];
        
        btn;
    });
    
    self.gendarLine = ({
        UIView *view = [self commonLine];
        [self.view addSubview:view];
        
        view;
    });
    
    self.nextBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[RGB(80., 140., 238.) parseToImage] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIColor lightGrayColor] parseToImage] forState:UIControlStateDisabled];
        [btn setTitle:@"注册" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        
        [self.view addSubview:btn];
        
        btn;
    });
    
    //添加视图约束
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.equalTo(weakSelf.view.mas_width).multipliedBy(avatarSizeRate);
        make.centerY.equalTo(weakSelf.view).multipliedBy(.5f);
        make.centerX.equalTo(weakSelf.view);
    }];
    
    [@[self.nicknameField, self.nicknameLine, self.selectSchoolBtn, self.selectSchoolLine, self.gendarLine, self.nextBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).with.offset(margin);
        make.right.equalTo(weakSelf.view).with.offset(- margin);
    }];
    
    [@[self.nicknameLine, self.selectSchoolLine, self.gendarLine] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(lineHeightOrWidth);
    }];
    
    [@[self.nicknameField, self.selectSchoolBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(commonHeight);
    }];
    
    [@[self.maleLabel, self.maleBtn, self.femaleLabel, self.femaleBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.mas_equalTo(smallHeight);
    }];
    
    [@[self.maleBtn, self.verticalLine, self.femaleLabel, self.femaleBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.maleLabel);
    }];
    
    //以昵称下划线位置为中心位置， 即Y为父视图的centerY
    [self.nicknameLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.view);
    }];
    
    [self.nicknameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.nicknameLine.mas_top);
    }];
    
    [self.selectSchoolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.nicknameLine.mas_bottom).with.offset(midMargin);
    }];
    
    [self.selectSchoolLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.selectSchoolBtn.mas_bottom);
    }];
    
    [self.maleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.selectSchoolLine.mas_bottom).with.offset(larginMargin);
        make.left.equalTo(weakSelf.view).with.offset(15.f);
    }];
    
    [self.verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(lineHeightOrWidth);
        make.height.mas_equalTo(weakSelf.maleLabel.mas_height).with.offset(5.f);
        make.centerX.equalTo(weakSelf.view);
    }];
    
    [self.maleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.verticalLine.mas_left).with.offset(- midMargin);
    }];
    
    [self.femaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.verticalLine.mas_right).with.offset(midMargin);
    }];
    
    [self.femaleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.view).with.offset(-15);
    }];
    
    [self.gendarLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.maleLabel.mas_bottom).with.offset(margin);
    }];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(45);
        make.top.equalTo(weakSelf.gendarLine.mas_bottom).with.offset(larginMargin);
    }];
    
}

- (UIView *)commonLine {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = RGB(240., 240., 240.);
    return view;
}

- (UILabel *)commonLabel {
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 1;
    label.textColor = [UIColor blackColor];
    label.font = ZWFont(17);
    [label sizeToFit];
    return label;
}

- (UIButton *)commonBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setBackgroundImage:[UIImage imageNamed:@"radio_button_unchecked"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"radio_button_checked"] forState:UIControlStateDisabled];
    return btn;
}

- (void)pickAvatarImage {
    NSLog(@"点击头像");
    
    __weak __typeof(self) weakSelf = self;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *fromCameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf selectedImage:0];
    }];
    UIAlertAction *fromPickerAction = [UIAlertAction actionWithTitle:@"从相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf selectedImage:1];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:fromCameraAction];
    [alertController addAction:fromPickerAction];
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover){
        popover.sourceView = self.avatarImageView;
        popover.sourceRect = self.avatarImageView.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [ZWHUDTool showHUDWithTitle:@"出现错误" message:@"未能检测到相机，请重试" duration:2.0];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.sourceType = getImageWay == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    __weak __typeof(self) weakSelf = self;
    
    UIImage *selectedImage = [info[UIImagePickerControllerEditedImage] imageByResizeToSize:CGSizeMake(640, 640)];
    
    // 将所选图片写进文件，以便上传使用
    NSData *imageData = UIImageJPEGRepresentation(selectedImage, 0.3);
    NSString *avatarPath = [[ZWPathTool avatarDirectory] stringByAppendingPathComponent:@"avatar.jpeg"];
    NSURL *avatarFileURL = [NSURL fileURLWithPath:avatarPath];
    [imageData writeToURL:avatarFileURL atomically:YES];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        weakSelf.isAvatarSelected = YES;
        weakSelf.avatarImageView.image = selectedImage;
    }];
}

@end


////
////  ZWFilloutInformationViewController.m
////  Qimokaola
////
////  Created by Administrator on 16/7/14.
////  Copyright © 2016年 Administrator. All rights reserved.
////
//
//#import "ZWFilloutInformationViewController.h"
//#import "ZWSelectSchoolViewController.h"
//#import "UIColor+Extension.h"
//#import "ZWBindAccountViewController.h"
//#import "ZWHUDTool.h"
//#import "ZWPathTool.h"
//#import "ZWAPIRequestTool.h"
//
//#import "Masonry.h"
//#import "ReactiveCocoa.h"
//#import <YYKit/YYKit.h>
//
//@interface ZWFilloutInformationViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
//
////头像
//@property (nonatomic, strong) UIImageView *avatarImageView;
////昵称
//@property (nonatomic, strong) UITextField *nicknameField;
////昵称框下划线
//@property (nonatomic, strong) UIView *nicknameLine;
////选择学校
//@property (nonatomic, strong) UIButton *selectSchoolBtn;
////选择学校下划线
//@property (nonatomic, strong) UIView *selectSchoolLine;
////性别男 按钮
//@property (nonatomic, strong) UIButton *maleBtn;
////性别女 按钮
//@property (nonatomic, strong) UIButton *femaleBtn;
////性别男 标签
//@property (nonatomic, strong) UILabel *maleLabel;
////性别女 标签
//@property (nonatomic, strong) UILabel *femaleLabel;
////竖直分隔线
//@property (nonatomic, strong) UIView *verticalLine;
////性别下划线
//@property (nonatomic, strong) UIView *gendarLine;
////下一步 按钮
//@property (nonatomic, strong) UIButton *nextBtn;
//
//@property (nonatomic, assign) BOOL isAvatarSelected;
//@property (nonatomic, assign) BOOL isSchoolSelected;
//@property (nonatomic, copy) NSString *collegeID;
//@property (nonatomic, strong) NSString *collegeName;
//@property (nonatomic, copy) NSString *academyID;
//@property (nonatomic, strong) NSString *academyName;
//@property (nonatomic, strong) NSNumber *enterYear;
//
//@end
//
//@implementation ZWFilloutInformationViewController
//
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    NSLog(@"%@", self.registerParam);
//    
//    self.view.backgroundColor = [UIColor whiteColor];
//    
//    self.isAvatarSelected = self.isSchoolSelected = NO;
//    
//    [self createSubViews];
//    
//    @weakify(self)
//    [[self.selectSchoolBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
//        @strongify(self)
//        ZWSelectSchoolViewController *selectSchool = [[ZWSelectSchoolViewController alloc] init];
//        selectSchool.completionBlock = ^(NSDictionary *result) {
//            NSDictionary *school = [result objectForKey:@"school"];
//            NSDictionary *academy = [result objectForKey:@"academy"];
//            self.enterYear = [result objectForKey:@"enterYear"];
//            
//            self.collegeID = [school objectForKey:@"id"];
//            self.collegeName = [school objectForKey:@"name"];
//            self.academyID = [academy objectForKey:@"id"];
//            self.academyName = [academy objectForKey:@"name"];
//            
//            self.selectSchoolBtn.titleLabel.font = ZWFont(15);
//            
//            [self.selectSchoolBtn setTitle:[NSString stringWithFormat:@"%@-%@-%@", [school objectForKey:@"name"], [academy objectForKey:@"name"], self.enterYear.stringValue] forState:UIControlStateNormal];
//            [self.selectSchoolBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            self.isSchoolSelected = YES;
//        };
//        [self.navigationController pushViewController:selectSchool animated:YES];
//    }];
//    
//    [self.avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickAvatarImage)]];
//
//    [[self.maleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
//        @strongify(self)
//        btn.enabled = NO;
//        self.femaleBtn.enabled = YES;
//    }];
//    
//    [[self.femaleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
//        @strongify(self)
//        btn.enabled = NO;
//        self.maleBtn.enabled = YES;
//    }];
//    
//    RAC(self.nextBtn, enabled) = [RACSignal combineLatest:@[
//                                                            RACObserve(self, isAvatarSelected),
//                                                            RACObserve(self, isSchoolSelected),
//                                                            RACObserve(self.nicknameField, text),
//                                                            RACObserve(self.maleBtn, enabled),
//                                                            RACObserve(self.femaleBtn, enabled)
//                                                            ]
//                                                   reduce:^id(NSNumber *avatarSelected,
//                                                              NSNumber *schoolSelected,
//                                                              NSString *text,
//                                                              NSNumber *maleBtnEnabled,
//                                                              NSNumber *femaleBtnEnabled){
//                                                       
//        return @(text.length > 0 && [schoolSelected boolValue] && ([maleBtnEnabled boolValue] != [femaleBtnEnabled boolValue]) && [avatarSelected boolValue]);
//    }];
//    
////    [[self.nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
////        @strongify(self)
////        [self goToBindAccountViewController];
////    }];
//    
//    __block MBProgressHUD *hud;
//    [[[self.nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^RACStream *(id value) {
//        @strongify(self)
//        hud = [ZWHUDTool excutingHudInView:self.navigationController.view title:nil];
//        return [self checkNicknameValidSignal];
//    }] subscribeNext:^(NSDictionary *result) {
//        if ([[result objectForKey:kHTTPResponseResKey] allKeys].count == 0) {
//            [hud hideAnimated:YES];
//            [self goToBindAccountViewController];
//        } else {
//            hud.mode = MBProgressHUDModeText;
//            hud.label.text = @"该昵称已存在，请换一个";
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDShort * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [hud hideAnimated:YES];
//                [self.nicknameField becomeFirstResponder];
//            });
//        }
//    } error:^(NSError *error) {
//        hud.mode = MBProgressHUDModeText;
//        hud.label.text = @"出现错误, 请重试";
//        [hud hideAnimated:YES afterDelay:kShowHUDShort];
//    }];
//}
//
//- (RACSignal *)checkNicknameValidSignal {
//    @weakify(self)
//    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        @strongify(self)
//       [ZWAPIRequestTool reuqestInfoByName:self.nicknameField.text result:^(id response, BOOL success) {
//           if (success) {
//               [subscriber sendNext:response];
//               [subscriber sendCompleted];
//           } else {
//               [subscriber sendError:response];
//           }
//       }];
//        return nil;
//    }];
//}
//
//- (void)goToBindAccountViewController {
//    ZWBindAccountViewController *bindAccount = [[ZWBindAccountViewController alloc] init];
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.registerParam];
//    NSString *nickname = self.nicknameField.text;
//    NSString *gender = self.maleBtn.enabled ? @"女" : @"男";
//    [params addEntriesFromDictionary:@{
//                                       @"nick": nickname,
//                                       @"gender": gender,
//                                       @"schoolId" : self.collegeID,
//                                       @"academyId": self.academyID,
//                                       @"enterYear": self.enterYear
//                                       }];
//    bindAccount.registerParam = params;
//    bindAccount.collegeInfo = @{@"collegeName": self.collegeName, @"academyName": self.academyName};
//    [self.navigationController pushViewController:bindAccount animated:YES];
//}
//
//- (void)createSubViews {
//    
//    __weak __typeof(self) weakSelf = self;
//    
//    CGFloat margin = 10.f;
//    CGFloat midMargin = 20.f;
//    CGFloat larginMargin = 30.f;
//    
//    CGFloat commonHeight = 30.f;
//    CGFloat smallHeight = 20.f;
//    CGFloat lineHeightOrWidth = .5f;
//    
//    CGFloat cornerRadius = 5.f;
//    
//    CGFloat avatarSizeRate = .28f;
//    
//    UIFont *commonFont = ZWFont(17);
//    
//    
//    
//    //创建视图并添加至父控件
//    self.avatarImageView = ({
//        UIImageView *avatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"select_avatar"]];
//        avatar.contentMode = UIViewContentModeScaleToFill;
//        avatar.layer.cornerRadius = cornerRadius;
//        avatar.layer.masksToBounds = YES;
//        avatar.userInteractionEnabled = YES;
//        avatar.layer.borderColor = RGB(240., 240., 240.).CGColor;
//        avatar.layer.borderWidth = 1.f;
//        [self.view addSubview:avatar];
//        
//        avatar;
//    });
//
//    self.nicknameField = ({
//        UITextField *field = [[UITextField alloc] init];
//        field.borderStyle = UITextBorderStyleNone;
//        field.clearButtonMode = UITextFieldViewModeWhileEditing;
//        field.font = commonFont;
//        field.placeholder = @"输入昵称";
//        
//        [self.view addSubview:field];
//        
//        field;
//    });
//    
//    self.nicknameLine = ({
//        UIView *view = [self commonLine];
//        [self.view addSubview:view];
//        
//        view;
//    });
//    
//    self.selectSchoolBtn = ({
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
//        btn.titleLabel.font = commonFont;
//        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        [btn setTitle:@"选择学校，学院" forState:UIControlStateNormal];
//        [btn setTitleColor:RGBA(0., 0., 25., 0.22) forState:UIControlStateNormal];
//        [self.view addSubview:btn];
//        
//        btn;
//    });
//    
//    self.selectSchoolLine = ({
//        UIView *view = [self commonLine];
//        [self.view addSubview:view];
//        
//        view;
//    });
//    
//    self.maleLabel = ({
//        UILabel *label = [self commonLabel];
//        label.text = @"男";
//        
//        [self.view addSubview:label];
//        
//        label;
//    });
//    
//    self.maleBtn = ({
//        UIButton *btn = [self commonBtn];
//        [self.view addSubview:btn];
//        
//        btn;
//    });
//    
//    self.verticalLine = ({
//        UIView *view = [self commonLine];
//        [self.view addSubview:view];
//        
//        view;
//    });
//    
//    self.femaleLabel = ({
//        UILabel *label = [self commonLabel];
//        label.text = @"女";
//        [self.view addSubview:label];
//        
//        label;
//    });
//    
//    self.femaleBtn = ({
//        UIButton *btn = [self commonBtn];
//        [self.view addSubview:btn];
//        
//        btn;
//    });
//    
//    self.gendarLine = ({
//        UIView *view = [self commonLine];
//        [self.view addSubview:view];
//        
//        view;
//    });
//    
//    self.nextBtn = ({
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [btn setBackgroundImage:[RGB(80., 140., 238.) parseToImage] forState:UIControlStateNormal];
//        [btn setBackgroundImage:[[UIColor lightGrayColor] parseToImage] forState:UIControlStateDisabled];
//        [btn setTitle:@"下一步" forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        btn.layer.cornerRadius = 5;
//        btn.layer.masksToBounds = YES;
//        
//        [self.view addSubview:btn];
//        
//        btn;
//    });
//    
//    //添加视图约束
//    
//    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.and.width.equalTo(weakSelf.view.mas_width).multipliedBy(avatarSizeRate);
//        make.centerY.equalTo(weakSelf.view).multipliedBy(.5f);
//        make.centerX.equalTo(weakSelf.view);
//    }];
//    
//    [@[self.nicknameField, self.nicknameLine, self.selectSchoolBtn, self.selectSchoolLine, self.gendarLine, self.nextBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(weakSelf.view).with.offset(margin);
//        make.right.equalTo(weakSelf.view).with.offset(- margin);
//    }];
//    
//    [@[self.nicknameLine, self.selectSchoolLine, self.gendarLine] mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(lineHeightOrWidth);
//    }];
//    
//    [@[self.nicknameField, self.selectSchoolBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(commonHeight);
//    }];
//    
//    [@[self.maleLabel, self.maleBtn, self.femaleLabel, self.femaleBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.and.width.mas_equalTo(smallHeight);
//    }];
//    
//    [@[self.maleBtn, self.verticalLine, self.femaleLabel, self.femaleBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(weakSelf.maleLabel);
//    }];
//    
//    //以昵称下划线位置为中心位置， 即Y为父视图的centerY
//    [self.nicknameLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(weakSelf.view);
//    }];
//    
//    [self.nicknameField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(weakSelf.nicknameLine.mas_top);
//    }];
//    
//    [self.selectSchoolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(weakSelf.nicknameLine.mas_bottom).with.offset(midMargin);
//    }];
//    
//    [self.selectSchoolLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(weakSelf.selectSchoolBtn.mas_bottom);
//    }];
//    
//    [self.maleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(weakSelf.selectSchoolLine.mas_bottom).with.offset(larginMargin);
//        make.left.equalTo(weakSelf.view).with.offset(15.f);
//    }];
//    
//    [self.verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(lineHeightOrWidth);
//        make.height.mas_equalTo(weakSelf.maleLabel.mas_height).with.offset(5.f);
//        make.centerX.equalTo(weakSelf.view);
//    }];
//    
//    [self.maleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(weakSelf.verticalLine.mas_left).with.offset(- midMargin);
//    }];
//    
//    [self.femaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(weakSelf.verticalLine.mas_right).with.offset(midMargin);
//    }];
//    
//    [self.femaleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(weakSelf.view).with.offset(-15);
//    }];
//    
//    [self.gendarLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(weakSelf.maleLabel.mas_bottom).with.offset(margin);
//    }];
//    
//    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(45);
//        make.top.equalTo(weakSelf.gendarLine.mas_bottom).with.offset(larginMargin);
//    }];
//    
//}
//
//- (UIView *)commonLine {
//    UIView *view = [[UIView alloc] init];
//    view.backgroundColor = RGB(240., 240., 240.);
//    return view;
//}
//
//- (UILabel *)commonLabel {
//    UILabel *label = [[UILabel alloc] init];
//    label.numberOfLines = 1;
//    label.textColor = [UIColor blackColor];
//    label.font = ZWFont(17);
//    [label sizeToFit];
//    return label;
//}
//
//- (UIButton *)commonBtn {
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [btn setBackgroundImage:[UIImage imageNamed:@"radio_button_unchecked"] forState:UIControlStateNormal];
//    [btn setBackgroundImage:[UIImage imageNamed:@"radio_button_checked"] forState:UIControlStateDisabled];
//    return btn;
//}
//
//- (void)pickAvatarImage {
//    NSLog(@"点击头像");
//    
//    __weak __typeof(self) weakSelf = self;
//    
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//    UIAlertAction *fromCameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [weakSelf selectedImage:0];
//    }];
//    UIAlertAction *fromPickerAction = [UIAlertAction actionWithTitle:@"从相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [weakSelf selectedImage:1];
//    }];
//    [alertController addAction:cancelAction];
//    [alertController addAction:fromCameraAction];
//    [alertController addAction:fromPickerAction];
//    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
//    if (popover){
//        popover.sourceView = self.avatarImageView;
//        popover.sourceRect = self.avatarImageView.bounds;
//        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
//        
//    }
//    [self presentViewController:alertController animated:YES completion:nil];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
///**
// *  @author Administrator, 16-07-15 17:07:18
// *
// *  选取图片
// *
// *  @param getImageWay 选取图片方式 0-拍照 1-相册
// */
//- (void)selectedImage:(NSInteger)getImageWay {
//    
//    if (getImageWay == 0 && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        [ZWHUDTool showHUDWithTitle:@"出现错误" message:@"未能检测到相机，请重试" duration:2.0];
//        return;
//    }
//    
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.allowsEditing = YES;
//    picker.sourceType = getImageWay == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
//    picker.allowsEditing = YES;
//    picker.delegate = self;
//    [self presentViewController:picker animated:YES completion:nil];
//}
//
//#pragma mark - UIImagePickerControllerDelegate
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
//    
//    __weak __typeof(self) weakSelf = self;
//    
//    UIImage *selectedImage = [info[UIImagePickerControllerEditedImage] imageByResizeToSize:CGSizeMake(640, 640)];
//    
//    // 将所选图片写进文件，以便上传使用
//    NSData *imageData = UIImageJPEGRepresentation(selectedImage, 0.3);
//    NSString *avatarPath = [[ZWPathTool avatarDirectory] stringByAppendingPathComponent:@"avatar.jpeg"];
//    NSURL *avatarFileURL = [NSURL fileURLWithPath:avatarPath];
//    [imageData writeToURL:avatarFileURL atomically:YES];
//    
//    [picker dismissViewControllerAnimated:YES completion:^{
//        weakSelf.isAvatarSelected = YES;
//        weakSelf.avatarImageView.image = selectedImage;
//    }];
//}
//
//@end
