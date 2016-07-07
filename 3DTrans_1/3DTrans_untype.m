//
//  3DTrans_untype.c
//  3DTrans_1
//
//  Created by Davie on 16/7/3.
//  Copyright © 2016年 Davie. All rights reserved.
//

//方法设计概览
/**
 总方法是获取z轴向量，返回目的矩阵（后面）
 
 基本思想就是我虽然传入4维矩阵，但我的所有计算都仅仅操作3维，且传入的矩阵是地址
 
 一个方法，传入单位矩阵地址，附上计算后的 运动前主动空间矩阵  （不直接返回是因为，声明矩阵是必须的，但传递该结构体需要复制）
 
 一个求逆方法，也是传入地址，附上返回求完逆后的矩阵
 
 一个求运动矩阵的方法，也是传入单位矩阵地址，然后根据向量返回运动矩阵
 
 一个矩阵乘法方法，目前暂定为传入地址，但返回新矩阵
 **/


#include "3DTrans_untype.h"



void printTrans(CATransform3D trans){
    NSLog(@"%0.4f    %0.4f    %0.4f    %0.4f    ",trans.m11,trans.m12,trans.m13,trans.m14);
    NSLog(@"%0.4f    %0.4f    %0.4f    %0.4f    ",trans.m21,trans.m22,trans.m23,trans.m24);
    NSLog(@"%0.4f    %0.4f    %0.4f    %0.4f    ",trans.m31,trans.m32,trans.m33,trans.m34);
    NSLog(@"%0.4f    %0.4f    %0.4f    %0.4f    ",trans.m41,trans.m42,trans.m43,trans.m44);
    NSLog(@" ");
}

//根据提供Z方向的透视参数设置透视
void makeToushiWithZ(CATransform3D *trans,CGFloat toushi){
    trans -> m14 = trans -> m13 * toushi;
    trans -> m24 = trans -> m23 * toushi;
    trans -> m34 = trans -> m33 * toushi;
}







