//
//  ZWDownloadInfoCell.m
//  Qimokaola
//
//  Created by Administrator on 15/10/12.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import "ZWDownloadInfoCell.h"
#import "ZWFileTool.h"

@interface ZWDownloadInfoCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation ZWDownloadInfoCell

+(instancetype)downloadInfoCellWithTablelView:(UITableView *)tableView  {
    static NSString *cellID = @"downloadCellID";
    
    ZWDownloadInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil)  {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ZWDownloadInfoCell" owner:nil options:nil] firstObject];
    }
    cell.separatorInset = UIEdgeInsetsMake(0, cell.nameLabel.frame.origin.x, 0, 0);
    return cell;
}

- (void)setDownloadInfo:(ZWDownloadInfoModel *)downloadInfo  {
    _downloadInfo = downloadInfo;
    self.imgViewIcon.image = [UIImage imageNamed:[ZWFileTool parseTypeWithString:_downloadInfo.type]];
    self.nameLabel.text = _downloadInfo.name;
    self.sizeLabel.text = [NSString stringWithFormat:@"%@", _downloadInfo.course];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", _downloadInfo.time];
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
