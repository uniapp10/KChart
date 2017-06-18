//
//  ViewController.m
//  画虚线
//
//  Created by zhudong on 2017/5/24.
//  Copyright © 2017年 zhudong. All rights reserved.
//

#import "ViewController.h"
#import "ZDChartView.h"
#import "ZDProductDataModel.h"
#import "ZDChartModel.h"

@interface ViewController ()

@property (nonatomic, strong) ZDChartView *chartView;
@property (nonatomic, strong) ZDProductDataModel *productModel;

@end

@implementation ViewController

#define ScreenSize [UIScreen mainScreen].bounds.size
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat btnW = 100;
    CGFloat leftMargin = 30;
    CGFloat centerMargin  = ScreenSize.width - 2 * (btnW + leftMargin);
    btn.frame = CGRectMake(leftMargin, 100, btnW, 40);
    btn.backgroundColor = [UIColor greenColor];
    [btn setTitle:@"showChart" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(show) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn_close = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_close.frame = CGRectMake(leftMargin + btnW + centerMargin, 100, btnW, 40);
    btn_close.backgroundColor = [UIColor redColor];
    [btn_close setTitle:@"closeChart" forState:UIControlStateNormal];
    [btn_close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_close];
}


- (void)show {
    ZDChartView *chartV = [[ZDChartView alloc] initWithFrame:CGRectMake(30, 200, ScreenSize.width - 2 * 30, 300)];
    chartV.backgroundColor = [UIColor orangeColor];
    chartV.leftMargin = 10;
    chartV.topMargin = 20;
    chartV.bottomMargin = 20;
    chartV.rightMargin = 10;
    chartV.verticalLineCount = 4;
    chartV.volumeTopMargin = 20;
    chartV.volumeHeight = 80;
    self.chartView = chartV;
    [self.view addSubview:chartV];
//    NSDictionary *dataDict = [[self data] firstObject];
    ZDChartModel *chartModel = [[ZDChartModel alloc] init];
    chartModel.lastCloseValue = self.productModel.lastclose;
    chartModel.openTime = self.productModel.openTime;
    
    NSArray *timeArr = [[self.productModel.duration substringFromIndex:2] componentsSeparatedByString:@"H"];
    NSString *hourStr = [timeArr firstObject];
    NSString *miniteStr = [[timeArr.lastObject componentsSeparatedByString:@"M"] firstObject];
    NSInteger hour = [hourStr integerValue];
    NSInteger minute = [miniteStr integerValue];
    //总时间以毫秒算
    chartModel.totalTime = [NSString stringWithFormat:@"%ld", hour * 60 * 60 * 1000 + minute * 60 * 1000];
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:self.productModel.timeLineItemList.count];
    [times addObject:chartModel.openTime];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:self.productModel.timeLineItemList.count];
    NSMutableArray *volums = [NSMutableArray arrayWithCapacity:self.productModel.timeLineItemList.count];
    [values addObject:chartModel.lastCloseValue];
    [self.productModel.timeLineItemList enumerateObjectsUsingBlock:^(ZDKLineDataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger currentTime = [self.productModel.openTime floatValue] + idx * 60 * 1000;
        if ([obj.time floatValue] > currentTime) {
            [times addObject:[NSString stringWithFormat:@"%zd", currentTime]];
        }else{
            [times addObject:obj.time];
        }
        [volums addObject:obj.volume];
        [values addObject:obj.current];
    }];
    chartModel.times = times;
    chartModel.values = values;
    chartModel.volumns = volums;
    chartModel.current = self.productModel.timeLineItemList.firstObject.current;
    chartModel.minValue = [values valueForKeyPath:@"@min.floatValue"];
    chartModel.maxValue = [values valueForKeyPath:@"@max.floatValue"];
    chartModel.minVolumn = [volums valueForKeyPath:@"@min.floatValue"];
    chartModel.maxVolumn = [volums valueForKeyPath:@"@max.floatValue"];
    chartV.chartModel = chartModel;
}

- (ZDProductDataModel *)productModel{
    if (!_productModel) {
        NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"k_data.txt" ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:pathStr];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *dictData = [dict[@"value"] firstObject];
        _productModel = [ZDProductDataModel mj_objectWithKeyValues:dictData];
    }
    return _productModel;
}

- (void)close {
    [self.chartView removeFromSuperview];
}

@end
