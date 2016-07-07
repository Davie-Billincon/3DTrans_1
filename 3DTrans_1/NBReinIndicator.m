//
//  NBReinIndicator.m
//  3DTrans_1
//
//  Created by Davie on 16/6/13.
//  Copyright © 2016年 Davie. All rights reserved.
//

#import "NBReinIndicator.h"

@implementation NBReinIndicator

@synthesize virWidth = _vir_act;


//该初始化有许多默认参数
//  默认显示坐标轴、指示器
//  坐标原点默认在中间
//  虚拟宽默认为100
- (id) init{
    if (self = [super init]) {
        [self basicInit];
        [self layerInit];
        _coordinatePath = [self createCoordinatePath];
        self.showIndicator = YES;
        self.showCoordinate = YES;
        [self moveOriginToCenter];
        self.virWidth = 100;
        self.indicatorColor = [UIColor blackColor];
    }
    return (self);
}

//基本常量的初始化
- (void) basicInit{
    //view无宽高是为了使得view的ceter位置就是原点，下面的layer和绘图都是依据这个来的
    self.frame = CGRectMake(0, 0, 0, 0);
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
}

//图层初始化
-(void) layerInit{
    //坐标层初始化（无边界，中点-position在view的左上角）
    _coordinateLayer = [[CAShapeLayer alloc]init];
    _coordinateLayer.bounds = CGRectMake(0, 0, 0, 0);
    _coordinateLayer.position = CGPointMake(0, 0);
    _coordinateLayer.fillColor = [UIColor clearColor].CGColor;
    _coordinateLayer.strokeColor = [UIColor blackColor].CGColor;
    _coordinateLayer.lineWidth = 1;
    [self.layer addSublayer:_coordinateLayer];
    //指示器层初始化
    _indicatorLayer = [[CAShapeLayer alloc]init];
    _indicatorLayer.bounds = CGRectMake(0, 0, 0, 0);
    _indicatorLayer.position = CGPointMake(0, 0);
    _indicatorLayer.fillColor = [UIColor clearColor].CGColor;
    _indicatorLayer.strokeColor = [UIColor blackColor].CGColor;
    _indicatorLayer.lineWidth = 0.8;
    [self.layer addSublayer:_indicatorLayer];
}

//绘制坐标系
- (UIBezierPath *) createCoordinatePath{

    UIBezierPath * path = [[UIBezierPath alloc] init];
    
    //分别绘制4个坐标轴
    [path moveToPoint: CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, _screenHeight)];
    
    [path moveToPoint: CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, -_screenHeight)];
    
    [path moveToPoint: CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(_screenWidth, 0)];
    
    [path moveToPoint: CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(-_screenWidth, 0)];
    
    //结束
    [path closePath];
    
    return path;
}

//设置是否显示指示器
-(void) setShowIndicator:(BOOL)showIndicator{
    NSLog(@"设置指示器显示情况为 %d",showIndicator);
    _showIndicator = showIndicator;
}
//设置是否显示坐标系
-(void) setShowCoordinate:(BOOL)showCoordinate{
    NSLog(@"设置坐标系显示情况为 %d",showCoordinate);
    _showCoordinate = showCoordinate;
    
    if (showCoordinate && _coordinateLayer.path == nil) {       //在path为空时才赋值，防止多次渲染
        _coordinateLayer.path = _coordinatePath.CGPath;
    }
    
    if (!showCoordinate && _coordinateLayer.path != nil) {       //在path不空时才置空，防止多次渲染
        _coordinateLayer.path = nil;
    }
}

//设置屏幕虚拟宽度
-(void) setVirWidth:(CGFloat)virWidth{
    _vir_width = virWidth;
    _vir_act = virWidth / _screenWidth;
    NSLog(@"虚拟宽 / 实际宽 ：%0.1f",_vir_act);
}
//获取屏幕的虚拟宽度
-(CGFloat) virWidth{
    return _vir_width;
}

//偏移原点位置
-(void) moveOriginToCenter{
    self.center = CGPointMake(_screenWidth/2, _screenHeight/2);
}
-(void) offsetOriginFromCenterWithVirPoint:(CGPoint)virPoint{
     self.center = CGPointMake(_screenWidth/2 + virPoint.x / _vir_act, _screenHeight/2 - virPoint.y / _vir_act);
}

