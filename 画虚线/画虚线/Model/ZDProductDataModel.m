//
//  ZDProductDataModel.m
//  画虚线
//
//  Created by zhudong on 2017/5/25.
//  Copyright © 2017年 zhudong. All rights reserved.
//

#import "ZDProductDataModel.h"

@implementation ZDProductDataModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"timeLineItemList":[ZDKLineDataModel class]};
}

@end
