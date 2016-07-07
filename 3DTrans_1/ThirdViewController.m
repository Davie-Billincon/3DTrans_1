//3DTrans接口测试学习组

//iOS进阶二区 — 图层几何变换有：
/**
    1. 如何获取当前的已经旋转的角度，以及注意事项
    2. 其他变换函数
 **/

//标准坐标变幻（两次旋转变幻都旋转的是标准坐标容器）
/**
    1. 思考原型：4方折叠纸的右下方形上边剪开，右下方形X轴逆时针旋转一定角度（假设45°），然后抬起左下方形，模拟标准容器旋转
    2. 抽象模型：
        边长为1的十字线，右线抬起45°，那么其关于十字面的垂线为√2/2
        当发生标准空间旋转时，右边线在十字面的投影线的另一个点，就是该垂线旋转后的新垂点，而且这个垂线旋转角度就是标准空间旋转角度α
        这个投影线就是原矩形宽的形变
        而下边线，在标准空间旋转的时候，在十字面的投影
        这个投影，就是原矩形高的形变
        宽投影线高为 sinα ，高投影线为 cosα ，那么投影的矩形变幻为的梯形边长为： cosα ~  cosα+sinα
    3. 在旋转发生的初期，一定会发生梯形长边长 > 1 的情况
    4. 矩形在该旋转过程中，右侧宽长恒定不变（第一次旋转后抬起的矩形右边线和第二次旋转旋转线垂面在第二次旋转过程中共面）
 **/

//绕轴旋转（每次旋转都是对新坐标空间的旋转）
/**
    1. 思考原型：4方折叠纸右下方形左边剪开，右侧全部抬起，然后单独抬起右下方形
    2. 抽象模型：
        边长为1的十字线，整体右侧抬起
        捏住右边线旋转，即是第二次绕轴旋转
        该旋转轨迹在原十字面的投影，实际为椭圆，长边为1，窄高为 sinα （α为第一次旋转抬起角度）
        所以 原矩形在第一次抬起后，以左，中，右边中点为心做椭圆，平行旋转这3个椭圆径形成的矩形就是第二次旋转可能形成的矩形投影
 **/

#import "ThirdViewController.h"
#import "3DTrans.h"

//随机数生成需要的C函数
#include<stdio.h>
#include<stdlib.h>
#include<time.h>

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%d\t%s\n", __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

@interface ThirdViewController ()

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicInit];
    [self testOneInit];
    [self testTwoInit];
    [self testThreeInit];
    [self testFiveInit];
    
    [self testFour2Init];
}

- (void) viewWillAppear:(BOOL)animated {
    [self testOne];
    [self testTwo];
    [self testThree];
    [self testFour];
    [self testFive];
    [self testSix];
    [self testSeven];
    
    [self testFour_2];
}

- (void) basicInit{
    //获取屏幕宽高
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    //展板初始化
    CGRect rect = CGRectMake(0, 30, _screenWidth, _screenHeight - 30);
    _showView = [[UIView alloc]initWithFrame:rect];
    _showView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_showView];
}




- (void) testOneInit{
    
    //每行2个方块，3个等宽分割线
    CGFloat lineWidth = 15;
    
    //第一个测试的基底layer
    _firstLayer = [[CALayer alloc] init];
    _firstLayer.bounds = CGRectMake(0, 0, (_screenWidth - lineWidth * 3)/2, (_screenWidth - lineWidth * 3)/2);
    
    _firstLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _firstLayer.position = CGPointMake(lineWidth + (_screenWidth - lineWidth * 3)/4, lineWidth + (_screenWidth - lineWidth * 3)/4);
    
    _firstLayer.backgroundColor = [UIColor grayColor].CGColor;
    _firstLayer.opacity = 0.7;
    
    [_showView.layer addSublayer:_firstLayer];
    
    
    //第一测试被操作的layer
    _secondLayer = [[CALayer alloc] init];
    _secondLayer.bounds = CGRectMake(0, 0, (_screenWidth - lineWidth * 3)/2, (_screenWidth - lineWidth * 3)/2);
    
     _secondLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _secondLayer.position = CGPointMake(lineWidth + (_screenWidth - lineWidth * 3)/4, lineWidth + (_screenWidth - lineWidth * 3)/4);
    
    _secondLayer.backgroundColor = [UIColor colorWithRed:245/255.0 green:133/255.0 blue:13/255.0 alpha:0.5].CGColor;
    _secondLayer.opacity = 0.3;
    
    [_showView.layer addSublayer:_secondLayer];
    
}
//实验一可得
/**
    直视对应轴顺时针方向为旋转正方向
    同view.layer层的各个layer在旋转时能产生高低遮挡效果
 **/
