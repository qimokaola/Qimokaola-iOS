//
//  ZWFileDetailController.m
//  Paper
//
//  Created by Administrator on 16/4/13.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWFileDetailViewController.h"
#import "Masonry.h"
#import "UIColor+CommonColor.h"
#import "UIColor+CommonColor.h"
#import "ZWDownloadCenter.h"
#import "ZWUtilsCenter.h"
#import "UMSocial.h"
#import "FMDB.h"
#import "AppDelegate.h"
#import "MobClick.h"
#import "UIColor+CommonColor.h"

static NSString *const querySQL = @"SELECT name FROM download_info WHERE link = '%@'";

@interface ZWFileDetailViewController () <UMSocialUIDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIDocumentInteractionController *documentController;

//文件对象
@property (nonatomic, strong) ZWFile *file;

//底部条栏
@property (nonatomic, strong) UITabBar *bottomBar;

//文件类型图像
@property (nonatomic, strong) UIImageView *typeImageView;

//文件名标签
@property (nonatomic, strong) UILabel *nameLabel;

//文件大小标签
@property (nonatomic, strong) UILabel *sizeLabel;

//打开、下载按钮
@property (nonatomic, strong) UIButton *downloadOrOpenButton;

//发送按钮
@property (nonatomic, strong) UIButton *sendButton;

//下载进度提示文本
@property (nonatomic, strong) UILabel *progressLabel;

//下载进度条
@property (nonatomic, strong) UIProgressView *progressView;

//打开文件提醒
@property (nonatomic, strong) UILabel *openingHintLabel;

//取消下载按钮
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) FMDatabaseQueue *DBQueue;

@property (nonatomic, copy) NSString *fileName;


@end

@implementation ZWFileDetailViewController


- (FMDatabaseQueue *)DBQueue {
    if (_DBQueue == nil) {
        _DBQueue = [(AppDelegate *)[UIApplication sharedApplication].delegate DBQueue];
    }
    return _DBQueue;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //若退出则停止下载
    [[ZWDownloadCenter sharedDownloadCenter] cancelAllDownloadTasks];
}

- (instancetype)initWithFile:(ZWFile *)file {
    if (self = [super init]) {
        _file = file;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) weakSelf = self;
    
    self.title = self.file.path;
    
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
    
    self.openingHintLabel = ({
        
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label.text = @"请选择合适方式打开文件";
        label.font = [UIFont systemFontOfSize:13];
        label.hidden = !self.file.download;
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
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[ZWUtilsCenter parseTypeWithString:self.file.type]]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.mas_equalTo(weakSelf.view);
            make.top.mas_equalTo(weakSelf.view).offset(kScreenHeight * 0.10);
            make.height.width.mas_equalTo(100);
            
        }];
        
        imageView;
    });
    
    self.nameLabel = ({
        
        UILabel *label = [[UILabel alloc] init];
        UIFont *font = [UIFont systemFontOfSize:18];
        label.font = font;
        label.text = self.file.name;
        label.numberOfLines = 0;
        label.textColor = [UIColor grayColor];
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
        label.text = self.file.size;
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        CGSize textSize = [label.text sizeWithAttributes:@{NSFontAttributeName: font}];
        [self.view addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.right.mas_equalTo(weakSelf.view);
            make.height.mas_equalTo(textSize.height);
            make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom);
            
        }];
        
        label;
        
    });
    
    int margin =20;
    float cornerRadius = 5.0f;
    UIFont *buttonTitleFont = [UIFont systemFontOfSize:15];
    UIColor *tintColor = RGB(26, 182, 238);
    
    self.downloadOrOpenButton = ({
        
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:self.file.download ? @"打开文件" : @"下载到手机" forState:UIControlStateNormal];
        [button.titleLabel setFont:buttonTitleFont];
        
        [button setBackgroundImage:[tintColor parseToImage] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIColor whiteColor] parseToImage] forState:UIControlStateSelected];
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:tintColor forState:UIControlStateSelected];
        
        button.layer.cornerRadius = cornerRadius;
        button.layer.masksToBounds = YES;
        [self.bottomBar addSubview:button];
        
        [button addTarget:self action:@selector(downloadOrOpenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    });
    
    self.sendButton = ({
        
        UIButton *button = [[UIButton alloc] init];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTitle:@"发送至电脑" forState: UIControlStateNormal];
        [button setTitleColor:tintColor forState:UIControlStateNormal];
        [button.titleLabel setFont:buttonTitleFont];
        button.layer.cornerRadius = cornerRadius;
        button.layer.borderColor = tintColor.CGColor;
        button.layer.borderWidth = 1.0;
        [self.bottomBar addSubview:button];
        
        [button addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    });
    
    [self.downloadOrOpenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(weakSelf.bottomBar);
        make.height.mas_equalTo(weakSelf.bottomBar).with.offset(- margin * 0.2);
        make.left.mas_equalTo(weakSelf.bottomBar.mas_left).with.offset(margin);
        
        make.right.mas_equalTo(weakSelf.sendButton.mas_left).with.offset(- margin);
        make.width.mas_equalTo(weakSelf.sendButton);
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(weakSelf.bottomBar);
        make.height.mas_equalTo(weakSelf.downloadOrOpenButton);
        make.right.mas_equalTo(weakSelf.bottomBar.mas_right).with.offset(- margin);
        
        make.left.mas_equalTo(weakSelf.downloadOrOpenButton.mas_right).with.offset(margin);
        make.width.mas_equalTo(weakSelf.downloadOrOpenButton);
    }];
    
    self.progressLabel = ({
        
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor grayColor];
        label.text = [NSString stringWithFormat:@"下载中...(0/%@)", self.file.size];
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
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(weakSelf.bottomBar).with.offset(margin / 2);
        make.right.mas_equalTo(weakSelf.bottomBar).with.offset(- margin * 2);
        make.bottom.mas_equalTo(weakSelf.bottomBar).with.offset(- margin * 0.5);
        make.height.mas_equalTo(3);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(weakSelf.bottomBar);
        make.right.mas_equalTo(weakSelf.bottomBar);
        make.height.width.mas_equalTo(40);
        
    }];
    
}