//设置指示器颜色
-(void) setIndicatorColor:(UIColor *)indicatorColor{
    _indicatorColor = indicatorColor;
    _coordinateLayer.strokeColor = _indicatorColor.CGColor;
    _indicatorLayer.strokeColor = _indicatorColor.CGColor;
}

//绘制组--------------------------------------------------------------------------------
//绘制指示器的根方法
-(void)drawIndicatorWithActualPoint: (CGPoint)actualPoint{
    
    //若不让绘制指示器，那么就不绘制
    if (!self.showIndicator) {
        return;
    }
    
    //在showIndicator为true情况下，coordinate必须显示
    if (_coordinateLayer.path == nil) {
        _coordinateLayer.path = _coordinatePath.CGPath;
    }
    
    //绘制指示轴
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    
    CGPoint pointY = CGPointMake(0, actualPoint.y);
    CGPoint pointX = CGPointMake(actualPoint.x, 0);
    
    [bezierPath moveToPoint:pointY];
    [bezierPath addLineToPoint:actualPoint];
    
    [bezierPath moveToPoint:pointX];
    [bezierPath addLineToPoint:actualPoint];
    
    [bezierPath closePath];
    
    [_indicatorLayer setPath:bezierPath.CGPath];
    
    //去除旧textLayer，加入新layer
    if ([_indicatorLayer.sublayers count] > 0) {
        _indicatorLayer.sublayers = nil;
    }
    
    CGFloat vir_pointX = actualPoint.x * _vir_act;
    CGFloat vir_pointY = -actualPoint.y * _vir_act;
    
    CATextLayer *label_pointY = [[CATextLayer alloc] init];
    label_pointY.bounds = CGRectMake(0, 0, FONT_SIZE * 3.6, FONT_SIZE * 1 + 3);
    [label_pointY setAlignmentMode:kCAAlignmentRight];
    [label_pointY setForegroundColor:[self.indicatorColor CGColor]];
    [label_pointY setFontSize:FONT_SIZE];
    
    label_pointY.position = pointY;
    NSString *pointInfo_Y = [NSString stringWithFormat:@"%0.1f:Y",vir_pointY];
    [label_pointY setString:pointInfo_Y];
    [_indicatorLayer addSublayer:label_pointY];
    
    
    CATextLayer *label_pointX = [[CATextLayer alloc] init];
    label_pointX.bounds = CGRectMake(0, 0, FONT_SIZE * 3.6, FONT_SIZE * 1 + 3);
    [label_pointX setAlignmentMode:kCAAlignmentRight];
    [label_pointX setForegroundColor:[self.indicatorColor CGColor]];
    [label_pointX setFontSize:FONT_SIZE];
    
    label_pointX.position = pointX;
    NSString *pointInfo_X = [NSString stringWithFormat:@"%0.1f:X",vir_pointX];
    [label_pointX setString:pointInfo_X];
    [_indicatorLayer addSublayer:label_pointX];
    
}
//擦除指示器
-(void) eraseIndicator{
    _indicatorLayer.path = nil;
    _indicatorLayer.sublayers = nil;
    
    //若坐标不显示，但由于indecator显示而强行显示了，那么必须在indicator被擦除后也被擦除
    if (!_showCoordinate && _coordinateLayer.path != nil ) {
        _coordinateLayer.path = nil;
    }
}

//绘制指示器（使用虚拟坐标）
-(void)drawIndicatorWithVirPoint: (CGPoint)virPoint{
    CGPoint actPoint = CGPointMake(virPoint.x / _vir_act, -virPoint.y / _vir_act);
    [self drawIndicatorWithActualPoint:actPoint];
}

//工具方法组------------------------------------------------------------------------
//实际坐标转虚拟坐标
-(CGPoint) actToVir:(CGPoint)actPoint{
    return CGPointMake(actPoint.x * _vir_act, -actPoint.y * _vir_act);
}
-(CGPoint) virToAct:(CGPoint)virPoint{
    return CGPointMake(virPoint.x / _vir_act, -virPoint.y / _vir_act);
}



@end

