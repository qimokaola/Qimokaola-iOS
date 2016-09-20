//
//  ZWFileDetailViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/9/11.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWFileDetailViewController.h"
#import "UIColor+Extension.h"
#import "ZWFileTool.h"

#import "Masonry.h"
#import "UMSocial.h"

@interface ZWFileDetailViewController () <UMSocialUIDelegate, UIDocumentInteractionControllerDelegate>

// 分享UI
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
// 底部条栏
@property (nonatomic, strong) UITabBar *bottomBar;
// 文件类型图像
@property (nonatomic, strong) UIImageView *typeImageView;
// 文件名标签
@property (nonatomic, strong) UILabel *nameLabel;
// 文件大小标签
@property (nonatomic, strong) UILabel *sizeLabel;
// 有关文件上传的信息
@property (nonatomic, strong) UILabel *uploaderDesclabel;
// 打开、下载按钮
@property (nonatomic, strong) UIButton *downloadOrOpenButton;
// 分享按钮
@property (nonatomic, strong) UIButton *shareButton;
// 下载进度提示文本
@property (nonatomic, strong) UILabel *progressLabel;
// 下载进度条
@property (nonatomic, strong) UIProgressView *progressView;
// 打开文件提醒
@property (nonatomic, strong) UILabel *openHintLabel;
// 取消下载按钮
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation ZWFileDetailViewController

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self zw_addSubViews];
    // 根据ZWFile设置相关视图
    [self setFileInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Common Methods

- (void)setFileInfo {
    _typeImageView.image = [UIImage imageNamed:[ZWFileTool fileTypeFromFileName:_file.name]];
    _nameLabel.text = _file.name;
    _sizeLabel.text = [ZWFileTool sizeWithString:_file.size];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:MM:ss"];
    NSDate *datea = [NSDate dateWithTimeIntervalSince1970:[_file.ctime doubleValue]];
    NSString *dateString = [formatter stringFromDate:datea];
    _uploaderDesclabel.text = [NSString stringWithFormat:@"由用户 %@ 于 %@ 上传", _file.creator, dateString];
}

- (void)zw_addSubViews {
    __weak __typeof(self) weakSelf = self;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.bottomBar = ({
        UITabBar *bar = [[UITabBar alloc] init];
        [self.view addSubview:bar];
        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(weakSelf.view);
            make.bottom.mas_equalTo(weakSelf.view.mas_bottom);
            make.height.mas_equalTo(55);
        }];
        bar;
    });
    
    self.openHintLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label.text = @"请选择合适方式打开文件";
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor lightGrayColor];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(weakSelf.view);
            make.bottom.mas_equalTo(weakSelf.bottomBar.mas_top);
            make.height.mas_equalTo(40);
        }];
        label;
        
    });
    
    self.typeImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(weakSelf.view);
            make.top.mas_equalTo(weakSelf.view).offset(kScreenHeight * 0.05);
            make.height.width.mas_equalTo(100);
        }];
        imageView;
    });
    
    self.nameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        UIFont *font = [UIFont systemFontOfSize:18];
        label.font = font;
        label.numberOfLines = 0;
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(weakSelf.view);
            make.height.mas_equalTo(50);
            make.top.mas_equalTo(weakSelf.typeImageView.mas_bottom).with.offset(kScreenHeight * 0.04);
            
        }];
        label;
    });
    
    self.sizeLabel = ({
        UILabel *label = [[UILabel alloc] init];
        UIFont *font = [UIFont systemFontOfSize:16];
        label.font = font;
        label.textColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(weakSelf.view);
            make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom);
            
        }];
        label;
    });
    
    _uploaderDesclabel = [[UILabel alloc] init];
    _uploaderDesclabel.textColor = [UIColor lightGrayColor];
    _uploaderDesclabel.font = ZWFont(15);
    _uploaderDesclabel.numberOfLines = 0;
    _uploaderDesclabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_uploaderDesclabel];
    [_uploaderDesclabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.sizeLabel.mas_bottom).offset(20);
    }];
    
    int margin =20;
    float cornerRadius = 5.0f;
    UIFont *buttonTitleFont = [UIFont systemFontOfSize:15];
    UIColor *tintColor = RGB(26, 182, 238);
    
    self.downloadOrOpenButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button.titleLabel setFont:buttonTitleFont];
        [button setTitle:@"下载文件" forState:UIControlStateNormal];
        [button setBackgroundImage:[tintColor parseToImage] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = cornerRadius;
        button.layer.masksToBounds = YES;
        [self.bottomBar addSubview:button];
        [button addTarget:self action:@selector(downloadOrOpenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    self.shareButton = ({
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[[UIColor whiteColor] parseToImage] forState:UIControlStateNormal];
       // [button setBackgroundImage:[[UIColor whiteColor] parseToImage] forState:UIControlStateDisabled];
        [button setTitle:@"发送至电脑" forState: UIControlStateNormal];
        [button setTitleColor:tintColor forState:UIControlStateNormal];
        [button.titleLabel setFont:buttonTitleFont];
        button.layer.cornerRadius = cornerRadius;
        button.layer.masksToBounds = YES;
        button.layer.borderColor = tintColor.CGColor;
        button.layer.borderWidth = 1.0;
        [self.bottomBar addSubview:button];
        
        [button addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    });
    
    [self.downloadOrOpenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(weakSelf.bottomBar);
        make.height.mas_equalTo(weakSelf.bottomBar).multipliedBy(0.8);
        make.left.mas_equalTo(weakSelf.bottomBar.mas_left).with.offset(margin);
        make.right.mas_equalTo(weakSelf.shareButton.mas_left).with.offset(- margin * 2);
        make.width.mas_equalTo(weakSelf.shareButton);
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(weakSelf.bottomBar);
        make.height.mas_equalTo(weakSelf.downloadOrOpenButton);
        make.right.mas_equalTo(weakSelf.bottomBar.mas_right).with.offset(- margin);
        
        make.left.mas_equalTo(weakSelf.downloadOrOpenButton.mas_right).with.offset(margin * 2);
        make.width.mas_equalTo(weakSelf.downloadOrOpenButton);
    }];
    
    self.progressLabel = ({
        
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor grayColor];
        [self.bottomBar addSubview:label];
        label.hidden = YES;
        label;
    });
    
    self.progressView = ({
        
        UIProgressView *progress = [[UIProgressView alloc] init];
        progress.trackTintColor = RGB(229, 229, 229);
        progress.progressTintColor = RGB(101, 213, 33);
        progress.progress = 0.0;
        [self.bottomBar addSubview:progress];
        
        progress.hidden = YES;
        
        progress;
        
    });
    
    self.cancelButton = ({
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [self.bottomBar addSubview:button];
        button.hidden = YES;
        [button addTarget:self action:@selector(cancelDownload) forControlEvents:UIControlEventTouchUpInside];
        button;
        
    });
    
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(weakSelf.progressView);
        make.top.mas_equalTo(weakSelf.bottomBar);
        make.bottom.mas_equalTo(weakSelf.progressView);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {        make.left.mas_equalTo(weakSelf.bottomBar).with.offset(margin / 2);
        make.right.mas_equalTo(weakSelf.bottomBar).with.offset(- margin * 2);
        make.bottom.mas_equalTo(weakSelf.bottomBar).with.offset(- margin * 0.5);
        make.height.mas_equalTo(3);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {        make.centerY.mas_equalTo(weakSelf.bottomBar);
        make.right.mas_equalTo(weakSelf.bottomBar);
        make.height.width.mas_equalTo(40);
        
    }];
}

