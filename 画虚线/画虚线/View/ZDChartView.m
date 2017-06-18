//
//  ChartView.m
//  画虚线
//
//  Created by zhudong on 2017/5/24.
//  Copyright © 2017年 zhudong. All rights reserved.
//

#import "ZDChartView.h"

//H方向预留高度
#define verticalMarginScale 0.1

@implementation ZDChartView

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    [self drawBounds:rect];
}

- (void)drawBounds: (CGRect)rect{
    
    //上边框
    CGFloat xLength = rect.size.width - self.leftMargin - self.rightMargin;
    CGFloat yLength = rect.size.height - self.topMargin - self.bottomMargin - self.volumeTopMargin - self.volumeHeight;
    CALayer *kLineLayer = [CALayer layer];
    kLineLayer.frame = CGRectMake(self.leftMargin, self.topMargin, xLength, yLength);
    kLineLayer.borderWidth = 1;
    kLineLayer.borderColor = [UIColor grayColor].CGColor;
    [self.layer addSublayer:kLineLayer];
    
    //下边框
    CALayer *volumnLayer = [CALayer layer];
    volumnLayer.frame = CGRectMake(self.leftMargin, rect.size.height - self.bottomMargin - self.volumeHeight, xLength, self.volumeHeight);
    volumnLayer.borderWidth = 1;
    volumnLayer.borderColor = [UIColor yellowColor].CGColor;
    [self.layer addSublayer:volumnLayer];
    
    //上边框横线
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(self.leftMargin, self.topMargin, xLength, yLength)];
    path.lineWidth = 1;
    CGFloat verticalH = yLength / self.verticalLineCount;
    CGFloat dash[] = {5,5};
    for (int i = 0; i < self.verticalLineCount; i++) {
        if ( i == 0) {
            continue;
        }
        CGFloat endY = self.topMargin + i * verticalH;
        [path removeAllPoints];
        [path moveToPoint:CGPointMake(self.leftMargin, endY)];
        [path addLineToPoint:CGPointMake(rect.size.width - self.rightMargin, endY)];
        if (i == 2) {
            //dash:实线,虚线交替的长度数组a
            //count:取数组a的有效位数, phase:起始跳过的长度
            //  [path setLineDash:dash count:2 phase:5];
            //count>dash的个数时,有效;
            [path setLineDash:dash count:2 phase:0];
        }else{
            //清除
            [path setLineDash:dash count:0 phase:0];
        }
        [[UIColor greenColor] set];
        [path stroke];
    }
    
    [path removeAllPoints];
    CGFloat bottomCenterY = rect.size.height - self.bottomMargin - self.volumeHeight * 0.5;
    [path moveToPoint:CGPointMake(self.leftMargin, bottomCenterY)];
    [path addLineToPoint:CGPointMake(rect.size.width - self.rightMargin, bottomCenterY)];
    [path setLineDash:dash count:2 phase:0];
    [[UIColor greenColor] set];
    [path stroke];
    //上边框K线
    [path removeAllPoints];
    
    //高度
    CGFloat maxDif = MAX(fabs([self.chartModel.minValue floatValue] - [self.chartModel.lastCloseValue floatValue]), fabs(([self.chartModel.maxValue floatValue] - [self.chartModel.lastCloseValue floatValue])));
    CGFloat unitH = yLength * 0.5 * (1 - verticalMarginScale) / maxDif;
    
    NSMutableArray *tempHeightArray = [NSMutableArray arrayWithCapacity:self.chartModel.values.count];
    CGFloat halfChartHeight = yLength * 0.5;
    //转换成Y坐标值
    [self.chartModel.values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat tempH = ([obj floatValue] - [self.chartModel.lastCloseValue floatValue]) * unitH;
        [tempHeightArray addObject: [NSString stringWithFormat:@"%lf", halfChartHeight - tempH + self.topMargin]];
    }];
    //转换成X坐标值
    CGFloat unitX = xLength / [self.chartModel.totalTime integerValue];
    NSMutableArray *tempTimeArray = [NSMutableArray arrayWithCapacity:self.chartModel.times.count];
    [self.chartModel.times enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat tempX = ([obj integerValue] - [self.chartModel.openTime integerValue]) * unitX + self.leftMargin;
        [tempTimeArray addObject:[NSString stringWithFormat:@"%lf", tempX]];
    }];
    //画K线
    path.lineWidth = 0.2;
    [path moveToPoint:CGPointMake(self.leftMargin, self.topMargin + yLength * 0.5)];
    [tempHeightArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [path addLineToPoint:CGPointMake([[tempTimeArray objectAtIndex:idx] floatValue], [obj floatValue])];
    }];
    
    [[UIColor blueColor] set];
    [path stroke];
    //填充颜色
    [path addLineToPoint:CGPointMake([tempTimeArray.lastObject floatValue], (self.topMargin + yLength))];
    [path addLineToPoint:CGPointMake(self.leftMargin, (self.topMargin + yLength))];
    [path closePath];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = kLineLayer.frame;
    gradientLayer.colors = @[(id)[[UIColor blueColor] colorWithAlphaComponent:0.3].CGColor, (id)[[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor];
    [gradientLayer setStartPoint:CGPointMake(0, 0)];
    [gradientLayer setEndPoint:CGPointMake(0, 1)];
    
    //注: 需要调整x和y的坐标
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = CGRectMake(-self.leftMargin, -self.topMargin, rect.size.width, rect.size.height);
    shapeLayer.path = path.CGPath;
    gradientLayer.mask = shapeLayer;
    [self.layer addSublayer:gradientLayer];
    
    //绘制成交量
    CGFloat unitH_volumn = self.volumeHeight / [self.chartModel.maxVolumn floatValue];
    [self.chartModel.volumns enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat tempX = ([self.chartModel.times[idx] integerValue] - [self.chartModel.openTime integerValue]) * unitX + self.leftMargin;
        CGFloat tempH = [self.chartModel.volumns[idx] floatValue] * unitH_volumn;
        CGFloat tempW = unitX * 100000;
        CGFloat tempY = rect.size.height - self.bottomMargin - tempH;
        CGRect tempRect = CGRectMake(tempX - tempW * 0.5, tempY, tempW, tempH);
        UIBezierPath *tempPath = [UIBezierPath bezierPathWithRect:tempRect];
        UIColor *fillColor;
        if ([self.chartModel.volumns[idx] floatValue] > [self.chartModel.current floatValue]) {
            fillColor = [UIColor redColor];
        }else{
            fillColor = [UIColor greenColor];
        }
        [fillColor set];
        [tempPath fill];
    }];
    
    //绘制K线左右文字
    CGFloat centerPrice =  [self.chartModel.lastCloseValue floatValue];
    CGFloat maxPrice = centerPrice + unitH * yLength * 0.5;
    CGFloat topCenterPrice = centerPrice + unitH * yLength * 0.25;
    CGFloat minPrice = centerPrice - unitH * yLength * 0.5;
    CGFloat bottomCenterPrice = centerPrice - unitH * yLength * 0.25;
    NSArray *leftTextArray = @[[self getString:maxPrice decimalCount:2], [self getString:topCenterPrice decimalCount:2], [self getString:centerPrice decimalCount:2], [self getString:bottomCenterPrice decimalCount:2], [self getString:minPrice decimalCount:2]];
    CGFloat unitHMargin = yLength / 4.0;
    
    CGFloat topMargin = 3;
    CGFloat leftMargin = 3;
    __block CGFloat textH;
    CGFloat fontSize = 10;
    [leftTextArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *text = (NSString *)obj;
        CGFloat textW = 50;
        CGRect leftTextRect= [text boundingRectWithSize:CGSizeMake(textW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
        textH = leftTextRect.size.height;
        CGFloat offsetY;
        NSString *upDownText;
        switch (idx) {
            case 0:
                offsetY = topMargin;
                upDownText = [NSString stringWithFormat:@"+%.2f%%", ([text floatValue] - centerPrice) * 100 / centerPrice];
                break;
            case 1:
                upDownText = [NSString stringWithFormat:@"+%.2f%%", ([text floatValue] - centerPrice) * 100 / centerPrice];
                offsetY = -textH * 0.5;
                break;
            case 2:
                upDownText = [NSString stringWithFormat:@"0.00%%"];
                offsetY = -textH * 0.5;
                break;
            case 3:
                upDownText = [NSString stringWithFormat:@"%.2f%%", ([text floatValue] - centerPrice) * 100 / centerPrice];
                offsetY = -textH * 0.5;
                break;
            default:
                upDownText = [NSString stringWithFormat:@"%.2f%%", ([text floatValue] - centerPrice) * 100 / centerPrice];
                offsetY = -textH - topMargin;
                break;
        }
        [text drawInRect:CGRectMake(self.leftMargin + leftMargin, self.topMargin + idx * unitHMargin + offsetY, textW, textH) withAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName: [UIColor grayColor]}];
        CGRect upDownRect = [upDownText boundingRectWithSize:CGSizeMake(MAXFLOAT, textH) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
        [upDownText drawInRect:CGRectMake(rect.size.width - self.rightMargin - upDownRect.size.width - leftMargin, self.topMargin + idx * unitHMargin + offsetY, upDownRect.size.width, textH) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName: [UIColor grayColor]}];
        
    }];
    
    //绘制成交量文字
    NSString *maxVolume = [NSString stringWithFormat:@"%@", self.chartModel.maxVolumn];
    [maxVolume drawInRect:CGRectMake(self.leftMargin + leftMargin, rect.size.height - self.bottomMargin - self.volumeHeight + topMargin, 100, textH) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName: [UIColor grayColor]}];
    NSString *centerVolume = [NSString stringWithFormat:@"%.0f", [self.chartModel.maxVolumn integerValue] * 0.5];
    [centerVolume drawInRect:CGRectMake(self.leftMargin + leftMargin, rect.size.height - self.bottomMargin - self.volumeHeight * 0.5 - textH * 0.5, 100, textH) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName: [UIColor grayColor]}];
}

- (NSString *)getString: (CGFloat)value decimalCount: (NSInteger)count{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.6f", value]];
    NSDecimalNumberHandler *handle = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:count raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSString *text = [NSString stringWithFormat:@"%@", [number decimalNumberByRoundingAccordingToBehavior:handle]];
    return text;
}
- (void)setChartModel:(ZDChartModel *)chartModel{
    _chartModel = chartModel;
    [self setNeedsDisplay];
}
@end
