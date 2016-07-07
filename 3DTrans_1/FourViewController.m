#import "FourViewController.h"
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%d\t%s\n", __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

@interface FourViewController ()

@end

@implementation FourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicInit];
    [self layerInit];
    [self otherLayerInit];
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
    _trans = CATransform3DIdentity;             //需要初始化，因为后面的转换赋值并不会改变最后一行
    
    // XOZ / YOZ 初始计算用矩阵初始化
    matrix_initWithNM(&_XOZOrigin,3,3);
    matrix_initWithNM(&_YOZOrigin,3,3);
    
    CATransform3D trans_1 = CATransform3DIdentity;
    trans_1 = CATransform3DRotate(trans_1,-90*M_PI/180, 1, 0, 0);   //获取初始状态矩阵
    matrix_trans3DToThreeMatrix((CATransform3D_my *)&trans_1,&_XOZOrigin);   //将初始矩阵转化为线性可用矩阵
    
    trans_1 = CATransform3DIdentity;
    trans_1 = CATransform3DRotate(trans_1,-90*M_PI/180, 0, 1, 0);   //获取初始状态矩阵
    matrix_trans3DToThreeMatrix((CATransform3D_my *)&trans_1,&_YOZOrigin);   //将初始矩阵转化为线性可用矩阵
    _trans_2 = CATransform3DIdentity;             //需要初始化，因为后面的转换赋值并不会改变最后一行
    _trans_3 = CATransform3DIdentity;             //需要初始化，因为后面的转换赋值并不会改变最后一行
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
        [self changeTransWitnZX:virPoint.x withZY:-virPoint.y withZZ:40];
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
    _orangeLayer.opacity = 0.7;
    
    [_showView.layer addSublayer:_orangeLayer];

    
    //灰色标准空间图层
    _grayLayer = [[CALayer alloc] init];
    
    CGRect gray_rect = CGRectMake(0, 0, 300, 300);
    _grayLayer.bounds = gray_rect;
    
    _grayLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _grayLayer.position = CGPointMake(_screenWidth/2, _screenHeight/2);
    
    _grayLayer.backgroundColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0].CGColor;
    _grayLayer.opacity = 0.4;
    
    [_showView.layer addSublayer:_grayLayer];
}

-(void) otherLayerInit{
    CATransform3D trans_1;
    
    //X0Z图层
    _XOZLayer = [[CALayer alloc] init];
    
    CGRect rect = CGRectMake(0, 0, 250, 250);
    _XOZLayer.bounds = rect;
    
    _XOZLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _XOZLayer.position = CGPointMake(_screenWidth/2, _screenHeight/2);
    
    _XOZLayer.backgroundColor = [UIColor colorWithRed:242/255.0 green:248/255.0 blue:88/255.0 alpha:1.0].CGColor;
    _XOZLayer.opacity = 0.7;
    
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DRotate(trans_1,-90*M_PI/180, 1, 0, 0);
    _XOZLayer.transform = trans_1;
    
    [_showView.layer addSublayer:_XOZLayer];

    
    //YOZ图层
    _YOZLayer = [[CALayer alloc] init];
    
    CGRect gray_rect = CGRectMake(0, 0, 250, 250);
    _YOZLayer.bounds = gray_rect;
    
    _YOZLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _YOZLayer.position = CGPointMake(_screenWidth/2, _screenHeight/2);
    
    _YOZLayer.backgroundColor = [UIColor colorWithRed:110/255.0 green:249/255.0 blue:237/255.0 alpha:0.5].CGColor;
    _YOZLayer.opacity = 0.7;
    
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DRotate(trans_1,-90*M_PI/180, 0, 1, 0);
    _YOZLayer.transform = trans_1;
    
    [_showView.layer addSublayer:_YOZLayer];
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
    // 选定 _yundongContainer 为最后结果容器
    matrix_multiply_unsafe(&_multiplyResult,&_zhudongSpace,&_yundongContainer);
    
    //将结果放到 3D矩阵中 ，并完成透视计算
    matrix_transThreeMatrixTo3D((CATransform3D_my *)&_trans,&_yundongContainer);
    makeToushiWithZ(&_trans,-4.5/2000);
    
    //计算XOZ 、YOZ 上的偏转，使用 _multiplyResult 做结果容器
    matrix_multiply_unsafe(&_XOZOrigin,&_yundongContainer,&_multiplyResult); //将这个初始矩阵 乘 随动变换结果
    matrix_transThreeMatrixTo3D((CATransform3D_my *)&_trans_2,&_multiplyResult);
    makeToushiWithZ(&_trans_2,-4.5/2000);
    
    matrix_multiply_unsafe(&_YOZOrigin,&_yundongContainer,&_multiplyResult); //将这个初始矩阵 乘 随动变换结果
    matrix_transThreeMatrixTo3D((CATransform3D_my *)&_trans_3,&_multiplyResult);
    makeToushiWithZ(&_trans_3,-4.5/2000);
    
    //将临时矩阵赋值到layer，完成动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _orangeLayer.transform = _trans;
    _XOZLayer.transform = _trans_2;
    _YOZLayer.transform = _trans_3;
    [CATransaction commit];
}

-(void) dealloc{
    matrix_free(&_zhudongSpace);
    matrix_free(&_zhudongSpace_forInverse);
    matrix_free(&_yundongContainer);
    matrix_free(&_multiplyResult);
    matrix_free(&_XOZOrigin);
    matrix_free(&_YOZOrigin);
}



@end












