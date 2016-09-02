//
//  ZWCreateCountDownViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/5/20.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWCreateCountDownViewController.h"
#import "UIColor+Extension.h"
#import "Masonry.h"

#define labelTextColor RGB(54., 114., 220.)
#define margin 20


@interface ZWCreateCountDownViewController ()

@property (nonatomic, strong) UITextField *hintContentField;

@end

@implementation ZWCreateCountDownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) weakSelf = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //设置导航栏样式
    self.navigationController.navigationBar.barTintColor = [UIColor universalColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:19],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.title = @"新建倒计时";
    
    //导航栏完成按钮
    UIBarButtonItem *finishItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishEditing)];
    self.navigationItem.rightBarButtonItem = finishItem;
    
    //取消按钮
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelEditing)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    //为兼容3.5设备采用UIScrollView
    UIScrollView *scrollView = ({
        UIScrollView *view = [[UIScrollView alloc] init];
        [self.view addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf.view);
        }];
        
        view;
    });
    
    //倒计时， 提醒时间字体
    UIFont *headFont = [UIFont systemFontOfSize:16];
    
    //添加倒计时标签
    UILabel *countdDownLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 1;
        label.text = @"倒计时";
        label.textColor = labelTextColor;
        label.font = headFont;
        [scrollView addSubview:label];
        
        CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName: headFont}];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_equalTo(scrollView).with.offset(margin);
            make.size.mas_equalTo(size);
        }];
        
        label;
    });
    
    //添加分隔线
    UIView *divider1 = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = labelTextColor;
        [scrollView addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.view).with.offset(margin);
            make.right.mas_equalTo(weakSelf.view).with.offset(- margin);
            make.height.mas_equalTo(1);
            make.top.mas_equalTo(countdDownLabel.mas_bottom).with.offset(5);
        }];
       
        view;
    });
    
    //提醒内容时间等字体
    UIFont *contentFont = [UIFont systemFontOfSize:17];
    
    //添加提醒内容标签
    UILabel *hintContentLabel = ({
        UILabel *lable = [[UILabel alloc] init];
        lable.numberOfLines = 1;
        lable.text = @"提醒内容";
        lable.textColor = [UIColor blackColor];
        lable.font = contentFont;
        [scrollView addSubview:lable];
        
        CGSize size = [lable.text sizeWithAttributes:@{NSFontAttributeName: contentFont}];
        [lable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.view).with.offset(margin);
            make.top.mas_equalTo(divider1.mas_bottom).with.offset(margin / 2);
            make.size.mas_equalTo(size);
        }];
        
        lable;
    });
    
    self.hintContentField = ({
        UITextField *field = [[UITextField alloc] init];
        field.font = contentFont;
        field.placeholder = @"输入提醒内容";
        [scrollView addSubview:field];
        
        [field mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(hintContentLabel);
            make.left.mas_equalTo(weakSelf.view).with.offset(5 * margin);
            make.right.mas_equalTo(weakSelf.view).with.offset(- margin);
        }];
        
        field;
    });

}



- (void)cancelEditing {
    [self dismissView];
}

- (void)finishEditing {
    [self dismissView];
}

- (void)dismissView {
    [self.view endEditing:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
