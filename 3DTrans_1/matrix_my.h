//
//  matrix_my.h
//  3DTrans_1
//
//  Created by Davie on 16/7/6.
//  Copyright © 2016年 Davie. All rights reserved.
//

//matrix_my为matrix原作者代码借鉴下的优化版本

#ifndef matrix_my_h
#define matrix_my_h

#include <stdio.h>
#include "matrix.h"

#include "math.h"//开根号用的

//下面结构体定义是为了方便求逆测试对UIKit中3D结构体转化的支持
struct CATransform3D_my
{
    double m11, m12, m13, m14;
    double m21, m22, m23, m24;
    double m31, m32, m33, m34;
    double m41, m42, m43, m44;
};
typedef struct CATransform3D_my CATransform3D_my;


//工具方法-----------------------------------------------------------------
//同时设置m和n并初始化
void matrix_initWithNM(struct _Matrix *m,int mm,int nn);

//缺少维度判断的矩阵读取
float matrix_read_unsafe(struct _Matrix *m,int i,int j);

//缺少维度判断的矩阵写入
int matrix_write_unsafe(struct _Matrix *m,int i,int j,float val);

//单位矩阵初始化
//即使传入的不是方阵，也处理为对角线为1，其他为0
void matrix_resetIndentity_unsafe(struct _Matrix *m);

//矩阵复制
//当然，严格要求传入的两个矩阵规模一致(第二个矩阵大一些也行)
int matrix_copy_unsafe(struct _Matrix * from,struct _Matrix * target);

//将官方矩阵转换为3维本地矩阵格式
void matrix_trans3DToThreeMatrix(CATransform3D_my * trans,struct _Matrix * target);

//将3维本地矩阵格式转换为官方矩阵
void matrix_transThreeMatrixTo3D(CATransform3D_my * trans,struct _Matrix * from);




//具体算法-----------------------------------------------------------------
//C = A + B 。成功返回1,失败返回-1
//严格要求 A B C 的维度一样
int matrix_add_unsafe(struct _Matrix *A,struct _Matrix *B,struct _Matrix *C);

//C = A - B 。成功返回1,失败返回-1
//严格要求 A B C 的维度一样
int matrix_subtract_unsafe(struct _Matrix *A,struct _Matrix *B,struct _Matrix *C);

//C = A * B 。成功返回1,失败返回-1
//严格要求 A列 = B行 且 C列 = B列 C行 = A行（行 * 列 = 列 * 行）
int matrix_multiply_unsafe(struct _Matrix *A,struct _Matrix *B,struct _Matrix *C);

//求逆矩阵,B = A^(-1) 。成功返回1,失败返回-1
//严格要求 A为方阵 、AB维度相同
//还有不要给我弄什么不可逆的矩阵过来：非线性 、……自己查
int matrix_inverse_unsafe(struct _Matrix *A,struct _Matrix *B);

//该求逆方法将直接修改传入的两个矩阵，所以若不希望矩阵被更改，请复制矩阵
//由于省去了增广矩阵的初始化和释放，所以效率上得到了提升
int matrix_inverse_unsafe_efficient(struct _Matrix *A,struct _Matrix * identity);


//其他必要的矩阵的生成算法-----------------------------------------------------------------
//主动空间坐标矩阵生成
int getZhuDongSpace_withZ(struct _Matrix *result,float a,float b,float c);
//主动空间，标准容器运动坐标矩阵生成
int getZhuDongContainerMove_withZ(struct _Matrix *result,float a,float b,float c);
//针对主动空间的求逆
void getInverse_fromZhuDongSpace(struct _Matrix *zhuDongSpace);

//测试-----------------------------------------------------------------
//自我测试一
void matrix_testMyself();

//求逆测试一
void matrix_testInverse_1(CATransform3D_my * trans);

//求逆测试二
void matrix_testInverse_2(CATransform3D_my * trans);


#endif /* matrix_my_h */