- (void) testOne{
    _secondLayer.transform = CATransform3DIdentity;
    
    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        CATransform3D trans_1 = CATransform3DIdentity;
        
        //注意：透视属性的设定必须在变换计算之前，因为这样才会针对m34的值来计算不同的旋转变换
        trans_1.m34 = 4.5/-2000;
        
        trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
        _secondLayer.transform = trans_1;
        
//        dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
//            CATransform3D trans_2  = CATransform3DRotate(trans_1,45*M_PI/180, 1, 0, 0);
//            _secondLayer.transform = trans_2;
//        });
    });
}




- (void) testTwoInit{
    
    //每行2个方块，3个等宽分割线
    CGFloat lineWidth = 15;
    
    //第二测试被操作的layer
    _thirdLayer = [[CALayer alloc] init];
    _thirdLayer.bounds = CGRectMake(0, 0, (_screenWidth - lineWidth * 3)/2, (_screenWidth - lineWidth * 3)/2);
    
    _thirdLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _thirdLayer.position = CGPointMake(lineWidth + (_screenWidth - lineWidth * 3)/2 + lineWidth + (_screenWidth - lineWidth * 3)/4, lineWidth + (_screenWidth - lineWidth * 3)/4);
    
    _thirdLayer.backgroundColor = [UIColor colorWithRed:245/255.0 green:133/255.0 blue:13/255.0 alpha:0.5].CGColor;
    _thirdLayer.opacity = 0.6;
    
    [_showView.layer addSublayer:_thirdLayer];
    
}
//实验二可得
/**
    接口提供的旋转方式是第二种的绕轴旋转
 **/
- (void) testTwo{
    _thirdLayer.transform = CATransform3DIdentity;
    
    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        CATransform3D trans_1 = CATransform3DIdentity;
        
        trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
        _thirdLayer.transform = trans_1;
        
        dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            CATransform3D trans_2  = CATransform3DRotate(trans_1,45*M_PI/180, 1, 0, 0);
            _thirdLayer.transform = trans_2;
        });
    });
}




- (void) testThreeInit{
    
    //每行2个方块，3个等宽分割线
    CGFloat lineWidth = 15;
    
    //第二测试被操作的layer
    _fourLayer = [[CALayer alloc] init];
    _fourLayer.bounds = CGRectMake(0, 0, (_screenWidth - lineWidth * 3)/2, (_screenWidth - lineWidth * 3)/2);
    
    _fourLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _fourLayer.position = CGPointMake(lineWidth + (_screenWidth - lineWidth * 3)/4, lineWidth + (_screenWidth - lineWidth * 3)/2  + lineWidth + (_screenWidth - lineWidth * 3)/4);
    
    _fourLayer.backgroundColor = [UIColor colorWithRed:245/255.0 green:133/255.0 blue:13/255.0 alpha:0.5].CGColor;
    _fourLayer.opacity = 0.6;
    
    [_showView.layer addSublayer:_fourLayer];
    
}
//实验三可得
/**
    透视存在下的z轴平移变换，会有放大效果
    第二个代码块：不能通过空变换来追加透视：
        说明变换是根据透视参数实时计算并赋值的，而不是在所有变换完后，最后进行透视变换的
 **/
- (void) testThree{
    _fourLayer.transform = CATransform3DIdentity;
    
    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        CATransform3D trans_1 = CATransform3DIdentity;
        
        //注意：透视属性的设定必须在变换计算之前，因为这样才会针对m34的值来计算不同的旋转变换
        trans_1.m34 = 4.5/-2000;
        
        trans_1 = CATransform3DTranslate(trans_1, 0, 0, -100);
        _fourLayer.transform = trans_1;
    });
//    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
//        CATransform3D trans_1 = CATransform3DIdentity;
//        //先变换
//        trans_1 = CATransform3DTranslate(trans_1, 0, 0, 100);
//        //后设定透视，再执行一个空变换
//        trans_1.m34 = 4.5/-2000;
//        trans_1 = CATransform3DTranslate(trans_1, 0, 0, 0);
//        
//        _fourLayer.transform = trans_1;
//    });
}




