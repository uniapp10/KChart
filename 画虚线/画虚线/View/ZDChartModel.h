//
//  ZDChartModel.h
//  画虚线
//
//  Created by zhudong on 2017/5/26.
//  Copyright © 2017年 zhudong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZDChartModel : NSObject

@property (nonatomic,strong) NSArray *times;
@property (nonatomic,strong) NSArray *values;
@property (nonatomic,strong) NSArray *volumns;

@property (nonatomic,strong) NSString *current;
@property (nonatomic,strong) NSString *maxValue;
@property (nonatomic,strong) NSString *minValue;
@property (nonatomic,strong) NSString *minVolumn;
@property (nonatomic,strong) NSString *maxVolumn;
@property (nonatomic,strong) NSString *lastCloseValue;
@property (nonatomic,strong) NSString *totalTime;
@property (nonatomic,strong) NSString *openTime;

@end