- (void)cancelDownload {
    
    [[ZWDownloadCenter sharedDownloadCenter] cancelAllDownloadTasks];
    [self setDownloadState:NO];
    self.progressLabel.text = [NSString stringWithFormat:@"下载中...(0/%@)", self.file.size];
}

- (void)downloadOrOpenButtonClicked:(UIButton *)sender {
    
    if (!self.file.download) {
        
        //文件未下载， 进行下载进程
        
        [MobClick event:@"Download_File"];
        
        //判断网络情况，若无网络进行提醒并终止下载
        if (![ZWUtilsCenter checkNetWorkStateAvailable]) {
            return;
        }
 
        //下载开始前的视图准备
        [self setDownloadState:YES];
        self.progressView.progress = 0.0;
       
        [[ZWDownloadCenter sharedDownloadCenter] addDownloadTaskWithFile:self.file beforeDownload:^{
            
            
                                                                   
         }
         whileDonwloading:^(int64_t hasWritten, int64_t totalExpected) {
             
             self.progressView.progress = (double)hasWritten / (double) totalExpected;
             
             self.progressLabel.text = [NSString stringWithFormat:@"下载中..(%@/%@)", [ZWUtilsCenter sizeWithDouble:(double)hasWritten / 1024],self.file.size];
             
        } afterDownload:^(NSString *fileName){
            
            self.openingHintLabel.hidden = NO;
            
            self.fileName = fileName;
            
            [self setDownloadState:NO];
            
            self.file.download = YES;
            
            [self.downloadOrOpenButton setTitle:@"打开文件" forState:UIControlStateNormal];
            
            if (self.downloadCompletionHandler) {
                self.downloadCompletionHandler();
                
       }
            
    }];
        
    } else {
        
        [self openDocumentInThirdPartyApp];
        
    }
    
}

#pragma mark - 分享至QQ QQ空间
- (void)shareToComputer{
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:nil
                                      shareText:[self.file.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                     shareImage:nil
                                shareToSnsNames:@[UMShareToQQ]
                                       delegate:self];
    
}

#pragma mark 打开已下载文件
-(void)openDocumentInThirdPartyApp {
    
    __weak __typeof(self) weakSelf = self;
    
    if (self.fileName != nil) {
        
        NSLog(@"通过下载完成块获得文件存于设备内的名字");
    
        NSString *filePath = [[ZWUtilsCenter downloadDirectory] stringByAppendingPathComponent:self.fileName];
        NSLog(@"%@", filePath);
        weakSelf.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
        weakSelf.documentController.delegate = weakSelf;
        
        [weakSelf.documentController presentOptionsMenuFromRect:weakSelf.view.bounds inView:weakSelf.view animated:YES];
        
    } else {
        
        
        [self.DBQueue inDatabase:^(FMDatabase *db) {
            
            NSLog(@"url: %@", weakSelf.file.url);
            
            FMResultSet *result = [db executeQuery:[NSString stringWithFormat:querySQL, weakSelf.file.url]];
            if (![result next]) {
                NSLog(@"query error");
            }
            NSString *fileName = [result stringForColumnIndex:0];
            [result close];
            
            NSString *filePath = [[ZWUtilsCenter downloadDirectory] stringByAppendingPathComponent:fileName];
            NSLog(@"%@", filePath);
            weakSelf.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
            weakSelf.documentController.delegate = weakSelf;
            
            [weakSelf.documentController presentOptionsMenuFromRect:weakSelf.view.bounds inView:weakSelf.view animated:YES];
            
        }];

        
    }

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
    self.sendButton.hidden = hidder;
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

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController*)_controller {
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
