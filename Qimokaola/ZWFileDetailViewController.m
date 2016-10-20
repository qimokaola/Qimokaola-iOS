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
#import "ZWAPITool.h"
#import "ZWNetworkingManager.h"
#import "ZWUserManager.h"
#import "ZWPathTool.h"
#import "ZWDataBaseTool.h"
#import "ZWHUDTool.h"

#import "NSString+Extension.h"

#import "ZWAPITool.h"

#import <AFNetworking/AFNetworking.h>
#import "Masonry.h"
#import <UMSocialCore/UMSocialCore.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ZWFileDetailViewController () <UIDocumentInteractionControllerDelegate>



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
// 文件上传时间
@property (nonatomic, strong) UILabel *uploadTimeLabel;
// 文件上传者标签
@property (nonatomic, strong) UILabel *uploaderLabel;
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

@property (nonatomic, strong) AFHTTPSessionManager *downloadManager;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;



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
    self.title = @"文件详情";
    
    [self zw_addSubViews];
    [self setFileInfo];
    
    // 构建文件标识符
    // 如果文件已经下载 则取出文件存于磁盘中的名字
    if (self.hasDownloaded && self.storage_name == nil) {
        self.storage_name = [[ZWDataBaseTool sharedInstance] storage_nameWithIdentifier:self.file.md5];
    }
    
    self.documentController = [[UIDocumentInteractionController alloc] init];
    self.documentController.delegate = self;
    
    RAC(self.downloadOrOpenButton, selected) = RACObserve(self, hasDownloaded);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelDownload];
}


#pragma mark - Lazy Loading

- (AFHTTPSessionManager *)downloadManager {
    if (_downloadManager == nil) {
        _downloadManager = [AFHTTPSessionManager manager];
        _downloadManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _downloadManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/html", @"application/json", @"audio/wav", @"application/octet-stream", nil];
    }
    return _downloadManager;
}

#pragma mark - Common Methods

- (void)setFileInfo {
    _typeImageView.image = [UIImage imageNamed:[ZWFileTool fileTypeFromFileName:_file.name]];
    
    _nameLabel.text = _file.name;
    
    _uploaderLabel.text = [NSString stringWithFormat:@"分享者：@%@", _file.creator];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *datea = [NSDate dateWithTimeIntervalSince1970:[_file.ctime doubleValue] / 1000];
    NSString *dateString = [formatter stringFromDate:datea];
    _uploadTimeLabel.text = [NSString stringWithFormat:@"%@上传",dateString];
    
    _sizeLabel.text = [NSString stringWithFormat:@"大小：%@", [ZWFileTool sizeWithString:_file.size]];
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
    
    _uploaderLabel = [[UILabel alloc] init];
    _uploaderLabel.font = ZWFont(16);
    _uploaderLabel.textColor = [UIColor blueColor];
    _uploaderLabel.textAlignment = NSTextAlignmentCenter;
    _uploaderLabel.numberOfLines = 1;
    [self.view addSubview:_uploaderLabel];
    [_uploaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.nameLabel.mas_bottom);
    }];
    
    _uploadTimeLabel = [[UILabel alloc] init];
    _uploadTimeLabel.textColor = [UIColor blackColor];
    _uploadTimeLabel.font = ZWFont(16);
    _uploadTimeLabel.numberOfLines = 0;
    _uploadTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_uploadTimeLabel];
    [_uploadTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.uploaderLabel.mas_bottom).offset(40);
    }];
    
    self.sizeLabel = ({
        UILabel *label = [[UILabel alloc] init];
        UIFont *font = [UIFont systemFontOfSize:16];
        label.font = font;
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(weakSelf.view);
            make.top.mas_equalTo(weakSelf.uploadTimeLabel.mas_bottom).with.offset(10);
            
        }];
        label;
    });
    
    int margin =20;
    float cornerRadius = 5.0f;
    UIFont *buttonTitleFont = [UIFont systemFontOfSize:15];
    UIColor *tintColor = RGB(26, 182, 238);
    
    self.downloadOrOpenButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button.titleLabel setFont:buttonTitleFont];
        [button setTitle:@"下载文件" forState:UIControlStateNormal];
        [button setTitle:@"打开文件" forState:UIControlStateSelected];
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
        label.text  = @"正在准备下载...";
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
    [self setDownloadState:NO];
    if (self.downloadTask) {
        [self.downloadTask cancel];
        self.downloadTask = nil;
    }
}

- (void)downloadOrOpenButtonClicked:(UIButton *)sender {
    if (!self.hasDownloaded) {
        [self downloadFile];
    } else {
        [self openDocumentInThirdPartyApp];
    }
}

