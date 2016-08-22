//
//  ZWMoreCollectionViewCell.m
//  Qimokaola
//
//  Created by Administrator on 16/2/24.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWServiceCollectionViewCell.h"

@interface ZWServiceCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *desc;

@end

@implementation ZWServiceCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"ZWServiceCollectionViewCell" owner:self options:nil] firstObject];
    }
    return self;
}

+ (instancetype)serviceCollectionViewCellWithCollectionView:(UICollectionView *)collectionView dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    ZWServiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

- (void)setModel:(NSDictionary *)model {
    if (_model == nil) {
        _model = model;
    }
    self.icon.image = [UIImage imageNamed:model[@"icon"]];
    self.desc.text = model[@"desc"];
}

@end