//实验四 + 四2号 可得
/**
    1. 平移变换：
        3维不动 、m43 = 平移距离 、m34 = 透视参数
        上面已知：1/m34 = 实际奇点距离
        也就是说，在 m43 = 奇点距离 时，图像缩放为 0 ，且在 m43 = 0 时，图像缩放为 1，m43 > 0 时按比例递增
        所以：（1/m34 - m43） /  1/m34  = 放大倍数 = 1 - m43 * m34
        经研究发现，官方透视算法是倒过来的：
            当 m43 < 0 时，在 -m43 情况时图像放大多少，那么m43时就缩小多少，这样就能无限缩小，比如在 444 时缩小为0.5
            当 m43 > 0 时，在 -m43 情况时图像缩小多少，那么m43时就放大多少，这样在 444 时会得到无限放大
        所以：放大倍数为 = 1 / (1 + m43 * m34)  （可以看出，这是个 向左偏移1/k的 1/x * 1/k 函数）
        所以： m44 = 1 + m43 * m34
        总结： - 奇点距离 = 观察点
        拓展：对于非坐标轴透视，应该是取平移向量在透视向量上的投影，然后使用上述算式中的距离计算公式
    3. 放大缩小变换
        m44 为1
        根据传入参数，分别乘前3行
    2. 3维任意变换后的透视变换
        3维变换不动，且m44为1
        若是有多个透视参数，则 n 行的 n4 = n1 * m14原参  +  n2 * m24原参  +  n3 * m34原参
        我怀疑：每次透视变换，都通过 透视原值 = m34 / m33 来获取原值，而对于非坐标轴透视情况，那就是解方程了
 **/
/**
    矩阵变换计算过程猜想（应该是对的了，需要testFour2更全面的测试，测试用例太多）
    0. 缩放变换：将 x ,y ,z 分别乘前 3 行即可
    1. 旋转变换：
        仅仅是变换 3 维坐标的部分，不影响其他变换，变换完后，会根据 透视原参 设定 ?4 的值
        且是 【原3维】 * 【运动后3维】 = 【新3维】
    2. 旋转后透视变换：是通过解方程来获取原值的 (仅 Z 透视的话，就是 m34 / m33 ），然后通过上面旋转后算式设定 ?4 的值
            a1 * x + a2 * y + a3 * z = a4
            b1 * x + b2 * y + b3 * z = b4
            c1 * x + c2 * y + c3 * z = c4
        解得（不会无解，因为原3维矩阵本身就是线性无关的，不会多个解，因为线性无关）(下列算式实验失败)：
            D = a1b2c3 + a2b3c1 + a3b1c2 - a3b2c1 - a1b3c2 - a2b1c3 0
            X = a4b2c3 + a2b3c4 + a3b4c2 - a3b2c4 - a4b3c2 - a2b4c3
            Y = a1b4c3 + a4b3c1 + a3b1c4 - a3b4c1 - a4b1c3 - a1b3c4
            Z = a1b2c4 + a2b4c1 + a4b1c2 - a4b2c1 - a2b1c4 - a1b4c2
            x=X/D ; y=Y/D ; z=Z/D
        缩放会影响整行，所以上述方程在各种变换后，解出的值不变
        若是变换中途更改 m34 呢？
    3. 平移变换：
        设平移为【a,b,c】  将 【a,b,c】 * 【3维矩阵】得到的数赋值到 m41,m42,m43 上
        然后计算透视缩放
        因为平移是在矩阵运动完后的基础上进行的，上述式子实际就是：获得 【在运动后容器空间中的平移向量】* 【运动后容器表达】= 【平移向量在标准空间中的表达】
    4. 平移后透视缩放：还是需要求得透视原值
        然后： m44 = （ 透视向量长 + 平移向量在透视向量上的投影(有正负) ） / 透视向量长
        好像涉及到叉乘
        反正 Z 轴透视就是 m44 = 1 + m34 * 透视原值
 
 **/
