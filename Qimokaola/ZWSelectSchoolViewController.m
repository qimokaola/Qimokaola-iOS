//
//  ZWSelectSchoolViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/7/14.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWSelectSchoolViewController.h"
#import "ZWAPIRequestTool.h"

#import <YYKit/YYKit.h>

typedef NS_ENUM(NSUInteger, ZWSelectSchoolViewControllerCuerentType) {
    ZWSelectSchoolViewControllerCuerentTypeSchool,
    ZWSelectSchoolViewControllerCuerentTypeAcademy,
    ZWSelectSchoolViewControllerCuerentTypeEnterYear,
};

@interface ZWSelectSchoolViewController ()

@property (nonatomic, strong) NSArray *schools;
@property (nonatomic, strong) NSArray *academies;
@property (nonatomic, strong) NSDictionary *selectedSchool;
@property (nonatomic, strong) NSDictionary *selectedAcademy;
@property (nonatomic, strong) UIBarButtonItem *chooseSchool;
@property (nonatomic, strong) UIBarButtonItem *chooseAcademy;
@property (nonatomic, strong) NSArray *enterYearArray;
@property (nonatomic, assign) ZWSelectSchoolViewControllerCuerentType type;

@end

@implementation ZWSelectSchoolViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //设置tableView分割线只在数据条目显示
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    self.chooseSchool = [[UIBarButtonItem alloc] initWithTitle:@"换个学校" style:UIBarButtonItemStyleDone target:self action:@selector(fetchSchoolList)];
    self.chooseAcademy = [[UIBarButtonItem alloc] initWithTitle:@"换个学院" style:UIBarButtonItemStyleDone target:self action:@selector(fetchAcademiesList)];
    NSInteger currentYear = [[NSDate date] year];
    self.enterYearArray = @[@(currentYear), @(currentYear - 1), @(currentYear - 2), @(currentYear - 3), @(currentYear - 4)];
    // 开始时加载学校列表
    [self fetchSchoolList];
}


- (void)fetchSchoolList {
    _type = ZWSelectSchoolViewControllerCuerentTypeSchool;
    self.title = @"选择学校";
    [ZWAPIRequestTool requestListSchool:^(id response, BOOL success) {
        if (success) {
            self.navigationItem.rightBarButtonItem = nil;
            self.schools = [response objectForKey:kHTTPResponseResKey];
            [self.tableView reloadData];
        }
    }];
}

- (void)fetchAcademiesList {
    _type = ZWSelectSchoolViewControllerCuerentTypeAcademy;
    self.title = [self.selectedSchool objectForKey:@"name"];
    [ZWAPIRequestTool requestListAcademyWithParameter:@{@"college" : [self.selectedSchool objectForKey:@"id"]} result:^(id response, BOOL success) {
        if (success) {
            self.navigationItem.rightBarButtonItem = self.chooseSchool;
            self.academies = [(NSDictionary *)response objectForKey:kHTTPResponseResKey];
            [self.tableView reloadData];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_type == ZWSelectSchoolViewControllerCuerentTypeSchool) {
        return self.schools.count;
    } else if (_type == ZWSelectSchoolViewControllerCuerentTypeAcademy) {
        return self.academies.count;
    } else {
        return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if (_type == ZWSelectSchoolViewControllerCuerentTypeSchool || _type == ZWSelectSchoolViewControllerCuerentTypeAcademy) {
        NSDictionary *dict = _type == ZWSelectSchoolViewControllerCuerentTypeSchool ? [self.schools objectAtIndex:indexPath.row] : [self.academies objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict objectForKey:@"name"];
    } else {
        NSNumber *enterYear = [self.enterYearArray objectAtIndex:indexPath.row];
        cell.textLabel.text = enterYear.stringValue;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_type == ZWSelectSchoolViewControllerCuerentTypeSchool) {
        self.selectedSchool = [self.schools objectAtIndex:indexPath.row];
        [self fetchAcademiesList];
    } else if (_type == ZWSelectSchoolViewControllerCuerentTypeAcademy) {
        self.selectedAcademy = [self.academies objectAtIndex:indexPath.row];
        self.title = [self.selectedAcademy objectForKey:@"name"];
        _type = ZWSelectSchoolViewControllerCuerentTypeEnterYear;
        self.navigationItem.rightBarButtonItem = self.chooseAcademy;
        [self.tableView reloadData];
    } else {
        if (_completionBlock) {
            NSNumber *selectedEnterYear = [self.enterYearArray objectAtIndex:indexPath.row];
            NSDictionary *result = [NSDictionary dictionaryWithObjects:@[self.selectedSchool, self.selectedAcademy, selectedEnterYear] forKeys:@[@"school", @"academy", @"enterYear"]];
            NSLog(@"selected school, academy, enterYear info: %@", result);
            _completionBlock(result);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    }
    
}

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
