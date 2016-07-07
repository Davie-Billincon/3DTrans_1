//
//  matrix.h
//  3DTrans_1
//
//  Created by Davie on 16/7/4.
//  Copyright © 2016年 Davie. All rights reserved.
//
//这是原作者的矩阵算法，有错误
/**
    1. 求逆算法中，上三角消元，出现重复（k,k） == 0 处理
    2. 求逆算法中，下三角消元，（k,k） == 0 处理中，作者在找到符合条件的行后，未使用该行进行行替换，而是默认使用k+1行
 **/

#ifndef matrix_h
#define matrix_h

//头文件
#include <stdio.h>
#include <stdlib.h>



//二维矩阵互数据结构
struct _Matrix
{
    int m;          //行
    int n;          //列
    float *arr;     //等待动态开辟内存
};


//设置矩阵m的值
void matrix_set_m(struct _Matrix *m,int mm);
//设置矩阵n的值
void matrix_set_n(struct _Matrix *m,int nn);
//初始化
void matrix_init(struct _Matrix *m);
//释放
void matrix_free(struct _Matrix *m);

//工具函数--------------------------------------------------
//读取i,j坐标的数据。失败返回-31415,成功返回值
float matrix_read(struct _Matrix *m,int i,int j);
//写入i,j坐标的数据。失败返回-1,成功返回1
int matrix_write(struct _Matrix *m,int i,int j,float val);
//格式化打印矩阵
void printf_matrix(struct _Matrix *A);


//矩阵算法函数--------------------------------------------------
//C = A + B 。成功返回1,失败返回-1
int matrix_add(struct _Matrix *A,struct _Matrix *B,struct _Matrix *C);

//C = A - B 。成功返回1,失败返回-1
int matrix_subtract(struct _Matrix *A,struct _Matrix *B,struct _Matrix *C);

//C = A * B 。成功返回1,失败返回-1
int matrix_multiply(struct _Matrix *A,struct _Matrix *B,struct _Matrix *C);

//求逆矩阵,B = A^(-1) 。成功返回1,失败返回-1
int matrix_inverse(struct _Matrix *A,struct _Matrix *B);

//行列式的值 。只能计算2 * 2,3 * 3,失败返回-31415,成功返回值
float matrix_det(struct _Matrix *A);

//求转置矩阵,B = AT 。成功返回1,失败返回-1
int matrix_transpos(struct _Matrix *A,struct _Matrix *B);


#endif /* matrix_h */
