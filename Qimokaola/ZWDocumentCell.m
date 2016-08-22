//
//  ZWCourseDocCell.m
//  Qimokaola
//
//  Created by Administrator on 15/10/9.
//  Copyright © 2015年 Administrator. All rights reserved.
//

#import "ZWDocumentCell.h"

@interface ZWDocumentCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *docNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *docSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;

@end

@implementation ZWDocumentCell

+ (instancetype)documentCellWithTableView:(UITableView *)tableView  {
    static NSString *cellID = @"docCellID";
    ZWDocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil)  {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ZWDocumentCell" owner:self options:nil] firstObject];
    }
    return cell;
}

- (void)setModel:(ZWDocumentModel *)model {
    _model = model;
    self.imgViewIcon.image = [UIImage imageNamed:_model.type];
    self.docNameLabel.text = _model.papername;
    self.docSizeLabel.text = [NSString stringWithFormat:@"%@", _model.size];
    self.downloadLabel.hidden = !_model.download;
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
