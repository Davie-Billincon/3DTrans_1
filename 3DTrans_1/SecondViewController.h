//
//  SecondViewController.h
//  3DTrans_1
//
//  Created by Davie on 16/6/13.
//  Copyright © 2016年 Davie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NBRein.h"
#include "NBReinIndicator.h"
#include "3DTrans.h"

@interface SecondViewController : UIViewController{
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
}


@end

