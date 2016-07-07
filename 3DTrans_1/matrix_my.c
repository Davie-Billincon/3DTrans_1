//
//  matrix_my.c
//  3DTrans_1
//
//  Created by Davie on 16/7/6.
//  Copyright © 2016年 Davie. All rights reserved.
//

#include "matrix_my.h"


//工具方法----------------------------------------------------------------------------------------
//同时设置m和n并初始化
void matrix_initWithNM(struct _Matrix *m,int mm,int nn){
    m->m = mm;
    m->n = nn;
    m->arr = (float *)malloc(mm * nn * sizeof(float));
}


//无判定的坐标读取
float matrix_read_unsafe(struct _Matrix *m,int i,int j)
{
    return *(m->arr + i * m->n + j);
}

//无判定的坐标写入
int matrix_write_unsafe(struct _Matrix *m,int i,int j,float val)
{
    *(m->arr + i * m->n + j) = val;
    return 1;
}

//单位矩阵初始化
void matrix_resetIndentity_unsafe(struct _Matrix *m){
    
    int i = 0;
    int j = 0;
    
    for (i = 0;i < m->m;i++)
    {
        for (j = 0;j < m->n;j++)
        {
            if (i == j)
            {
                matrix_write_unsafe(m,i,j,1);
            }
            else
            {
                matrix_write_unsafe(m,i,j,0);
            }
            
        }
    }
}

int matrix_copy_unsafe(struct _Matrix * from,struct _Matrix * target){
    int i = 0;
    int j = 0;
    
    for (i = 0;i < from->m;i++)
    {
        for (j = 0;j < from->n;j++)
        {
            matrix_write_unsafe(target,i,j,matrix_read_unsafe(from, i, j));
        }
    }
    
    return 1;
}

//将官方矩阵转换为3维本地矩阵格式
void matrix_trans3DToThreeMatrix(CATransform3D_my * trans,struct _Matrix * target){
    matrix_write_unsafe(target,0,0,trans->m11);
    matrix_write_unsafe(target,0,1,trans->m12);
    matrix_write_unsafe(target,0,2,trans->m13);
    matrix_write_unsafe(target,1,0,trans->m21);
    matrix_write_unsafe(target,1,1,trans->m22);
    matrix_write_unsafe(target,1,2,trans->m23);
    matrix_write_unsafe(target,2,0,trans->m31);
    matrix_write_unsafe(target,2,1,trans->m32);
    matrix_write_unsafe(target,2,2,trans->m33);
}
void matrix_transThreeMatrixTo3D(CATransform3D_my * trans,struct _Matrix * from){
    trans->m11 = matrix_read_unsafe(from,0,0);
    trans->m12 = matrix_read_unsafe(from,0,1);
    trans->m13 = matrix_read_unsafe(from,0,2);
    trans->m21 = matrix_read_unsafe(from,1,0);
    trans->m22 = matrix_read_unsafe(from,1,1);
    trans->m23 = matrix_read_unsafe(from,1,2);
    trans->m31 = matrix_read_unsafe(from,2,0);
    trans->m32 = matrix_read_unsafe(from,2,1);
    trans->m33 =  matrix_read_unsafe(from,2,2);
}



//具体算法-----------------------------------------------------------------------------------------
//矩阵加法
int matrix_add_unsafe(struct _Matrix *A,struct _Matrix *B,struct _Matrix *C)
{
    int i = 0;
    int j = 0;
    
    //运算
    for (i = 0;i < C->m;i++)
    {
        for (j = 0;j < C->n;j++)
        {
            //C对应坐标 =  A对应坐标 + C对应坐标
            matrix_write_unsafe(C,i,j,matrix_read_unsafe(A,i,j) + matrix_read_unsafe(B,i,j));
        }
    }
    
    return 1;
}

//矩阵减法
int matrix_subtract_unsafe(struct _Matrix *A,struct _Matrix *B,struct _Matrix *C)
{
    int i = 0;
    int j = 0;
    
    //运算
    for (i = 0;i < C->m;i++)
    {
        for (j = 0;j < C->n;j++)
        {
            matrix_write_unsafe(C,i,j,matrix_read_unsafe(A,i,j) - matrix_read_unsafe(B,i,j));
        }
    }
    
    return 1;
}

