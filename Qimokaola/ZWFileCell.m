//
//  ZWFileCell.m
//  Qimokaola
//
//  Created by Administrator on 16/4/5.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWFileCell.h"
#import "Masonry.h"
#import "ZWUtilsCenter.h"

@interface ZWFileCell ()

@property (weak, nonatomic) IBOutlet UIImageView *typeIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;

@end

@implementation ZWFileCell

+(instancetype)fileCellWithTableView:(UITableView *)tableView {
    static NSString *const FileCellID = @"FileCellID";
    ZWFileCell *cell = [tableView dequeueReusableCellWithIdentifier:FileCellID];
    if(cell == nil)  {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ZWFileCell" owner:self options:nil] firstObject];
    }
    cell.separatorInset = UIEdgeInsetsMake(0, cell.nameLabel.frame.origin.x, 0, 0);
    return cell;
}


- (void)setFile:(ZWFile *)file {
    _file = file;
    self.typeIcon.image = [UIImage imageNamed:[ZWUtilsCenter parseTypeWithString:_file.type]];
    self.nameLabel.text = _file.name;
    self.sizeLabel.text = _file.size;
    self.downloadLabel.hidden = ! _file.download;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
