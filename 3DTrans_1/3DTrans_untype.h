//
//  Header.h
//  3DTrans_1
//
//  Created by Davie on 16/7/3.
//  Copyright © 2016年 Davie. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%d\t%s\n", __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

//打印4维矩阵
void printTrans(CATransform3D trans);

//根据提供Z方向的透视参数设置透视
void makeToushiWithZ(CATransform3D *trans,CGFloat toushi);


