//
//  FirstViewController.m
//  3DTrans_1
//
//  Created by Davie on 16/6/13.
//  Copyright © 2016年 Davie. All rights reserved.
//

//自定义坐标显示的控制手柄插件测试窗口

#import "FirstViewController.h"
#import "NBRein.h"
#include "NBReinIndicator.h"

@interface FirstViewController ()

@end

@implementation FirstViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    //展板初始化
    UIView *showView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    showView.backgroundColor = [UIColor colorWithRed:246/255.0 green:200/255.0 blue:251/255.0 alpha:1.0];
    [self.view addSubview:showView];
    
    //坐标层初始化
    NBReinIndicator *indicator = [[NBReinIndicator alloc]init];
    
//    indicator.virWidth = 100;
    
//    CGPoint originOffset = CGPointMake(50, 50);
//    [indicator offsetOriginFromCenterWithVirPoint:originOffset];
    
//    CGPoint indicatePoint = CGPointMake(50, 70);
//    [indicator drawIndicatorWithVirPoint:indicatePoint];
    
//    indicator.showCoordinate = NO;
//    indicator.showIndicator = YES;
    
//    indicator.indicatorColor = [UIColor colorWithRed:68/255.0 green:208/255.0 blue:11/255.0 alpha:1.0];
    
    [showView addSubview:indicator];
    
    //控制手柄初始化
    NBRein *rein = [[NBRein alloc] init];
    
    CGPoint reinCenter = CGPointMake(100, 200);
    rein.center = reinCenter;
    
    [rein changeReinColor:[UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:0.5]];
    
    rein.indicator = indicator;
    
    rein.reinHandlerPanForIndicator = ^(UIPanGestureRecognizer *reinPan,CGPoint virPoint){
        NSLog(@"场外滑动回调，坐标虚拟为：%0.2f    %0.2f",virPoint.x,virPoint.y);
    };
    
    rein.reinHandlerTouchDown = ^(CGPoint location,UIView *locateView){
        NSLog(@"场外按下，按下位置在手柄父视图的坐标为：%0.2f    %0.2f     %0.2f",location.x,location.y,locateView.bounds.size.width);
    };
    
    rein.reinHandlerTouchCancle = ^(){
        NSLog(@"抬起的场外回调");
    };
    
    [showView addSubview:rein];
    
    
}

@end
