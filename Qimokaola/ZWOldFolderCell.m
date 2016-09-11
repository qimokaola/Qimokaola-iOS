//
//  ZWOldFolderCell.m
//  Qimokaola
//
//  Created by Administrator on 16/4/6.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWOldFolderCell.h"

@interface ZWOldFolderCell ()


@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ZWOldFolderCell

+(instancetype)folderCellWithTableView:(UITableView *)tableView {
    static NSString *const FolderCellID = @"FolderCellID";
    
    ZWOldFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:FolderCellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ZWOldFolderCell" owner:self options:nil] lastObject];
    }
    cell.separatorInset = UIEdgeInsetsMake(0, cell.nameLabel.frame.origin.x, 0, 0);
    return cell;
}

- (void)setName:(NSString *)name {
    _name = name;
    self.nameLabel.text = _name;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
