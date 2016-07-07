//
//  NBRein.m
//  3DTrans_1
//
//  Created by Davie on 16/6/13.
//  Copyright © 2016年 Davie. All rights reserved.
//

#import "NBRein.h"


@implementation NBRein


//初始化设置组----------------------------------------------------------------------------------------
-(id) init{
    if (self = [super init]) {
        
        [self basicInit];
        
        [self drawReinView:self];
        [self setGestures:self];
        [self setControlEventHandler:self];
    }
    return (self);
}

//基本初始化
-(void) basicInit{
    self.indicator = nil;
    self.reinHandlerPan = nil;
    self.reinHandlerPanForIndicator = nil;
    self.reinHandlerTouchDown = nil;
    self.reinHandlerTouchCancle = nil;
}

//绘制按钮形状和颜色，加入滑动手势识别
-(void) drawReinView:(UIView *)reinView{
    CGRect rect = CGRectMake(0,0,CTROL_VIEW_SIZE,CTROL_VIEW_SIZE);
    reinView.frame = rect;
    
    //绘制圆形layer
    CAShapeLayer *roundLayer = [[CAShapeLayer alloc]init];
    roundLayer.frame = rect;
    roundLayer.fillColor = [UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:0.4].CGColor;
    roundLayer.strokeColor = [UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:0.4].CGColor;
    CGFloat radius = rect.size.width / 2.f;
    UIBezierPath *path = [UIBezierPath
                          bezierPathWithArcCenter:CGPointMake(radius,radius)    //圆心
                          radius:radius                                         //半径
                          startAngle:0                                          //开始角度，从右水平开始
                          endAngle:M_PI * 2                                     //结束角度
                          clockwise:YES];
    [roundLayer setPath: path.CGPath];
    
    [reinView.layer addSublayer:roundLayer];
    
}

//设置view检测的手势
-(void) setGestures:(UIView *)reinView{
    //增加滑动手势识别器（使用传入的SEL来产生滑动回调）
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandel:)];
    [reinView addGestureRecognizer:pan];
}

//设置control检测触控时的回调
-(void) setControlEventHandler:(UIControl *)reinControl{
    [reinControl addTarget:self action:@selector(tapHandelTouchDown) forControlEvents:UIControlEventTouchDown];
    [reinControl addTarget:self action:@selector(tapHandelTouchCancel) forControlEvents:UIControlEventTouchCancel];
    [reinControl addTarget:self action:@selector(tapHandelTouchCancel) forControlEvents:UIControlEventTouchUpInside];
}

//设置按钮颜色
-(void) changeReinColor:(UIColor *)color{
    
    CAShapeLayer * roundLayer = self.layer.sublayers[0];
    roundLayer.fillColor = color.CGColor;
    roundLayer.strokeColor = color.CGColor;
}


//触控回调组-----------------------------------------------------------------------------------------------
//rein滑动回调
-(void)panHandel:(UIPanGestureRecognizer *)pan{
    
    //使自身在父窗口的位置得到重置
    CGPoint location = [pan locationInView:self.superview];
    self.center = location;
    
    //回调滑动手柄的指定回调
    if (self.reinHandlerPan != nil) {
        self.reinHandlerPan(pan);
    }
    
    //回调存在的指示器
    if (self.indicator != nil) {
        
        CGPoint indicatorLocation = [pan locationInView:self.indicator];
        [self.indicator drawIndicatorWithActualPoint:indicatorLocation];
        
        if (pan.state == UIGestureRecognizerStateEnded  ) {
            [self.indicator eraseIndicator];
        }
        
        if (self.reinHandlerPanForIndicator != nil) {
            CGPoint virPoint = [self.indicator actToVir:indicatorLocation];
            self.reinHandlerPanForIndicator(pan,virPoint);
        }
    }

}
//按下回调
-(void)tapHandelTouchDown{
//    NSLog(@"插件内按下回调");
    
    if (self.indicator != nil) {
        //需要转换坐标
        CGPoint indicatorLocation = [self.superview convertPoint:self.center toView:self.indicator];
        [self.indicator drawIndicatorWithActualPoint:indicatorLocation];
    }
    if (self.reinHandlerTouchDown != nil) {
        self.reinHandlerTouchDown(self.center,self.superview);
    }

}
//抬起回调
-(void)tapHandelTouchCancel{
//    NSLog(@"插件内抬起回调");
    
    if (self.indicator != nil) {
        [self.indicator eraseIndicator];
    }
    if (self.reinHandlerTouchCancle != nil) {
        self.reinHandlerTouchCancle();
    }
    
}



@end
