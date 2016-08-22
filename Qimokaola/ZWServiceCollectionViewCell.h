//
//  ZWMoreCollectionViewCell.h
//  Qimokaola
//
//  Created by Administrator on 16/2/24.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZWServiceCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSDictionary *model;

+ (instancetype)serviceCollectionViewCellWithCollectionView:(UICollectionView *)collectionView dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

@end
