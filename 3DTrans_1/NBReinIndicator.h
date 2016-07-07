//坐标显示控制手柄套装 —— 坐标显示器代码组

//代码基本思路：
/**
    basicInit：进行最基本属性的初始化，view长宽，屏幕的宽高等
    layerInit：本view包含两个layer，一个用来绘制坐标系，一个用来绘制指示器，该方法中仅初始化layer的线条显色等，路径还没初始化
    createCoordinatePath：返回坐标的绘制路径，该路径作为属性在对象中持有，因为坐标的显示与否是可控的，不希望开关时不断新建对象
    self.showIndicator/self.showCoordinate：
        坐标和指示器开关属性默认都是开，设定方法被重写了，因为开关会有一系列的动作存在
        指示器显示情况的设定仅仅是属性值更改，但其响应是在后面实际绘制中判断的
        坐标系显示情况的设定会控制layer.path的为空情况，不会空就会使得屏幕自动渲染路径
    moveOriginToCenter：将原点移到中点，原点以距离中点的偏移的方式移动，详见属性说明
    self.virWidth：
        默认设定的虚拟宽为100，也就是说设备屏幕宽统一虚拟化为100
        该方法会计算出 虚拟宽 / 实际宽 比值来存于属性中，用与转化和计算
    self.indicatorColor：指示器的颜色默认为黑色（包括坐标数字），这也是可以设定的，详见属性说明
 
    drawIndicatorWithActualPoint：
        根据在该view中的location绘制指示器的对外对内接口
        开头便会判断是否显示坐标，不让显示则直接不绘图
        若让显示，但坐标又没有显示，则会强制显示坐标线
    eraseIndicator：
        擦除指示器的对内对外接口
        若坐标线被强制显示了，也会在这里得到擦除
 **/

//特别说明：
/**
    1. 该view的宽高为0，所以使用者对该view.center位置的确定，实际就是设定了原点的位置
    2. 该坐标系是一屏幕宽高为基础的，与父视图无关
    3. 虚拟宽的更改是及时响应的，但是依据之前虚拟宽而偏移的原点位置，不会因为新虚拟宽的设定而重定位（一波缺陷）
    4. 
 **/


#import <UIKit/UIKit.h>

#define FONT_SIZE       12              //x，y坐标打印的字符大小

@interface NBReinIndicator : UIView{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    UIBezierPath *_coordinatePath;          //坐标系绘图对象
    CAShapeLayer *_coordinateLayer;
    
    CGFloat _vir_act;                       //virWidth / actualWidth 的系数
    CGFloat _vir_width;
    
    CAShapeLayer *_indicatorLayer;          //指示器层layer
    
    
}

@property(readwrite)   BOOL showCoordinate;             //是否展示坐标系 和 指示器
@property(readwrite)   BOOL showIndicator;
@property(readwrite)   CGFloat virWidth;                //虚拟屏幕宽度（后续坐标计算等都要依据这个）
@property(readwrite,strong)   UIColor *indicatorColor;

-(void) moveOriginToCenter;                             //定位原点到屏幕中间
-(void) offsetOriginFromCenterWithVirPoint:(CGPoint)virPoint;   //依据虚拟坐标的距离中点的偏移量来偏移原点

-(void)drawIndicatorWithActualPoint: (CGPoint)actualPoint;      //必须传入在该view中的实际坐标来绘制
-(void) drawIndicatorWithVirPoint: (CGPoint)virPoint;           //传入虚拟坐标来绘制指示器
-(void) eraseIndicator;                                         //擦除指示器

-(CGPoint) actToVir:(CGPoint)actPoint;                  //必须传入在该view中的实际坐标来转换为虚拟坐标
-(CGPoint) virToAct:(CGPoint)virPoint;                  //必须传入在该view中的实际坐标来转换为虚拟坐标

@end
