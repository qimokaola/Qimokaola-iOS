
//
//  ZWFeedDetailViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/8/28.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWFeedDetailViewController.h"
#import "SDWeiXinPhotoContainerView.h"
#import "UIColor+Extension.h"
#import "ZWCommentCell.h"
#import "ZWFeedComposeViewController.h"
#import "ZWHUDTool.h"

#import "ZWUserDetailViewController.h"

#import "UIColor+Extension.h"

#import "UMComResouceDefines.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SDAutoLayout/SDAutoLayout.h>
#import <YYKit/YYKit.h>
#import <LinqToObjectiveC/LinqToObjectiveC.h>

#define kCommentTextViewInitilzedHeight 35
#define kCommentTextViewMaxHeight 85
#define kCommentTextLimit 140

#define kCommentCellIdentifier @"kCommentCellIdentifier"

@interface ZWFeedDetailViewController () <UITableViewDataSource, UITableViewDelegate, ZWCommentCellDelegate, YYTextViewDelegate>

/**
 评论数组
 */
@property (nonatomic, strong) NSMutableArray *comments;

/**
 评论视图
 */
@property (nonatomic, strong) UITableView *tableView;

/**
 feed详情
 */
@property (nonatomic, strong) UIView *headerView;

/**
 分隔视图
 */
@property (nonatomic, strong) UIView *separatorView;

/**
 用户头像
 */
@property (nonatomic, strong) UIImageView *avatarView;

/**
 用户名
 */
@property (nonatomic, strong) UILabel *nameLabel;

/**
 用户性别图片
 */
@property (nonatomic, strong) UIImageView *genderView;

/**
 时间标签
 */
@property (nonatomic, strong) UILabel *timeLabel;

/**
 学校标签
 */
@property (nonatomic, strong) UILabel *schoolLabel;

/**
 内容
 */
@property (nonatomic, strong) UILabel *contentLabel;

/**
 图片容器
 */
@property (nonatomic, strong) SDWeiXinPhotoContainerView *picContainerView;

/**
 喜欢按钮
 */
@property (nonatomic, strong) UIButton *likeButton;

/**
 评论按钮
 */
@property (nonatomic, strong) UIButton *collectButton;

/**
 操作按钮
 */
@property (nonatomic, strong) UIButton *moreButton;

/**
 评论View
 */
@property (nonatomic, strong) UIView *commentView;

/**
 评论框
 */
@property (nonatomic, strong) YYTextView *commentTextView;

/**
 匿名按钮
 */
@property (nonatomic, strong) UIButton *anonymousButton;

/**
 匿名标签
 */
@property (nonatomic, strong) UILabel *anonymousLabel;

/**
 字数限制标签
 */
@property (nonatomic, strong) UILabel *commentLimitLabel;

/**
 将要评论的评论
 */
@property (nonatomic, strong) UMComComment *commentToCommentWith;

/**
 是否点赞
 */
@property (nonatomic, assign) BOOL isLiked;

/**
 是否收藏
 */
@property (nonatomic, assign) BOOL isCollected;


@end

@implementation ZWFeedDetailViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.title = @"详情";
    self.view.backgroundColor = defaultBackgroundColor;
    _comments = [NSMutableArray array];
    
    UIBarButtonItem *moreBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStyleDone target:self action:@selector(feedMoreButtonClicked)];
    self.navigationItem.rightBarButtonItem = moreBarButtonItem;
    
    __weak __typeof(self) weakSelf = self;
    // 监听要评论的评论 来设置评论框的placeholder
    [RACObserve(self, commentToCommentWith) subscribeNext:^(UMComComment *comment) {
        NSString *placeholderPlainText = nil;
        if (comment) {
            if (DecodeAnonyousCode(comment.custom) == 0) {
                placeholderPlainText = [NSString stringWithFormat:@"回复 %@", comment.creator.name];
            } else {
                placeholderPlainText = @"回复 某同学";
            }
        } else {
            placeholderPlainText = @"点此输入你的评论";
        }
        NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:placeholderPlainText];
        atr.color = UIColorHex(b4b4b4);
        atr.font = [UIFont systemFontOfSize:17];
        weakSelf.commentTextView.placeholderAttributedText = atr;
    }];
    
    // 添加子视图
    [self zw_addSubViews];
    // 根据feed加载数据
    [self loadDetailData];
    // 获取feed的评论并加载
    [self fetchCommentsData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_isCommentTextViewNeedFocusWhenInit) {
        [self.commentTextView becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    NSLog(@"dealloc detail");
}

#pragma mark - Views

- (void)zw_addSubViews {
    [self initTableView];
    [self initHeaderView];
    [self initCommentView];
}

- (void)initCommentView {
    _commentView = [[UIView alloc] init];
    _commentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_commentView];
    
    _commentTextView = [[YYTextView alloc] init];
    _commentTextView.backgroundColor = RGB(210., 219., 226.);
    _commentTextView.showsVerticalScrollIndicator = NO;
    _commentTextView.alwaysBounceVertical = YES;
    _commentTextView.allowsCopyAttributedString = NO;
    _commentTextView.font = ZWFont(17);
    _commentTextView.delegate = self;
    _commentTextView.returnKeyType = UIReturnKeySend;
    _commentTextView.scrollsToTop = NO;
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:@"点此输入你的评论"];
    atr.color = UIColorHex(b4b4b4);
    atr.font = [UIFont systemFontOfSize:17];
    _commentTextView.placeholderAttributedText = atr;

    _anonymousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_anonymousButton setImage:[UIImage imageNamed:@"icon_detail_checkbox"] forState:UIControlStateNormal];
    [_anonymousButton setImage:[UIImage imageNamed:@"icon_detail_checkbox_selected"] forState:UIControlStateSelected];
    [[_anonymousButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
        button.selected = !button.selected;
    }];
    _anonymousButton.selected = YES;
    
    _anonymousLabel = [[UILabel alloc] init];
    _anonymousLabel.text = @"匿名";
    _anonymousLabel.textColor = [UIColor blackColor];
    _anonymousLabel.font = ZWFont(15);
    
    _commentLimitLabel = [[UILabel alloc] init];
    _commentLimitLabel.text = @"140";
    _commentLimitLabel.textColor = [UIColor lightGrayColor];
    _commentLimitLabel.font = ZWFont(14);
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = [UIColor lightGrayColor];
    
    NSArray *subViews = @[topLine, _commentTextView, _anonymousButton, _anonymousLabel, _commentLimitLabel];
    [_commentView sd_addSubviews:subViews];
    
    CGFloat larginMargin = 15.f;
    CGFloat margin = 10.f;
    CGFloat smallMargin = 7.f;
    CGFloat buttonHeight = 20.f;
    CGFloat bottomMargin = - (margin + buttonHeight + (larginMargin - smallMargin));
    
    _commentView.sd_layout
    .leftEqualToView(self.view)
    .rightEqualToView(self.view);
    
    topLine.sd_layout
    .leftEqualToView(_commentView)
    .rightEqualToView(_commentView)
    .topEqualToView(_commentView)
    .heightIs(0.5);
    
    _commentTextView.sd_layout
    .leftSpaceToView(_commentView, larginMargin)
    .rightSpaceToView(_commentView, larginMargin)
    .topSpaceToView(_commentView, smallMargin)
    .heightIs(kCommentTextViewInitilzedHeight)
    .minHeightIs(kCommentTextViewInitilzedHeight)
    .maxHeightIs(kCommentTextViewMaxHeight);
    _commentTextView.sd_cornerRadius = @10;
    
    
    _anonymousButton.sd_layout
    .leftEqualToView(_commentTextView)
    .topSpaceToView(_commentTextView, larginMargin)
    .heightIs(buttonHeight)
    .widthEqualToHeight();
    
    _anonymousLabel.sd_layout
    .centerYEqualToView(_anonymousButton)
    .leftSpaceToView(_anonymousButton, margin)
    .heightIs(buttonHeight)
    .widthIs(50);
    
    _commentLimitLabel.sd_layout
    .centerYEqualToView(_anonymousButton)
    .rightEqualToView(_commentTextView)
    .heightIs(buttonHeight);
    [_commentLimitLabel setSingleLineAutoResizeWithMaxWidth:200];
    
    [_commentView setupAutoHeightWithBottomView:_anonymousButton bottomMargin:margin];
    
    _commentView.sd_layout.bottomSpaceToView(self.view, bottomMargin);
    
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(NSNotification *notification) {
        @strongify(self)
        // 获取键盘的位置和大小
        CGRect keyboardBounds = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        
        // Need to translate the bounds to account for rotation.
        keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
        // 动画改变位置
        [UIView animateWithDuration:[duration doubleValue] animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:[duration doubleValue]];
            [UIView setAnimationCurve:[curve intValue]];
            // 更改输入框的位置
            self.commentView.sd_layout.bottomSpaceToView(self.view, keyboardBounds.size.height);
            [self.commentView updateLayout];
        }];
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(NSNotification *notification) {
        @strongify(self)
        NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        
        // 动画改变位置
        [UIView animateWithDuration:[duration doubleValue] animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:[duration doubleValue]];
            [UIView setAnimationCurve:[curve intValue]];
            // 更改输入框的位置
            self.commentView.sd_layout.bottomSpaceToView(self.view, bottomMargin);
            [self.commentView updateLayout];
        }];
    }];
}

