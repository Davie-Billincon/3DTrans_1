#CALayer3D动效研究成果一
***
###概述：
* #####在透视效果存在的情况下，控制正交空间的Z轴，来旋转整个空间，并产生对应的动画效果

###内容：
* #####Tab1用来演示控制手柄插件NBRein
	1. 该插件用来方便获得触屏以及滑动时触屏位置的坐标的
	2. NBRein是圆形手柄，传入适当的闭包，就可以在滑动这个手柄时进行对应的控制
	3. NBReinIndicator是坐标指示器，以屏幕宽为比照，设定一个虚拟宽度后，就可以自定义NBRein手柄返回的虚拟坐标，还可以在控制时，在屏幕上实时的显示当前坐标
* #####Tab3含有所有涉及3DTransform变换的研究与实验
	1. 含有缩放，平移，透视的正确算法解析，使用该算法可以重写缩放，平移，透视函数
	2. 其他有关官方接口的实验和结论
* #####Tab2：仅XOY面3D旋转效果演示
	1. 灰色圆形手柄就是被控制的Z轴，滑动该手柄，会获得控制Z轴带来的整个空间转动的效果
* #####Tab4：XOY面 + XOZ面 + YOZ面 3面的3D旋转效果演示
	1. 与Tab2性质相同，但是多个2个面
* #####3DTrans代码组 —— 3D矩阵运算支持
	1. matrix文件是网上摘录的矩阵运算函数（加、减、乘、求逆、矩阵值 ），有多处bug，和严重的效率问题
	2. matrix_my为改进的矩阵运算函数，纠正bug，提高运算效率，并针对iOS提供转换接口
	
###效果图：
![效果图](https://github.com/Davie-Billincon/3DTrans_1/blob/master/效果图.png?raw=true)