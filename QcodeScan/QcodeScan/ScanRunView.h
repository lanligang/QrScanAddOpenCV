//
//  ScanRunView.h
//  QcodeScan
//
//  Created by ios2 on 2019/5/14.
//  Copyright © 2019 ShanZhou. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
	ScanLineDefaultType = 1,
	ScanLineTopType,
} ScanLineRunType;


@interface ScanRunView : UIView

//边上矩形的颜色
@property (nonatomic,strong)UIColor *rect_color;

//线条的高度
@property(nonatomic,assign)CGFloat lineHeight;

//开始运行
@property(nonatomic,assign)BOOL runAnimation;

//运行的类型
@property(nonatomic,assign)ScanLineRunType scanLineRunType;


@end

