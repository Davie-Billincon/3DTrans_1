//坐标显示控制手柄套装 —— 手柄代码组

//代码基本思路是：
/**
    drawReinView：   将传入的空view对象绘制为圆形（颜色为灰色，使用define好的半径）
    setGestures：    为给定view添加手势识别器，独立出来是因为可能还需要添加其他识别器，目前添加的是pan滑动识别器
    setControlEventHandler：为传入的control对象设定事件回调，目前设定了“按下、抬起、任何原因的取消”，回调都作为属性存在于对象中，若不为空，则会予以调用
    panHandel：
        pan滑动回调组，会获取滑动location在superView中的位置，并重定位本身到该位置，也就是手柄随着滑动而滑动
        若使用者设定了滑动回调，重定位后，调用使用者设定的回调，详见属性说明
        若是配套了坐标指示器indicator对象：
            获取location在indicatorview中的位置，传送并调用其中的坐标显示方法进行坐标显示
            检测滑动状态为结束的话，则erase显示的坐标
            若坐标内滑动回调存在，则使用indicator内置转换方法获取locaiton的虚拟坐标，传给回调，详见属性说明
    tapHandelTouchDown：
        control对象的按下回调组
        若是配套了坐标指示器indicator对象，则转化坐标并予以显示
        若使用者给予了这方面的回调，则调用回调，详见属性说明
    tapHandelTouchCancel：
        control对象各种cancel的回调
        若是配套了坐标指示器indicator对象，则调用擦除坐标指示器方法
        若使用者给予了这方面的回调，则调用回调，详见属性说明
 **/

//其他说明
/**
    1. 当按下，然后滑动的时候，会调用一次“使用者滑动闭包”，然后触发control的cancel回调
    2. 使用期间的任何属性变化都会即时相应，比如去除某种回调，给予某种回调
    3. 配套的indicator为空了，仅仅是取消了坐标显示和坐标滑动回调，不会崩溃
 **/



#import <UIKit/UIKit.h>
#import "NBReinIndicator.h"

#define CTROL_VIEW_SIZE 35              //圆形的直径

//回调闭包属性定义组--------------------------------------------------------
//无坐标手柄滑动回调：直接传入滑动手势对象，你爱怎么用怎么用
typedef void (^ReinHandlerPan)(UIPanGestureRecognizer *reinPan);

//坐标内滑动回调：传入滑动时，依据坐标原点和转换方式的虚拟坐标供你使用
typedef void (^ReinHandlerPanForIndicator)(UIPanGestureRecognizer *reinPan,CGPoint virPoint);

//手柄按下回调：目前是传入controlview的中点在父view的坐标，和父view对象，你可以使用view坐标转化方法进行转化以获取你需要的坐标
typedef void (^ReinHandlerTouchDown)(CGPoint location,UIView *locateView);

//手柄取消回调：目前是不给予任何坐标，因为取消一般涉及的是多个取消操作
typedef void (^ReinHandlerTouchCancle)(void);
//--------------------------------------------------------

@interface NBRein : UIControl{
    
}


-(void) changeReinColor:(UIColor *)color;                   //更换手柄颜色的方法
@property(readwrite,strong) NBReinIndicator *indicator;     //配套indicator坐标指示器
@property(readwrite,strong) ReinHandlerPan reinHandlerPan;  //各种回调（作为属性一直持有）
@property(readwrite,strong) ReinHandlerPanForIndicator reinHandlerPanForIndicator;  //各种回调（作为属性一直持有）
@property(readwrite,strong) ReinHandlerTouchDown reinHandlerTouchDown;      //各种回调（作为属性一直持有）
@property(readwrite,strong) ReinHandlerTouchCancle reinHandlerTouchCancle;  //各种回调（作为属性一直持有）

@end