- (void)initTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.contentInset = UIEdgeInsetsMake(64, 0, 64, 0);
    _tableView.scrollIndicatorInsets = _tableView.contentInset;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[ZWCommentCell class] forCellReuseIdentifier:kCommentCellIdentifier];
    
    __weak __typeof(self) weakSelf = self;
    [_tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(UIGestureRecognizer *recognizer) {
        [weakSelf.commentTextView endEditing:YES];
        if (weakSelf.commentToCommentWith) {
            weakSelf.commentToCommentWith = nil;
        }
    }]];
}

- (void)initHeaderView {
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.width = kScreenW;
    
    // 内容字体大小
    CGFloat contentLabelFontSize = 16;
    // 中等文字字体大小
    CGFloat midFontSize = 15;
    // 较小文本的字体大小
    CGFloat smallFontSize = 12;
    
    CGFloat margin = 10.f;
    CGFloat smallMargin = 5.0f;
    CGFloat avatarHeightOrWidth = 40;
    CGFloat singleLineLabelMaxWidth = 200.f;
    CGFloat genderViewSize = 15;
    CGFloat separatorViewHeight = 10.f;
    UIColor *separatorViewColor = defaultBackgroundColor;
    
    CGFloat buttonHieght = 45.f;
    CGSize imageSize = CGSizeMake(buttonHieght, buttonHieght);
    
    _separatorView = [[UIView alloc] init];
    _separatorView.backgroundColor = separatorViewColor;
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.layer.cornerRadius = avatarHeightOrWidth / 2;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.userInteractionEnabled = YES;
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToUser)]];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:midFontSize];
    _nameLabel.numberOfLines = 1;
    
    _genderView = [[UIImageView alloc] init];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:smallFontSize];
    _timeLabel.numberOfLines = 1;
    _timeLabel.textColor = [UIColor lightGrayColor];
    
    _schoolLabel = [[UILabel alloc] init];
    _schoolLabel.font = [UIFont systemFontOfSize:smallFontSize];
    _schoolLabel.numberOfLines = 1;
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:contentLabelFontSize];
    _contentLabel.numberOfLines = 0;
    
    _picContainerView = [[SDWeiXinPhotoContainerView alloc] init];
    
    _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_likeButton setImage:[[UIImage imageNamed:@"icon_detail_liked"] imageByResizeToSize:imageSize] forState:UIControlStateNormal];
    [_likeButton addTarget:self action:@selector(likeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_collectButton setImage:[[UIImage imageNamed:@"icon_detail_collected"] imageByResizeToSize:imageSize] forState:UIControlStateNormal];
    [_collectButton addTarget:self action:@selector(collectButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *views = @[_avatarView, _nameLabel, _genderView, _timeLabel, _schoolLabel, _contentLabel, _picContainerView, _separatorView, _likeButton, _collectButton];
    
    [_headerView sd_addSubviews:views];
    
    _separatorView.sd_layout
    .leftEqualToView(_headerView)
    .rightEqualToView(_headerView)
    .topEqualToView(_headerView)
    .heightIs(separatorViewHeight);
    
    _avatarView.sd_layout
    .leftSpaceToView(_headerView, margin)
    .topSpaceToView(_separatorView, margin)
    .heightIs(avatarHeightOrWidth)
    .widthIs(avatarHeightOrWidth);
    
    _nameLabel.sd_layout
    .leftSpaceToView(_avatarView, margin)
    .topEqualToView(_avatarView)
    .heightIs(18);
    [_nameLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
    
    _genderView.sd_layout
    .leftSpaceToView(_nameLabel, smallMargin)
    .centerYEqualToView(_nameLabel)
    .heightIs(genderViewSize)
    .widthIs(genderViewSize);
    
    _timeLabel.sd_layout
    .leftEqualToView(_nameLabel)
    .bottomEqualToView(_avatarView)
    .heightIs(15);
    [_timeLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
    
    _schoolLabel.sd_layout
    .leftSpaceToView(_timeLabel, smallMargin)
    .topEqualToView(_timeLabel)
    .heightIs(15);
    [_schoolLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
    
    _contentLabel.sd_layout
    .leftSpaceToView(_headerView, margin)
    .rightSpaceToView(_headerView, margin)
    .topSpaceToView(_avatarView, margin)
    .autoHeightRatio(0);
    
    _picContainerView.sd_layout
    .leftEqualToView(_contentLabel);
    
    _likeButton.sd_layout
    .heightIs(buttonHieght)
    .widthEqualToHeight()
    .centerXIs(_headerView.centerX_sd - margin * 4);
    
    _collectButton.sd_layout
    .topEqualToView(_likeButton)
    .heightRatioToView(_likeButton, 1.0)
    .widthEqualToHeight()
    .centerXIs(_headerView.centerX_sd + margin * 4);
    
}


#pragma mark - Setters and Getters

- (void)setIsLiked:(BOOL)isLiked {
    _isLiked = isLiked;
    _likeButton.selected = isLiked;
}

- (void)setIsCollected:(BOOL)isCollected {
    _isCollected = isCollected;
    _collectButton.selected = _isCollected;
}

#pragma mark - Common Methods

- (void)loadDetailData {
    if (DecodeAnonyousCode(_feed.custom) == 0) {
        [_avatarView setImageWithURL:[NSURL URLWithString:_feed.creator.icon_url.small_url_string] placeholder:[UIImage imageNamed:@"avatar"]];
        _nameLabel.text = _feed.creator.name;
        _genderView.image = _feed.creator.gender.intValue == 0 ? [UIImage imageNamed:@"icon_female"] : [UIImage imageNamed:@"icon_male"];
        _schoolLabel.text = createSchoolName(_feed.creator.custom);
    } else {
        _avatarView.image = [UIImage imageNamed:@"avatar"];
        _nameLabel.text = kStudentCircleAnonyousName;
        _genderView.image = [UIImage imageNamed:@"icon_female"];
        _schoolLabel.text = nearBySchoolName;
    }
    
    _timeLabel.text = createTimeString(_feed.create_time);
    
    _contentLabel.text = _feed.text;
    
    self.isLiked = _feed.liked.boolValue;
    self.isCollected = _feed.has_collected.boolValue;
    
    _picContainerView.picPathStringsArray = [_feed.image_urls linq_select:^id(UMComImageUrl *item) {
        return item.small_url_string;
    }];
    
    _picContainerView.highQuantityPicArray = [_feed.image_urls linq_select:^id(UMComImageUrl *item) {
        return item.large_url_string;
    }];
    
    CGFloat margin = 20.f;
    CGFloat picContainerViewTopMargin = 0.f;
    if (_feed.image_urls && _feed.image_urls.count > 0) {
        picContainerViewTopMargin = 10;
        _likeButton.sd_layout.topSpaceToView(_picContainerView, margin);
    } else {
        _likeButton.sd_layout.topSpaceToView(_contentLabel, margin);
    }
    
    _picContainerView.sd_layout.topSpaceToView(_contentLabel, picContainerViewTopMargin);
    
    [_headerView setupAutoHeightWithBottomView:_likeButton bottomMargin:margin];
    [_headerView layoutSubviews];
    
    _tableView.tableHeaderView = _headerView;
}

- (void)sendComment {
    if (self.commentTextView.text.length == 0 || self.commentTextView.text.length > 140) {
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"内容长度要在1-140以内" message:nil duration:kShowHUDMid];
        return;
    }
    __weak __typeof(self) weakSelf = self;
    NSString *anonyousString = [NSString stringWithFormat:@"{\"a\" : %d}", _anonymousButton.selected ? 1 : 0];
    MBProgressHUD * hud = [ZWHUDTool excutingHudInView:self.navigationController.view title:@"正在发送"];
    NSLog(@"%@ %@", _commentToCommentWith.commentID, _commentToCommentWith.creator.uid);
    [[UMComDataRequestManager defaultManager] commentFeedWithFeedID:_feed.feedID
                                                     commentContent:_commentTextView.text
                                                     replyCommentID:_commentToCommentWith.commentID
                                                        replyUserID:_commentToCommentWith ? _commentToCommentWith.creator.uid : _feed.creator.uid
                                               commentCustomContent:anonyousString
                                                             images:nil
                                                         completion:^(NSDictionary *responseObject, NSError *error) {
                                                             hud.mode = MBProgressHUDModeText;
                                                             NSString *resultContent = nil;
                                                             if (responseObject) {
                                                                 [weakSelf insertCommentToTop:responseObject[@"data"]];
                                                                 resultContent =  @"发送成功";
                                                                 weakSelf.commentTextView.text = nil;
                                                                 if (weakSelf.commentToCommentWith) {
                                                                     weakSelf.commentToCommentWith = nil;
                                                                 }
                                                                 // 重置匿名按钮状态
                                                                 weakSelf.anonymousButton.selected = YES;
                                                             } else {
                                                                 if (error.code == 20024) {
                                                                     resultContent = @"短时间内不可多次发送同样内容";
                                                                 } else {
                                                                     resultContent = @"出错了，发送失败";
                                                                 }
                                                             }
                                                             hud.label.text = resultContent;
                                                             [hud hideAnimated:YES afterDelay:kShowHUDShort];
                                                         }];
}

- (void)insertCommentToTop:(UMComComment *)comment {
    [self.comments insertObject:comment atIndex:0];
    [self.tableView insertRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
    if (self.commentCountChangedCompletion) {
        self.commentCountChangedCompletion(@(self.comments.count));
    }
}

- (void)feedMoreButtonClicked {
    [self showAlertControllerForDealWithFeed:YES orForComment:nil andIndex:0];
}

// for feed or comment
// 根据处理的类型操作
- (void)showAlertControllerForDealWithFeed:(BOOL)isForFeed orForComment:(UMComComment *)comment andIndex:(NSInteger) index {
    __weak __typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if ([isForFeed ? _feed.creator.uid : comment.creator.uid isEqualToString:[UMComSession sharedInstance].loginUser.uid]) {
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (isForFeed) {
                [[UMComDataRequestManager defaultManager] feedDeleteWithFeedID:_feed.feedID
                                                                    completion:^(NSDictionary *responseObject, NSError *error) {
                                                                        if (responseObject) {
                                                                            if (weakSelf.deleteCompletion) {
                                                                                weakSelf.deleteCompletion();
                                                                            }
                                                                            [weakSelf.navigationController popViewControllerAnimated:YES];
                                                                        } else {
                                                                            [ZWHUDTool showHUDInView:weakSelf.navigationController.view
                                                                                           withTitle:@"出错了，删除失败"
                                                                                             message:nil
                                                                                            duration:kShowHUDMid];
                                                                        }
                                                                    }];
            } else {
                [[UMComDataRequestManager defaultManager] commentDeleteWithCommentID:comment.commentID
                                                                              feedID:_feed.feedID
                                                                          completion:^(NSDictionary *responseObject, NSError *error) {
                                                                              if (responseObject) {
                                                                                  [weakSelf.comments removeObjectAtIndex:index];
                                                                                  [weakSelf.tableView deleteRow:index inSection:0 withRowAnimation:UITableViewRowAnimationFade];
                                                                                  // 执行回调更新feed流页面数据
                                                                                  if (weakSelf.commentCountChangedCompletion) {
                                                                                      weakSelf.commentCountChangedCompletion(@(weakSelf.comments.count));
                                                                                  }
                                                                              } else {
                                                                                  [ZWHUDTool showHUDInView:weakSelf.navigationController.view
                                                                                                 withTitle:@"出错了，删除失败"
                                                                                                   message:nil
                                                                                                  duration:kShowHUDMid];
                                                                              }
                                                                          }];
            }
        }];
        [alertController addAction:deleteAction];
    } else {
        UIAlertAction *reportUserAction = [UIAlertAction actionWithTitle:@"举报用户" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UMComDataRequestManager defaultManager] userSpamWitUID:isForFeed ? _feed.creator.uid : comment.creator.uid
                                                          completion:^(NSDictionary *responseObject, NSError *error) {
                                                              [weakSelf dealWiteSpamResult:responseObject error:error];
                                                          }];
        }];
        UIAlertAction *reportConentAction = [UIAlertAction actionWithTitle:@"举报内容" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (isForFeed) {
                [[UMComDataRequestManager defaultManager] feedSpamWithFeedID:_feed.feedID
                                                                  completion:^(NSDictionary *responseObject, NSError *error) {
                                                                      [weakSelf dealWiteSpamResult:responseObject error:error];
                                                                  }];
            } else {
                [[UMComDataRequestManager defaultManager] commentSpamWithCommentID:comment.commentID
                                                                        completion:^(NSDictionary *responseObject, NSError *error) {
                                                                            [weakSelf dealWiteSpamResult:responseObject error:error];
                                                                        }];
            }
        }];
        [alertController addAction:reportUserAction];
        [alertController addAction:reportConentAction];
    }
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        [pasteBoard setString:isForFeed ? _feed.text : comment.content];
        [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"已复制内容至剪贴板" message:nil duration:kShowHUDMid];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancleAction];
    [alertController addAction:copyAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)dealWiteSpamResult:(NSDictionary *)responseObject error:(NSError *)error {
    NSString *content = nil;
    if (responseObject) {
        content = @"举报成功";
    } else {
        NSLog(@"%@", error);
        if (error.code == 40002) {
           content = @"该用户或内容已被举报";
        } else {
            content = @"出错了，举报失败";
        }
    }
    [ZWHUDTool showHUDInView:self.navigationController.view
                   withTitle:content
                     message:nil
                    duration:kShowHUDMid];
}