-(void) testFour{
    NSLog(@"------------------------透视计算探析------------------------------");
    CATransform3D trans_1 = CATransform3DIdentity;
    
    trans_1 = CATransform3DTranslate(trans_1, 0, 0, 100);
    NSLog(@"无透视的z平移变换");
    [self printTransform:trans_1];
    
    trans_1.m34 = 4.5/-2000;
    NSLog(@"无透视平移变换后，单独赋值透视");
    [self printTransform:trans_1];
    
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DTranslate(trans_1, 0, 0, -200);
    NSLog(@"先赋值透视然后平移变换");
    [self printTransform:trans_1];
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DTranslate(trans_1, 0, 0, 200);
    NSLog(@"先赋值透视然后平移变换");
    [self printTransform:trans_1];
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DTranslate(trans_1, 0, 0, 300);
    NSLog(@"先赋值透视然后平移变换");
    [self printTransform:trans_1];
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DTranslate(trans_1, 0, 0, 500);
    NSLog(@"先赋值透视然后平移变换");
    [self printTransform:trans_1];

    
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
    NSLog(@"先赋值透视然后y轴逆时针旋转45°变换");
    [self printTransform:trans_1];
    CATransform3D trans_2  = CATransform3DRotate(trans_1,45*M_PI/180, 1, 0, 0);
    NSLog(@"先赋值透视然后y轴逆时针旋转45° ， 然后X轴顺旋45°");
    [self printTransform:trans_2];
    
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DRotate(trans_1,-30*M_PI/180, 0, 1, 0);
    NSLog(@"先赋值透视然后y轴逆时针旋转30°变换");
    [self printTransform:trans_1];
    
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1.m24 = 4.5/-2000;
    trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
    trans_2  = CATransform3DRotate(trans_1,45*M_PI/180, 1, 0, 0);
    NSLog(@"先赋值2个透视然后y轴逆时针旋转45° ， 然后X轴顺旋45°");
    [self printTransform:trans_2];
    
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^透视计算探析^^^^^^^^^^^^^^^^^^^^^^^");
}

- (void) testFour2Init{
    //每行2个方块，3个等宽分割线
    CGFloat lineWidth = 15;

    _sixLayer = [[CALayer alloc] init];
    _sixLayer.bounds = CGRectMake(0, 0, (_screenWidth - lineWidth * 3)/2, (_screenWidth - lineWidth * 3)/2);

    _sixLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _sixLayer.position = CGPointMake(lineWidth + (_screenWidth - lineWidth * 3)/4,lineWidth + (_screenWidth - lineWidth * 3)/2 + lineWidth + (_screenWidth - lineWidth * 3)/2 + lineWidth + (_screenWidth - lineWidth * 3)/4);

    _sixLayer.backgroundColor = [UIColor colorWithRed:245/255.0 green:133/255.0 blue:13/255.0 alpha:0.5].CGColor;
    _sixLayer.opacity = 0.6;

    [_showView.layer addSublayer:_sixLayer];
}

//透视算法组合研究实验
//呼应和依赖实验四，观察结果如下，观察结果总结回到 实验四 那边去看
/**
    1. 先透视 放大2倍 后 旋转：
        会连带着，使得透视距离缩小，从而使得旋转时候的缩放效果更明显
        这个性质和在透视情况下拉近物体，获得更强的透视效果的事实一致
    2. 先放大2倍 后 透视旋转：
        该情况下不会更改透视距离，使得透视产生的缩放比例和放大前一样
        就像物体并没有拉近，仅仅是物体自身放大了2倍
    3. 先透视旋转 然后 Z轴平移：
        此时会沿着旋转后的Z轴平移
    4. 先透视 Z轴平移 然后  旋转：
        此时会放大，然后旋转，就像物体被拉近了一样，但是透视距离没有变
        类似于“先放大2倍 后 透视旋转”的情况
    5. 先 Z轴平移 然后  缩放：
        平移标示没有被缩放
    6. 先 缩放 然后 Z轴平移：
        平移标示被缩放了
    7. 透视 先y轴逆时针旋转45°  透视 然后X轴顺旋45°
        虽然两个透视设置的值一样，但是和不二次设置的计算结果产生了偏差
        说明解方程得出的 透视原值 出现了差错
 **/