//矩阵乘法
int matrix_multiply_unsafe(struct _Matrix *A,struct _Matrix *B,struct _Matrix *C)
{
    int i = 0;
    int j = 0;
    int k = 0;
    float temp = 0;
    
    //运算
    for (i = 0;i < C->m;i++)        //二次循环 为C的 m*n 赋值
    {
        for (j = 0;j < C->n;j++)    //二次循环 为C的 m*n 赋值
        {
            temp = 0;
            for (k = 0;k < A->n;k++)//行 * 列 对应位数相乘并相加
            {
                temp += matrix_read_unsafe(A,i,k) * matrix_read_unsafe(B,k,j);
            }
            matrix_write_unsafe(C,i,j,temp);
        }
    }
    
    return 1;
}


//矩阵求逆
int matrix_inverse_unsafe(struct _Matrix *A,struct _Matrix *B)
{
    struct _Matrix m;       //增广临时矩阵
    
    int i = 0;
    int j = 0;
    int k = 0;
    float temp = 0;
    float b = 0;
    
    //增广矩阵m = A | B初始化(2倍的列)
    matrix_initWithNM(&m, A->m, 2 * A->m);
    
    //赋值A矩阵到增广矩阵左侧，右侧置为单位矩阵
    for (i = 0;i < m.m;i++)
    {
        for (j = 0;j < m.n;j++)
        {
            
            if (j < A->n )  //列在左侧时
            {
                matrix_write_unsafe(&m,i,j,matrix_read_unsafe(A,i,j));
            }
            else
            {
                if (i == j - A->n)
                {
                    matrix_write_unsafe(&m,i,j,1);
                }
                else
                {
                    matrix_write_unsafe(&m,i,j,0);
                }
            }
            
        }
    }
    
    //高斯消元
    /**
     1. 首先确保对角线的数不能为0（在处理每行的时候）
     2. 先消上三角为0 还是下三角 顺序无所谓，这用先下来举例
     3. 第一行 * 某个系数 + 第二行 使得 第二行的第 1 数为0，第三行的第 1 数为0，…… ，（因为第一行第一个数在对角线，必定有值）
     4. 第二行 * 某个系数 + 第三行 使得 第三行的第 2 数为0，第四行的第 2 数为0，…… ，（因为每行第 1 数已经为0，所以……）
     5. 依此类推直到整个下3角都为0
     6. 从最后一行开始 * 系数 + 倒数第二行 …… 整个上三角为0
     **/
    
    //变换下三角
    for (k = 0;k < m.m - 1;k++) //遍历处理 m-1 行
    {
        //如果坐标为（k,k）的数为0,则需要向下进行行交换，使其不为0（每次循环都要，因为谁知道上一次行列变换有没有把这行变成0）
        if (matrix_read_unsafe(&m,k,k) == 0)
        {
            //从下一行开始筛选，第k列不为0的行（第i行）
            for (i = k + 1;i < m.m;i++)
            {
                if (matrix_read_unsafe(&m,i,k) != 0){ break; }
            }
            //若筛选到最后一行都没有符合条件的，则失败
            if (i >= m.m) { return -1; }
            
            //现在，在第k行出现（k.k）为0的情况下，发现第i行k数不为0，则开始交换行
            else
            {
                for (j = 0;j < m.n;j++)     //读取每列，交换对应坐标的数
                {
                    temp = matrix_read_unsafe(&m,k,j);
                    matrix_write_unsafe(&m,k,j,matrix_read_unsafe(&m,i,j));
                    matrix_write_unsafe(&m,i,j,temp);
                }
            }
        }
        
        //消元（使用第k行的第k数，从第k行的下一行开始消起，消到最后一行）
        for (i = k + 1;i < m.m;i++)
        {
            //获得倍数（第 k 往下所有行的第 k 个数 - b * 第 k 行第 k 个数 = 0）
            b = matrix_read_unsafe(&m,i,k) / matrix_read_unsafe(&m,k,k);
            
            //使用倍数，将第 k往下所有i行 对应位 减去 第 k行 对应位
            for (j = 0;j < m.n;j++)
            {
                temp = matrix_read_unsafe(&m,i,j) - b * matrix_read_unsafe(&m,k,j);
                matrix_write_unsafe(&m,i,j,temp);
            }
        }
    }
    
    
    //变换上三角
    for (k = m.m - 1;k > 0;k--)//从最后一行开始，向上处理
    {
        
        //等等，既然下列算式，并不能处理（下三角变换后，坐标(m,n)为0）的情况，而由于下三角为0，并不会出现（k,k）为0的情况，我要这个干嘛？
        //        //如果坐标为k,k的数为0,则行变换
        //        //但同样还是向下替换，这样才不会弄乱 下三角 处理好的内容)（下三角变换后，坐标(k,k)为0的话就GG了）
        //        if (matrix_read_unsafe(&m,k,k) == 0)
        //        {
        //            for (i = k + 1;i < m.m;i++)
        //            {
        //                if (matrix_read_unsafe(&m,i,k) != 0)
        //                {
        //                    break;
        //                }
        //            }
        //            if (i >= m.m)
        //            {
        //                return -1;
        //            }
        //            else
        //            {
        //                //交换行
        //                for (j = 0;j < m.n;j++)
        //                {
        //                    temp = matrix_read_unsafe(&m,k,j);
        //                    matrix_write(&m,k,j,matrix_read_unsafe(&m,k + 1,j));
        //                    matrix_write_unsafe(&m,k + 1,j,temp);
        //                }
        //            }
        //        }
        
        //消元
        for (i = k - 1;i >= 0;i--)
        {
            //获得倍数
            b = matrix_read_unsafe(&m,i,k) / matrix_read_unsafe(&m,k,k);
            //行变换
            for (j = 0;j < m.n;j++)
            {
                temp = matrix_read_unsafe(&m,i,j) - b * matrix_read_unsafe(&m,k,j);
                matrix_write_unsafe(&m,i,j,temp);
            }
        }
    }
    
    //将左边方阵化为单位矩阵（遍历每行的（k,k），除以k）
    for (i = 0;i < m.m;i++)
    {
        if (matrix_read_unsafe(&m,i,i) != 1)
        {
            //获得倍数
            b = 1 / matrix_read_unsafe(&m,i,i);
            //行变换
            for (j = 0;j < m.n;j++)
            {
                temp = matrix_read_unsafe(&m,i,j) * b;
                matrix_write_unsafe(&m,i,j,temp);
            }
        }
    }
    //求得逆矩阵
    for (i = 0;i < B->m;i++)
    {
        for (j = 0;j < B->m;j++)
        {
            matrix_write_unsafe(B,i,j,matrix_read_unsafe(&m,i,j + m.m));
        }
    }
    //释放增广矩阵
    matrix_free(&m);
    
    return 1;
}