- (void)cancelDownload {
}

- (void)downloadOrOpenButtonClicked:(UIButton *)sender {
    
    
}

#pragma mark - 分享至QQ QQ空间
- (void)shareToComputer{
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:nil
                                      shareText:nil
                                     shareImage:nil
                                shareToSnsNames:@[UMShareToQQ]
                                       delegate:self];
    
}

#pragma mark 打开已下载文件
-(void)openDocumentInThirdPartyApp {
    
}

- (void)sendButtonClicked:(UIButton *)sender {
    [self shareToComputer];
}

- (void)setDownloadState:(BOOL)isDownload {
    [self setMainButtonHidden:isDownload];
    [self setDownloadComponmentHidden:!isDownload];
}

- (void)setMainButtonHidden:(BOOL)hidder {
    self.downloadOrOpenButton.hidden = hidder;
    self.shareButton.hidden = hidder;
}

- (void)setDownloadComponmentHidden:(BOOL)hidden {
    self.progressLabel.hidden = hidden;
    self.progressView.hidden = hidden;
    self.cancelButton.hidden = hidden;
}

#pragma mark - UIDocumentInteractionControllerDelegate代理方法

- (UIViewController*)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController*)controller {
    if (self.navigationController) {
        return self.navigationController;
    }
    return self;
}

- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller {
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller {
    return self.view.frame;
}
//点击预览窗口的“Done”(完成)按钮时调用

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController*)controller {
    
}

//弹出列表方法presentSnsIconSheetView需要设置delegate为self
-(BOOL)isDirectShareInIconActionSheet {
    return YES;
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

@end
