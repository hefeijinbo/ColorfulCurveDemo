//
//  ColorfulCurveView.m
//  ColorfulCurveDemo
//
//  Created by jinbo on 2023/5/28.
//

#import "ColorfulCurveView.h"

@interface ColorfulCurveView ()

@property (nonatomic, strong) NSArray *points;

@end

@implementation ColorfulCurveView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self drawCurveView];
}

- (void)drawCurveView {
    // 创建渐变Layer
    CAGradientLayer *gradientLayer = [self createGradientLayer];
    
    // 构造绘制点 y坐标/viewHeight 的比例数组
    NSArray *yValues = @[@(0.63), @(0.63), @(0.63), @(0.62), @(0.61), @(0.6),@(0.59), @(0.58), @(0.55), @(0.53), @(0.5),@(0.48), @(0.45), @(0.42), @(0.40), @(0.36),@(0.35), @(0.33), @(0.3), @(0.29), @(0.28),@(0.29),@(0.3), @(0.32), @(0.35), @(0.38), @(0.41), @(0.43), @(0.44), @(0.45), @(0.48),@(0.5), @(0.53), @(0.55), @(0.57), @(0.59), @(0.60), @(0.61)];
    yValues = [yValues arrayByAddingObjectsFromArray:yValues];

    // 创建 CGPoint 数组, 表示曲线的每个点在view 的位置
    self.points = [self createPointsWithYValuess:yValues];
    
    // 创建曲线Layer
    CAShapeLayer *curveLayer = [self createCurveLayer];
    curveLayer.path = [self createCurvePathWithPoints:_points].CGPath; //创建曲线path
    
    // 1. mask(蒙版图层): 作用就是让父图层(gradientLayer)部分区域可见
    // 2. curveLayer alpha>0的像素点显示出来, alpha = 0 的像素点被过滤掉了。
    // 3. 最后的效果是gradientLayer 显示了多彩的曲线。
    gradientLayer.mask = curveLayer;
    
    [self.layer addSublayer:gradientLayer];
}

// 创建渐变区域
- (CAGradientLayer*)createGradientLayer {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = self.bounds;
    // [红色, 浅蓝色, 浅蓝色, 黄色]
    layer.colors = @[(__bridge id)[self colorWithHex:0xFB7AD8].CGColor, (__bridge id)[self colorWithHex:0x7DEEF6].CGColor, (__bridge id)[self colorWithHex:0x7DEEF6].CGColor, (__bridge id)[self colorWithHex:0xFFC82E].CGColor];
    // locations: 表示每段颜色渐变的范围
    /* 0-0.3 : 红色区域
       0.3-0.4 : 红色->浅蓝的过渡区域
       0.4-0.5: 浅蓝色区域
       0.5-0.6: 浅蓝色->黄色过渡区域
       0.6-1: 黄色区域
     */
    layer.locations = @[@(0.3), @(0.4), @(0.5), @(0.6)];
    return layer;
}

// 创建坐标点数组
- (NSArray *)createPointsWithYValuess:(NSArray *)yValues {
    NSMutableArray *points = [NSMutableArray array];
    CGFloat xSeqValue = self.bounds.size.width / yValues.count; // x坐标根据点的数量均分
    for (NSInteger i = 0;i<yValues.count;i++) {
        CGFloat yValue = [yValues[i] floatValue];
        CGPoint point = CGPointMake(xSeqValue * i, yValue * self.bounds.size.height); // x 坐标均等递增, y 坐标根据 "比例 * 高度" 算的
        [points addObject:[NSValue valueWithCGPoint:point]]; // 使用 NSValue 包装成对象
    }
    return points;
}

// 创建曲线路径
- (UIBezierPath *)createCurvePathWithPoints:(NSArray *)points {
    if (points.count == 0) {
        return nil;
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint PrePonit = [points.firstObject CGPointValue];
    [path moveToPoint:PrePonit];

    for (NSInteger i = 1; i < points.count; i++) {
        CGPoint NowPoint = [points[i] CGPointValue];
        // 根据起点(PerPoint)、终点、controlPoint1和controlPoint2绘制一段曲线线段
        [path addCurveToPoint:NowPoint controlPoint1:CGPointMake((PrePonit.x+NowPoint.x)/2, PrePonit.y) controlPoint2:CGPointMake((PrePonit.x+NowPoint.x)/2, NowPoint.y)];
        PrePonit = NowPoint;
    }
    return path;
}

// 创建曲线Layer
- (CAShapeLayer *)createCurveLayer {
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    shaperLayer.lineCap = kCALineCapRound;
    shaperLayer.lineJoin = kCALineJoinRound;
    shaperLayer.backgroundColor = [UIColor clearColor].CGColor; // 背景透明, alpha = 0
    shaperLayer.fillColor = [[UIColor clearColor] CGColor]; // fillColor alpha = 0
    shaperLayer.strokeColor = [UIColor redColor].CGColor; // 线段使用任何颜色都可以,只要alpha > 0
    shaperLayer.lineWidth = 4;
    shaperLayer.frame = self.bounds;
    return shaperLayer;
}

// 根据hex值创建颜色
- (UIColor *)colorWithHex:(NSInteger)hexValue {
    CGFloat r = (float)(hexValue >> 16 & 0xFF) / 255.0;
    CGFloat g = (float)(hexValue >> 8 & 0xFF) / 255.0;
    CGFloat b = (float)(hexValue >> 0 & 0xFF) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@end