int matrix_inverse_unsafe_efficient(struct _Matrix *A,struct _Matrix * identity){
    
    //用作循环计数
    int i = 0;
    int j = 0;
    int k = 0;
    
    float temp = 0;
    float b = 0;
    
    //变换下三角
    for (k = 0;k < A->m - 1;k++) //遍历处理 m-1 行
    {
        //如果坐标为（k,k）的数为0,则需要向下进行行交换，使其不为0（每次循环都要，因为谁知道上一次行列变换有没有把这行变成0）
        if (matrix_read_unsafe(A,k,k) == 0)
        {
            //从下一行开始筛选，第k列不为0的行（第i行）
            for (i = k + 1;i < A->m;i++)
            {
                if (matrix_read_unsafe(A,i,k) != 0){ break; }
            }
            //若筛选到最后一行都没有符合条件的，则失败
            if (i >= A->m) { return -1; }
            
            //现在，在第k行出现（k.k）为0的情况下，发现第i行k数不为0，则开始交换行
            else
            {
                for (j = 0;j < A->n;j++)     //读取每列，交换对应坐标的数
                {
                    //先换行原矩阵
                    temp = matrix_read_unsafe(A,k,j);
                    matrix_write_unsafe(A,k,j,matrix_read_unsafe(A,i,j));
                    matrix_write_unsafe(A,i,j,temp);
                    
                    //再操作单位伴随矩阵
                    temp = matrix_read_unsafe(identity,k,j);
                    matrix_write_unsafe(identity,k,j,matrix_read_unsafe(identity,i,j));
                    matrix_write_unsafe(identity,i,j,temp);
                }
            }
        }
        
        //消元（使用第k行的第k数，从第k行的下一行开始消起，消到最后一行）
        for (i = k + 1;i < A->m;i++)
        {
            //获得倍数（第 k 往下所有行的第 k 个数 - b * 第 k 行第 k 个数 = 0）
            b = matrix_read_unsafe(A,i,k) / matrix_read_unsafe(A,k,k);
            
            //使用倍数，将第 k往下所有i行 对应位 减去 第k行 对应位
            for (j = 0;j < A->n;j++)
            {
                //先操作原矩阵
                temp = matrix_read_unsafe(A,i,j) - b * matrix_read_unsafe(A,k,j);
                matrix_write_unsafe(A,i,j,temp);
                
                //再操作单位伴随矩阵
                temp = matrix_read_unsafe(identity,i,j) - b * matrix_read_unsafe(identity,k,j);
                matrix_write_unsafe(identity,i,j,temp);
            }
        }
    }
    
    
    //变换上三角
    for (k = A->m - 1;k > 0;k--)//从最后一行开始，向上处理
    {
        //消元
        for (i = k - 1;i >= 0;i--)
        {
            //获得倍数
            b = matrix_read_unsafe(A,i,k) / matrix_read_unsafe(A,k,k);
            
            //行变换
            for (j = 0;j < A->n;j++)
            {
                //先操作原矩阵
                temp = matrix_read_unsafe(A,i,j) - b * matrix_read_unsafe(A,k,j);
                matrix_write_unsafe(A,i,j,temp);
                
                //再操作单位伴随矩阵
                temp = matrix_read_unsafe(identity,i,j) - b * matrix_read_unsafe(identity,k,j);
                matrix_write_unsafe(identity,i,j,temp);
            }
        }
    }
    
    //将左边方阵化为单位矩阵（遍历每行的（k,k），除以k）
    for (i = 0;i < A->m;i++)
    {
        if (matrix_read_unsafe(A,i,i) != 1)
        {
            //获得倍数（这里获得倍数是为了减小下面行变换时的除法压力）
            b = 1 / matrix_read_unsafe(A,i,i);
            
            //行变换
            for (j = 0;j < A->n;j++)
            {
                //仅操作单位伴随矩阵即可
                temp = matrix_read_unsafe(identity,i,j) * b;
                matrix_write_unsafe(identity,i,j,temp);
                
                //若是为了测试，取消下面行的注释，可以看出原矩阵是否都变为1了
//                temp = matrix_read_unsafe(A,i,j) * b;
//                matrix_write_unsafe(A,i,j,temp);
            }
        }
    }

    return 1;
}