- (void)fetchCommentsData {
    __weak __typeof(self) weakSelf = self;
    [[UMComDataRequestManager defaultManager] fetchCommentsWithFeedId:_feed.feedID
                                                        commentUserId:nil
                                                             sortType:UMComCommentSortType_Default
                                                                count:9999
                                                           completion:^(NSDictionary *responseObject, NSError *error) {
                                                               if (responseObject) {
                                                                   [weakSelf.comments addObjectsFromArray:responseObject[@"data"]];
                                                                   [weakSelf.tableView reloadData];
                                                               } else {
                                                                   NSLog(@"%@", error);
                                                               }
                                                           }];
}

- (void)gotoUserDetailViewController:(UMComUser *)user {
    ZWUserDetailViewController *userDetailViewController = [[ZWUserDetailViewController alloc] init];
    userDetailViewController.user = user;
    [self.navigationController pushViewController:userDetailViewController animated:YES];
}

#pragma mark - Actions

- (void)likeButtonClicked {
    __weak __typeof(self) weakSelf = self;
    [[UMComDataRequestManager defaultManager] feedLikeWithFeedID:_feed.feedID
                                                          isLike:!_isLiked
                                                      completion:^(NSDictionary *responseObject, NSError *error) {
                                                          if (responseObject) {
                                                              weakSelf.isLiked = !weakSelf.isLiked;
                                                              // 执行回调更新feed流页面数据
                                                              if (weakSelf.isLikedChangedCompletion) {
                                                                  weakSelf.isLikedChangedCompletion(weakSelf.isLiked);
                                                              }
                                                          } else {
                                                              [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"呀,出错了！" message:nil duration:kShowHUDMid];
                                                          }
                                                      }];
}


