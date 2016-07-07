#import <UIKit/UIKit.h>

#import "NBRein.h"
#include "NBReinIndicator.h"
#include "3DTrans.h"


@interface FourViewController : UIViewController{
    UIView *_showView;
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    CALayer *_orangeLayer;
    CALayer *_grayLayer;
    
    NBReinIndicator *_indicator;
    
    //矩阵计算组
    struct _Matrix _zhudongSpace;
    struct _Matrix _zhudongSpace_forInverse;
    struct _Matrix _yundongContainer;
    struct _Matrix _multiplyResult;
    CATransform3D _trans;
    
    //XOZ / YOZ 变化组
    CALayer *_XOZLayer;
    CALayer *_YOZLayer;
    
    struct _Matrix _XOZOrigin;
    struct _Matrix _YOZOrigin;
    CATransform3D _trans_2;
    CATransform3D _trans_3;
}


@end