- (void)downloadFile {
    __weak __typeof(self) weakSelf = self;
    [self setDownloadState:YES];
    [ZWAPIRequestTool requestDownloadUrlInSchool:[ZWUserManager sharedInstance].loginUser.currentCollegeId
                                            path:[_path stringByAppendingString:_file.name]
                                          result:^(id response, BOOL success) {
                                              if (success && [[response objectForKey:kHTTPResponseCodeKey] intValue] == 0) {
                                                  NSString *urlString = [[response objectForKey:kHTTPResponseResKey] objectForKey:@"url"];
                                                  [weakSelf downloadFileWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
                                              } else {
                                                  [weakSelf setDownloadState:NO];
                                                  [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"获取下载地址失败" message:nil duration:kShowHUDShort];
                                              }
                                          }];
}

- (void)downloadFileWithRequest:(NSURLRequest *)request {
    __weak __typeof(self) weakSelf = self;
    weakSelf.downloadTask = [self.downloadManager downloadTaskWithRequest:request
                                                                     progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                             weakSelf.progressLabel.text = [NSString stringWithFormat:@"已完成：%.1f%%", downloadProgress.fractionCompleted * 100];
                                                                             weakSelf.progressView.progress = downloadProgress.fractionCompleted;
                                                                         });
                                                                     }
                                                                  destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                                      return [NSURL fileURLWithPath:[weakSelf properFileName:weakSelf.file.name]];
                                                                  }
                                                            completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                                [weakSelf setDownloadState:NO];
                                                                if (error) {
                                                                    NSLog(@"取消下载或下载失败");
                                                                } else {
                                                                    weakSelf.hasDownloaded = YES;
                                                                    if (weakSelf.downloadCompletion) {
                                                                        weakSelf.downloadCompletion();
                                                                    }
                                                                    [[ZWDataBaseTool sharedInstance] addFileDownloadInfo:weakSelf.file
                                                                                                                storage_name:weakSelf.storage_name
                                                                                                                inSchool:[ZWUserManager sharedInstance].loginUser.currentCollegeName
                                                                                                                inCourse:weakSelf.course];
                                                                }
                                                            }];
    [weakSelf.downloadTask resume];
}



/**
 获得文件的最佳存储路径

 @param originFileName

 @return
 */
- (NSString *)properFileName:(NSString *)originFileName {
    NSString *properFileName = originFileName;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *downloadDir = [ZWPathTool downloadDirectory];
    NSRange range = [properFileName rangeOfString:@"." options:NSBackwardsSearch];
    int suffix = 1;
    while ([fileManager fileExistsAtPath:[downloadDir stringByAppendingPathComponent:properFileName]]) {
        properFileName = [originFileName stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"(%d).", suffix ++]];
    }
    self.storage_name = properFileName;
    return [downloadDir stringByAppendingPathComponent:properFileName];
}

#pragma mark - 分享至QQ QQ空间
- (void)shareToComputer{
    NSString *shareUrl = [NSString stringWithFormat:@"%@：%@", self.file.name, [NSString stringWithFormat:[ZWAPITool shareFileAPI], self.file.md5, [self.file.name URLEncodedString]]];
    
//    [UMSocialSnsService presentSnsIconSheetView:self
//                                         appKey:nil
//                                      shareText:shareUrl
//                                     shareImage:nil
//                                shareToSnsNames:@[UMShareToQQ]
//                                       delegate:self];
    
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    messageObject.text = shareUrl;
    [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_QQ messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        NSString *message = nil;
        if (!error) {
            message = [NSString stringWithFormat:@"分享成功"];
        } else {
            message = [NSString stringWithFormat:@"失败原因Code: %d\n",(int)error.code];
            
        }
        NSLog(@"%@", message);
    }];
    
}

#pragma mark 打开已下载文件
-(void)openDocumentInThirdPartyApp {
    NSString *filePath = [[ZWPathTool downloadDirectory] stringByAppendingPathComponent:self.storage_name];
    self.documentController.URL = [NSURL fileURLWithPath:filePath];
    [self.documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
}

- (void)sendButtonClicked:(UIButton *)sender {
    [self shareToComputer];
}

- (void)setDownloadState:(BOOL)isDownload {
    [self setMainButtonHidden:isDownload];
    [self setDownloadComponmentHidden:!isDownload];
}

- (void)setMainButtonHidden:(BOOL)hidden {
    self.downloadOrOpenButton.hidden = hidden;
    self.shareButton.hidden = hidden;
}

- (void)setDownloadComponmentHidden:(BOOL)hidden {
    self.progressLabel.hidden = hidden;
    self.progressView.hidden = hidden;
    self.cancelButton.hidden = hidden;
    
    self.progressView.progress = 0.f;
    self.progressLabel.text = @"正在准备下载...";
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
    NSLog(@"documentInteractionControllerDidEndPreview");
}

// 预览文件或者拷贝至第三方App时都会触发以下两个方法

- (void)documentInteractionControllerWillBeginPreview:(UIDocumentInteractionController *)controller {
    [[ZWDataBaseTool sharedInstance] updateLastAccessTimeWithIdentifier:_file.md5];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    [[ZWDataBaseTool sharedInstance] updateLastAccessTimeWithIdentifier:_file.md5];
}

//弹出列表方法presentSnsIconSheetView需要设置delegate为self
-(BOOL)isDirectShareInIconActionSheet {
    return YES;
}

@end