- (void) testFour_2{
    NSLog(@"------------------------透视 组合 探析------------------------------");
    NSLog(@"目前有 4 种情况：透视设定 ，平移 ，缩放 ，旋转");
    //不带透视分为(自己翻转顺序)：平移+缩放 、平移+旋转 、缩放+旋转
    CATransform3D trans_1;
    CATransform3D trans_2;
    
    NSLog(@"先 Z轴平移 然后  缩放  ");
    trans_1 = CATransform3DIdentity;
    trans_1 = CATransform3DTranslate(trans_1, 0, 0, 100);
    [self printTransform:trans_1];
    trans_1 = CATransform3DScale(trans_1, 2, 2, 2);
    [self printTransform:trans_1];
    
    NSLog(@"先  缩放 然后 Z轴平移  ");
    trans_1 = CATransform3DIdentity;
    trans_1 = CATransform3DScale(trans_1, 2, 2, 2);
    [self printTransform:trans_1];
    trans_1 = CATransform3DTranslate(trans_1, 0, 0, 100);
    [self printTransform:trans_1];
    
    NSLog(@"先 Z轴平移 然后  旋转  ");
    trans_1 = CATransform3DIdentity;
    trans_1 = CATransform3DTranslate(trans_1, 0, 0, 100);
    [self printTransform:trans_1];
    trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
    [self printTransform:trans_1];
    
    NSLog(@"先  旋转 然后 Z轴平移  ");
    trans_1 = CATransform3DIdentity;
    trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
    [self printTransform:trans_1];
    trans_1 = CATransform3DTranslate(trans_1, 0, 0, 100);
    [self printTransform:trans_1];
    
    NSLog(@"先 旋转 然后  缩放  ");
    trans_1 = CATransform3DIdentity;
    trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
    [self printTransform:trans_1];
    trans_1 = CATransform3DScale(trans_1, 2, 2, 2);
    [self printTransform:trans_1];
    
    NSLog(@"先  缩放 然后 旋转  ");
    trans_1 = CATransform3DIdentity;
    trans_1 = CATransform3DScale(trans_1, 2, 2, 2);
    [self printTransform:trans_1];
    trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
    [self printTransform:trans_1];
    
    
    NSLog(@"透视 先 Z轴平移 然后  缩放  ");
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DTranslate(trans_1, 0, 0, 100);
    [self printTransform:trans_1];
    trans_1 = CATransform3DScale(trans_1, 2, 2, 2);
    [self printTransform:trans_1];
    
    NSLog(@"透视 先  缩放 然后 Z轴平移  ");
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DScale(trans_1, 2, 2, 2);
    [self printTransform:trans_1];
    trans_1 = CATransform3DTranslate(trans_1, 0, 0, 100);
    [self printTransform:trans_1];
    
    NSLog(@"透视 先 Z轴平移 然后  旋转  ");
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DTranslate(trans_1, 0, 0, 100);
    [self printTransform:trans_1];
    trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
    [self printTransform:trans_1];
    
    NSLog(@"透视 先  旋转 然后 Z轴平移  ");
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
    [self printTransform:trans_1];
    trans_1 = CATransform3DTranslate(trans_1, 0, 0, 100);
    [self printTransform:trans_1];
    
    NSLog(@"透视 先 旋转 然后  缩放  ");
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
    [self printTransform:trans_1];
    trans_1 = CATransform3DScale(trans_1, 2, 2, 2);
    [self printTransform:trans_1];
    
    NSLog(@"透视 先  缩放 然后 旋转  ");
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DScale(trans_1, 2, 2, 2);
    [self printTransform:trans_1];
    trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
    [self printTransform:trans_1];
    
    NSLog(@"透视 先y轴逆时针旋转45°  然后X轴顺旋45°");
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
    [self printTransform:trans_1];
    trans_2  = CATransform3DRotate(trans_1,45*M_PI/180, 1, 0, 0);
    [self printTransform:trans_2];
    
    NSLog(@"透视 先y轴逆时针旋转45°  透视 然后X轴顺旋45°");
    trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
    trans_1.m34 = 4.5/-2000;
    [self printTransform:trans_1];
    trans_2  = CATransform3DRotate(trans_1,45*M_PI/180, 1, 0, 0);
    [self printTransform:trans_2];

    //    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){    _sixLayer.transform = trans_1;     });
    //    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){    _sixLayer.transform = trans_1;     });
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^透视 组合 计算探析^^^^^^^^^^^^^^^^^^^^^^^");
}