- (void)collectButtonClicked {
    __weak __typeof(self) weakSelf = self;
    [[UMComDataRequestManager defaultManager] feedFavouriteWithFeedId:_feed.feedID
                                                          isFavourite:!_isCollected
                                                      completionBlock:^(NSDictionary *responseObject, NSError *error) {
                                                          if (!error) {
                                                              weakSelf.isCollected = !weakSelf.isCollected;
                                                              if (weakSelf.isCollectedChangedCompletion) {
                                                                  weakSelf.isCollectedChangedCompletion(weakSelf.isCollected);
                                                              }
                                                          } else {
                                                              [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"呀,出错了！" message:nil duration:kShowHUDMid];
                                                          }
                                                      }];
}



- (void)clickToUser {
    if (DecodeAnonyousCode(_feed.custom) == 1) {
        return;
    }
    [self gotoUserDetailViewController:_feed.creator];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
    cell.comment = [self.comments objectAtIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [self.comments objectAtIndex:indexPath.row];
    return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"comment" cellClass:[ZWCommentCell class] contentViewWidth:kScreenWidth];
}

#pragma mark - ZWCommentCellDelegate

- (void)cell:(ZWCommentCell *)cell didClickUser:(UMComUser *)user {
    [self gotoUserDetailViewController:user];
}

- (void)didClickMoreButtonInInCell:(ZWCommentCell *)cell {
    [self showAlertControllerForDealWithFeed:NO orForComment:cell.comment andIndex:[self.comments indexOfObject:cell.comment]];
}

- (void)didClickCommentButtonInCell:(ZWCommentCell *)cell {
//    __weak __typeof(self) weakSelf = self;
//    ZWFeedComposeViewController *composeViewController = [[ZWFeedComposeViewController alloc] init];
//    composeViewController.composeType = ZWFeedComposeTypeReplyComment;
//    composeViewController.feedID = _feed.feedID;
//    composeViewController.commentID = cell.comment.commentID;
//    composeViewController.completion = ^(UMComComment *newComment) {
//        [weakSelf.comments insertObject:newComment atIndex:0];
//        [weakSelf.tableView insertRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationTop];
//    };
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeViewController];
//    [self presentViewController:nav animated:YES completion:nil];
    [self.commentTextView becomeFirstResponder];
    [self.tableView scrollToRow:[self.comments indexOfObject:cell.comment] inSection:0 atScrollPosition:UITableViewScrollPositionNone animated:YES];
    self.commentToCommentWith = cell.comment;
}