//其他必要的矩阵生成算法-----------------------------------------------------------------
//主动空间坐标矩阵生成
int getZhuDongSpace_withZ(struct _Matrix *result,float a,float b,float c){
    float temp_1 = a/sqrt(a*a + b*b);
    float temp_2 = b/sqrt(a*a + b*b);
    
    matrix_write_unsafe(result, 0, 0,   temp_1);
    matrix_write_unsafe(result, 0, 1,   temp_2);
    matrix_write_unsafe(result, 0, 2,   0);
    matrix_write_unsafe(result, 1, 0,  -temp_2);
    matrix_write_unsafe(result, 1, 1,   temp_1);
    matrix_write_unsafe(result, 1, 2,   0);
    matrix_write_unsafe(result, 2, 0,   0);
    matrix_write_unsafe(result, 2, 1,   0);
    matrix_write_unsafe(result, 2, 2,   1);
    return 1;
}
//主动空间，标准容器运动坐标矩阵生成
int getZhuDongContainerMove_withZ(struct _Matrix *result,float a,float b,float c){
    float temp_1 = sqrt(a*a + b*b)/sqrt(a*a + b*b + c*c);
    float temp_2 = c/sqrt(a*a + b*b + c*c);
    
    matrix_write_unsafe(result, 0, 0,   temp_2);
    matrix_write_unsafe(result, 0, 1,   0);
    matrix_write_unsafe(result, 0, 2,  -temp_1);
    matrix_write_unsafe(result, 1, 0,   0);
    matrix_write_unsafe(result, 1, 1,   1);
    matrix_write_unsafe(result, 1, 2,   0);
    matrix_write_unsafe(result, 2, 0,   temp_1);
    matrix_write_unsafe(result, 2, 1,   0);
    matrix_write_unsafe(result, 2, 2,   temp_2);
    return 1;
}
//针对主动空间的求逆
void getInverse_fromZhuDongSpace(struct _Matrix *zhuDongSpace){
    matrix_write_unsafe(zhuDongSpace,0,1,-matrix_read_unsafe(zhuDongSpace,0,1));
    matrix_write_unsafe(zhuDongSpace,1,0,-matrix_read_unsafe(zhuDongSpace,1,0));
}