- (void) testFiveInit{
    
    //每行2个方块，3个等宽分割线
    CGFloat lineWidth = 15;
    
    _fiveLayer = [[CALayer alloc] init];
    _fiveLayer.bounds = CGRectMake(0, 0, (_screenWidth - lineWidth * 3)/2, (_screenWidth - lineWidth * 3)/2);
    
    _fiveLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _fiveLayer.position = CGPointMake(lineWidth + (_screenWidth - lineWidth * 3)/2 + lineWidth + (_screenWidth - lineWidth * 3)/4, lineWidth + (_screenWidth - lineWidth * 3)/2  + lineWidth + (_screenWidth - lineWidth * 3)/4);
    
    _fiveLayer.backgroundColor = [UIColor colorWithRed:245/255.0 green:133/255.0 blue:13/255.0 alpha:0.5].CGColor;
    _fiveLayer.opacity = 0.6;
    
    [_showView.layer addSublayer:_fiveLayer];
    
}
//实验五可得
/**
    1/m44 是放大的倍数，但是这种直接设定，会导致没有放大的动画
    只有使用trans接口才能有动画
    因为第二个是将变化直接作用于3维基向量，第一个是交给渲染器，渲染器获取m44的值后手动更改基空间
 **/
- (void) testFive{
    _fiveLayer.transform = CATransform3DIdentity;

//    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
//        CATransform3D trans_1 = CATransform3DIdentity;
//        
//        trans_1.m44 = 2;
//        
//        _fiveLayer.transform = trans_1;
//    });
    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        CATransform3D trans_1 = CATransform3DIdentity;
        
        trans_1 = CATransform3DScale(trans_1,0.5,0.5,0.5);
        NSLog(@"使用trans接口的矩阵");
        [self printTransform:trans_1];

        _fiveLayer.transform = trans_1;
        
        trans_1 = CATransform3DIdentity;
        trans_1.m44 = 2;
        NSLog(@"不使用trans接口，直接赋值的矩阵");
        [self printTransform:trans_1];
    });
}




//试验六可得
/**
    1. C与OC可以各种嵌套使用
    2. C方法可以出现在@end前，也就是对象里
 **/
- (void) testSix{
    CATransform3D trans_1 = CATransform3DIdentity;
    trans_1.m34 = 4.5/-2000;
    trans_1 = CATransform3DRotate(trans_1,-45*M_PI/180, 0, 1, 0);
    
    //先实验本地方法草稿
    [self changeMatrix:&trans_1 withX:1 withY:2 withZ:3];

}
//根据z轴新向量计算新3维矩阵的方法
//该方法是可以变成纯C的，但为了试验 C 与 OC 方法的兼容性而保留该设计（OC方法调用C方法，C方法又调用OC的nslog方法）
- (void) changeMatrix:(CATransform3D *) matrix withX:(CGFloat) x  withY:(CGFloat) y withZ:(CGFloat) z{
    register CATransform3D * matrix_rig = matrix;
    NSLog(@"Z轴随动3维计算方法，获取的数值为： matrix_rig = %0x  (%0.2f,%0.2f,%0.2f)",matrix_rig,x,y,z);
    NSLog(@"被计算的3维矩阵计算结果");
    printTransform(*matrix_rig);
}
//纯C的矩阵打印法
void printTransform(CATransform3D trans){
    NSLog(@"%0.4f    %0.4f    %0.4f    %0.4f    ",trans.m11,trans.m12,trans.m13,trans.m14);
    NSLog(@"%0.4f    %0.4f    %0.4f    %0.4f    ",trans.m21,trans.m22,trans.m23,trans.m24);
    NSLog(@"%0.4f    %0.4f    %0.4f    %0.4f    ",trans.m31,trans.m32,trans.m33,trans.m34);
    NSLog(@"%0.4f    %0.4f    %0.4f    %0.4f    ",trans.m41,trans.m42,trans.m43,trans.m44);
    NSLog(@" ");
}
//OC的矩阵打印方法
-(void) printTransform:(CATransform3D) trans{
    NSLog(@"%0.4f    %0.4f    %0.4f    %0.4f    ",trans.m11,trans.m12,trans.m13,trans.m14);
    NSLog(@"%0.4f    %0.4f    %0.4f    %0.4f    ",trans.m21,trans.m22,trans.m23,trans.m24);
    NSLog(@"%0.4f    %0.4f    %0.4f    %0.4f    ",trans.m31,trans.m32,trans.m33,trans.m34);
    NSLog(@"%0.4f    %0.4f    %0.4f    %0.4f    ",trans.m41,trans.m42,trans.m43,trans.m44);
    NSLog(@" ");
}



