//
//  ZWCountDownPickerView.m
//  Qimokaola
//
//  Created by Administrator on 2017/2/21.
//  Copyright © 2017年 Administrator. All rights reserved.
//

#import "ZWCountDownPickerView.h"

#import "ZWHUDTool.h"
#import "NSDate+Extension.h"

#define kDatePickerViewHeight 216
#define kToolbarHeight 45
#define kBottomViewHeight (kDatePickerViewHeight + kToolbarHeight)

#define kAnimationDuration 0.2


@interface ZWCountDownPickerView ()

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIView *toolbar;
@property (nonatomic, weak) UIDatePicker *datePicker;
@property (nonatomic, weak) UILabel *dateLabel;

@end

@implementation ZWCountDownPickerView


- (instancetype)initWithTime:(NSDate *)date {
    if (self = [self initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)]) {
        self.date = date ? date : [NSDate date];
        [self setupViews];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"CountDownPickerView dealloc");
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    
    UIView *topView = [[UIView alloc] initWithFrame:self.frame];
    topView.backgroundColor = RGB(46, 49, 50);
    topView.layer.opacity = 0.3;
    [topView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSelf)]];
    [self addSubview:topView];
    self.topView = topView;
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenH, kScreenW, kBottomViewHeight)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self insertSubview:bottomView aboveSubview:topView];
    self.bottomView = bottomView;
    
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kToolbarHeight)];
    toolbar.backgroundColor = defaultPlaceHolderColor;
    [bottomView addSubview:toolbar];
    self.toolbar = toolbar;
    
    CGFloat finishButtonWidth = 50;
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    finishBtn.frame = CGRectMake(kScreenW - finishButtonWidth, 0, finishButtonWidth, kToolbarHeight);
    [finishBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn addTarget: self action:@selector(finishPickDate) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:finishBtn];
    
    UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancleButton.frame = CGRectMake(0, 0, finishButtonWidth, kToolbarHeight);
    [cancleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancleButton addTarget: self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(finishButtonWidth, 0, kScreenW - finishButtonWidth * 2.0, kToolbarHeight)];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    [toolbar addSubview:dateLabel];
    self.dateLabel = dateLabel;
    
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, kToolbarHeight, kScreenW, kDatePickerViewHeight)];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.minuteInterval = 5;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    datePicker.date = self.date;
    datePicker.minimumDate = [self getPropriateMinDate];
    [self datePickerValueChanged:datePicker];
    [self.bottomView addSubview:datePicker];
    self.datePicker = datePicker;
}

- (void)datePickerValueChanged:(UIDatePicker *)datePicker {
    self.dateLabel.text = [datePicker.date dateStringForCountdown];
}

- (void)finishPickDate {
    NSDate *now = [NSDate date];
    // 选择器时间小于等于现在时间
    NSComparisonResult result = [self.datePicker.date compare:now];
    if (result == NSOrderedAscending) {
        [ZWHUDTool showHUDInView:self withTitle:@"所选时间不能小于当前时间" message:nil duration:1.0];
        self.datePicker.minimumDate = [self getPropriateMinDate];
        self.date = now;
        return;
    }
    if (self.completion) {
        self.completion(self.datePicker.date, self.dateLabel.text);
    }
    [self dismissSelf];
}

- (NSDate *)getPropriateMinDate {
    NSDate *date = [NSDate date];
    NSInteger minute = [[NSCalendar currentCalendar] component:NSCalendarUnitMinute fromDate:date] % 10;
    date = [date dateByAddingTimeInterval:(minute < 5 ? 5 - minute : 10 - minute) * 60];
    return date;
}

- (void)dismissSelf {
    self.topView.alpha = 0.0;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        weakSelf.bottomView.frame = CGRectMake(0, kScreenH, kScreenW, kBottomViewHeight);
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:kAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        weakSelf.bottomView.frame = CGRectMake(0, kScreenH - kBottomViewHeight, kScreenW, kBottomViewHeight);
    } completion:nil];
}

@end
