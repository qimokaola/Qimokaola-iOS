//
//  UMComActionPickerAddView.h
//  UMCommunity
//
//  Created by luyiyuan on 14/9/12.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UMComActionPickerAddView : UIView

@property(nonatomic,assign)BOOL isDashWithBorder;//判断是否边框是否虚线
@end


/**
 *  简版的增加图片的控件,增加点击效果
 */
@interface UMComActionPickerBriefAddView : UIButton

@property(nonatomic,readwrite,strong)UIImage* normalAddImg;
@property(nonatomic,readwrite,strong)UIImage* highlightedAddImg;


@end