#pragma mark - YYTextViewDelegate

- (void)textViewDidChange:(YYTextView *)textView {
    self.commentLimitLabel.text = @(kCommentTextLimit - (int)textView.text.length).stringValue;
    CGFloat fixedWidth = textView.width_sd;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    // 使得高度永远不大于最大高度，防止出现滑动现象
    textView.sd_layout
    .heightIs(newSize.height > kCommentTextViewMaxHeight ? kCommentTextViewMaxHeight : newSize.height);
}


/**
 处理按下 发送 的逻辑

 @param textView textView
 @param range    range
 @param text     text

 @return should change text
 */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [textView resignFirstResponder];
        // 按下 发送键之后发送评论
        [self sendComment];
        return NO;
    }
    return YES;
}

#pragma mark - UISCrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.tableView] && self.commentTextView.isFirstResponder) {
        [self.commentTextView resignFirstResponder];
        // 清除要回复的comment
        if (self.commentToCommentWith) {
            self.commentToCommentWith = nil;
        }
    }
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



////
////  ZWFeedDetailViewController.m
////  Qimokaola
////
////  Created by Administrator on 16/8/28.
////  Copyright © 2016年 Administrator. All rights reserved.
////
//
//#import "ZWFeedDetailViewController.h"
//#import "SDWeiXinPhotoContainerView.h"
//#import "UIColor+Extension.h"
//#import "ZWCommentCell.h"
//#import "ZWFeedComposeViewController.h"
//#import "ZWHUDTool.h"
//
//#import "UIColor+Extension.h"
//
//#import "UMComResouceDefines.h"
//
//#import <SDAutoLayout/SDAutoLayout.h>
//#import <YYKit/YYKit.h>
//#import <LinqToObjectiveC/LinqToObjectiveC.h>
//
//#define kCommentCellIdentifier @"kCommentCellIdentifier"
//
//#define kBottomToolBarHeight 44.f
//
//@interface ZWFeedDetailViewController () <UITableViewDataSource, UITableViewDelegate, ZWCommentCellDelegate>
//
//@property (nonatomic, strong) NSMutableArray *comments;
//
//@property (nonatomic, strong) UIView *headerView;
//@property (nonatomic, strong) UITableView *tableView;
//// 用户头像
//@property (nonatomic, strong) UIImageView *avatarView;
//// 用户名
//@property (nonatomic, strong) UILabel *nameLabel;
//// 用户性别图片
//@property (nonatomic, strong) UIImageView *genderView;
//// 时间标签
//@property (nonatomic, strong) UILabel *timeLabel;
//// 学校标签
//@property (nonatomic, strong) UILabel *schoolLabel;
//// 内容
//@property (nonatomic, strong) UILabel *contentLabel;
//// 图片容器
//@property (nonatomic, strong) SDWeiXinPhotoContainerView *picContainerView;
//// toolbar
//@property (nonatomic, strong) UIView *toolbar;
//// 喜欢按钮
//@property (nonatomic, strong) UIButton *likeButton;
//// 评论按钮
//@property (nonatomic, strong) UIButton *commentButton;
//// 操作按钮
//@property (nonatomic, strong) UIButton *moreButton;
//// 分享按钮
//@property (nonatomic, strong) UIButton *shareButton;
//// 分隔视图
//@property (nonatomic, strong) UIView *separatorView;
//// 水平分隔线1 三个按钮之上
//@property (nonatomic, strong) UIView *horizontalLine1;
//// 竖直分隔线 点赞 与 分享按钮 之间
//@property (nonatomic, strong) UIView *verticalLine1;
//// 竖直分隔线 评论 与 分享按钮 之间
//@property (nonatomic, strong) UIView *verticalLine2;
//
//@end
//
//@implementation ZWFeedDetailViewController
//
//#pragma mark - Life Cycle
//
//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        [self zw_addSubViews];
//    }
//    return self;
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
//    self.title = @"详情";
//    self.view.backgroundColor = defaultBackgroundColor;
//    _comments = [NSMutableArray array];
//    
//    UIBarButtonItem *moreBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStyleDone target:self action:@selector(feedMoreButtonClicked)];
//    self.navigationItem.rightBarButtonItem = moreBarButtonItem;
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//}
//
//#pragma mark - Lazy Loading
//
//#pragma mark - Common Methods
//
//- (void)feedMoreButtonClicked {
//    [self showAlertControllerForDealWithFeed:YES orForComment:nil andIndex:0];
//}
//
//// for feed or comment
//// 根据处理的类型操作
//- (void)showAlertControllerForDealWithFeed:(BOOL)isForFeed orForComment:(UMComComment *)comment andIndex:(NSInteger) index {
//    __weak __typeof(self) weakSelf = self;
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    if ([isForFeed ? _feed.creator.uid : comment.creator.uid isEqualToString:[UMComSession sharedInstance].loginUser.uid]) {
//        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            if (isForFeed) {
//                [[UMComDataRequestManager defaultManager] feedDeleteWithFeedID:_feed.feedID
//                                                                    completion:^(NSDictionary *responseObject, NSError *error) {
//                                                                        if (responseObject) {
//                                                                            if (weakSelf.deleteCompletion) {
//                                                                                weakSelf.deleteCompletion();
//                                                                            }
//                                                                            [weakSelf.navigationController popViewControllerAnimated:YES];
//                                                                        } else {
//                                                                            [ZWHUDTool showHUDInView:weakSelf.navigationController.view
//                                                                                           withTitle:@"出错了，删除失败"
//                                                                                             message:nil
//                                                                                            duration:kShowHUDMid];
//                                                                        }
//                 }];
//            } else {
//                [[UMComDataRequestManager defaultManager] commentDeleteWithCommentID:comment.commentID
//                                                                              feedID:_feed.feedID
//                                                                          completion:^(NSDictionary *responseObject, NSError *error) {
//                                                                              if (responseObject) {
//                                                                                  [weakSelf.comments removeObjectAtIndex:index];
//                                                                                  [weakSelf.tableView deleteRow:index inSection:0 withRowAnimation:UITableViewRowAnimationFade];
//                                                                                  // 执行回调更新feed流页面数据
//                                                                                  if (weakSelf.commentCountChangedCompletion) {
//                                                                                      weakSelf.commentCountChangedCompletion(@(weakSelf.comments.count));
//                                                                                  }
//                                                                              } else {
//                                                                                  [ZWHUDTool showHUDInView:weakSelf.navigationController.view
//                                                                                                 withTitle:@"出错了，删除失败"
//                                                                                                   message:nil
//                                                                                                  duration:kShowHUDMid];
//                                                                              }
//                                                                          }];
//            }
//        }];
//        [alertController addAction:deleteAction];
//    } else {
//        UIAlertAction *reportUserAction = [UIAlertAction actionWithTitle:@"举报用户" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [[UMComDataRequestManager defaultManager] userSpamWitUID:isForFeed ? _feed.creator.uid : comment.creator.uid
//                                                          completion:^(NSDictionary *responseObject, NSError *error) {
//                                                              [weakSelf dealWiteSpamResult:responseObject error:error];
//                                                          }];
//        }];
//        UIAlertAction *reportConentAction = [UIAlertAction actionWithTitle:@"举报内容" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            if (isForFeed) {
//                [[UMComDataRequestManager defaultManager] feedSpamWithFeedID:_feed.feedID
//                                                                  completion:^(NSDictionary *responseObject, NSError *error) {
//                                                                      [weakSelf dealWiteSpamResult:responseObject error:error];
//                                                                  }];
//            } else {
//                [[UMComDataRequestManager defaultManager] commentSpamWithCommentID:comment.commentID
//                                                                        completion:^(NSDictionary *responseObject, NSError *error) {
//                                                                            [weakSelf dealWiteSpamResult:responseObject error:error];
//                                                                        }];
//            }
//        }];
//        [alertController addAction:reportUserAction];
//        [alertController addAction:reportConentAction];
//    }
//    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
//        [pasteBoard setString:isForFeed ? _feed.text : comment.content];
//        [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"已复制内容至剪贴板" message:nil duration:kShowHUDMid];
//    }];
//    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//    [alertController addAction:cancleAction];
//    [alertController addAction:copyAction];
//    [self presentViewController:alertController animated:YES completion:nil];
//}
//
//
//- (void)dealWiteSpamResult:(NSDictionary *)responseObject error:(NSError *)error {
//    NSString *content = nil;
//    if (responseObject) {
//        content = @"举报成功";
//    } else {
//        content = @"出错了，举报失败";
//    }
//    [ZWHUDTool showHUDInView:self.navigationController.view
//                   withTitle:content
//                     message:nil
//                    duration:kShowHUDMid];
//}
//
//- (void)fetchCommentsData {
//    NSLog(@"%@", _feed.feedID);
//    __weak __typeof(self) weakSelf = self;
//    [[UMComDataRequestManager defaultManager] fetchCommentsWithFeedId:_feed.feedID
//                                                        commentUserId:nil
//                                                             sortType:UMComCommentSortType_Default
//                                                                count:9999
//                                                           completion:^(NSDictionary *responseObject, NSError *error) {
//                                                               if (responseObject) {
//                                                                   [_comments addObjectsFromArray:responseObject[@"data"]];
//                                                                   [weakSelf.tableView reloadData];
//                                                               } else {
//                                                                   NSLog(@"%@", error);
//                                                               }
//                                                           }];
//}
//
//- (void)zw_addSubViews {
//    [self initTableView];
//    [self initHeaderView];
//    [self initWithButtonToolBar];
//}
//
//- (void)initTableView {
//    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//    _tableView.contentInset = UIEdgeInsetsMake(64, 0, kBottomToolBarHeight, 0);
//    _tableView.scrollIndicatorInsets = _tableView.contentInset;
//    _tableView.backgroundColor = [UIColor clearColor];
//    _tableView.backgroundView.backgroundColor = [UIColor clearColor];
//    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    _tableView.dataSource = self;
//    _tableView.delegate = self;
//    [self.view addSubview:_tableView];
//    
//    [_tableView registerClass:[ZWCommentCell class] forCellReuseIdentifier:kCommentCellIdentifier];
//}
//
//- (void)initHeaderView {
//    _headerView = [[UIView alloc] init];
//    _headerView.backgroundColor = [UIColor whiteColor];
//    _headerView.width = [UIScreen mainScreen].bounds.size.width;
//    
//    // 内容字体大小
//    CGFloat contentLabelFontSize = 16;
//    // 中等文字字体大小
//    CGFloat midFontSize = 15;
//    // 较小文本的字体大小
//    CGFloat smallFontSize = 12;
//    
//    CGFloat margin = 10.f;
//    CGFloat smallMargin = 5.0f;
//    CGFloat avatarHeightOrWidth = 40;
//    CGFloat singleLineLabelMaxWidth = 200.f;
//    CGFloat genderViewSize = 15;
//    CGFloat separatorViewHeight = 10.f;
//    UIColor *separatorViewColor = defaultBackgroundColor;
//    
//    _separatorView = [[UIView alloc] init];
//    _separatorView.backgroundColor = separatorViewColor;
//    
//    _avatarView = [[UIImageView alloc] init];
//    _avatarView.layer.cornerRadius = avatarHeightOrWidth / 2;
//    _avatarView.layer.masksToBounds = YES;
//    _avatarView.userInteractionEnabled = YES;
//    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToUser)]];
//    
//    _nameLabel = [[UILabel alloc] init];
//    _nameLabel.font = [UIFont systemFontOfSize:midFontSize];
//    _nameLabel.numberOfLines = 1;
//    _nameLabel.userInteractionEnabled = YES;
//    [_nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToUser)]];
//    
//    _genderView = [[UIImageView alloc] init];
//    
//    _timeLabel = [[UILabel alloc] init];
//    _timeLabel.font = [UIFont systemFontOfSize:smallFontSize];
//    _timeLabel.numberOfLines = 1;
//    _timeLabel.textColor = [UIColor lightGrayColor];
//    
//    _schoolLabel = [[UILabel alloc] init];
//    _schoolLabel.font = [UIFont systemFontOfSize:smallFontSize];
//    _schoolLabel.numberOfLines = 1;
//    
//    _contentLabel = [[UILabel alloc] init];
//    _contentLabel.font = [UIFont systemFontOfSize:contentLabelFontSize];
//    _contentLabel.numberOfLines = 0;
//    
//    _picContainerView = [[SDWeiXinPhotoContainerView alloc] init];
//    
//    NSArray *views = @[_avatarView, _nameLabel, _genderView, _timeLabel, _schoolLabel, _contentLabel, _picContainerView, _separatorView];
//    
//    [_headerView sd_addSubviews:views];
//    
//    _separatorView.sd_layout
//    .leftEqualToView(_headerView)
//    .rightEqualToView(_headerView)
//    .topEqualToView(_headerView)
//    .heightIs(separatorViewHeight);
//    
//    _avatarView.sd_layout
//    .leftSpaceToView(_headerView, margin)
//    .topSpaceToView(_separatorView, margin)
//    .heightIs(avatarHeightOrWidth)
//    .widthIs(avatarHeightOrWidth);
//    
//    _nameLabel.sd_layout
//    .leftSpaceToView(_avatarView, margin)
//    .topEqualToView(_avatarView)
//    .heightIs(18);
//    [_nameLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
//    
//    _genderView.sd_layout
//    .leftSpaceToView(_nameLabel, smallMargin)
//    .centerYEqualToView(_nameLabel)
//    .heightIs(genderViewSize)
//    .widthIs(genderViewSize);
//    
//    _timeLabel.sd_layout
//    .leftEqualToView(_nameLabel)
//    .bottomEqualToView(_avatarView)
//    .heightIs(15);
//    [_timeLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
//    
//    _schoolLabel.sd_layout
//    .leftSpaceToView(_timeLabel, smallMargin)
//    .topEqualToView(_timeLabel)
//    .heightIs(15);
//    [_schoolLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
//    
//    _contentLabel.sd_layout
//    .leftSpaceToView(_headerView, margin)
//    .rightSpaceToView(_headerView, margin)
//    .topSpaceToView(_avatarView, margin)
//    .autoHeightRatio(0);
//    
//    _picContainerView.sd_layout
//    .leftEqualToView(_contentLabel);
//}
//
//- (void)initWithButtonToolBar {
//    _toolbar = [[UIView alloc] init];
//    _toolbar.backgroundColor = universalGrayColor;
//    [self.view addSubview:_toolbar];
//    _toolbar.sd_layout
//    .leftEqualToView(self.view)
//    .rightEqualToView(self.view)
//    .bottomEqualToView(self.view)
//    .heightIs(kBottomToolBarHeight);
//    
//    UIColor *separatorViewColor = universalGrayColor;
//    CGFloat separatorLineSize = .5f;
//    UIColor *sepatatorLineColor = defaultBackgroundColor;
//    
//    UIImage *backgroundImage = [[UIColor whiteColor] parseToImage];
//    UIImage *highlightedBackgroundImage = [separatorViewColor parseToImage];
//    
//    UIFont *insideButtonFont = ZWFont(13);
//    UIColor *insideButtonColor = [UIColor lightGrayColor];
//    
//    _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_likeButton setImage:[UIImage imageNamed:@"icon_unlike"] forState:UIControlStateNormal];
//    [_likeButton setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateSelected];
//    [_likeButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
//    [_likeButton setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
//    [_likeButton addTarget:self action:@selector(likeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//
//    
//    _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_shareButton setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
//    [_shareButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
//    [_shareButton setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
//    [_shareButton addTarget:self action:@selector(shareButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    
//    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_commentButton setImage:[UIImage imageNamed:@"icon_comment"] forState:UIControlStateNormal];
//    [_commentButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
//    [_commentButton setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
//    [_commentButton addTarget:self action:@selector(commentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    
//    _horizontalLine1 = [[UIView alloc] init];
//    _horizontalLine1.backgroundColor = sepatatorLineColor;
//    
//    _verticalLine1 = [[UIView alloc] init];
//    _verticalLine1.backgroundColor = sepatatorLineColor;
//    
//    _verticalLine2 = [[UIView alloc] init];
//    _verticalLine2.backgroundColor = sepatatorLineColor;
//    
//    NSArray *subViews = @[_horizontalLine1, _likeButton, _shareButton, _commentButton, _verticalLine1, _verticalLine2];
//    [_toolbar sd_addSubviews:subViews];
//    
//    _horizontalLine1.sd_layout
//    .leftEqualToView(_toolbar)
//    .rightEqualToView(_toolbar)
//    .topEqualToView(_toolbar)
//    .heightIs(separatorLineSize);
//    
//    _likeButton.sd_layout
//    .leftEqualToView(_toolbar)
//    .topSpaceToView(_horizontalLine1, 0)
//    .heightRatioToView(_toolbar, 1)
//    .widthRatioToView(_toolbar, 1.0 / 3.0);
//    
//    _verticalLine1.sd_layout
//    .leftSpaceToView(_likeButton, 0)
//    .centerYEqualToView(_likeButton)
//    .widthIs(separatorLineSize)
//    .heightRatioToView(_likeButton, 0.6);
//    
//    _shareButton.sd_layout
//    .leftSpaceToView(_likeButton, 0)
//    .topEqualToView(_likeButton)
//    .heightRatioToView(_likeButton, 1)
//    .widthRatioToView(_likeButton, 1.0);
//    
//    _verticalLine2.sd_layout
//    .leftSpaceToView(_shareButton, 0)
//    .centerYEqualToView(_likeButton)
//    .widthIs(separatorLineSize)
//    .heightRatioToView(_verticalLine1, 1.0);
//    
//    _commentButton.sd_layout
//    .topEqualToView(_likeButton)
//    .rightEqualToView(_toolbar)
//    .heightRatioToView(_likeButton, 1)
//    .widthRatioToView(_likeButton, 1.0);
//}
//
//- (void)likeButtonClicked {
//    __weak __typeof(self) weakSelf = self;
//    [[UMComDataRequestManager defaultManager] feedLikeWithFeedID:_feed.feedID
//                                                          isLike:!_isLiked
//                                                      completion:^(NSDictionary *responseObject, NSError *error) {
//                                                          if (responseObject) {
//                                                              if (_isLiked) {
//                                                                  NSLog(@"unlike success");
//                                                              } else {
//                                                                  NSLog(@"like success");
//                                                              }
//                                                              weakSelf.isLiked = !_isLiked;
//                                                              // 执行回调更新feed流页面数据
//                                                              if (weakSelf.isLikedChangedCompletion) {
//                                                                  weakSelf.isLikedChangedCompletion(weakSelf.isLiked, [responseObject objectForKey:@"feedLiked"]);
//                                                              }
//                                                          } else {
//                                                              [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"呀,出错了！" message:nil duration:kShowHUDMid];
//                                                          }
//                                                      }];
//}
//
//- (void) shareButtonClicked {
//    
//}
//
//- (void)commentButtonClicked {
//    __weak __typeof(self) weakSelf = self;
//    ZWFeedComposeViewController *composeViewController = [[ZWFeedComposeViewController alloc] init];
//    composeViewController.composeType = ZWFeedComposeTypeReplyFeed;
//    composeViewController.feedID = _feed.feedID;
//    composeViewController.completion = ^(UMComComment *newComment) {
//        [weakSelf.comments insertObject:newComment atIndex:0];
//        [weakSelf.tableView insertRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationTop];
//        // 执行回调更新feed流页面数据
//        if (weakSelf.commentCountChangedCompletion) {
//            weakSelf.commentCountChangedCompletion(@(weakSelf.comments.count));
//        }
//    };
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeViewController];
//    [self presentViewController:nav animated:YES completion:nil];
//}
//
//- (void)setIsLiked:(BOOL)isLiked {
//    _isLiked = isLiked;
//    _likeButton.selected = isLiked;
//}
//
//- (void)setFeed:(UMComFeed *)feed {
//    _feed = feed;
//    _creator = feed.creator;
//    
//    if ([feed.custom intValue] == 0) {
//        [_avatarView setImageWithURL:[NSURL URLWithString:_creator.icon_url.small_url_string] placeholder:[UIImage imageNamed:@"avatar"]];
//        _nameLabel.text = _creator.name;
//        _genderView.image = _creator.gender.intValue == 0 ? [UIImage imageNamed:@"icon_female"] : [UIImage imageNamed:@"icon_male"];
//        _schoolLabel.text = createSchoolName(_creator.custom);
//    } else {
//        _avatarView.image = [UIImage imageNamed:@"avatar"];
//        _nameLabel.text = kStudentCircleAnonyousName;
//        _genderView.image = [UIImage imageNamed:@"icon_female"];
//        _schoolLabel.text = nearBySchoolName;
//    }
//    
//    _timeLabel.text = createTimeString(feed.create_time);
//    
//    _contentLabel.text = feed.text;
//    
//    _picContainerView.picPathStringsArray = [feed.image_urls linq_select:^id(UMComImageUrl *item) {
//        return item.small_url_string;
//    }];
//    
//    _picContainerView.highQuantityPicArray = [feed.image_urls linq_select:^id(UMComImageUrl *item) {
//        return item.large_url_string;
//    }];
//    
//    CGFloat picContainerViewTopMargin = 0.f;
//    if (feed.image_urls && feed.image_urls.count > 0) {
//        picContainerViewTopMargin = 10;
//    }
//    
//    _picContainerView.sd_layout.topSpaceToView(_contentLabel, picContainerViewTopMargin);
//    [_picContainerView layoutIfNeeded];
//    
//    [_headerView setupAutoHeightWithBottomView:_picContainerView bottomMargin:10.f];
//    [_headerView layoutSubviews];
//    
//    _tableView.tableHeaderView = _headerView;
//    
//    
//    [self fetchCommentsData];
//}
//
//- (void)clickToUser {
//    
//}
//
//#pragma mark - UITableViewDataSource
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.comments.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    ZWCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
//    cell.comment = [self.comments objectAtIndex:indexPath.row];
//    cell.delegate = self;
//    return cell;
//}
//
//#pragma mark - UITableViewDelegate
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 20;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    id model = [self.comments objectAtIndex:indexPath.row];
//    return [tableView cellHeightForIndexPath:indexPath model:model keyPath:@"comment" cellClass:[ZWCommentCell class] contentViewWidth:kScreenWidth];
//}
//
//#pragma mark - ZWCommentCellDelegate
//
//- (void)cell:(ZWCommentCell *)cell didClickUser:(UMComUser *)user {
//    
//}
//
//- (void)didClickMoreButtonInInCell:(ZWCommentCell *)cell {
//    [self showAlertControllerForDealWithFeed:NO orForComment:cell.comment andIndex:[self.comments indexOfObject:cell.comment]];
////    __weak __typeof(self) weakSelf = self;
////    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
////    if ([cell.comment.creator.uid isEqualToString:[UMComSession sharedInstance].loginUser.uid]) {
////        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////            [[UMComDataRequestManager defaultManager] commentDeleteWithCommentID:cell.comment.commentID
////                                                                          feedID:_feed.feedID
////                                                                      completion:^(NSDictionary *responseObject, NSError *error) {
////                                                                          if (responseObject) {
////                                                                              NSInteger index = [weakSelf.comments indexOfObject:cell.comment];
////                                                                              [weakSelf.comments removeObjectAtIndex:index];
////                                                                              [weakSelf.tableView deleteRow:index inSection:0 withRowAnimation:UITableViewRowAnimationFade];
////                                                                          } else {
////                                                                              [ZWHUDTool showHUDInView:weakSelf.navigationController.view
////                                                                                             withTitle:@"出错了，删除失败"
////                                                                                               message:nil
////                                                                                              duration:kShowHUDMid];
////                                                                          }
////                                                                      }];
////        }];
////        [alertController addAction:deleteAction];
////    } else {
////        UIAlertAction *reportUserAction = [UIAlertAction actionWithTitle:@"举报用户" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////            [[UMComDataRequestManager defaultManager] userSpamWitUID:cell.comment.creator.uid
////                                                          completion:^(NSDictionary *responseObject, NSError *error) {
////                                                              NSString *content = nil;
////                                                              if (responseObject) {
////                                                                  content = @"举报成功";
////                                                              } else {
////                                                                  content = @"出错了，举报失败";
////                                                              }
////                                                              [ZWHUDTool showHUDInView:weakSelf.navigationController.view                                                                               withTitle:content
////                                                                               message:nil
////                                                                              duration:kShowHUDMid];
////                                                          }];
////        }];
////        UIAlertAction *reportConentAction = [UIAlertAction actionWithTitle:@"举报内容" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////            [[UMComDataRequestManager defaultManager] commentSpamWithCommentID:cell.comment.commentID
////                                                                    completion:^(NSDictionary *responseObject, NSError *error) {
////                                                                        NSString *content = nil;
////                                                                        if (responseObject) {
////                                                                            content = @"举报成功";
////                                                                        } else {
////                                                                            content = @"出错了，举报失败";
////                                                                        }
////                                                                        [ZWHUDTool showHUDInView:weakSelf.navigationController.view                                                                               withTitle:content
////                                                                                         message:nil
////                                                                                        duration:kShowHUDMid];
////                                                                    }];
////        }];
////        [alertController addAction:reportUserAction];
////        [alertController addAction:reportConentAction];
////    }
////    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
////        [pasteBoard setString:cell.comment.content];
////        [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"已复制内容至剪贴板" message:nil duration:kShowHUDMid];
////    }];
////    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
////    [alertController addAction:cancleAction];
////    [alertController addAction:copyAction];
////    [self presentViewController:alertController animated:YES completion:nil];
//}
//
//- (void)didClickCommentButtonInCell:(ZWCommentCell *)cell {
//    __weak __typeof(self) weakSelf = self;
//    ZWFeedComposeViewController *composeViewController = [[ZWFeedComposeViewController alloc] init];
//    composeViewController.composeType = ZWFeedComposeTypeReplyComment;
//    composeViewController.feedID = _feed.feedID;
//    composeViewController.commentID = cell.comment.commentID;
//    composeViewController.completion = ^(UMComComment *newComment) {
//        [weakSelf.comments insertObject:newComment atIndex:0];
//        [weakSelf.tableView insertRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationTop];
//    };
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeViewController];
//    [self presentViewController:nav animated:YES completion:nil];
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//
//@end