//测试--------------------------------------------------------------------------------------
//自己测试自己 —— 永远置底
void matrix_testMyself(){
    int i = 0;
    int j = 0;
    int k = 0;
    struct _Matrix m1;
    struct _Matrix m2;
    struct _Matrix m3;
    
    //初始化内存
    matrix_set_m(&m1,3);
    matrix_set_n(&m1,3);
    matrix_init(&m1);
    matrix_set_m(&m2,3);
    matrix_set_n(&m2,3);
    matrix_init(&m2);
    matrix_set_m(&m3,3);
    matrix_set_n(&m3,3);
    matrix_init(&m3);
    
    //初始化数据
    k = 1;
    for (i = 0;i < m1.m;i++)
    {
        for (j = 0;j < m1.n;j++)
        {
            matrix_write(&m1,i,j,k++);
        }
    }
    
    for (i = 0;i < m2.m;i++)
    {
        for (j = 0;j < m2.n;j++)
        {
            matrix_write(&m2,i,j,k++);
        }
    }
    
    //原数据
    printf("A矩阵初始化完毕为:\n");
    printf_matrix(&m1);
    printf("B矩阵初始化完毕为:\n");
    printf_matrix(&m2);
    
    printf("\n");
    
    printf("A:行列式的值%f\n",matrix_det(&m1));
    
    printf("\n");
    
    //C = A + B
    if (matrix_add_unsafe(&m1,&m2,&m3) > 0)
    {
        printf("C = A + B:\n");
        printf_matrix(&m3);
    }
    
    printf("\n");
    
    //C = A - B
    if (matrix_subtract_unsafe(&m1,&m2,&m3) > 0)
    {
        printf("C = A - B:\n");
        printf_matrix(&m3);
    }
    
    printf("\n");
    
    //C = A * B
    if (matrix_multiply_unsafe(&m1,&m2,&m3) > 0)
    {
        printf("C = A * B:\n");
        printf_matrix(&m3);
    }
    
    printf("\n");
    
    if (matrix_inverse_unsafe(&m2,&m3) > 0)
    {
        printf("C = A^(-1):\n");
        printf_matrix(&m3);
    }
    
    printf("\n");
    
    //C = AT
    if (matrix_transpos(&m1,&m3) > 0)
    {
        printf("C = AT:\n");
        printf_matrix(&m3);
    }
    
    printf("单位矩阵设置测试\n");
    struct _Matrix m4;
    matrix_initWithNM(&m4, 5, 7);
    printf_matrix(&m4);
    matrix_resetIndentity_unsafe(&m4);
    printf("设置前/设置后\n");
    printf_matrix(&m4);
    
    printf("矩阵复制测试\n");
    matrix_copy_unsafe(&m3, &m4);
    printf_matrix(&m4);
    
    printf("获取主动空间测试\n");
    getZhuDongSpace_withZ(&m1, 3, 4, 5);
    printf_matrix(&m1);
    
    printf("获取主动空间标准容器运动后的测试\n");
    getZhuDongContainerMove_withZ(&m1, 3, 4, 5);
    printf_matrix(&m1);
    
    printf("主动空间求逆规律观察测试组----------------------\n");
    printf("1\n");
    getZhuDongSpace_withZ(&m1, 3, 4, 5);
    printf("Z轴运动求得的主动空间\n");
    printf_matrix(&m1);
    matrix_resetIndentity_unsafe(&m2);
    matrix_inverse_unsafe_efficient(&m1, &m2);
    printf("主动空间求逆结果\n");
    printf_matrix(&m2);
    
    printf("2\n");
    getZhuDongSpace_withZ(&m1, 4, 5, 6);
    printf("Z轴运动求得的主动空间\n");
    printf_matrix(&m1);
    matrix_resetIndentity_unsafe(&m2);
    matrix_inverse_unsafe_efficient(&m1, &m2);
    printf("主动空间求逆结果\n");
    printf_matrix(&m2);
    
    printf("3\n");
    getZhuDongSpace_withZ(&m1, 5, 6, 7);
    printf("Z轴运动求得的主动空间\n");
    printf_matrix(&m1);
    matrix_resetIndentity_unsafe(&m2);
    matrix_inverse_unsafe_efficient(&m1, &m2);
    printf("主动空间求逆结果\n");
    printf_matrix(&m2);
    
    printf("4\n");
    getZhuDongSpace_withZ(&m1, 3, 4, 5);
    printf("Z轴运动求得的主动空间\n");
    printf_matrix(&m1);
    getInverse_fromZhuDongSpace(&m1);
    printf("主动空间求逆结果\n");
    printf_matrix(&m1);
    
    printf("5\n");
    getZhuDongSpace_withZ(&m1, 4, 5, 6);
    printf("Z轴运动求得的主动空间\n");
    printf_matrix(&m1);
    getInverse_fromZhuDongSpace(&m1);
    printf("主动空间求逆结果\n");
    printf_matrix(&m1);
    
    printf("6\n");
    getZhuDongSpace_withZ(&m1, 5, 6, 7);
    printf("Z轴运动求得的主动空间\n");
    printf_matrix(&m1);
    getInverse_fromZhuDongSpace(&m1);
    printf("主动空间求逆结果\n");
    printf_matrix(&m1);
    printf("主动空间求逆规律观察测试组^^^^^^^^^^^^^^^^^^^^^^^^\n");
    
    matrix_free(&m1);
    matrix_free(&m2);
    matrix_free(&m3);
    matrix_free(&m4);
}