//原作者矩阵运算测试
/**
    1. 恩，我的矩阵更好用些
    2. 恩，我的矩阵更效率些
    3. 作者算法有问题(#‵′)凸
 **/
- (void) testSeven{
    
    //开始测试不同的求逆函数
    NSLog(@"-----------求逆循环随机测试-----------");
    CATransform3D trans_1 = CATransform3DIdentity;
    srand(time(0));
    NSLog(@"被注释掉了");
//    for(int i = 0;i < 20;i++){
//        NSLog(@"第 %d 次使用求逆测试函数：#############",i);
//        trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 1, 0, 0);
//        trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 0, 1, 0);
//        trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 0, 0, 1);
//            NSLog(@"该矩阵的原打印结果为");
//            printTrans(trans_1);
////        matrix_testInverse_1((CATransform3D_my *)(&trans_1));
//        matrix_testInverse_2((CATransform3D_my *)(&trans_1));
//    }
    NSLog(@"^^^^^^^^^^^^求逆循环随机测试^^^^^^^^^^^^");
    
    //开始测不同求逆函数的效率问题
    NSLog(@"-----------求逆效率循环随机测试-----------");
    struct _Matrix tranContainer;
    matrix_initWithNM(&tranContainer, 3, 3);
    struct _Matrix result;
    matrix_initWithNM(&result, 3, 3);
    struct _Matrix identity;
    matrix_initWithNM(&identity, 3, 3);
    
    int testTimes = 100;
    NSLog(@"循环次数为：%d",testTimes);
    
    clock_t tm = clock();
    for(int i = 0;i < testTimes;i++){
        trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 1, 0, 0);
        trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 0, 1, 0);
        trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 0, 0, 1);
        matrix_trans3DToThreeMatrix((CATransform3D_my *)&trans_1,&tranContainer);
        matrix_inverse(&tranContainer,&result);
    }
    NSLog(@"循环一占用的时间为：%lu",clock() - tm);
    
    tm = clock();
    for(int i = 0;i < testTimes;i++){
        trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 1, 0, 0);
        trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 0, 1, 0);
        trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 0, 0, 1);
        matrix_trans3DToThreeMatrix((CATransform3D_my *)&trans_1,&tranContainer);
        matrix_inverse_unsafe(&tranContainer,&result);
    }
    NSLog(@"循环二占用的时间为：%lu",clock() - tm);
    
    tm = clock();
    for(int i = 0;i < testTimes;i++){
        trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 1, 0, 0);
        trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 0, 1, 0);
        trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 0, 0, 1);
        matrix_trans3DToThreeMatrix((CATransform3D_my *)&trans_1,&tranContainer);
        matrix_resetIndentity_unsafe(&identity);
        matrix_inverse_unsafe_efficient(&tranContainer,&identity);
    }
    NSLog(@"循环三占用的时间为：%lu",clock() - tm);
    
    NSLog(@"^^^^^^^^^^^^求逆效率循环随机测试^^^^^^^^^^^^");
    
    
    NSLog(@"--------------------------其他测试--------------------------")
    matrix_testMyself();
    
    NSLog(@"线性矩阵转3d矩阵测试：");
    trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 1, 0, 0);
    trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 0, 1, 0);
    trans_1 = CATransform3DRotate(trans_1,(rand()%360 - 180)*M_PI/180, 0, 0, 1);
    matrix_trans3DToThreeMatrix((CATransform3D_my *)&trans_1,&tranContainer);
    matrix_resetIndentity_unsafe(&identity);
    matrix_inverse_unsafe_efficient(&tranContainer,&identity);
    matrix_transThreeMatrixTo3D((CATransform3D_my *)&trans_1, &identity);
    NSLog(@"    线性矩阵为：");
    printf_matrix(&identity);
    NSLog(@"    3d矩阵为：");
    printTrans(trans_1);
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^其他测试^^^^^^^^^^^^^^^^^^^^^^^^^^");
    
    
    
    matrix_free(&tranContainer);
    matrix_free(&result);
    matrix_free(&identity);
}








@end












