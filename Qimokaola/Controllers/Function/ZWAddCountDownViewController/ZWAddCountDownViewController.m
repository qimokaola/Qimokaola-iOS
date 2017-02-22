//
//  ZWAddCountDownViewController.m
//  Qimokaola
//
//  Created by Administrator on 2017/2/20.
//  Copyright © 2017年 Administrator. All rights reserved.
//

#import "ZWAddCountDownViewController.h"

#import "ZWCountDownPickerView.h"

#define bottomViewHeight 200

@interface ZWAddCountDownViewController ()

@property (weak, nonatomic) IBOutlet UITextField *eaxmNameField;
@property (weak, nonatomic) IBOutlet UITextField *examLocationField;
@property (weak, nonatomic) IBOutlet UIButton *alarmTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *examTimeBtn;

@end

@implementation ZWAddCountDownViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.allowsSelection = NO;
    
    UIBarButtonItem *finishItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishTheCountdown)];
    self.navigationItem.rightBarButtonItem = finishItem;
    
    [self.examTimeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.examTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

#pragma mark 选择提醒时间

- (IBAction)chooseAlarmTime:(id)sender {
    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:@"设置提醒时间" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    // 关闭提醒
    UIAlertAction *shutdownAlarmAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alerController addAction:shutdownAlarmAction];
    // 取消更改
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alerController addAction:cancleAction];
    // 提醒时间
    NSArray *alarmTimesArray = @[@"提前半小时", @"提前1小时", @"提前2小时", @"提前1天", @"提前2天", @"提前3天", @"提前5天", @"提前7天"];
    [alarmTimesArray enumerateObjectsUsingBlock:^(id  _Nonnull alarmTime, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *alertTimeAction = [UIAlertAction actionWithTitle:alarmTime style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"%@, %d", alarmTime, (int)idx);
        }];
        [alerController addAction:alertTimeAction];
    }];
    [self presentViewController:alerController animated:YES completion:nil];
}

- (IBAction)chooseCountdownTime:(id)sender {
    ZWCountDownPickerView *pickerView = [[ZWCountDownPickerView alloc] init];
    __weak __typeof(self) weakSelf = self;
    pickerView.completion = ^(NSDate *date, NSString *dateString) {
        [weakSelf.examTimeBtn setTitle:dateString forState:UIControlStateNormal];
        weakSelf.examTimeBtn.selected = YES;
    };
    [pickerView show];
}


#pragma mark - Common Methods

- (void)finishTheCountdown {
   
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 20;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 40)];
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