void matrix_testInverse_1(CATransform3D_my * trans){
    struct _Matrix m1;
    matrix_initWithNM(&m1, 3, 3);
    matrix_trans3DToThreeMatrix(trans,&m1);
    
    printf("求逆测试-传入的3D矩阵为:\n");
    printf_matrix(&m1);
    
    struct _Matrix m2;
    matrix_initWithNM(&m2, 3, 3);
    printf("求逆测试-matrix_inverse_unsafe计算结果为:\n");
    if(matrix_inverse_unsafe(&m1, &m2) > 0){
        printf_matrix(&m2);
        
        struct _Matrix m3;
        matrix_initWithNM(&m3, 3, 3);
        matrix_multiply_unsafe(&m1, &m2, &m3);
        printf("求逆测试-求逆前 * 求逆后的结果为:\n");
        printf_matrix(&m3);
        
        float result = matrix_det(&m3);
        printf("行列式结果为：%0.7f   \n",result);
        if(result >= 0.99999 && result <= 1.00001){
            printf("                                          成功\n");
        }else{
            printf("                                          失败\n");
        }
        printf("\n");
        matrix_free(&m3);
    }else{
        printf("-1");
        printf("\n");
    }
    
    matrix_free(&m1);
    matrix_free(&m2);
}

void matrix_testInverse_2(CATransform3D_my * trans){
    struct _Matrix m1;
    matrix_initWithNM(&m1, 3, 3);
    matrix_trans3DToThreeMatrix(trans,&m1);
    struct _Matrix m4;
    matrix_initWithNM(&m4, 3, 3);
    matrix_trans3DToThreeMatrix(trans,&m4);
    
    printf("求逆测试-传入的3D矩阵为:\n");
    printf_matrix(&m1);
    
    struct _Matrix m2;
    matrix_initWithNM(&m2, 3, 3);
    matrix_resetIndentity_unsafe(&m2);
    
    printf("求逆测试-matrix_inverse_unsafe_efficient计算结果为:\n");
    if(matrix_inverse_unsafe_efficient(&m1, &m2) > 0){
        printf_matrix(&m2);
        
        printf("求逆测试-原矩阵变成了:\n");
        printf_matrix(&m1);
        
        struct _Matrix m3;
        matrix_initWithNM(&m3, 3, 3);
        matrix_multiply_unsafe(&m4, &m2, &m3);
        printf("求逆测试-求逆前 * 求逆后的结果为:\n");
        printf_matrix(&m3);
        
        float result = matrix_det(&m3);
        printf("求逆测试-乘法结果的行列式结果为：%0.7f   \n",result);
        if(result >= 0.99999 && result <= 1.00001){
            printf("                                          成功\n");
        }else{
            printf("                                          失败\n");
        }
        printf("\n");
        matrix_free(&m3);
    }else{
        printf("-1");
        printf("\n");
    }
    matrix_free(&m1);
    matrix_free(&m2);
    matrix_free(&m4);
}
