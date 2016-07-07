//
//  SecondViewController.m
//  3DTrans_1
//
//  Created by Davie on 16/6/13.
//  Copyright © 2016年 Davie. All rights reserved.
//

//仅控制Z轴的XOY变换实验

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicInit];
    [self layerInit];
    [self reinControlInit];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
}

-(void) basicInit{
    //获取屏幕宽高
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    //展板初始化
    _showView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _showView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_showView];
    
    //矩阵计算容器初始化
    matrix_initWithNM(&_zhudongSpace,3,3);
    matrix_initWithNM(&_zhudongSpace_forInverse,3,3);
    matrix_initWithNM(&_yundongContainer,3,3);
    matrix_initWithNM(&_multiplyResult,3,3);
    _trans = CATransform3DIdentity;
}

-(void) reinControlInit{
    //坐标层初始化
    _indicator = [[NBReinIndicator alloc]init];
    [_showView addSubview:_indicator];
    
    //控制手柄初始化
    NBRein *rein = [[NBRein alloc] init];
    
    CGPoint reinCenter = CGPointMake(_screenWidth/2, _screenHeight/2);
    rein.center = reinCenter;
    
    [rein changeReinColor:[UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:0.5]];
    
    rein.indicator = _indicator;
    
    rein.reinHandlerPanForIndicator = ^(UIPanGestureRecognizer *reinPan,CGPoint virPoint){
        NSLog(@"滑动时的虚拟坐标为：%0.2f    %0.2f",virPoint.x,virPoint.y);
        [self changeTransWitnZX:virPoint.x withZY:-virPoint.y withZZ:_indicator.virWidth * 0.3];
    };
    
    rein.reinHandlerTouchDown = ^(CGPoint location,UIView *locateView){
        NSLog(@"场外按下，按下位置在手柄父视图的坐标为：%0.2f    %0.2f     %0.2f",location.x,location.y,locateView.bounds.size.width);
    };
    
    rein.reinHandlerTouchCancle = ^(){
        NSLog(@"抬起的场外回调");
    };
    
    [_showView addSubview:rein];
}

-(void) layerInit{
    
    //橙色XOY图层
    _orangeLayer = [[CALayer alloc] init];
    
    CGRect rect = CGRectMake(0, 0, 250, 250);
    _orangeLayer.bounds = rect;
    
    _orangeLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _orangeLayer.position = CGPointMake(_screenWidth/2, _screenHeight/2);
    
    _orangeLayer.backgroundColor = [UIColor colorWithRed:245/255.0 green:133/255.0 blue:13/255.0 alpha:1.0].CGColor;
    _orangeLayer.opacity = 0.8;
    
    [_showView.layer addSublayer:_orangeLayer];
    NSLog(@"目前showView.rootLayer的子layer数为：%lu",[_showView.layer.sublayers count]);
    
    //灰色标准空间图层
    _grayLayer = [[CALayer alloc] init];
    
    CGRect gray_rect = CGRectMake(0, 0, 300, 300);
    _grayLayer.bounds = gray_rect;
    
    _grayLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _grayLayer.position = CGPointMake(_screenWidth/2, _screenHeight/2);
    
    _grayLayer.backgroundColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:0.5].CGColor;
    _grayLayer.opacity = 0.5;
    
    [_showView.layer addSublayer:_grayLayer];
}

//根据传入的Z轴坐标进行layer的矩阵变幻
-(void) changeTransWitnZX:(CGFloat)a withZY:(CGFloat)b withZZ:(CGFloat)c{
    NSLog(@"%0.2f    %0.2f     %0.2f",a,b,c);
    
    //【主动空间运动前在标准空间的表述】
    getZhuDongSpace_withZ(&_zhudongSpace,a,b,c);
    printf("主动空间为：\n");
    printf_matrix(&_zhudongSpace);
    
    //复制主动空间的表述（用于inverse）
    matrix_copy_unsafe(&_zhudongSpace,&_zhudongSpace_forInverse);
    //【单位矩阵 — 标准容器】÷【主动空间运动前在标准空间的表述】=  【运动前-标准容器在主动空间的表述】（使用针对Z轴随动变幻的那个函数）
    getInverse_fromZhuDongSpace(&_zhudongSpace_forInverse);
    printf("标准容器在主动空间的表述（逆矩阵）为：\n");
    printf_matrix(&_zhudongSpace_forInverse);
    
    //求主动空间的容器运动后在主动空间中的表述
    getZhuDongContainerMove_withZ(&_yundongContainer,a,b,c);
    printf("运动矩阵为：\n");
    printf_matrix(&_yundongContainer);
    
    //【运动前-标准容器在主动空间的表述】 * 【在主动空间表述的运动】= 【运动后-标准容器在主动空间的表述】
    matrix_multiply_unsafe(&_zhudongSpace_forInverse,&_yundongContainer,&_multiplyResult);
    
    //【运动后-标准容器在主动空间的表述】*【主动在标准空间的表述】=【运动后-标准容器在标准空间的表述】
    matrix_multiply_unsafe(&_multiplyResult,&_zhudongSpace,&_yundongContainer);
    
    matrix_transThreeMatrixTo3D((CATransform3D_my *)&_trans,&_yundongContainer);
    
    makeToushiWithZ(&_trans,-4.5/2000);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _orangeLayer.transform = _trans;
    [CATransaction commit];
}

-(void) dealloc{
    matrix_free(&_zhudongSpace);
    matrix_free(&_zhudongSpace_forInverse);
    matrix_free(&_yundongContainer);
    matrix_free(&_multiplyResult);
}


@end


