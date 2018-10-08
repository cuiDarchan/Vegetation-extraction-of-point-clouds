function [groundpoints,nogroundpoints]=Groundpoints_classification(Ave_m,B,threshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%groundpoints  获取的地面点云
%nogroundpoints非地面点云
%ave:          ave为缩放比例，一般取1
%B:            B为输入的点云矩阵，txt下一般为n*4格式
%threshold     阈值，经验上取2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 变量定义
Ave_Num=12;
ave=fix(sqrt((Ave_Num/Ave_m)))+1;
chajz=zeros(length(B),1);
tt=1;
d=1;                                                                      %地面点索引值
nd=1;                                                                     %非地面点索引值
h_threshlod=3;                                                            %高出阈值，直接判断为非地面点
zg=0;                                                                     %z相对坐标的估值
%% 获取16个格网内最低点，存入矩阵Qm（曲面）
% 加载数据B，变为正常n*5格式,分别为x,y,z,以及二维格网坐标值
len=length(B);
I=zeros(len,6);
for i=1:len
    I(i,1)=B(i,1);
    I(i,2)=B(i,2);
    I(i,3)=B(i,3);
    %I(i,6)=B(i,4);
end
% 写入胞元数据
xmin=min(I(:,1));
xmax=max(I(:,1));
ymin=min(I(:,2));
ymax=max(I(:,2));
ZMIN=min(I(:,3));                                 %全域最低值
for t=1:len
    I(t,4)=fix((I(t,1)-xmin)/ave)+1;
    I(t,5)=fix((I(t,2)-ymin)/ave)+1;
end
%% 将各个格网内部点封装到相应格网元胞内，方便索引
M=max(I(:,4));
N=max(I(:,5));
netcell=cell(M,N);                                %长M,宽N，二维格网尺度确定
count=zeros(M,N);
for i=1:len
    [p,~]=size(netcell{I(i,4),I(i,5)});           %初始时，p为0，将长宽 数据写入胞元内
    netcell{I(i,4),I(i,5)}(p+1,1)=I(i,1);         %langcell{}是指引用胞元内元素,与()有区别
    netcell{I(i,4),I(i,5)}(p+1,2)=I(i,2);
    netcell{I(i,4),I(i,5)}(p+1,3)=I(i,3);
    count(I(i,4),I(i,5))=count(I(i,4),I(i,5))+1;
end
%%  挑选6个拟合点的变量
%定义变量
Nh=6;                                             %Nh为拟合点个数
groundpoints=zeros(len,5);                        %为地面点分配内存空间
nogroundpoints=zeros(len,5);
cr=0.01;                                          %中心随机因子0.1
theshold_Num=4;                                   %找寻曲面中间的4个最低值
Qm=zeros(Nh,3);                                   %6个格网内Z第一低的值，用于拟合曲面
TQm=zeros(theshold_Num,3);                        %4个曲面中心格网内Z最低值
Rmin=30;
Rmax=60;
Rf=(fix(Rmin/ave)+1)*ave;
Rl=(fix(Rmax/ave))*ave;
R_num=(Rl-Rf)/ave+1;
RMatrix=zeros(R_num,4);
R_i=1;
for R=Rf:+ave:Rl
    RMatrix(R_i,1)=R;
    RMatrix(R_i,2)=mod(M*ave,R);
    RMatrix(R_i,3)=mod(N*ave,R);
    RMatrix(R_i,4)=RMatrix(R_i,2)+RMatrix(R_i,3);
    R_i=R_i+1;
end
R_min=min(RMatrix(:,4));
[row,~]=find(RMatrix(:,4)==R_min);
avec=RMatrix(row(1),1);
fg=avec/ave;                                      %大格网中分割的小格网个数
MM=fix(M*ave/avec)+1;                             %格网大尺度切分个数
NN=fix(N*ave/avec)+1;
RefNum=cell(MM,NN);                               %存放c0-c5六个参数的元胞
Zmi=zeros(MM,NN);                                 %Zmi用来过滤Z高出的点，优化速度
Zpc=zeros(MM,NN);                                 %Zpc为对应各个网格内的曲面中心
var_th=5;                                         %数据波动阈值
hz_th=1;                                          %选取随机点的阈值
yc_Matrix=ones(MM-1,NN-1);                        %异常处理矩阵
yc_Matrix2=ones(MM-1,NN-1);                       %异常处理矩阵2
%% 遍历大格网找寻参数
for ii=1:MM-1
    for jj=1:NN-1
        while 1
            Num=fix(fg*rand(1,1))+1;
            if Num>0.8*fg
                Num=Num-4;
            elseif Num<0.2*fg
                Num=Num+4;
            end
            %异常处理
            if isempty(netcell{Num+(ii-1)*fg,Num+(jj-1)*fg})==1||isempty(netcell{Num+(ii-1)*fg,Num+1+(jj-1)*fg})==1||isempty(netcell{Num+(ii-1)*fg,Num+2+(jj-1)*fg})==1 ...
                    ||isempty(netcell{Num+2+(ii-1)*fg,Num+(jj-1)*fg})==1||isempty(netcell{Num+2+(ii-1)*fg,Num+1+(jj-1)*fg})==1||isempty(netcell{Num+2+(ii-1)*fg,Num+2+(jj-1)*fg})==1
                yc_Matrix(ii,jj)=yc_Matrix(ii,jj)+1;
                if yc_Matrix(ii,jj)>=10                  %如果迭代10次还未找到Num，用上一方格中的Qm
                    break;
                end
                continue;
            end
            %找到6个最小值点
            x=1;
            for u=Num:+2:Num+2
                for l=Num:Num+2
                    netcell{u+(ii-1)*fg,l+(jj-1)*fg}=sortrows(netcell{u+(ii-1)*fg,l+(jj-1)*fg},3);
                    Qm(x,:)=netcell{u+(ii-1)*fg,l+(jj-1)*fg}(1,:);
                    x=x+1;
                end
            end
            %判别处理
            if jj==1&&ii==1
                bl1=mean(Qm(:,3))-(ZMIN+10);
            elseif jj~=1
                bl1=mean(Qm(:,3))-(Zmi(ii,jj-1)+3);
            elseif jj==1&&ii~=1
                bl1=mean(Qm(:,3))-(Zmi(ii-1,jj)+3);
            end
            bl2=var(Qm(:,3))-var_th;
            yc_Matrix2(ii,jj)=yc_Matrix2(ii,jj)+1;         %异常处理矩阵
            if yc_Matrix2(ii,jj)>=10                       %迭代10次停止
                break;
            end
            if (bl1<0&&bl2<0)
                break;
            end
        end
        %初始化求解6参数
        Center=mean(Qm);                                  %求解Qm矩阵的中心
        xp0=Center(1);yp0=Center(2);zp0=Center(3);
        syms a0 a1 a2 a3 a4 a5;
        for q=1:Nh
            eqn(q)=a0+a1*(Qm(q,1)-xp0)+a2*(Qm(q,2)-yp0)+a3*(Qm(q,1)-xp0).^2+a4*(Qm(q,1)-xp0)*(Qm(q,2)-yp0)+a5*(Qm(q,2)-yp0).^2-(Qm(q,3)-zp0);
        end
        [a0,a1,a2,a3,a4,a5]=solve(eqn(1),eqn(2),eqn(3),eqn(4),eqn(5),eqn(6),'a0','a1','a2','a3','a4','a5');
        c0=double(a0);c1=double(a1);c2=double(a2);c3=double(a3);c4=double(a4);c5=double(a5);
        RefNum{ii,jj}=[c0,c1,c2,c3,c4,c5];                %将求得的参数存放到对应坐标下
        Zmi(ii,jj)=mean(Qm(:,3));                         %Zmi用来过滤Z高出的点，优化速度
        Zpc(ii,jj)=zp0;                                   %Zpc为曲面中心
    end
end
%3个变量矩阵赋值RefNum，Zmi，Zpc
RefNum(ii+1,:)=RefNum(ii,:);RefNum(:,jj+1)=RefNum(:,jj);
Zmi(ii+1,:)=Zmi(ii,:);Zmi(:,jj+1)=Zmi(:,jj);
Zpc(ii+1,:)=Zpc(ii,:);Zpc(:,jj+1)=Zpc(:,jj);
%% 曲面拟合判别
%逐一添加newpoint
newpoint=zeros(1,3);
for i=1:M
    for j=1:N
        ii1=fix(i/fg)+1;
        jj1=fix(j/fg)+1;
        [p,~]=size(netcell{i,j});
        for k=1:p
            newpoint=netcell{i,j}(k,:);
            if newpoint(3)<Zmi(ii1,jj1)+h_threshlod;
                %一定范围内的随机中心
                xp=newpoint(1)+cr*(rand(1,1)*2-1);
                yp=newpoint(2)+cr*(rand(1,1)*2-1);
                zp=newpoint(3);
                zg=c0+c1*(newpoint(1)-xp)+c2*(newpoint(2)-yp)+c3*(newpoint(1)-xp).^2+c4*(newpoint(1)-xp)*(newpoint(2)-yp)+c5*(newpoint(2)-yp).^2+Zpc(ii1,jj1);
                cha=double(zg-zp);                                                 %cha为接近0的数
                chajz(tt,1)=cha;
                tt=tt+1;
                if abs(cha)<threshold
                    groundpoints(d,1:3)=newpoint;
                    d=d+1;
                else
                    nogroundpoints(nd,1:3)=newpoint;
                    nd=nd+1;
                end
            else
                nogroundpoints(nd,1:3)=newpoint;
                nd=nd+1;
            end
        end
    end
end
groundpoints=groundpoints(1:d-1,:);
nogroundpoints=nogroundpoints(1:nd-1,:);
end
