//
//  ZDProductDataModel.h
//  画虚线
//
//  Created by zhudong on 2017/5/25.
//  Copyright © 2017年 zhudong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZDKLineDataModel.h"

@interface ZDProductDataModel : NSObject

@property (nonatomic,strong) NSString *duration;
@property (nonatomic,strong) NSString *lastclose;
@property (nonatomic,strong) NSString *openTime;
@property (nonatomic,strong) NSArray<ZDKLineDataModel *> *timeLineItemList;

@end
