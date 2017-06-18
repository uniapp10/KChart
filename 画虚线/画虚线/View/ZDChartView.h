//
//  ChartView.h
//  画虚线
//
//  Created by zhudong on 2017/5/24.
//  Copyright © 2017年 zhudong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZDChartModel.h"

@interface ZDChartView : UIView

@property (nonatomic,assign) CGFloat topMargin;
@property (nonatomic,assign) CGFloat leftMargin;
@property (nonatomic,assign) CGFloat bottomMargin;
@property (nonatomic,assign) CGFloat rightMargin;
@property (nonatomic,assign) NSInteger verticalLineCount;//横线个数

@property (nonatomic,assign) CGFloat volumeHeight;//成交量高度
@property (nonatomic,assign) CGFloat volumeTopMargin;//成交量于K线图距离
@property (nonatomic,strong) ZDChartModel *chartModel;

@end
