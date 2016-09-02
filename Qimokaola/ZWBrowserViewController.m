//
//  ZWBrowserViewController.m
//  Qimokaola
//
//  Created by Administrator on 15/12/8.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import "ZWBrowserViewController.h"
#import "Masonry.h"
#import "UIColor+Extension.h"

#define kAnimationTime 0.3

@interface ZWBrowserViewController ()

@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIWebView *webPage;
@property (nonatomic, assign) ZWBrowserLoadType loadType;


@end

@implementation ZWBrowserViewController


- (instancetype)initWithURLString:(NSString *)URLString titleString:(NSString *)titleString loadType:(ZWBrowserLoadType)loadType {
    if (self = [super init]) {
        self.URLString = URLString;
        self.titleString = titleString;
        self.loadType = loadType;
        self.hidesBottomBarWhenPushed = loadType == ZWBrowserLoadTypeFromOthers;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.loadType == ZWBrowserLoadTypeFromOthers) {
        
        return;
    }
    
    [UIView animateWithDuration:kAnimationTime animations:^{
        CGRect frame = self.tabBarController.tabBar.frame;
        frame.origin.y += frame.size.height;
        self.tabBarController.tabBar.frame = frame;
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (self.loadType == ZWBrowserLoadTypeFromOthers) {
        
        return;
    }
    
    [UIView animateWithDuration:kAnimationTime animations:^{
        CGRect frame = self.tabBarController.tabBar.frame;
        frame.origin.y -= frame.size.height;
        self.tabBarController.tabBar.frame = frame;
    }];
}

- (void)initView {
    //设置背景为白色
    self.view.backgroundColor = [UIColor whiteColor];

    self.title = self.titleString;
 
    if ([self.titleString isEqualToString:@"福大拼车"]) {
        UIBarButtonItem *carpoolingItem = [[UIBarButtonItem alloc] initWithTitle:@"发起拼车" style:UIBarButtonItemStylePlain target:self action:@selector(carpooling)];
        self.navigationItem.rightBarButtonItem = carpoolingItem;
    }
    
    //UIWebView视图 网页内容显示器
    self.webPage = ({
        UIWebView *webView = [[UIWebView alloc] init];
        webView.scalesPageToFit = YES;
        [self.view addSubview:webView];
        
        [webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top);
            make.left.right.equalTo(self.view);
            if (self.loadType == ZWBrowserLoadTypeFromServices) {
                make.height.equalTo(self.view).offset(kTabBarHeight);
            } else {
                make.edges.equalTo(self.view);
            }
        }];
        
        webView;
    });
    
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       [self.webPage loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.URLString]]];
   });
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSURL *url = [NSURL URLWithString:self.URLString];
//        NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            [self.webPage loadHTMLString:content baseURL:nil];
//            
//        });
//        
//    });
}

- (void)carpooling {
    ZWBrowserViewController *browser = [[ZWBrowserViewController alloc] initWithURLString:@"http://weixinpinpin.duapp.com/pinpinPage/creatTill.jsp" titleString:@"发起拼车" loadType:ZWBrowserLoadTypeFromServices];
    [self.navigationController pushViewController:browser animated:YES];
}

- (void)popView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window)// 是否是正在使用的视图
    {
        // Add code to preserve data stored in the views that might be
        // needed later.
        
        // Add code to clean up other strong references to the view in
        // the view hierarchy.
        self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
    }
}

- (void)dealloc {
    self.webPage = nil;
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
