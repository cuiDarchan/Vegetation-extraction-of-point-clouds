1.Codes：源码文件
2.PointcloudGUI：利用源码文件生成的GUI文件
   1）EXE_Test：当本地拥有matlab环境时，可以直接打开Pointcloudprocessing.exe
   2）Install：有网络环境下安装程序所需环境，大约500M
   3）Resources：图片资源文件
3.Test_Data：
   test_data.txt 为测试点云数据集
   qz：去噪
   car：车辆点
   building：建筑物点
   ground：地面点
   vegetation：植被点
4.操作指南：
1）利用Pointcloudprocessing.exe，或者打开Install文件夹安装程序，点击读取txt点云文件，选择要处理的txt格式点云文件。
2）设置元胞尺寸，根据需要选择去噪或者各类地物操作。
3）完成后，点击生成las点云，选择输出路径即可，成功后会提示“恭喜处理成功！”

*******************************************************************************************************
注：
本人利用地物点云空间特征进行地相应提取，并未使用现有算法，有的小思路还需改进。