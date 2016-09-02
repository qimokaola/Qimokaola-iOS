//
//  ZWDonateViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/3/3.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWAboutUsViewController.h"
#import "Masonry.h"
#import "UIColor+Extension.h"
#define kAnimationTime 0.3

#define margin 20


@interface ZWAboutUsViewController ()


@end

@implementation ZWAboutUsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor colorWithRed:252 / 255.0 green:252 / 255.0 blue:252 / 255.0 alpha:252 / 255.0];
    
    __weak __typeof(self) weakSelf = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"关于";
    

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    //App图标
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:iconImageView];
    
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(scrollView).offset(15);
        make.size.mas_equalTo(CGSizeMake(86, 86));
    }];
    
    //版本标签
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.font = [UIFont systemFontOfSize:17];
    versionLabel.textColor = [UIColor darkGrayColor];
    versionLabel.text = [NSString stringWithFormat:@"期末考啦 iOS v%@", [self version]];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:versionLabel];
    
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(iconImageView.mas_bottom).offset(15);
        make.height.equalTo(@20);
    }];
    
    
    //打赏按钮
    UITabBar *bar = [[UITabBar alloc] init];
    [self.view addSubview:bar];
    
    [bar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view.mas_bottom);
        make.height.equalTo(@49);
    }];
    
    UIButton *donateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [donateButton setTitle:@"支付宝捐赠" forState:UIControlStateNormal];
    [donateButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [donateButton addTarget:self action:@selector(donate:) forControlEvents:UIControlEventTouchUpInside];
    [donateButton setBackgroundImage:[[UIColor lightGrayColor] parseToImage] forState:UIControlStateHighlighted];
    [bar addSubview:donateButton];
    
    [donateButton mas_makeConstraints:^(MASConstraintMaker *make) {
    
        make.edges.equalTo(bar);
            
        }];
    
    //关于标签
    UILabel *aboutLabel = [[UILabel alloc] init];
    aboutLabel.numberOfLines = 0;
    aboutLabel.textColor = [UIColor grayColor];
    aboutLabel.font = [UIFont systemFontOfSize:15];
    aboutLabel.text = @"• “期末考啦”是一款学习资料分享为主的大学生app, 在福大出生, 在福大成长ing, 希望大家多多关照!";
    
    [scrollView addSubview:aboutLabel];
    
    [aboutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(margin);
        make.right.equalTo(weakSelf.view).offset(-margin);
        make.top.equalTo(versionLabel.mas_bottom).offset(40);
        make.height.equalTo(@60);
    }];
    
    //团队标签
    UILabel *groupLabel = [[UILabel alloc] init];
    groupLabel.numberOfLines = 0;
    groupLabel.textColor = [UIColor grayColor];
    groupLabel.font = [UIFont systemFontOfSize:15];
    groupLabel.text = @"• 我们是几个14级小伙伴组成的独立开发团队, 立志打造一个学习资料分享和学习问答app!我们在努力!";
    
    [scrollView addSubview:groupLabel];
    
    [groupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(aboutLabel);
        make.top.equalTo(aboutLabel.mas_bottom).offset(10);
        make.height.equalTo(aboutLabel);
    }];
    
    //邮箱支付宝标签
    UILabel *accountLabel = [[UILabel alloc] init];
    accountLabel.numberOfLines = 0;
    accountLabel.textColor = [UIColor grayColor];
    accountLabel.font = [UIFont systemFontOfSize:14];
    accountLabel.text = @"• 我的邮箱及支付宝 727489038@qq.com";
    
    [scrollView addSubview:accountLabel];
    
    [accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(groupLabel);
        make.top.equalTo(groupLabel.mas_bottom).offset(20);
        make.height.equalTo(@40);
    }];
    
    //反馈建议标签
    UILabel *feedbackLabel = [[UILabel alloc] init];
    feedbackLabel.numberOfLines = 0;
    feedbackLabel.textColor = [UIColor grayColor];
    feedbackLabel.font = [UIFont systemFontOfSize:14];
    feedbackLabel.text = @"• 有任何意见建议欢迎反馈";
    
    [scrollView addSubview:feedbackLabel];
    
    [feedbackLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(groupLabel);
        make.top.equalTo(accountLabel.mas_bottom);
        make.height.equalTo(@40);
    }];
    
    //打赏标签
    UILabel *donateLabel = [[UILabel alloc] init];
    donateLabel.numberOfLines = 0;
    donateLabel.textColor = [UIColor grayColor];
    donateLabel.font = [UIFont systemFontOfSize:14];
    donateLabel.text = @"• 你的支持让开发者得到肯定并更开心地写代码";
    
    [scrollView addSubview:donateLabel];
    
    [donateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(groupLabel);
        make.top.equalTo(feedbackLabel.mas_bottom);
        make.height.equalTo(@40);
    }];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.mas_equalTo(weakSelf.view).insets(UIEdgeInsetsMake(0, 0, bar.bounds.size.height, 0));
        
        make.bottom.mas_equalTo(donateLabel.mas_bottom).offset(margin);
        
    }];
}

- (NSString *)version {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

- (void)donate:(UIButton *)button {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"alipayqr://platformapi/startapp?saId=10000007&qrcode=https://qr.alipay.com/aex07582k8zs99mpldqsb20"]];
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];;
    
    [UIView animateWithDuration:kAnimationTime animations:^{
        CGRect frame = self.tabBarController.tabBar.frame;
        frame.origin.y += frame.size.height;
        [self.tabBarController.tabBar setFrame:frame];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];

    [UIView animateWithDuration:kAnimationTime animations:^{
        CGRect frame = self.tabBarController.tabBar.frame;
        frame.origin.y -= frame.size.height;
        [self.tabBarController.tabBar setFrame:frame];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
